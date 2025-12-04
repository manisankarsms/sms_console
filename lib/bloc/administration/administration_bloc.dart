import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import '../../models/administration.dart';
import '../../repositories/administration_repository.dart';
import 'administration_event.dart';
import 'administration_state.dart';

class AdministrationBloc extends Bloc<AdministrationEvent, AdministrationState> {
  final AdministrationRepository administrationRepository;
  List<AcademicYear> _academicYears = [];
  List<AdminUser> _adminUsers = [];

  AdministrationBloc({required this.administrationRepository}) : super(AdministrationInitial()) {
    on<LoadAcademicYears>(_onLoadAcademicYears);
    on<CreateAcademicYear>(_onCreateAcademicYear);
    on<CreateUser>(_onCreateUser);
    on<LoadAdminUsers>(_onLoadAdminUsers);
    on<DeleteUser>(_onDeleteUser);
  }

  Future<void> _onLoadAcademicYears(LoadAcademicYears event, Emitter<AdministrationState> emit) async {
    try {
      emit(AdministrationLoading());
      _academicYears = await administrationRepository.fetchAcademicYears(event.tenantId);
      emit(AdministrationLoaded(
        academicYears: List.from(_academicYears),
        adminUsers: List.from(_adminUsers),
      ));
    } catch (e) {
      if (kDebugMode) {
        print("[AdministrationBloc] Error loading academic years: $e");
      }
      emit(AdministrationFailure(
        'Failed to load academic years: ${e.toString()}',
        List.from(_academicYears),
        List.from(_adminUsers),
      ));
    }
  }

  Future<void> _onCreateAcademicYear(CreateAcademicYear event, Emitter<AdministrationState> emit) async {
    try {
      emit(AdministrationOperationInProgress(List.from(_academicYears), List.from(_adminUsers), 'Creating academic year...'));
      await administrationRepository.createAcademicYear(event.tenantId, event.academicYear);
      _academicYears = await administrationRepository.fetchAcademicYears(event.tenantId);
      emit(AdministrationLoaded(
        academicYears: List.from(_academicYears),
        adminUsers: List.from(_adminUsers),
        message: 'Academic year created successfully.',
      ));
    } catch (e) {
      emit(AdministrationFailure(
        'Failed to create academic year: ${e.toString()}',
        List.from(_academicYears),
        List.from(_adminUsers),
      ));
    }
  }

  Future<void> _onCreateUser(CreateUser event, Emitter<AdministrationState> emit) async {
    try {
      emit(AdministrationOperationInProgress(List.from(_academicYears), List.from(_adminUsers), 'Creating user...'));
      await administrationRepository.createUser(event.tenantId, event.user);
      _adminUsers = await administrationRepository.fetchAdminUsers(event.tenantId);
      emit(AdministrationLoaded(
        academicYears: List.from(_academicYears),
        adminUsers: List.from(_adminUsers),
        message: 'User created successfully.',
      ));
    } catch (e) {
      emit(AdministrationFailure(
        'Failed to create user: ${e.toString()}',
        List.from(_academicYears),
        List.from(_adminUsers),
      ));
    }
  }

  Future<void> _onLoadAdminUsers(LoadAdminUsers event, Emitter<AdministrationState> emit) async {
    try {
      emit(AdministrationOperationInProgress(List.from(_academicYears), List.from(_adminUsers), 'Loading admin users...'));
      _adminUsers = await administrationRepository.fetchAdminUsers(event.tenantId);
      emit(AdministrationLoaded(
        academicYears: List.from(_academicYears),
        adminUsers: List.from(_adminUsers),
      ));
    } catch (e) {
      emit(AdministrationFailure(
        'Failed to load admin users: ${e.toString()}',
        List.from(_academicYears),
        List.from(_adminUsers),
      ));
    }
  }

  Future<void> _onDeleteUser(DeleteUser event, Emitter<AdministrationState> emit) async {
    try {
      emit(AdministrationOperationInProgress(List.from(_academicYears), List.from(_adminUsers), 'Deleting user...'));
      await administrationRepository.deleteUser(event.tenantId, event.userId);
      _adminUsers = await administrationRepository.fetchAdminUsers(event.tenantId);
      emit(AdministrationLoaded(
        academicYears: List.from(_academicYears),
        adminUsers: List.from(_adminUsers),
        message: 'User deleted successfully.',
      ));
    } catch (e) {
      emit(AdministrationFailure(
        'Failed to delete user: ${e.toString()}',
        List.from(_academicYears),
        List.from(_adminUsers),
      ));
    }
  }
}
