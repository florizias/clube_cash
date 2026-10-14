import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../services/firebase/firebase_providers.dart';
import '../../data/repositories/firestore_stores_repository.dart';
import '../../domain/entities/store.dart';
import '../../domain/repositories/stores_repository.dart';

final storesRepositoryProvider = Provider<StoresRepository>((ref) {
  final db = ref.watch(firebaseFirestoreProvider);
  return FirestoreStoresRepository(db);
});

final activeStoresProvider = StreamProvider<List<Store>>((ref) {
  final repository = ref.watch(storesRepositoryProvider);
  return repository.watchActiveStores();
});
