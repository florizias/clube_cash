import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/utils/image_webp_converter.dart';
import '../models/customer_purchase_request_model.dart';

class CustomerPurchaseRequestsRepository {
  final FirebaseFirestore _db;
  final FirebaseStorage _storage;

  CustomerPurchaseRequestsRepository({required FirebaseFirestore db, required FirebaseStorage storage}) : _db = db, _storage = storage;

  Future<void> submitReceipt({
    required String partnerId,
    required String customerId,
    required String customerName,
    required double amount,
    required XFile receiptImage,
  }) async {
    if (amount <= 0) {
      throw Exception('Informe um valor válido para a compra.');
    }

    final partnerRef = _db.collection('partners').doc(partnerId);
    final partnerSnapshot = await partnerRef.get();
    final partnerData = partnerSnapshot.data();

    if (partnerData == null) {
      throw Exception('Loja não encontrada.');
    }

    final partnerName = partnerData['name']?.toString() ?? '';
    final partnerStoreId = partnerData['storeId']?.toString() ?? '';
    final cashbackPercent = (partnerData['cashbackLabel'] as num?)?.toDouble() ?? 0;

    final cashbackAmount = amount * (cashbackPercent / 100);

    final requestRef = _db.collection('purchase_requests').doc();
    final requestId = requestRef.id;

    final receiptImageUrl = await _uploadReceiptImage(partnerId: partnerId, customerId: customerId, requestId: requestId, image: receiptImage);

    await requestRef.set({
      'id': requestId,

      'partnerId': partnerId,
      'partnerName': partnerName,
      'partnerStoreId': partnerStoreId,

      'customerId': customerId,
      'customerName': customerName,

      'amount': amount,
      'cashbackPercent': cashbackPercent,
      'cashbackAmount': cashbackAmount,

      'receiptImageUrl': receiptImageUrl,
      'status': 'pending',

      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),

      'approvedAt': null,
      'rejectedAt': null,
    });
  }

  Stream<List<CustomerPurchaseRequestModel>> watchCustomerRequests(String customerId) {
    return _db.collection('purchase_requests').where('customerId', isEqualTo: customerId).snapshots().map((snapshot) {
      final requests = snapshot.docs.map((doc) {
        return CustomerPurchaseRequestModel.fromFirestore(doc);
      }).toList();

      requests.sort((a, b) {
        final aDate = a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        final bDate = b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);

        return bDate.compareTo(aDate);
      });

      return requests;
    });
  }

  Future<String> _uploadReceiptImage({required String partnerId, required String customerId, required String requestId, required XFile image}) async {
    final webpBytes = await ImageWebpConverter.xFileToWebp(image: image);

    final ref = _storage.ref('purchase_receipts/$partnerId/$customerId/$requestId/receipt.webp');

    final snapshot = await ref.putData(
      webpBytes,
      SettableMetadata(contentType: 'image/webp', customMetadata: {'originalName': image.name, 'originalMimeType': image.mimeType ?? ''}),
    );

    return snapshot.ref.getDownloadURL();
  }
}
