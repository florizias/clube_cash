import 'package:cloud_firestore/cloud_firestore.dart';

class StorePartnershipRequestDto {
  final String uid;
  final String storeName;
  final String cnpj;
  final String category;
  final String monthlyRevenue;
  final String openingDate;
  final String address;
  final String legalResponsible;
  final String commercialEmail;
  final String loginEmail;
  final String whatsapp;
  final String whyParticipate;
  final int cashbackProposal;
  final String status;
  final Timestamp createdAt;
  final Timestamp updatedAt;

  const StorePartnershipRequestDto({
    required this.uid,
    required this.storeName,
    required this.cnpj,
    required this.category,
    required this.monthlyRevenue,
    required this.openingDate,
    required this.address,
    required this.legalResponsible,
    required this.commercialEmail,
    required this.loginEmail,
    required this.whatsapp,
    required this.whyParticipate,
    required this.cashbackProposal,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'storeName': storeName.trim(),
      'cnpj': cnpj.trim(),
      'category': category.trim(),
      'monthlyRevenue': monthlyRevenue.trim(),
      'openingDate': openingDate.trim(),
      'address': address.trim(),
      'legalResponsible': legalResponsible.trim(),
      'commercialEmail': commercialEmail.trim().toLowerCase(),
      'loginEmail': loginEmail.trim().toLowerCase(),
      'whatsapp': whatsapp.trim(),
      'whyParticipate': whyParticipate.trim(),
      'cashbackProposal': cashbackProposal,
      'status': status,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  factory StorePartnershipRequestDto.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final json = doc.data() ?? {};

    Timestamp parseTimestamp(dynamic value) {
      if (value is Timestamp) return value;
      return Timestamp.now();
    }

    return StorePartnershipRequestDto(
      uid: json['uid']?.toString() ?? doc.id,
      storeName: json['storeName']?.toString() ?? '',
      cnpj: json['cnpj']?.toString() ?? '',
      category: json['category']?.toString() ?? '',
      monthlyRevenue: json['monthlyRevenue']?.toString() ?? '',
      openingDate: json['openingDate']?.toString() ?? '',
      address: json['address']?.toString() ?? '',
      legalResponsible: json['legalResponsible']?.toString() ?? '',
      commercialEmail: json['commercialEmail']?.toString() ?? '',
      loginEmail: json['loginEmail']?.toString() ?? '',
      whatsapp: json['whatsapp']?.toString() ?? '',
      whyParticipate: json['whyParticipate']?.toString() ?? '',
      cashbackProposal: int.tryParse(json['cashbackProposal']?.toString() ?? '0') ?? 0,
      status: json['status']?.toString() ?? 'pending',
      createdAt: parseTimestamp(json['createdAt']),
      updatedAt: parseTimestamp(json['updatedAt']),
    );
  }
}
