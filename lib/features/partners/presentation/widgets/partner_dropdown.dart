import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../models/partner_model.dart';

class PartnerDropdown extends StatelessWidget {
  final List<PartnerStore> partners;
  final PartnerStore? selected;
  final ValueChanged<PartnerStore?> onChanged;

  const PartnerDropdown({super.key, required this.partners, required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return DropdownSearch<PartnerStore>(
      selectedItem: selected,
      compareFn: (a, b) => a.id == b.id,

      items: (filter, infiniteScrollProps) {
        final q = (filter).trim().toLowerCase();

        final filtered = q.isEmpty ? partners : partners.where((p) => p.name.toLowerCase().contains(q)).toList();

        return filtered.take(5).toList();
      },

      itemAsString: (p) => p.name,

      decoratorProps: DropDownDecoratorProps(
        decoration: InputDecoration(
          hintText: 'Selecionar',
          hintStyle: GoogleFonts.inter(color: const Color(0xFF6B7280), fontSize: 14, fontWeight: FontWeight.w400),
          filled: true,
          fillColor: Color(0xFFFFFFFF),
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFF2563EB), width: 1.4),
          ),
        ),
      ),

      popupProps: PopupProps.menu(
        menuProps: MenuProps(backgroundColor: const Color(0xFFF8FAFC), elevation: 8, borderRadius: BorderRadius.circular(14)),
        showSearchBox: true,
        fit: FlexFit.loose,
        constraints: const BoxConstraints(),

        searchFieldProps: TextFieldProps(
          decoration: InputDecoration(
            hintText: 'Pesquisar estabelecimento...',
            hintStyle: GoogleFonts.inter(color: const Color(0xFF6B7280), fontSize: 14),
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFF2563EB), width: 1.4),
            ),
          ),
        ),

        itemBuilder: (context, item, isSelected, isDisabled) {
          return ListTile(
            dense: true,
            enabled: !isDisabled,
            title: Text(
              item.name,
              style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: const Color(0xFF0F172A)),
            ),
          );
        },
      ),

      onSelected: onChanged,

      validator: (value) => value == null ? 'Selecione um estabelecimento.' : null,
    );
  }
}
