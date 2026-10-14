import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FloatingSaveBar extends StatelessWidget {
  final bool hasChanges;
  final VoidCallback onSave;
  final VoidCallback onCancel;

  const FloatingSaveBar({super.key, required this.hasChanges, required this.onSave, required this.onCancel});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      elevation: 8,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        height: 58,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Color(0xFFFFFFFF).withValues(alpha: 0.85),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE6ECF3)),
        ),
        child: Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 42,
                child: ElevatedButton(
                  onPressed: hasChanges ? onSave : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0038BC),
                    disabledBackgroundColor: const Color(0xFFE6ECF3),
                    foregroundColor: Color(0xFFFFFFFF),
                    disabledForegroundColor: const Color(0xFF9CA3AF),
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                  ),
                  child: Text('Salvar', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700)),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextButton(
                onPressed: hasChanges ? onCancel : null,
                style: ButtonStyle(overlayColor: WidgetStateProperty.all(Colors.transparent)),
                child: Text(
                  'Cancelar alteração',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: hasChanges ? const Color(0xFF64748B) : const Color(0xFF9CA3AF),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
