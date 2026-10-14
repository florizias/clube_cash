import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../services/firebase/firebase_providers.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../data/model/partner_dashboard_model.dart';
import '../../data/repositories/firebase_partner_dashboard_repository.dart';

final partnerDashboardRepositoryProvider = Provider<FirebasePartnerDashboardRepository>((ref) {
  final db = ref.watch(firebaseFirestoreProvider);
  return FirebasePartnerDashboardRepository(db);
});

final partnerDashboardProvider = StreamProvider<PartnerDashboardModel>((ref) {
  final userAsync = ref.watch(firebaseUserProvider);

  return userAsync.when(
    data: (user) {
      if (user == null) {
        return Stream.value(PartnerDashboardModel.empty());
      }

      final repository = ref.watch(partnerDashboardRepositoryProvider);

      return repository.watchDashboard(user.uid);
    },
    loading: () => Stream.value(PartnerDashboardModel.empty()),
    error: (_, _) => Stream.value(PartnerDashboardModel.empty()),
  );
});

final partnerDashboardActionsProvider = Provider<PartnerDashboardActions>((ref) {
  final repository = ref.watch(partnerDashboardRepositoryProvider);

  return PartnerDashboardActions(repository);
});

class PartnerDashboardActions {
  final FirebasePartnerDashboardRepository _repository;

  PartnerDashboardActions(this._repository);

  Future<void> approveRequest(String requestId) {
    return _repository.approveRequest(requestId: requestId);
  }

  Future<void> rejectRequest(String requestId) {
    return _repository.rejectRequest(requestId: requestId);
  }
}
