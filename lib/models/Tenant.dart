class Tenant {
  final String? id;
  final String name;
  final String schemaName;
  final String? createdAt;
  final String? updatedAt;

  Tenant({
    this.id,
    required this.name,
    required this.schemaName,
    this.createdAt,
    this.updatedAt,
  });

  factory Tenant.fromJson(Map<String, dynamic> json) {
    return Tenant(
      id: json['id'],
      name: json['name'],
      schemaName: json['schemaName'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'schema_name': schemaName,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}