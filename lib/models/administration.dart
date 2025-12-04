class AcademicYear {
  final String? id;
  final String year;
  final String startDate;
  final String endDate;
  final bool isActive;

  AcademicYear({
    this.id,
    required this.year,
    required this.startDate,
    required this.endDate,
    required this.isActive,
  });

  factory AcademicYear.fromJson(Map<String, dynamic> json) {
    return AcademicYear(
      id: json['id']?.toString(),
      year: json['year'],
      startDate: json['startDate'],
      endDate: json['endDate'],
      isActive: json['isActive'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'year': year,
      'startDate': startDate,
      'endDate': endDate,
      'isActive': isActive,
    };
  }
}

class AdminUser {
  final String id;
  final String email;
  final String mobileNumber;
  final String role;
  final String firstName;
  final String lastName;
  final String? createdAt;
  final String? updatedAt;

  AdminUser({
    required this.id,
    required this.email,
    required this.mobileNumber,
    required this.role,
    required this.firstName,
    required this.lastName,
    this.createdAt,
    this.updatedAt,
  });

  factory AdminUser.fromJson(Map<String, dynamic> json) {
    return AdminUser(
      id: json['id']?.toString() ?? '',
      email: json['email'] ?? '',
      mobileNumber: json['mobileNumber']?.toString() ?? '',
      role: json['role'] ?? '',
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      createdAt: json['createdAt']?.toString(),
      updatedAt: json['updatedAt']?.toString(),
    );
  }
}

class UserPayload {
  final String email;
  final String mobileNumber;
  final String password;
  final String role;
  final String firstName;
  final String lastName;

  UserPayload({
    required this.email,
    required this.mobileNumber,
    required this.password,
    required this.role,
    required this.firstName,
    required this.lastName,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'mobileNumber': mobileNumber,
      'password': password,
      'role': role,
      'firstName': firstName,
      'lastName': lastName,
    };
  }
}
