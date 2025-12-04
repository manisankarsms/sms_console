import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../models/administration.dart';
import '../services/web_service.dart';

class AdministrationRepository {
  final WebService webService;

  AdministrationRepository({required this.webService});

  Future<List<AcademicYear>> fetchAcademicYears(String tenantId) async {
    try {
      final responseString = await webService.fetchDataWithTenantId('academic-years', tenantId);
      final Map<String, dynamic> response = jsonDecode(responseString);

      if (response['success'] != true) {
        throw Exception(response['message'] ?? 'Failed to fetch academic years');
      }

      final List<dynamic> list = response['data'];
      return list.map((item) => AcademicYear.fromJson(item)).toList();
    } catch (e) {
      if (kDebugMode) {
        print("Error fetching academic years: $e");
      }
      throw Exception('Failed to fetch academic years: $e');
    }
  }

  Future<List<AdminUser>> fetchAdminUsers(String tenantId) async {
    try {
      final responseString = await webService.fetchDataWithTenantId('users/ADMIN', tenantId);
      final Map<String, dynamic> response = jsonDecode(responseString);

      if (response['success'] != true) {
        throw Exception(response['message'] ?? 'Failed to fetch admin users');
      }

      final List<dynamic> list = response['data'];
      return list.map((item) => AdminUser.fromJson(item)).toList();
    } catch (e) {
      if (kDebugMode) {
        print("Error fetching admin users: $e");
      }
      throw Exception('Failed to fetch admin users: $e');
    }
  }

  Future<void> createAcademicYear(String tenantId, AcademicYear academicYear) async {
    try {
      final body = jsonEncode(academicYear.toJson());
      final responseString = await webService.postDataWithTenantId('academic-years', body, tenantId);
      final Map<String, dynamic> response = jsonDecode(responseString);

      if (response['success'] != true) {
        throw Exception(response['message'] ?? 'Failed to create academic year');
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error creating academic year: $e");
      }
      throw Exception('Failed to create academic year: $e');
    }
  }

  Future<void> createUser(String tenantId, UserPayload user) async {
    try {
      final body = jsonEncode(user.toJson());
      final responseString = await webService.postDataWithTenantId('users', body, tenantId);
      final Map<String, dynamic> response = jsonDecode(responseString);

      if (response['success'] != true) {
        throw Exception(response['message'] ?? 'Failed to create user');
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error creating user: $e");
      }
      throw Exception('Failed to create user: $e');
    }
  }

  Future<void> deleteUser(String tenantId, String userId) async {
    try {
      final responseString = await webService.deleteDataWithTenantId('users/$userId', tenantId);
      if (responseString.isNotEmpty) {
        final Map<String, dynamic> response = jsonDecode(responseString);

        if (response['success'] != true) {
          throw Exception(response['message'] ?? 'Failed to delete user');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error deleting user: $e");
      }
      throw Exception('Failed to delete user: $e');
    }
  }
}
