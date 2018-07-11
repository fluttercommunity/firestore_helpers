import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firestore_helpers/firestore_helpers.dart';
import 'package:test/test.dart';

main() {
  test("Distance Test1", () {
    var distance = distanceInKilometers(
        new GeoPoint(42.825932, 13.715370), new GeoPoint(42.753814, 13.966505));
    print(distance);

    expect(distance, closeTo(22.0, 3.0));
  });

  test("Distance2 Test1", () {
    var distance = distanceInKilometers2(
        new GeoPoint(42.825932, 13.715370), new GeoPoint(42.753814, 13.966505));
    print(distance);

    expect(distance, closeTo(22.0, 3.0));
  });


  test("Distance Test2", () {
    var distance = distanceInKilometers(
        new GeoPoint(50.73743, 7.0982068), new GeoPoint(50.937531, 6.960279));
    print(distance);

    expect(distance, closeTo(22.0, 3.0));
  });

  test("Distance2 Test2", () {
    var distance = distanceInKilometers2(
        new GeoPoint(50.73743, 7.0982068), new GeoPoint(50.937531, 6.960279));
    print(distance);

    expect(distance, closeTo(22.0, 3.0));
  });


  test("Distance Test3", () {
    var distance = distanceInKilometers(
        new GeoPoint(50.73743, 7.0982068), new GeoPoint(50.683861199999996, 7.1491171));
    print(distance);

    expect(distance, closeTo(5.0, 3.0));
  });



  test("Distance2 Test3", () {
    var distance = distanceInKilometers2(
        new GeoPoint(50.73743, 7.0982068), new GeoPoint(50.683861199999996, 7.1491171));
    print(distance);

    expect(distance, closeTo(5.0, 3.0));
  });
}
