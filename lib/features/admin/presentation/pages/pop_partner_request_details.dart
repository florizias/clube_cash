import 'dart:ui';

import 'package:clubcash/features/admin/presentation/widgets/section_title.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../auth/data/dtos/store_partnership_request_dto.dart';
import '../widgets/pop_partner_reject_reason.dart';
import '../widgets/read_only_field.dart';

class PartnerRequestDecision {
  final String status;
  final String rejectionReason;

  const PartnerRequestDecision({required this.status, this.rejectionReason = ''});

  bool get isApproved => status == 'approved';

  bool get isRejected => status == 'rejected';

  factory PartnerRequestDecision.approved() {
    return const PartnerRequestDecision(status: 'approved');
  }

  factory PartnerRequestDecision.rejected(String reason) {
    return PartnerRequestDecision(status: 'rejected', rejectionReason: reason);
  }
}

Future<PartnerRequestDecision?> showPartnerRequestDetailsPop(BuildContext context, StorePartnershipRequestDto request) {
  return showGeneralDialog<PartnerRequestDecision>(
    context: context,
    useRootNavigator: true,
    barrierDismissible: true,
    barrierLabel: 'request_request_details',
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
          _PartnerRequestDetailsDialog(request: request),
        ],
      );
    },
  );
}

class _PartnerRequestDetailsDialog extends StatelessWidget {
  final StorePartnershipRequestDto request;

  const _PartnerRequestDetailsDialog({required this.request});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: true,
      bottom: true,
      child: Center(
        child: Material(
          color: Colors.transparent,
          child: Container(
            width: 330,
            constraints: const BoxConstraints(maxHeight: 760),
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFFFFFFF),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.18), blurRadius: 28, offset: const Offset(0, 18))],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: const BoxDecoration(gradient: LinearGradient(colors: [Color(0xFF0038BC), Color(0xFF001E68)])),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          request.storeName,
                          style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFFFFFFFF)),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Data da solicitação: ${DateFormat('dd/MM/yyyy').format(request.createdAt.toDate())}',
                          style: GoogleFonts.inter(fontSize: 11, color: const Color(0xFFE6ECF3)),
                        ),
                      ],
                    ),
                  ),

                  Flexible(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          sectionTitle('Identificação do Negócio'),
                          const SizedBox(height: 14),
                          readonlyField('CNPJ', request.cnpj),
                          readonlyField('Categoria', request.category),
                          readonlyField('Faturamento Mensal', request.monthlyRevenue),
                          readonlyField('Data de abertura', request.openingDate),
                          readonlyField('Localização', request.address),

                          const SizedBox(height: 12),
                          sectionTitle('Responsável Legal'),
                          const SizedBox(height: 14),

                          readonlyField('Nome Completo', request.legalResponsible),
                          readonlyField('E-mail', request.commercialEmail),
                          readonlyField('WhatsApp', request.whatsapp),

                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(color: const Color(0xFFEAF1FF), borderRadius: BorderRadius.circular(12)),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Por que participar?',
                                  style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w800, color: const Color(0xFF0038BC)),
                                ),
                                const SizedBox(height: 10),
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFFFFFF),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: const Color(0xFF2563EB)),
                                  ),
                                  child: Text(
                                    request.whyParticipate.trim().isEmpty ? 'Não informado' : request.whyParticipate,
                                    style: GoogleFonts.inter(fontSize: 11, height: 1.35, color: const Color(0xFF0F172A)),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 14),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(colors: [Color(0xFF0038BC), Color(0xFF001952)]),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Proposta de Cashback',
                                  style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w800, color: Color(0xFFFFFFFF)),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  '${request.cashbackProposal}%',
                                  style: GoogleFonts.inter(fontSize: 36, fontWeight: FontWeight.w800, color: Color(0xFFFFFFFF)),
                                ),
                                Text(
                                  'Taxa mínima de retribuição ao usuário sugerida para adesão.',
                                  style: GoogleFonts.inter(fontSize: 10, color: const Color(0xFFE6ECF3)),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsetsGeometry.symmetric(horizontal: 16, vertical: 12),
                    child: Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 42,
                            child: ElevatedButton.icon(
                              onPressed: () {
                                Navigator.of(context).pop(PartnerRequestDecision.approved());
                              },
                              icon: const Icon(Icons.check, size: 16),
                              label: const Text('Aprovar'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF1E9E5A),
                                foregroundColor: Color(0xFFFFFFFF),
                                elevation: 0,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: SizedBox(
                            height: 42,
                            child: ElevatedButton.icon(
                              onPressed: () async {
                                final reason = await showPartnerRejectReasonPop(context);

                                if (reason == null || reason.trim().isEmpty) return;

                                if (!context.mounted) return;

                                Navigator.of(context).pop(PartnerRequestDecision.rejected(reason.trim()));
                              },
                              icon: const Icon(Icons.close, size: 16),
                              label: const Text('Recusar'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFC0392B),
                                foregroundColor: Color(0xFFFFFFFF),
                                elevation: 0,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                            ),
                          ),
                        ),
                      ],
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
