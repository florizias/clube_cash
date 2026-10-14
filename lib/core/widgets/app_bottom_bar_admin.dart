import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/controllers/auth_controller.dart';
import '../../features/share/widgets_exports.dart';
import 'app_nav_item.dart';

class BottomBarAdmin extends ConsumerWidget {
  final int currentIndex;
  final ValueChanged<int> onTab;
  final VoidCallback onCenter;

  const BottomBarAdmin({super.key, required this.currentIndex, required this.onTab, required this.onCenter});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Future<void> logout(WidgetRef ref, BuildContext context) async {
      final shouldLogout = await showConfirmLogoutPop(context);
      if (!shouldLogout) return;
      if (!context.mounted) return;
      await ref.read(authControllerProvider.notifier).signOut();
      if (!context.mounted) return;
      context.go('/login');
    }

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
                  NavItem(svgIcon: "assets/icons/couple.svg", label: 'Parceiros', selected: currentIndex == 0, onTap: () => onTab(0)),
                  NavItem(svgIcon: "assets/icons/image.svg", label: 'Anúncios', selected: currentIndex == 1, onTap: () => onTab(1)),
                  NavItem(
                    svgIcon: "assets/icons/logout-rounded.svg",
                    label: 'Sair',
                    selected: currentIndex == 3,
                    onTap: () => logout(ref, context),
                    isLogout: true,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
