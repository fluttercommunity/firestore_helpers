// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'location.dart';

// **************************************************************************
// JaguarSerializerGenerator
// **************************************************************************

abstract class _$LocationSerializer implements Serializer<Location> {
  final _passProcessor = const PassProcessor();
  @override
  Map<String, dynamic> toMap(Location model) {
    if (model == null) return null;
    Map<String, dynamic> ret = <String, dynamic>{};
    setMapValue(ret, 'name', model.name);
    setMapValue(ret, 'position', _passProcessor.serialize(model.position));
    return ret;
  }

  @override
  Location fromMap(Map map) {
    if (map == null) return null;
    final obj = new Location(
        map['name'] as String ?? getJserDefault('name'),
        _passProcessor.deserialize(map['position']) as GeoPoint ??
            getJserDefault('position'));
    return obj;
  }
}
