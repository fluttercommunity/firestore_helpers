// from https://stackoverflow.com/questions/46630507/how-to-run-a-geo-nearby-query-with-firestore

import 'dart:math' as math;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firestore_helpers/firestore_helpers.dart';

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
  return (degrees * math.pi) / 180;
}

///
///Calculates the number of degrees a given distance is at a given latitude.
/// [distance] The distance to convert.
/// [latitude] The latitude at which to calculate.
/// returns the number of degrees the distance corresponds to.
double metersToLongitudeDegrees(double distance, double latitude) {
  const EARTH_EQ_RADIUS = 6378137.0;
  // this is a super, fancy magic number that the GeoFire lib can explain (maybe)
  const E2 = 0.00669447819799;
  const EPSILON = 1e-12;
  final radians = degreesToRadians(latitude);
  final num = math.cos(radians) * EARTH_EQ_RADIUS * math.pi / 180;
  final denom = 1 / math.sqrt(1 - E2 * math.sin(radians) * math.sin(radians));
  final deltaDeg = num * denom;
  if (deltaDeg < EPSILON) {
    return distance > 0 ? 360.0 : 0.0;
  }
  // else
  return math.min(360.0, distance / deltaDeg);
}

///
/// Defines the boundingbox for the query based
/// on its south-west and north-east corners
class GeoBoundingBox {
  final GeoPoint swCorner;
  final GeoPoint neCorner;

  GeoBoundingBox({this.swCorner, this.neCorner});
}

///
/// Defines the search area by a  circle [center] / [radius]
/// Based on the limitations of FireStore we can only search in rectangles
/// which means that from this definition a final search square is calculated
/// that contains the circle
class Area {
  final GeoPoint center;
  final double radius;

  Area(this.center, this.radius);
}

///
///Calculates the SW and NE corners of a bounding box around a center point for a given radius;
/// [area] with the center given as .latitude and .longitude
/// and the radius of the box (in kilometers)
GeoBoundingBox boundingBoxCoordinates(Area area) {
  const KM_PER_DEGREE_LATITUDE = 110.574;
  final latDegrees = area.radius / KM_PER_DEGREE_LATITUDE;
  final latitudeNorth = math.min(90.0, area.center.latitude + latDegrees);
  final latitudeSouth = math.max(-90.0, area.center.latitude - latDegrees);
  // calculate longitude based on current latitude
  final longDegsNorth = metersToLongitudeDegrees(area.radius, latitudeNorth);
  final longDegsSouth = metersToLongitudeDegrees(area.radius, latitudeSouth);
  final longDegs = math.max(longDegsNorth, longDegsSouth);
  return new GeoBoundingBox(
      swCorner: new GeoPoint(latitudeSouth, wrapLongitude(area.center.longitude - longDegs)),
      neCorner: new GeoPoint(latitudeNorth, wrapLongitude(area.center.longitude + longDegs)));
}

///
/// Calculates the distance, in kilometers, between two locations, via the
/// Haversine formula. Note that this is approximate due to the fact that
/// the Earth's radius varies between 6356.752 km and 6378.137 km.
/// [location1] The first location given
/// [location2] The second location given
/// sreturn the distance, in kilometers, between the two locations.
///
double distance(GeoPoint location1, GeoPoint location2) {
  const radius = 6371; // Earth's radius in kilometers
  final latDelta = degreesToRadians(location2.latitude - location1.latitude);
  final lonDelta = degreesToRadians(location2.longitude - location1.longitude);

  final a = (math.sin(latDelta / 2) * math.sin(latDelta / 2)) +
      (math.cos(degreesToRadians(location1.latitude)) *
          math.cos(degreesToRadians(location2.latitude)) *
          math.sin(lonDelta / 2) *
          math.sin(lonDelta / 2));

  final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));

  return radius * c;
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
