enum LedgerStatus { pending, approved, rejected, cancelled }

extension LedgerStatusX on LedgerStatus {
  String get value {
    switch (this) {
      case LedgerStatus.pending:
        return 'pending';
      case LedgerStatus.approved:
        return 'approved';
      case LedgerStatus.rejected:
        return 'rejected';
      case LedgerStatus.cancelled:
        return 'cancelled';
    }
  }

  static LedgerStatus fromString(String value) {
    switch (value) {
      case 'approved':
        return LedgerStatus.approved;
      case 'rejected':
        return LedgerStatus.rejected;
      case 'cancelled':
        return LedgerStatus.cancelled;
      case 'pending':
      default:
        return LedgerStatus.pending;
    }
  }
}
