import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AdDialogSavingOverlay extends StatelessWidget {
  final String message;

  const AdDialogSavingOverlay({super.key, this.message = 'Salvando banner...'});

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: AbsorbPointer(
        child: Container(
          color: Colors.black.withValues(alpha: 0.28),
          alignment: Alignment.center,
          child: Container(
            width: 250,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
            decoration: BoxDecoration(
              color: const Color(0xFFFFFFFF),
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [BoxShadow(color: Color(0x26000000), blurRadius: 24, offset: Offset(0, 12))],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(width: 34, height: 34, child: CircularProgressIndicator(strokeWidth: 3)),
                const SizedBox(height: 16),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: const Color(0xFF0F172A)),
                ),
                const SizedBox(height: 6),
                Text(
                  'Isso pode levar alguns segundos.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w400, color: const Color(0xFF64748B)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
