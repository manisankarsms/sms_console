import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'tenant_event.dart';
import 'tenant_state.dart';
import '../../models/tenant.dart';
import '../../repositories/tenant_repository.dart';

class TenantBloc extends Bloc<TenantEvent, TenantState> {
  final TenantRepository tenantRepository;
  List<Tenant> _tenants = [];

  TenantBloc({required this.tenantRepository}) : super(TenantLoading()) {
    if (kDebugMode) {
      print("[TenantBloc] Initialized.");
    }
    on<LoadTenants>(_onLoadTenants);
    on<AddTenant>(_onAddTenant);
    on<UpdateTenant>(_onUpdateTenant);
    on<DeleteTenant>(_onDeleteTenant);
    add(LoadTenants());
  }

  Future<void> _onLoadTenants(LoadTenants event, Emitter<TenantState> emit) async {
    try {
      if (kDebugMode) {
        print("[TenantBloc] Processing LoadTenants event");
      }
      emit(TenantLoading());
      _tenants = await tenantRepository.fetchTenants();
      if (kDebugMode) {
        print("[TenantBloc] Emitting TenantsLoaded with ${_tenants.length} tenants");
      }
      emit(TenantsLoaded(List.from(_tenants)));
    } catch (e, stacktrace) {
      if (kDebugMode) {
        print("[TenantBloc] Error loading tenants: $e");
        print("[TenantBloc] Stacktrace: $stacktrace");
      }
      emit(TenantOperationFailure('Failed to load tenants: ${e.toString()}', _tenants));
    }
  }

  Future<void> _onAddTenant(AddTenant event, Emitter<TenantState> emit) async {
    try {
      emit(TenantOperationInProgress(List.from(_tenants), "Adding tenant..."));

      await tenantRepository.addTenant(event.tenant);
      emit(TenantOperationSuccess(List.from(_tenants), "Tenant added successfully!"));
      add(LoadTenants());
    } catch (e) {
      emit(TenantOperationFailure('Failed to add tenant: ${e.toString()}', List.from(_tenants)));
    }
  }

  Future<void> _onUpdateTenant(UpdateTenant event, Emitter<TenantState> emit) async {
    try {
      emit(TenantOperationInProgress(List.from(_tenants), "Updating tenant..."));

      await tenantRepository.updateTenant(event.tenant);
      final index = _tenants.indexWhere((t) => t.id == event.tenant.id);
      if (index != -1) {
        _tenants[index] = event.tenant;
      }

      emit(TenantOperationSuccess(List.from(_tenants), "Tenant updated successfully!"));
      emit(TenantsLoaded(List.from(_tenants)));
    } catch (e) {
      emit(TenantOperationFailure('Failed to update tenant: ${e.toString()}', List.from(_tenants)));
    }
  }

  Future<void> _onDeleteTenant(DeleteTenant event, Emitter<TenantState> emit) async {
    try {
      emit(TenantOperationInProgress(List.from(_tenants), "Deleting tenant..."));

      await tenantRepository.deleteTenant(event.tenantId);
      _tenants.removeWhere((t) => t.id == event.tenantId);

      emit(TenantOperationSuccess(List.from(_tenants), "Tenant deleted successfully!"));
      emit(TenantsLoaded(List.from(_tenants)));
    } catch (e) {
      emit(TenantOperationFailure('Failed to delete tenant: ${e.toString()}', List.from(_tenants)));
    }
  }
}