import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

Widget inputTextform({
  required FocusNode focusNode,
  required TextEditingController controller,
  String? hint,
  int maxLines = 1,
  ValueChanged<String>? onChanged,
  TextStyle? style,
  bool enabled = true,
}) {
  return TextFormField(
    controller: controller,
    focusNode: focusNode,
    keyboardType: TextInputType.text,
    enabled: enabled,
    maxLines: maxLines,
    onChanged: onChanged,
    style: style ?? GoogleFonts.inter(fontSize: 12, color: const Color(0xFF111827)),
    decoration: InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF999999)),
      isDense: true,
      filled: true,
      fillColor: const Color(0xFFFFFFFF),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFF0038BC)),
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
      ),
    ),
  );
}
