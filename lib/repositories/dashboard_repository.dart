import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../models/dashboard.dart';
import '../services/web_service.dart';

class DashboardRepository {
  final WebService webService;

  DashboardRepository({required this.webService});

  Future<DashboardData> fetchDashboardData(String tenantId) async {
    try {
      // Pass tenant ID as header for the API request
      final String responseString = await webService.fetchDataWithTenantId(
        'dashboard/complete',
        tenantId,
      );

      final Map<String, dynamic> response = jsonDecode(responseString);

      if (response['success'] != true) {
        throw Exception(response['message'] ?? 'Failed to fetch dashboard data');
      }

      return DashboardData.fromJson(response['data']);
    } catch (e) {
      if (kDebugMode) {
        print("Error fetching dashboard data: $e");
      }
      throw Exception('Failed to fetch dashboard data: $e');
    }
  }
}