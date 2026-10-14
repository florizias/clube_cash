import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../partners/models/partner_model.dart';

class ProductDropdown extends StatelessWidget {
  final List<PartnerProduct> products;
  final PartnerProduct? selected;
  final ValueChanged<PartnerProduct?> onChanged;

  const ProductDropdown({super.key, required this.products, required this.selected, required this.onChanged});

  String _formatPrice(num value) {
    return 'R\$ ${value.toStringAsFixed(2).replaceAll('.', ',')}';
  }

  @override
  Widget build(BuildContext context) {
    return DropdownSearch<PartnerProduct>(
      selectedItem: selected,
      compareFn: (a, b) => a.id == b.id,
      itemAsString: (product) => product.title,
      items: (filter, infiniteScrollProps) {
        final q = filter.trim().toLowerCase();

        final filtered = q.isEmpty
            ? products
            : products.where((product) {
                return product.title.toLowerCase().contains(q);
              }).toList();

        return filtered.take(8).toList();
      },
      decoratorProps: DropDownDecoratorProps(
        decoration: InputDecoration(
          hintText: products.isEmpty ? 'Nenhum produto cadastrado' : 'Selecionar produto',
          hintStyle: GoogleFonts.inter(color: const Color(0xFF6B7280), fontSize: 14, fontWeight: FontWeight.w400),
          filled: true,
          fillColor: const Color(0xFFFFFFFF),
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFF2563EB), width: 1.4),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFFDC2626), width: 1.2),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFFDC2626), width: 1.4),
          ),
        ),
      ),
      popupProps: PopupProps.menu(
        menuProps: MenuProps(backgroundColor: const Color(0xFFF8FAFC), elevation: 8, borderRadius: BorderRadius.circular(14)),
        showSearchBox: true,
        fit: FlexFit.loose,
        constraints: const BoxConstraints(maxHeight: 280),
        searchFieldProps: TextFieldProps(
          decoration: InputDecoration(
            hintText: 'Pesquisar produto...',
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
              item.title,
              style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: const Color(0xFF0F172A)),
            ),
            subtitle: Text(
              _formatPrice(item.price),
              style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500, color: const Color(0xFF64748B)),
            ),
          );
        },
      ),
      onSelected: onChanged,
      enabled: products.isNotEmpty,
      validator: (value) {
        if (products.isEmpty) return 'Esta loja ainda não possui produtos cadastrados.';
        if (value == null) return 'Selecione um produto.';
        return null;
      },
    );
  }
}
