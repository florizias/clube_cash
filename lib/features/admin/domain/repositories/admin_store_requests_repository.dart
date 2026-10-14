import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/helper/store_slug.dart';
import '../../../../core/utils/geo_point.dart';
import '../../../auth/data/dtos/store_partnership_request_dto.dart';

class AdminStoreRequestsRepository {
  final FirebaseFirestore _db;

  AdminStoreRequestsRepository(this._db);

  CollectionReference<Map<String, dynamic>> get _requests {
    return _db.collection('store_requests');
  }

  CollectionReference<Map<String, dynamic>> get _users {
    return _db.collection('users');
  }

  CollectionReference<Map<String, dynamic>> get _partners {
    return _db.collection('partners');
  }

  Stream<List<StorePartnershipRequestDto>> watchPendingRequests() {
    return _requests.snapshots().map((snapshot) {
      final requests = snapshot.docs
          .map((doc) {
            return StorePartnershipRequestDto.fromFirestore(doc);
          })
          .where((request) {
            return request.status == 'pending';
          })
          .toList();

      requests.sort((a, b) {
        return b.createdAt.compareTo(a.createdAt);
      });

      return requests;
    });
  }

  Future<void> approveRequest(StorePartnershipRequestDto request) async {
    final batch = _db.batch();

    final userRef = _users.doc(request.uid);
    final requestRef = _requests.doc(request.uid);
    final partnerRef = _partners.doc(request.uid);
    final storeSlug = storeSlugFun(request.storeName);
    final geo = await geocodeByAddressSmart(request.address);

    batch.delete(requestRef);

    batch.set(userRef, {
      'role': 'partner',
      'status': 'active',
      'storeUID': request.uid,
      'storeId': storeSlug,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    batch.set(partnerRef, {
      'id': request.uid,
      'uid': request.uid,
      'storeId': storeSlug,

      'role': 'partner',
      'status': 'active',
      'name': request.storeName,
      'email': request.commercialEmail,
      'whatsapp': request.whatsapp,
      'cnpj': request.cnpj,
      'category': request.category,
      'subCategory': '',
      'rating': 0,
      'ratingCount': 0,
      'cashbackLabel': request.cashbackProposal.toDouble(),
      'address': request.address,
      'latitude': geo?.lat,
      'longitude': geo?.lng,
      'geocodeStatus': geo == null ? 'failed' : 'success',
      'geocodedAt': FieldValue.serverTimestamp(),
      'coverImageUrl': '',
      'logoUrl': '',
      'phone': request.whatsapp,
      'instagram': '',
      'facebook': '',
      'tiktok': '',
      'website': '',
      'openingHours': [],
      'products': [],
      'reviews': [],
      'application': {
        'monthlyRevenue': request.monthlyRevenue,
        'openedAt': request.openingDate,
        'legalResponsibleName': request.legalResponsible,
        'whyJoin': request.whyParticipate,
        'dateSolicitation': request.createdAt,
        'approvedAt': FieldValue.serverTimestamp(),
      },
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    await batch.commit();
  }

  Future<void> rejectRequest({required String uid, required String reason}) async {
    final cleanReason = reason.trim();

    if (cleanReason.isEmpty) {
      throw Exception('Informe o motivo da recusa.');
    }

    final requestRef = _db.collection('store_requests').doc(uid);
    final userRef = _db.collection('users').doc(uid);

    final batch = _db.batch();

    batch.set(requestRef, {
      'status': 'rejected',
      'rejectionReason': cleanReason,
      'rejectedAt': FieldValue.serverTimestamp(),
      'reviewedAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    batch.set(userRef, {'status': 'rejected', 'rejectionReason': cleanReason, 'updatedAt': FieldValue.serverTimestamp()}, SetOptions(merge: true));

    await batch.commit();
  }
}
