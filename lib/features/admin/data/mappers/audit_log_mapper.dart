import '../../domain/entities/audit_log.dart';
import '../dtos/audit_log_dto.dart';

class AuditLogMapper {
  static AuditLog toEntity(String id, AuditLogDto dto) {
    return AuditLog(
      id: id,
      actorId: dto.actorId,
      actorRole: dto.actorRole,
      action: dto.action,
      entityType: dto.entityType,
      entityId: dto.entityId,
      metadata: dto.metadata,
      createdAt: dto.createdAt.toDate(),
    );
  }
}
