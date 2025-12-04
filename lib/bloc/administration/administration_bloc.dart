import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import '../../models/administration.dart';
import '../../repositories/administration_repository.dart';
import 'administration_event.dart';
import 'administration_state.dart';

class AdministrationBloc extends Bloc<AdministrationEvent, AdministrationState> {
  final AdministrationRepository administrationRepository;
  List<AcademicYear> _academicYears = [];

  AdministrationBloc({required this.administrationRepository}) : super(AdministrationInitial()) {
    on<LoadAcademicYears>(_onLoadAcademicYears);
    on<CreateAcademicYear>(_onCreateAcademicYear);
    on<CreateUser>(_onCreateUser);
  }

  Future<void> _onLoadAcademicYears(LoadAcademicYears event, Emitter<AdministrationState> emit) async {
    try {
      emit(AdministrationLoading());
      _academicYears = await administrationRepository.fetchAcademicYears(event.tenantId);
      emit(AdministrationLoaded(academicYears: List.from(_academicYears)));
    } catch (e) {
      if (kDebugMode) {
        print("[AdministrationBloc] Error loading academic years: $e");
      }
      emit(AdministrationFailure('Failed to load academic years: ${e.toString()}', List.from(_academicYears)));
    }
  }

  Future<void> _onCreateAcademicYear(CreateAcademicYear event, Emitter<AdministrationState> emit) async {
    try {
      emit(AdministrationOperationInProgress(List.from(_academicYears), 'Creating academic year...'));
      await administrationRepository.createAcademicYear(event.tenantId, event.academicYear);
      _academicYears = await administrationRepository.fetchAcademicYears(event.tenantId);
      emit(AdministrationLoaded(academicYears: List.from(_academicYears), message: 'Academic year created successfully.'));
    } catch (e) {
      emit(AdministrationFailure('Failed to create academic year: ${e.toString()}', List.from(_academicYears)));
    }
  }

  Future<void> _onCreateUser(CreateUser event, Emitter<AdministrationState> emit) async {
    try {
      emit(AdministrationOperationInProgress(List.from(_academicYears), 'Creating user...'));
      await administrationRepository.createUser(event.tenantId, event.user);
      emit(AdministrationLoaded(academicYears: List.from(_academicYears), message: 'User created successfully.'));
    } catch (e) {
      emit(AdministrationFailure('Failed to create user: ${e.toString()}', List.from(_academicYears)));
    }
  }
}
