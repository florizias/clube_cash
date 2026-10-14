import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';

class PickedReceipt {
  final String name;
  final Uint8List? bytes;
  final String? path;
  final XFile file;

  const PickedReceipt({required this.name, required this.file, this.bytes, this.path});
}

Future<PickedReceipt?> pickReceipt() async {
  final result = await FilePicker.pickFiles(type: FileType.custom, allowedExtensions: ['png', 'jpg', 'jpeg', 'webp']);

  if (result == null || result.files.isEmpty) return null;

  final pickedFile = result.files.first;
  final path = pickedFile.path;
  final mimeType = _mimeTypeFromName(pickedFile.name);

  final bytes = await pickedFile.readAsBytes();

  final xFile = path != null
      ? XFile(path, name: pickedFile.name, mimeType: mimeType)
      : XFile.fromData(bytes, name: pickedFile.name, mimeType: mimeType, length: bytes.length);

  return PickedReceipt(name: pickedFile.name, bytes: bytes, path: path, file: xFile);
}

String _mimeTypeFromName(String fileName) {
  final extension = fileName.split('.').last.toLowerCase();

  switch (extension) {
    case 'png':
      return 'image/png';
    case 'webp':
      return 'image/webp';
    case 'jpg':
    case 'jpeg':
      return 'image/jpeg';
    default:
      return 'image/jpeg';
  }
}
