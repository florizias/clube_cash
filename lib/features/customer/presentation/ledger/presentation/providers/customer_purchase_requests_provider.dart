import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../../../services/firebase/firebase_providers.dart';
import '../../../../../auth/presentation/providers/auth_providers.dart';
import '../../../../data/models/customer_purchase_request_model.dart';
import '../../../../data/repositories/customer_purchase_requests_repository.dart';

final customerPurchaseRequestsRepositoryProvider = Provider<CustomerPurchaseRequestsRepository>((ref) {
  final db = ref.watch(firebaseFirestoreProvider);

  return CustomerPurchaseRequestsRepository(db: db, storage: FirebaseStorage.instance);
});

final currentCustomerPurchaseRequestsProvider = StreamProvider<List<CustomerPurchaseRequestModel>>((ref) {
  final userAsync = ref.watch(firebaseUserProvider);

  return userAsync.when(
    data: (user) {
      if (user == null) {
        return Stream.value([]);
      }

      final repository = ref.watch(customerPurchaseRequestsRepositoryProvider);

      return repository.watchCustomerRequests(user.uid);
    },
    loading: () => Stream.value([]),
    error: (_, _) => Stream.value([]),
  );
});

final customerPurchaseRequestsActionsProvider = Provider<CustomerPurchaseRequestsActions>((ref) {
  final repository = ref.watch(customerPurchaseRequestsRepositoryProvider);

  return CustomerPurchaseRequestsActions(ref: ref, repository: repository);
});

class CustomerPurchaseRequestsActions {
  final Ref ref;
  final CustomerPurchaseRequestsRepository repository;

  CustomerPurchaseRequestsActions({required this.ref, required this.repository});

  Future<void> submitReceipt({required String partnerId, required double amount, required XFile receiptImage}) async {
    final user = ref.read(firebaseUserProvider).when(data: (user) => user, loading: () => null, error: (_, _) => null);

    final profile = ref.read(currentUserProfileProvider).when(data: (profile) => profile, loading: () => null, error: (_, _) => null);

    if (user == null) {
      throw Exception('Usuário não autenticado.');
    }

    await repository.submitReceipt(
      partnerId: partnerId,
      customerId: user.uid,
      customerName: profile?.name ?? user.displayName ?? 'Cliente',
      amount: amount,
      receiptImage: receiptImage,
    );
  }
}
