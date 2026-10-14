import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

Widget cashbackBox({required double cashback, required VoidCallback onEdit}) {
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      gradient: const LinearGradient(colors: [Color(0xFF0038BC), Color(0xFF001952)]),
      borderRadius: BorderRadius.circular(10),
    ),
    child: Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Alíquota de Cashback (%)',
                style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w800, color: Color(0xFFFFFFFF)),
              ),
              const SizedBox(height: 4),
              Text(
                '${cashback.toStringAsFixed(0)}%',
                style: GoogleFonts.inter(fontSize: 32, fontWeight: FontWeight.w800, color: Color(0xFFFFFFFF), height: 1),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 34,
          child: ElevatedButton.icon(
            onPressed: onEdit,
            icon: const Icon(Icons.edit, size: 13),
            label: Text('Alterar', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700)),
            style: ButtonStyle(
              backgroundColor: WidgetStateProperty.all(const Color(0xFFEF8F00)),
              foregroundColor: WidgetStateProperty.all(Color(0xFFFFFFFF)),
              elevation: WidgetStateProperty.all(0),
              padding: WidgetStateProperty.all(const EdgeInsets.symmetric(horizontal: 12)),
              overlayColor: WidgetStateProperty.all(Colors.transparent),
              surfaceTintColor: WidgetStateProperty.all(Colors.transparent),
              shape: WidgetStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
            ),
          ),
        ),
      ],
    ),
  );
}
