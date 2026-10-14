import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../customer/presentation/purchases/presentation/qrcode_scanner_page.dart';

final _imagePicker = ImagePicker();

Future<XFile?> pickReceiptFrom(ImageSource source) async {
  return await _imagePicker.pickImage(source: source, imageQuality: 85, maxWidth: 1600);
}

Future<void> showPickReceiptOptions({required BuildContext context, required Function(XFile file) onImagePicked}) async {
  await showModalBottomSheet(
    context: context,
    backgroundColor: Color(0xFFFFFFFF),
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(18))),
    builder: (context) {
      return SafeArea(
        top: true,
        bottom: true,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.qr_code_scanner),
                title: const Text('Escanear QR Code'),
                onTap: () async {
                  Navigator.of(context).pop();

                  await Navigator.of(context).push(MaterialPageRoute(builder: (_) => QRScannerPage(onDetect: (code) {})));
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library_outlined),
                title: const Text('Selecionar da galeria'),
                onTap: () async {
                  Navigator.of(context).pop();

                  final image = await pickReceiptFrom(ImageSource.gallery);
                  if (image != null) {
                    onImagePicked(image);
                  }
                },
              ),
            ],
          ),
        ),
      );
    },
  );
}
