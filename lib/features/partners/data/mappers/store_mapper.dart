import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/store.dart' as store_entity;
import '../dtos/store_dto.dart';

class StoreMapper {
  static store_entity.Store toEntity(String id, StoreDto dto) {
    return store_entity.Store(
      id: id,
      name: dto.name,
      logoUrl: dto.logoUrl,
      isActive: dto.isActive,
      cashbackLabel: dto.cashbackLabel,
      rulesText: dto.rulesText,
      createdAt: dto.createdAt.toDate(),
      updatedAt: dto.updatedAt.toDate(),
    );
  }

  static StoreDto toDto(store_entity.Store store) {
    return StoreDto(
      name: store.name,
      logoUrl: store.logoUrl,
      isActive: store.isActive,
      cashbackLabel: store.cashbackLabel,
      rulesText: store.rulesText,
      createdAt: Timestamp.fromDate(store.createdAt),
      updatedAt: Timestamp.fromDate(store.updatedAt),
    );
  }
}
