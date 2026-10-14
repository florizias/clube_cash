import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'confirm_row.dart';

Future<bool> showConfirmPurchasePop(
  BuildContext context, {
  required Uint8List? receiptImageBytes,
  required String partnerName,
  required String date,
  required String nfCode,
  required double purchaseValue,
  required double cashbackPercent,
}) async {
  final cashbackAmount = purchaseValue * (cashbackPercent / 100);

  final confirmed = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) {
      return AlertDialog(
        backgroundColor: const Color(0xFFFFFFFF),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Confirmar envio',
          style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w800, color: const Color(0xFF0F172A)),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (receiptImageBytes != null) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: SizedBox(
                    width: double.infinity,
                    height: 160,
                    child: Image.memory(
                      receiptImageBytes,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) {
                        return const ReceiptFallback();
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 14),
              ],
              ConfirmRow(label: 'Estabelecimento', value: partnerName),
              ConfirmRow(label: 'Data', value: date),
              ConfirmRow(label: 'Valor', value: 'R\$ ${purchaseValue.toStringAsFixed(2).replaceAll('.', ',')}'),
              ConfirmRow(label: 'Código da nota', value: nfCode),
              ConfirmRow(
                label: 'Cashback estimado',
                value: 'R\$ ${cashbackAmount.toStringAsFixed(2).replaceAll('.', ',')}',
                valueColor: const Color(0xFF16A34A),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop(false);
            },
            child: Text(
              'Editar',
              style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: const Color(0xFF64748B)),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(dialogContext).pop(true);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF8F00),
              foregroundColor: const Color(0xFFFFFFFF),
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: Text('Confirmar envio', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700)),
          ),
        ],
      );
    },
  );

  return confirmed == true;
}
