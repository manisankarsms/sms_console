import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../models/tenant.dart';
import '../services/web_service.dart';

class TenantRepository {
  final WebService webService;

  TenantRepository({required this.webService});

  Future<List<Tenant>> fetchTenants() async {
    try {
      final String responseString = await webService.fetchData('tenants');
      final Map<String, dynamic> response = jsonDecode(responseString);

      if (response['success'] != true) {
        throw Exception(response['message'] ?? 'Failed to fetch tenants');
      }

      final List<dynamic> tenantsJson = response['data'];
      return tenantsJson.map((json) => Tenant.fromJson(json)).toList();
    } catch (e) {
      if (kDebugMode) {
        print("Error fetching tenants: $e");
      }
      throw Exception('Failed to fetch tenants: $e');
    }
  }

  Future<void> addTenant(Tenant newTenant) async {
    try {
      final String tenantJson = jsonEncode(newTenant.toJson());
      final responseString = await webService.postData('tenants', tenantJson);

      final Map<String, dynamic> response = jsonDecode(responseString);

      if (response['success'] != true) {
        throw Exception(response['message'] ?? 'Failed to add tenant');
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error adding tenant: $e");
      }
      throw Exception('Failed to add tenant: $e');
    }
  }

  Future<void> updateTenant(Tenant tenant) async {
    try {
      final String tenantJson = jsonEncode(tenant.toJson());
      final responseString = await webService.putData('tenants/${tenant.id}', tenantJson);

      final Map<String, dynamic> response = jsonDecode(responseString);
      if (response['success'] != true) {
        throw Exception(response['message'] ?? 'Failed to update tenant');
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error updating tenant: $e");
      }
      throw Exception('Failed to update tenant: $e');
    }
  }

  Future<void> deleteTenant(String tenantId) async {
    try {
      final responseString = await webService.deleteData('tenants/$tenantId');

      final Map<String, dynamic> response = jsonDecode(responseString);
      if (response['success'] != true) {
        throw Exception(response['message'] ?? 'Failed to delete tenant');
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error deleting tenant: $e");
      }
      throw Exception('Failed to delete tenant: $e');
    }
  }
}