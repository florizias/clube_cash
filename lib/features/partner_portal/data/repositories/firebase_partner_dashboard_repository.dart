import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/constants/rewards_config.dart';
import '../../../partner_portal/data/model/partner_dashboard_model.dart';

class FirebasePartnerDashboardRepository {
  final FirebaseFirestore _db;

  FirebasePartnerDashboardRepository(this._db);

  Stream<PartnerDashboardModel> watchDashboard(String partnerId) {
    return _db.collection('purchase_requests').where('partnerId', isEqualTo: partnerId).snapshots().map((snapshot) {
      final docs = snapshot.docs.toList();

      docs.sort((a, b) {
        final aData = a.data();
        final bData = b.data();

        final aCreatedAt = aData['createdAt'];
        final bCreatedAt = bData['createdAt'];

        final aDate = aCreatedAt is Timestamp ? aCreatedAt.toDate() : DateTime.fromMillisecondsSinceEpoch(0);

        final bDate = bCreatedAt is Timestamp ? bCreatedAt.toDate() : DateTime.fromMillisecondsSinceEpoch(0);

        return bDate.compareTo(aDate);
      });

      double totalSales = 0;
      double cashbackDistributed = 0;
      final Set<String> uniqueClients = {};
      final recentTransactions = <PartnerRecentTransactionModel>[];

      for (final doc in docs) {
        final data = doc.data();

        final status = data['status']?.toString() ?? 'pending';
        final customerId = data['customerId']?.toString() ?? '';
        final customerName = data['customerName']?.toString() ?? 'Cliente';
        final amount = (data['amount'] as num?)?.toDouble() ?? 0;
        final cashbackAmount = (data['cashbackAmount'] as num?)?.toDouble() ?? 0;
        final receiptImageUrl = data['receiptImageUrl']?.toString() ?? '';

        final createdAt = data['createdAt'];
        final createdDate = createdAt is Timestamp ? createdAt.toDate() : DateTime.now();

        final minutesAgo = DateTime.now().difference(createdDate).inMinutes;

        if (status == 'approved') {
          totalSales += amount;
          cashbackDistributed += cashbackAmount;

          if (customerId.isNotEmpty) {
            uniqueClients.add(customerId);
          }
        }

        recentTransactions.add(
          PartnerRecentTransactionModel(
            id: doc.id,
            customerId: customerId,
            customerName: customerName,
            initials: _initials(customerName),
            amount: amount,
            cashback: cashbackAmount,
            status: status,
            receiptImageUrl: receiptImageUrl,
            minutesAgo: minutesAgo,
          ),
        );
      }

      return PartnerDashboardModel(
        totalSales: totalSales,
        activeClients: uniqueClients.length,
        cashbackDistributed: cashbackDistributed,
        recentTransactions: recentTransactions.take(20).toList(),
      );
    });
  }

  Future<void> approveRequest({required String requestId}) async {
    final requestRef = _db.collection('purchase_requests').doc(requestId);

    await _db.runTransaction((transaction) async {
      final requestSnapshot = await transaction.get(requestRef);
      final requestData = requestSnapshot.data();

      if (requestData == null) {
        throw Exception('Comprovante não encontrado.');
      }

      final status = requestData['status']?.toString() ?? 'pending';

      if (status == 'approved') {
        return;
      }

      if (status == 'rejected') {
        throw Exception('Este comprovante já foi rejeitado.');
      }

      final customerId = requestData['customerId']?.toString().trim().isNotEmpty == true
          ? requestData['customerId'].toString().trim()
          : requestData['userId']?.toString().trim() ?? '';

      if (customerId.isEmpty) {
        throw Exception('Cliente não encontrado no comprovante.');
      }

      final cashbackAmount = (requestData['cashbackAmount'] as num?)?.toDouble() ?? 0;

      final pointsEarned = RewardsConfig.cashbackValueToPoints(cashbackAmount);

      final walletRef = _db.collection('customer_wallets').doc(customerId);
      final movementRef = walletRef.collection('transactions').doc(requestId);

      transaction.update(requestRef, {'status': 'approved', 'approvedAt': FieldValue.serverTimestamp(), 'updatedAt': FieldValue.serverTimestamp()});

      transaction.set(walletRef, {
        'customerId': customerId,
        'availablePoints': FieldValue.increment(pointsEarned),
        'totalPoints': FieldValue.increment(pointsEarned),
        'availableCashbackValue': FieldValue.increment(cashbackAmount),
        'totalCashbackValue': FieldValue.increment(cashbackAmount),
        'lastPurchaseRequestId': requestId,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      transaction.set(movementRef, {
        'id': requestId,
        'type': 'cashback_credit',
        'source': 'purchase_request',
        'purchaseRequestId': requestId,
        'customerId': customerId,
        'partnerId': requestData['partnerId'],
        'partnerName': requestData['partnerName'],
        'amount': requestData['amount'],
        'cashbackAmount': cashbackAmount,
        'points': pointsEarned,
        'createdAt': FieldValue.serverTimestamp(),
      });
    });
  }

  Future<void> rejectRequest({required String requestId}) async {
    await _db.collection('purchase_requests').doc(requestId).update({
      'status': 'rejected',
      'rejectedAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));

    if (parts.isEmpty || parts.first.isEmpty) {
      return 'CL';
    }

    if (parts.length == 1) {
      return parts.first.substring(0, 1).toUpperCase();
    }

    final first = parts.first.substring(0, 1);
    final last = parts.last.substring(0, 1);

    return '$first$last'.toUpperCase();
  }
}
