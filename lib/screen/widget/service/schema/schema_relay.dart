import 'dart:convert';

import 'package:equatable/equatable.dart';

import '_schema.dart';

enum RelayAvailability {
  enabled,
  disabled;

  String toJson() {
    return name;
  }

  @override
  String toString() {
    return switch (this) {
      RelayAvailability.enabled => 'time::now()',
      RelayAvailability.disabled => 'NONE',
    };
  }
}

class Relay extends Equatable {
  const Relay({
    this.createdAt,
    required this.id,
    this.availability,
    required this.name,
    required this.image,
    required this.location,
    required this.contacts,
  });

  static const String schema = 'relay';

  static const String idKey = 'id';
  static const String nameKey = 'name';
  static const String imageKey = 'image';
  static const String locationKey = 'location';
  static const String contactsKey = 'contacts';
  static const String createdAtKey = 'created_at';
  static const String availabilityKey = 'availability';

  final String id;
  final String name;
  final String? image;
  final Place? location;
  final DateTime? createdAt;
  final DateTime? availability;
  final List<String>? contacts;

  @override
  List<Object?> get props {
    return [
      id,
      name,
      image,
      location,
      contacts,
      createdAt,
      availability,
    ];
  }

  Relay copyWith({
    String? id,
    String? name,
    String? image,
    Place? location,
    DateTime? createdAt,
    DateTime? availability,
    List<String>? contacts,

    /// Edges
  }) {
    return Relay(
      id: id ?? this.id,
      name: name ?? this.name,
      image: image ?? this.image,
      location: location ?? this.location,
      contacts: contacts ?? this.contacts,
      createdAt: createdAt ?? this.createdAt,
      availability: availability ?? this.availability,
    );
  }

  Relay clone() {
    return copyWith(
      id: id,
      name: name,
      image: image,
      contacts: contacts,
      location: location,
      createdAt: createdAt,
      availability: availability,
    );
  }

  static Relay? fromMap(dynamic data) {
    if (data == null) return null;
    return Relay(
      id: data[idKey],
      name: data[nameKey],
      image: data[imageKey],
      location: Place.fromMap(data[locationKey]),
      contacts: data[contactsKey]?.cast<String>(),
      createdAt: DateTime.tryParse(data[createdAtKey].toString()),
      availability: DateTime.tryParse(data[availabilityKey].toString()),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      idKey: id,
      nameKey: name,
      imageKey: image,
      contactsKey: contacts,
      locationKey: location?.toMap(),
      createdAtKey: createdAt?.toString(),
      availabilityKey: availability?.toString(),
    }..removeWhere((key, value) => value == null);
  }

  Map<String, dynamic> toSurreal() {
    return {
      idKey: id,
      nameKey: name.json(),
      imageKey: image?.json(),
      locationKey: location?.toMap(),
      createdAtKey: createdAt?.toString(),
      availabilityKey: availability?.toString(),
      contactsKey: contacts?.map((e) => e.json()),
    }..removeWhere((key, value) => value == null);
  }

  static Relay fromJson(String source) {
    return fromMap(jsonDecode(source))!;
  }

  String toJson() {
    return jsonEncode(toMap());
  }
}
