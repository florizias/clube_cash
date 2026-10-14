import 'package:image_picker/image_picker.dart';

import '../../data/model/partner_product_model.dart';

abstract class PartnerProductsRepository {
  Stream<List<PartnerProductModel>> watchProductsByPartnerId(String partnerId);

  Stream<PartnerProductModel?> watchProductById({required String partnerId, required String productId});

  Future<void> addProduct({
    required String partnerId,
    required String name,
    required String description,
    required double price,
    required int stock,
    required String category,
    required bool isActive,
    required XFile image,
  });

  Future<void> deleteProduct({required String partnerId, required String productId});

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
  });
}
