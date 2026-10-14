import '../../../../../../core/constants/enums.dart';
import 'ledger_status.dart';

class LedgerEntry {
  final String id;
  final String userId;
  final String idempotencyKey;
  final String createdBy;

  final LedgerType type;
  final LedgerStatus status;

  final String source;
  final String sourceId;

  final String partnerId;
  final String partnerName;

  final int points;
  final double cashbackValue;
  final double purchaseValue;

  final String description;
  final DateTime createdAt;

  const LedgerEntry({
    required this.id,
    required this.userId,
    required this.idempotencyKey,
    required this.createdBy,
    required this.type,
    required this.status,
    required this.source,
    required this.sourceId,
    required this.partnerId,
    required this.partnerName,
    required this.points,
    required this.cashbackValue,
    required this.purchaseValue,
    required this.description,
    required this.createdAt,
  });

  bool get isCredit => type == LedgerType.credit;

  bool get isDebit => type == LedgerType.debit;

  bool get isApproved => status == LedgerStatus.approved;

  bool get isPending => status == LedgerStatus.pending;

  bool get isRejected => status == LedgerStatus.rejected;
}
