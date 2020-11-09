import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firestore_helpers/firestore_helpers.dart';
import 'package:firestorehelpertest/location.dart';

class DatabaseService {
  final locationCollection = FirebaseFirestore.instance.collection("locations");

  Future<void> createLocation(Location loc) async {
    locationCollection.doc().set(LocationSerializer().toMap(loc));
  }

  Stream<List<Location>> getLocations({GeoPoint center, double radiusInKm}) {
    return getDataInArea<Location>(
        source: locationCollection,
        area: Area(center, radiusInKm),
        locationFieldNameInDB: 'position',
        mapper: (doc) =>
            LocationSerializer().fromMap(doc.data as Map<String, dynamic>),
        locationAccessor: (item) => item.position,
        // The distancemapper is applied after the mapper
        distanceMapper: (item, dist) {
          item.distance = dist;
          return item;
        });
  }
}
