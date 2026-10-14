import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../../../app/theme/app_spacing.dart';
import '../../domain/entities/wallet.dart';
import 'wallet_status_style.dart';

Future<void> showCustomerPurchaseDetailsPop(BuildContext context, {required WalletEntry entry}) {
  return showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'customer_purchase_details',
    barrierColor: Colors.black.withValues(alpha: 0.35),
    transitionDuration: const Duration(milliseconds: 180),
    pageBuilder: (context, animation, secondaryAnimation) {
      return Stack(
        children: [
          Positioned.fill(
            child: ClipRect(
              child: BackdropFilter(filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8), child: const SizedBox.expand()),
            ),
          ),
          _CustomerPurchaseDetailsDialog(entry: entry),
        ],
      );
    },
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      final curved = CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);

      return FadeTransition(
        opacity: curved,
        child: ScaleTransition(scale: Tween<double>(begin: 0.98, end: 1).animate(curved), child: child),
      );
    },
  );
}

class _CustomerPurchaseDetailsDialog extends StatelessWidget {
  final WalletEntry entry;

  const _CustomerPurchaseDetailsDialog({required this.entry});

  String _formatMoney(double value) {
    return 'R\$ ${value.toStringAsFixed(2).replaceAll('.', ',')}';
  }

  @override
  Widget build(BuildContext context) {
    final statusStyle = walletStatusStyle(entry.status);

    return SafeArea(
      top: true,
      bottom: true,
      child: Center(
        child: Material(
          color: Colors.transparent,
          child: Container(
            width: 360,
            constraints: const BoxConstraints(maxHeight: 620),
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: const Color(0xFFFFFFFF),
              borderRadius: BorderRadius.circular(18),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.18), blurRadius: 28, offset: const Offset(0, 18))],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 8, 10),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Detalhes da compra',
                            style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w800, color: const Color(0xFF0F172A)),
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const Icon(Icons.close_rounded, size: 20, color: Color(0xFF94A3B8)),
                        ),
                      ],
                    ),
                  ),

                  Flexible(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(color: statusStyle.bgColor, borderRadius: BorderRadius.circular(12)),
                            child: Row(
                              children: [
                                Container(
                                  width: 9,
                                  height: 9,
                                  decoration: BoxDecoration(color: statusStyle.textColor, shape: BoxShape.circle),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  statusStyle.label,
                                  style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w800, color: statusStyle.textColor),
                                ),
                              ],
                            ),
                          ),

                          SizedBox(height: AppSpacing.md),

                          _InfoRow(label: 'Estabelecimento', value: entry.partnerName.isNotEmpty ? entry.partnerName : entry.title),
                          _InfoRow(label: 'Data do envio', value: entry.date),
                          _InfoRow(label: 'Valor da compra', value: _formatMoney(entry.purchaseValue)),
                          _InfoRow(label: 'Cashback', value: _formatMoney(entry.cashbackValue)),
                          _InfoRow(label: 'Código da nota', value: entry.nfCode.isNotEmpty ? entry.nfCode : 'Não informado'),

                          if (entry.status == 'rejected' && entry.rejectionReason
                              .trim()
                              .isNotEmpty) ...[
                            SizedBox(height: AppSpacing.sm),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFEE2E2),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: const Color(0xFFDC2626)),
                              ),
                              child: Text(
                                'Motivo da reprovação: ${entry.rejectionReason}',
                                style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: const Color(0xFF991B1B), height: 1.35),
                              ),
                            ),
                          ],

                          SizedBox(height: AppSpacing.md),

                          Text(
                            'Comprovante enviado',
                            style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700, color: const Color(0xFF475569)),
                          ),

                          SizedBox(height: AppSpacing.xs),

                          if (entry.receiptImageUrl
                              .trim()
                              .isNotEmpty)
                            ClipRRect(
                              borderRadius: BorderRadius.circular(14),
                              child: Image.network(
                                entry.receiptImageUrl.trim(),
                                width: double.infinity,
                                height: 260,
                                fit: BoxFit.cover,
                                errorBuilder: (_, _, _) {
                                  return const _ReceiptFallback(text: 'Não foi possível carregar o comprovante.');
                                },
                              ),
                            )
                          else
                            const _ReceiptFallback(text: 'Esta compra foi enviada por QR Code ou não possui imagem anexada.'),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: const Color(0xFF94A3B8)),
            ),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: const Color(0xFF0F172A)),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReceiptFallback extends StatelessWidget {
  final String text;

  const _ReceiptFallback({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 180,
      alignment: Alignment.center,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500, color: const Color(0xFF64748B), height: 1.35),
      ),
    );
  }
}
