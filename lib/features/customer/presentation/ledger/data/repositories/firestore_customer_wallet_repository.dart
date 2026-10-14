import 'package:cloud_firestore/cloud_firestore.dart';

import '../dtos/customer_ledger_entry_dto.dart';
import '../dtos/customer_wallet_dto.dart';

class FirestoreCustomerWalletRepository {
  final FirebaseFirestore _db;

  FirestoreCustomerWalletRepository(this._db);

  DocumentReference<Map<String, dynamic>> _walletDoc(String userId) {
    return _db.collection('customer_wallets').doc(userId);
  }

  CollectionReference<Map<String, dynamic>> _ledger(String userId) {
    return _walletDoc(userId).collection('transactions');
  }

  Stream<CustomerWalletDto?> watchWallet(String userId) {
    return _walletDoc(userId).snapshots().map((doc) {
      if (!doc.exists) return null;
      return CustomerWalletDto.fromFirestore(doc);
    });
  }

  Stream<List<CustomerLedgerEntryDto>> watchLedger(String userId) {
    return _ledger(userId).orderBy('createdAt', descending: true).limit(50).snapshots().map((snapshot) {
      return snapshot.docs.map(CustomerLedgerEntryDto.fromFirestore).toList();
    });
  }

  Future<void> ensureWalletExists(String userId) async {
    final doc = await _walletDoc(userId).get();

    if (doc.exists) return;

    await _walletDoc(userId).set({
      'userId': userId,
      'availablePoints': 0,
      'pendingPoints': 0,
      'rejectedPoints': 0,
      'lifetimePoints': 0,
      'availableCashbackValue': 0,
      'pendingCashbackValue': 0,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}
