import 'package:cloud_firestore/cloud_firestore.dart';

class CustomerPurchaseRequestModel {
  final String id;
  final String partnerId;
  final String partnerName;
  final String partnerStoreId;
  final String customerId;
  final String customerName;
  final double amount;
  final double cashbackPercent;
  final double cashbackAmount;
  final String receiptImageUrl;
  final String status;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? approvedAt;
  final DateTime? rejectedAt;

  const CustomerPurchaseRequestModel({
    required this.id,
    required this.partnerId,
    required this.partnerName,
    required this.partnerStoreId,
    required this.customerId,
    required this.customerName,
    required this.amount,
    required this.cashbackPercent,
    required this.cashbackAmount,
    required this.receiptImageUrl,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.approvedAt,
    required this.rejectedAt,
  });

  factory CustomerPurchaseRequestModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};

    DateTime? dateFrom(dynamic value) {
      if (value is Timestamp) return value.toDate();
      return null;
    }

    return CustomerPurchaseRequestModel(
      id: doc.id,
      partnerId: data['partnerId']?.toString() ?? '',
      partnerName: data['partnerName']?.toString() ?? '',
      partnerStoreId: data['partnerStoreId']?.toString() ?? '',
      customerId: data['customerId']?.toString() ?? '',
      customerName: data['customerName']?.toString() ?? '',
      amount: (data['amount'] as num?)?.toDouble() ?? 0,
      cashbackPercent: (data['cashbackPercent'] as num?)?.toDouble() ?? 0,
      cashbackAmount: (data['cashbackAmount'] as num?)?.toDouble() ?? 0,
      receiptImageUrl: data['receiptImageUrl']?.toString() ?? '',
      status: data['status']?.toString() ?? 'pending',
      createdAt: dateFrom(data['createdAt']),
      updatedAt: dateFrom(data['updatedAt']),
      approvedAt: dateFrom(data['approvedAt']),
      rejectedAt: dateFrom(data['rejectedAt']),
    );
  }
}
