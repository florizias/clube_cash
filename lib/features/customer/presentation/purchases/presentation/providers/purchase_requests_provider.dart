import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../../../services/firebase/firebase_providers.dart';
import '../../../../../auth/presentation/providers/auth_providers.dart';
import '../../../../../partners/models/partner_model.dart';
import '../../data/dtos/purchase_dto.dart';
import '../../data/repositories/firestore_purchase_requests_repository.dart';

final purchaseRequestsRepositoryProvider = Provider<FirestorePurchaseRequestsRepository>((ref) {
  final db = ref.watch(firebaseFirestoreProvider);

  return FirestorePurchaseRequestsRepository(db: db, storage: FirebaseStorage.instance);
});

final purchaseRequestActionsProvider = Provider<PurchaseRequestActions>((ref) {
  final repository = ref.watch(purchaseRequestsRepositoryProvider);
  return PurchaseRequestActions(repository);
});

class PurchaseRequestActions {
  final FirestorePurchaseRequestsRepository _repository;

  PurchaseRequestActions(this._repository);

  Future<void> createPurchaseRequest({
    required String userId,
    required String userName,
    required String userEmail,
    required PartnerStore partner,
    required String nfCode,
    required DateTime purchaseDate,
    required double purchaseValue,
    XFile? receiptImage,
    String source = 'manual',
    String qrCodeRaw = '',
  }) {
    return _repository.createPurchaseRequest(
      userId: userId,
      userName: userName,
      userEmail: userEmail,
      partner: partner,
      nfCode: nfCode,
      purchaseDate: purchaseDate,
      purchaseValue: purchaseValue,
      receiptImage: receiptImage,
      source: source,
      qrCodeRaw: qrCodeRaw,
    );
  }

  Future<void> approveRequest(String requestId) {
    return _repository.approveRequest(requestId);
  }

  Future<void> rejectRequest({required String requestId, required String reason}) {
    return _repository.rejectRequest(requestId: requestId, reason: reason);
  }
}

final userPurchaseRequestsProvider = StreamProvider<List<PurchaseRequestDto>>((ref) {
  final uid = ref.watch(currentUidProvider);

  if (uid == null) {
    return Stream.value([]);
  }

  final repository = ref.watch(purchaseRequestsRepositoryProvider);
  return repository.watchUserRequests(uid);
});

final partnerPurchaseRequestsProvider = StreamProvider.family<List<PurchaseRequestDto>, String>((ref, partnerId) {
  final repository = ref.watch(purchaseRequestsRepositoryProvider);
  return repository.watchPartnerRequests(partnerId);
});

final partnerPendingPurchaseRequestsProvider = StreamProvider.family<List<PurchaseRequestDto>, String>((ref, partnerId) {
  final repository = ref.watch(purchaseRequestsRepositoryProvider);
  return repository.watchPartnerPendingRequests(partnerId);
});
