import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../share/widgets_exports.dart';

class PartnerAboutAppPage extends ConsumerWidget {
  const PartnerAboutAppPage({super.key});

  Widget _featureCard({required String svgAsset, required Color iconBg, required Color iconColor, required String title, required String subtitle}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 62,
            height: 62,
            decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(10)),
            child: Center(child: SvgPicture.asset(svgAsset, width: 24, height: 24, colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn))),
          ),
          SizedBox(width: 10),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w700, color: const Color(0xFF0F172A)),
                  ),
                  SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w400, color: const Color(0xFF9CA3AF), height: 1.35),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(currentUserProfileProvider);
    final greeting = getGreeting();

    final headerName = profileAsync.when(
      data: (profile) {
        final name = profile?.name.trim() ?? '';
        if (name.isEmpty) return 'Usuário';
        return name.split(RegExp(r'\s+')).first;
      },
      loading: () => 'Carregando...',
      error: (_, _) => 'Usuário',
    );

    final photoUrl = profileAsync.when(data: (profile) => profile?.photoUrl.trim() ?? '', loading: () => '', error: (_, _) => '');

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        top: true,
        bottom: true,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
              decoration: BoxDecoration(
                color: const Color(0xFF001E68),
                border: Border(bottom: BorderSide(color: Color(0xFFE6ECF3))),
              ),
              child: Row(
                children: [
                  ClipOval(
                    child: Container(
                      width: 36,
                      height: 36,
                      color: const Color(0xFFFFFFFF),
                      child: photoUrl.isNotEmpty
                          ? Image.network(
                              photoUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return const Icon(Icons.person, color: Colors.grey);
                              },
                            )
                          : const Icon(Icons.person, color: Colors.grey),
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      '$greeting, $headerName',
                      style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFFFFFFFF)),
                    ),
                  ),
                  //circleAction(svgAsset: 'assets/icons/notification.svg', onTap: () {}),
                  SizedBox(width: AppSpacing.sm),
                  circleAction(svgAsset: 'assets/icons/support.svg', onTap: () {}),
                ],
              ),
            ),
            Container(
              height: 46,
              color: const Color(0xFF001E68),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: InkWell(
                      onTap: () => Navigator.of(context).pop(),
                      borderRadius: BorderRadius.circular(24),
                      splashColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      hoverColor: Colors.transparent,
                      focusColor: Colors.transparent,
                      child: SizedBox(
                        width: 15,
                        height: 15,
                        child: SvgPicture.asset(
                          width: 10,
                          height: 10,
                          "assets/icons/arrow-back.svg",
                          fit: BoxFit.contain,
                          colorFilter: const ColorFilter.mode(Color(0xFFFFFFFF), BlendMode.srcIn),
                        ),
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      'Sobre o Aplicativo',
                      style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFFFFFFFF)),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Container(
                      width: double.infinity,
                      color: const Color(0xFF001E68),
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(color: const Color(0xFFF3F4F6), borderRadius: BorderRadius.circular(10)),
                            alignment: Alignment.center,
                            child: Text(
                              'CC',
                              style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.w800, color: const Color(0xFF000000)),
                            ),
                          ),
                          SizedBox(height: 10),
                          Text(
                            'ClubeCash',
                            style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w700, color: Color(0xFFE6ECF3)),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Versão 2.4.0 (build 1024)',
                            style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w400, color: const Color(0xFF9CA3AF)),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: double.infinity,
                      color: const Color(0xFFF8F8F8),
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Nossa Missão',
                            style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.w800, color: const Color(0xFF000000)),
                          ),
                          SizedBox(height: AppSpacing.sm),
                          Text(
                            'O ClubeCash nasceu com o propósito de transformar a relação entre consumidores e marcas, trazendo benefícios reais e imediatos para cada compra realizada. Queremos que cada centavo gasto pelo usuário retorne em valor e experiências.',
                            style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w400, color: const Color(0xFF9CA3AF), height: 1.45),
                          ),
                          SizedBox(height: 20),
                          _featureCard(
                            svgAsset: 'assets/icons/flash.svg',
                            iconBg: const Color(0xFFEAF1FF),
                            iconColor: const Color(0xFF1D4ED8),
                            title: 'Rápido e Simples',
                            subtitle: 'Escaneie sua nota e receba seu cashback em segundos.',
                          ),
                          SizedBox(height: AppSpacing.md),
                          _featureCard(
                            svgAsset: 'assets/icons/safety.svg',
                            iconBg: const Color(0xFFFFF4DB),
                            iconColor: const Color(0xFFEAB308),
                            title: 'Seguro',
                            subtitle: 'Seus dados e transações protegidos com tecnologia de ponta.',
                          ),
                          SizedBox(height: AppSpacing.md),
                          _featureCard(
                            svgAsset: 'assets/icons/heart.svg',
                            iconBg: const Color(0xFFFDECEC),
                            iconColor: const Color(0xFFDC2626),
                            title: 'Feito para você',
                            subtitle: 'Ofertas personalizadas baseadas no seu estilo de vida.',
                          ),
                          SizedBox(height: 18),
                          Container(
                            alignment: Alignment.center,
                            padding: EdgeInsets.all(48),
                            child: Column(
                              children: [
                                Text(
                                  '© 2026 ClubeCash Tecnologia LTDA.',
                                  style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: const Color(0xFF6B7280)),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  'Todos os direitos reservados.',
                                  style: GoogleFonts.inter(fontSize: 10.5, fontWeight: FontWeight.w400, color: const Color(0xFF9CA3AF)),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
