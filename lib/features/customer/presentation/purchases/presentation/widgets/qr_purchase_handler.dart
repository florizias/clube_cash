import 'package:flutter/material.dart';

import '../../../../../../core/helper/nfe_qr_parser.dart';
import '../../../../../partners/models/partner_model.dart';
import 'show_confirm_purchase_pop.dart';

typedef SendQrPurchaseRequest = Future<void> Function({
required String nfCode,
required DateTime purchaseDate,
required double purchaseValue,
required String qrCodeRaw,
});

Future<void> handleQrCodeRead(
    BuildContext context, {
      required String rawCode,
      required PartnerStore partner,
      required bool isSubmitting,
      required SendQrPurchaseRequest onSendQrPurchase,
      VoidCallback? onReleaseScanner,
    }) async {
  if (isSubmitting) return;

  try {
    final data = NfeQrParser.parse(rawCode);

    final purchaseDate = data.date ?? DateTime.now();
    final purchaseValue = data.amount ?? 0;

    if (!context.mounted) return;

    if (purchaseValue <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'QR Code lido, mas não foi possível identificar o valor da compra.',
          ),
        ),
      );

      onReleaseScanner?.call();
      return;
    }

    final confirmed = await showConfirmPurchasePop(
      context,
      receiptImageBytes: null,
      partnerName: partner.name,
      date: _formatDate(purchaseDate),
      nfCode: data.nfCode,
      purchaseValue: purchaseValue,
      cashbackPercent: partner.cashbackLabel,
    );

    if (!context.mounted) return;

    if (!confirmed) {
      onReleaseScanner?.call();
      return;
    }

    await onSendQrPurchase(
      nfCode: data.nfCode,
      purchaseDate: purchaseDate,
      purchaseValue: purchaseValue,
      qrCodeRaw: data.raw,
    );
  } catch (error) {
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Não foi possível ler a nota fiscal: $error'),
      ),
    );

    onReleaseScanner?.call();
  }
}

String _formatDate(DateTime date) {
  final dd = date.day.toString().padLeft(2, '0');
  final mm = date.month.toString().padLeft(2, '0');
  final yyyy = date.year.toString();

  return '$dd/$mm/$yyyy';
}
