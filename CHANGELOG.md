## [3.2.1+1] - 07.11.2019

* Bump `cloud_firestore` version to 0.12.9+6,

## [3.2.0+1] - 26.06.2019

* updated logo in readme

## [3.2.0] - 22.05.2019

* Bump `cloud_firestore` version to 0.11.0+2, 


## [3.1.0] - 04.02.2019

* Bump up the version to use cloud_firestore 0.9.0, 
* add arrayContains of constraints

## [3.0.0] - 01.01.2019

* Fix in handling client side filters
* Fix of typo clientSite <-> clientSide

## [2.0.7] - 18.09.2018

* Added:
```Dart
/// [serverSideConstraints] : If you need some serverside filtering besides the [Area] pass a list of [QueryConstraint]
/// [serverSideOrdering] : If you need some serverside ordering you can pass a List of [OrderConstraints]
```
To `getDataInArea()`

## [2.0.6] - 06.09.2018

* Updated dependency to cloud_firestore 0.8.0## 

## [2.0.5] - 07.08.2018

* `buildQuery` now accepts a Query as data source, before only DocumentCollections were possible.

## [2.0.4] - 04.08.2018

* `getDataInArea` now accepts a Query as data source, before only DocumentCollections were possible.

## [2.0.3] - 11.07.2018

* Fixed a bug in distance calculation.

## [2.0.2] - 10.07.2018

* If you provide a `datalocationAccessor` to `getDataInArea` the results are not additionally filtered so that you only get places within the given radius not in a square. Also some bug fixes.

## [2.0.0] - 03.07.2018

* Breaking changes in naming of Area members and adding more functions

##[1.0.0] - 30.06.2018

* Initial release.










