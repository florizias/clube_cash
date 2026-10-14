import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../../../app/theme/app_spacing.dart';

class EarnPartnerItem {
  final String id;
  final String name;
  final String cashbackText;
  final Widget logo;

  EarnPartnerItem({required this.id, required this.name, required this.cashbackText, required this.logo});
}

class LogoPlaceholder extends StatelessWidget {
  final Color color;

  const LogoPlaceholder({super.key, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: color.withValues(alpha: 0.18),
      child: Icon(Icons.store, color: color, size: 26),
    );
  }
}

class EarnPartnerCard extends StatefulWidget {
  final EarnPartnerItem store;
  final VoidCallback onTap;

  const EarnPartnerCard({required this.store, required this.onTap, super.key});

  @override
  State<EarnPartnerCard> createState() => _EarnPartnerCardState();
}

class _EarnPartnerCardState extends State<EarnPartnerCard> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 88,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _isHovering = true),
        onExit: (_) => setState(() => _isHovering = false),
        child: InkWell(
          onTap: widget.onTap,
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
      ),
    );
  }

  Widget _buildContent() {
    final store = widget.store;

    return Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: SizedBox(height: 62, width: 62, child: store.logo),
        ),
        SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                store.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600, color: const Color(0xFF0F172A)),
              ),
              SizedBox(height: AppSpacing.xs),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: const Color(0xFFE6F6EE), borderRadius: BorderRadius.circular(100)),
                child: Text(
                  store.cashbackText,
                  style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500, color: const Color(0xFF1E9E5A)),
                ),
              ),
            ],
          ),
        ),
        SizedBox(width: 10),
        InkWell(
          onTap: () {},
          borderRadius: BorderRadius.circular(10),
          child: Icon(Icons.arrow_forward_ios, color: const Color(0xFF000D26), size: 16),
        ),
      ],
    );
  }
}
