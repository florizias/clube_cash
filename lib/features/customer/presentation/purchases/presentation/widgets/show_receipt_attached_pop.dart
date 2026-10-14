import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'confirm_row.dart';

Future<void> showReceiptAttachedPop(BuildContext context, {required Uint8List receiptImageBytes, required VoidCallback onCheckData}) async {
  await showDialog<void>(
    context: context,
    barrierDismissible: true,
    builder: (dialogContext) {
      return AlertDialog(
        backgroundColor: const Color(0xFFFFFFFF),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Comprovante anexado',
          style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w800, color: const Color(0xFF0F172A)),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                width: double.infinity,
                height: 180,
                child: Image.memory(
                  receiptImageBytes,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) {
                    return const ReceiptFallback();
                  },
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Agora confira os dados da compra antes de enviar para análise.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w400, color: const Color(0xFF64748B)),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
            },
            child: Text(
              'Trocar depois',
              style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: const Color(0xFF64748B)),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              onCheckData();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF8F00),
              foregroundColor: const Color(0xFFFFFFFF),
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: Text('Conferir dados', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700)),
          ),
        ],
      );
    },
  );
}
