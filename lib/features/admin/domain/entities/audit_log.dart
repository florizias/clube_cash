class AuditLog {
  final String id;
  final String actorId;
  final String actorRole; // "partner" | "admin" | "system"
  final String action; // ex: "purchase_approved"
  final String entityType; // "purchase" | "voucher" | "store" ...
  final String entityId;
  final Map<String, dynamic> metadata;
  final DateTime createdAt;

  const AuditLog({
    required this.id,
    required this.actorId,
    required this.actorRole,
    required this.action,
    required this.entityType,
    required this.entityId,
    required this.metadata,
    required this.createdAt,
  });
}
