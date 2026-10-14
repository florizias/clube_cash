import 'package:clubcash/features/partners/models/partner_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../app/theme/theme_exports.dart';

class PartnerCard extends StatefulWidget {
  final PartnerStore store;
  final double? userLatitude;
  final double? userLongitude;

  const PartnerCard({super.key, required this.store, required this.userLatitude, required this.userLongitude});

  @override
  State<PartnerCard> createState() => _PartnerCardState();
}

class _PartnerCardState extends State<PartnerCard> {
  bool _isHovering = false;

  String _distanceLabel() {
    final userLat = widget.userLatitude;
    final userLng = widget.userLongitude;
    final storeLat = widget.store.latitude;
    final storeLng = widget.store.longitude;

    if (userLat == null || userLng == null) {
      return '-- km';
    }

    if (storeLat == null || storeLng == null) {
      return '-- km';
    }

    final meters = Geolocator.distanceBetween(userLat, userLng, storeLat, storeLng);

    if (meters < 1000) {
      return '${meters.round()} m';
    }

    final km = meters / 1000;

    return '${km.toStringAsFixed(1).replaceAll('.', ',')} km';
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      child: InkWell(
        onTap: () {
          final storeId = widget.store.storeId.trim().isNotEmpty ? widget.store.storeId.trim() : widget.store.id;

          context.go('/home/partner/$storeId', extra: widget.store.id);
        },
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Color(0xFFFFFFFF),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _isHovering ? const Color(0xFF0038BC) : const Color(0x291F2933), width: 1),
            boxShadow: _isHovering
                ? [BoxShadow(color: const Color(0x1F0F172A), spreadRadius: 0, blurRadius: 24, offset: const Offset(0, 8))]
                : [BoxShadow(color: const Color(0x0D36717D), spreadRadius: -2, blurRadius: 20, offset: const Offset(0, 4))],
          ),
          child: _buildContent(),
        ),
      ),
    );
  }

  Widget _buildContent() {
    final store = widget.store;

    return Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: SizedBox(
            height: 90,
            width: 90,
            child: Image.network(
              widget.store.logoUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: const Color(0xFFF1F5F9),
                  alignment: Alignment.center,
                  child: Icon(Icons.store, color: Color(0xFF6A1B9A), size: 26),
                );
              },
              loadingBuilder: (context, child, progress) {
                if (progress == null) return child;
                return Container(
                  color: const Color(0xFFF1F5F9),
                  alignment: Alignment.center,
                  child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
                );
              },
            ),
          ),
        ),
        SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                store.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700, color: const Color(0xFF0F172A)),
              ),
              SizedBox(height: AppSpacing.xs),
              Row(
                children: [
                  const Icon(Icons.star, size: 14, color: Color(0xFFEF8F00)),
                  SizedBox(width: AppSpacing.xs),
                  Text(
                    store.rating.toStringAsFixed(1),
                    style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w400, color: const Color(0xFFEF8F00)),
                  ),
                  SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Text(
                      store.category,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      softWrap: true,
                      style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w400, color: const Color(0xFF6B7280)),
                    ),
                  ),
                ],
              ),
              SizedBox(height: AppSpacing.xs),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: const Color(0xFFE6F6EE), borderRadius: BorderRadius.circular(100)),
                child: Text(
                  "Dinheiro de volta: ${store.cashbackLabel}%",
                  style: GoogleFonts.manrope(fontSize: 12, fontWeight: FontWeight.w700, color: const Color(0xFF1E9E5A)),
                ),
              ),
            ],
          ),
        ),
        SizedBox(width: 10),
        SizedBox(
          height: 80,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SvgPicture.asset(
                    "assets/icons/place.svg",
                    height: 18,
                    width: 18,
                    colorFilter: const ColorFilter.mode(Color(0xFF001952), BlendMode.srcIn),
                  ),
                  SizedBox(width: AppSpacing.xs),
                  Text(
                    _distanceLabel(),
                    style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w700, color: const Color(0xFF001952)),
                  ),
                ],
              ),
              InkWell(
                borderRadius: BorderRadius.circular(10),
                child: Text(
                  'Ver Mais',
                  style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: const Color(0xFF001952)),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
