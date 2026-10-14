import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../../../app/theme/app_spacing.dart';
import '../../domain/entities/wallet.dart';
import 'customer_purchase_details_pop.dart';
import 'wallet_status_style.dart';

class WalletEntryTile extends StatefulWidget {
  final WalletEntry entry;

  const WalletEntryTile({super.key, required this.entry});

  @override
  State<WalletEntryTile> createState() => WalletEntryTileState();
}

class WalletEntryTileState extends State<WalletEntryTile> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    final entry = widget.entry;
    final isCredit = entry.isCredit;
    final statusStyle = walletStatusStyle(entry.status);

    final bgNormal = Color(0xFFFFFFFF);
    final bgHover = isCredit ? const Color(0xFFEAF8F0) : const Color(0xFFFCE8E8);
    final bg = _hovering ? bgHover : bgNormal;

    final iconBgNormal = isCredit ? const Color(0xFFBFEAD0) : const Color(0xFFF4B9B9);
    final iconBgHover = isCredit ? const Color(0xFF1E9E5A) : const Color(0xFFC0392B);
    final iconFgNormal = isCredit ? const Color(0xFF459A33) : const Color(0xFFC0392B);
    final iconFgHover = isCredit ? const Color(0xFFE6F6EE) : const Color(0xFFFCEAEA);
    final iconBg = _hovering ? iconBgHover : iconBgNormal;
    final iconFg = _hovering ? iconFgHover : iconFgNormal;

    final amountText = '${isCredit ? '+ ' : '- '}R\$ ${entry.amount.toStringAsFixed(2).replaceAll('.', ',')}';
    final amountColor = statusStyle.textColor;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: InkWell(
        onTap: () {
          showCustomerPurchaseDetailsPop(context, entry: entry);
        },
        borderRadius: BorderRadius.circular(14),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: _hovering ? (isCredit ? const Color(0xFFBFEAD0) : const Color(0xFFF4B9B9)) : const Color(0xFFE5E7EB)),
            boxShadow: _hovering ? [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 12, offset: const Offset(0, 6))] : [],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
                child: Icon(isCredit ? Icons.south_west : Icons.north_east, size: 18, color: iconFg),
              ),
              SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 2),
                    Text(
                      entry.title,
                      style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w400, color: const Color(0xFF9CA3AF)),
                    ),
                    SizedBox(height: 2),
                    Text(
                      entry.date,
                      style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w400, color: const Color(0xFF9CA3AF)),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 10),
              Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(color: statusStyle.bgColor, borderRadius: BorderRadius.circular(999)),
                    child: Text(
                      statusStyle.label,
                      style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w700, color: statusStyle.textColor),
                    ),
                  ),
                  Text(
                    amountText,
                    style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w500, color: amountColor),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
