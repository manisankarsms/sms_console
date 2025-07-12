import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import '../../models/dashboard.dart';
import 'dashboard_event.dart';
import 'dashboard_state.dart';
import '../../repositories/dashboard_repository.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final DashboardRepository dashboardRepository;

  DashboardBloc({required this.dashboardRepository}) : super(DashboardLoading()) {
    if (kDebugMode) {
      print("[DashboardBloc] Initialized.");
    }
    on<LoadDashboardData>(_onLoadDashboardData);
  }

  Future<void> _onLoadDashboardData(LoadDashboardData event, Emitter<DashboardState> emit) async {
    try {
      if (kDebugMode) {
        print("[DashboardBloc] Processing LoadDashboardData event for tenant: ${event.tenantId}");
      }
      emit(DashboardLoading());

      final dashboardData = await dashboardRepository.fetchDashboardData(event.tenantId);

      if (kDebugMode) {
        print("[DashboardBloc] Emitting DashboardLoaded");
      }
      emit(DashboardLoaded(dashboardData));
    } catch (e, stacktrace) {
      if (kDebugMode) {
        print("[DashboardBloc] Error loading dashboard data: $e");
        print("[DashboardBloc] Stacktrace: $stacktrace");
      }
      emit(DashboardOperationFailure('Failed to load dashboard data: ${e.toString()}'));
    }
  }
}