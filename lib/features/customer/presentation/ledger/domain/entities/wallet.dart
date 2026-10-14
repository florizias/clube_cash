class Wallet {
  final String userId; // doc id
  final int availablePoints;
  final int pendingPoints;
  final int version;
  final DateTime updatedAt;

  const Wallet({required this.userId, required this.availablePoints, required this.pendingPoints, required this.version, required this.updatedAt});
}

class WalletEntry {
  final String id;
  final String title;
  final String date;
  final double amount;
  final bool isCredit;
  final bool highlighted;
  final String status;

  final String partnerName;
  final String nfCode;
  final String receiptImageUrl;
  final String rejectionReason;
  final double purchaseValue;
  final double cashbackValue;

  const WalletEntry({
    required this.id,
    required this.title,
    required this.date,
    required this.amount,
    required this.isCredit,
    required this.highlighted,
    this.status = 'approved',
    this.partnerName = '',
    this.nfCode = '',
    this.receiptImageUrl = '',
    this.rejectionReason = '',
    this.purchaseValue = 0,
    this.cashbackValue = 0,
  });
}
