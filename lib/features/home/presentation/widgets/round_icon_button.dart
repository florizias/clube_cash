import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class RoundIconButton extends StatelessWidget {
  final String svgIcon;
  final VoidCallback onTap;
  final Color color;

  const RoundIconButton({super.key, required this.svgIcon, required this.onTap, this.color = const Color(0xFFFFFFFF)});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(25),
      onTap: onTap,
      child: Container(
        height: 40,
        width: 40,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: const Color(0x00FFFFFF),
          borderRadius: BorderRadius.circular(25),
          border: Border.all(color: Color(0x29FFFFFF), width: 1),
        ),
        child: SvgPicture.asset(
          svgIcon,
          colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
        ),
      ),
    );
  }
}
