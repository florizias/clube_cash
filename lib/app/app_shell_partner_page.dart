import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/widgets/app_bottom_bar_partner.dart';

class AppShellPartnerPage extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const AppShellPartnerPage({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCFCFC),
      body: navigationShell,
      bottomNavigationBar: BottomBarPartner(
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
