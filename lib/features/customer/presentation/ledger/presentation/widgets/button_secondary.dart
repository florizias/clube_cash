import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SecondaryButton extends StatefulWidget {
  final String label;
  final VoidCallback onTap;
  const SecondaryButton({super.key , required this.label, required this.onTap});

  @override
  State<SecondaryButton> createState() => _SecondaryButtonState();
}

class _SecondaryButtonState extends State<SecondaryButton> {
  bool _hovering = false;

  VoidCallback get onTap => widget.onTap;
  String get label => widget.label;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Container(
          height: 40,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Color(0xFFFFFFFF),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: _hovering ? Color(0xFFEF8F00) : Color(0xFFE6ECF3)),
            boxShadow: [BoxShadow(color: const Color(0x140F172A), blurRadius: 8, offset: const Offset(0, 2))],
          ),
          child: Text(
            label,
            style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: const Color(0xFF0F172A)),
          ),
        ),
      ),
    );
  }
}
