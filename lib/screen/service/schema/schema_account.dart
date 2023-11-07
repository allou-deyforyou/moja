import 'dart:convert';

import 'package:equatable/equatable.dart';

class Account extends Equatable {
  const Account({
    required this.id,
    required this.name,
    required this.avatar,
  });

  static const String schema = 'accounts';

  static const String idKey = 'id';
  static const String nameKey = 'name';
  static const String avatarKey = 'avatar';

  final String id;
  final String name;
  final String avatar;

  @override
  String toString() {
    return toMap().toString();
  }

  @override
  List<Object?> get props {
    return [
      id,
      name,
      avatar,
    ];
  }

  Account copyWith({
    String? id,
    String? name,
    String? avatar,
  }) {
    return Account(
      id: id ?? this.id,
      name: name ?? this.name,
      avatar: avatar ?? this.avatar,
    );
  }

  Account clone() {
    return copyWith(
      id: id,
      name: name,
      avatar: avatar,
    );
  }

  static Account fromMap(Map<String, dynamic> data) {
    return Account(
      id: data[idKey],
      name: data[nameKey],
      avatar: data[avatarKey],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      idKey: id,
      nameKey: name,
      avatarKey: avatar,
    }..removeWhere((key, value) => value == null);
  }

  static List<Account> fromListMap(List<Map<String, dynamic>> data) {
    return List.of(data.map((value) => fromMap(value)));
  }

  static List<Map<String, dynamic>> toListMap(List<Account> values) {
    return List.of(values.map((value) => value.toMap()));
  }

  static Account fromJson(String source) {
    return fromMap(jsonDecode(source));
  }

  String toJson() {
    return jsonEncode(toMap());
  }

  static List<Account> fromListJson(String source) {
    return List.of((jsonDecode(source) as List).map((value) => fromMap(value)));
  }

  static String toListJson(List<Account> values) {
    return jsonEncode(values.map((value) => value.toMap()));
  }
}
