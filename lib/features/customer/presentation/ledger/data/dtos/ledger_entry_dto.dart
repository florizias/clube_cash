import 'package:cloud_firestore/cloud_firestore.dart';

class LedgerEntryDto {
  final String userId;
  final String idempotencyKey;
  final String createdBy;

  final String type;
  final String status;

  final String source;
  final String sourceId;

  final String partnerId;
  final String partnerName;

  final int points;
  final double cashbackValue;
  final double purchaseValue;

  final String description;
  final Timestamp createdAt;

  const LedgerEntryDto({
    required this.userId,
    required this.idempotencyKey,
    required this.createdBy,
    required this.type,
    required this.status,
    required this.source,
    required this.sourceId,
    required this.partnerId,
    required this.partnerName,
    required this.points,
    required this.cashbackValue,
    required this.purchaseValue,
    required this.description,
    required this.createdAt,
  });

  factory LedgerEntryDto.fromJson(Map<String, dynamic> json) {
    return LedgerEntryDto(
      userId: json['userId']?.toString() ?? '',
      idempotencyKey: json['idempotencyKey']?.toString() ?? '',
      createdBy: json['createdBy']?.toString() ?? '',

      type: json['type']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      source: json['source']?.toString() ?? '',
      sourceId: json['sourceId']?.toString() ?? '',

      partnerId: json['partnerId']?.toString() ?? '',
      partnerName: json['partnerName']?.toString() ?? '',

      points: (json['points'] as num?)?.toInt() ?? 0,
      cashbackValue: (json['cashbackValue'] as num?)?.toDouble() ?? 0,
      purchaseValue: (json['purchaseValue'] as num?)?.toDouble() ?? 0,

      description: json['description']?.toString() ?? '',
      createdAt: json['createdAt'] is Timestamp ? json['createdAt'] as Timestamp : Timestamp.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'idempotencyKey': idempotencyKey,
      'createdBy': createdBy,
      'type': type,
      'status': status,
      'source': source,
      'sourceId': sourceId,
      'partnerId': partnerId,
      'partnerName': partnerName,
      'points': points,
      'cashbackValue': cashbackValue,
      'purchaseValue': purchaseValue,
      'description': description,
      'createdAt': createdAt,
    };
  }
}
