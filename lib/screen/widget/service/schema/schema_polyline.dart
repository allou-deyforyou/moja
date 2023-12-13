import 'dart:convert';

import 'package:equatable/equatable.dart';

import '_schema.dart';

class PolyLine extends Equatable {
  const PolyLine({
    this.type,
    this.coordinates,
  });

  static const String schema = 'polyline';

  static const String typeKey = 'type';
  static const String coordinatesKey = 'coordinates';

  final String? type;
  final List<List<double>>? coordinates;

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

  PolyLine copyWith({
    String? type,
    List<List<double>>? coordinates,
  }) {
    return PolyLine(
      type: type ?? this.type,
      coordinates: coordinates ?? this.coordinates,
    );
  }

  PolyLine clone() {
    return copyWith(
      type: type,
      coordinates: coordinates,
    );
  }

  static PolyLine fromMap(dynamic data) {
    return PolyLine(
      type: data[typeKey],
      coordinates: List.from((data[coordinatesKey] as List).map<List<double>>((item) => item.cast<double>())),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      typeKey: type,
      coordinatesKey: coordinates,
    }..removeWhere((key, value) => value == null);
  }

  Map<String, dynamic> toSurreal() {
    return {
      typeKey: type?.json(),
      coordinatesKey: coordinates,
    }..removeWhere((key, value) => value == null);
  }

  static PolyLine fromJson(String source) {
    return fromMap(jsonDecode(source));
  }

  String toJson() {
    return jsonEncode(toMap());
  }
}
