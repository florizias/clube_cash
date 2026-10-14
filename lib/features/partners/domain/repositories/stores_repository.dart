import 'package:cloud_firestore/cloud_firestore.dart';

import '../../models/partner_model.dart';
import '../entities/store.dart' as store_entity;

abstract class StoresRepository {
  Stream<List<store_entity.Store>> watchActiveStores();

  Future<List<store_entity.Store>> listActiveStores();

  Future<store_entity.Store?> getStoreById(String storeId);
}

class FirestorePartnerStoreRepository {
  final FirebaseFirestore _db;

  FirestorePartnerStoreRepository(this._db);

  CollectionReference<Map<String, dynamic>> get _collection {
    return _db.collection('partners');
  }

  Stream<List<PartnerStore>> watchActivePartners() {
    return _collection.where('role', isEqualTo: 'partner').where('status', isEqualTo: 'active').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return PartnerStore.fromJson(doc.id, doc.data());
      }).toList();
    });
  }

  Stream<List<PartnerStore>> watchAllPartnersForAdmin() {
    return _collection.where('role', isEqualTo: 'partner').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return PartnerStore.fromJson(doc.id, doc.data());
      }).toList();
    });
  }

  Stream<PartnerStore?> watchPartnerById(String partnerId) {
    return _collection.doc(partnerId).snapshots().map((doc) {
      if (!doc.exists) return null;

      final data = doc.data();
      if (data == null) return null;

      return PartnerStore.fromJson(doc.id, data);
    });
  }

  Stream<PartnerStore?> watchPartnerByStoreId(String storeId) {
    final cleanStoreId = storeId.trim().toLowerCase();

    if (cleanStoreId.isEmpty) {
      return Stream.value(null);
    }

    return _collection.where('storeId', isEqualTo: cleanStoreId).limit(1).snapshots().map((snapshot) {
      if (snapshot.docs.isEmpty) {
        return null;
      }

      final doc = snapshot.docs.first;
      return PartnerStore.fromJson(doc.id, doc.data());
    });
  }

  Future<PartnerStore?> getPartnerById(String partnerId) async {
    final doc = await _collection.doc(partnerId).get();

    if (!doc.exists) return null;

    final data = doc.data();
    if (data == null) return null;

    return PartnerStore.fromJson(doc.id, data);
  }

  Future<void> updatePartnerStatus({required String partnerId, required String status}) async {
    await _collection.doc(partnerId).update({'status': status, 'updatedAt': FieldValue.serverTimestamp()});
  }
}
