import 'dart:convert';

import 'package:equatable/equatable.dart';

import '_schema.dart';

enum Transaction {
  cashin,
  cashout;
}

class Account extends Equatable {
  const Account({
    required this.id,
    required this.name,
    required this.image,
    this.transaction,
    this.country,
    this.amount,
  });

  static const String schema = 'account';

  static const String idKey = 'id';
  static const String nameKey = 'name';
  static const String imageKey = 'image';
  static const String amountKey = 'balance';
  static const String transactionKey = 'transaction';

  /// Edges
  static const String countryKey = 'countries';

  final String id;
  final String name;
  final String image;
  final double? amount;
  final Transaction? transaction;

  /// Edges
  final Country? country;

  @override
  String toString() {
    return toMap().toString();
  }

  @override
  List<Object?> get props {
    return [
      id,
      name,
      amount,
      image,
      transaction,
    ];
  }

  Account copyWith({
    String? id,
    String? name,
    String? image,
    double? amount,
    Transaction? transaction,
    Country? country,
  }) {
    return Account(
      id: id ?? this.id,
      name: name ?? this.name,
      image: image ?? this.image,
      amount: amount ?? this.amount,
      transaction: transaction ?? this.transaction,
      country: country ?? this.country,
    );
  }

  Account clone() {
    return copyWith(
      id: id,
      name: name,
      image: image,
      amount: amount,
      transaction: transaction,
      country: country,
    );
  }

  static Account? fromMap(dynamic data) {
    if (data == null) return null;
    return Account(
      id: data[idKey],
      name: data[nameKey],
      image: data[imageKey],
      country: List.of((data[countryKey] ?? []).map<Country>((item) => Country.fromMap(item)!)).firstOrNull,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      idKey: id,
      nameKey: name,
      imageKey: image,
      amountKey: amount,
      transactionKey: transaction,
    }..removeWhere((key, value) => value == null);
  }

  Map<String, dynamic> toSurreal() {
    return {
      idKey: id,
      imageKey: image,
      amountKey: amount,
      nameKey: name.json(),
      transactionKey: transaction,
    }..removeWhere((key, value) => value == null);
  }

  static Account fromJson(String source) {
    return fromMap(jsonDecode(source))!;
  }

  String toJson() {
    return jsonEncode(toMap());
  }
}
