import 'dart:convert';

import 'package:equatable/equatable.dart';

import '_schema.dart';

class Box extends Equatable {
  const Box({
    required this.id,
    required this.name,
    required this.phone,
    required this.location,
  });

  static const String schema = 'boxs';

  static const String idKey = 'id';
  static const String nameKey = 'name';
  static const String phoneKey = 'phone';
  static const String locationKey = 'location';

  final String id;
  final String name;
  final String phone;
  final Place location;

  @override
  String toString() {
    return toMap().toString();
  }

  @override
  List<Object?> get props {
    return [
      id,
      name,
      phone,
      location,
    ];
  }

  Box copyWith({
    String? id,
    String? name,
    String? phone,
    Place? location,
  }) {
    return Box(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      location: location ?? this.location,
    );
  }

  Box clone() {
    return copyWith(
      id: id,
      name: name,
      phone: phone,
      location: location,
    );
  }

  static Box fromMap(Map<String, dynamic> data) {
    return Box(
      id: data[idKey],
      name: data[nameKey],
      phone: data[phoneKey],
      location: data[locationKey],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      idKey: id,
      nameKey: name,
      phoneKey: phone,
      locationKey: location.toMap(),
    }..removeWhere((key, value) => value == null);
  }

  static List<Box> fromListMap(List<Map<String, dynamic>> data) {
    return List.of(data.map((value) => fromMap(value)));
  }

  static List<Map<String, dynamic>> toListMap(List<Box> values) {
    return List.of(values.map((value) => value.toMap()));
  }

  static Box fromJson(String source) {
    return fromMap(jsonDecode(source));
  }

  String toJson() {
    return jsonEncode(toMap());
  }

  static List<Box> fromListJson(String source) {
    return List.of((jsonDecode(source) as List).map((value) => fromMap(value)));
  }

  static String toListJson(List<Box> values) {
    return jsonEncode(values.map((value) => value.toMap()));
  }
}
