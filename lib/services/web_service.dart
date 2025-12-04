import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class WebService {
  final String baseUrl;

  WebService({required this.baseUrl});

  Future<String> postData(String endpoint, String data) async {
    try {
      if (kDebugMode) {
        print('POST URL: $baseUrl/$endpoint');
        print('POST Data: $data');
      }

      final response = await http.post(
        Uri.parse('$baseUrl/$endpoint'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: data,
      );

      if (kDebugMode) {
        print('Response Status: ${response.statusCode}');
        print('Response Body: ${response.body}');
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.body;
      } else {
        try {
          final errorData = jsonDecode(response.body);
          if (errorData['error'] != null) {
            throw Exception(errorData['error']['message'] ?? 'Server error');
          } else {
            throw Exception('HTTP ${response.statusCode}: ${response.reasonPhrase}');
          }
        } catch (e) {
          if (e is Exception) rethrow;
          throw Exception('HTTP ${response.statusCode}: ${response.reasonPhrase}');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error in postData: $e");
      }
      rethrow;
    }
  }

  Future<String> fetchData(String endpoint) async {
    try {
      if (kDebugMode) {
        print('GET URL: $baseUrl/$endpoint');
      }

      final response = await http.get(
        Uri.parse('$baseUrl/$endpoint'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (kDebugMode) {
        print('Response Status: ${response.statusCode}');
        print('Response Body: ${response.body}');
      }

      if (response.statusCode == 200) {
        return response.body;
      } else {
        try {
          final errorData = jsonDecode(response.body);
          if (errorData['error'] != null) {
            throw Exception(errorData['error']['message'] ?? 'Server error');
          } else {
            throw Exception('HTTP ${response.statusCode}: ${response.reasonPhrase}');
          }
        } catch (e) {
          if (e is Exception) rethrow;
          throw Exception('HTTP ${response.statusCode}: ${response.reasonPhrase}');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error in fetchData: $e");
      }
      rethrow;
    }
  }

  Future<String> putData(String endpoint, String data) async {
    try {
      if (kDebugMode) {
        print('PUT URL: $baseUrl/$endpoint');
        print('PUT Data: $data');
      }

      final response = await http.put(
        Uri.parse('$baseUrl/$endpoint'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: data,
      );

      if (kDebugMode) {
        print('Response Status: ${response.statusCode}');
        print('Response Body: ${response.body}');
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.body;
      } else {
        try {
          final errorData = jsonDecode(response.body);
          if (errorData['error'] != null) {
            throw Exception(errorData['error']['message'] ?? 'Server error');
          } else {
            throw Exception('HTTP ${response.statusCode}: ${response.reasonPhrase}');
          }
        } catch (e) {
          if (e is Exception) rethrow;
          throw Exception('HTTP ${response.statusCode}: ${response.reasonPhrase}');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error in putData: $e");
      }
      rethrow;
    }
  }

  Future<String> deleteData(String endpoint) async {
    try {
      if (kDebugMode) {
        print('DELETE URL: $baseUrl/$endpoint');
      }

      final response = await http.delete(
        Uri.parse('$baseUrl/$endpoint'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (kDebugMode) {
        print('Response Status: ${response.statusCode}');
        print('Response Body: ${response.body}');
      }

      if (response.statusCode == 200 || response.statusCode == 204) {
        return response.statusCode == 204 ? '' : response.body;
      } else {
        try {
          final errorData = jsonDecode(response.body);
          if (errorData['error'] != null) {
            throw Exception(errorData['error']['message'] ?? 'Server error');
          } else {
            throw Exception('HTTP ${response.statusCode}: ${response.reasonPhrase}');
          }
        } catch (e) {
          if (e is Exception) rethrow;
          throw Exception('HTTP ${response.statusCode}: ${response.reasonPhrase}');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error in deleteData: $e");
      }
      rethrow;
    }
  }

  Future<String> fetchDataWithTenantId(String endpoint, String tenantId) async {
    try {
      final sanitizedBaseUrl = baseUrl.replaceAll(RegExp(r'/+$'), '');
      final sanitizedEndpoint = endpoint.replaceAll(RegExp(r'^/+'), '');
      final uri = Uri.parse('$sanitizedBaseUrl/$sanitizedEndpoint');

      if (kDebugMode) {
        print('GET URL: $uri');
        print('X-Tenant: ${tenantId.trim()}');
      }

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'X-Tenant': tenantId.trim(),
        },
      );

      if (kDebugMode) {
        print('Response Status: ${response.statusCode}');
        print('Response Body: ${response.body}');
      }

      if (response.statusCode == 200) {
        return response.body;
      } else {
        throw Exception('Failed to load data: ${response.statusCode}');
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error in fetchDataWithTenantId: $e");
      }
      throw Exception('Network error: $e');
    }
  }
}