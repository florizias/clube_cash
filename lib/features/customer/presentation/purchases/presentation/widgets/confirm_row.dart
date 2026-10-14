import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ConfirmRow extends StatelessWidget {
  final String label;
  final String value;
  final Color valueColor;

  const ConfirmRow({super.key, required this.label, required this.value, this.valueColor = const Color(0xFF0F172A)});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 118,
            child: Text(
              label,
              style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500, color: const Color(0xFF64748B)),
            ),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: valueColor),
            ),
          ),
        ],
      ),
    );
  }
}

class ReceiptFallback extends StatelessWidget {
  const ReceiptFallback({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFE6ECF3),
      alignment: Alignment.center,
      child: const Icon(Icons.receipt_long_outlined, color: Color(0xFF94A3B8), size: 42),
    );
  }
}
