import 'package:equatable/equatable.dart';
import '../../models/tenant.dart';

abstract class TenantEvent extends Equatable {
  const TenantEvent();
  @override
  List<Object?> get props => [];
}

class LoadTenants extends TenantEvent {}

class AddTenant extends TenantEvent {
  final Tenant tenant;
  const AddTenant(this.tenant);
  @override
  List<Object?> get props => [tenant];
}

class UpdateTenant extends TenantEvent {
  final Tenant tenant;
  const UpdateTenant(this.tenant);
  @override
  List<Object?> get props => [tenant];
}

class DeleteTenant extends TenantEvent {
  final String tenantId;
  const DeleteTenant(this.tenantId);
  @override
  List<Object?> get props => [tenantId];
}