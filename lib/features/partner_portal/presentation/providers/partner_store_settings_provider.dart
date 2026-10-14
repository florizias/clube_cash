import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../services/firebase/firebase_providers.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../data/repositories/partner_store_settings_repository.dart';

final partnerStoreSettingsRepositoryProvider = Provider<PartnerStoreSettingsRepository>((ref) {
  final db = ref.watch(firebaseFirestoreProvider);

  return PartnerStoreSettingsRepository(db: db, storage: FirebaseStorage.instance);
});

final currentPartnerStoreSettingsProvider = StreamProvider<PartnerStoreSettingsDto?>((ref) {
  final uid = ref.watch(currentUidProvider);

  if (uid == null) {
    return Stream.value(null);
  }

  final repository = ref.watch(partnerStoreSettingsRepositoryProvider);

  return repository.watchPartnerStore(uid);
});

final partnerStoreSettingsActionsProvider = Provider<PartnerStoreSettingsActions>((ref) {
  final repository = ref.watch(partnerStoreSettingsRepositoryProvider);

  return PartnerStoreSettingsActions(ref, repository);
});

class PartnerStoreSettingsActions {
  final Ref _ref;
  final PartnerStoreSettingsRepository _repository;

  PartnerStoreSettingsActions(this._ref, this._repository);

  Future<void> updateCurrentPartnerStore({
    required String name,
    required String category,
    required String address,
    required String cep,
    required String street,
    required String number,
    required String neighborhood,
    required String city,
    required String state,
    required String whatsapp,
    required String website,
    required String instagram,
    required String facebook,
    required String tiktok,
    required String description,
    XFile? logoImage,
    XFile? coverImage,
  }) async {
    final uid = _ref.read(currentUidProvider);

    if (uid == null) {
      throw Exception('Parceiro não autenticado.');
    }

    String? logoUrl;
    String? coverImageUrl;

    if (logoImage != null) {
      logoUrl = await _repository.uploadLogo(partnerId: uid, image: logoImage);
    }

    if (coverImage != null) {
      coverImageUrl = await _repository.uploadCover(partnerId: uid, image: coverImage);
    }

    await _repository.updateStoreSettings(
      partnerId: uid,
      name: name,
      category: category,
      address: address,
      cep: cep,
      street: street,
      number: number,
      neighborhood: neighborhood,
      city: city,
      state: state,
      whatsapp: whatsapp,
      website: website,
      instagram: instagram,
      facebook: facebook,
      tiktok: tiktok,
      description: description,
      logoUrl: logoUrl,
      coverImageUrl: coverImageUrl,
    );
  }
}
