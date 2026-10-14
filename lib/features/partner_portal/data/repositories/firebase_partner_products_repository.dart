import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/utils/image_webp_converter.dart';
import '../model/partner_product_model.dart';
import 'partner_products_repository.dart';

class FirebasePartnerProductsRepository implements PartnerProductsRepository {
  final FirebaseFirestore _db;
  final FirebaseStorage _storage;

  FirebasePartnerProductsRepository({required FirebaseFirestore db, required FirebaseStorage storage}) : _db = db, _storage = storage;

  @override
  Stream<List<PartnerProductModel>> watchProductsByPartnerId(String partnerId) {
    return _db.collection('partners').doc(partnerId).snapshots().map((doc) {
      final data = doc.data();

      if (data == null) {
        return <PartnerProductModel>[];
      }

      final rawProducts = data['products'];

      if (rawProducts is! List) {
        return <PartnerProductModel>[];
      }

      final products = rawProducts
          .asMap()
          .entries
          .map((entry) {
            final index = entry.key;
            final item = entry.value;

            if (item is! Map) return null;

            final json = Map<String, dynamic>.from(item);
            json['id'] = json['id']?.toString() ?? index.toString();

            return PartnerProductModel.fromJson(json);
          })
          .whereType<PartnerProductModel>()
          .toList();

      products.sort((a, b) {
        return a.name.toLowerCase().compareTo(b.name.toLowerCase());
      });

      return products;
    });
  }

  @override
  Stream<PartnerProductModel?> watchProductById({required String partnerId, required String productId}) {
    return watchProductsByPartnerId(partnerId).map((products) {
      for (final product in products) {
        if (product.id == productId) {
          return product;
        }
      }

      return null;
    });
  }

  @override
  Future<void> addProduct({
    required String partnerId,
    required String name,
    required String description,
    required double price,
    required int stock,
    required String category,
    required bool isActive,
    required XFile image,
  }) async {
    final partnerRef = _db.collection('partners').doc(partnerId);
    final productId = partnerRef.collection('_product_ids').doc().id;

    final partnerSnapshot = await partnerRef.get();
    final partnerData = partnerSnapshot.data();

    if (partnerData == null) {
      throw Exception('Parceiro não encontrado.');
    }

    final cashbackLabel = (partnerData['cashbackLabel'] as num?)?.toDouble() ?? 0;

    final imageUrl = await _uploadProductImage(partnerId: partnerId, productId: productId, image: image);

    final now = Timestamp.now();

    final product = {
      'id': productId,
      'name': name.trim(),
      'description': description.trim(),
      'stock': stock,
      'category': category.trim(),
      'cashbackLabel': cashbackLabel,
      'price': price,
      'imageUrl': imageUrl,
      'isActive': isActive,
      'createdAt': now,
      'updatedAt': now,
    };

    await partnerRef.update({
      'products': FieldValue.arrayUnion([product]),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<String> _uploadProductImage({required String partnerId, required String productId, required XFile image}) async {
    final webpBytes = await ImageWebpConverter.xFileToWebp(image: image);

    final ref = _storage.ref('partners/$partnerId/products/$productId/image.webp');

    final snapshot = await ref.putData(
      webpBytes,
      SettableMetadata(contentType: 'image/webp', customMetadata: {'originalName': image.name, 'originalMimeType': image.mimeType ?? ''}),
    );

    return snapshot.ref.getDownloadURL();
  }

  @override
  Future<void> deleteProduct({required String partnerId, required String productId}) async {
    final partnerRef = _db.collection('partners').doc(partnerId);

    await _db.runTransaction((transaction) async {
      final snapshot = await transaction.get(partnerRef);
      final data = snapshot.data();

      if (data == null) {
        throw Exception('Parceiro não encontrado.');
      }

      final rawProducts = data['products'];

      if (rawProducts is! List) {
        return;
      }

      final updatedProducts = rawProducts.where((item) {
        if (item is! Map) return true;

        final product = Map<String, dynamic>.from(item);
        final id = product['id']?.toString() ?? '';

        return id != productId;
      }).toList();

      transaction.update(partnerRef, {'products': updatedProducts, 'updatedAt': FieldValue.serverTimestamp()});
    });

    try {
      await _storage.ref('partners/$partnerId/products/$productId/image.webp').delete();
    } catch (_) {}
  }

  @override
  Future<void> updateProduct({
    required String partnerId,
    required String productId,
    required String name,
    required String description,
    required double price,
    required int stock,
    required String category,
    required bool isActive,
    XFile? image,
  }) async {
    final partnerRef = _db.collection('partners').doc(partnerId);

    final partnerSnapshot = await partnerRef.get();
    final partnerData = partnerSnapshot.data();

    if (partnerData == null) {
      throw Exception('Parceiro não encontrado.');
    }

    final rawProducts = partnerData['products'];

    if (rawProducts is! List) {
      throw Exception('Lista de produtos não encontrada.');
    }

    final products = rawProducts.map((item) {
      if (item is Map) {
        return Map<String, dynamic>.from(item);
      }

      return <String, dynamic>{};
    }).toList();

    final index = products.indexWhere((item) {
      return item['id']?.toString() == productId;
    });

    if (index == -1) {
      throw Exception('Produto não encontrado.');
    }

    final currentProduct = products[index];

    String imageUrl = currentProduct['imageUrl']?.toString() ?? '';

    if (image != null) {
      imageUrl = await _uploadProductImage(partnerId: partnerId, productId: productId, image: image);
    }

    final cashbackLabel = (currentProduct['cashbackLabel'] as num?)?.toDouble() ?? (partnerData['cashbackLabel'] as num?)?.toDouble() ?? 0;

    products[index] = {
      ...currentProduct,
      'id': productId,
      'name': name.trim(),
      'description': description.trim(),
      'stock': stock,
      'category': category.trim(),
      'cashbackLabel': cashbackLabel,
      'price': price,
      'imageUrl': imageUrl,
      'isActive': isActive,
      'updatedAt': Timestamp.now(),
    };

    await partnerRef.update({'products': products, 'updatedAt': FieldValue.serverTimestamp()});
  }
}
