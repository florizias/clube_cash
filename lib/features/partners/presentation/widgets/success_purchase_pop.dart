import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../app/theme/theme_exports.dart';

Future<void> showPurchaseSuccessPop(BuildContext context) {
  return showGeneralDialog(
    context: context,
    useRootNavigator: true,
    barrierDismissible: true,
    barrierLabel: 'purchase_success',
    barrierColor: Colors.black.withValues(alpha: 0.35),
    transitionDuration: const Duration(milliseconds: 180),
    pageBuilder: (context, a1, a2) {
      return Stack(
        children: [
          Positioned.fill(
            child: ClipRect(
              child: BackdropFilter(filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10), child: SizedBox.expand()),
            ),
          ),
          Center(
            child: Material(
              color: Colors.transparent,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 360),
                child: Container(
                  padding: const EdgeInsets.fromLTRB(20, 22, 20, 18),
                  decoration: BoxDecoration(
                    color: Color(0xFFFFFFFF),
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.18), blurRadius: 28, offset: const Offset(0, 18))],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 72,
                        height: 72,
                        decoration: const BoxDecoration(
                          color: Color(0xFF22C55E), // verde
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.check_rounded, color: Color(0xFFFFFFFF), size: 42),
                      ),
                      SizedBox(height: 14),
                      Text(
                        'Sucesso',
                        style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w800, color: const Color(0xFF0F172A)),
                      ),
                      SizedBox(height: AppSpacing.sm),
                      Text(
                        'Tudo certo! Seu registro de compra entrou\nem fase de avaliação com sucesso.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(fontSize: 12.5, height: 1.35, fontWeight: FontWeight.w400, color: const Color(0xFF64748B)),
                      ),
                      SizedBox(height: AppSpacing.lg),
                      SizedBox(
                        width: double.infinity,
                        height: 44,
                        child: ElevatedButton(
                          onPressed: () => Navigator.of(context, rootNavigator: true).pop(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0038BC),
                            foregroundColor: Color(0xFFFFFFFF),
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: Text('Voltar a economizar', style: GoogleFonts.inter(fontSize: 13.5, fontWeight: FontWeight.w800)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
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
