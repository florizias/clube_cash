import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../models/ad_banner.dart';

Widget adCard({required AdBanner ad, required ValueChanged<bool> onActiveChanged, required VoidCallback onEdit, required VoidCallback onDelete}) {
  return Container(
    margin: const EdgeInsets.only(bottom: 14),
    decoration: BoxDecoration(
      color: const Color(0xFFFFFFFF),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: const Color(0xFFE6ECF3)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: const BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12)),
          child: Stack(
            children: [
              Image.network(
                ad.imageURL,
                height: 165,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) {
                  return Container(
                    height: 165,
                    width: double.infinity,
                    color: const Color(0xFFE6ECF3),
                    alignment: Alignment.center,
                    child: const Icon(Icons.broken_image_outlined, color: Color(0xFF64748B), size: 32),
                  );
                },
              ),
              Positioned.fill(
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(begin: Alignment.bottomCenter, end: Alignment.center, colors: [Color(0x99000000), Color(0x00000000)]),
                  ),
                ),
              ),
              Positioned(
                left: 14,
                bottom: 58,
                child: Text(
                  ad.title,
                  style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFFFFFFFF)),
                ),
              ),
              Positioned(
                left: 14,
                bottom: 18,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(100),
                    border: Border.all(color: Color(0xFFFFFFFF)),
                  ),
                  child: Text(
                    ad.buttonText,
                    style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500, color: Color(0xFFFFFFFF)),
                  ),
                ),
              ),
            ],
          ),
        ),

        Padding(
          padding: const EdgeInsets.fromLTRB(12, 14, 12, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      ad.title,
                      style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w800, color: const Color(0xFF000000)),
                    ),
                  ),
                  Switch(
                    value: ad.isActive,
                    onChanged: onActiveChanged,
                    activeThumbColor: Color(0xFFFFFFFF),
                    activeTrackColor: const Color(0xFF2FA36B),
                    inactiveThumbColor: Color(0xFFFFFFFF),
                    inactiveTrackColor: const Color(0xFFE2E8F0),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                ad.description,
                style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w400, color: const Color(0xFF9CA3AF), height: 1.25),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 42,
                      child: OutlinedButton.icon(
                        onPressed: onEdit,
                        icon: const Icon(Icons.tune_rounded, size: 18, color: Color(0xFF475569)),
                        label: Text(
                          'Editar Detalhes',
                          style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: const Color(0xFF475569)),
                        ),
                        style: ButtonStyle(
                          foregroundColor: WidgetStateProperty.all(const Color(0xFF475569)),
                          backgroundColor: WidgetStateProperty.all(const Color(0xFFFFFFFF)),
                          overlayColor: WidgetStateProperty.all(Colors.transparent),
                          surfaceTintColor: WidgetStateProperty.all(Colors.transparent),
                          side: WidgetStateProperty.all(BorderSide(color: Color(0xFFE6ECF3))),
                          shape: WidgetStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  SizedBox(
                    height: 42,
                    width: 54,
                    child: ElevatedButton(
                      onPressed: onDelete,
                      style: ButtonStyle(
                        backgroundColor: WidgetStateProperty.all(const Color(0xFFFDECEC)),
                        foregroundColor: WidgetStateProperty.all(const Color(0xFFDC2626)),
                        elevation: WidgetStateProperty.all(0),
                        padding: WidgetStateProperty.all(EdgeInsets.zero),
                        overlayColor: WidgetStateProperty.all(Colors.transparent),
                        splashFactory: NoSplash.splashFactory,
                        shadowColor: WidgetStateProperty.all(Colors.transparent),
                        surfaceTintColor: WidgetStateProperty.all(Colors.transparent),
                        shape: WidgetStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                      ),
                      child: const Icon(Icons.delete_rounded, size: 18),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
