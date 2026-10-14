import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../data/model/partner_dashboard_model.dart';
import '../providers/partner_dashboard_provider.dart';

Future<void> showReceiptReviewPop(BuildContext context, {required PartnerRecentTransactionModel transaction}) {
  return showDialog<void>(
    context: context,
    barrierDismissible: true,
    builder: (_) {
      return ReceiptReviewPop(transaction: transaction);
    },
  );
}

class ReceiptReviewPop extends ConsumerStatefulWidget {
  final PartnerRecentTransactionModel transaction;

  const ReceiptReviewPop({super.key, required this.transaction});

  @override
  ConsumerState<ReceiptReviewPop> createState() => _ReceiptReviewPopState();
}

class _ReceiptReviewPopState extends ConsumerState<ReceiptReviewPop> {
  bool _isApproving = false;
  bool _isRejecting = false;

  bool get _isLoading => _isApproving || _isRejecting;

  String _brl(num value) {
    return 'R\$ ${value.toStringAsFixed(2).replaceAll('.', ',')}';
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'approved':
        return 'Aprovado';
      case 'rejected':
        return 'Rejeitado';
      default:
        return 'Pendente';
    }
  }

  Color _statusBg(String status) {
    switch (status) {
      case 'approved':
        return const Color(0xFFE6F6EE);
      case 'rejected':
        return const Color(0xFFFDECEC);
      default:
        return const Color(0xFFFFF6DD);
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'approved':
        return const Color(0xFF1E9E5A);
      case 'rejected':
        return const Color(0xFFC0392B);
      default:
        return const Color(0xFFEF8F00);
    }
  }

  Future<void> _approve() async {
    if (_isLoading) return;

    setState(() {
      _isApproving = true;
    });

    try {
      await ref.read(partnerDashboardActionsProvider).approveRequest(widget.transaction.id);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Comprovante aprovado com sucesso.')));

      Navigator.of(context).pop();
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Não foi possível aprovar: $error')));
    } finally {
      if (mounted) {
        setState(() {
          _isApproving = false;
        });
      }
    }
  }

  Future<void> _reject() async {
    if (_isLoading) return;

    setState(() {
      _isRejecting = true;
    });

    try {
      await ref.read(partnerDashboardActionsProvider).rejectRequest(widget.transaction.id);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Comprovante rejeitado.')));

      Navigator.of(context).pop();
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Não foi possível rejeitar: $error')));
    } finally {
      if (mounted) {
        setState(() {
          _isRejecting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final transaction = widget.transaction;
    final isPending = transaction.status == 'pending';

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Container(
        width: 420,
        constraints: const BoxConstraints(maxHeight: 720),
        decoration: BoxDecoration(color: const Color(0xFFFFFFFF), borderRadius: BorderRadius.circular(18)),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.fromLTRB(18, 16, 12, 14),
                decoration: const BoxDecoration(
                  border: Border(bottom: BorderSide(color: Color(0xFFE6ECF3))),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Análise do Comprovante',
                        style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w800, color: const Color(0xFF0F172A)),
                      ),
                    ),
                    IconButton(
                      onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close_rounded, color: Color(0xFF64748B)),
                    ),
                  ],
                ),
              ),
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 22,
                            backgroundColor: const Color(0xFFE8EEF9),
                            child: Text(
                              transaction.initials,
                              style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700, color: const Color(0xFF0038BC)),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  transaction.customerName,
                                  style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w700, color: const Color(0xFF0F172A)),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  'Cliente',
                                  style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w400, color: const Color(0xFF94A3B8)),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(color: _statusBg(transaction.status), borderRadius: BorderRadius.circular(999)),
                            child: Text(
                              _statusLabel(transaction.status),
                              style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: _statusColor(transaction.status)),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      Row(
                        children: [
                          Expanded(
                            child: _InfoCard(label: 'Valor da nota', value: _brl(transaction.amount)),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _InfoCard(label: 'Cashback', value: _brl(transaction.cashback), valueColor: const Color(0xFF1E9E5A)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      Text(
                        'Comprovante enviado',
                        style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: const Color(0xFF0F172A)),
                      ),
                      const SizedBox(height: 10),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: AspectRatio(
                          aspectRatio: 4 / 5,
                          child: _ReceiptImage(imageUrl: transaction.receiptImageUrl),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(18, 12, 18, 16),
                decoration: const BoxDecoration(
                  color: Color(0xFFF8FAFC),
                  border: Border(top: BorderSide(color: Color(0xFFE6ECF3))),
                ),
                child: isPending
                    ? Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: _isLoading ? null : _reject,
                              style: OutlinedButton.styleFrom(
                                foregroundColor: const Color(0xFFC0392B),
                                side: const BorderSide(color: Color(0xFFC0392B)),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                minimumSize: const Size.fromHeight(44),
                              ),
                              child: Text(
                                _isRejecting ? 'Rejeitando...' : 'Rejeitar',
                                style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _approve,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF1E9E5A),
                                foregroundColor: const Color(0xFFFFFFFF),
                                elevation: 0,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                minimumSize: const Size.fromHeight(44),
                              ),
                              child: Text(
                                _isApproving ? 'Aprovando...' : 'Aprovar',
                                style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700),
                              ),
                            ),
                          ),
                        ],
                      )
                    : SizedBox(
                        width: double.infinity,
                        height: 44,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0038BC),
                            foregroundColor: const Color(0xFFFFFFFF),
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          child: Text('Fechar', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700)),
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String label;
  final String value;
  final Color valueColor;

  const _InfoCard({required this.label, required this.value, this.valueColor = const Color(0xFF0F172A)});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFAFAF8),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFEFEAE3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w500, color: const Color(0xFF94A3B8)),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w800, color: valueColor),
          ),
        ],
      ),
    );
  }
}

class _ReceiptImage extends StatelessWidget {
  final String imageUrl;

  const _ReceiptImage({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    final cleanUrl = imageUrl.trim();

    if (cleanUrl.isEmpty) {
      return const _ReceiptImageFallback();
    }

    return Image.network(
      cleanUrl,
      fit: BoxFit.cover,
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;

        return const _ReceiptImageFallback(child: SizedBox(width: 26, height: 26, child: CircularProgressIndicator(strokeWidth: 2)));
      },
      errorBuilder: (_, _, _) {
        return const _ReceiptImageFallback();
      },
    );
  }
}

class _ReceiptImageFallback extends StatelessWidget {
  final Widget? child;

  const _ReceiptImageFallback({this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFE6ECF3),
      alignment: Alignment.center,
      child: child ?? const Icon(Icons.receipt_long_outlined, color: Color(0xFF94A3B8), size: 42),
    );
  }
}
