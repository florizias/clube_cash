import 'package:cloud_firestore/cloud_firestore.dart';

class StoreDto {
  final String name;
  final String? logoUrl;
  final bool isActive;
  final int cashbackLabel;

  final String? rulesText;
  final Timestamp createdAt;
  final Timestamp updatedAt;

  const StoreDto({
    required this.name,
    required this.isActive,
    required this.cashbackLabel,
    required this.createdAt,
    required this.updatedAt,
    this.logoUrl,
    this.rulesText,
  });

  factory StoreDto.fromJson(Map<String, dynamic> json) {
    final status = json['status']?.toString();

    return StoreDto(
      name: json['name']?.toString().trim() ?? '',

      logoUrl: json['logoUrl']?.toString(),

      isActive: json['isActive'] is bool ? json['isActive'] as bool : status == 'active',

      cashbackLabel: (json['cashbackLabel'] as num?)?.toInt() ?? 0,

      rulesText: json['rulesText']?.toString(),

      createdAt: json['createdAt'] is Timestamp ? json['createdAt'] as Timestamp : Timestamp.now(),

      updatedAt: json['updatedAt'] is Timestamp ? json['updatedAt'] as Timestamp : Timestamp.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name.trim(),
      'logoUrl': logoUrl,
      'isActive': isActive,
      'cashbackLabel': cashbackLabel,
      'rulesText': rulesText,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}
