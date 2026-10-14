import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../app/theme/app_spacing.dart';
import '../../share/widgets_exports.dart';
import '../models/partner_model.dart';

class TabAboutPartner extends StatelessWidget {
  final PartnerStore partner;
  final String cashbackLabel;

  const TabAboutPartner({super.key, required this.partner, required this.cashbackLabel});

  @override
  Widget build(BuildContext context) {
    final categoryText = [partner.category, partner.subCategory].where((item) => item.trim().isNotEmpty).join(' • ');

    final aboutText = categoryText.isEmpty
        ? '${partner.name} é uma loja parceira ClubCash.'
        : '${partner.name} é uma loja parceira ClubCash na categoria $categoryText.';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFFFAFAF8),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE6ECF3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Sobre a Empresa',
                style: GoogleFonts.inter(color: const Color(0xFF001952), fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 6),
              Text(
                aboutText,
                style: GoogleFonts.inter(color: const Color(0xFF9CA3AF), fontSize: 12, fontWeight: FontWeight.w400, height: 1.4),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        AboutCard(partner: partner, cashbackLabel: cashbackLabel),

        SizedBox(height: AppSpacing.md),

        if (partner.openingHours.isNotEmpty) ...[OpeningHoursCard(openingHours: partner.openingHours), SizedBox(height: AppSpacing.md)],

        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFFFFFFFF),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE0B84C)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Regras do Cashback',
                style: GoogleFonts.inter(color: const Color(0xFFE0B84C), fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              _ruleItem('Ganhe $cashbackLabel em compras aprovadas nesta loja.'),
              _ruleItem('Para pontuar, identifique sua compra conforme as regras do ClubCash.'),
              _ruleItem('Os pontos podem passar por análise antes da liberação.'),
            ],
          ),
        ),
      ],
    );
  }
}

class AboutCard extends StatelessWidget {
  final PartnerStore partner;
  final String cashbackLabel;

  const AboutCard({super.key, required this.partner, required this.cashbackLabel});

  @override
  Widget build(BuildContext context) {
    final whatsappDigits = partner.whatsapp.replaceAll(RegExp(r'[^0-9]'), '');
    final whatsappNumber = whatsappDigits.startsWith('55') ? whatsappDigits : '55$whatsappDigits';

    final encodedAddress = Uri.encodeComponent(partner.address);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Contato e Endereço',
          style: GoogleFonts.inter(color: const Color(0xFF000000), fontSize: 14, fontWeight: FontWeight.w400),
        ),

        SizedBox(height: AppSpacing.md),

        if (partner.address.trim().isNotEmpty)
          _row(
            icon: 'assets/icons/place.svg',
            colorIcon: const Color(0xFF0038BC),
            title: 'Endereço',
            subtitle: partner.address,
            onTap: () {
              openUrl('https://www.google.com/maps/search/?api=1&query=$encodedAddress');
            },
          ),

        if (partner.whatsapp.trim().isNotEmpty) ...[
          const SizedBox(height: 10),
          _row(
            icon: 'assets/icons/message.svg',
            colorIcon: const Color(0xFF1E9E5A),
            title: 'Falar no WhatsApp',
            subtitle: partner.whatsapp,
            onTap: () {
              openUrl('https://wa.me/$whatsappNumber');
            },
          ),
        ],

        if (partner.phone.trim().isNotEmpty) ...[
          const SizedBox(height: 10),
          _row(
            icon: 'assets/icons/call.svg',
            colorIcon: const Color(0xFF000D26),
            title: 'Telefone',
            subtitle: partner.phone,
            onTap: () {
              final phoneDigits = partner.phone.replaceAll(RegExp(r'[^0-9]'), '');
              openUrl('tel:$phoneDigits');
            },
          ),
        ],

        if (partner.email.trim().isNotEmpty) ...[
          const SizedBox(height: 10),
          _row(
            icon: 'assets/icons/email.svg',
            colorIcon: const Color(0xFF0038BC),
            title: 'E-mail',
            subtitle: partner.email,
            onTap: () {
              openUrl('mailto:${partner.email}');
            },
          ),
        ],

        SizedBox(height: AppSpacing.xl),

        Text(
          'Redes Sociais',
          style: GoogleFonts.inter(color: const Color(0xFF000000), fontSize: 14, fontWeight: FontWeight.w400),
        ),

        SizedBox(height: AppSpacing.md),

        if (partner.instagram.isEmpty && partner.facebook.isEmpty && partner.tiktok.isEmpty && partner.website.isEmpty)
          Text(
            'Nenhuma rede social cadastrada.',
            style: GoogleFonts.inter(color: const Color(0xFF9CA3AF), fontSize: 12, fontWeight: FontWeight.w500),
          )
        else
          Row(
            children: [
              if (partner.instagram.isNotEmpty) _socialIcon(icon: 'assets/images/instagram.png', url: partner.instagram),
              if (partner.facebook.isNotEmpty) ...[const SizedBox(width: 12), _socialIcon(icon: 'assets/images/facebook.png', url: partner.facebook)],
              if (partner.tiktok.isNotEmpty) ...[const SizedBox(width: 12), _socialIcon(icon: 'assets/images/tiktok.png', url: partner.tiktok)],
              if (partner.website.isNotEmpty) ...[const SizedBox(width: 12), _websiteIcon(partner.website)],
            ],
          ),

        SizedBox(height: AppSpacing.md),
      ],
    );
  }

  Widget _row({required String icon, required Color colorIcon, required String title, required String subtitle, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      hoverColor: Colors.transparent,
      focusColor: Colors.transparent,
      child: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFFFFFFF),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE6ECF3)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SvgPicture.asset(icon, width: 18, height: 18, fit: BoxFit.contain, colorFilter: ColorFilter.mode(colorIcon, BlendMode.srcIn)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.inter(color: const Color(0xFF0F1729), fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: GoogleFonts.inter(color: const Color(0xFF9CA3AF), fontSize: 11, fontWeight: FontWeight.w400),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _socialIcon({required String icon, required String url}) {
    return InkWell(
      onTap: () => openUrl(url),
      borderRadius: BorderRadius.circular(20),
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      hoverColor: Colors.transparent,
      child: Container(
        width: 36,
        height: 36,
        decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFFF1F5F9)),
        child: Center(child: Image.asset(icon, width: 18, height: 18, fit: BoxFit.contain)),
      ),
    );
  }

  Widget _websiteIcon(String url) {
    return InkWell(
      onTap: () => openUrl(url),
      borderRadius: BorderRadius.circular(20),
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      hoverColor: Colors.transparent,
      child: Container(
        width: 36,
        height: 36,
        decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFFF1F5F9)),
        child: const Center(child: Icon(Icons.language_rounded, size: 20, color: Color(0xFF0038BC))),
      ),
    );
  }
}

class OpeningHoursCard extends StatelessWidget {
  final List<OpeningHour> openingHours;

  const OpeningHoursCard({super.key, required this.openingHours});

  @override
  Widget build(BuildContext context) {
    final sortedHours = [...openingHours]..sort((a, b) => a.weekday.compareTo(b.weekday));

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE6ECF3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Horário de Funcionamento',
            style: GoogleFonts.inter(color: const Color(0xFF000000), fontSize: 14, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 10),
          ...sortedHours.map((hour) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                children: [
                  SizedBox(
                    width: 42,
                    child: Text(
                      _weekdayLabel(hour.weekday),
                      style: GoogleFonts.inter(color: const Color(0xFF64748B), fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      hour.closed ? 'Fechado' : '${hour.open} às ${hour.close}',
                      style: GoogleFonts.inter(
                        color: hour.closed ? const Color(0xFFDC2626) : const Color(0xFF0F172A),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  static String _weekdayLabel(int weekday) {
    switch (weekday) {
      case 1:
        return 'Seg';
      case 2:
        return 'Ter';
      case 3:
        return 'Qua';
      case 4:
        return 'Qui';
      case 5:
        return 'Sex';
      case 6:
        return 'Sáb';
      case 7:
        return 'Dom';
      default:
        return '';
    }
  }
}

Widget _ruleItem(String text) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 5),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 7),
          child: Container(
            width: 4,
            height: 4,
            decoration: const BoxDecoration(color: Color(0xFFE0B84C), shape: BoxShape.circle),
          ),
        ),
        const SizedBox(width: 5),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.inter(color: const Color(0xFFE0B84C), fontSize: 12, fontWeight: FontWeight.w400, height: 1.35),
          ),
        ),
      ],
    ),
  );
}
