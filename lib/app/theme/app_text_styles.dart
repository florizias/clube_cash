import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTextStyles {
  // Headlines
  static TextStyle h1 = GoogleFonts.inter(fontSize: 28, fontWeight: FontWeight.w800, color: AppColors.textPrimary);
  static TextStyle h2 = GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.textPrimary);
  static TextStyle h3 = GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary);

  // Titles / Sections
  static TextStyle title = GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary);
  static TextStyle subtitle = GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textSecondary);

  // Body
  static TextStyle body = GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w500, color: AppColors.textPrimary);
  static TextStyle bodyMedium = GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.textSecondary);
  static TextStyle bodySmall = GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w400, color: AppColors.textSecondary);

  // Buttons
  static TextStyle button = GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textOnPrimary);

  // Caption / Helper
  static TextStyle caption = GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w500, color: AppColors.textTertiary);
}
