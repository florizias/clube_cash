import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

Widget readonlyField(String label, String value) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: const Color(0xFF94A3B8)),
      ),
      const SizedBox(height: 6),
      TextFormField(
        initialValue: value,
        enabled: false,
        style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF94A3B8)),
        decoration: InputDecoration(
          isDense: true,
          filled: true,
          fillColor: const Color(0xFFFFFFFF),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
          ),
        ),
      ),
      const SizedBox(height: 12),
    ],
  );
}
