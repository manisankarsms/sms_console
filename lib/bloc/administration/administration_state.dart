import '../../models/administration.dart';

abstract class AdministrationState {}

class AdministrationInitial extends AdministrationState {}

class AdministrationLoading extends AdministrationState {}

class AdministrationLoaded extends AdministrationState {
  final List<AcademicYear> academicYears;
  final List<AdminUser> adminUsers;
  final String? message;

  AdministrationLoaded({
    required this.academicYears,
    required this.adminUsers,
    this.message,
  });
}

class AdministrationOperationInProgress extends AdministrationState {
  final List<AcademicYear> academicYears;
  final List<AdminUser> adminUsers;
  final String message;

  AdministrationOperationInProgress(this.academicYears, this.adminUsers, this.message);
}

class AdministrationFailure extends AdministrationState {
  final String error;
  final List<AcademicYear> academicYears;
  final List<AdminUser> adminUsers;

  AdministrationFailure(this.error, this.academicYears, this.adminUsers);
}
