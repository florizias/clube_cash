import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../services/firebase/firebase_providers.dart';
import '../../../auth/data/dtos/store_partnership_request_dto.dart';
import '../../domain/repositories/admin_store_requests_repository.dart';

final adminStoreRequestsRepositoryProvider = Provider<AdminStoreRequestsRepository>((ref) {
  final db = ref.watch(firebaseFirestoreProvider);
  return AdminStoreRequestsRepository(db);
});

final pendingStoreRequestsProvider = StreamProvider<List<StorePartnershipRequestDto>>((ref) {
  final repository = ref.watch(adminStoreRequestsRepositoryProvider);
  return repository.watchPendingRequests();
});

final adminStoreRequestActionsProvider = Provider<AdminStoreRequestActions>((ref) {
  final repository = ref.watch(adminStoreRequestsRepositoryProvider);
  return AdminStoreRequestActions(repository);
});

class AdminStoreRequestActions {
  final AdminStoreRequestsRepository _repository;

  AdminStoreRequestActions(this._repository);

  Future<void> approveRequest(StorePartnershipRequestDto request) {
    return _repository.approveRequest(request);
  }

  Future<void> rejectRequest({required String uid, required String reason}) {
    return _repository.rejectRequest(uid: uid, reason: reason);
  }
}
