import 'package:clubcash/app/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

class PointsCardUser extends StatelessWidget {
  final String points;
  final String label;
  final String estimatedValue;
  final double progress;

  const PointsCardUser({super.key, required this.points, required this.label, required this.estimatedValue, required this.progress});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          stops: [0.4, 0.9],
          transform: const GradientRotation(45),
          colors: [AppColors.primary, AppColors.tertiary],
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  points,
                  style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.w700, color: Color(0xFFFFFFFF)),
                ),
              ),
              SizedBox(width: 10),
              Text(
                label,
                style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w400, color: Color(0xFFFFFFFF)),
              ),
            ],
          ),
          SizedBox(height: 10),
          Divider(color: Color(0xFFFFFFFF), height: 1),
          SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: 'Valor estimado: ',
                        style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: const Color(0xFF9CA3AF)),
                      ),
                      TextSpan(
                        text: estimatedValue,
                        style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: const Color(0xFFFFFFFF)),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(width: 10),
              SizedBox(
                width: 70,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: progress.clamp(0, 1),
                    minHeight: 8,
                    backgroundColor: const Color(0xE6687ea6),
                    valueColor: const AlwaysStoppedAnimation(Color(0xFFEF8F00)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class PointsCard extends StatelessWidget {
  const PointsCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Color(0xFFDBDDDE),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  "0 pontos",
                  style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.w700, color: Color(0x291F2933)),
                ),
              ),
              SizedBox(width: 10),
              Text(
                "Saldo de Pontos",
                style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w400, color: Color(0x291F2933)),
              ),
            ],
          ),
          SizedBox(height: 10),
          Divider(color: Color(0x291F2933), height: 1),
          SizedBox(height: 10),
          Row(
            children: [
              Expanded(child: Text(
                "Valor estimado: R\$ 00,00",
                style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w400, color: Color(0x291F2933)),
              )),
              SvgPicture.asset("assets/icons/lock.svg", width: 20, height: 20, colorFilter: ColorFilter.mode(Color(0xFF0038BC), BlendMode.srcIn)),
            ],
          ),
        ],
      ),
    );
  }
}
