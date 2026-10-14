import 'package:flutter/material.dart';

class WalletStatusStyle {
  final String label;
  final Color bgColor;
  final Color textColor;

  const WalletStatusStyle({required this.label, required this.bgColor, required this.textColor});
}

WalletStatusStyle walletStatusStyle(String status) {
  switch (status) {
    case 'approved':
      return const WalletStatusStyle(label: 'Confirmado', bgColor: Color(0xFFE6F6EE), textColor: Color(0xFF16A34A));

    case 'rejected':
      return const WalletStatusStyle(label: 'Reprovado', bgColor: Color(0xFFFEE2E2), textColor: Color(0xFFDC2626));

    case 'pending':
    default:
      return const WalletStatusStyle(label: 'Em análise', bgColor: Color(0xFFFFF6DD), textColor: Color(0xFFCA8A04));
  }
}
