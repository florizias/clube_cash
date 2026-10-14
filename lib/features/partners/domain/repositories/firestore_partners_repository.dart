import 'package:cloud_firestore/cloud_firestore.dart';

import '../../models/partner_model.dart';

class FirestorePartnersRepository {
  final FirebaseFirestore _db;

  FirestorePartnersRepository(this._db);

  CollectionReference<Map<String, dynamic>> get _collection {
    return _db.collection('partners');
  }

  Stream<List<PartnerStore>> watchActivePartners() {
    return _collection.where('status', isEqualTo: 'active').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return PartnerStore.fromJson(doc.id, doc.data());
      }).toList();
    });
  }
}
