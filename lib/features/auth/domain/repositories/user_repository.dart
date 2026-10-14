import '../entities/user_profile.dart';

abstract class UserRepository {
  Stream<UserProfile?> watchProfile(String uid);
  Future<UserProfile?> getProfile(String uid);
  Future<void> createOrUpdateProfile(UserProfile profile);
}
