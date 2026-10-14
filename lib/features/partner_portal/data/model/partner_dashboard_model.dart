class PartnerDashboardModel {
  final double totalSales;
  final int activeClients;
  final double cashbackDistributed;
  final List<PartnerRecentTransactionModel> recentTransactions;

  const PartnerDashboardModel({
    required this.totalSales,
    required this.activeClients,
    required this.cashbackDistributed,
    required this.recentTransactions,
  });

  factory PartnerDashboardModel.empty() {
    return const PartnerDashboardModel(totalSales: 0, activeClients: 0, cashbackDistributed: 0, recentTransactions: []);
  }
}

class PartnerRecentTransactionModel {
  final String id;
  final String customerId;
  final String customerName;
  final String initials;
  final double amount;
  final double cashback;
  final String status;
  final String receiptImageUrl;
  final int minutesAgo;

  const PartnerRecentTransactionModel({
    required this.id,
    required this.customerId,
    required this.customerName,
    required this.initials,
    required this.amount,
    required this.cashback,
    required this.status,
    required this.receiptImageUrl,
    required this.minutesAgo,
  });
}
