import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import 'providers/partner_stores_provider.dart';
import 'tab_about_partner.dart';
import 'tab_product_partner.dart';
import 'tab_review_partner.dart';
import 'widgets/cover_partner.dart';

class PartnerPage extends ConsumerStatefulWidget {
  final String storeId;
  final String? partnerUID;

  const PartnerPage({super.key, required this.storeId, this.partnerUID});

  @override
  ConsumerState<PartnerPage> createState() => _PartnerPageState();
}

class _PartnerPageState extends ConsumerState<PartnerPage> {
  int _tabIndex = 0;

  @override
  Widget build(BuildContext context) {
    final partnerAsync = widget.partnerUID != null && widget.partnerUID!.trim().isNotEmpty
        ? ref.watch(partnerByIdProvider(widget.partnerUID!))
        : ref.watch(partnerByStoreIdProvider(widget.storeId));

    return partnerAsync.when(
      loading: () {
        return const Scaffold(
          backgroundColor: Color(0xFFFFFFFF),
          body: Center(child: CircularProgressIndicator()),
        );
      },
      error: (error, stackTrace) {
        return Scaffold(
          backgroundColor: const Color(0xFFFFFFFF),
          body: SafeArea(
            top: true,
            bottom: true,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Não foi possível carregar os dados do parceiro.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.red),
                ),
              ),
            ),
          ),
        );
      },
      data: (partner) {
        if (partner == null) {
          return Scaffold(
            backgroundColor: const Color(0xFFFFFFFF),
            body: SafeArea(
              top: true,
              bottom: true,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    'Parceiro não encontrado.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500, color: const Color(0xFF64748B)),
                  ),
                ),
              ),
            ),
          );
        }

        final cashbackLabel = '${partner.cashbackLabel.toStringAsFixed(0)}% de cashback';

        return Scaffold(
          backgroundColor: const Color(0xFFFFFFFF),
          body: SafeArea(
            top: true,
            bottom: true,
            child: CustomScrollView(
              slivers: [
                SliverAppBar(
                  automaticallyImplyLeading: false,
                  pinned: false,
                  expandedHeight: 200,
                  backgroundColor: Colors.transparent,
                  surfaceTintColor: Colors.transparent,
                  flexibleSpace: CoverPartner(partner: partner),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 12)),
                SliverToBoxAdapter(
                  child: Row(
                    children: [
                      Expanded(
                        child: _TopTab(
                          label: 'Produtos',
                          selected: _tabIndex == 0,
                          onTap: () {
                            setState(() {
                              _tabIndex = 0;
                            });
                          },
                        ),
                      ),
                      Expanded(
                        child: _TopTab(
                          label: 'Avaliação',
                          selected: _tabIndex == 1,
                          onTap: () {
                            setState(() {
                              _tabIndex = 1;
                            });
                          },
                        ),
                      ),
                      Expanded(
                        child: _TopTab(
                          label: 'Sobre',
                          selected: _tabIndex == 2,
                          onTap: () {
                            setState(() {
                              _tabIndex = 2;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                    child: Column(
                      spacing: 12,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(width: 12),
                        if (_tabIndex == 0) TabProductPartner(partner: partner),
                        if (_tabIndex == 1) TabReviewPartner(partner: partner, cashbackLabel: cashbackLabel),
                        if (_tabIndex == 2) TabAboutPartner(partner: partner, cashbackLabel: cashbackLabel),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _TopTab extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _TopTab({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      hoverColor: Colors.transparent,
      focusColor: Colors.transparent,
      child: AnimatedContainer(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        duration: const Duration(milliseconds: 180),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: selected ? const Color(0xFFEF8F00) : const Color(0xFFEFEAE3), width: 1.5)),
        ),
        child: Center(
          child: Text(
            label,
            style: GoogleFonts.inter(color: selected ? const Color(0xFF0F172A) : const Color(0x291F2933), fontSize: 14, fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }
}
