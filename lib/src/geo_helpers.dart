// from https://stackoverflow.com/questions/46630507/how-to-run-a-geo-nearby-query-with-firestore

import 'dart:async';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firestore_helpers/firestore_helpers.dart';

///
/// Checks if these coordinates are valid geo coordinates.
/// [latitude]  The latitude must be in the range [-90, 90]
/// [longitude] The longitude must be in the range [-180, 180]
/// returns [true] if these are valid geo coordinates
///
bool coordinatesValid(double latitude, double longitude) {
  return (latitude >= -90 && latitude <= 90 && longitude >= -180 && longitude <= 180);
}

///
/// Checks if the coordinates  of a GeopPoint are valid geo coordinates.
/// [latitude]  The latitude must be in the range [-90, 90]
/// [longitude] The longitude must be in the range [-180, 180]
/// returns [true] if these are valid geo coordinates
///
bool geoPointValid(GeoPoint point) {
  return (point.latitude >= -90 && point.latitude <= 90 && point.longitude >= -180 && point.longitude <= 180);
}

///
/// Wraps the longitude to [-180,180].
///
/// [longitude] The longitude to wrap.
/// returns The resulting longitude.
///
double wrapLongitude(double longitude) {
  if (longitude <= 180 && longitude >= -180) {
    return longitude;
  }
  final adjusted = longitude + 180;
  if (adjusted > 0) {
    return (adjusted % 360) - 180;
  }
  // else
  return 180 - (-adjusted % 360);
}

double degreesToRadians(double degrees) {
  return (degrees * pi) / 180;
}

///
///Calculates the number of degrees a given distance is at a given latitude.
/// [distance] The distance to convert.
/// [latitude] The latitude at which to calculate.
/// returns the number of degrees the distance corresponds to.
double kilometersToLongitudeDegrees(double distance, double latitude) {
  const EARTH_EQ_RADIUS = 6378137.0;
  // this is a super, fancy magic number that the GeoFire lib can explain (maybe)
  const E2 = 0.00669447819799;
  const EPSILON = 1e-12;
  final radians = degreesToRadians(latitude);
  final numerator = cos(radians) * EARTH_EQ_RADIUS * pi / 180;
  final denom = 1 / sqrt(1 - E2 * sin(radians) * sin(radians));
  final deltaDeg = numerator * denom;
  if (deltaDeg < EPSILON) {
    return distance > 0 ? 360.0 : 0.0;
  }
  // else
  return min(360.0, distance / deltaDeg);
}

///
/// Defines the boundingbox for the query based
/// on its south-west and north-east corners
class GeoBoundingBox {
  final GeoPoint swCorner;
  final GeoPoint neCorner;

  GeoBoundingBox({required this.swCorner, required this.neCorner});
}

///
/// Defines the search area by a  circle [center] / [radiusInKilometers]
/// Based on the limitations of FireStore we can only search in rectangles
/// which means that from this definition a final search square is calculated
/// that contains the circle
class Area {
  final GeoPoint center;
  final double radiusInKilometers;

  Area(this.center, this.radiusInKilometers)
      : assert(geoPointValid(center)),
        assert(radiusInKilometers >= 0);

  factory Area.inMeters(GeoPoint gp, int radiusInMeters) {
    return new Area(gp, radiusInMeters / 1000.0);
  }

  factory Area.inMiles(GeoPoint gp, int radiusMiles) {
    return new Area(gp, radiusMiles * 1.60934);
  }

  /// returns the distance in km of [point] to center
  double distanceToCenter(GeoPoint point) {
    return distanceInKilometers(center, point);
  }
}

///
///Calculates the SW and NE corners of a bounding box around a center point for a given radius;
/// [area] with the center given as .latitude and .longitude
/// and the radius of the box (in kilometers)
GeoBoundingBox boundingBoxCoordinates(Area area) {
  const KM_PER_DEGREE_LATITUDE = 110.574;
  final latDegrees = area.radiusInKilometers / KM_PER_DEGREE_LATITUDE;
  final latitudeNorth = min(90.0, area.center.latitude + latDegrees);
  final latitudeSouth = max(-90.0, area.center.latitude - latDegrees);
  // calculate longitude based on current latitude
  final longDegsNorth = kilometersToLongitudeDegrees(area.radiusInKilometers, latitudeNorth);
  final longDegsSouth = kilometersToLongitudeDegrees(area.radiusInKilometers, latitudeSouth);
  final longDegs = max(longDegsNorth, longDegsSouth);
  return new GeoBoundingBox(
      swCorner: new GeoPoint(latitudeSouth, wrapLongitude(area.center.longitude - longDegs)),
      neCorner: new GeoPoint(latitudeNorth, wrapLongitude(area.center.longitude + longDegs)));
}

///
/// Calculates the distance, in kilometers, between two locations, via the
/// Haversine formula. Note that this is approximate due to the fact that
/// the Earth's radius varies between 6356.752 km and 6378.137 km.
/// [p1] The first location given
/// [p2] The second location given
/// return the distance, in kilometers, between the two locations.
///
double distanceInKilometers(GeoPoint p1, GeoPoint p2) {
  final dlat = degreesToRadians(p2.latitude - p1.latitude);
  final dlon = degreesToRadians(p2.longitude - p1.longitude);
  final lat1 = degreesToRadians(p1.latitude);
  final lat2 = degreesToRadians(p2.latitude);

  final r = 6378.137; // WGS84 major axis
  double c = 2 * asin(sqrt(pow(sin(dlat / 2), 2) + cos(lat1) * cos(lat2) * pow(sin(dlon / 2), 2)));
  return r * c;
}

// Spherical Law of Cosines
double distanceInKilometers2(GeoPoint p1, GeoPoint p2) {
  final earthRadius = 6378.137; // WGS84 major axis

  final lon1 = degreesToRadians(p1.longitude);
  final lon2 = degreesToRadians(p2.longitude);
  final lat1 = degreesToRadians(p1.latitude);
  final lat2 = degreesToRadians(p2.latitude);

  final distance = acos(sin(lat1) * sin(lat2) + cos(lat1) * cos(lat2) * cos(lon2 - lon1));
  return distance * earthRadius;
}

///
/// Creates the necessary constraints to query for items in a FireStore collection that are inside a specific range from a center point
/// [fieldName] : the name of the field in FireStore where the location of the items is stored
/// [area] : Area within that the returned items should be
List<QueryConstraint> getLocationsConstraint(String fieldName, Area area) {
  // calculate the SW and NE corners of the bounding box to query for
  final box = boundingBoxCoordinates(area);

  // construct the GeoPoints
  final lesserGeopoint = box.swCorner;
  final greaterGeopoint = box.neCorner;

  assert(box.swCorner.latitude < box.neCorner.latitude);
  assert(box.swCorner.longitude < box.neCorner.longitude);
  // print( "LOC: ${area.center.latitude}/${area.center.longitude}");
  // print( "SW: ${box.swCorner.latitude}/${box.swCorner.longitude}");
  // print( "NE: ${box.neCorner.latitude}/${box.neCorner.longitude}");

  List<QueryConstraint> query = <QueryConstraint>[
    new QueryConstraint(
      field: fieldName,
      isLessThan: greaterGeopoint,
    ),
    new QueryConstraint(
      field: fieldName,
      isGreaterThan: lesserGeopoint,
    )
  ];

  return query;
}

/// function typse used to acces the field that contains the loaction inside
/// the generic type
typedef LocationAccessor<T> = GeoPoint Function(T item);

/// function typse used to access the distance field that contains the
/// distance to the target inside the generic type
typedef DistanceAccessor<T> = double Function(T item);

typedef DistanceMapper<T> = T Function(T item, double itemsDistance);

///
/// Provides as Stream of lists of data items of type [T] that have a location field in a
/// specified area sorted by the distance of to the areas center.
/// [area]  : The area that constraints the query
/// [source] : The source FireStore document collection
/// [mapper] : mapping function that gets applied to every document in the query.
/// Typically used to deserialize the Map returned from FireStore
/// [locationFieldInDb] : The name of the data field in your FireStore document.
/// Need to make the location based search on the server side
/// [locationAccessor] : As this is a generic function it cannot know where your
/// location is stored in you generic type.
/// optional if you don't use [distanceMapper] and don't want to sort by distance
/// Therefore pass a function that returns a valur from the location field inside
/// your generic type.
/// [distanceMapper] : optional mapper that gets the distance to the center of the
/// area passed to give you the chance to save this inside your item
/// if you use a [distanceMapper] you HAVE to pass [locationAccessor]
/// [clientSideFilters] : optional list of filter functions that execute a `.where()`
/// on the result on the client side
/// [distanceAccessor] : if you have stored the distance using a [distanceMapper] passing
/// this accessor function will prevent additional distance computing for sorting.
/// [sortDecending] : if the resulting list should be sorted descending by the distance
/// to the area's center. If you don't provide [loacationAccessor] or [distanceAccessor]
/// no sorting is done. This Sorting is done one the client side
/// [serverSideConstraints] : If you need some serverside filtering besides the [Area] pass a list of [QueryConstraint]
/// [serverSideOrdering] : If you need some serverside ordering you can pass a List of [OrderConstraints]
/// Using [serverSideConstraints] or  [serverSideOrdering] almost always requires to create an index for
/// this field. Check your debug output for a message from FireStore with
/// a link to create them
Stream<List<T>> getDataInArea<T>(
    {required Area area,
    required Query source,
    required DocumentMapper<T> mapper,
    required String locationFieldNameInDB,
    LocationAccessor<T>? locationAccessor,
    List<ItemFilter<T>>? clientSidefilters,
    DistanceMapper<T>? distanceMapper,
    DistanceAccessor<T>? distanceAccessor,
    bool sortDecending = false,
    List<QueryConstraint>? serverSideConstraints,
    List<OrderConstraint>? serverSideOrdering}) {
  assert(
    (distanceAccessor == null) || (distanceMapper != null && distanceAccessor != null),
  );

  if (serverSideOrdering != null) {
    serverSideOrdering.insert(0, new OrderConstraint(locationFieldNameInDB, false));
  }

  var constraints = getLocationsConstraint(locationFieldNameInDB, area);
  if (serverSideConstraints != null) {
    constraints.addAll(serverSideConstraints);
  }

  var query = buildQuery(collection: source, constraints: constraints, orderBy: serverSideOrdering);

  // as we replace items ouside the target circle at the corners of the surrounding square with null we have to filter
  // them out on the clients side
  if (clientSidefilters != null) {
    clientSidefilters..insert(0, (item) => item != null);
  } else {
    clientSidefilters = [(item) => item != null];
  }

  return getDataFromQuery<T /*!*/ >(
      query: query,
      mapper: (docSnapshot) {
        // get a real objects from FireStore
        var item = mapper(docSnapshot);
        double distance;
        if (locationAccessor != null) {
          distance = area.distanceToCenter(locationAccessor(item!));
          // We might get places outside the target circle at the corners of the surrounding square
          if (distance > area.radiusInKilometers) {
            return null;
          }
          if (distanceMapper != null) {
            return distanceMapper(item, distance);
          }
        }
        return item;
      },
      clientSidefilters: clientSidefilters,
      orderComparer: distanceAccessor != null // i this case we don't have to calculate the distance again
          ? (item1, item2) => sortDecending
              ? distanceAccessor(item1).compareTo(distanceAccessor(item2))
              : distanceAccessor(item2).compareTo(distanceAccessor(item1))
          : locationAccessor != null
              ? (item1, item2) => sortDecending
                  ? area
                      .distanceToCenter(locationAccessor(item1))
                      .compareTo(area.distanceToCenter(locationAccessor(item2)))
                  : area
                      .distanceToCenter(locationAccessor(item2))
                      .compareTo(area.distanceToCenter(locationAccessor(item1)))
              : null);
}
