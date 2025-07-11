import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:worker_manager/worker_manager.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cashnetic/data/models/account_create/account_request.dart';
import 'package:cashnetic/data/models/category/category.dart';
import 'package:cashnetic/data/models/transaction_request/transaction_request.dart';
import 'dart:math';

/// Singleton Dio client with auth and logging
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
          RetryInterceptor(), // Add retry interceptor here
        ]);

  static Dio get dio => _dio;
}

/// Interceptor for Bearer Token injection
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

class IsolateConfig {
  static const int bigListThreshold = 1000;
}

class IsolateJsonInterceptor extends Interceptor {
  static const int bigListThreshold = IsolateConfig.bigListThreshold;

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

class RetryConfig {
  static const int maxRetries = 3;
  static const Duration baseDelay = Duration(milliseconds: 500);
  static const int jitterMs = 250;
}

class RetryInterceptor extends Interceptor {
  final int maxRetries;
  final Duration baseDelay;
  final int jitterMs;
  final List<int> retryableStatuses;

  RetryInterceptor({
    this.maxRetries = RetryConfig.maxRetries,
    this.baseDelay = RetryConfig.baseDelay,
    this.jitterMs = RetryConfig.jitterMs,
    this.retryableStatuses = const [500, 502, 503, 504, 408, 429],
  });

  @override
  Future<void> onError(DioError err, ErrorInterceptorHandler handler) async {
    final requestOptions = err.requestOptions;
    int retryCount = requestOptions.extra['retryCount'] ?? 0;
    if (retryableStatuses.contains(err.response?.statusCode) &&
        retryCount < maxRetries) {
      retryCount++;
      final base = baseDelay * pow(2, retryCount - 1).toInt();
      final jitter = Random().nextInt(jitterMs); // up to jitterMs ms
      final delay = base + Duration(milliseconds: jitter);
      debugPrint(
        '[RetryInterceptor] Attempt $retryCount for ${requestOptions.uri} after $delay',
      );
      await Future.delayed(delay);
      final newOptions = Options(
        method: requestOptions.method,
        headers: requestOptions.headers,
        responseType: requestOptions.responseType,
        contentType: requestOptions.contentType,
        extra: Map<String, dynamic>.from(requestOptions.extra)
          ..['retryCount'] = retryCount,
        followRedirects: requestOptions.followRedirects,
        validateStatus: requestOptions.validateStatus,
        receiveDataWhenStatusError: requestOptions.receiveDataWhenStatusError,
        sendTimeout: requestOptions.sendTimeout,
        receiveTimeout: requestOptions.receiveTimeout,
      );
      try {
        final response = await err.requestOptions.cancelToken != null
            ? err.requestOptions.cancelToken!.whenCancel.then((_) => null)
            : null;
        if (response == null) {
          final dio = Dio();
          final result = await dio.request(
            requestOptions.path,
            data: requestOptions.data,
            queryParameters: requestOptions.queryParameters,
            options: newOptions,
            cancelToken: requestOptions.cancelToken,
            onSendProgress: requestOptions.onSendProgress,
            onReceiveProgress: requestOptions.onReceiveProgress,
          );
          debugPrint(
            '[RetryInterceptor] Success on retry $retryCount for ${requestOptions.uri}',
          );
          return handler.resolve(result);
        }
      } catch (e) {
        debugPrint(
          '[RetryInterceptor] Retry $retryCount failed for ${requestOptions.uri}: $e',
        );
        return handler.next(err);
      }
    }
    return handler.next(err);
  }
}

/// Base API client
class ApiClient {
  final Dio _dio;
  ApiClient([Dio? dio]) : _dio = dio ?? DioProvider.dio;

  // Accounts
  Future<Response> getAccounts({String? since}) => _dio.get(
    '/accounts',
    queryParameters: since != null ? {'since': since} : null,
  );
  Future<Response> getAccount(String id) => _dio.get('/accounts/$id');
  Future<Response> createAccount(AccountRequestDTO dto) =>
      _dio.post('/accounts', data: dto.toJson());
  Future<Response> updateAccount(String id, AccountRequestDTO dto) =>
      _dio.put('/accounts/$id', data: dto.toJson());
  Future<Response> patchAccount(String id, Map<String, dynamic> diff) =>
      _dio.patch('/accounts/$id', data: diff);
  Future<Response> deleteAccount(String id) => _dio.delete('/accounts/$id');

  // Categories
  Future<Response> getCategories({String? since}) => _dio.get(
    '/categories',
    queryParameters: since != null ? {'since': since} : null,
  );
  Future<Response> getCategory(String id) => _dio.get('/categories/$id');
  Future<Response> createCategory(CategoryDTO dto) =>
      _dio.post('/categories', data: dto.toJson());
  Future<Response> updateCategory(String id, CategoryDTO dto) =>
      _dio.put('/categories/$id', data: dto.toJson());
  Future<Response> patchCategory(String id, Map<String, dynamic> diff) =>
      _dio.patch('/categories/$id', data: diff);
  Future<Response> deleteCategory(String id) => _dio.delete('/categories/$id');

  // Transactions
  Future<Response> getTransactions({String? since}) => _dio.get(
    '/transactions',
    queryParameters: since != null ? {'since': since} : null,
  );
  Future<Response> getTransaction(String id) => _dio.get('/transactions/$id');
  Future<Response> createTransaction(TransactionRequestDTO dto) =>
      _dio.post('/transactions', data: dto.toJson());
  Future<Response> updateTransaction(String id, TransactionRequestDTO dto) =>
      _dio.put('/transactions/$id', data: dto.toJson());
  Future<Response> patchTransaction(String id, Map<String, dynamic> diff) =>
      _dio.patch('/transactions/$id', data: diff);
  Future<Response> deleteTransaction(String id) =>
      _dio.delete('/transactions/$id');

  Dio get dio => _dio;
}
