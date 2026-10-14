import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../services/firebase/firebase_providers.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../data/model/partner_product_model.dart';
import '../../data/repositories/partner_images_repository.dart';
import 'partner_products_provider.dart';

final partnerImagesRepositoryProvider = Provider<PartnerImagesRepository>((ref) {
  final db = ref.watch(firebaseFirestoreProvider);

  return PartnerImagesRepository(db: db, storage: FirebaseStorage.instance);
});

final partnerImagesActionsProvider = Provider<PartnerImagesActions>((ref) {
  final repository = ref.watch(partnerImagesRepositoryProvider);
  return PartnerImagesActions(ref, repository);
});

class PartnerImagesActions {
  final Ref _ref;
  final PartnerImagesRepository _repository;

  PartnerImagesActions(this._ref, this._repository);

  Future<void> updateCurrentPartnerImages({XFile? logoImage, XFile? coverImage}) async {
    final uid = _ref.read(currentUidProvider);

    if (uid == null) {
      throw Exception('Parceiro não autenticado.');
    }

    String? logoUrl;
    String? coverImageUrl;

    if (logoImage != null) {
      logoUrl = await _repository.uploadPartnerLogo(partnerId: uid, image: logoImage);
    }

    if (coverImage != null) {
      coverImageUrl = await _repository.uploadPartnerCover(partnerId: uid, image: coverImage);
    }

    await _repository.updatePartnerImages(partnerId: uid, logoUrl: logoUrl, coverImageUrl: coverImageUrl);
  }

  final partnerProductsProvider = StreamProvider<List<PartnerProductModel>>((ref) {
    final userAsync = ref.watch(firebaseUserProvider);

    return userAsync.when(
      data: (user) {
        if (user == null) {
          return Stream.value([]);
        }

        final repository = ref.watch(partnerProductsRepositoryProvider);
        return repository.watchProductsByPartnerId(user.uid);
      },
      loading: () => Stream.value([]),
      error: (_, _) => Stream.value([]),
    );
  });
}
