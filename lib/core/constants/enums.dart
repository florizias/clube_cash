enum LedgerType { credit, debit, adjustment }

extension LedgerTypeX on LedgerType {
  String get value {
    switch (this) {
      case LedgerType.credit:
        return 'credit';
      case LedgerType.debit:
        return 'debit';
      case LedgerType.adjustment:
        return 'adjustment';
    }
  }

  bool get isCredit => this == LedgerType.credit;

  static LedgerType fromString(String value) {
    switch (value) {
      case 'debit':
        return LedgerType.debit;
      case 'adjustment':
        return LedgerType.adjustment;
      case 'credit':
      default:
        return LedgerType.credit;
    }
  }
}
