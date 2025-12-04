import '../../models/administration.dart';

abstract class AdministrationState {}

class AdministrationInitial extends AdministrationState {}

class AdministrationLoading extends AdministrationState {}

class AdministrationLoaded extends AdministrationState {
  final List<AcademicYear> academicYears;
  final String? message;

  AdministrationLoaded({required this.academicYears, this.message});
}

class AdministrationOperationInProgress extends AdministrationState {
  final List<AcademicYear> academicYears;
  final String message;

  AdministrationOperationInProgress(this.academicYears, this.message);
}

class AdministrationFailure extends AdministrationState {
  final String error;
  final List<AcademicYear> academicYears;

  AdministrationFailure(this.error, this.academicYears);
}
