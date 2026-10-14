import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/audit_log.dart';
import '../../domain/repositories/audit_logs_repository.dart';
import '../dtos/audit_log_dto.dart';

class FirestoreAuditLogsRepository implements AuditLogsRepository {
  final FirebaseFirestore _db;
  FirestoreAuditLogsRepository(this._db);

  CollectionReference<Map<String, dynamic>> get _col => _db.collection('audit_logs');

  @override
  Future<void> add(AuditLog log) async {
    final dto = AuditLogDto(
      actorId: log.actorId,
      actorRole: log.actorRole,
      action: log.action,
      entityType: log.entityType,
      entityId: log.entityId,
      metadata: log.metadata,
      createdAt: Timestamp.fromDate(log.createdAt),
    );
    await _col.add(dto.toJson());
  }
}
