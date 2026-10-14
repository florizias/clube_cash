import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../app/theme/theme_exports.dart';
import '../../../../core/widgets/app_search_field.dart';
import '../../../share/widgets_exports.dart';

class PartnerSupportPage extends StatefulWidget {
  const PartnerSupportPage({super.key});

  @override
  State<PartnerSupportPage> createState() => _PartnerSupportPageState();
}

class _PartnerSupportPageState extends State<PartnerSupportPage> {
  final TextEditingController _searchCtrl = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleSupportAction(Future<bool> Function() action, String errorMessage) async {
    final success = await action();
    if (!mounted) return;
    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(errorMessage)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredFaqs = faqItems.where((item) {
      final query = _query.trim().toLowerCase();
      if (query.isEmpty) return true;
      return item.question.toLowerCase().contains(query) || item.answer.toLowerCase().contains(query);
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      body: SafeArea(
        top: true,
        bottom: true,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Container(
                      height: 48,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Align(
                            alignment: Alignment.centerLeft,
                            child: InkWell(
                              onTap: () {
                                if (context.canPop()) {
                                  context.pop();
                                } else {
                                  context.go('/partner/home');
                                }
                              },
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
                                  colorFilter: const ColorFilter.mode(Color(0xFF0038BC), BlendMode.srcIn),
                                ),
                              ),
                            ),
                          ),
                          Align(
                            alignment: Alignment.centerRight,
                            child: Text(
                              'Suporte',
                              style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF0038BC)),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: double.infinity,
                      margin: EdgeInsets.all(12),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            'Suporte ao Parceiro',
                            style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.w700, color: const Color(0xFF000000)),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Estamos aqui para ajudar sua empresa a crescer.',
                            style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w400, color: const Color(0xFF9CA3AF)),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: double.infinity,
                      margin: EdgeInsets.all(16),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Color(0xFFFAFAF8),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFE6ECF3)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            'O que você procura?',
                            style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.w700, color: const Color(0xFF000000)),
                          ),
                          SizedBox(height: AppSpacing.md),
                          SearchField(
                            hint: 'Busque por dúvida',
                            onChanged: (v) {
                              setState(() {
                                _query = v;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: double.infinity,
                      margin: EdgeInsets.symmetric(horizontal: 16),
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Color(0xFFFAFAF8),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: const Color(0xFFEFEAE3)),
                      ),
                      child: Column(
                        spacing: 12,
                        children: [
                          supportButton(
                            title: 'Falar no WhatsApp',
                            subtitle: 'Atendimento de seg-sex | 09h às 18h',
                            subtitleColor: Color(0xFF1E9E5A),
                            background: Color(0xFFE6F6EE),
                            iconAsset: 'assets/icons/message.svg',
                            iconBg: const Color(0xFF1E9E5A),
                            iconColor: const Color(0xFFE6F6EE),
                            onTap: () => _handleSupportAction(SupportActions.openWhatsApp, 'Não foi possível abrir o WhatsApp.'),
                          ),
                          supportButton(
                            title: 'Enviar E-mail',
                            subtitle: 'Responderemos em até 24h.',
                            subtitleColor: Color(0xFF0038BC),
                            background: Color(0xFFE6ECF3),
                            iconAsset: 'assets/icons/mail.svg',
                            iconBg: const Color(0xFF0038BC),
                            iconColor: const Color(0xFFE6ECF3),
                            onTap: () => _handleSupportAction(SupportActions.openEmail, 'Não foi possível abrir o aplicativo de e-mail.'),
                          ),
                          supportButton(
                            title: '0800 123 4567',
                            subtitle: 'Apenas emergências técnicas',
                            subtitleColor: Color(0xFF9CA3AF),
                            background: Color(0xFFFFFFFF),
                            iconAsset: 'assets/icons/phone.svg',
                            iconBg: const Color(0xFF9CA3AF),
                            iconColor: const Color(0xFFFFFFFF),
                            onTap: () => _handleSupportAction(SupportActions.openPhoneCall, 'Não foi possível abrir o aplicativo de chamadas.'),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: AppSpacing.md),
                    Container(
                      width: double.infinity,
                      margin: EdgeInsets.only(left: 16, right: 16, bottom: 16),
                      decoration: BoxDecoration(
                        color: Color(0xFFFFFFFF),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: const Color(0xFFE5E7EB)),
                      ),
                      child: Column(
                        children: [
                          Container(
                            color: const Color(0xFFFAFAF8),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            child: Row(
                              children: [
                                SvgPicture.asset(
                                  'assets/icons/document-text.svg',
                                  width: 16,
                                  height: 16,
                                  colorFilter: const ColorFilter.mode(Color(0xFF6B7280), BlendMode.srcIn),
                                ),
                                SizedBox(width: AppSpacing.sm),
                                Text(
                                  'Dúvidas Frequentes',
                                  style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700, color: const Color(0xFF001952)),
                                ),
                              ],
                            ),
                          ),
                          ...filteredFaqs
                              .asMap()
                              .entries
                              .map((entry) {
                            final index = entry.key;
                            final item = entry.value;
                            return faqCard(context: context,
                                index: index,
                                totalItems: filteredFaqs.length,
                                item: item,
                                query: _query);
                          }),
                        ],
                      ),
                    ),
                    SizedBox(height: AppSpacing.xs),
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
