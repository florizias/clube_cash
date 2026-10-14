import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

Future<String?> showQrCodeScannerPop(BuildContext context) {
  return showDialog<String>(context: context, barrierDismissible: true, builder: (_) => const _QrCodeScannerDialog());
}

class _QrCodeScannerDialog extends StatefulWidget {
  const _QrCodeScannerDialog();

  @override
  State<_QrCodeScannerDialog> createState() => _QrCodeScannerDialogState();
}

class _QrCodeScannerDialogState extends State<_QrCodeScannerDialog> {
  bool _didRead = false;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFFFFFFFF),
      insetPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: SizedBox(
          width: 360,
          height: 470,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 8, 10),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Ler QR Code',
                        style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w800, color: const Color(0xFF0F172A)),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close_rounded, size: 20, color: Color(0xFF94A3B8)),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: MobileScanner(
                        onDetect: (capture) {
                          if (_didRead) return;

                          final barcodes = capture.barcodes;
                          if (barcodes.isEmpty) return;

                          final rawCode = barcodes.first.rawValue;
                          if (rawCode == null || rawCode.trim().isEmpty) {
                            return;
                          }

                          setState(() {
                            _didRead = true;
                          });

                          Navigator.of(context).pop(rawCode.trim());
                        },
                      ),
                    ),
                    Center(
                      child: Container(
                        width: 230,
                        height: 230,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: const Color(0xFFEF8F00), width: 3),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(14),
                child: Text(
                  'Aponte a câmera para o QR Code da nota fiscal.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500, color: const Color(0xFF64748B)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
