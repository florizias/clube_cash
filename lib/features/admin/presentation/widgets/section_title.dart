import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

Widget sectionTitle(String title) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Text(
      title,
      style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w800, color: const Color(0xFF0038BC)),
    ),
  );
}
