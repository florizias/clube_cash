import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TransactionStatusStyle {
  final String label;
  final Color bgColor;
  final Color textColor;
  final Color dotColor;

  const TransactionStatusStyle({required this.label, required this.bgColor, required this.textColor, required this.dotColor});
}

class TransactionStatusChip extends StatelessWidget {
  final TransactionStatusStyle style;

  const TransactionStatusChip({super.key, required this.style});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(color: style.bgColor, borderRadius: BorderRadius.circular(999)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: style.dotColor, shape: BoxShape.circle),
          ),
          const SizedBox(width: 5),
          Text(
            style.label,
            style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w700, color: style.textColor),
          ),
        ],
      ),
    );
  }
}
