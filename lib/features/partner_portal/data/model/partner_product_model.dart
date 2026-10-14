import '../../../../core/utils/double_from.dart';

class PartnerProductModel {
  final String id;
  final String name;
  final String description;
  final String imageUrl;
  final double price;
  final bool isActive;
  final int stock;
  final String category;
  final double cashbackLabel;

  const PartnerProductModel({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.price,
    required this.isActive,
    required this.stock,
    required this.category,
    required this.cashbackLabel,
  });

  factory PartnerProductModel.fromJson(Map<String, dynamic> json) {
    return PartnerProductModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      imageUrl: json['imageUrl']?.toString() ?? '',
      price: doubleFrom(json['price']),
      isActive: json['isActive'] as bool? ?? true,
      stock: (json['stock'] as num?)?.toInt() ?? 0,
      category: json['category']?.toString() ?? '',
      cashbackLabel: doubleFrom(json['cashbackLabel']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name.trim(),
      'description': description.trim(),
      'imageUrl': imageUrl.trim(),
      'price': price,
      'isActive': isActive,
      'stock': stock,
      'category': category.trim(),
      'cashbackLabel': cashbackLabel,
    };
  }
}
