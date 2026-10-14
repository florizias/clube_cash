import 'package:cloud_firestore/cloud_firestore.dart';

class CustomerWalletDto {
  final String userId;

  final int availablePoints;
  final int pendingPoints;
  final int rejectedPoints;
  final int lifetimePoints;

  final double availableCashbackValue;
  final double pendingCashbackValue;

  final Timestamp updatedAt;

  const CustomerWalletDto({
    required this.userId,
    required this.availablePoints,
    required this.pendingPoints,
    required this.rejectedPoints,
    required this.lifetimePoints,
    required this.availableCashbackValue,
    required this.pendingCashbackValue,
    required this.updatedAt,
  });

  factory CustomerWalletDto.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final json = doc.data() ?? {};

    return CustomerWalletDto(
      userId: json['userId']?.toString() ?? doc.id,
      availablePoints: (json['availablePoints'] as num?)?.toInt() ?? 0,
      pendingPoints: (json['pendingPoints'] as num?)?.toInt() ?? 0,
      rejectedPoints: (json['rejectedPoints'] as num?)?.toInt() ?? 0,
      lifetimePoints: (json['lifetimePoints'] as num?)?.toInt() ?? 0,
      availableCashbackValue: (json['availableCashbackValue'] as num?)?.toDouble() ?? 0,
      pendingCashbackValue: (json['pendingCashbackValue'] as num?)?.toDouble() ?? 0,
      updatedAt: json['updatedAt'] is Timestamp ? json['updatedAt'] as Timestamp : Timestamp.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'availablePoints': availablePoints,
      'pendingPoints': pendingPoints,
      'rejectedPoints': rejectedPoints,
      'lifetimePoints': lifetimePoints,
      'availableCashbackValue': availableCashbackValue,
      'pendingCashbackValue': pendingCashbackValue,
      'updatedAt': updatedAt,
    };
  }
}
