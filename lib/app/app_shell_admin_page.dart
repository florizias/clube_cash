import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/widgets/app_bottom_bar_admin.dart';

class AppShellAdminPage extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const AppShellAdminPage({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCFCFC),
      body: navigationShell,
      bottomNavigationBar: BottomBarAdmin(
        currentIndex: navigationShell.currentIndex,
        onTab: (index) {
          navigationShell.goBranch(index, initialLocation: index == navigationShell.currentIndex);
        },
        onCenter: () {
          navigationShell.goBranch(2);
        },
      ),
    );
  }
}
