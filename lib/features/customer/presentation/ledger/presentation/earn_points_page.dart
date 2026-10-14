import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../../app/theme/app_spacing.dart';
import '../../../../../core/widgets/app_search_field.dart';
import '../../../../partners/models/partner_model.dart';
import '../../../../partners/presentation/providers/partner_stores_provider.dart';
import 'widgets/earn_partner_tile.dart';
import 'widgets/earn_purchase_dialog.dart';

EarnPartnerItem mapPartnerToEarn(PartnerStore partner) {
  return EarnPartnerItem(
    id: partner.id,
    name: partner.name,
    cashbackText: 'Dinheiro de volta: ${partner.cashbackLabel.toStringAsFixed(0)}%',
    logo: ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: partner.logoUrl.trim().isEmpty
          ? const LogoPlaceholder(color: Color(0xFF6A1B9A))
          : Image.network(
              partner.logoUrl,
              width: 40,
              height: 40,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) {
                return const LogoPlaceholder(color: Color(0xFF6A1B9A));
              },
            ),
    ),
  );
}

class EarnPointsPage extends ConsumerStatefulWidget {
  const EarnPointsPage({super.key});

  @override
  ConsumerState<EarnPointsPage> createState() => _EarnPointsPageState();
}

class _EarnPointsPageState extends ConsumerState<EarnPointsPage> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final partnersAsync = ref.watch(partnerStoresProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      appBar: AppBar(
        backgroundColor: const Color(0xFF001952),
        elevation: 0,
        automaticallyImplyLeading: false,
        leadingWidth: 32,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16),
          child: InkWell(
            onTap: () => Navigator.of(context).pop(),
            borderRadius: BorderRadius.circular(24),
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            hoverColor: Colors.transparent,
            focusColor: Colors.transparent,
            child: SizedBox(
              width: 10,
              height: 10,
              child: SvgPicture.asset(
                'assets/icons/arrow-back.svg',
                fit: BoxFit.contain,
                colorFilter: const ColorFilter.mode(Color(0xFFFFFFFF), BlendMode.srcIn),
              ),
            ),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Text(
                'Ganhar pontos',
                style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600, color: const Color(0xFFFFFFFF)),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        top: true,
        bottom: true,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
          children: [
            SearchField(
              hint: 'Procurando alguma loja?',
              onChanged: (value) {
                setState(() {
                  _query = value;
                });
              },
            ),

            SizedBox(height: AppSpacing.md),

            Text(
              'Lojas parceiras',
              style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w400, color: const Color(0xFF000000)),
            ),

            SizedBox(height: AppSpacing.md),

            partnersAsync.when(
              loading: () => const Padding(
                padding: EdgeInsets.all(24),
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (_, _) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Text(
                  'Não foi possível carregar as lojas parceiras.',
                  style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500, color: Colors.red),
                ),
              ),
              data: (partners) {
                final filteredPartners = partners.where((partner) {
                  final query = _query.trim().toLowerCase();

                  if (query.isEmpty) return true;

                  return partner.name.toLowerCase().contains(query) ||
                      partner.category.toLowerCase().contains(query) ||
                      partner.subCategory.toLowerCase().contains(query);
                }).toList();

                if (filteredPartners.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Text(
                      'Nenhuma loja parceira encontrada.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500, color: const Color(0xFF9CA3AF)),
                    ),
                  );
                }

                return Column(
                  children: filteredPartners.map((partner) {
                    final item = mapPartnerToEarn(partner);

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: EarnPartnerCard(
                        store: item,
                        onTap: () {
                          showEarnPurchaseDialog(context, partner: partner);
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
    );
  }
}
