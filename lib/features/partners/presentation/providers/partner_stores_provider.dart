import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../services/firebase/firebase_providers.dart';
import '../../domain/repositories/stores_repository.dart';
import '../../models/partner_model.dart';

final partnerStoreRepositoryProvider = Provider<FirestorePartnerStoreRepository>((ref) {
  final db = ref.watch(firebaseFirestoreProvider);
  return FirestorePartnerStoreRepository(db);
});

final partnerStoresProvider = StreamProvider<List<PartnerStore>>((ref) {
  final repository = ref.watch(partnerStoreRepositoryProvider);
  return repository.watchActivePartners();
});

final partnerByIdProvider = StreamProvider.family<PartnerStore?, String>((ref, partnerId) {
  final repository = ref.watch(partnerStoreRepositoryProvider);
  return repository.watchPartnerById(partnerId);
});

final partnerByStoreIdProvider = StreamProvider.family<PartnerStore?, String>((ref, storeId) {
  final repository = ref.watch(partnerStoreRepositoryProvider);
  return repository.watchPartnerByStoreId(storeId);
});
