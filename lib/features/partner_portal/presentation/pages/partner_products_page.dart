import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../app/theme/theme_exports.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../share/widgets_exports.dart';
import '../../data/model/partner_product_model.dart';
import '../providers/partner_products_provider.dart';
import '../providers/partner_store_settings_provider.dart';
import '../widgets/product_image_thumb.dart';
import '../widgets/settings_header_logo.dart';

class PartnerProductsPage extends ConsumerStatefulWidget {
  const PartnerProductsPage({super.key});

  @override
  ConsumerState<PartnerProductsPage> createState() => _PartnerProductsPageState();
}

class _PartnerProductsPageState extends ConsumerState<PartnerProductsPage> {
  final TextEditingController _searchCtrl = TextEditingController();
  String _search = '';
  bool _showAll = false;

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<PartnerProductModel> _filterProducts(List<PartnerProductModel> items) {
    final filtered = items.where((p) {
      final q = _search.trim().toLowerCase();
      if (q.isEmpty) return true;
      return p.name.toLowerCase().contains(q) || p.description.toLowerCase().contains(q);
    }).toList();

    if (_showAll) return filtered;
    return filtered.take(5).toList();
  }

  @override
  Widget build(BuildContext context) {
    final productsAsync = ref.watch(partnerProductsProvider);
    final storeAsync = ref.watch(currentPartnerStoreSettingsProvider);
    final profileAsync = ref.watch(currentUserProfileProvider);
    final greeting = getGreeting();

    final name = profileAsync.when(data: (profile) => profile?.name ?? 'Usuário', loading: () => 'Carregando...', error: (_, _) => 'Usuário');
    final logoUrl = storeAsync.when(data: (store) => store?.logoUrl ?? '', loading: () => '', error: (_, _) => '');

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        top: true,
        bottom: true,
        child: productsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, s) => Center(child: Text('Erro ao carregar produtos', style: GoogleFonts.inter())),
          data: (products) {
            final visibleProducts = _filterProducts(products);

            final filteredCount = products.where((p) {
              final q = _search.trim().toLowerCase();
              if (q.isEmpty) return true;
              return p.name.toLowerCase().contains(q) || p.description.toLowerCase().contains(q);
            }).length;

            final hasMore = filteredCount > 5 && !_showAll;

            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: const BoxDecoration(
                      border: Border(bottom: BorderSide(color: Color(0xFFE6ECF3), width: 1.5)),
                    ),
                    child: Row(
                      children: [
                        SettingsHeaderLogo(logoBytes: null, logoUrl: logoUrl),
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
                  const SizedBox(height: 14),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'Gerenciamento de Produtos',
                      style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.w700, color: const Color(0xFF000000)),
                    ),
                  ),
                  SizedBox(height: AppSpacing.xs),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'Adicione, edite ou remova produtos do seu catálogo.',
                      style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w400, color: const Color(0xFF9CA3AF)),
                    ),
                  ),
                  const SizedBox(height: 14),
                  _buildAddButton(),
                  const SizedBox(height: 14),
                  _buildProductsCard(visibleProducts: visibleProducts, hasMore: hasMore),
                  const SizedBox(height: 14),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildAddButton() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      width: double.infinity,
      height: 44,
      child: OutlinedButton.icon(
        onPressed: () => context.push('/partner/products/new'),
        icon: SvgPicture.asset(
          'assets/icons/plus.svg',
          width: 12,
          height: 12,
          colorFilter: const ColorFilter.mode(Color(0xFF0038BC), BlendMode.srcIn),
        ),
        label: Padding(
          padding: EdgeInsetsGeometry.only(left: 8),
          child: Text(
            'Novo Produto',
            style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700, color: const Color(0xFF0F172A)),
          ),
        ),
        style: OutlinedButton.styleFrom(
          backgroundColor: Color(0xFFFFFFFF),
          side: const BorderSide(color: Color(0xFF1D4ED8)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          overlayColor: Colors.transparent,
        ),
      ),
    );
  }

  Widget _buildProductsCard({required List<PartnerProductModel> visibleProducts, required bool hasMore}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
      margin: EdgeInsetsGeometry.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFFAFAF8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEFEAE3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Produtos',
            style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w700, color: const Color(0xFF000000)),
          ),
          SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: Container(
                  alignment: Alignment.center,
                  height: 42,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF2F5),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Color(0xFFE6ECF3)),
                  ),
                  child: TextField(
                    controller: _searchCtrl,
                    onChanged: (value) {
                      setState(() {
                        _search = value;
                        _showAll = false;
                      });
                    },
                    style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF9CA3AF)),
                    decoration: InputDecoration(
                      hintText: 'Digitar...',
                      hintStyle: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF9CA3AF)),
                      prefixIcon: Padding(
                        padding: const EdgeInsets.all(12),
                        child: SvgPicture.asset(
                          'assets/icons/search.svg',
                          width: 18,
                          height: 18,
                          colorFilter: const ColorFilter.mode(Color(0xFF0A56BD), BlendMode.srcIn),
                        ),
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 10),
              InkWell(
                onTap: () {},
                borderRadius: BorderRadius.circular(10),
                child: Padding(
                  padding: EdgeInsets.only(right: 10, left: 30),
                  child: SvgPicture.asset(
                    'assets/icons/filter.svg',
                    width: 18,
                    height: 18,
                    colorFilter: const ColorFilter.mode(Color(0xFF0A56BD), BlendMode.srcIn),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 14),
          if (visibleProducts.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 18),
              child: Center(
                child: Text(
                  'Nenhum produto cadastrado.',
                  style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500, color: const Color(0xFF9CA3AF)),
                ),
              ),
            )
          else
            ...visibleProducts.map(
                  (product) =>
                  Padding(
                    key: ValueKey('product-padding-${product.id}'),
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _PartnerProductsTile(key: ValueKey('product-tile-${product.id}'), product: product),
                  ),
            ),
          if (hasMore)
            SizedBox(
              width: double.infinity,
              height: 36,
              child: OutlinedButton(
                onPressed: () {
                  setState(() {
                    _showAll = true;
                  });
                },
                style: OutlinedButton.styleFrom(
                  backgroundColor: const Color(0xFFF8FAFC),
                  side: const BorderSide(color: Color(0xFFD1D5DB)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Ver mais',
                      style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: const Color(0xFF1D4ED8)),
                    ),
                    SizedBox(width: AppSpacing.sm),
                    const Icon(Icons.chevron_right_rounded, size: 20, color: Color(0xFF1D4ED8)),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _PartnerProductsTile extends StatelessWidget {
  final PartnerProductModel product;

  const _PartnerProductsTile({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        context.push('/partner/products/${product.id}');
      },
      child: Container(
        padding: EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: const Color(0xFFE5E7EB), width: 1)),
          //boxShadow: [BoxShadow(color: const Color(0x140F172A), blurRadius: 12, offset: const Offset(0, 4), spreadRadius: 0)],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: SizedBox(
                width: 62,
                height: 62,
                child: ProductImageThumb(key: ValueKey('product-image-${product.id}-${product.imageUrl}'), imageUrl: product.imageUrl),
              ),
            ),
            SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600, color: const Color(0xFF0F172A)),
                  ),
                  SizedBox(height: 2),
                  Text(
                    product.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w400, color: const Color(0xFF9CA3AF), height: 1.2),
                  ),
                ],
              ),
            ),
            SizedBox(width: AppSpacing.sm),
            const Icon(Icons.chevron_right, size: 30, color: Color(0xFF000D26)),
          ],
        ),
      ),
    );
  }
}
