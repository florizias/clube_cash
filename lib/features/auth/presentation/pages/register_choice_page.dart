import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../app/theme/theme_exports.dart';

class RegisterChoicePage extends StatelessWidget {
  const RegisterChoicePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      body: SafeArea(
        top: true,
        bottom: true,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 430),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 28, 20, 20),
              child: Column(
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: const BoxDecoration(color: Color(0xFFFFF4E5), shape: BoxShape.circle),
                    child: Center(
                      child: SvgPicture.asset(
                        'assets/icons/wallet.svg',
                        width: 34,
                        height: 34,
                        colorFilter: const ColorFilter.mode(Color(0xFFEF8F00), BlendMode.srcIn),
                      ),
                    ),
                  ),
                  const SizedBox(height: 22),
                  Text(
                    'Como você quer participar do ClubCash?',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.w800, color: const Color(0xFF0F172A), height: 1.15),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Você pode entrar para economizar nas compras ou solicitar que sua loja participe do app.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w400, color: const Color(0xFF9CA3AF), height: 1.4),
                  ),
                  SizedBox(height: AppSpacing.xl),
                  _ChoiceCard(
                    icon: 'assets/icons/person-name.svg',
                    title: 'Quero ganhar cashback',
                    description: 'Crie sua conta de consumidor, compre nas lojas parceiras e acompanhe seus pontos.',
                    badge: 'Consumidor',
                    color: const Color(0xFF0038BC),
                    background: const Color(0xFFEFF6FF),
                    onTap: () => context.go('/register'),
                  ),
                  const SizedBox(height: 14),
                  _ChoiceCard(
                    icon: 'assets/icons/store.svg',
                    title: 'Quero cadastrar minha loja',
                    description: 'Envie uma solicitação para o time ClubCash analisar sua loja e liberar sua participação.',
                    badge: 'Vendedor',
                    color: const Color(0xFFEF8F00),
                    background: const Color(0xFFFFF4E5),
                    onTap: () => context.go('/store-partnership-request'),
                  ),
                  const SizedBox(height: 28),
                  SizedBox(height: AppSpacing.md),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Já tem uma conta? ',
                        style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500, color: const Color(0xFF0F172A)),
                      ),
                      InkWell(
                        onTap: () => context.go('/login'),
                        borderRadius: BorderRadius.circular(8),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
                          child: Text(
                            'Entrar',
                            style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w800, color: const Color(0xFFEF8F00)),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Divider(),
                  TextButton(
                    style: ButtonStyle(overlayColor: WidgetStateProperty.all(Colors.transparent)),
                    onPressed: () => context.go('/home'),
                    child: Text(
                      "Voltar a página principal",
                      style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500, color: const Color(0xFF0F172A)),
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

class _ChoiceCard extends StatelessWidget {
  final String icon;
  final String title;
  final String description;
  final String badge;
  final Color color;
  final Color background;
  final VoidCallback onTap;

  const _ChoiceCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.badge,
    required this.color,
    required this.background,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      hoverColor: Colors.transparent,
      focusColor: Colors.transparent,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: const Color(0xFFFFFFFF),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFE6ECF3)),
          boxShadow: const [BoxShadow(color: Color(0x0F000000), blurRadius: 18, offset: Offset(0, 8))],
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(color: background, borderRadius: BorderRadius.circular(16)),
              child: Center(child: SvgPicture.asset(icon, width: 25, height: 25, colorFilter: ColorFilter.mode(color, BlendMode.srcIn))),
            ),

            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: background, borderRadius: BorderRadius.circular(100)),
                    child: Text(
                      badge,
                      style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w800, color: color),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    title,
                    style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w800, color: const Color(0xFF0F172A)),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w400, color: const Color(0xFF64748B), height: 1.35),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Icon(Icons.arrow_forward_ios_rounded, size: 16, color: color),
          ],
        ),
      ),
    );
  }
}
