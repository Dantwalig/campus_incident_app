import 'package:cloud_firestore/cloud_firestore.dart';

enum UserRole { student, staff }

class AppUser {
  const AppUser({
    required this.uid,
    required this.name,
    required this.email,
    required this.role,
    required this.createdAt,
    this.department,
  });

  final String uid;
  final String name;
  final String email;
  final UserRole role;
  final String? department;
  final DateTime createdAt;

  bool get isStaff => role == UserRole.staff;

  factory AppUser.fromMap(String uid, Map<String, dynamic> map) {
    return AppUser(
      uid: uid,
      name: (map['name'] as String?) ?? 'Unknown',
      email: (map['email'] as String?) ?? '',
      role: map['role'] == 'staff' ? UserRole.staff : UserRole.student,
      department: map['department'] as String?,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
        'name': name,
        'email': email,
        'role': role.name,
        'department': department,
        'createdAt': Timestamp.fromDate(createdAt),
      };
}
