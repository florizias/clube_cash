import 'package:cloud_firestore/cloud_firestore.dart';

import '../dtos/store_partnership_request_dto.dart';

class FirestoreStoreRequestRepository {
  final FirebaseFirestore _db;

  FirestoreStoreRequestRepository(this._db);

  DocumentReference<Map<String, dynamic>> _doc(String uid) {
    return _db.collection('store_requests').doc(uid);
  }

  Future<void> createRequest(StorePartnershipRequestDto request) async {
    await _doc(request.uid).set(request.toJson(), SetOptions(merge: true));
  }

  Future<void> updateStatus({required String uid, required String status}) async {
    await _doc(uid).update({'status': status, 'updatedAt': FieldValue.serverTimestamp()});
  }
}
