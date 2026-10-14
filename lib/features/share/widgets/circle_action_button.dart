import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

Widget circleAction({
  required String svgAsset,
  required VoidCallback onTap,
  Color? background,
  Color? border,
  Color svgColor = const Color(0xFFFFFFFF),
}) {
  final bgColor = background ?? const Color(0xFFFFFFFF).withValues(alpha: 0.04);
  final borderColor = border ?? const Color(0xFFFFFFFF).withValues(alpha: 0.20);

  return InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(18),
    child: Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: bgColor,
        border: Border.all(color: borderColor),
      ),
      child: Center(child: SvgPicture.asset(svgAsset, width: 16, height: 16, colorFilter: ColorFilter.mode(svgColor, BlendMode.srcIn))),
    ),
  );
}
