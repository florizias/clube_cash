import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/widgets/app_bottom_bar_customer.dart';

class AppShellCustomerPage extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const AppShellCustomerPage({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCFCFC),
      body: navigationShell,
      bottomNavigationBar: BottomBar(
        currentIndex: navigationShell.currentIndex,
        onTab: (index) {
          if (context.canPop()) {
            context.pop();
          }

          if (index == 3) {
            context.push('/customer/profile');
            return;
          }
          if (index == 4) {
            context.push('/customer/settings');
            return;
          }
          navigationShell.goBranch(index, initialLocation: index == navigationShell.currentIndex);
        },
        onCenter: () {
          navigationShell.goBranch(2);
        },
      ),
    );
  }
}
