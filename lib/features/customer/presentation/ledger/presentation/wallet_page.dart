import 'package:clubcash/app/theme/app_text_styles.dart';
import 'package:clubcash/features/customer/presentation/ledger/presentation/providers/customer_wallet_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../../app/theme/app_spacing.dart';
import '../../../../../core/widgets/app_search_field.dart';
import '../../../../home/presentation/widgets/points_card.dart';
import '../../../../share/functions/order_date.dart';
import '../../purchases/data/dtos/purchase_dto.dart';
import '../../purchases/presentation/providers/purchase_requests_provider.dart';
import '../domain/entities/wallet.dart';
import 'widgets/button_primary.dart';
import 'widgets/button_secondary.dart';
import 'widgets/wallet_card.dart';

class WalletPage extends ConsumerStatefulWidget {
  const WalletPage({super.key});

  @override
  ConsumerState<WalletPage> createState() => _WalletPageState();
}

class _WalletPageState extends ConsumerState<WalletPage> {
  String searchQuery = '';

  String _formatPoints(dynamic points) {
    return '$points pontos';
  }

  String _formatMoney(double value) {
    final formatted = value.toStringAsFixed(2).replaceAll('.', ',');
    return 'R\$ $formatted';
  }

  String _dateBr(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();

    return '$day/$month/$year';
  }

  WalletEntry _mapPurchaseRequestToWalletEntry(PurchaseRequestDto request) {
    return WalletEntry(
      id: request.id,
      title: request.partnerName.isNotEmpty ? request.partnerName : 'Compra enviada',
      date: _dateBr(request.createdAt),
      amount: request.cashbackValue,
      isCredit: request.status != 'rejected',
      highlighted: request.status == 'approved',
      status: request.status,
      partnerName: request.partnerName,
      nfCode: request.nfCode,
      receiptImageUrl: request.receiptImageUrl,
      rejectionReason: request.rejectionReason,
      purchaseValue: request.purchaseValue,
      cashbackValue: request.cashbackValue,
    );
  }

  @override
  Widget build(BuildContext context) {
    final walletAsync = ref.watch(currentCustomerWalletProvider);
    final purchaseRequestsAsync = ref.watch(userPurchaseRequestsProvider);

    return SafeArea(
      top: true,
      bottom: true,
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Stack(
              children: [
                Container(height: 110, decoration: const BoxDecoration(color: Color(0xFF001952))),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text('Carteira', style: AppTextStyles.body.copyWith(color: const Color(0xFFFFFFFF))),
                          ),
                          SvgPicture.asset('assets/icons/wallet2.svg', colorFilter: const ColorFilter.mode(Color(0xFFFFFFFF), BlendMode.srcIn)),
                          const SizedBox(width: 10),
                        ],
                      ),
                      const SizedBox(height: 14),

                      walletAsync.when(
                        loading: () => const SizedBox(
                          height: 96,
                          child: Center(child: CircularProgressIndicator(color: Color(0xFFFFFFFF))),
                        ),
                        error: (_, _) => PointsCardUser(points: '0 pontos', label: 'Saldo de Pontos', estimatedValue: 'R\$ 0,00', progress: 0),
                        data: (wallet) {
                          final availablePoints = wallet?.availablePoints ?? 0;
                          final availableValue = wallet?.availableCashbackValue ?? 0;

                          final progress = (availablePoints / 5000).clamp(0.0, 1.0);

                          return PointsCardUser(
                            points: _formatPoints(availablePoints),
                            label: 'Saldo de Pontos',
                            estimatedValue: _formatMoney(availableValue),
                            progress: progress,
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  purchaseRequestsAsync.when(
                    loading: () => const SizedBox.shrink(),
                    error: (_, _) => const SizedBox.shrink(),
                    data: (requests) {
                      final pendingRequests = requests.where((request) {
                        return request.status.toLowerCase() == 'pending';
                      }).toList();

                      final pendingPoints = pendingRequests.fold<double>(0, (sum, request) {
                        return sum + request.cashbackAmount;
                      });

                      final pendingValue = pendingRequests.fold<double>(0, (sum, request) {
                        return sum + request.cashbackValue;
                      });

                      if (pendingRequests.isEmpty || (pendingPoints <= 0 && pendingValue <= 0)) {
                        return const SizedBox.shrink();
                      }

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF7E8),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: const Color(0xFFEF8F00)),
                          ),
                          child: Text(
                            'Você tem ${_formatPoints(pendingPoints)} em análise (${_formatMoney(pendingValue)}).',
                            style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: const Color(0xFF9A5A00)),
                          ),
                        ),
                      );
                    },
                  ),

                  Row(
                    children: [
                      Expanded(
                        child: SecondaryButton(label: 'Ganhar pontos', onTap: () => context.push('/earnpoints')),
                      ),
                      SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: SecondaryButton(label: 'Trocar pontos', onTap: () {}),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  PrimaryButton(label: 'Resgate seus pontos por dinheiro', onTap: () {}),

                  SizedBox(height: AppSpacing.xl),

                  Text(
                    'Extrato',
                    style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w400, color: const Color(0xFF000000)),
                  ),

                  SizedBox(height: AppSpacing.md),

                  Row(
                    children: [
                      Expanded(
                        child: SearchField(
                          hint: 'Digitar...',
                          onChanged: (value) {
                            setState(() {
                              searchQuery = value;
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      InkWell(
                        splashColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        hoverColor: Colors.transparent,
                        focusColor: Colors.transparent,
                        onTap: () {},
                        child: SvgPicture.asset('assets/icons/filter.svg', colorFilter: const ColorFilter.mode(Color(0xFF0038BC), BlendMode.srcIn)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          purchaseRequestsAsync.when(
            loading: () => const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Center(child: CircularProgressIndicator()),
              ),
            ),
            error: (_, _) => SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text('Não foi possível carregar o extrato.', style: GoogleFonts.inter(fontSize: 13, color: Colors.red)),
              ),
            ),
            data: (requests) {
              final entries = requests.map(_mapPurchaseRequestToWalletEntry).where((entry) {
                final query = searchQuery.trim().toLowerCase();

                if (query.isEmpty) return true;

                return entry.title.toLowerCase().contains(query) ||
                    entry.date.toLowerCase().contains(query) ||
                    entry.amount.toStringAsFixed(2).contains(query) ||
                    entry.status.toLowerCase().contains(query);
              }).toList();

              entries.sort((a, b) {
                final dateA = parseDate(a.date);
                final dateB = parseDate(b.date);
                return dateB.compareTo(dateA);
              });

              if (entries.isEmpty) {
                return SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                    child: Text(
                      'Nenhuma movimentação encontrada.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500, color: const Color(0xFF9CA3AF)),
                    ),
                  ),
                );
              }

              return SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 18),
                sliver: SliverList.separated(
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemCount: entries.length,
                  itemBuilder: (context, index) {
                    return WalletEntryTile(entry: entries[index]);
                  },
                ),
              );
            },
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 16)),
        ],
      ),
    );
  }
}
