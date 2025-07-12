import 'package:equatable/equatable.dart';
import '../../models/tenant.dart';

abstract class TenantState extends Equatable {
  const TenantState();
  @override
  List<Object?> get props => [];
}

class TenantLoading extends TenantState {}

class TenantsLoaded extends TenantState {
  final List<Tenant> tenants;
  const TenantsLoaded(this.tenants);
  @override
  List<Object?> get props => [tenants];
}

class TenantOperationInProgress extends TenantState {
  final List<Tenant> currentTenants;
  final String operation;
  const TenantOperationInProgress(this.currentTenants, this.operation);
  @override
  List<Object?> get props => [currentTenants, operation];
}

class TenantOperationSuccess extends TenantState {
  final List<Tenant> tenants;
  final String message;
  const TenantOperationSuccess(this.tenants, this.message);
  @override
  List<Object?> get props => [tenants, message];
}

class TenantOperationFailure extends TenantState {
  final String error;
  final List<Tenant> currentTenants;
  const TenantOperationFailure(this.error, this.currentTenants);
  @override
  List<Object?> get props => [error, currentTenants];
}