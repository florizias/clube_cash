import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../services/firebase/firebase_providers.dart';
import '../../domain/repositories/admin_ads_repository.dart';
import '../../models/ad_banner.dart';

final adminAdsRepositoryProvider = Provider<AdminAdsRepository>((ref) {
  final db = ref.watch(firebaseFirestoreProvider);

  return AdminAdsRepository(db: db, storage: FirebaseStorage.instance);
});

final adminAdsProvider = StreamProvider<List<AdBanner>>((ref) {
  final repository = ref.watch(adminAdsRepositoryProvider);
  return repository.watchAllBanners();
});

final activeAdsProvider = StreamProvider<List<AdBanner>>((ref) {
  final repository = ref.watch(adminAdsRepositoryProvider);
  return repository.watchActiveBanners();
});

final adminAdsActionsProvider = Provider<AdminAdsActions>((ref) {
  final repository = ref.watch(adminAdsRepositoryProvider);
  return AdminAdsActions(repository);
});

class AdminAdsActions {
  final AdminAdsRepository _repository;

  AdminAdsActions(this._repository);

  String createBannerId() {
    return _repository.createBannerId();
  }

  Future<String> uploadBannerImage({required String bannerId, required XFile image}) {
    return _repository.uploadBannerImage(bannerId: bannerId, image: image);
  }

  Future<void> createBanner(AdBanner banner) {
    return _repository.createBanner(banner);
  }

  Future<void> updateBanner(AdBanner banner) {
    return _repository.updateBanner(banner);
  }

  Future<void> toggleActive(String id, bool value) {
    return _repository.toggleBannerActive(id: id, isActive: value);
  }

  Future<void> deleteBanner(String id) {
    return _repository.deleteBanner(id);
  }
}
