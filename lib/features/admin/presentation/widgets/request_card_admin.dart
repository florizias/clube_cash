import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../auth/data/dtos/store_partnership_request_dto.dart';
import '../../../share/functions/get_inicials.dart';
import '../pages/pop_partner_request_details.dart';

Widget requestItem({
  required BuildContext context,
  required StorePartnershipRequestDto request,
  required Future<void> Function() onApprove,
  required Future<void> Function(String reason) onReject,
}) {
  return Padding(
    padding: const EdgeInsets.only(top: 4, bottom: 4),
    child: Row(
      children: [
        CircleAvatar(
          radius: 20,
          backgroundColor: const Color(0xFFEAF1FF),
          child: Text(
            getInitials(request.storeName),
            style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700, color: const Color(0xFF0038BC)),
          ),
        ),
        const SizedBox(width: 12),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                request.storeName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700, color: const Color(0xFF1A1A1A)),
              ),
              const SizedBox(height: 2),
              Text(
                'CNPJ: ${request.cnpj}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w400, color: const Color(0xFF999999)),
              ),
              if (request.category.trim().isNotEmpty) ...[
                const SizedBox(height: 2),
                Text(
                  request.category,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500, color: const Color(0xFF64748B)),
                ),
              ],
            ],
          ),
        ),

        const SizedBox(width: 10),

        SizedBox(
          height: 34,
          child: ElevatedButton(
            onPressed: () async {
              final decision = await showPartnerRequestDetailsPop(context, request);
              if (decision == null) return;
              if (decision.isApproved) {
                await onApprove();
                return;
              }
              if (decision.isRejected) {
                await onReject(decision.rejectionReason);
                return;
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0038BC),
              foregroundColor: const Color(0xFFFFFFFF),
              elevation: 0,
              splashFactory: NoSplash.splashFactory,
              overlayColor: Colors.transparent,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: Text('Detalhes', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w400)),
          ),
        ),
      ],
    ),
  );
}
