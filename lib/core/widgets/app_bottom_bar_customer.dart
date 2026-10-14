import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../features/auth/presentation/providers/auth_providers.dart';
import 'app_nav_item.dart';

class BottomBar extends ConsumerWidget {
  final int currentIndex;
  final ValueChanged<int> onTab;
  final VoidCallback onCenter;

  const BottomBar({super.key, required this.currentIndex, required this.onTab, required this.onCenter});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoggedIn = ref.watch(isLoggedInProvider);
    final color = isLoggedIn
        ? const Color(0xFF9CA3AF)
        : currentIndex == 2
        ? const Color(0xFF1D4ED8)
        : const Color(0xFF6B7280);

    return SafeArea(
      top: false,
      child: SizedBox(
        height: 72,
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.topCenter,
          children: [
            Container(
              height: 64,
              decoration: const BoxDecoration(
                color: Color(0xFFFFFFFF),
                border: Border(top: BorderSide(color: Color(0xFFE5E7EB))),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  NavItem(svgIcon: "assets/icons/home.svg", label: 'Início', selected: currentIndex == 0, onTap: () => onTab(0)),
                  NavItem(
                    svgIcon: "assets/icons/wallet.svg",
                    label: 'Carteira',
                    selected: currentIndex == 1,
                    enabled: isLoggedIn,
                    onTap: isLoggedIn ? () => onTab(1) : null,
                  ),
                  SizedBox(width: 56),
                  NavItem(
                    svgIcon: "assets/icons/profile.svg",
                    label: 'Perfil',
                    selected: currentIndex == 3,
                    enabled: isLoggedIn,
                    onTap: isLoggedIn ? () => onTab(3) : null,
                  ),
                  NavItem(
                    svgIcon: "assets/icons/config.svg",
                    label: 'Config.',
                    selected: currentIndex == 4,
                    enabled: isLoggedIn,
                    onTap: isLoggedIn ? () => onTab(4) : null,
                  ),
                ],
              ),
            ),
            Positioned(
              bottom: 40,
              child: InkWell(
                onTap: isLoggedIn ? onCenter : null,
                borderRadius: BorderRadius.circular(26),
                child: Container(
                  height: 56,
                  width: 56,
                  decoration: BoxDecoration(
                    color: Color(0xFFDBDDDE),
                    shape: BoxShape.circle,
                    border: Border.all(color: Color(0xFFFFFFFF), width: 3),
                    boxShadow: isLoggedIn ? [
                      BoxShadow(color: Color(0x4D36717D), blurRadius: 10, spreadRadius: -6, offset: const Offset(0, 8)),
                      BoxShadow(color: Color(0x4D36717D), blurRadius: 25, spreadRadius: -5, offset: const Offset(0, 20)),
                      BoxShadow(color: Color(0xFFFFFFFF), blurRadius: 0, spreadRadius: 1, offset: const Offset(0, 0)),
                    ] : [
                      BoxShadow(color: Color(0x4D36717D), blurRadius: 10, spreadRadius: -6, offset: const Offset(0, 8)),
                      BoxShadow(color: Color(0x291F2933), blurRadius: 25, spreadRadius: -5, offset: const Offset(0, 20)),
                      BoxShadow(color: Color(0xFFFFFFFF), blurRadius: 0, spreadRadius: 1, offset: const Offset(0, 0)),
                    ],
                  ),
                  child: Container(
                    height: 48,
                    width: 48,
                    decoration: BoxDecoration(
                      color: isLoggedIn ? Color(0xFF1D4ED8) : Color(0xFFDBDDDE),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.add, color: Color(0xFFFFFFFF), size: 28),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 40,
              child: Text(
                'Registrar',
                style: GoogleFonts.inter(fontSize: 11, fontWeight: isLoggedIn ? FontWeight.w700 : FontWeight.w400, color: color),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
