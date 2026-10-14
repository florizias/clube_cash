import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../share/widgets_exports.dart';

class PartnerTermsConditionsPage extends ConsumerWidget {
  const PartnerTermsConditionsPage({super.key});

  Widget _termSection({required String title, required String body}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.w800, color: const Color(0xFF001952), height: 1.2),
          ),
          Text(
            body,
            style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w400, color: const Color(0xFF001952), height: 1.5),
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
      backgroundColor: const Color(0xFFFCFCFC),
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
                      'Termos & Condições',
                      style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFFFFFFFF)),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _termSection(
                      title: '1. Aceitação dos Termos',
                      body:
                          'Ao acessar e usar o aplicativo ClubeCash, você concorda em cumprir e estar vinculado a estes Termos e Condições de Uso. Se você não concordar com qualquer parte destes termos, não deverá utilizar o aplicativo.',
                    ),
                    _termSection(
                      title: '2. Programa de Cashback',
                      body:
                          'O ClubeCash oferece um programa de fidelidade onde os usuários podem acumular pontos e receber parte do valor gasto em compras de volta (cashback) em parceiros selecionados. As taxas de cashback variam de acordo com o parceiro e o nível de fidelidade do usuário.',
                    ),
                    _termSection(
                      title: '3. Privacidade de Dados',
                      body:
                          'Sua privacidade é importante para nós. Coletamos e processamos seus dados de acordo com nossa Política de Privacidade e em conformidade com a LGPD. Ao utilizar o scanner de notas fiscais, você autoriza o processamento dos dados contidos no documento para fins de validação de cashback.',
                    ),
                    _termSection(
                      title: '4. Uso Indevido',
                      body:
                          'Qualquer tentativa de fraude, incluindo a submissão de notas fiscais falsas ou de terceiros sem autorização, resultará no banimento imediato da conta e perda de todos os pontos acumulados.',
                    ),
                    _termSection(
                      title: '5. Alterações nos Termos',
                      body:
                          'Reservamo-nos o direito de modificar estes termos a qualquer momento. Notificaremos os usuários sobre mudanças significativas através do aplicativo.',
                    ),
                    SizedBox(height: AppSpacing.xs),
                    Container(
                      alignment: Alignment.center,
                      padding: EdgeInsets.all(20),
                      child: Text(
                        'Última atualização: 12 de Março de 2026',
                        style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500, color: const Color(0xFF9CA3AF)),
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
