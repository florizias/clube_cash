import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../services/firebase/firebase_providers.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../data/repositories/partner_reviews_repository.dart';
import '../../models/partner_model.dart';

final partnerReviewsRepositoryProvider = Provider<PartnerReviewsRepository>((ref) {
  final db = ref.watch(firebaseFirestoreProvider);
  return PartnerReviewsRepository(db);
});

final partnerReviewActionsProvider = Provider<PartnerReviewActions>((ref) {
  final repository = ref.watch(partnerReviewsRepositoryProvider);
  return PartnerReviewActions(ref, repository);
});

class PartnerReviewActions {
  final Ref _ref;
  final PartnerReviewsRepository _repository;

  PartnerReviewActions(this._ref, this._repository);

  Future<void> sendReview({required PartnerStore partner, required double rating, required String comment}) async {
    final user = _ref.read(firebaseUserProvider).value;
    final profile = _ref.read(currentUserProfileProvider).value;

    if (user == null) {
      throw Exception('Faça login para avaliar.');
    }

    if (partner.id.trim().isEmpty) {
      throw Exception('Loja inválida.');
    }

    await _repository.sendReview(
      partnerId: partner.id,
      userId: user.uid,
      userName: profile?.name ?? user.displayName ?? 'Cliente',
      rating: rating,
      comment: comment,
    );
  }
}
