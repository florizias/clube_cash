class PartnerReviewInfo {
  final String status;
  final String rejectionReason;
  final String storeName;
  final String email;

  const PartnerReviewInfo({required this.status, required this.rejectionReason, required this.storeName, required this.email});
}

enum PartnerApprovalAction { close, edit, whatsapp }
