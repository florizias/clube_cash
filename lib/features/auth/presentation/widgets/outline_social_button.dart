import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class OutlineSocialButton extends StatelessWidget {
  final VoidCallback onTap;
  final Widget icon;
  final String label;

  const OutlineSocialButton({super.key, required this.onTap, required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 44,
      child: OutlinedButton(
        onPressed: onTap,
        style: ButtonStyle(
          foregroundColor: WidgetStateProperty.all(const Color(0xFF0F172A)),
          side: WidgetStateProperty.all(const BorderSide(color: Color(0xFFE2E8F0))),
          shape: WidgetStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
          overlayColor: WidgetStateProperty.all(Colors.transparent),
          splashFactory: NoSplash.splashFactory,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            icon,
            SizedBox(width: 10),
            Text(label, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }
}
