import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../../../app/theme/app_spacing.dart';

class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const PrimaryButton({super.key, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: onTap,
      child: Container(
        height: 42,
        width: double.infinity,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: const Color(0xFFEF8F00),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Color(0xFFE6ECF3)),
          boxShadow: [BoxShadow(color: const Color(0x140F172A), blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              "assets/icons/dollar-square.svg",
              width: 18,
              height: 18,
              fit: BoxFit.contain,
              colorFilter: const ColorFilter.mode(Color(0xFFFFFFFF), BlendMode.srcIn),
            ),
            SizedBox(width: AppSpacing.sm),
            Text(
              label,
              style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFFFFFFFF)),
            ),
          ],
        ),
      ),
    );
  }
}
