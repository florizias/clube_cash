class RecentTransactionModel {
  final String id;
  final String customerName;
  final double amount;
  final double cashback;
  final int minutesAgo;
  final String initials;

  const RecentTransactionModel({
    required this.id,
    required this.customerName,
    required this.amount,
    required this.cashback,
    required this.minutesAgo,
    required this.initials,
  });

  factory RecentTransactionModel.fromJson(Map<String, dynamic> json) {
    return RecentTransactionModel(
      id: json['id'] as String,
      customerName: json['customerName'] as String,
      amount: (json['amount'] as num).toDouble(),
      cashback: (json['cashback'] as num).toDouble(),
      minutesAgo: json['minutesAgo'] as int,
      initials: json['initials'] as String,
    );
  }
}
