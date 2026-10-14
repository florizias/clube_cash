import 'package:cloud_firestore/cloud_firestore.dart';

class AuditLogDto {
  final String actorId;
  final String actorRole;
  final String action;
  final String entityType;
  final String entityId;
  final Map<String, dynamic> metadata;
  final Timestamp createdAt;

  AuditLogDto({
    required this.actorId,
    required this.actorRole,
    required this.action,
    required this.entityType,
    required this.entityId,
    required this.metadata,
    required this.createdAt,
  });

  factory AuditLogDto.fromJson(Map<String, dynamic> json) {
    return AuditLogDto(
      actorId: json['actorId'] as String? ?? '',
      actorRole: json['actorRole'] as String? ?? 'system',
      action: json['action'] as String? ?? '',
      entityType: json['entityType'] as String? ?? '',
      entityId: json['entityId'] as String? ?? '',
      metadata: (json['metadata'] as Map<String, dynamic>?) ?? <String, dynamic>{},
      createdAt: (json['createdAt'] as Timestamp?) ?? Timestamp.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'actorId': actorId,
      'actorRole': actorRole,
      'action': action,
      'entityType': entityType,
      'entityId': entityId,
      'metadata': metadata,
      'createdAt': createdAt,
    };
  }
}
