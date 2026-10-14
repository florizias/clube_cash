import 'package:cloud_firestore/cloud_firestore.dart';

class PartnerReviewsRepository {
  final FirebaseFirestore _db;

  PartnerReviewsRepository(this._db);

  Future<void> sendReview({
    required String partnerId,
    required String userId,
    required String userName,
    required double rating,
    required String comment,
  }) async {
    final cleanComment = comment.trim();

    if (rating <= 0 || rating > 5) {
      throw Exception('Escolha uma nota entre 1 e 5.');
    }

    if (cleanComment.length < 5) {
      throw Exception('Escreva uma avaliação um pouco mais completa.');
    }

    final partnerRef = _db.collection('partners').doc(partnerId);

    await _db.runTransaction((transaction) async {
      final snap = await transaction.get(partnerRef);

      if (!snap.exists) {
        throw Exception('Loja não encontrada.');
      }

      final data = snap.data() ?? <String, dynamic>{};

      final rawReviews = data['reviews'];

      final reviews = rawReviews is List
          ? rawReviews.whereType<Map>().map((item) => Map<String, dynamic>.from(item)).toList()
          : <Map<String, dynamic>>[];

      reviews.removeWhere((review) {
        return review['userId']?.toString() == userId;
      });

      reviews.add({
        'id': '${userId}_${DateTime.now().millisecondsSinceEpoch}',
        'userId': userId,
        'userName': userName.trim().isEmpty ? 'Cliente' : userName.trim(),
        'rating': rating,
        'comment': cleanComment,
        'status': 'active',
        'createdAt': Timestamp.now(),
        'updatedAt': Timestamp.now(),
      });

      final activeReviews = reviews.where((review) {
        return review['status']?.toString() != 'inactive';
      }).toList();

      final ratingCount = activeReviews.length;

      final ratingSum = activeReviews.fold<double>(0, (double sum, review) {
        return sum + ((review['rating'] as num?)?.toDouble() ?? 0);
      });

      final ratingAverage = ratingCount == 0 ? 0.0 : ratingSum / ratingCount;

      transaction.set(partnerRef, {
        'reviews': reviews,
        'rating': ratingAverage,
        'ratingCount': ratingCount,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    });
  }
}
