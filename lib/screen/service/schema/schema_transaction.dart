import 'dart:convert';

import 'package:equatable/equatable.dart';

import '_schema.dart';

enum TransactionType {
  cashin,
  cashout;

  factory TransactionType.fromString(String value) => switch (value) {
        'cashin' => cashin,
        'cashout' => cashout,
        _ => throw 'Invalid TransactionType: $value',
      };
}

class Transaction extends Equatable {
  const Transaction({
    this.id,
    this.amount,
    required this.account,
    required this.type,
  });

  static const String schema = 'transactions';

  static const String idKey = 'id';
  static const String accountKey = 'account';
  static const String amountKey = 'amount';
  static const String typeKey = 'transaction';

  final String? id;
  final Account account;
  final double? amount;
  final TransactionType type;

  List<double> get amountSuggestions {
    return [];
  }

  @override
  String toString() {
    return toMap().toString();
  }

  @override
  List<Object?> get props {
    return [
      id,
      account,
      amount,
      type,
    ];
  }

  Transaction copyWith({
    String? id,
    Account? account,
    double? amount,
    TransactionType? type,
  }) {
    return Transaction(
      id: id ?? this.id,
      account: account ?? this.account,
      amount: amount ?? this.amount,
      type: type ?? this.type,
    );
  }

  Transaction clone() {
    return copyWith(
      id: id,
      account: account,
      amount: amount,
      type: type,
    );
  }

  static Transaction fromMap(Map<String, dynamic> data) {
    return Transaction(
      id: data[idKey],
      account: data[accountKey],
      amount: data[amountKey],
      type: TransactionType.fromString(data[typeKey]),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      idKey: id,
      accountKey: account,
      amountKey: amount,
      typeKey: type,
    }..removeWhere((key, value) => value == null);
  }

  static List<Transaction> fromListMap(List<Map<String, dynamic>> data) {
    return List.of(data.map((value) => fromMap(value)));
  }

  static List<Map<String, dynamic>> toListMap(List<Transaction> values) {
    return List.of(values.map((value) => value.toMap()));
  }

  static Transaction fromJson(String source) {
    return fromMap(jsonDecode(source));
  }

  String toJson() {
    return jsonEncode(toMap());
  }

  static List<Transaction> fromListJson(String source) {
    return List.of((jsonDecode(source) as List).map((value) => fromMap(value)));
  }

  static String toListJson(List<Transaction> values) {
    return jsonEncode(values.map((value) => value.toMap()));
  }
}
