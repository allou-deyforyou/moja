import 'dart:convert';

import 'package:equatable/equatable.dart';

import '_schema.dart';

class Point extends Equatable {
  const Point({
    this.type,
    this.coordinates,
  });

  static const String schema = 'Point';

  static const String typeKey = 'type';
  static const String coordinatesKey = 'coordinates';

  final String? type;
  final List<double>? coordinates;

  @override
  String toString() {
    return toMap().toString();
  }

  @override
  List<Object?> get props {
    return [
      type,
      coordinates,
    ];
  }

  Point copyWith({
    String? type,
    List<double>? coordinates,
  }) {
    return Point(
      type: type ?? this.type,
      coordinates: coordinates ?? this.coordinates,
    );
  }

  Point clone() {
    return copyWith(
      type: type,
      coordinates: coordinates,
    );
  }

  static Point fromMap(dynamic data) {
    return Point(
      type: data[typeKey],
      coordinates: data[coordinatesKey].cast<double>(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      typeKey: type ?? 'Point',
      coordinatesKey: coordinates,
    }..removeWhere((key, value) => value == null);
  }

  Map<String, dynamic> toSurreal() {
    return {
      typeKey: type?.json() ?? '"Point"',
      coordinatesKey: coordinates,
    }..removeWhere((key, value) => value == null);
  }

  static Point fromJson(String source) {
    return fromMap(jsonDecode(source));
  }

  String toJson() {
    return jsonEncode(toMap());
  }
}
