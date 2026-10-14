import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../services/firebase/firebase_providers.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../data/repositories/account_deactivation_repository.dart';

final accountDeactivationRepositoryProvider = Provider<AccountDeactivationRepository>((ref) {
  final db = ref.watch(firebaseFirestoreProvider);
  return AccountDeactivationRepository(db);
});

final accountDeactivationActionsProvider = Provider<AccountDeactivationActions>((ref) {
  final repository = ref.watch(accountDeactivationRepositoryProvider);
  return AccountDeactivationActions(ref, repository);
});

class AccountDeactivationActions {
  final Ref _ref;
  final AccountDeactivationRepository _repository;

  AccountDeactivationActions(this._ref, this._repository);

  Future<void> deactivateCurrentAccount() async {
    final user = _ref.read(firebaseUserProvider).value;

    if (user == null) {
      throw Exception('Usuário não autenticado.');
    }

    final userRepo = _ref.read(userRepositoryProvider);
    final profile = await userRepo.getProfile(user.uid);

    if (profile == null) {
      throw Exception('Perfil do usuário não encontrado.');
    }

    await _repository.deactivateAccount(uid: user.uid, role: profile.role);

    await _ref.read(authControllerProvider.notifier).signOut();
  }
}
