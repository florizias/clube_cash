import 'package:cloud_firestore/cloud_firestore.dart';

class AdBanner {
  final String id;
  final String title;
  final String imageURL;
  final String buttonLink;
  final String buttonText;
  final String description;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const AdBanner({
    required this.id,
    required this.title,
    required this.imageURL,
    required this.buttonLink,
    required this.buttonText,
    required this.description,
    required this.isActive,
    this.createdAt,
    this.updatedAt,
  });

  factory AdBanner.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final json = doc.data() ?? {};

    String readImageUrl() {
      final imageURL = json['imageURL']?.toString().trim() ?? '';
      if (imageURL.isNotEmpty) return imageURL;

      final imageUrl = json['imageUrl']?.toString().trim() ?? '';
      if (imageUrl.isNotEmpty) return imageUrl;

      final thumbnailUrl = json['thumbnailUrl']?.toString().trim() ?? '';
      if (thumbnailUrl.isNotEmpty) return thumbnailUrl;

      return '';
    }

    return AdBanner(
      id: doc.id,
      title: json['title']?.toString() ?? '',
      imageURL: readImageUrl(),
      buttonLink: json['buttonLink']?.toString() ?? '',
      buttonText: json['buttonText']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      isActive: json['isActive'] == true,
    );
  }
  
  factory AdBanner.fromJson(Map<String, dynamic> json) {
    return AdBanner(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      imageURL: json['imageURL']?.toString() ?? '',
      buttonLink: json['buttonLink']?.toString() ?? '',
      buttonText: json['buttonText']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      isActive: json['isActive'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title.trim(),
      'imageURL': imageURL.trim(),
      'buttonLink': buttonLink.trim(),
      'buttonText': buttonText.trim(),
      'description': description.trim(),
      'isActive': isActive,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  AdBanner copyWith({
    String? id,
    String? title,
    String? imageURL,
    String? buttonLink,
    String? buttonText,
    String? description,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AdBanner(
      id: id ?? this.id,
      title: title ?? this.title,
      imageURL: imageURL ?? this.imageURL,
      buttonLink: buttonLink ?? this.buttonLink,
      buttonText: buttonText ?? this.buttonText,
      description: description ?? this.description,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
