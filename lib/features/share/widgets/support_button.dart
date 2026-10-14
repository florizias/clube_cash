import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../app/theme/app_spacing.dart';

Widget supportButton({
  required String title,
  required String subtitle,
  Color? subtitleColor,
  Color? background,
  required String iconAsset,
  required Color iconBg,
  required Color iconColor,
  required VoidCallback onTap,
}) {
  return Padding(
    padding: EdgeInsets.only(left: 16, right: 16, bottom: 12),
    child: InkWell(
      onTap: onTap,
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      hoverColor: Colors.transparent,
      focusColor: Colors.transparent,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFFFFFFF),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE6ECF3)),
        ),
        child: Row(
          children: [
            Container(
              width: 45,
              height: 45,
              decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
              child: Center(child: SvgPicture.asset(iconAsset, width: 20, height: 20, colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn))),
            ),
            SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: const Color(0xFF0F1729)),
                  ),
                  SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w400, color: const Color(0xFF9CA3AF)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
