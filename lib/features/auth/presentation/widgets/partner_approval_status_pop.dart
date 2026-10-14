import 'dart:ui';

import 'package:clubcash/app/variables.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/partner_rewiew.dart';

Future<PartnerApprovalAction?> showPartnerApprovalStatusPop(
  BuildContext context, {
  required String status,
  required String rejectionReason,
  required String storeName,
  required String userEmail,
}) {
  return showGeneralDialog<PartnerApprovalAction>(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'partner_approval_status',
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
          _PartnerApprovalStatusDialog(status: status, rejectionReason: rejectionReason, storeName: storeName, userEmail: userEmail),
        ],
      );
    },
  );
}

class _PartnerApprovalStatusDialog extends StatelessWidget {
  final String status;
  final String rejectionReason;
  final String storeName;
  final String userEmail;

  const _PartnerApprovalStatusDialog({required this.status, required this.rejectionReason, required this.storeName, required this.userEmail});

  bool get isRejected => status == 'rejected';

  String get title {
    if (isRejected) return 'Cadastro recusado';
    return 'Cadastro em análise';
  }

  String get message {
    if (isRejected) {
      return 'Seu cadastro de parceiro foi analisado, mas precisa de ajustes antes de ser aprovado.';
    }

    return 'Seu cadastro de parceiro ainda está em análise pela administração. Assim que for aprovado, você poderá acessar o painel da loja.';
  }

  Color get mainColor {
    if (isRejected) return const Color(0xFFDC2626);
    return const Color(0xFFCA8A04);
  }

  Color get bgColor {
    if (isRejected) return const Color(0xFFFEE2E2);
    return const Color(0xFFFFF6DD);
  }

  Future<void> _openWhatsApp(BuildContext context) async {
    final text = Uri.encodeComponent(
      'Olá, equipe ClubCash. Gostaria de contestar a análise do meu cadastro de parceiro.\n\n'
      'Loja: ${storeName.isEmpty ? 'Não informado' : storeName}\n'
      'E-mail: $userEmail\n'
      'Status: $status\n'
      'Motivo informado: ${rejectionReason.isEmpty ? 'Não informado' : rejectionReason}',
    );

    final uri = Uri.parse('https://wa.me/${Variables.supportPhone}?text=$text');

    final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);

    if (!opened && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Não foi possível abrir o WhatsApp.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: true,
      bottom: true,
      child: Center(
        child: Material(
          color: Colors.transparent,
          child: Container(
            width: 360,
            margin: const EdgeInsets.symmetric(horizontal: 18),
            decoration: BoxDecoration(
              color: const Color(0xFFFFFFFF),
              borderRadius: BorderRadius.circular(18),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.18), blurRadius: 28, offset: const Offset(0, 18))],
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 58,
                    height: 58,
                    decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
                    child: Icon(isRejected ? Icons.cancel_rounded : Icons.hourglass_top_rounded, color: mainColor, size: 30),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w800, color: const Color(0xFF0F172A)),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    message,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500, color: const Color(0xFF64748B), height: 1.4),
                  ),
                  if (storeName.trim().isNotEmpty) ...[const SizedBox(height: 14), _InfoBox(label: 'Loja', value: storeName)],
                  if (isRejected) ...[
                    const SizedBox(height: 10),
                    _InfoBox(
                      label: 'Motivo da recusa',
                      value: rejectionReason.trim().isEmpty ? 'O administrador não informou um motivo.' : rejectionReason.trim(),
                      danger: true,
                    ),
                  ],
                  const SizedBox(height: 18),
                  if (isRejected)
                    SizedBox(
                      width: double.infinity,
                      height: 44,
                      child: ElevatedButton(
                        onPressed: () async {
                          await _openWhatsApp(context);

                          if (context.mounted) {
                            Navigator.of(context).pop(PartnerApprovalAction.whatsapp);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF16A34A),
                          foregroundColor: const Color(0xFFFFFFFF),
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: Text('Contestar pelo WhatsApp', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w800)),
                      ),
                    ),
                  if (isRejected) const SizedBox(height: 10),
                  if (isRejected) ...[
                    SizedBox(
                      width: double.infinity,
                      height: 44,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop(PartnerApprovalAction.edit);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0038BC),
                          foregroundColor: const Color(0xFFFFFFFF),
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: Text('Corrigir cadastro', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w800)),
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                  SizedBox(
                    width: double.infinity,
                    height: 44,
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.of(context).pop(PartnerApprovalAction.close);
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF0F172A),
                        side: const BorderSide(color: Color(0xFFE2E8F0)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: Text('Entendi', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w800)),
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

class _InfoBox extends StatelessWidget {
  final String label;
  final String value;
  final bool danger;

  const _InfoBox({required this.label, required this.value, this.danger = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: danger ? const Color(0xFFFEE2E2) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: danger ? const Color(0xFFDC2626) : const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: danger ? const Color(0xFF991B1B) : const Color(0xFF64748B)),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: danger ? const Color(0xFF991B1B) : const Color(0xFF0F172A),
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}
