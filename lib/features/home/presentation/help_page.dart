import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../app/theme/theme_exports.dart';
import '../../../core/widgets/app_search_field.dart';
import '../../share/widgets_exports.dart';

class HelpPage extends StatefulWidget {
  const HelpPage({super.key});

  @override
  State<HelpPage> createState() => _HelpPageState();
}

class _HelpPageState extends State<HelpPage> {
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
      backgroundColor: const Color(0xFFFCFCFC),
      body: SafeArea(
        top: true,
        bottom: true,
        child: Column(
          children: [
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
                      onTap: () => context.go('/home'),
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
                      'Dúvidas & Suporte',
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
                      margin: EdgeInsets.all(16),
                      padding: const EdgeInsets.fromLTRB(12, 12, 12, 14),
                      decoration: BoxDecoration(
                        color: Color(0xFFFAFAF8),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFE6ECF3)),
                      ),
                      child: Column(
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 60,
                                height: 60,
                                decoration: const BoxDecoration(color: Color(0xFFE7EEF8), shape: BoxShape.circle),
                                child: Center(
                                  child: SvgPicture.asset(
                                    'assets/icons/support.svg',
                                    width: 24,
                                    height: 24,
                                    colorFilter: const ColorFilter.mode(Color(0xFF0038BC), BlendMode.srcIn),
                                  ),
                                ),
                              ),
                              SizedBox(width: AppSpacing.xl),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Dúvidas & Suporte',
                                      style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.w700, color: const Color(0xFF001952)),
                                    ),
                                    SizedBox(height: 2),
                                    Text(
                                      'Como podemos te ajudar?',
                                      style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w400, color: const Color(0xFF9CA3AF)),
                                    ),
                                  ],
                                ),
                              ),
                            ],
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
                                  colorFilter: const ColorFilter.mode(Color(0xFF9CA3AF), BlendMode.srcIn),
                                ),
                                SizedBox(width: AppSpacing.sm),
                                Text(
                                  'Dúvidas Frequentes',
                                  style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700, color: const Color(0xFF001952)),
                                ),
                              ],
                            ),
                          ),
                          ...filteredFaqs.asMap().entries.map((entry) {
                            final index = entry.key;
                            final item = entry.value;
                            return faqCard(context: context, index: index, totalItems: filteredFaqs.length, item: item, query: _query);
                          }),
                        ],
                      ),
                    ),
                    Divider(height: 1, thickness: 1, color: Color(0xFFE6ECF3)),
                    SizedBox(height: AppSpacing.md),
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
