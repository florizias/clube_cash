import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../share/widgets_exports.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  Future<void> logout(WidgetRef ref, BuildContext context) async {
    final shouldLogout = await showConfirmLogoutPop(context);
    if (!shouldLogout) return;
    if (!context.mounted) return;
    await ref.read(authControllerProvider.notifier).signOut();
    if (!context.mounted) return;
    context.go('/login');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(firebaseUserProvider);
    final profileAsync = ref.watch(currentUserProfileProvider);

    final user = userAsync.asData?.value;
    final profile = profileAsync.asData?.value;

    final headerName = profileAsync.when(
      data: (profile) {
        final name = profile?.name.trim() ?? '';
        if (name.isEmpty) return 'Usuário';
        return name.split(RegExp(r'\s+')).first;
      },
      loading: () => 'Carregando...',
      error: (_, _) => 'Usuário',
    );

    final email = profile?.email.trim().isNotEmpty == true ? profile!.email : user?.email ?? 'Sem e-mail';

    final photoUrl = profileAsync.when(data: (profile) => profile?.photoUrl.trim() ?? '', loading: () => '', error: (_, _) => '');

    return Scaffold(
      body: SafeArea(
        top: true,
        bottom: true,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: _Header(
                name: headerName,
                email: email,
                photoUrl: photoUrl,
                onBack: () => Navigator.of(context).maybePop(),
                onEdit: () => context.push('/customer/settings/profile'),
              ),
            ),
            SliverToBoxAdapter(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Column(
                  children: [
                    SettingsTile(
                      iconSVG: SvgPicture.asset(
                        "assets/icons/user-settings.svg",
                        width: 20,
                        height: 20,
                        colorFilter: const ColorFilter.mode(Color(0xFF2A3646), BlendMode.srcIn),
                      ),
                      label: 'Configurações do Perfil',
                      onTap: () => context.push('/customer/settings/profile'),
                    ),
                    SettingsTile(
                      iconSVG: SvgPicture.asset(
                        "assets/icons/forgot-password.svg",
                        width: 20,
                        height: 20,
                        colorFilter: const ColorFilter.mode(Color(0xFF2A3646), BlendMode.srcIn),
                      ),
                      label: 'Alteração de Senha',
                      onTap: () => context.push('/customer/settings/change-password'),
                    ),
                    SettingsTile(
                      iconSVG: SvgPicture.asset(
                        "assets/icons/user-settings-delete.svg",
                        width: 20,
                        height: 20,
                        colorFilter: const ColorFilter.mode(Color(0xFF2A3646), BlendMode.srcIn),
                      ),
                      label: 'Deletar conta',
                      onTap: () => context.push('/customer/settings/delete-account'),
                    ),
                    SettingsTile(
                      iconSVG: SvgPicture.asset(
                        "assets/icons/mentoring.svg",
                        width: 20,
                        height: 20,
                        colorFilter: const ColorFilter.mode(Color(0xFF2A3646), BlendMode.srcIn),
                      ),
                      label: 'Dúvidas & Suporte',
                      onTap: () => context.push('/customer/settings/help-support'),
                    ),
                    SettingsTile(
                      iconSVG: SvgPicture.asset(
                        "assets/icons/warning.svg",
                        width: 20,
                        height: 20,
                        colorFilter: const ColorFilter.mode(Color(0xFF2A3646), BlendMode.srcIn),
                      ),
                      label: 'Termo & Condições',
                      onTap: () => context.push('/customer/settings/terms-conditions'),
                    ),
                    SettingsTile(
                      iconSVG: SvgPicture.asset(
                        "assets/icons/mobile-protection.svg",
                        width: 20,
                        height: 20,
                        colorFilter: const ColorFilter.mode(Color(0xFF2A3646), BlendMode.srcIn),
                      ),
                      label: 'Informações sobre o Aplicativo',
                      onTap: () => context.push('/customer/settings/about-app'),
                    ),
                    SettingsTile(
                      iconSVG: SvgPicture.asset(
                        "assets/icons/logout.svg",
                        width: 20,
                        height: 20,
                        colorFilter: const ColorFilter.mode(Color(0xFFC0392B), BlendMode.srcIn),
                      ),
                      label: 'Sair',
                      color: const Color(0xFFC0392B),
                      onTap: () => logout(ref, context),
                    ),
                  ],
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 20)),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final String name;
  final String email;
  final String photoUrl;
  final VoidCallback onBack;
  final VoidCallback onEdit;

  const _Header({required this.name, required this.email, required this.photoUrl, required this.onBack, required this.onEdit});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFF001952), Color(0xFF001952)]),
      ),
      child: SafeArea(
        top: true,
        bottom: true,
        child: Column(
          children: [
            Row(
              children: [
                InkWell(
                  onTap: onBack,
                  borderRadius: BorderRadius.circular(24),
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  hoverColor: Colors.transparent,
                  focusColor: Colors.transparent,
                  child: SizedBox(
                    width: 15,
                    height: 15,
                    child: SvgPicture.asset(
                      width: 10,
                      height: 10,
                      "assets/icons/arrow-back.svg",
                      fit: BoxFit.contain,
                      colorFilter: const ColorFilter.mode(Color(0xFFFFFFFF), BlendMode.srcIn),
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  'Configurações',
                  style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFFFFFFFF)),
                ),
              ],
            ),
            SizedBox(height: AppSpacing.lg),
            ClipOval(
              child: Container(
                width: 70,
                height: 70,
                color: Color(0xFFFFFFFF),
                child: photoUrl.trim().isNotEmpty
                    ? Image.network(
                        photoUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(Icons.person, size: 42, color: Colors.grey);
                        },
                      )
                    : const Icon(Icons.person, size: 42, color: Colors.grey),
              ),
            ),
            SizedBox(height: 10),
            InkWell(
              onTap: onEdit,
              borderRadius: BorderRadius.circular(20),
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
              hoverColor: Colors.transparent,
              focusColor: Colors.transparent,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      name,
                      style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: const Color(0xFFE6ECF3)),
                    ),
                    SizedBox(width: AppSpacing.sm),
                    SvgPicture.asset(
                      "assets/icons/edit-square.svg",
                      width: 15,
                      height: 15,
                      colorFilter: const ColorFilter.mode(Color(0xFFEF8F00), BlendMode.srcIn),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: AppSpacing.xs),
            Text(
              email,
              style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w400, color: Color(0xFF9CA3AF)),
            ),
          ],
        ),
      ),
    );
  }
}

class SettingsTile extends StatelessWidget {
  final Widget iconSVG;
  final String label;
  final VoidCallback onTap;
  final Color? color;

  const SettingsTile({super.key, required this.iconSVG, required this.label, required this.onTap, this.color});

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? const Color(0xFF2A3646);

    return InkWell(
      onTap: onTap,
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      hoverColor: Colors.transparent,
      focusColor: Colors.transparent,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          children: [
            iconSVG,
            SizedBox(width: 10),
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w400, color: effectiveColor),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
