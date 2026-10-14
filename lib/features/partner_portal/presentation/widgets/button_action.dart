import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TopActionButton extends StatefulWidget {
  final String label;
  final VoidCallback onTap;

  const TopActionButton({
    super.key,
    required this.label,
    required this.onTap,
  });

  @override
  State<TopActionButton> createState() => _TopActionButtonState();
}

class _TopActionButtonState extends State<TopActionButton> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        hoverColor: Colors.transparent,
        focusColor: Colors.transparent,
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 140),
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFFFFFFFF),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: _hovering
                  ? const Color(0xFF1D4ED8)
                  : const Color(0xFFE5E7EB),
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0x140F172A),
                blurRadius: _hovering ? 18 : 12,
                offset: Offset(0, _hovering ? 6 : 4),
                spreadRadius: 0,
              ),
            ],
          ),
          child: Center(
            child: Text(
              widget.label,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF0F172A),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
