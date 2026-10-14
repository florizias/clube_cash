class Store {
  final String id;
  final String name;
  final String? logoUrl;
  final bool isActive;
  final int cashbackLabel;

  final String? rulesText;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Store({
    required this.id,
    required this.name,
    required this.isActive,
    required this.cashbackLabel,
    required this.createdAt,
    required this.updatedAt,
    this.logoUrl,
    this.rulesText,
  });

  bool get canReceivePurchases {
    return isActive && cashbackLabel >= 3 && cashbackLabel <= 10;
  }
}
