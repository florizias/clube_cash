import 'package:cloud_firestore/cloud_firestore.dart';

class AccountDeactivationRepository {
  final FirebaseFirestore _db;

  AccountDeactivationRepository(this._db);

  Future<void> deactivateAccount({
    required String uid,
    required String role,
  }) async {
    final batch = _db.batch();

    final userRef = _db.collection('users').doc(uid);

    batch.set(
      userRef,
      {
        'status': 'deactivated',
        'deactivatedAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );

    if (role == 'customer') {
      final walletRef = _db.collection('customer_wallets').doc(uid);

      batch.set(
        walletRef,
        {
          'status': 'deactivated',
          'deactivatedAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );
    }

    if (role == 'partner') {
      final partnerRef = _db.collection('partners').doc(uid);

      batch.set(
        partnerRef,
        {
          'status': 'inactive',
          'deactivatedAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );
    }

    await batch.commit();
  }
}
