import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../partners/models/partner_model.dart';
import '../../../share/widgets_exports.dart';
import '../widgets/box_cashback.dart';
import '../widgets/edit_cashback.dart';
import '../widgets/read_only_field.dart';
import '../widgets/section_title.dart';

Future<void> showPartnerDetailsPop(BuildContext context, PartnerStore partner) {
  return showGeneralDialog(
    context: context,
    useRootNavigator: true,
    barrierDismissible: true,
    barrierLabel: 'partner_details',
    barrierColor: Colors.black.withValues(alpha: 0.35),
    transitionDuration: const Duration(milliseconds: 180),
    pageBuilder: (context, anim1, anim2) {
      return Stack(
        children: [
          Positioned.fill(
            child: ClipRect(
              child: BackdropFilter(filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10), child: const SizedBox.expand()),
            ),
          ),
          _PartnerDetailsDialog(partner: partner),
        ],
      );
    },
  );
}

class _PartnerDetailsDialog extends StatefulWidget {
  final PartnerStore partner;

  const _PartnerDetailsDialog({required this.partner});

  @override
  State<_PartnerDetailsDialog> createState() => _PartnerDetailsDialogState();
}

class _PartnerDetailsDialogState extends State<_PartnerDetailsDialog> {
  String _formatDate(DateTime? date) {
    if (date == null) return 'Não informado';
    return DateFormat('dd/MM/yyyy').format(date);
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'active':
        return 'Ativo';
      case 'inactive':
        return 'Inativo';
      case 'rejected':
        return 'Rejeitado';
      default:
        return status;
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'active':
        return const Color(0xFF1E9E5A);
      case 'inactive':
        return const Color(0xFFC0392B);
      case 'pending_approval':
        return const Color(0xFFEF8F00);
      default:
        return const Color(0xFF64748B);
    }
  }

  @override
  Widget build(BuildContext context) {
    final app = widget.partner.application;

    return SafeArea(
      top: true,
      bottom: true,
      child: Center(
        child: Material(
          color: Colors.transparent,
          child: Container(
            width: 340,
            constraints: const BoxConstraints(maxHeight: 760),
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFFFFFFF),
              borderRadius: BorderRadius.circular(14),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.18), blurRadius: 28, offset: const Offset(0, 18))],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Stack(
                    children: [
                      Image.network(
                        widget.partner.coverImageUrl,
                        height: 135,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) {
                          return Container(height: 135, color: const Color(0xFFE6ECF3));
                        },
                      ),
                      Positioned.fill(child: Container(color: Colors.black.withValues(alpha: 0.28))),
                      Positioned(
                        left: 14,
                        right: 14,
                        bottom: 14,
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.network(
                                widget.partner.logoUrl.isNotEmpty ? widget.partner.logoUrl : widget.partner.coverImageUrl,
                                width: 58,
                                height: 58,
                                fit: BoxFit.cover,
                                errorBuilder: (_, _, _) {
                                  return Container(width: 58, height: 58, color: const Color(0xFFE6ECF3), child: const Icon(Icons.store));
                                },
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.partner.name,
                                    style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFFFFFFFF)),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          'ID.: ${widget.partner.storeId}',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          softWrap: false,
                                          style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w400, color: const Color(0xFFFFFFFF)),
                                        ),
                                      ),
                                      SizedBox(width: 20),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: _statusColor(widget.partner.status),
                                          borderRadius: BorderRadius.circular(100),
                                        ),
                                        child: Text(
                                          _statusLabel(widget.partner.status),
                                          style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFFFFFFFF)),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Positioned(
                        top: 10,
                        right: 10,
                        child: InkWell(
                          onTap: () => Navigator.of(context).pop(),
                          child: const Icon(Icons.close, color: Color(0xFFFFFFFF), size: 20),
                        ),
                      ),
                    ],
                  ),

                  Flexible(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          cashbackBox(
                            cashback: widget.partner.cashbackLabel,
                            onEdit: () async {
                              final newCashback = await showEditCashbackPop(context, widget.partner.cashbackLabel);
                              if (newCashback == null) return;
                              setState(() {
                                widget.partner.cashbackLabel = newCashback;
                              });
                            },
                          ),
                          SizedBox(height: 16),
                          sectionTitle('Dados da Loja'),
                          readonlyField('CNPJ', widget.partner.cnpj),
                          readonlyField('Categoria', '${widget.partner.category} • ${widget.partner.subCategory}'),
                          readonlyField('Endereço', widget.partner.address),
                          readonlyField('Telefone', widget.partner.phone),
                          readonlyField('WhatsApp', widget.partner.whatsapp),
                          readonlyField('Site', widget.partner.website.isEmpty ? 'Não informado' : widget.partner.website),
                          sectionTitle('Redes Sociais'),
                          readonlyField('Instagram', widget.partner.instagram),
                          readonlyField('Facebook', widget.partner.facebook),
                          readonlyField('TikTok', widget.partner.tiktok),

                          sectionTitle('Dados da Solicitação'),
                          readonlyField('Data da Solicitação', _formatDate(app?.dateSolicitation)),
                          readonlyField('Data de Aprovação', _formatDate(app?.approvedAt)),
                          readonlyField('Faturamento Mensal', app?.monthlyRevenue ?? 'Não informado'),
                          readonlyField('Tempo de Mercado', getMarketTime(app?.openedAt)),

                          sectionTitle('Responsável Legal'),
                          readonlyField('Nome', app?.legalResponsibleName ?? 'Não informado'),
                          readonlyField('E-mail', widget.partner.email),
                          readonlyField('WhatsApp', widget.partner.whatsapp),

                          sectionTitle('Por que participou?'),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFAFAF8),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: const Color(0xFFE6ECF3)),
                            ),
                            child: Text(
                              app?.whyJoin ?? 'Não informado',
                              style: GoogleFonts.inter(fontSize: 12, height: 1.35, color: const Color(0xFF64748B)),
                            ),
                          ),

                          const SizedBox(height: 16),

                          SizedBox(
                            width: double.infinity,
                            height: 42,
                            child: ElevatedButton(
                              onPressed: () => Navigator.of(context).pop(),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF0038BC),
                                foregroundColor: Color(0xFFFFFFFF),
                                elevation: 0,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              child: Text('Fechar', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700)),
                            ),
                          ),
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
