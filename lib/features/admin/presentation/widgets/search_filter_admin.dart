import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/widgets/app_search_field.dart';

Widget searchFilter({required ValueChanged<String> onSearchChanged, required ValueChanged<String> onStatusChanged, required String selectedStatus}) {
  return Row(
    children: [
      Expanded(
        child: SearchField(hint: 'Digitar...', onChanged: onSearchChanged),
      ),

      const SizedBox(width: 10),

      Container(
        height: 42,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: const Color(0xFFFFFFFF),
          borderRadius: BorderRadius.circular(100),
          border: Border.all(color: const Color(0xFFE6ECF3)),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: selectedStatus,
            borderRadius: BorderRadius.circular(14),
            icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF0038BC)),
            style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500, color: const Color(0xFF64748B)),
            dropdownColor: Color(0xFFFFFFFF),
            items: const [
              DropdownMenuItem(value: 'active', child: Text('Ativos')),
              DropdownMenuItem(value: 'inactive', child: Text('Inativos')),
              DropdownMenuItem(value: 'rejected', child: Text('Recusados')),
            ],
            onChanged: (value) {
              if (value == null) return;
              onStatusChanged(value);
            },
          ),
        ),
      ),
    ],
  );
}
