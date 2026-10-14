import 'package:clubcash/app/theme/app_spacing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../auth/presentation/providers/auth_providers.dart';
import '../models/partner_model.dart';
import 'widgets/pop_register_purchase.dart';
import 'widgets/product_image.dart';

class TabProductPartner extends ConsumerWidget {
  final PartnerStore partner;

  const TabProductPartner({super.key, required this.partner});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoggedIn = ref.watch(isLoggedInProvider);

    String brl(double value) {
      final valueFormatted = value.toStringAsFixed(2).replaceAll('.', ',');
      return 'R\$ $valueFormatted';
    }

    final visibleProducts = partner.products.where((product) {
      return product.isActive;
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (isLoggedIn)
          Padding(
            padding: EdgeInsets.only(bottom: AppSpacing.md),
            child: InkWell(
              onTap: () => showRegisterPurchasePop(context, partner),
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
              hoverColor: Colors.transparent,
              focusColor: Colors.transparent,
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: const Color(0xFF001952), borderRadius: BorderRadius.circular(14)),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Acabou de comprar?',
                            style: GoogleFonts.inter(color: const Color(0xFFFFFFFF), fontSize: 16, fontWeight: FontWeight.w600),
                          ),
                          Text(
                            'Envie a nota fiscal desta loja agora.',
                            style: GoogleFonts.inter(color: const Color(0xFFE6ECF3), fontSize: 12, fontWeight: FontWeight.w400),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(10),
                      width: 37,
                      height: 37,
                      decoration: BoxDecoration(color: const Color(0x1AFFFFFF), borderRadius: BorderRadius.circular(100)),
                      child: SvgPicture.asset(
                        'assets/icons/camera.svg',
                        fit: BoxFit.contain,
                        colorFilter: const ColorFilter.mode(Color(0xFFE6ECF3), BlendMode.srcIn),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        Text(
          'Produtos',
          style: GoogleFonts.inter(color: const Color(0xFF000000), fontSize: 14, fontWeight: FontWeight.w400),
        ),
        SizedBox(height: AppSpacing.md),
        if (visibleProducts.isEmpty)
          _EmptyProducts(partnerName: partner.name)
        else
          ...visibleProducts.map((product) {
            final cashbackLabel = '${product.cashbackLabel.toStringAsFixed(0)}% de cashback';
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: ProductCard(
                title: product.title,
                subtitle: product.description,
                price: brl(product.price),
                cashback: cashbackLabel,
                imageUrl: product.imageUrl,
                pillBg: const Color(0xFFDDF7E7),
                pillText: const Color(0xFF1B9C52),
              ),
            );
          }),
      ],
    );
  }
}

class _EmptyProducts extends StatelessWidget {
  final String partnerName;

  const _EmptyProducts({required this.partnerName});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE6ECF3)),
      ),
      child: Text(
        '$partnerName ainda não cadastrou produtos.',
        textAlign: TextAlign.center,
        style: GoogleFonts.inter(color: const Color(0xFF9CA3AF), fontSize: 13, fontWeight: FontWeight.w500),
      ),
    );
  }
}

class ProductCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String price;
  final String cashback;
  final String imageUrl;
  final Color pillBg;
  final Color pillText;

  const ProductCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.price,
    required this.cashback,
    required this.imageUrl,
    required this.pillBg,
    required this.pillText,
  });

  @override
  Widget build(BuildContext context) {
    bool isHovering = false;

    return StatefulBuilder(
      builder: (context, setState) {
        return MouseRegion(
          cursor: SystemMouseCursors.click,
          onEnter: (_) => setState(() => isHovering = true),
          onExit: (_) => setState(() => isHovering = false),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOut,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFFFFFF),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: isHovering ? const Color(0xFF0038BC) : const Color(0x291F2933), width: 1),
              boxShadow: isHovering
                  ? [const BoxShadow(color: Color(0x1F0F172A), spreadRadius: 0, blurRadius: 24, offset: Offset(0, 8))]
                  : [const BoxShadow(color: Color(0x0D36717D), spreadRadius: -2, blurRadius: 20, offset: Offset(0, 4))],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    width: 96,
                    height: 96,
                    color: const Color(0xFFF1F5F9),
                    child: ProductImage(imageUrl: imageUrl),
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: SizedBox(
                    height: 96,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.inter(color: const Color(0xFF0F172A), fontSize: 16, fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              subtitle,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.inter(color: const Color(0xFF6B7280), fontSize: 12, fontWeight: FontWeight.w400),
                            ),
                          ],
                        ),

                        Row(
                          children: [
                            Text(
                              price,
                              style: GoogleFonts.inter(color: const Color(0xFF000000), fontSize: 14, fontWeight: FontWeight.w600),
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(color: pillBg, borderRadius: BorderRadius.circular(999)),
                              child: Text(
                                cashback,
                                style: GoogleFonts.manrope(color: pillText, fontSize: 12, fontWeight: FontWeight.w700),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
