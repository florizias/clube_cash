import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../share/widgets_exports.dart';
import '../providers/admin_ads_provider.dart';
import '../widgets/admin_header_avatar.dart';
import '../widgets/ads_card_admin.dart';
import 'pop_ad_banner.dart';

class AdminAdsPage extends ConsumerWidget {
  const AdminAdsPage({super.key});

  Future<void> _toggleBannerActive({required BuildContext context, required WidgetRef ref, required String id, required bool value}) async {
    try {
      await ref.read(adminAdsActionsProvider).toggleActive(id, value);
    } catch (error) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Não foi possível atualizar o banner: $error')));
    }
  }

  Future<void> _deleteBanner({required BuildContext context, required WidgetRef ref, required String id, required String title}) async {
    final confirmDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xFFFFFFFF),
          title: Text(
            'Excluir banner?',
            style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700, color: const Color(0xFF111827)),
          ),
          content: Text(
            'Tem certeza que deseja excluir "$title"? Essa ação não poderá ser desfeita.',
            style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w400, color: const Color(0xFF6B7280), height: 1.35),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(
                'Cancelar',
                style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: const Color(0xFF6B7280)),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFDC2626),
                foregroundColor: const Color(0xFFFFFFFF),
                elevation: 0,
                splashFactory: NoSplash.splashFactory,
                overlayColor: Colors.transparent,
                surfaceTintColor: Colors.transparent,
              ),
              child: Text('Excluir', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700)),
            ),
          ],
        );
      },
    );

    if (confirmDelete != true) return;

    try {
      await ref.read(adminAdsActionsProvider).deleteBanner(id);

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Banner excluído com sucesso.')));
    } catch (error) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Não foi possível excluir o banner: $error')));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(currentUserProfileProvider);
    final adsAsync = ref.watch(adminAdsProvider);
    final greeting = getGreeting();

    final name = profileAsync.when(data: (profile) => profile?.name ?? 'Usuário', loading: () => 'Carregando...', error: (_, _) => 'Usuário');
    final photoUrl = profileAsync.when(data: (profile) => profile?.photoUrl ?? '', loading: () => '', error: (_, _) => '');

    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      body: SafeArea(
        top: true,
        bottom: true,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
              decoration: const BoxDecoration(
                color: Color(0xFFFFFFFF),
                border: Border(bottom: BorderSide(color: Color(0xFFE6ECF3))),
              ),
              child: Row(
                children: [
                  ClipOval(child: AdminHeaderAvatar(photoUrl: photoUrl)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      '$greeting, $name',
                      style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w500, color: const Color(0xFF001952)),
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(14, 14, 14, 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.only(left: 12, bottom: 12, right: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Gerenciador de Anúncios',
                            style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w700, color: const Color(0xFF000000)),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Configure os destaques exibidos na tela inicial e login dos compradores.',
                            style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w400, color: const Color(0xFF9CA3AF), height: 1.35),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(
                      width: double.infinity,
                      height: 44,
                      child: OutlinedButton.icon(
                        onPressed: () => showAdBannerDialog(context, ref),
                        icon: const Icon(Icons.add, size: 18),
                        label: Text('Novo Banner', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700)),
                        style:
                        OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF0F172A),
                          backgroundColor: const Color(0xFFFFFFFF),
                          side: const BorderSide(color: Color(0xFF0038BC)),
                          elevation: 5,
                          splashFactory: NoSplash.splashFactory,
                          overlayColor: Colors.transparent,
                          shadowColor: const Color(0x140F172A),
                          surfaceTintColor: Colors.transparent,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ).copyWith(
                          mouseCursor: WidgetStateProperty.all(SystemMouseCursors.click),
                          overlayColor: WidgetStateProperty.all(Colors.transparent),
                        ),
                      ),
                    ),

                    const SizedBox(height: 18),

                    adsAsync.when(
                      loading: () =>
                      const Padding(
                        padding: EdgeInsets.all(24),
                        child: Center(child: CircularProgressIndicator()),
                      ),
                      error: (error, stackTrace) =>
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Text('Erro ao carregar banners: $error', style: GoogleFonts.inter(fontSize: 13, color: Colors.red)),
                          ),
                      data: (ads) {
                        if (ads.isEmpty) {
                          return Padding(
                            padding: const EdgeInsets.all(16),
                            child: Text('Nenhum banner cadastrado.', style: GoogleFonts.inter(fontSize: 13, color: const Color(0xFF6B7280))),
                          );
                        }

                        return Column(
                          children: ads.map((ad) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: adCard(
                                ad: ad,
                                onEdit: () {
                                  showAdBannerDialog(context, ref, banner: ad);
                                },
                                onActiveChanged: (value) {
                                  _toggleBannerActive(context: context, ref: ref, id: ad.id, value: value);
                                },
                                onDelete: () {
                                  _deleteBanner(context: context, ref: ref, id: ad.id, title: ad.title);
                                },
                              ),
                            );
                          }).toList(),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
