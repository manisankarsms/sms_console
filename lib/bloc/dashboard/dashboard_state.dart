import '../../models/dashboard.dart';

abstract class DashboardState {}

class DashboardLoading extends DashboardState {}

class DashboardLoaded extends DashboardState {
  final DashboardData dashboardData;

  DashboardLoaded(this.dashboardData);
}

class DashboardOperationFailure extends DashboardState {
  final String error;

  DashboardOperationFailure(this.error);
}