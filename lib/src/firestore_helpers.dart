import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

/// Used by [buildQuery] to define a list of constraints. Important besides the [field] property not more than one of the others can ne [!=null].
/// They corespond to the possisble parameters of Firestore`s [where()] method.
class QueryConstraint {
  final String field;
  final dynamic isEqualTo;
  final dynamic isLessThan;
  final dynamic isLessThanOrEqualTo;
  final dynamic isGreaterThan;
  final dynamic isGreaterThanOrEqualTo;
  final bool isNull;

  QueryConstraint(
      {this.field,
      this.isEqualTo,
      this.isLessThan,
      this.isLessThanOrEqualTo,
      this.isGreaterThan,
      this.isGreaterThanOrEqualTo,
      this.isNull});
}

/// Used by [buildQuery] to define how the results should be ordered. The fields
/// corespond to the possisble parameters of Firestore`s [oderby()] method.
class OrderConstraint {
  final String field;
  final bool descending;

  OrderConstraint(this.field, this.descending);
}

///
/// Builds a query dynamically based on a list of [QueryConstraint] and orders the result based on a list of [OrderConstraint].
/// [collection] : the source collection for the new query
/// [constraints] : a list of constraints that should be applied to the [collection].
/// [orderBy] : a list of order constraints that should be applied to the [collection] after the filtering by [constraints] was done.
/// Important all limitation of FireStore apply for this method two on how you can query fields in collections and order them.
Query buildQuery(
    {CollectionReference collection,
    List<QueryConstraint> constraints,
    List<OrderConstraint> orderBy}) {
  Query ref = collection;

  if (constraints != null) {
    for (var constraint in constraints) {
      ref = ref.where(constraint.field,
          isEqualTo: constraint.isEqualTo,
          isGreaterThan: constraint.isGreaterThan,
          isGreaterThanOrEqualTo: constraint.isGreaterThanOrEqualTo,
          isLessThan: constraint.isLessThan,
          isLessThanOrEqualTo: constraint.isLessThanOrEqualTo,
          isNull: constraint.isNull);
    }
  }
  if (orderBy != null) {
    for (var order in orderBy) {
      ref = ref.orderBy(order.field, descending: order.descending);
    }
  }
  return ref;
}

typedef DocumentMapper<T> = T Function(DocumentSnapshot document);

///
/// Convenience Method to access the data of a Query as a stream while applying a mapping function on each document
/// [qery] : the data source
/// [mapper] : mapping function that gets applied to every document in the query.
Stream<List<T>> getData<T>(Query query, DocumentMapper<T> mapper) {
  return query.snapshots().map((snapShot) => snapShot.documents.map(mapper).toList());
}
