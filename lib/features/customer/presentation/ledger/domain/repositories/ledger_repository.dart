import '../entities/ledger_entry.dart';

abstract class LedgerRepository {
  Stream<List<LedgerEntry>> watchUserLedger(String userId, {int limit = 50});
  Future<List<LedgerEntry>> listUserLedger(String userId, {int limit = 50});
}
