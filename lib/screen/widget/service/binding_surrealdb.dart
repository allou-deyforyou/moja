import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

Dio get dio => SurrealConfig._internalDio!;

class SurrealConfig {
  const SurrealConfig._();

  static Dio? _internalDio;
  static const _baseUrl = 'https://dei-surrealdb.fly.dev';

  static String? _namespace;
  static String get namespace => _namespace!;
  static String? _database;
  static String get database => _database!;
  static String? _scope;
  static String get scope => _scope!;

  static void _createDio() {
    _internalDio ??= Dio(BaseOptions(
      baseUrl: _baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      sendTimeout: const Duration(minutes: 30),
      headers: {
        Headers.contentTypeHeader: Headers.textPlainContentType,
        Headers.acceptHeader: Headers.jsonContentType,
        'NS': namespace,
        'DB': database,
        'SC': scope,
      },
    ));
  }

  static Future<void> development() async {
    _namespace = 'development';
    _database = 'moja';
    _scope = 'agent';

    _createDio();
  }

  static Future<void> production() async {
    _namespace = 'production';
    _database = 'moja';
    _scope = 'agent';

    _createDio();
  }
}

Future<Iterable<dynamic>> sql(dynamic query, {Map<String, dynamic>? headers}) async {
  final response = await dio.post<String>('/sql', data: query);
  final data = await compute(_Response.fromListJson, response.data!);
  return data.map((res) => res.result);
}

class _Response {
  const _Response({
    required this.id,
    required this.error,
    required this.result,
  });

  static const String idKey = 'id';
  static const String errorKey = 'error';
  static const String resultKey = 'result';

  final String? id;
  final dynamic error;
  final dynamic result;

  static _Response fromMap(dynamic data) {
    return _Response(
      id: data[idKey],
      error: data[errorKey],
      result: data[resultKey],
    );
  }

  static Iterable<_Response> fromListJson(String source) {
    return (jsonDecode(source) as List).map(fromMap);
  }
}
