import 'package:clubcash/features/partners/presentation/widgets/pop_register_review.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../app/theme/app_spacing.dart';
import '../../auth/presentation/providers/auth_providers.dart';
import '../models/partner_model.dart';

class TabReviewPartner extends ConsumerWidget {
  final PartnerStore partner;
  final String cashbackLabel;

  const TabReviewPartner({super.key, required this.partner, required this.cashbackLabel});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoggedIn = ref.watch(isLoggedInProvider);
    final visibleReviews = partner.reviews.where((review) {
      return review.status == 'active';
    }).toList();

    final reviewCount = partner.ratingCount > 0 ? partner.ratingCount : visibleReviews.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: const Color(0xFF001952), borderRadius: BorderRadius.circular(14)),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Média Geral',
                      style: GoogleFonts.inter(color: const Color(0xFFFFFFFF), fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    Text(
                      'Baseado em $reviewCount opiniões',
                      style: GoogleFonts.inter(color: const Color(0xFF9CA3AF), fontSize: 12, fontWeight: FontWeight.w400),
                    ),
                  ],
                ),
              ),
              Column(
                children: [
                  Row(
                    children: [
                      Text(
                        partner.rating.toStringAsFixed(1),
                        style: GoogleFonts.inter(color: const Color(0xFFFFFFFF), fontSize: 24, fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(width: 8),
                      SvgPicture.asset(
                        'assets/icons/star.svg',
                        width: 16,
                        height: 16,
                        fit: BoxFit.contain,
                        colorFilter: const ColorFilter.mode(Color(0xFFEF8F00), BlendMode.srcIn),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Stars(rating: partner.rating),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        if (isLoggedIn)
          InkWell(
            onTap: () => showRegisterReviewPop(context, partner),
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            hoverColor: Colors.transparent,
            focusColor: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFFFFFFF),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE6ECF3)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgPicture.asset(
                    'assets/icons/send_review.svg',
                    width: 16,
                    height: 16,
                    fit: BoxFit.contain,
                    colorFilter: const ColorFilter.mode(Color(0xFF001952), BlendMode.srcIn),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Escreva uma Avaliação',
                    style: GoogleFonts.inter(color: const Color(0xFF0F172A), fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ),

        const SizedBox(height: 24),

        Text(
          'Avaliações',
          style: GoogleFonts.inter(color: const Color(0xFF000000), fontSize: 14, fontWeight: FontWeight.w400),
        ),

        const SizedBox(height: 10),

        if (visibleReviews.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
            decoration: BoxDecoration(
              color: const Color(0xFFFFFFFF),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE6ECF3)),
            ),
            child: Text(
              'Ainda não há avaliações para esta loja.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(color: const Color(0xFF9CA3AF), fontWeight: FontWeight.w500, fontSize: 13),
            ),
          )
        else
          ...visibleReviews.map((review) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: ReviewCard(review: review),
            );
          }),
      ],
    );
  }
}

class ReviewCard extends StatelessWidget {
  final PartnerReview review;

  const ReviewCard({super.key, required this.review});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 100),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE6ECF3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const SizedBox(
                width: 30,
                height: 30,
                child: CircleAvatar(
                  radius: 16,
                  backgroundColor: Color(0xFFF1F5F9),
                  child: Icon(Icons.person, color: Color(0xFF64748B), size: 18),
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.userName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(color: const Color(0xFF0F172A), fontSize: 14, fontWeight: FontWeight.w600),
                    ),
                    Text(
                      _dateBr(review.createdAt),
                      style: GoogleFonts.inter(color: const Color(0xFF6B7280), fontSize: 10, fontWeight: FontWeight.w400),
                    ),
                  ],
                ),
              ),

              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: const Color(0xFFFFF4D6), borderRadius: BorderRadius.circular(100)),
                child: Row(
                  children: [
                    Text(
                      review.rating.toStringAsFixed(1),
                      style: GoogleFonts.inter(color: const Color(0xFFE0B84C), fontSize: 12, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(width: 4),
                    SvgPicture.asset(
                      'assets/icons/star.svg',
                      width: 8,
                      height: 8,
                      fit: BoxFit.contain,
                      colorFilter: const ColorFilter.mode(Color(0xFFE0B84C), BlendMode.srcIn),
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: AppSpacing.md),

          Text(
            review.comment,
            style: GoogleFonts.inter(color: const Color(0xFF000000), fontSize: 12, fontWeight: FontWeight.w400, height: 1.35),
          ),
        ],
      ),
    );
  }

  static String _dateBr(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();

    return '$day/$month/$year';
  }
}

class Stars extends StatelessWidget {
  final double rating;

  const Stars({super.key, required this.rating});

  @override
  Widget build(BuildContext context) {
    final normalizedRating = rating.clamp(0, 5);
    final full = normalizedRating.floor();
    final half = (normalizedRating - full) >= 0.5 ? 1 : 0;
    final empty = 5 - full - half;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (int i = 0; i < full; i++) const Icon(Icons.star_rounded, size: 16, color: Color(0xFFF59E0B)),
        if (half == 1) const Icon(Icons.star_half_rounded, size: 16, color: Color(0xFFF59E0B)),
        for (int i = 0; i < empty; i++) const Icon(Icons.star_border_rounded, size: 16, color: Color(0xFFF59E0B)),
      ],
    );
  }
}
