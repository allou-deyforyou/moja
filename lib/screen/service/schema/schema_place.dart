import 'dart:convert';

import 'package:equatable/equatable.dart';

class Place extends Equatable {
  const Place({
    this.city,
    this.locality,
    this.state,
    this.name,
    this.country,
    this.position,
  });

  static const String schema = 'places';

  static const String cityKey = 'city';
  static const String localityKey = 'locality';
  static const String stateKey = 'state';
  static const String nameKey = 'name';
  static const String countryKey = 'country';
  static const String positionKey = 'position';

  final String? city;
  final String? locality;
  final String? state;
  final String? name;
  final String? country;
  final (double, double)? position;

  @override
  String toString() {
    return toMap().toString();
  }

  @override
  List<Object?> get props {
    return [
      city,
      locality,
      state,
      name,
      country,
      position,
    ];
  }

  Place copyWith({
    String? city,
    String? locality,
    String? state,
    String? name,
    String? country,
    (double, double)? position,
  }) {
    return Place(
      city: city ?? this.city,
      locality: locality ?? this.locality,
      state: state ?? this.state,
      name: name ?? this.name,
      country: country ?? this.country,
      position: position ?? this.position,
    );
  }

  Place clone() {
    return copyWith(
      city: city,
      locality: locality,
      state: state,
      name: name,
      country: country,
      position: position,
    );
  }

  static List<Place> fromListMap(List<Map<String, dynamic>> data) {
    return data.map((e) => fromMap(e)).toList();
  }

  static Place fromMap(Map<String, dynamic> data) {
    return Place(
      city: data[cityKey],
      name: data[nameKey],
      state: data[stateKey],
      country: data[countryKey],
      locality: data[localityKey],
      position: (data[positionKey]),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      nameKey: name,
      cityKey: city,
      stateKey: state,
      countryKey: country,
      localityKey: locality,
      positionKey: position,
    }..removeWhere((key, value) => value == null);
  }

  static Place fromJson(String source) {
    return fromMap(jsonDecode(source));
  }

  static List<Place> fromListJson(String source) {
    return List.of((jsonDecode(source) as List).map((data) => fromMap(data)));
  }

  static String toListJson(List<Place> values) {
    return jsonEncode(List.of(values.map((value) => value.toMap())));
  }

  String toJson() {
    return jsonEncode(toMap());
  }
}
