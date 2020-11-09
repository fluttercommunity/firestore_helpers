import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:jaguar_serializer/jaguar_serializer.dart';

part 'location.jser.dart';

class Location {
  final String name;
  @pass // GeopPoints should not be serialized but passed as they are to FireStore
  final GeoPoint position;

  @ignore // we don't store the distance. This will be filled in during reading
  double distance;

  Location(this.name, this.position);
}

// We use jaguar_serializer to serialize the Location object
@GenSerializer()
class LocationSerializer extends Serializer<Location>
    with _$LocationSerializer {}
