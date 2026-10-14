import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/admin/presentation/pages/admin_ads_page.dart';
import '../features/admin/presentation/pages/admin_home_page.dart';
import '../features/auth/presentation/pages/login_page.dart';
import '../features/auth/presentation/pages/partner_status_gate_page.dart';
import '../features/auth/presentation/pages/recover_password_page.dart';
import '../features/auth/presentation/pages/register_choice_page.dart';
import '../features/auth/presentation/pages/register_page.dart';
import '../features/auth/presentation/pages/store_partnership_request_page.dart';
import '../features/auth/presentation/pages/store_partnership_review_page.dart';
import '../features/auth/presentation/providers/auth_providers.dart';
import '../features/customer/presentation/ledger/presentation/earn_points_page.dart';
import '../features/customer/presentation/ledger/presentation/wallet_page.dart';
import '../features/customer/presentation/profile/customer_about_app_page.dart';
import '../features/customer/presentation/profile/customer_change_password_page.dart';
import '../features/customer/presentation/profile/customer_delete_account_page.dart';
import '../features/customer/presentation/profile/customer_help_support_page.dart';
import '../features/customer/presentation/profile/customer_profile_page.dart';
import '../features/customer/presentation/profile/customer_settings_page.dart';
import '../features/customer/presentation/profile/customer_terms_conditions_page.dart';
import '../features/customer/presentation/purchases/presentation/register_purchase.dart';
import '../features/home/presentation/help_page.dart';
import '../features/home/presentation/home_page.dart';
import '../features/partner_portal/presentation/pages/partner_home_page.dart';
import '../features/partner_portal/presentation/pages/partner_product_edit_page.dart';
import '../features/partner_portal/presentation/pages/partner_product_new_page.dart';
import '../features/partner_portal/presentation/pages/partner_products_page.dart';
import '../features/partner_portal/presentation/pages/partner_settings_page.dart';
import '../features/partner_portal/presentation/pages/partner_support_page.dart';
import '../features/partners/presentation/partner_page.dart';
import 'app_shell_admin_page.dart';
import 'app_shell_customer_page.dart';
import 'app_shell_partner_page.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final rootNavigatorKey = GlobalKey<NavigatorState>();

  final userAsync = ref.watch(firebaseUserProvider);
  final profileAsync = ref.watch(userProfileProvider);

  final isLoggedIn = userAsync.maybeWhen(data: (user) => user != null, orElse: () => false);
  final role = profileAsync.maybeWhen(data: (profile) => profile?.role, orElse: () => null);
  final status = profileAsync.maybeWhen(data: (profile) => profile?.status, orElse: () => null);

  return GoRouter(
    navigatorKey: rootNavigatorKey,
    debugLogDiagnostics: false,
    initialLocation: '/home',
    routes: [
      GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
      GoRoute(path: '/register', builder: (context, state) => const RegisterPage()),
      GoRoute(path: '/register-choice', builder: (context, state) => const RegisterChoicePage()),
      GoRoute(path: '/store-partnership-request', builder: (context, state) => const StorePartnershipRequestPage()),
      GoRoute(path: '/recover', builder: (context, state) => const RecoverPasswordPage()),
      GoRoute(path: '/earnpoints', builder: (context, state) => const EarnPointsPage()),
      GoRoute(path: '/help-support', parentNavigatorKey: rootNavigatorKey, builder: (context, state) => const HelpPage()),

      //CUSTOMER
      GoRoute(path: '/customer/profile', parentNavigatorKey: rootNavigatorKey, builder: (context, state) => const ProfilePage()),
      GoRoute(path: '/customer/settings', parentNavigatorKey: rootNavigatorKey, builder: (context, state) => const SettingsPage()),
      GoRoute(path: '/customer/settings/profile', parentNavigatorKey: rootNavigatorKey, builder: (context, state) => const ProfilePage()),
      GoRoute(
        path: '/customer/settings/change-password',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const PartnerChangePasswordPage(),
      ),
      GoRoute(
        path: '/customer/settings/delete-account',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const CustomerDeleteAccountPage(),
      ),
      GoRoute(
        path: '/customer/settings/help-support',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const PartnerHelpSupportPage(),
      ),
      GoRoute(
        path: '/customer/settings/terms-conditions',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const PartnerTermsConditionsPage(),
      ),
      GoRoute(path: '/customer/settings/about-app', parentNavigatorKey: rootNavigatorKey, builder: (context, state) => const PartnerAboutAppPage()),

      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return AppShellCustomerPage(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home',
                builder: (context, state) => const HomePage(),
                routes: [
                  GoRoute(
                    path: 'partner/:storeId',
                    builder: (context, state) {
                      final storeId = state.pathParameters['storeId']!;
                      final partnerUID = state.extra as String?;

                      return PartnerPage(storeId: storeId, partnerUID: partnerUID);
                    },
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [GoRoute(path: '/customer/wallet', builder: (context, state) => const WalletPage())],
          ),
          StatefulShellBranch(
            routes: [GoRoute(path: '/customer/purchase/new', builder: (context, state) => const RegisterPurchasePage())],
          ),
        ],
      ),

      //PARTNERS
      GoRoute(path: '/partner/status', builder: (context, state) => const PartnerStatusGatePage()),
      GoRoute(path: '/partner/request-review', builder: (context, state) => const StorePartnershipReviewPage()),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return AppShellPartnerPage(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [GoRoute(path: '/partner/home', builder: (context, state) => const PartnerHomePage())],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/partner/products',
                builder: (context, state) => const PartnerProductsPage(),
                routes: [
                  GoRoute(path: 'new', parentNavigatorKey: rootNavigatorKey, builder: (context, state) => const PartnerProductNewPage()),
                  GoRoute(
                    path: ':id',
                    parentNavigatorKey: rootNavigatorKey,
                    builder: (context, state) {
                      final id = state.pathParameters['id']!;
                      return PartnerProductEditPage(productId: id);
                    },
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [GoRoute(path: '/partner/settings', builder: (context, state) => const PartnerStoreSettingsPage())],
          ),
          StatefulShellBranch(
            routes: [GoRoute(path: '/partner/support', builder: (context, state) => const PartnerSupportPage())],
          ),
        ],
      ),

      // ADMIN
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return AppShellAdminPage(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [GoRoute(path: '/admin/home', builder: (context, state) => const AdminHomePage())],
          ),
          StatefulShellBranch(
            routes: [GoRoute(path: '/admin/ads', builder: (context, state) => const AdminAdsPage())],
          ),
        ],
      ),
    ],

    redirect: (context, state) {
      final loc = state.matchedLocation;

      final isAuthRoute =
          loc == '/login' || loc == '/register' || loc == '/register-choice' || loc == '/store-partnership-request' || loc == '/recover';

      final isPublicRoute = loc == '/home' || loc.startsWith('/home/partner/') || loc == '/earnpoints' || isAuthRoute;

      final isAdminRoute = loc.startsWith('/admin/');
      final isPartnerRoute = loc.startsWith('/partner/');
      final isCustomerRoute = loc.startsWith('/customer/');

      final isPartnerStatusRoute = loc == '/partner/status';
      final isPartnerReviewRoute = loc == '/partner/request-review';

      final authIsLoading = userAsync.isLoading;
      final profileIsLoading = isLoggedIn && profileAsync.isLoading;

      if (authIsLoading || profileIsLoading) {
        return null;
      }

      if (!isLoggedIn) {
        if (isPublicRoute) return null;

        if (isAdminRoute || isPartnerRoute || isCustomerRoute) {
          return '/login';
        }

        return null;
      }

      if (status == 'blocked') {
        if (loc == '/login') return null;
        return '/login';
      }

      // parceiro ainda não aprovado
      // essa regra precisa vir antes do isAuthRoute
      if (role == 'partner' && status != 'active') {
        if (isPartnerStatusRoute || isPartnerReviewRoute) {
          return null;
        }

        return '/partner/status';
      }

      if (isAuthRoute) {
        if (role == 'admin') return '/admin/home';
        if (role == 'partner') return '/partner/home';
        return '/home';
      }

      if (role == 'admin' && !isAdminRoute) {
        return '/admin/home';
      }

      if (role == 'partner' && !isPartnerRoute) {
        return '/partner/home';
      }

      if (role == 'customer' && (isAdminRoute || isPartnerRoute)) {
        return '/home';
      }

      return null;
    },

    errorBuilder: (context, state) {
      return Scaffold(body: Center(child: Text('Rota não encontrada: ${state.uri}')));
    },
  );
});
