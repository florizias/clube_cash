import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfileDto {
  final String name;
  final String email;
  final String phone;

  //final String cpf;
  final String photoUrl;
  final String role;
  final String? storeId;
  final String status;
  final Timestamp createdAt;
  final Timestamp updatedAt;

  UserProfileDto({
    required this.name,
    required this.email,
    required this.phone,
    required this.photoUrl,
    required this.role,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.storeId,
  });

  factory UserProfileDto.fromJson(Map<String, dynamic> json) {
    Timestamp timestampFrom(dynamic value) {
      if (value is Timestamp) return value;
      return Timestamp.now();
    }

    return UserProfileDto(
      name: json['name']?.toString().trim() ?? '',
      email: json['email']?.toString().trim().toLowerCase() ?? '',
      phone: json['phone']?.toString().trim() ?? '',
      photoUrl: json['photoUrl']?.toString().trim() ?? '',
      role: json['role']?.toString() ?? 'customer',
      storeId: json['storeId']?.toString(),
      status: json['status']?.toString() ?? 'active',
      createdAt: timestampFrom(json['createdAt']),
      updatedAt: timestampFrom(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name.trim(),
      'email': email.trim().toLowerCase(),
      'phone': phone.trim(),
      'photoUrl': photoUrl.trim(),
      'role': role,
      'storeId': storeId,
      'status': status,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}
