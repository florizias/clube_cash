import '../../../../../../core/constants/enums.dart';
import '../../domain/entities/ledger_entry.dart';
import '../../domain/entities/ledger_status.dart';
import '../dtos/ledger_entry_dto.dart';

class LedgerEntryMapper {
  static LedgerEntry toEntity(String id, LedgerEntryDto dto) {
    return LedgerEntry(
      id: id,
      userId: dto.userId,
      idempotencyKey: dto.idempotencyKey,
      createdBy: dto.createdBy,

      type: LedgerTypeX.fromString(dto.type),
      status: LedgerStatusX.fromString(dto.status),

      source: dto.source,
      sourceId: dto.sourceId,

      partnerId: dto.partnerId,
      partnerName: dto.partnerName,

      points: dto.points,
      cashbackValue: dto.cashbackValue,
      purchaseValue: dto.purchaseValue,

      description: dto.description,
      createdAt: dto.createdAt.toDate(),
    );
  }
}
