import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../app/theme/theme_exports.dart';

class CategoryChips extends StatefulWidget {
  final ValueChanged<String?> onChanged;

  const CategoryChips({super.key, required this.onChanged});

  @override
  State<CategoryChips> createState() => CategoryChipsState();
}

class CategoryChipsState extends State<CategoryChips> {
  int selected = 0;
  int? hoveredIndex;

  final items = const [
    'Todos',
    'Alimentação',
    'Moda e acessórios',
    'Beleza e estética',
    'Mercado e conveniência',
    'Saúde e bem-estar',
    'Casa e decoração',
    'Serviços',
    'Educação',
    'Pet shop',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12),
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        separatorBuilder: (_, _) => SizedBox(width: AppSpacing.sm),
        itemBuilder: (context, i) {
          final isSelected = selected == i;
          final isHovering = hoveredIndex == i;

          return MouseRegion(
            cursor: SystemMouseCursors.click,
            onEnter: (_) => setState(() => hoveredIndex = i),
            onExit: (_) => setState(() => hoveredIndex = null),
            child: InkWell(
              borderRadius: BorderRadius.circular(10),
              onTap: () {
                setState(() => selected = i);
                final category = items[i] == 'Todos' ? null : items[i];
                widget.onChanged(category);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFFEF8F00)
                      : isHovering
                      ? const Color(0xFFFFFFFF)
                      : const Color(0xFFFFFFFF),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: isSelected ? const Color(0xFFEF8F00) : const Color(0xFFE6ECF3)),
                  boxShadow: const [BoxShadow(color: Color(0x140F172A), blurRadius: 2, offset: Offset(0, 2))],
                ),
                child: Text(
                  items[i],
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: isSelected
                        ? const Color(0xFFFFFFFF)
                        : isHovering
                        ? const Color(0xFFEF8F00)
                        : const Color(0xFF0F172A),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
