import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:test/test.dart';
import 'package:firestore_helpers/firestore_helpers.dart';

const List<Map<String, dynamic>> hairdressersMock = [
  {'name': 'carmelina', 'position': const GeoPoint(42.822598, 13.710538), 'id': 'carmelina_id'},
  {'name': 'enzio', 'position': const GeoPoint(42.811002, 13.733058), 'id': 'enzio_id'},
  {'name': 'vizio', 'position': const GeoPoint(42.818818, 13.721902), 'id': 'vizio_id'},
  {
    'name': 'franco lu barbiere',
    'position': const GeoPoint(42.825702, 13.712359),
    'id': 'franco_id'
  },
  {
    'name': 'giulianova parrucchiere',
    'position': const GeoPoint(42.822448, 13.710180),
    'id': 'giulianova_id'
  },
  {'name': 'delizia', 'position': const GeoPoint(42.813138, 13.727661), 'id': 'delizia_id'},
  {'name': 'casa', 'position': const GeoPoint(42.324322, 13.7075033), 'id': 'casa_id'},
];

class HairDresserData {
  HairDresser event;
  double distance;

  HairDresserData(this.event, [this.distance]);
}

class HairDresser {
  String id;

  String name;
  GeoPoint location;

  HairDresser();

  HairDresser.fromMap(Map map) {
    location = map['position'];
    name = map['name'] ?? 'bpo';
    id = map['id'];
  }
}

main() {

  CollectionReference

  test("All within Aera", () {

     var data = getDataInArea<HairDresserData>()

  });
}
