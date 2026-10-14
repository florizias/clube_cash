import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../share/widgets_exports.dart';
import '../../models/partner_model.dart';

class CoverPartner extends StatelessWidget {
  final PartnerStore partner;

  const CoverPartner({super.key, required this.partner});

  @override
  Widget build(BuildContext context) {
    final coverUrl = partner.coverImageUrl.trim();
    final shareId = partner.storeId.trim().isNotEmpty ? partner.storeId.trim() : partner.id;

    Widget buildCover() {
      if (coverUrl.isEmpty) {
        return const _CoverFallback();
      }

      if (coverUrl.startsWith('http')) {
        return Image.network(
          coverUrl,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, progress) {
            if (progress == null) return child;

            return const _CoverLoading();
          },
          errorBuilder: (_, _, _) {
            return const _CoverFallback();
          },
        );
      }

      return Image.asset(
        coverUrl,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) {
          return const _CoverFallback();
        },
      );
    }

    void goBack() {
      if (context.canPop()) {
        context.pop();
        return;
      }

      context.go('/home');
    }

    return FlexibleSpaceBar(
      background: ClipRRect(
        borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(12), bottomRight: Radius.circular(12)),
        child: Stack(
          fit: StackFit.expand,
          children: [
            buildCover(),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0x00000000), Color(0x00000000), Color(0x330A2C6E), Color(0xFF0A2C6E)],
                ),
              ),
            ),
            Positioned(
              top: 12,
              left: 14,
              child: Material(
                color: const Color(0xFFFFFFFF).withValues(alpha: 0.20),
                shape: const CircleBorder(),
                child: InkWell(
                  onTap: goBack,
                  borderRadius: BorderRadius.circular(32),
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  hoverColor: Colors.transparent,
                  focusColor: Colors.transparent,
                  child: Container(
                    padding: const EdgeInsets.all(5),
                    width: 24,
                    height: 24,
                    child: SvgPicture.asset(
                      "assets/icons/arrow-back.svg",
                      fit: BoxFit.contain,
                      colorFilter: const ColorFilter.mode(Color(0xFFFFFFFF), BlendMode.srcIn),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 12,
              right: 14,
              child: Row(
                spacing: 16,
                children: [
                  Material(
                    color: const Color(0xFFFFFFFF).withValues(alpha: 0.20),
                    shape: const CircleBorder(),
                    child: InkWell(
                      customBorder: const CircleBorder(),
                      onTap: () => sharePartnerPage(partner.name, shareId),
                      child: Container(
                        padding: const EdgeInsets.all(5),
                        width: 24,
                        height: 24,
                        child: SvgPicture.asset(
                          "assets/icons/share.svg",
                          fit: BoxFit.contain,
                          colorFilter: const ColorFilter.mode(Color(0xFFFFFFFF), BlendMode.srcIn),
                        ),
                      ),
                    ),
                  ),
                  Material(
                    color: const Color(0xFFFFFFFF).withValues(alpha: 0.20),
                    shape: const CircleBorder(),
                    child: InkWell(
                      customBorder: const CircleBorder(),
                      onTap: () {},
                      child: Container(
                        padding: const EdgeInsets.all(5),
                        width: 24,
                        height: 24,
                        child: SvgPicture.asset(
                          "assets/icons/alert.svg",
                          fit: BoxFit.contain,
                          colorFilter: const ColorFilter.mode(Color(0xFFFFFFFF), BlendMode.srcIn),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              left: 16,
              right: 16,
              bottom: 18,
              child: Column(
                spacing: 4,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    partner.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(color: const Color(0xFFFFFFFF), fontSize: 24, fontWeight: FontWeight.w800, height: 1.1),
                  ),
                  Row(
                    children: [
                      SvgPicture.asset(
                        "assets/icons/place.svg",
                        fit: BoxFit.contain,
                        colorFilter: const ColorFilter.mode(Color(0xFFFFFFFF), BlendMode.srcIn),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          partner.address.trim().isEmpty ? 'Endereço não informado' : partner.address,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.inter(
                            color: const Color(0xFFFFFFFF).withValues(alpha: 0.90),
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CoverLoading extends StatelessWidget {
  const _CoverLoading();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF0F172A),
      alignment: Alignment.center,
      child: const CircularProgressIndicator(color: Color(0xFFFFFFFF), strokeWidth: 2),
    );
  }
}

class _CoverFallback extends StatelessWidget {
  const _CoverFallback();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF0F172A),
      alignment: Alignment.center,
      child: const Icon(Icons.storefront, color: Color(0xFFFFFFFF), size: 42),
    );
  }
}
