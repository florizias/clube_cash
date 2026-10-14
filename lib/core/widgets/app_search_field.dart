import 'package:clubcash/app/theme/app_colors.dart';
import 'package:flutter/material.dart';

import '../../app/theme/app_text_styles.dart';

class SearchField extends StatelessWidget {
  final String hint;
  final ValueChanged<String> onChanged;

  const SearchField({super.key, required this.hint, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE6ECF3)),
        //boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 2, offset: const Offset(0, 1))],
      ),
      child: Row(
        spacing: 16,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Icon(Icons.search, size: 28, color: Color(0xFF0A56BD)),
          Expanded(
            child: SizedBox(
              height: 30,
              child: TextField(
                cursorColor: AppColors.cursor,
                textAlignVertical: TextAlignVertical.center,
                style: AppTextStyles.body,
                decoration: InputDecoration(
                  isDense: true,
                  hintText: hint,
                  hintStyle: AppTextStyles.bodySmall,
                  contentPadding: EdgeInsets.zero,
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  errorBorder: InputBorder.none,
                  disabledBorder: InputBorder.none,
                ),
                onChanged: onChanged,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
