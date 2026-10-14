import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/utils/double_from.dart';

class PartnerStore {
  final String id;
  final String storeId;
  final String role;
  String status;

  final String name;
  final String email;
  final String whatsapp;
  final String cnpj;
  final String category;
  final String subCategory;

  final PartnerApplication? application;

  final double rating;
  final int ratingCount;
  double cashbackLabel;

  final String address;
  final double? latitude;
  final double? longitude;
  final String coverImageUrl;
  final String logoUrl;

  final String phone;
  final String instagram;
  final String facebook;
  final String tiktok;
  final String website; // opcional

  final List<OpeningHour> openingHours;
  final List<PartnerProduct> products;
  final List<PartnerReview> reviews;

  PartnerStore({
    required this.id,
    required this.storeId,
    required this.role,
    required this.status,
    required this.name,
    required this.email,
    required this.whatsapp,
    required this.cnpj,
    required this.category,
    required this.subCategory,
    required this.application,
    required this.rating,
    required this.ratingCount,
    required this.cashbackLabel,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.coverImageUrl,
    required this.logoUrl,
    required this.phone,
    required this.instagram,
    required this.facebook,
    required this.tiktok,
    required this.website,
    required this.openingHours,
    required this.products,
    required this.reviews,
  });

  factory PartnerStore.fromJson(String id, Map<String, dynamic> json) {
    DateTime? parseDate(dynamic value) {
      if (value == null) return null;
      if (value is DateTime) return value;
      if (value is Timestamp) return value.toDate();
      if (value is String) return DateTime.tryParse(value);
      return null;
    }

    return PartnerStore(
      id: id,
      storeId: json['storeId']?.toString() ?? '',
      role: json['role']?.toString() ?? 'partner',
      status: json['status']?.toString() ?? 'active',

      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      whatsapp: json['whatsapp']?.toString() ?? '',
      cnpj: json['cnpj']?.toString() ?? '',
      category: json['category']?.toString() ?? '',
      subCategory: json['subCategory']?.toString() ?? '',

      application: json['application'] is Map
          ? PartnerApplication(
              monthlyRevenue: Map<String, dynamic>.from(json['application'])['monthlyRevenue']?.toString(),
              openedAt: parseDate(Map<String, dynamic>.from(json['application'])['openedAt']),
              legalResponsibleName: Map<String, dynamic>.from(json['application'])['legalResponsibleName']?.toString(),
              whyJoin: Map<String, dynamic>.from(json['application'])['whyJoin']?.toString(),
              dateSolicitation: parseDate(Map<String, dynamic>.from(json['application'])['dateSolicitation']),
              approvedAt: parseDate(Map<String, dynamic>.from(json['application'])['approvedAt']),
            )
          : null,

      rating: (json['rating'] as num?)?.toDouble() ?? 0,
      ratingCount: (json['ratingCount'] as num?)?.toInt() ?? 0,
      cashbackLabel: (json['cashbackLabel'] as num?)?.toDouble() ?? 0,

      address: json['address']?.toString() ?? '',
      latitude: doubleFromNull(json['latitude']),
      longitude: doubleFromNull(json['longitude']),
      coverImageUrl: json['coverImageUrl']?.toString() ?? '',
      logoUrl: json['logoUrl']?.toString() ?? '',

      phone: json['phone']?.toString() ?? '',
      instagram: json['instagram']?.toString() ?? '',
      facebook: json['facebook']?.toString() ?? '',
      tiktok: json['tiktok']?.toString() ?? '',
      website: json['website']?.toString() ?? '',

      openingHours: ((json['openingHours'] as List?) ?? []).map((item) {
        final map = Map<String, dynamic>.from(item as Map);

        return OpeningHour(
          weekday: (map['weekday'] as num?)?.toInt() ?? 1,
          open: map['open']?.toString() ?? '',
          close: map['close']?.toString() ?? '',
          closed: map['closed'] == true,
        );
      }).toList(),

      products: ((json['products'] as List?) ?? []).map((item) {
        final map = Map<String, dynamic>.from(item as Map);

        return PartnerProduct(
          id: map['id']?.toString() ?? '',
          title: map['title']?.toString() ?? '',
          description: map['description']?.toString() ?? '',
          price: (map['price'] as num?)?.toDouble() ?? 0,
          cashbackLabel: (map['cashbackLabel'] as num?)?.toDouble() ?? 0,
          imageUrl: map['imageUrl']?.toString() ?? '',
          isActive: map['isActive'] is bool ? map['isActive'] : true,
        );
      }).toList(),

      reviews: ((json['reviews'] as List?) ?? []).map((item) {
        final map = Map<String, dynamic>.from(item as Map);

        return PartnerReview(
          id: map['id']?.toString() ?? '',
          userName: map['userName']?.toString() ?? '',
          rating: (map['rating'] as num?)?.toDouble() ?? 0,
          comment: map['comment']?.toString() ?? '',
          createdAt: parseDate(map['createdAt']) ?? DateTime.now(),
          status: map['status']?.toString() ?? 'active',
        );
      }).toList(),
    );
  }
}

class PartnerApplication {
  final String? monthlyRevenue;
  final DateTime? openedAt;

  final String? legalResponsibleName;

  final String? whyJoin;

  final DateTime? dateSolicitation;
  final DateTime? approvedAt;

  const PartnerApplication({this.monthlyRevenue, this.openedAt, this.legalResponsibleName, this.whyJoin, this.dateSolicitation, this.approvedAt});
}

class OpeningHour {
  final int weekday; // 1=Seg ... 7=Dom (padrão ISO)
  final String open; // "09:00"
  final String close; // "18:00"
  final bool closed;

  const OpeningHour({required this.weekday, required this.open, required this.close, required this.closed});
}

class PartnerProduct {
  final String id;
  final String title;
  final String description;
  final double price;
  final double cashbackLabel; // 3.0 => 3%
  final String imageUrl;
  final bool isActive;

  const PartnerProduct({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.cashbackLabel,
    required this.imageUrl,
    this.isActive = true,
  });
}

class PartnerReview {
  final String id;
  final String userName;
  final double rating;
  final String comment;
  final DateTime createdAt;
  final String status;

  const PartnerReview({
    required this.id,
    required this.userName,
    required this.rating,
    required this.comment,
    required this.createdAt,
    this.status = 'active',
  });
}
