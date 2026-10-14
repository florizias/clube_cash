import '../entities/audit_log.dart';

abstract class AuditLogsRepository {
  Future<void> add(AuditLog log);
}
