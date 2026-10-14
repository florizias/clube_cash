import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../services/firebase/firebase_providers.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../data/model/partner_product_model.dart';
import '../../data/repositories/firebase_partner_products_repository.dart';
import '../../data/repositories/partner_products_repository.dart';

final partnerProductsRepositoryProvider = Provider<PartnerProductsRepository>((ref) {
  final db = ref.watch(firebaseFirestoreProvider);

  return FirebasePartnerProductsRepository(db: db, storage: FirebaseStorage.instance);
});

final partnerProductsProvider = StreamProvider<List<PartnerProductModel>>((ref) {
  final userAsync = ref.watch(firebaseUserProvider);

  return userAsync.when(
    data: (user) {
      if (user == null) return Stream.value([]);

      final repository = ref.watch(partnerProductsRepositoryProvider);
      return repository.watchProductsByPartnerId(user.uid);
    },
    loading: () => Stream.value([]),
    error: (_, _) => Stream.value([]),
  );
});

final partnerProductByIdProvider = StreamProvider.family<PartnerProductModel?, String>((ref, productId) {
  final userAsync = ref.watch(firebaseUserProvider);

  return userAsync.when(
    data: (user) {
      if (user == null) return Stream.value(null);

      final repository = ref.watch(partnerProductsRepositoryProvider);

      return repository.watchProductById(partnerId: user.uid, productId: productId);
    },
    loading: () => Stream.value(null),
    error: (_, _) => Stream.value(null),
  );
});

final currentPartnerCashbackProvider = StreamProvider<double>((ref) {
  final userAsync = ref.watch(firebaseUserProvider);

  return userAsync.when(
    data: (user) {
      if (user == null) return Stream.value(0);

      final db = ref.watch(firebaseFirestoreProvider);

      return db.collection('partners').doc(user.uid).snapshots().map((doc) {
        final data = doc.data();
        return (data?['cashbackLabel'] as num?)?.toDouble() ?? 0;
      });
    },
    loading: () => Stream.value(0),
    error: (_, _) => Stream.value(0),
  );
});

final partnerProductsActionsProvider = Provider<PartnerProductsActions>((ref) {
  final repository = ref.watch(partnerProductsRepositoryProvider);

  return PartnerProductsActions(ref: ref, repository: repository);
});

class PartnerProductsActions {
  final Ref ref;
  final PartnerProductsRepository repository;

  PartnerProductsActions({required this.ref, required this.repository});

  Future<void> addCurrentPartnerProduct({
    required String name,
    required String description,
    required double price,
    required int stock,
    required String category,
    required bool isActive,
    required XFile image,
  }) async {
    final user = ref.read(firebaseUserProvider).when(data: (user) => user, loading: () => null, error: (_, _) => null);

    if (user == null) {
      throw Exception('Usuário não autenticado.');
    }

    await repository.addProduct(
      partnerId: user.uid,
      name: name,
      description: description,
      price: price,
      stock: stock,
      category: category,
      isActive: isActive,
      image: image,
    );
  }

  Future<void> deleteCurrentPartnerProduct({required String productId}) async {
    final user = ref.read(firebaseUserProvider).when(data: (user) => user, loading: () => null, error: (_, _) => null);

    if (user == null) {
      throw Exception('Usuário não autenticado.');
    }

    await repository.deleteProduct(partnerId: user.uid, productId: productId);
  }

  Future<void> updateCurrentPartnerProduct({
    required String productId,
    required String name,
    required String description,
    required double price,
    required int stock,
    required String category,
    required bool isActive,
    XFile? image,
  }) async {
    final user = ref.read(firebaseUserProvider).when(data: (user) => user, loading: () => null, error: (_, _) => null);

    if (user == null) {
      throw Exception('Usuário não autenticado.');
    }

    await repository.updateProduct(
      partnerId: user.uid,
      productId: productId,
      name: name,
      description: description,
      price: price,
      stock: stock,
      category: category,
      isActive: isActive,
      image: image,
    );
  }
}
