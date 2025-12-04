import '../../models/administration.dart';

abstract class AdministrationEvent {}

class LoadAcademicYears extends AdministrationEvent {
  final String tenantId;

  LoadAcademicYears(this.tenantId);
}

class CreateAcademicYear extends AdministrationEvent {
  final String tenantId;
  final AcademicYear academicYear;

  CreateAcademicYear({required this.tenantId, required this.academicYear});
}

class CreateUser extends AdministrationEvent {
  final String tenantId;
  final UserPayload user;

  CreateUser({required this.tenantId, required this.user});
}
