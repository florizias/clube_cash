import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../app/theme/theme_exports.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../share/widgets_exports.dart';
import '../providers/partner_dashboard_provider.dart';
import '../providers/partner_store_settings_provider.dart';
import '../widgets/receipt_review_pop.dart';
import '../widgets/settings_header_logo.dart';
import '../widgets/transaction_status_style.dart';

class PartnerHomePage extends ConsumerWidget {
  const PartnerHomePage({super.key});

  String brl(num value) {
    return 'R\$ ${value.toStringAsFixed(2).replaceAll('.', ',')}';
  }

  String timeAgo(int minutes) {
    if (minutes < 60) return 'Há $minutes minutos';
    final hours = (minutes / 60).floor();
    return 'Há $hours horas';
  }

  TransactionStatusStyle transactionStatusStyle(String status) {
    switch (status) {
      case 'approved':
        return const TransactionStatusStyle(
          label: 'Confirmada',
          bgColor: Color(0xFFE6F6EE),
          textColor: Color(0xFF16A34A),
          dotColor: Color(0xFF16A34A),
        );

      case 'rejected':
        return const TransactionStatusStyle(
          label: 'Reprovada',
          bgColor: Color(0xFFFEE2E2),
          textColor: Color(0xFFDC2626),
          dotColor: Color(0xFFDC2626),
        );

      case 'pending':
      default:
        return const TransactionStatusStyle(
          label: 'Em espera',
          bgColor: Color(0xFFFFF6DD),
          textColor: Color(0xFFCA8A04),
          dotColor: Color(0xFFEAB308),
        );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardAsync = ref.watch(partnerDashboardProvider);
    final profileAsync = ref.watch(currentUserProfileProvider);
    final storeAsync = ref.watch(currentPartnerStoreSettingsProvider);

    final name = profileAsync.when(data: (profile) => profile?.name ?? 'Usuário', loading: () => 'Carregando...', error: (_, _) => 'Usuário');
    final logoUrl = storeAsync.when(data: (store) => store?.logoUrl ?? '', loading: () => '', error: (_, _) => '');
    final greeting = getGreeting();

    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      body: dashboardAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text('Erro ao carregar portal: $e')),
        data: (data) {
          return SafeArea(
            top: true,
            bottom: true,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      border: Border(bottom: BorderSide(color: Color(0xFFE6ECF3), width: 1.5)),
                    ),
                    child: Row(
                      children: [
                        SettingsHeaderLogo(logoBytes: null, logoUrl: logoUrl),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            '$greeting, $name',
                            style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w500, color: const Color(0xFF001952)),
                          ),
                        ),
                        //RoundIconButton(svgIcon: "assets/icons/notification-ringing.svg", color: Color(0xFF001952), onTap: () {}),
                      ],
                    ),
                  ),
                  SizedBox(height: AppSpacing.lg),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: SizedBox(
                      width: double.infinity,
                      height: 44,
                      child: ElevatedButton(
                        onPressed: () => context.push('/partner/products/new'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0038BC),
                          foregroundColor: Color(0xFFFFFFFF),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          elevation: 0,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SvgPicture.asset(
                              'assets/icons/basket.svg',
                              width: 18,
                              height: 18,
                              colorFilter: const ColorFilter.mode(Color(0xFFFFFFFF), BlendMode.srcIn),
                            ),
                            SizedBox(width: AppSpacing.sm),
                            Text('Adicionar Novo Produto', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700)),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 18),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'Aqui está o que está acontecendo com sua loja hoje.',
                      style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700, color: const Color(0xFF000000)),
                    ),
                  ),
                  SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.all(14),
                    margin: EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Color(0xFFFFFFFF),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE5E7EB)),
                    ),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Row(
                        spacing: 12,
                        children: [
                          SvgPicture.asset(
                            'assets/icons/calendar-outline.svg',
                            width: 18,
                            height: 18,
                            colorFilter: const ColorFilter.mode(Color(0xFF9CA3AF), BlendMode.srcIn),
                          ),
                          Text(
                            'Últimos 7 dias',
                            style: GoogleFonts.inter(fontSize: 14, color: const Color(0xFF9CA3AF), fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: AppSpacing.md),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: [
                        _SummaryTile(
                          svgIcon: 'assets/icons/dollar.svg',
                          title: 'Vendas Totais',
                          value: brl(data.totalSales),
                          iconBg: const Color(0xFFE6F6EE),
                          iconColor: const Color(0xFF1E9E5A),
                        ),
                        SizedBox(height: AppSpacing.md),
                        _SummaryTile(
                          svgIcon: 'assets/icons/couple.svg',
                          title: 'Clientes Ativos',
                          value: '${data.activeClients}',
                          iconBg: const Color(0xFFE6ECF3),
                          iconColor: const Color(0xFF0038BC),
                        ),
                        SizedBox(height: AppSpacing.md),
                        _SummaryTile(
                          svgIcon: 'assets/icons/update.svg',
                          title: 'Cashback Distribuído',
                          value: brl(data.cashbackDistributed),
                          iconBg: const Color(0xFFFFF6DD),
                          iconColor: const Color(0xFFEAB308),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: AppSpacing.md),
                  Container(
                    padding: const EdgeInsets.all(14),
                    margin: EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Color(0xFFFFFFFF),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE5E7EB)),
                      boxShadow: [BoxShadow(color: const Color(0x140F172A), blurRadius: 12, offset: const Offset(0, 4), spreadRadius: 0)],
                    ),
                    child: Column(
                      children: [
                        Row(
                          spacing: 8,
                          children: [
                            SvgPicture.asset(
                              'assets/icons/clock.svg',
                              width: 18,
                              height: 18,
                              colorFilter: const ColorFilter.mode(Color(0xFFEF8F00), BlendMode.srcIn),
                            ),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'Transações Recentes',
                                style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600, color: const Color(0xFF000000)),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: AppSpacing.md),
                        if (data.recentTransactions.isEmpty)
                          Column(
                            children: [
                              Text(
                                'Nenhuma transação recente',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: const Color(0xFF0F172A)),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Quando um cliente enviar um comprovante para sua loja, ele aparecerá aqui para análise.',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w400, color: const Color(0xFF94A3B8), height: 1.3),
                              ),
                            ],
                          )
                        else
                          ...data.recentTransactions.map(
                                (tx) =>
                                Padding(
                                  key: ValueKey('recent-transaction-${tx.id}'),
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(12),
                                    onTap: () {
                                      showReceiptReviewPop(context, transaction: tx);
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 6),
                                      child: Row(
                                        children: [
                                          CircleAvatar(
                                            radius: 18,
                                            backgroundColor: const Color(0xFFE8EEF9),
                                            child: Text(
                                              tx.initials,
                                              style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600, color: const Color(0xFF0038BC)),
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  tx.customerName,
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                  style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: const Color(0xFF111827)),
                                                ),
                                                const SizedBox(height: 3),
                                                Row(
                                                  children: [
                                                    Text(timeAgo(tx.minutesAgo),
                                                        style: GoogleFonts.inter(fontSize: 11, color: const Color(0xFF94A3B8))),
                                                    const SizedBox(width: 6),
                                                    TransactionStatusChip(style: transactionStatusStyle(tx.status)),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.end,
                                            children: [
                                              Text(
                                                brl(tx.amount),
                                                style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700, color: const Color(0xFF111827)),
                                              ),
                                              Text('+ ${brl(tx.cashback)}', style: GoogleFonts.inter(fontSize: 11, color: const Color(0xFF16A34A))),
                                            ],
                                          ),
                                          const SizedBox(width: 8),
                                          const Icon(Icons.chevron_right_rounded, size: 22, color: Color(0xFF94A3B8)),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                          ),
                      ],
                    ),
                  ),
                  Container(
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.all(16),
                    margin: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE6ECF3),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFF0038BC), width: 1.5),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Suporte ao Parceiro',
                          style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: Color(0xFF0038BC)),
                        ),
                        Text(
                          'Precisa de ajuda com o painel ou pagamentos?',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w400, color: Color(0xFF0038BC)),
                        ),
                        SizedBox(height: AppSpacing.md),
                        SizedBox(
                          height: 32,
                          child: ElevatedButton.icon(
                            onPressed: () => context.push('/partner/support'),
                            style: ButtonStyle(
                              backgroundColor: WidgetStateProperty.all(const Color(0xFF0038BC)),
                              foregroundColor: WidgetStateProperty.all(const Color(0xFFE6ECF3)),
                              elevation: WidgetStateProperty.all(0),
                              padding: WidgetStateProperty.all(const EdgeInsets.symmetric(horizontal: 12)),
                              shape: WidgetStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                              overlayColor: WidgetStateProperty.all(Colors.transparent),
                              shadowColor: WidgetStateProperty.all(Colors.transparent),
                              surfaceTintColor: WidgetStateProperty.all(Colors.transparent),
                            ),
                            icon: SvgPicture.asset(
                              'assets/icons/support.svg',
                              width: 12,
                              height: 12,
                              colorFilter: const ColorFilter.mode(Color(0xFFE6ECF3), BlendMode.srcIn),
                            ),
                            label: const Text('Fale com o Suporte', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w400)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _SummaryTile extends StatelessWidget {
  final String svgIcon;
  final String title;
  final String value;
  final Color iconBg;
  final Color iconColor;

  const _SummaryTile({required this.svgIcon, required this.title, required this.value, required this.iconBg, required this.iconColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [BoxShadow(color: const Color(0x140F172A), blurRadius: 12, offset: const Offset(0, 4), spreadRadius: 0)],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            width: 62,
            height: 62,
            decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(10)),
            padding: const EdgeInsets.all(17),
            child: SvgPicture.asset(svgIcon, width: 18, height: 18, colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn)),
          ),
          SizedBox(width: AppSpacing.md),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                title,
                style: GoogleFonts.inter(fontSize: 14, color: iconColor, fontWeight: FontWeight.w400),
              ),
              Text(
                value,
                style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w700, color: const Color(0xFF0F172A)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
