import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../../services/firebase/firebase_providers.dart';
import '../../../../../auth/presentation/providers/auth_providers.dart';
import '../../data/dtos/customer_ledger_entry_dto.dart';
import '../../data/dtos/wallet_dto.dart';
import '../../data/repositories/firestore_wallet_repository.dart';

final customerWalletRepositoryProvider = Provider<FirestoreCustomerWalletRepository>((ref) {
  final db = ref.watch(firebaseFirestoreProvider);
  return FirestoreCustomerWalletRepository(db);
});

final currentCustomerWalletProvider = StreamProvider<CustomerWalletDto?>((ref) {
  final uid = ref.watch(currentUidProvider);

  if (uid == null) {
    return Stream.value(null);
  }

  final repository = ref.watch(customerWalletRepositoryProvider);
  return repository.watchWallet(uid);
});

final currentCustomerLedgerProvider = StreamProvider<List<CustomerLedgerEntryDto>>((ref) {
  final uid = ref.watch(currentUidProvider);

  if (uid == null) {
    return Stream.value([]);
  }

  final repository = ref.watch(customerWalletRepositoryProvider);
  return repository.watchLedger(uid);
});
