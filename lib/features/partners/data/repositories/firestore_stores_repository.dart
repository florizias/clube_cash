import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/store.dart' as store_entity;
import '../../domain/repositories/stores_repository.dart';
import '../dtos/store_dto.dart';
import '../mappers/store_mapper.dart';

class FirestoreStoresRepository implements StoresRepository {
  final FirebaseFirestore _db;

  FirestoreStoresRepository(this._db);

  CollectionReference<Map<String, dynamic>> get _col {
    return _db.collection('partners');
  }

  store_entity.Store _mapDoc(String id, Map<String, dynamic> data) {
    final normalizedData = {
      ...data,
      'isActive': data['status'] == 'active',
      'logoUrl': data['logoUrl']?.toString().isNotEmpty == true ? data['logoUrl'] : data['coverImageUrl'],
      'cashbackLabel': data['cashbackLabel'] ?? 0,
    };

    final dto = StoreDto.fromJson(normalizedData);

    return StoreMapper.toEntity(id, dto);
  }

  @override
  Stream<List<store_entity.Store>> watchActiveStores() {
    return _col.where('status', isEqualTo: 'active').orderBy('name').snapshots().map((snap) {
      return snap.docs.map((doc) {
        return _mapDoc(doc.id, doc.data());
      }).toList();
    });
  }

  @override
  Future<List<store_entity.Store>> listActiveStores() async {
    final snap = await _col.where('status', isEqualTo: 'active').orderBy('name').get();

    return snap.docs.map((doc) {
      return _mapDoc(doc.id, doc.data());
    }).toList();
  }

  @override
  Future<store_entity.Store?> getStoreById(String storeId) async {
    final doc = await _col.doc(storeId).get();

    if (!doc.exists) return null;

    final data = doc.data();

    if (data == null) return null;

    if (data['status'] != 'active') return null;

    return _mapDoc(doc.id, data);
  }
}
