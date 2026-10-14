import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../partners/models/partner_model.dart';

class AdminPartnersRepository {
  final FirebaseFirestore _db;

  AdminPartnersRepository(this._db);

  CollectionReference<Map<String, dynamic>> get _collection {
    return _db.collection('partners');
  }

  Stream<List<PartnerStore>> watchPartners() {
    return _collection.snapshots().map((snapshot) {
      final partners = snapshot.docs.map((doc) {
        return PartnerStore.fromJson(doc.id, doc.data());
      }).toList();

      partners.sort((a, b) {
        return a.name.toLowerCase().compareTo(b.name.toLowerCase());
      });

      return partners;
    });
  }
}
