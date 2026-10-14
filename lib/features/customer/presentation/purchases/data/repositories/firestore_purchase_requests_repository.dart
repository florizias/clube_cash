import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../../../core/constants/rewards_config.dart';
import '../../../../../../core/utils/image_webp_converter.dart';
import '../../../../../partners/models/partner_model.dart';
import '../dtos/purchase_dto.dart';

class FirestorePurchaseRequestsRepository {
  final FirebaseFirestore _db;
  final FirebaseStorage _storage;

  FirestorePurchaseRequestsRepository({required FirebaseFirestore db, required FirebaseStorage storage}) : _db = db, _storage = storage;

  CollectionReference<Map<String, dynamic>> get _collection {
    return _db.collection('purchase_requests');
  }

  Future<String> uploadReceiptImage({required String partnerId, required String userId, required String requestId, required XFile image}) async {
    final webpBytes = await ImageWebpConverter.xFileToWebp(image: image);

    final ref = _storage.ref('purchase_receipts/$partnerId/$userId/$requestId/receipt.webp');

    final snapshot = await ref.putData(
      webpBytes,
      SettableMetadata(contentType: 'image/webp', customMetadata: {'originalName': image.name, 'originalMimeType': image.mimeType ?? ''}),
    );

    return snapshot.ref.getDownloadURL();
  }

  Future<void> createPurchaseRequest({
    required String userId,
    required String userName,
    required String userEmail,
    required PartnerStore partner,
    required String nfCode,
    required DateTime purchaseDate,
    required double purchaseValue,
    XFile? receiptImage,
    String source = 'manual',
    String qrCodeRaw = '',
  }) async {
    if (userId.trim().isEmpty) {
      throw Exception('Usuário inválido.');
    }

    if (partner.id.trim().isEmpty) {
      throw Exception('Loja inválida.');
    }

    if (purchaseValue <= 0) {
      throw Exception('Informe um valor válido para a compra.');
    }

    if (nfCode.trim().isEmpty) {
      throw Exception('Informe o código da nota fiscal.');
    }

    if (source == 'manual' && receiptImage == null) {
      throw Exception('Envie a imagem do comprovante.');
    }

    final doc = _collection.doc();

    String receiptImageUrl = '';

    if (receiptImage != null) {
      receiptImageUrl = await uploadReceiptImage(partnerId: partner.id, userId: userId, requestId: doc.id, image: receiptImage);
    }

    final cashbackPercent = partner.cashbackLabel;
    final cashbackAmount = purchaseValue * (cashbackPercent / 100);
    final points = RewardsConfig.cashbackValueToPoints(cashbackAmount);

    final walletRef = _db.collection('customer_wallets').doc(userId);

    await _db.runTransaction((transaction) async {
      transaction.set(doc, {
        'id': doc.id,

        'userId': userId,
        'customerId': userId,
        'userName': userName.trim(),
        'customerName': userName.trim(),
        'userEmail': userEmail.trim().toLowerCase(),
        'customerEmail': userEmail.trim().toLowerCase(),

        'partnerId': partner.id,
        'partnerName': partner.name,
        'partnerStoreId': partner.storeId,

        'nfCode': nfCode.trim(),
        'qrCodeRaw': qrCodeRaw.trim(),
        'source': source,
        'receiptImageUrl': receiptImageUrl,
        'hasReceiptImage': receiptImageUrl.isNotEmpty,

        'purchaseDate': Timestamp.fromDate(purchaseDate),

        'purchaseValue': purchaseValue,
        'amount': purchaseValue,

        'cashbackPercentage': cashbackPercent,
        'cashbackPercent': cashbackPercent,
        'cashbackValue': cashbackAmount,
        'cashbackAmount': cashbackAmount,

        'points': points,

        'status': 'pending',
        'rejectionReason': '',

        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'approvedAt': null,
        'rejectedAt': null,
      });

      transaction.set(walletRef, {
        'userId': userId,
        'customerId': userId,

        'availablePoints': FieldValue.increment(0),
        'lifetimePoints': FieldValue.increment(0),
        'pendingPoints': FieldValue.increment(points),

        'availableCashbackValue': FieldValue.increment(0),
        'lifetimeCashbackValue': FieldValue.increment(0),
        'totalCashbackValue': FieldValue.increment(0),
        'pendingCashbackValue': FieldValue.increment(cashbackAmount),

        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    });
  }

  Stream<List<PurchaseRequestDto>> watchUserRequests(String userId) {
    return _collection.where('userId', isEqualTo: userId).snapshots().map((snapshot) {
      final requests = snapshot.docs.map(PurchaseRequestDto.fromFirestore).toList();

      requests.sort((a, b) {
        return b.createdAt.compareTo(a.createdAt);
      });

      return requests;
    });
  }

  Stream<List<PurchaseRequestDto>> watchPartnerRequests(String partnerId) {
    return _collection.where('partnerId', isEqualTo: partnerId).snapshots().map((snapshot) {
      final requests = snapshot.docs.map(PurchaseRequestDto.fromFirestore).toList();

      requests.sort((a, b) {
        return b.createdAt.compareTo(a.createdAt);
      });

      return requests;
    });
  }

  Stream<List<PurchaseRequestDto>> watchPartnerPendingRequests(String partnerId) {
    return _collection.where('partnerId', isEqualTo: partnerId).where('status', isEqualTo: 'pending').snapshots().map((snapshot) {
      final requests = snapshot.docs.map(PurchaseRequestDto.fromFirestore).toList();

      requests.sort((a, b) {
        return b.createdAt.compareTo(a.createdAt);
      });

      return requests;
    });
  }

  Future<void> rejectRequest({required String requestId, required String reason}) async {
    final requestRef = _collection.doc(requestId);

    await _db.runTransaction((transaction) async {
      final requestSnap = await transaction.get(requestRef);

      if (!requestSnap.exists) {
        throw Exception('Solicitação não encontrada.');
      }

      final data = requestSnap.data() ?? {};

      final status = data['status']?.toString() ?? 'pending';

      if (status == 'approved') {
        throw Exception('Essa solicitação já foi aprovada.');
      }

      if (status == 'rejected') {
        return;
      }

      final userId = data['customerId']?.toString() ?? data['userId']?.toString() ?? '';

      final cashbackAmount = (data['cashbackAmount'] as num?)?.toDouble() ?? (data['cashbackValue'] as num?)?.toDouble() ?? 0;

      final points = (data['points'] as num?)?.toInt() ?? RewardsConfig.cashbackValueToPoints(cashbackAmount);

      if (userId.isEmpty) {
        throw Exception('Cliente não encontrado na solicitação.');
      }

      final walletRef = _db.collection('customer_wallets').doc(userId);

      transaction.set(walletRef, {
        'pendingPoints': FieldValue.increment(-points),
        'pendingCashbackValue': FieldValue.increment(-cashbackAmount),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      transaction.update(requestRef, {
        'status': 'rejected',
        'rejectionReason': reason.trim(),
        'rejectedAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    });
  }

  Future<void> approveRequest(String requestId) async {
    final requestRef = _collection.doc(requestId);

    await _db.runTransaction((transaction) async {
      final requestSnap = await transaction.get(requestRef);

      if (!requestSnap.exists) {
        throw Exception('Solicitação não encontrada.');
      }

      final data = requestSnap.data() ?? {};

      final status = data['status']?.toString() ?? 'pending';

      if (status == 'approved') {
        return;
      }

      if (status == 'rejected') {
        throw Exception('Essa solicitação já foi rejeitada.');
      }

      final userId = data['customerId']?.toString() ?? data['userId']?.toString() ?? '';

      final partnerId = data['partnerId']?.toString() ?? '';
      final partnerName = data['partnerName']?.toString() ?? '';

      final purchaseValue = (data['amount'] as num?)?.toDouble() ?? (data['purchaseValue'] as num?)?.toDouble() ?? 0;

      final cashbackAmount = (data['cashbackAmount'] as num?)?.toDouble() ?? (data['cashbackValue'] as num?)?.toDouble() ?? 0;

      if (userId.isEmpty) {
        throw Exception('Cliente não encontrado na solicitação.');
      }

      if (cashbackAmount <= 0) {
        throw Exception('Valor de cashback inválido.');
      }

      final points = (data['points'] as num?)?.toInt() ?? RewardsConfig.cashbackValueToPoints(cashbackAmount);

      final walletRef = _db.collection('customer_wallets').doc(userId);
      final ledgerRef = walletRef.collection('transactions').doc(requestId);

      transaction.set(walletRef, {
        'userId': userId,
        'customerId': userId,

        'availablePoints': FieldValue.increment(points),
        'lifetimePoints': FieldValue.increment(points),
        'pendingPoints': FieldValue.increment(-points),

        'availableCashbackValue': FieldValue.increment(cashbackAmount),
        'lifetimeCashbackValue': FieldValue.increment(cashbackAmount),
        'totalCashbackValue': FieldValue.increment(cashbackAmount),
        'pendingCashbackValue': FieldValue.increment(-cashbackAmount),

        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      transaction.set(ledgerRef, {
        'id': requestId,
        'type': 'credit',
        'status': 'approved',
        'source': 'purchase_request',
        'sourceId': requestId,
        'purchaseRequestId': requestId,

        'partnerId': partnerId,
        'partnerName': partnerName,

        'points': points,
        'cashbackValue': cashbackAmount,
        'cashbackAmount': cashbackAmount,
        'purchaseValue': purchaseValue,
        'amount': purchaseValue,

        'description': 'Cashback aprovado em $partnerName',
        'createdAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      transaction.update(requestRef, {'status': 'approved', 'approvedAt': FieldValue.serverTimestamp(), 'updatedAt': FieldValue.serverTimestamp()});
    });
  }
}
