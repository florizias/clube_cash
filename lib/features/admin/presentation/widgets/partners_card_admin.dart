import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../partners/models/partner_model.dart';
import '../pages/pop_partner_details.dart';

Widget partnerItem({required BuildContext context, required PartnerStore partner, bool showDivider = true}) {
  return InkWell(
    onTap: () {
      showPartnerDetailsPop(context, partner);
    },
    child: Column(
      children: [
        Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                partner.coverImageUrl,
                width: 62,
                height: 62,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) {
                  return Container(
                    width: 62,
                    height: 62,
                    color: const Color(0xFFE6ECF3),
                    child: const Icon(Icons.store, color: Color(0xFF94A3B8)),
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    partner.name,
                    style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700, color: const Color(0xFF0F172A)),
                  ),
                  Text(
                    'ID.: ${partner.storeId}',
                    style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w400, color: const Color(0xFF9CA3AF)),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: Color(0xFF000D26)),
          ],
        ),
        if (showDivider)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(height: 1, color: Color(0xFFE6ECF3)),
          ),
      ],
    ),
  );
}
