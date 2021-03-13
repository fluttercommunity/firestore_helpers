import 'package:cloud_firestore/cloud_firestore.dart';

class Location {
  final String name;
  // GeopPoints should not be serialized but passed as they are to FireStore
  final GeoPoint position;

  // we don't store the distance. This will be filled in during reading
  double? distance;

  Location(this.name, this.position);
  Map<String, dynamic> toMap() {
    Map<String, dynamic> ret = <String, dynamic>{};
    ret['name'] = name;
    ret['position'] = position;
    return ret;
  }

  static Location fromMap(Map map) {
    final obj =
        new Location(map['name'] as String? ?? 'NoLocationName', map['position'] as GeoPoint? ?? GeoPoint(-1, -1));
    return obj;
  }
}
