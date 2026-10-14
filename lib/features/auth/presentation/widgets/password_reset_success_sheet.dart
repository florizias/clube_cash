import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../app/theme/theme_exports.dart';

class PasswordResetSuccessSheet extends StatelessWidget {
  const PasswordResetSuccessSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.35),
      isDismissible: false,
      enableDrag: false,
      builder: (_) => const PasswordResetSuccessSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: true,
      bottom: true,
      child: Container(
        margin: const EdgeInsets.all(12),
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 16),
        decoration: BoxDecoration(color: Color(0xFFFFFFFF), borderRadius: BorderRadius.circular(24)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 4,
              width: 48,
              decoration: BoxDecoration(color: const Color(0xFFE2E8F0), borderRadius: BorderRadius.circular(99)),
            ),
            SizedBox(height: 18),
            SizedBox(height: 96, width: 96, child: Image.asset("assets/images/verify-email.png", fit: BoxFit.fill)),
            SizedBox(height: AppSpacing.lg),
            Text(
              'E-mail enviado!',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w800, color: const Color(0xFF0F172A)),
            ),
            SizedBox(height: AppSpacing.sm),
            Text(
              "Enviamos um link para redefinição de senha para o seu e-mail."
              "Acesse sua caixa de entrada e siga as instruções para criar uma nova senha.",
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w400, color: const Color(0xFF94A3B8), height: 1.3),
            ),
            SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              height: 44,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  context.go('/login');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  foregroundColor: Color(0xFFFFFFFF),
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  overlayColor: Colors.transparent,
                  splashFactory: NoSplash.splashFactory,
                ),
                child: Text('Retornar ao login', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
