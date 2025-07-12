abstract class DashboardEvent {}

class LoadDashboardData extends DashboardEvent {
  final String tenantId;

  LoadDashboardData(this.tenantId);
}