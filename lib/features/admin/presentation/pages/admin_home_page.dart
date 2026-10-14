import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../share/widgets_exports.dart';
import '../providers/admin_partners_provider.dart';
import '../providers/admin_store_requests_provider.dart';
import '../widgets/admin_header_avatar.dart';
import '../widgets/partners_card_admin.dart';
import '../widgets/request_card_admin.dart';
import '../widgets/search_filter_admin.dart';

class AdminHomePage extends ConsumerStatefulWidget {
  const AdminHomePage({super.key});

  @override
  ConsumerState<AdminHomePage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends ConsumerState<AdminHomePage> {
  String _partnerQuery = '';
  int _visiblePartners = 3;
  String _selectedStatus = 'active';

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(currentUserProfileProvider);
    final requestsAsync = ref.watch(pendingStoreRequestsProvider);
    final partnersAsync = ref.watch(adminPartnerStoresProvider);
    final greeting = getGreeting();

    final name = profileAsync.when(data: (profile) => profile?.name ?? 'Usuário', loading: () => 'Carregando...', error: (_, _) => 'Usuário');
    final photoUrl = profileAsync.when(data: (profile) => profile?.photoUrl ?? '', loading: () => '', error: (_, _) => '');
    final emptyMessage = switch (_selectedStatus) {
      'active' => 'Nenhum parceiro ativo encontrado',
      'inactive' => 'Nenhum parceiro inativo encontrado',
      'rejected' => 'Nenhum parceiro recusado encontrado',
      _ => 'Nenhum parceiro encontrado',
    };

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
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.only(left: 12, bottom: 12, right: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Gestão de Parceiros',
                            style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w700, color: const Color(0xFF000000)),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Analise solicitações de entrada e gerencie\nparceiros ativos.',
                            style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w400, color: const Color(0xFF9CA3AF), height: 1.35),
                          ),
                        ],
                      ),
                    ),

                    sectionCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              SvgPicture.asset(
                                'assets/icons/clock.svg',
                                width: 18,
                                height: 18,
                                colorFilter: const ColorFilter.mode(Color(0xFFEF8F00), BlendMode.srcIn),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Novas Solicitações',
                                style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w800, color: const Color(0xFF000000)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          requestsAsync.when(
                            loading: () => const Padding(
                              padding: EdgeInsets.all(20),
                              child: Center(child: CircularProgressIndicator()),
                            ),
                            error: (_, _) => Padding(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              child: Text(
                                'Erro ao carregar solicitações.',
                                style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.red),
                              ),
                            ),
                            data: (requests) {
                              final pendingRequests = requests.take(3).toList();

                              if (pendingRequests.isEmpty) {
                                return Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  child: Text(
                                    'Nenhuma solicitação pendente',
                                    style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500, color: const Color(0xFF9CA3AF)),
                                  ),
                                );
                              }

                              return Column(
                                children: pendingRequests.asMap().entries.map((entry) {
                                  final index = entry.key;
                                  final request = entry.value;
                                  final isLast = index == pendingRequests.length - 1;

                                  return Padding(
                                    padding: EdgeInsets.only(bottom: isLast ? 0 : 12),
                                    child: requestItem(
                                      context: context,
                                      request: request,
                                      onApprove: () async {
                                        await ref.read(adminStoreRequestActionsProvider).approveRequest(request);
                                      },
                                      onReject: (reason) async {
                                        await ref.read(adminStoreRequestActionsProvider).rejectRequest(uid: request.uid, reason: reason);
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

                    const SizedBox(height: 12),

                    sectionCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Parceiros Ativos',
                            style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w700, color: const Color(0xFF000000)),
                          ),
                          const SizedBox(height: 14),

                          searchFilter(
                            selectedStatus: _selectedStatus,
                            onSearchChanged: (value) {
                              setState(() {
                                _partnerQuery = value;
                                _visiblePartners = 3;
                              });
                            },
                            onStatusChanged: (value) {
                              setState(() {
                                _selectedStatus = value;
                                _visiblePartners = 3;
                              });
                            },
                          ),

                          const SizedBox(height: 14),

                          partnersAsync.when(
                            loading: () => const Padding(
                              padding: EdgeInsets.all(20),
                              child: Center(child: CircularProgressIndicator()),
                            ),
                            error: (_, _) => Text('Erro ao carregar parceiros.', style: GoogleFonts.inter(color: Colors.red)),
                            data: (partners) {
                              final filteredPartners = partners.where((partner) {
                                final query = _partnerQuery.trim().toLowerCase();

                                final matchesSearch =
                                    query.isEmpty ||
                                    partner.name.toLowerCase().contains(query) ||
                                    partner.category.toLowerCase().contains(query) ||
                                    partner.subCategory.toLowerCase().contains(query) ||
                                    partner.id.toLowerCase().contains(query);

                                final isPartner = partner.role == 'partner';

                                final matchesStatus =
                                    (_selectedStatus == 'active' && partner.status == 'active') ||
                                    (_selectedStatus == 'inactive' && partner.status == 'inactive') ||
                                    (_selectedStatus == 'rejected' && partner.status == 'rejected') ||
                                    (_selectedStatus == 'all');

                                return isPartner && matchesSearch && matchesStatus;
                              }).toList();

                              final visiblePartners = filteredPartners.take(_visiblePartners).toList();

                              final canShowMore = _visiblePartners < filteredPartners.length;

                              if (visiblePartners.isEmpty) {
                                return Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 20),
                                  child: Center(
                                    child: Text(
                                      emptyMessage,
                                      style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500, color: const Color(0xFF9CA3AF)),
                                    ),
                                  ),
                                );
                              }

                              return Column(
                                children: [
                                  ...visiblePartners.asMap().entries.map((entry) {
                                    final index = entry.key;
                                    final partner = entry.value;

                                    return partnerItem(context: context, partner: partner, showDivider: index != visiblePartners.length - 1);
                                  }),

                                  if (canShowMore) ...[
                                    const SizedBox(height: 12),
                                    SizedBox(
                                      width: double.infinity,
                                      height: 39,
                                      child: OutlinedButton.icon(
                                        onPressed: () {
                                          setState(() {
                                            _visiblePartners += 3;
                                          });
                                        },
                                        label: Text(
                                          'Ver mais',
                                          style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500, color: const Color(0xFF0038BC)),
                                        ),
                                        icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 24, color: Color(0xFF0038BC)),
                                        iconAlignment: IconAlignment.end,
                                        style: ButtonStyle(
                                          foregroundColor: WidgetStateProperty.all(const Color(0xFF0038BC)),
                                          backgroundColor: WidgetStateProperty.all(const Color(0xFFFFFFFF)),
                                          overlayColor: WidgetStateProperty.all(Colors.transparent),
                                          surfaceTintColor: WidgetStateProperty.all(Colors.transparent),
                                          shadowColor: WidgetStateProperty.all(const Color(0x0D36717D)),
                                          elevation: WidgetStateProperty.all(10),
                                          side: WidgetStateProperty.all(const BorderSide(color: Color(0xFFE6ECF3))),
                                          shape: WidgetStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              );
                            },
                          ),
                        ],
                      ),
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
