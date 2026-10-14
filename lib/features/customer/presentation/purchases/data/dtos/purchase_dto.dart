import 'package:cloud_firestore/cloud_firestore.dart';

class PurchaseRequestDto {
  final String id;

  final String userId;
  final String userName;
  final String userEmail;

  final String customerId;
  final String customerName;
  final String customerEmail;

  final String partnerId;
  final String partnerName;
  final String partnerStoreId;

  final String nfCode;
  final String receiptImageUrl;

  final DateTime purchaseDate;

  final double purchaseValue;
  final double amount;

  final double cashbackPercentage;
  final double cashbackPercent;

  final double cashbackValue;
  final double cashbackAmount;

  final String status;
  final String rejectionReason;

  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? approvedAt;
  final DateTime? rejectedAt;

  const PurchaseRequestDto({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userEmail,
    required this.customerId,
    required this.customerName,
    required this.customerEmail,
    required this.partnerId,
    required this.partnerName,
    required this.partnerStoreId,
    required this.nfCode,
    required this.receiptImageUrl,
    required this.purchaseDate,
    required this.purchaseValue,
    required this.amount,
    required this.cashbackPercentage,
    required this.cashbackPercent,
    required this.cashbackValue,
    required this.cashbackAmount,
    required this.status,
    required this.rejectionReason,
    required this.createdAt,
    required this.updatedAt,
    required this.approvedAt,
    required this.rejectedAt,
  });

  factory PurchaseRequestDto.fromFirestore(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();

    DateTime dateFrom(dynamic value, {DateTime? fallback}) {
      if (value is Timestamp) {
        return value.toDate();
      }

      return fallback ?? DateTime.fromMillisecondsSinceEpoch(0);
    }

    DateTime? nullableDateFrom(dynamic value) {
      if (value is Timestamp) {
        return value.toDate();
      }

      return null;
    }

    final userId = data['userId']?.toString() ?? data['customerId']?.toString() ?? '';

    final userName = data['userName']?.toString() ?? data['customerName']?.toString() ?? 'Cliente';

    final userEmail = data['userEmail']?.toString() ?? data['customerEmail']?.toString() ?? '';

    final customerId = data['customerId']?.toString() ?? userId;
    final customerName = data['customerName']?.toString() ?? userName;
    final customerEmail = data['customerEmail']?.toString() ?? userEmail;

    final purchaseValue = (data['purchaseValue'] as num?)?.toDouble() ?? (data['amount'] as num?)?.toDouble() ?? 0;

    final amount = (data['amount'] as num?)?.toDouble() ?? purchaseValue;

    final cashbackPercentage = (data['cashbackPercentage'] as num?)?.toDouble() ?? (data['cashbackPercent'] as num?)?.toDouble() ?? 0;

    final cashbackPercent = (data['cashbackPercent'] as num?)?.toDouble() ?? cashbackPercentage;

    final cashbackValue = (data['cashbackValue'] as num?)?.toDouble() ?? (data['cashbackAmount'] as num?)?.toDouble() ?? 0;

    final cashbackAmount = (data['cashbackAmount'] as num?)?.toDouble() ?? cashbackValue;

    return PurchaseRequestDto(
      id: data['id']?.toString() ?? doc.id,

      userId: userId,
      userName: userName,
      userEmail: userEmail,

      customerId: customerId,
      customerName: customerName,
      customerEmail: customerEmail,

      partnerId: data['partnerId']?.toString() ?? '',
      partnerName: data['partnerName']?.toString() ?? '',
      partnerStoreId: data['partnerStoreId']?.toString() ?? '',

      nfCode: data['nfCode']?.toString() ?? '',
      receiptImageUrl: data['receiptImageUrl']?.toString() ?? '',

      purchaseDate: dateFrom(data['purchaseDate'], fallback: DateTime.now()),

      purchaseValue: purchaseValue,
      amount: amount,

      cashbackPercentage: cashbackPercentage,
      cashbackPercent: cashbackPercent,

      cashbackValue: cashbackValue,
      cashbackAmount: cashbackAmount,

      status: data['status']?.toString() ?? 'pending',
      rejectionReason: data['rejectionReason']?.toString() ?? '',

      createdAt: dateFrom(data['createdAt']),
      updatedAt: dateFrom(data['updatedAt']),
      approvedAt: nullableDateFrom(data['approvedAt']),
      rejectedAt: nullableDateFrom(data['rejectedAt']),
    );
  }

  bool get isPending => status == 'pending';

  bool get isApproved => status == 'approved';

  bool get isRejected => status == 'rejected';

  String get statusLabel {
    switch (status) {
      case 'approved':
        return 'Aprovado';
      case 'rejected':
        return 'Rejeitado';
      default:
        return 'Pendente';
    }
  }
}
