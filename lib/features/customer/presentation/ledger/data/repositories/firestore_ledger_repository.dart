import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/ledger_entry.dart';
import '../../domain/repositories/ledger_repository.dart';
import '../dtos/ledger_entry_dto.dart';
import '../mappers/ledger_entry_mapper.dart';

class FirestoreLedgerRepository implements LedgerRepository {
  final FirebaseFirestore _db;

  FirestoreLedgerRepository(this._db);

  CollectionReference<Map<String, dynamic>> get _col => _db.collection('transactions');

  Query<Map<String, dynamic>> _baseQuery(String userId) {
    return _col.where('userId', isEqualTo: userId).orderBy('createdAt', descending: true);
  }

  @override
  Stream<List<LedgerEntry>> watchUserLedger(String userId, {int limit = 50}) {
    return _baseQuery(userId)
        .limit(limit)
        .snapshots()
        .map(
          (snap) => snap.docs.map((doc) {
            final dto = LedgerEntryDto.fromJson(doc.data());
            return LedgerEntryMapper.toEntity(doc.id, dto);
          }).toList(),
        );
  }

  @override
  Future<List<LedgerEntry>> listUserLedger(String userId, {int limit = 50}) async {
    final snap = await _baseQuery(userId).limit(limit).get();
    return snap.docs.map((doc) {
      final dto = LedgerEntryDto.fromJson(doc.data());
      return LedgerEntryMapper.toEntity(doc.id, dto);
    }).toList();
  }
}
