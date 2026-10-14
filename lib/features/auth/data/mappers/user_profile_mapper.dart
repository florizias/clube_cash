import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/user_profile.dart';
import '../dtos/user_profile_dto.dart';

class UserProfileMapper {
  static UserProfile toEntity(String uid, UserProfileDto dto) {
    return UserProfile(
      uid: uid,
      name: dto.name,
      email: dto.email,
      phone: dto.phone,
      photoUrl: dto.photoUrl,
      role: dto.role,
      storeId: dto.storeId,
      status: dto.status,
      createdAt: dto.createdAt.toDate(),
      updatedAt: dto.updatedAt.toDate(),
    );
  }

  static UserProfileDto toDto(UserProfile profile) {
    return UserProfileDto(
      name: profile.name,
      email: profile.email,
      phone: profile.phone,
      photoUrl: profile.photoUrl,
      role: profile.role,
      storeId: profile.storeId,
      status: profile.status,
      createdAt: Timestamp.fromDate(profile.createdAt),
      updatedAt: Timestamp.fromDate(profile.updatedAt),
    );
  }
}
