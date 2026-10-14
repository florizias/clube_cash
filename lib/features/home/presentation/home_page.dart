import 'package:clubcash/app/theme/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../app/theme/app_spacing.dart';
import '../../../app/variables.dart';
import '../../../core/constants/rewards_config.dart';
import '../../../core/helper/first_name.dart';
import '../../../core/location/user_location_helper.dart';
import '../../../core/widgets/app_search_field.dart';
import '../../admin/presentation/providers/admin_ads_provider.dart';
import '../../auth/presentation/providers/auth_providers.dart';
import '../../customer/presentation/ledger/presentation/providers/customer_wallet_provider.dart';
import '../../partners/presentation/providers/partner_stores_provider.dart';
import '../../share/functions/get_greeting_hour.dart';
import 'widgets/category_chips.dart';
import 'widgets/home_header_avatar.dart';
import 'widgets/news_carousel.dart';
import 'widgets/partner_card.dart';
import 'widgets/points_card.dart';
import 'widgets/round_icon_button.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  String? selectedCategory;
  String searchQuery = '';
  bool _isLoadingLocation = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadUserLocation();
    });
  }

  Future<void> _loadUserLocation() async {
    if (_isLoadingLocation) return;

    setState(() {
      _isLoadingLocation = true;
    });

    final location = await UserLocationHelper.getCurrentLocation();

    if (!mounted) return;

    if (location != null) {
      Variables.latitudeLocal = location.latitude;
      Variables.longitudeLocal = location.longitude;

      if (location.address
          .trim()
          .isNotEmpty) {
        Variables.addressLocal = location.address;
      }

      debugPrint('USER LAT: ${location.latitude}');
      debugPrint('USER LNG: ${location.longitude}');
      debugPrint('USER ADDRESS: ${location.address}');
    }

    setState(() {
      _isLoadingLocation = false;
    });
  }

  Future<void> _openAdLink(Map<String, dynamic> item) async {
    final link = item['buttonLink']?.toString().trim() ?? '';
    if (link.isEmpty) return;
    if (link.startsWith('/')) {
      context.go(link);
      return;
    }
    final uri = Uri.tryParse(link);
    if (uri == null || !uri.hasScheme) return;
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(currentUserProfileProvider);
    final walletAsync = ref.watch(currentCustomerWalletProvider);
    final adsAsync = ref.watch(activeAdsProvider);
    final partnersAsync = ref.watch(partnerStoresProvider);
    final isLoggedIn = ref.watch(isLoggedInProvider);
    final greeting = getGreeting();
    final name = profileAsync.when(data: (profile) => firstNameFrom(profile?.name ?? ''), loading: () => '', error: (_, _) => '');
    final photoUrl = profileAsync.when(data: (profile) => profile?.photoUrl ?? '', loading: () => '', error: (_, _) => '');

    return SafeArea(
      top: true,
      bottom: true,
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Stack(
              children: [
                Container(height: 130, decoration: const BoxDecoration(color: Color(0xFF001952))),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          if (isLoggedIn)
                            if (isLoggedIn) HomeHeaderAvatar(photoUrl: photoUrl),
                          SizedBox(width: AppSpacing.sm),
                          if (isLoggedIn)
                            Expanded(
                              child: Text('$greeting, $name', style: AppTextStyles.body.copyWith(color: Color(0xFFFFFFFF))),
                            )
                          else
                            InkWell(
                              onTap: () => context.go('/login'),
                              borderRadius: BorderRadius.circular(100),
                              splashColor: Colors.transparent,
                              highlightColor: Colors.transparent,
                              hoverColor: Colors.transparent,
                              focusColor: Colors.transparent,
                              child: Container(
                                padding: AppPadding.symetricLG,
                                decoration: BoxDecoration(color: Color(0xFFEF8F00), borderRadius: BorderRadius.circular(100)),
                                child: Row(
                                  spacing: AppSpacing.sm,
                                  children: [
                                    Text(
                                      "Crie sua conta ou faça login",
                                      style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: const Color(0xFFEFEAE3)),
                                    ),
                                    SvgPicture.asset(
                                      "assets/icons/logout-rounded.svg",
                                      width: 20,
                                      height: 20,
                                      colorFilter: const ColorFilter.mode(Color(0xFFEFEAE3), BlendMode.srcIn),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          const Spacer(),
                          //if (isLoggedIn) RoundIconButton(svgIcon: "assets/icons/notification-ringing.svg", onTap: () {}),
                          SizedBox(width: AppSpacing.sm),
                          RoundIconButton(svgIcon: "assets/icons/support.svg", onTap: () => context.go('/help-support')),
                        ],
                      ),
                      SizedBox(height: 14),
                      if (isLoggedIn)
                        walletAsync.when(
                          loading: () =>
                          const SizedBox(
                            height: 96,
                            child: Center(child: CircularProgressIndicator(color: Color(0xFFFFFFFF))),
                          ),
                          error: (_, _) => PointsCardUser(points: '0 pontos', label: 'Saldo de Pontos', estimatedValue: 'R\$ 0,00', progress: 0),
                          data: (wallet) {
                            final points = wallet?.availablePoints ?? 0;
                            final value = RewardsConfig.pointsToCashbackValue(points);

                            final formattedValue = value.toStringAsFixed(2).replaceAll('.', ',');
                            final progress = (points / 5000).clamp(0.0, 1.0);

                            return PointsCardUser(
                              points: '$points pontos',
                              label: 'Saldo de Pontos',
                              estimatedValue: 'R\$ $formattedValue',
                              progress: progress,
                            );
                          },
                        )
                      else
                        const PointsCard(),
                      SizedBox(height: AppSpacing.lg),
                    ],
                  ),
                ),
              ],
            ),
          ),
          adsAsync.when(
            loading: () =>
            const SliverToBoxAdapter(
              child: SizedBox(height: 180, child: Center(child: CircularProgressIndicator())),
            ),
            error: (error, stackTrace) =>
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Text(
                      'Erro ao carregar novidades.',
                      style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500, color: Colors.red),
                    ),
                  ),
                ),
            data: (ads) {
              final activeAds = ads.where((ad) => ad.isActive).toList();
              if (activeAds.isEmpty) {
                return const SliverToBoxAdapter(child: SizedBox.shrink());
              }
              final adsJson = activeAds.map((ad) {
                return {
                  'id': ad.id,
                  'tag': 'Destaque',
                  'title': ad.title,
                  'buttonText': ad.buttonText,
                  'buttonLink': ad.buttonLink,
                  'thumbnailUrl': ad.imageURL,
                };
              }).toList();
              return SliverToBoxAdapter(
                child: NewsCarousel(headerTitle: 'Novidades Conever', itemsJson: adsJson, onTapItem: _openAdLink),
              );
            },
          ),
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 14),
                if (isLoggedIn)
                  Padding(
                    padding: AppPadding.symetricLG,
                    child: SearchField(
                      hint: 'Procurando alguma loja?',
                      onChanged: (v) {
                        setState(() {
                          searchQuery = v.toLowerCase();
                        });
                      },
                    ),
                  ),
                if (isLoggedIn) SizedBox(height: AppSpacing.md),
                if (isLoggedIn)
                  CategoryChips(
                    onChanged: (category) {
                      setState(() {
                        selectedCategory = category;
                      });
                    },
                  ),
                SizedBox(height: AppSpacing.md),
                Padding(
                  padding: AppPadding.symetricLG,
                  child: Text(
                    'Lojas parceiras',
                    style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w400, color: const Color(0xFF000000)),
                  ),
                ),
              ],
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            sliver: partnersAsync.when(
              loading: () =>
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Center(child: CircularProgressIndicator()),
                ),
              ),
              error: (error, stackTrace) =>
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: Text(
                        'Erro ao carregar lojas parceiras.',
                        style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500, color: Colors.red),
                      ),
                    ),
                  ),
              data: (partners) {
                final filteredPartners = partners.where((partner) {
                  final matchesCategory = selectedCategory == null || partner.category == selectedCategory;

                  final matchesSearch = searchQuery.isEmpty || partner.name.toLowerCase().contains(searchQuery.toLowerCase());

                  return matchesCategory && matchesSearch;
                }).toList();

                if (filteredPartners.isEmpty) {
                  return SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                      child: Text(
                        'Nenhuma loja parceira encontrada.',
                        style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500, color: const Color(0xFF64748B)),
                      ),
                    ),
                  );
                }

                return SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  sliver: SliverList.separated(
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemCount: filteredPartners.length,
                    itemBuilder: (context, i) {
                      final partner = filteredPartners[i];

                      return PartnerCard(store: partner, userLatitude: Variables.latitudeLocal, userLongitude: Variables.longitudeLocal);
                    },
                  ),
                );
              },
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 10)),
        ],
      ),
    );
  }
}
