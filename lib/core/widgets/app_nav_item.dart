import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../app/theme/theme_exports.dart';

class NavItem extends StatelessWidget {
  final String svgIcon;
  final String label;
  final bool selected;
  final bool enabled;
  final VoidCallback? onTap;
  final bool isLogout;

  const NavItem({
    super.key,
    required this.svgIcon,
    required this.label,
    required this.selected,
    this.enabled = true,
    this.onTap,
    this.isLogout = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = !enabled
        ? const Color(0xFF9CA3AF)
        : selected
        ? const Color(0xFF1D4ED8)
        : const Color(0xFF6B7280);

    final colorLogout = Color(0xFFC0392B);

    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(12),
      child: Opacity(
        opacity: enabled ? 1 : 0.4,
        child: SizedBox(
          width: 68,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(svgIcon, width: 20, height: 20, colorFilter: ColorFilter.mode(isLogout ? colorLogout : color, BlendMode.srcIn)),
              SizedBox(height: AppSpacing.xs),
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: enabled ? FontWeight.w700 : FontWeight.w400,
                  color: isLogout ? colorLogout : color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
