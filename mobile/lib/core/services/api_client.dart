import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import '../security/secure_storage.dart';

/// Centralized API Client connecting BuildMart Flutter Mobile App
/// to the Python FastAPI backend service (`services/api`).
class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;
  ApiClient._internal();

  final SecureStorage _storage = secureStorage;

  String get baseUrl {
    final envUrl = dotenv.env['API_BASE_URL'];
    if (envUrl != null && envUrl.isNotEmpty) {
      return envUrl;
    }
    // Android emulator loopback alias to host localhost:
    if (!kIsWeb && Platform.isAndroid) {
      return 'http://10.0.2.2:8000/api/v1';
    }
    // Default loopback for iOS / Desktop / Web:
    return 'http://127.0.0.1:8000/api/v1';
  }

  Future<Map<String, String>> _headers({bool includeAuth = true}) async {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (includeAuth) {
      final token = await _storage.getToken();
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
    }
    return headers;
  }

  Future<dynamic> get(String endpoint,
      {Map<String, String>? queryParams, bool auth = true}) async {
    var uri = Uri.parse('$baseUrl$endpoint');
    if (queryParams != null && queryParams.isNotEmpty) {
      uri = uri.replace(queryParameters: queryParams);
    }

    final headers = await _headers(includeAuth: auth);
    final response = await http.get(uri, headers: headers);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(utf8.decode(response.bodyBytes));
    }
    throw ApiException(
      statusCode: response.statusCode,
      message: 'GET $endpoint failed: ${response.body}',
    );
  }

  Future<dynamic> post(String endpoint,
      {dynamic body, bool auth = true}) async {
    final uri = Uri.parse('$baseUrl$endpoint');
    final headers = await _headers(includeAuth: auth);
    final response = await http.post(
      uri,
      headers: headers,
      body: body != null ? jsonEncode(body) : null,
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(utf8.decode(response.bodyBytes));
    }
    throw ApiException(
      statusCode: response.statusCode,
      message: 'POST $endpoint failed: ${response.body}',
    );
  }

  // Catalog APIs
  Future<List<dynamic>> getCategories() async {
    final res = await get('/categories', auth: false);
    return res is List ? res : [];
  }

  Future<List<dynamic>> getBrands() async {
    final res = await get('/brands', auth: false);
    return res is List ? res : [];
  }

  Future<List<dynamic>> getBanners() async {
    final res = await get('/banners', auth: false);
    return res is List ? res : [];
  }

  Future<List<dynamic>> getShops() async {
    final res = await get('/shops', auth: false);
    return res is List ? res : [];
  }

  Future<List<dynamic>> getProducts({
    String? categoryId,
    String? brandId,
    String? shopId,
    String? query,
    int limit = 50,
  }) async {
    final params = <String, String>{'limit': limit.toString()};
    if (categoryId != null) params['category_id'] = categoryId;
    if (brandId != null) params['brand_id'] = brandId;
    if (shopId != null) params['shop_id'] = shopId;
    if (query != null && query.isNotEmpty) params['q'] = query;

    final res = await get('/products', queryParams: params, auth: false);
    return res is List ? res : [];
  }

  Future<Map<String, dynamic>> getProduct(String id) async {
    final res = await get('/products/$id', auth: false);
    return res is Map<String, dynamic> ? res : {};
  }

  // Cart & Orders
  Future<dynamic> getCart() => get('/cart', auth: true);

  Future<dynamic> addToCart(String productId, int quantity) =>
      post('/cart/items',
          body: {'product_id': productId, 'quantity': quantity}, auth: true);

  Future<dynamic> createOrder(Map<String, dynamic> orderPayload) =>
      post('/orders', body: orderPayload, auth: true);

  // Health probe
  Future<bool> checkHealth() async {
    try {
      final res = await get('/health', auth: false);
      return res['status'] == 'healthy';
    } catch (_) {
      return false;
    }
  }
}

class ApiException implements Exception {
  final int statusCode;
  final String message;

  ApiException({required this.statusCode, required this.message});

  @override
  String toString() => 'ApiException ($statusCode): $message';
}

final apiClient = ApiClient();
