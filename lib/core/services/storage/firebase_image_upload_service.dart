import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

import '../../utils/image_webp_converter.dart';

class FirebaseImageUploadService {
  final FirebaseStorage _storage;

  FirebaseImageUploadService(this._storage);

  Future<String> uploadWebpImage({required XFile image, required String path, int? maxWidth, int? maxHeight}) async {
    final webpBytes = await ImageWebpConverter.xFileToWebp(image: image);

    final ref = _storage.ref().child(path);

    final metadata = SettableMetadata(contentType: 'image/webp', customMetadata: {'originalMimeType': image.mimeType ?? ''});

    await ref.putData(webpBytes, metadata);

    return ref.getDownloadURL();
  }
}
