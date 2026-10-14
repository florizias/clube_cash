import 'dart:typed_data';

import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';

class ImageWebpConverter {
  static Future<Uint8List> xFileToWebp({required XFile image}) async {
    final bytes = await image.readAsBytes();

    final decodedImage = img.decodeImage(bytes);

    if (decodedImage == null) {
      throw Exception('Não foi possível processar a imagem.');
    }

    final webpBytes = img.encodeWebP(decodedImage);

    return Uint8List.fromList(webpBytes);
  }
}
