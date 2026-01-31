import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import '../constants/api_constants.dart';
import '../navigation/app_navigator.dart';

class ApiException implements Exception {
  final String message;
  ApiException(this.message);
  @override
  String toString() => 'ApiException: $message';
}

class BadRequestException extends ApiException {
  BadRequestException(String message) : super(message);
}

class UnauthorizedException extends ApiException {
  UnauthorizedException(String message) : super(message);
}

class NotFoundException extends ApiException {
  NotFoundException(String message) : super(message);
}

class ServerException extends ApiException {
  ServerException(String message) : super(message);
}

class ApiClient {
  final http.Client _client;
  String? _token;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  final String baseUrl;

  ApiClient({http.Client? client, String? token, String? baseUrl})
      : _client = client ?? http.Client(),
        _token = token,
        baseUrl = baseUrl ?? ApiConstants.baseUrl;

  /// Update or clear the authorization token
  void updateToken(String? token) => _token = token;

  Future<Map<String, String>> _headers([Map<String, String>? extra]) async {
    final headers = Map<String, String>.from(ApiConstants.defaultHeaders);
    // Prefer storage token if available
    final stored = await _storage.read(key: 'auth_token');
    final tokenToUse = (stored != null && stored.isNotEmpty) ? stored : _token;
    if (tokenToUse != null && tokenToUse.isNotEmpty) {
      headers['Authorization'] = 'Bearer $tokenToUse';
    }
    if (extra != null) headers.addAll(extra);
    return headers;
  }

  Uri _uri(String path) {
    final base = Uri.parse(baseUrl);
    if (path.startsWith('http')) return Uri.parse(path);

    final baseSegments = List<String>.from(base.pathSegments);
    if (baseSegments.isNotEmpty && baseSegments.last.contains('.')) {
      baseSegments.removeLast();
    }
    final pathSegments = _splitPath(path);
    return base.replace(pathSegments: [...baseSegments, ...pathSegments]);
  }

  List<String> _splitPath(String path) {
    final p = path.startsWith('/') ? path.substring(1) : path;
    if (p.isEmpty) return [];
    return p.split('/');
  }

  Future<dynamic> get(String path, {Map<String, String>? params, Map<String, String>? headers}) async {
    try {
      final uri = _uri(path).replace(queryParameters: params);
      final h = await _headers(headers);
      final res = await _client.get(uri, headers: h);
      return await _processResponse(res);
    } catch (e) {
      final msg = e.toString();
      if (msg.contains('XMLHttpRequest') || msg.contains('CORS') || msg.contains('Cross origin') || msg.contains('Access to fetch')) {
        throw ApiException('Network error (possible CORS when running in browser): $msg. Ensure the API allows cross-origin requests from this origin or run a proxy.');
      }
      throw ApiException('Network error: $msg');
    }
  }

  Future<dynamic> post(String path, {Object? body, Map<String, String>? headers}) async {
    try {
      final uri = _uri(path);
      final encoded = body == null ? null : jsonEncode(body);
      final h = await _headers(headers);
      final res = await _client.post(uri, headers: h, body: encoded);
      return await _processResponse(res);
    } catch (e) {
      final msg = e.toString();
      if (msg.contains('XMLHttpRequest') || msg.contains('CORS') || msg.contains('Cross origin') || msg.contains('Access to fetch')) {
        throw ApiException('Network error (possible CORS when running in browser): $msg. Ensure the API allows cross-origin requests from this origin or run a proxy.');
      }
      throw ApiException('Network error: $msg');
    }
  }

  Future<dynamic> put(String path, {Object? body, Map<String, String>? headers}) async {
    try {
      final uri = _uri(path);
      final encoded = body == null ? null : jsonEncode(body);
      final h = await _headers(headers);
      final res = await _client.put(uri, headers: h, body: encoded);
      return await _processResponse(res);
    } catch (e) {
      final msg = e.toString();
      if (msg.contains('XMLHttpRequest') || msg.contains('CORS') || msg.contains('Cross origin') || msg.contains('Access to fetch')) {
        throw ApiException('Network error (possible CORS when running in browser): $msg. Ensure the API allows cross-origin requests from this origin or run a proxy.');
      }
      throw ApiException('Network error: $msg');
    }
  }

  Future<dynamic> delete(String path, {Object? body, Map<String, String>? headers}) async {
    try {
      final uri = _uri(path);
      final encoded = body == null ? null : jsonEncode(body);
      final h = await _headers(headers);
      final res = await _client.delete(uri, headers: h, body: encoded);
      return await _processResponse(res);
    } catch (e) {
      final msg = e.toString();
      if (msg.contains('XMLHttpRequest') || msg.contains('CORS') || msg.contains('Cross origin') || msg.contains('Access to fetch')) {
        throw ApiException('Network error (possible CORS when running in browser): $msg. Ensure the API allows cross-origin requests from this origin or run a proxy.');
      }
      throw ApiException('Network error: $msg');
    }
  }
  Future<dynamic> _processResponse(http.Response res) async {
    final status = res.statusCode;
    final body = res.body;
    dynamic decoded;
    if (body.isNotEmpty) {
      try {
        decoded = jsonDecode(body);
      } catch (_) {
        decoded = body;
      }
    }

    if (status >= 200 && status < 300) {
      return decoded ?? {};
    } else if (status == 400) {
      final message = _extractMessage(decoded) ?? 'Bad request';
      throw BadRequestException(message);
    } else if (status == 401) {
      final message = _extractMessage(decoded) ?? 'Unauthorized';
      // clear stored token and navigate to login
      await _storage.delete(key: 'auth_token');
      // clear in-memory token too
      _token = null;
      try {
        appNavigatorKey.currentState?.pushNamedAndRemoveUntil('/', (route) => false);
      } catch (_) {}
      throw UnauthorizedException(message);
    } else if (status == 404) {
      final message = _extractMessage(decoded) ?? 'Not found';
      throw NotFoundException(message);
    } else if (status >= 500) {
      final message = _extractMessage(decoded) ?? 'Server error';
      throw ServerException(message);
    } else {
      throw ApiException('HTTP $status: ${_extractMessage(decoded) ?? res.reasonPhrase ?? 'Unknown error'}');
    }
  }

  String? _extractMessage(dynamic decoded) {
    if (decoded == null) return null;
    if (decoded is String) return decoded;
    if (decoded is Map && decoded.containsKey('message')) return decoded['message']?.toString();
    if (decoded is Map && decoded.containsKey('error')) return decoded['error']?.toString();
    return decoded.toString();
  }
}
