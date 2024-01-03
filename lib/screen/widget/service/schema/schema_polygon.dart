import 'dart:math';
import 'dart:convert';

import 'package:equatable/equatable.dart';

import '_schema.dart';

class Polygon extends Equatable {
  const Polygon({
    this.type,
    this.coordinates,
  });

  static Polygon decode(String str, {int precision = 5}) {
    var index = 0;
    var lat = 0.0;
    var lng = 0.0;
    var coordinates = <List<double>>[];
    var shift = 0;
    var result = 0;
    var byte = 0;
    var latitudeChange = 0.0;
    var longitudeChange = 0.0;
    var factor = pow(10, precision);

    while (index < str.length) {
      // Reset shift, result, and byte
      byte = 0;
      shift = 1;
      result = 0;

      do {
        byte = str.codeUnitAt(index++) - 63;
        result += (byte & 0x1f) * shift;
        shift *= 32;
      } while (byte >= 0x20);

      latitudeChange = (result & 1) != 0 ? ((-result - 1) / 2) : (result / 2);

      shift = 1;
      result = 0;

      do {
        byte = str.codeUnitAt(index++) - 63;
        result += (byte & 0x1f) * shift;
        shift *= 32;
      } while (byte >= 0x20);

      longitudeChange = (result & 1) != 0 ? ((-result - 1) / 2) : (result / 2);

      lat += latitudeChange;
      lng += longitudeChange;

      coordinates.add([(lng / factor).toDouble(), (lat / factor).toDouble()]);
    }

    return Polygon(coordinates: coordinates);
  }

  static Polygon? fromRadius(List<double>? center, double radius, {int sides = 360}) {
    if (center == null || center.length != 2) return null;

    final longitude = center[0];
    final latitude = center[1];

    List<List<double>> coordinates = [];

    for (int i = 0; i <= sides; i++) {
      double theta = (2 * pi * i) / sides;

      double x = latitude + (radius / 111111) * cos(theta);
      double y = longitude + (radius / (111111 * cos(latitude))) * sin(theta);

      coordinates.add([y, x]);
    }

    return Polygon(coordinates: coordinates);
  }

  static const String schema = 'polygon';

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

  Polygon copyWith({
    String? type,
    List<List<double>>? coordinates,
  }) {
    return Polygon(
      type: type ?? this.type,
      coordinates: coordinates ?? this.coordinates,
    );
  }

  Polygon clone() {
    return copyWith(
      type: type,
      coordinates: coordinates,
    );
  }

  static Polygon fromMap(dynamic data) {
    return Polygon(
      type: data[typeKey],
      coordinates: List.from((data[coordinatesKey] as List).map<List<double>>((item) => item.cast<double>())),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      typeKey: type ?? "Polygon",
      coordinatesKey: coordinates,
    }..removeWhere((key, value) => value == null);
  }

  Map<String, dynamic> toSurreal() {
    return {
      coordinatesKey: '[$coordinates]',
      typeKey: type?.json() ?? '"Polygon"',
    }..removeWhere((key, value) => value == null);
  }

  static Polygon fromJson(String source) {
    return fromMap(jsonDecode(source));
  }

  String toJson() {
    return jsonEncode(toMap());
  }
}
