import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:worker_manager/worker_manager.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cashnetic/data/models/account_create/account_request.dart';
import 'package:cashnetic/data/models/category/category.dart';
import 'package:cashnetic/data/models/transaction_request/transaction_request.dart';

/// Singleton Dio client с авторизацией и логированием
class DioProvider {
  static final Dio _dio =
      Dio(
          BaseOptions(
            baseUrl: dotenv.env['API_URL'] ?? '',
            connectTimeout: const Duration(seconds: 10),
            receiveTimeout: const Duration(seconds: 20),
            headers: {'Content-Type': 'application/json'},
          ),
        )
        ..interceptors.addAll([
          _AuthInterceptor(),
          SafeLogInterceptor(),
          IsolateJsonInterceptor(),
        ]);

  static Dio get dio => _dio;
}

/// Интерцептор для подстановки Bearer Token
class _AuthInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final token = dotenv.env['API_TOKEN'];
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    super.onRequest(options, handler);
  }
}

class SafeLogInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final headers = Map<String, dynamic>.from(options.headers);
    if (headers.containsKey('Authorization')) {
      headers['Authorization'] = '***';
    }
    debugPrint('[Dio] REQUEST: ${options.method} ${options.uri}');
    debugPrint('[Dio] Headers: $headers');
    if (options.data != null) {
      debugPrint('[Dio] Body: ${options.data}');
    }
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    debugPrint(
      '[Dio] RESPONSE: ${response.statusCode} ${response.requestOptions.uri}',
    );
    debugPrint('[Dio] Data: ${response.data}');
    handler.next(response);
  }

  @override
  void onError(DioError err, ErrorInterceptorHandler handler) {
    debugPrint('[Dio] ERROR: ${err.requestOptions.uri}');
    debugPrint('[Dio] Error: ${err.error}');
    handler.next(err);
  }
}

class IsolateJsonInterceptor extends Interceptor {
  static const int bigListThreshold = 1000;

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) async {
    final data = response.data;
    if (data is List &&
        data.length > bigListThreshold &&
        response.requestOptions.responseType == ResponseType.json) {
      debugPrint(
        '[IsolateJsonInterceptor] Start parsing in isolate, length:  [33m${data.length} [0m',
      );
      final parsed = await workerManager.execute(
        () => _parseListInIsolate(jsonEncode(data)),
      );
      debugPrint(
        '[IsolateJsonInterceptor] Done parsing in isolate, result length:  [32m${parsed.length} [0m',
      );
      response.data = parsed;
    }
    handler.next(response);
  }
}

List<dynamic> _parseListInIsolate(String jsonStr) {
  return jsonDecode(jsonStr) as List<dynamic>;
}

/// Базовый API-клиент
class ApiClient {
  final Dio _dio;
  ApiClient([Dio? dio]) : _dio = dio ?? DioProvider.dio;

  // Accounts
  Future<Response> getAccounts() => _dio.get('/accounts');
  Future<Response> getAccount(String id) => _dio.get('/accounts/$id');
  Future<Response> createAccount(AccountRequestDTO dto) =>
      _dio.post('/accounts', data: dto.toJson());
  Future<Response> updateAccount(String id, AccountRequestDTO dto) =>
      _dio.put('/accounts/$id', data: dto.toJson());
  Future<Response> deleteAccount(String id) => _dio.delete('/accounts/$id');

  // Categories
  Future<Response> getCategories() => _dio.get('/categories');
  Future<Response> getCategory(String id) => _dio.get('/categories/$id');
  Future<Response> createCategory(CategoryDTO dto) =>
      _dio.post('/categories', data: dto.toJson());
  Future<Response> updateCategory(String id, CategoryDTO dto) =>
      _dio.put('/categories/$id', data: dto.toJson());
  Future<Response> deleteCategory(String id) => _dio.delete('/categories/$id');

  // Transactions
  Future<Response> getTransactions() => _dio.get('/transactions');
  Future<Response> getTransaction(String id) => _dio.get('/transactions/$id');
  Future<Response> createTransaction(TransactionRequestDTO dto) =>
      _dio.post('/transactions', data: dto.toJson());
  Future<Response> updateTransaction(String id, TransactionRequestDTO dto) =>
      _dio.put('/transactions/$id', data: dto.toJson());
  Future<Response> deleteTransaction(String id) =>
      _dio.delete('/transactions/$id');

  Dio get dio => _dio;
}
