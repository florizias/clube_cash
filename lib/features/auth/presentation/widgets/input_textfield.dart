import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class Input extends StatelessWidget {
  final FocusNode focusNode;
  final TextEditingController controller;
  final String hint;
  final VoidCallback? onTap;
  final ValueChanged<String>? onChanged;
  final bool readOnly;
  final TextInputType? keyboardType;
  final bool obscureText;
  final int? maxLines;
  final Widget? prefix;
  final Widget? suffix;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onFieldSubmitted;
  final String? Function(String?)? validator;
  final List<TextInputFormatter>? inputFormatters;
  final TextStyle? style;

  const Input({
    required this.focusNode,
    required this.controller,
    required this.hint,
    this.onTap,
    this.onChanged,
    this.readOnly = false,
    this.keyboardType,
    this.obscureText = false,
    this.maxLines = 1,
    this.prefix,
    this.suffix,
    this.textInputAction,
    this.onFieldSubmitted,
    this.validator,
    this.inputFormatters,
    this.style,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      focusNode: focusNode,
      controller: controller,
      onTap: onTap,
      onChanged: onChanged,
      readOnly: readOnly,
      keyboardType: keyboardType,
      obscureText: obscureText,
      maxLines: maxLines,
      textInputAction: textInputAction,
      onFieldSubmitted: onFieldSubmitted,
      validator: validator,
      inputFormatters: inputFormatters,
      style: GoogleFonts.inter(
        fontSize: focusNode.hasFocus ? 16 : 14,
        fontWeight: focusNode.hasFocus ? FontWeight.w500 : FontWeight.w400,
        color: focusNode.hasFocus ? const Color(0xFF0F172A) : const Color(0xFF9CA3AF),
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: style ?? GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500, color: const Color(0xFF9CA3AF)),
        prefixIcon: prefix != null ? Padding(padding: const EdgeInsets.only(left: 16, right: 8), child: prefix) : null,
        prefixIconConstraints: const BoxConstraints(minWidth: 40, minHeight: 40, maxWidth: 40, maxHeight: 40),
        focusColor: Color(0xFF0038BC),
        suffixIcon: suffix != null ? Padding(padding: const EdgeInsets.only(left: 16, right: 8), child: suffix) : null,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        filled: false,
        fillColor: Color(0xFFFFFFFF),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF2563EB), width: 1.2),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0x291F2933)),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFDC2626)),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFDC2626), width: 1.2),
        ),
      ),
      cursorColor: const Color(0xFF2563EB),
    );
  }
}
