import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

Future<String?> showPartnerRejectReasonPop(BuildContext context) {
  final reasonCtrl = TextEditingController();
  final formKey = GlobalKey<FormState>();

  return showDialog<String>(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) {
      return AlertDialog(
        backgroundColor: const Color(0xFFFFFFFF),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Motivo da recusa',
          style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w800, color: const Color(0xFF0F172A)),
        ),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: reasonCtrl,
            maxLines: 5,
            minLines: 4,
            textInputAction: TextInputAction.newline,
            decoration: InputDecoration(
              hintText: 'Explique o que precisa ser corrigido pelo parceiro...',
              hintStyle: GoogleFonts.inter(fontSize: 13, color: const Color(0xFF94A3B8)),
              filled: true,
              fillColor: const Color(0xFFF8FAFC),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFF0038BC)),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFDC2626)),
              ),
            ),
            validator: (value) {
              final text = value?.trim() ?? '';

              if (text.isEmpty) {
                return 'Informe o motivo da recusa.';
              }

              if (text.length < 10) {
                return 'Escreva uma justificativa mais completa.';
              }

              return null;
            },
          ),
        ),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
        actions: [
          SizedBox(
            height: 40,
            child: TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: Text(
                'Cancelar',
                style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700, color: const Color(0xFF64748B)),
              ),
            ),
          ),
          SizedBox(
            height: 40,
            child: ElevatedButton(
              onPressed: () {
                final ok = formKey.currentState?.validate() ?? false;
                if (!ok) return;

                Navigator.of(dialogContext).pop(reasonCtrl.text.trim());
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFC0392B),
                foregroundColor: const Color(0xFFFFFFFF),
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: Text('Confirmar recusa', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w800)),
            ),
          ),
        ],
      );
    },
  ).whenComplete(reasonCtrl.dispose);
}
