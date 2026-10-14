import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class QRScannerPage extends StatelessWidget {
  final Function(String code) onDetect;

  const QRScannerPage({super.key, required this.onDetect});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          MobileScanner(
            onDetect: (barcodeCapture) {
              final barcode = barcodeCapture.barcodes.first;

              if (barcode.rawValue != null) {
                onDetect(barcode.rawValue!);
                Navigator.pop(context);
              }
            },
          ),
          Container(
            margin: EdgeInsets.all(20),
            alignment: Alignment.topLeft,
            child: InkWell(
              onTap: () => Navigator.of(context).pop(),
              borderRadius: BorderRadius.circular(24),
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
              hoverColor: Colors.transparent,
              focusColor: Colors.transparent,
              child: SizedBox(
                width: 15,
                height: 15,
                child: SvgPicture.asset(
                  width: 10,
                  height: 10,
                  "assets/icons/arrow-back.svg",
                  fit: BoxFit.contain,
                  colorFilter: const ColorFilter.mode(Color(0xFFFFFFFF), BlendMode.srcIn),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
