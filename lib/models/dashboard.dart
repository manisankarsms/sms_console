// dashboard_data.dart
class DashboardData {
  final Overview overview;
  final StudentStatistics studentStatistics;
  final StaffStatistics staffStatistics;
  final ExamStatistics examStatistics;
  final AttendanceStatistics attendanceStatistics;
  final ComplaintStatistics complaintStatistics;
  final AcademicStatistics academicStatistics;
  final HolidayStatistics holidayStatistics;

  DashboardData({
    required this.overview,
    required this.studentStatistics,
    required this.staffStatistics,
    required this.examStatistics,
    required this.attendanceStatistics,
    required this.complaintStatistics,
    required this.academicStatistics,
    required this.holidayStatistics,
  });

  factory DashboardData.fromJson(Map<String, dynamic> json) {
    return DashboardData(
      overview: Overview.fromJson(json['overview']),
      studentStatistics: StudentStatistics.fromJson(json['studentStatistics']),
      staffStatistics: StaffStatistics.fromJson(json['staffStatistics']),
      examStatistics: ExamStatistics.fromJson(json['examStatistics']),
      attendanceStatistics: AttendanceStatistics.fromJson(json['attendanceStatistics']),
      complaintStatistics: ComplaintStatistics.fromJson(json['complaintStatistics']),
      academicStatistics: AcademicStatistics.fromJson(json['academicStatistics']),
      holidayStatistics: HolidayStatistics.fromJson(json['holidayStatistics']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'overview': overview.toJson(),
      'studentStatistics': studentStatistics.toJson(),
      'staffStatistics': staffStatistics.toJson(),
      'examStatistics': examStatistics.toJson(),
      'attendanceStatistics': attendanceStatistics.toJson(),
      'complaintStatistics': complaintStatistics.toJson(),
      'academicStatistics': academicStatistics.toJson(),
      'holidayStatistics': holidayStatistics.toJson(),
    };
  }
}

class Overview {
  final int totalStudents;
  final int totalStaff;
  final int totalClasses;
  final int totalSubjects;
  final int activeAcademicYears;
  final int upcomingExams;
  final int totalComplaints;
  final int pendingComplaints;
  final double todayAttendanceRate;
  final int totalHolidays;
  final int upcomingHolidays;

  Overview({
    required this.totalStudents,
    required this.totalStaff,
    required this.totalClasses,
    required this.totalSubjects,
    required this.activeAcademicYears,
    required this.upcomingExams,
    required this.totalComplaints,
    required this.pendingComplaints,
    required this.todayAttendanceRate,
    required this.totalHolidays,
    required this.upcomingHolidays,
  });

  factory Overview.fromJson(Map<String, dynamic> json) {
    return Overview(
      totalStudents: json['totalStudents'],
      totalStaff: json['totalStaff'],
      totalClasses: json['totalClasses'],
      totalSubjects: json['totalSubjects'],
      activeAcademicYears: json['activeAcademicYears'],
      upcomingExams: json['upcomingExams'],
      totalComplaints: json['totalComplaints'],
      pendingComplaints: json['pendingComplaints'],
      todayAttendanceRate: (json['todayAttendanceRate'] ?? 0).toDouble(),
      totalHolidays: json['totalHolidays'],
      upcomingHolidays: json['upcomingHolidays'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalStudents': totalStudents,
      'totalStaff': totalStaff,
      'totalClasses': totalClasses,
      'totalSubjects': totalSubjects,
      'activeAcademicYears': activeAcademicYears,
      'upcomingExams': upcomingExams,
      'totalComplaints': totalComplaints,
      'pendingComplaints': pendingComplaints,
      'todayAttendanceRate': todayAttendanceRate,
      'totalHolidays': totalHolidays,
      'upcomingHolidays': upcomingHolidays,
    };
  }
}

class StudentStatistics {
  final int totalStudents;
  final List<StudentsByClass> studentsByClass;
  final List<StudentsByAcademicYear> studentsByAcademicYear;
  final List<RecentEnrollment> recentEnrollments;

  StudentStatistics({
    required this.totalStudents,
    required this.studentsByClass,
    required this.studentsByAcademicYear,
    required this.recentEnrollments,
  });

  factory StudentStatistics.fromJson(Map<String, dynamic> json) {
    return StudentStatistics(
      totalStudents: json['totalStudents'],
      studentsByClass: (json['studentsByClass'] as List)
          .map((x) => StudentsByClass.fromJson(x))
          .toList(),
      studentsByAcademicYear: (json['studentsByAcademicYear'] as List)
          .map((x) => StudentsByAcademicYear.fromJson(x))
          .toList(),
      recentEnrollments: (json['recentEnrollments'] as List)
          .map((x) => RecentEnrollment.fromJson(x))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalStudents': totalStudents,
      'studentsByClass': studentsByClass.map((x) => x.toJson()).toList(),
      'studentsByAcademicYear': studentsByAcademicYear.map((x) => x.toJson()).toList(),
      'recentEnrollments': recentEnrollments.map((x) => x.toJson()).toList(),
    };
  }
}

class StudentsByClass {
  final String classId;
  final String className;
  final String sectionName;
  final int studentCount;
  final String academicYearName;

  StudentsByClass({
    required this.classId,
    required this.className,
    required this.sectionName,
    required this.studentCount,
    required this.academicYearName,
  });

  factory StudentsByClass.fromJson(Map<String, dynamic> json) {
    return StudentsByClass(
      classId: json['classId'],
      className: json['className'],
      sectionName: json['sectionName'],
      studentCount: json['studentCount'],
      academicYearName: json['academicYearName'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'classId': classId,
      'className': className,
      'sectionName': sectionName,
      'studentCount': studentCount,
      'academicYearName': academicYearName,
    };
  }
}

class StudentsByAcademicYear {
  final String academicYearId;
  final String academicYearName;
  final int studentCount;

  StudentsByAcademicYear({
    required this.academicYearId,
    required this.academicYearName,
    required this.studentCount,
  });

  factory StudentsByAcademicYear.fromJson(Map<String, dynamic> json) {
    return StudentsByAcademicYear(
      academicYearId: json['academicYearId'],
      academicYearName: json['academicYearName'],
      studentCount: json['studentCount'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'academicYearId': academicYearId,
      'academicYearName': academicYearName,
      'studentCount': studentCount,
    };
  }
}

class RecentEnrollment {
  final String studentId;
  final String studentName;
  final String className;
  final String sectionName;
  final String academicYearName;
  final String enrollmentDate;

  RecentEnrollment({
    required this.studentId,
    required this.studentName,
    required this.className,
    required this.sectionName,
    required this.academicYearName,
    required this.enrollmentDate,
  });

  factory RecentEnrollment.fromJson(Map<String, dynamic> json) {
    return RecentEnrollment(
      studentId: json['studentId'],
      studentName: json['studentName'],
      className: json['className'],
      sectionName: json['sectionName'],
      academicYearName: json['academicYearName'],
      enrollmentDate: json['enrollmentDate'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'studentId': studentId,
      'studentName': studentName,
      'className': className,
      'sectionName': sectionName,
      'academicYearName': academicYearName,
      'enrollmentDate': enrollmentDate,
    };
  }
}

class StaffStatistics {
  final int totalStaff;
  final List<StaffByRole> staffByRole;
  final int classTeachers;
  final int subjectTeachers;
  final List<StaffWorkload> staffWorkload;

  StaffStatistics({
    required this.totalStaff,
    required this.staffByRole,
    required this.classTeachers,
    required this.subjectTeachers,
    required this.staffWorkload,
  });

  factory StaffStatistics.fromJson(Map<String, dynamic> json) {
    return StaffStatistics(
      totalStaff: json['totalStaff'],
      staffByRole: (json['staffByRole'] as List)
          .map((x) => StaffByRole.fromJson(x))
          .toList(),
      classTeachers: json['classTeachers'],
      subjectTeachers: json['subjectTeachers'],
      staffWorkload: (json['staffWorkload'] as List)
          .map((x) => StaffWorkload.fromJson(x))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalStaff': totalStaff,
      'staffByRole': staffByRole.map((x) => x.toJson()).toList(),
      'classTeachers': classTeachers,
      'subjectTeachers': subjectTeachers,
      'staffWorkload': staffWorkload.map((x) => x.toJson()).toList(),
    };
  }
}

class StaffByRole {
  final String role;
  final int count;

  StaffByRole({
    required this.role,
    required this.count,
  });

  factory StaffByRole.fromJson(Map<String, dynamic> json) {
    return StaffByRole(
      role: json['role'],
      count: json['count'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'role': role,
      'count': count,
    };
  }
}

class StaffWorkload {
  final String staffId;
  final String staffName;
  final String email;
  final int classesAssigned;
  final int subjectsAssigned;
  final int totalWorkload;

  StaffWorkload({
    required this.staffId,
    required this.staffName,
    required this.email,
    required this.classesAssigned,
    required this.subjectsAssigned,
    required this.totalWorkload,
  });

  factory StaffWorkload.fromJson(Map<String, dynamic> json) {
    return StaffWorkload(
      staffId: json['staffId'],
      staffName: json['staffName'],
      email: json['email'],
      classesAssigned: json['classesAssigned'],
      subjectsAssigned: json['subjectsAssigned'],
      totalWorkload: json['totalWorkload'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'staffId': staffId,
      'staffName': staffName,
      'email': email,
      'classesAssigned': classesAssigned,
      'subjectsAssigned': subjectsAssigned,
      'totalWorkload': totalWorkload,
    };
  }
}

class ExamStatistics {
  final int totalExams;
  final int upcomingExams;
  final List<ExamsBySubject> examsBySubject;
  final List<ExamsByClass> examsByClass;
  final List<RecentExamResult> recentExamResults;
  final List<dynamic> upcomingExamSchedules;

  ExamStatistics({
    required this.totalExams,
    required this.upcomingExams,
    required this.examsBySubject,
    required this.examsByClass,
    required this.recentExamResults,
    required this.upcomingExamSchedules,
  });

  factory ExamStatistics.fromJson(Map<String, dynamic> json) {
    return ExamStatistics(
      totalExams: json['totalExams'],
      upcomingExams: json['upcomingExams'],
      examsBySubject: (json['examsBySubject'] as List)
          .map((x) => ExamsBySubject.fromJson(x))
          .toList(),
      examsByClass: (json['examsByClass'] as List)
          .map((x) => ExamsByClass.fromJson(x))
          .toList(),
      recentExamResults: (json['recentExamResults'] as List)
          .map((x) => RecentExamResult.fromJson(x))
          .toList(),
      upcomingExamSchedules: json['upcomingExamSchedules'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalExams': totalExams,
      'upcomingExams': upcomingExams,
      'examsBySubject': examsBySubject.map((x) => x.toJson()).toList(),
      'examsByClass': examsByClass.map((x) => x.toJson()).toList(),
      'recentExamResults': recentExamResults.map((x) => x.toJson()).toList(),
      'upcomingExamSchedules': upcomingExamSchedules,
    };
  }
}

class ExamsBySubject {
  final String subjectId;
  final String subjectName;
  final String subjectCode;
  final int examCount;

  ExamsBySubject({
    required this.subjectId,
    required this.subjectName,
    required this.subjectCode,
    required this.examCount,
  });

  factory ExamsBySubject.fromJson(Map<String, dynamic> json) {
    return ExamsBySubject(
      subjectId: json['subjectId'],
      subjectName: json['subjectName'],
      subjectCode: json['subjectCode'],
      examCount: json['examCount'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'subjectId': subjectId,
      'subjectName': subjectName,
      'subjectCode': subjectCode,
      'examCount': examCount,
    };
  }
}

class ExamsByClass {
  final String classId;
  final String className;
  final String sectionName;
  final int examCount;
  final String academicYearName;

  ExamsByClass({
    required this.classId,
    required this.className,
    required this.sectionName,
    required this.examCount,
    required this.academicYearName,
  });

  factory ExamsByClass.fromJson(Map<String, dynamic> json) {
    return ExamsByClass(
      classId: json['classId'],
      className: json['className'],
      sectionName: json['sectionName'],
      examCount: json['examCount'],
      academicYearName: json['academicYearName'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'classId': classId,
      'className': className,
      'sectionName': sectionName,
      'examCount': examCount,
      'academicYearName': academicYearName,
    };
  }
}

class RecentExamResult {
  final String examId;
  final String examName;
  final String subjectName;
  final String className;
  final String sectionName;
  final double averageMarks;
  final int maxMarks;
  final int studentsAppeared;
  final String examDate;

  RecentExamResult({
    required this.examId,
    required this.examName,
    required this.subjectName,
    required this.className,
    required this.sectionName,
    required this.averageMarks,
    required this.maxMarks,
    required this.studentsAppeared,
    required this.examDate,
  });

  factory RecentExamResult.fromJson(Map<String, dynamic> json) {
    return RecentExamResult(
      examId: json['examId'],
      examName: json['examName'],
      subjectName: json['subjectName'],
      className: json['className'],
      sectionName: json['sectionName'],
      averageMarks: (json['averageMarks'] ?? 0).toDouble(),
      maxMarks: json['maxMarks'],
      studentsAppeared: json['studentsAppeared'],
      examDate: json['examDate'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'examId': examId,
      'examName': examName,
      'subjectName': subjectName,
      'className': className,
      'sectionName': sectionName,
      'averageMarks': averageMarks,
      'maxMarks': maxMarks,
      'studentsAppeared': studentsAppeared,
      'examDate': examDate,
    };
  }
}

class AttendanceStatistics {
  final double todayAttendanceRate;
  final double weeklyAttendanceRate;
  final double monthlyAttendanceRate;
  final List<dynamic> attendanceByClass;
  final List<dynamic> lowAttendanceStudents;

  AttendanceStatistics({
    required this.todayAttendanceRate,
    required this.weeklyAttendanceRate,
    required this.monthlyAttendanceRate,
    required this.attendanceByClass,
    required this.lowAttendanceStudents,
  });

  factory AttendanceStatistics.fromJson(Map<String, dynamic> json) {
    return AttendanceStatistics(
      todayAttendanceRate: (json['todayAttendanceRate'] ?? 0).toDouble(),
      weeklyAttendanceRate: (json['weeklyAttendanceRate'] ?? 0).toDouble(),
      monthlyAttendanceRate: (json['monthlyAttendanceRate'] ?? 0).toDouble(),
      attendanceByClass: json['attendanceByClass'] ?? [],
      lowAttendanceStudents: json['lowAttendanceStudents'] ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'todayAttendanceRate': todayAttendanceRate,
      'weeklyAttendanceRate': weeklyAttendanceRate,
      'monthlyAttendanceRate': monthlyAttendanceRate,
      'attendanceByClass': attendanceByClass,
      'lowAttendanceStudents': lowAttendanceStudents,
    };
  }
}

class ComplaintStatistics {
  final int totalComplaints;
  final int pendingComplaints;
  final int resolvedComplaints;
  final List<ComplaintsByCategory> complaintsByCategory;
  final List<ComplaintsByStatus> complaintsByStatus;
  final List<RecentComplaint> recentComplaints;

  ComplaintStatistics({
    required this.totalComplaints,
    required this.pendingComplaints,
    required this.resolvedComplaints,
    required this.complaintsByCategory,
    required this.complaintsByStatus,
    required this.recentComplaints,
  });

  factory ComplaintStatistics.fromJson(Map<String, dynamic> json) {
    return ComplaintStatistics(
      totalComplaints: json['totalComplaints'],
      pendingComplaints: json['pendingComplaints'],
      resolvedComplaints: json['resolvedComplaints'],
      complaintsByCategory: (json['complaintsByCategory'] as List)
          .map((x) => ComplaintsByCategory.fromJson(x))
          .toList(),
      complaintsByStatus: (json['complaintsByStatus'] as List)
          .map((x) => ComplaintsByStatus.fromJson(x))
          .toList(),
      recentComplaints: (json['recentComplaints'] as List)
          .map((x) => RecentComplaint.fromJson(x))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalComplaints': totalComplaints,
      'pendingComplaints': pendingComplaints,
      'resolvedComplaints': resolvedComplaints,
      'complaintsByCategory': complaintsByCategory.map((x) => x.toJson()).toList(),
      'complaintsByStatus': complaintsByStatus.map((x) => x.toJson()).toList(),
      'recentComplaints': recentComplaints.map((x) => x.toJson()).toList(),
    };
  }
}

class ComplaintsByCategory {
  final String category;
  final int count;

  ComplaintsByCategory({
    required this.category,
    required this.count,
  });

  factory ComplaintsByCategory.fromJson(Map<String, dynamic> json) {
    return ComplaintsByCategory(
      category: json['category'],
      count: json['count'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'category': category,
      'count': count,
    };
  }
}

class ComplaintsByStatus {
  final String status;
  final int count;

  ComplaintsByStatus({
    required this.status,
    required this.count,
  });

  factory ComplaintsByStatus.fromJson(Map<String, dynamic> json) {
    return ComplaintsByStatus(
      status: json['status'],
      count: json['count'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'count': count,
    };
  }
}

class RecentComplaint {
  final String id;
  final String title;
  final String category;
  final String status;
  final String author;
  final bool isAnonymous;
  final String createdAt;

  RecentComplaint({
    required this.id,
    required this.title,
    required this.category,
    required this.status,
    required this.author,
    required this.isAnonymous,
    required this.createdAt,
  });

  factory RecentComplaint.fromJson(Map<String, dynamic> json) {
    return RecentComplaint(
      id: json['id'],
      title: json['title'],
      category: json['category'],
      status: json['status'],
      author: json['author'],
      isAnonymous: json['isAnonymous'],
      createdAt: json['createdAt'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'category': category,
      'status': status,
      'author': author,
      'isAnonymous': isAnonymous,
      'createdAt': createdAt,
    };
  }
}

class AcademicStatistics {
  final int totalAcademicYears;
  final int activeAcademicYears;
  final int totalClasses;
  final int totalSubjects;
  final int classSubjectMappings;
  final List<AcademicYearDetail> academicYearDetails;

  AcademicStatistics({
    required this.totalAcademicYears,
    required this.activeAcademicYears,
    required this.totalClasses,
    required this.totalSubjects,
    required this.classSubjectMappings,
    required this.academicYearDetails,
  });

  factory AcademicStatistics.fromJson(Map<String, dynamic> json) {
    return AcademicStatistics(
      totalAcademicYears: json['totalAcademicYears'],
      activeAcademicYears: json['activeAcademicYears'],
      totalClasses: json['totalClasses'],
      totalSubjects: json['totalSubjects'],
      classSubjectMappings: json['classSubjectMappings'],
      academicYearDetails: (json['academicYearDetails'] as List)
          .map((x) => AcademicYearDetail.fromJson(x))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalAcademicYears': totalAcademicYears,
      'activeAcademicYears': activeAcademicYears,
      'totalClasses': totalClasses,
      'totalSubjects': totalSubjects,
      'classSubjectMappings': classSubjectMappings,
      'academicYearDetails': academicYearDetails.map((x) => x.toJson()).toList(),
    };
  }
}

class AcademicYearDetail {
  final String academicYearId;
  final String academicYearName;
  final String startDate;
  final String endDate;
  final bool isActive;
  final int totalClasses;
  final int totalStudents;
  final int totalExams;

  AcademicYearDetail({
    required this.academicYearId,
    required this.academicYearName,
    required this.startDate,
    required this.endDate,
    required this.isActive,
    required this.totalClasses,
    required this.totalStudents,
    required this.totalExams,
  });

  factory AcademicYearDetail.fromJson(Map<String, dynamic> json) {
    return AcademicYearDetail(
      academicYearId: json['academicYearId'],
      academicYearName: json['academicYearName'],
      startDate: json['startDate'],
      endDate: json['endDate'],
      isActive: json['isActive'],
      totalClasses: json['totalClasses'],
      totalStudents: json['totalStudents'],
      totalExams: json['totalExams'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'academicYearId': academicYearId,
      'academicYearName': academicYearName,
      'startDate': startDate,
      'endDate': endDate,
      'isActive': isActive,
      'totalClasses': totalClasses,
      'totalStudents': totalStudents,
      'totalExams': totalExams,
    };
  }
}

class HolidayStatistics {
  final int totalHolidays;
  final int upcomingHolidays;
  final int publicHolidays;
  final int schoolHolidays;
  final List<UpcomingHoliday> upcomingHolidaysList;

  HolidayStatistics({
    required this.totalHolidays,
    required this.upcomingHolidays,
    required this.publicHolidays,
    required this.schoolHolidays,
    required this.upcomingHolidaysList,
  });

  factory HolidayStatistics.fromJson(Map<String, dynamic> json) {
    return HolidayStatistics(
      totalHolidays: json['totalHolidays'],
      upcomingHolidays: json['upcomingHolidays'],
      publicHolidays: json['publicHolidays'],
      schoolHolidays: json['schoolHolidays'],
      upcomingHolidaysList: (json['upcomingHolidaysList'] as List)
          .map((x) => UpcomingHoliday.fromJson(x))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalHolidays': totalHolidays,
      'upcomingHolidays': upcomingHolidays,
      'publicHolidays': publicHolidays,
      'schoolHolidays': schoolHolidays,
      'upcomingHolidaysList': upcomingHolidaysList.map((x) => x.toJson()).toList(),
    };
  }
}

class UpcomingHoliday {
  final int id;
  final String name;
  final String date;
  final String description;
  final bool isPublicHoliday;
  final int daysUntilHoliday;

  UpcomingHoliday({
    required this.id,
    required this.name,
    required this.date,
    required this.description,
    required this.isPublicHoliday,
    required this.daysUntilHoliday,
  });

  factory UpcomingHoliday.fromJson(Map<String, dynamic> json) {
    return UpcomingHoliday(
      id: json['id'],
      name: json['name'],
      date: json['date'],
      description: json['description'] ?? '',
      isPublicHoliday: json['isPublicHoliday'],
      daysUntilHoliday: json['daysUntilHoliday'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'date': date,
      'description': description,
      'isPublicHoliday': isPublicHoliday,
      'daysUntilHoliday': daysUntilHoliday,
    };
  }
}

// Main response wrapper
class DashboardResponse {
  final bool success;
  final DashboardData data;
  final String message;

  DashboardResponse({
    required this.success,
    required this.data,
    required this.message,
  });

  factory DashboardResponse.fromJson(Map<String, dynamic> json) {
    return DashboardResponse(
      success: json['success'],
      data: DashboardData.fromJson(json['data']),
      message: json['message'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'data': data.toJson(),
      'message': message,
    };
  }
}