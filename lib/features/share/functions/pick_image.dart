import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

final _imagePicker = ImagePicker();

Future<XFile?> pickProfileImage(ImageSource source) async {
  return await _imagePicker.pickImage(source: source, imageQuality: 85, maxWidth: 1200);
}

Future<void> showProfileImageOptions({required BuildContext context, required Function(XFile file) onImagePicked}) async {
  await showModalBottomSheet(
    context: context,
    backgroundColor: Color(0xFFFFFFFF),
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(18))),
    builder: (ctx) {
      return SafeArea(
        top: true,
        bottom: true,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined),
              title: const Text('Tirar foto'),
              onTap: () async {
                Navigator.of(ctx).pop();

                final image = await pickProfileImage(ImageSource.camera);
                if (image != null) {
                  onImagePicked(image);
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Escolher da galeria'),
              onTap: () async {
                Navigator.of(ctx).pop();

                final image = await pickProfileImage(ImageSource.gallery);
                if (image != null) {
                  onImagePicked(image);
                }
              },
            ),
          ],
        ),
      );
    },
  );
}
