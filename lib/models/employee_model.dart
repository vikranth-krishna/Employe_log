class Employee {
  final int? id;
  final String name;
  final String role;
  final DateTime? startDate;
  final DateTime? endDate;
  final bool isDeleted;

  Employee({
    this.id,
    required this.name,
    required this.role,
    this.startDate,
    this.endDate,
    this.isDeleted = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'role': role,
      'startDate': startDate?.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'isDeleted': isDeleted ? 1 : 0,
    };
  }

  factory Employee.fromMap(Map<String, dynamic> map) {
    return Employee(
      id: map['id'],
      name: map['name'],
      role: map['role'],
      startDate: map['startDate'] != null ? DateTime.parse(map['startDate']) : null,
      endDate: map['endDate'] != null ? DateTime.parse(map['endDate']) : null,
      isDeleted: map['isDeleted'] == 1,
    );
  }
}
