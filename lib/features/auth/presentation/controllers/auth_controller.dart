import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../customer/presentation/ledger/presentation/providers/customer_wallet_provider.dart';
import '../../data/dtos/store_partnership_request_dto.dart';
import '../../domain/entities/user_profile.dart';
import '../providers/auth_providers.dart';

final authControllerProvider = NotifierProvider<AuthController, AsyncValue<void>>(AuthController.new);

class AuthController extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  Future<UserProfile> _getActiveProfileOrSignOut(String uid) async {
    final authRepo = ref.read(authRepositoryProvider);
    final userRepo = ref.read(userRepositoryProvider);

    final profile = await userRepo.getProfile(uid);

    if (profile == null) {
      await authRepo.signOut();
      throw Exception('Perfil do usuário não encontrado.');
    }

    if (profile.status == 'deactivated') {
      await authRepo.signOut();
      throw Exception('Esta conta foi desativada. Entre em contato com o suporte.');
    }

    return profile;
  }

  Future<void> signIn({required String email, required String password}) async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      final authRepo = ref.read(authRepositoryProvider);

      final credential = await authRepo.signIn(email: email, password: password);

      final user = credential.user;

      if (user == null) {
        throw Exception('Erro ao entrar na conta.');
      }

      final profile = await _getActiveProfileOrSignOut(user.uid);

      if (profile.role == 'customer') {
        await ref.read(customerWalletRepositoryProvider).ensureWalletExists(user.uid);
      }
    });
  }

  Future<void> signUp({required String name, required String email, required String phone, required String password, required String role}) async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      final authRepo = ref.read(authRepositoryProvider);
      final userRepo = ref.read(userRepositoryProvider);

      final cred = await authRepo.signUp(name: name, email: email, phone: phone, password: password, role: role);

      final user = cred.user;

      if (user == null) {
        throw Exception('Erro ao criar usuário');
      }

      await user.sendEmailVerification();

      final now = DateTime.now();

      final profile = UserProfile(
        uid: user.uid,
        name: name.trim(),
        email: email.trim().toLowerCase(),
        phone: phone.trim(),
        photoUrl: '',
        role: role,
        status: role == 'partner' ? 'pending_approval' : 'active',
        createdAt: now,
        updatedAt: now,
      );

      await userRepo.createOrUpdateProfile(profile);

      if (role == 'customer') {
        await ref.read(customerWalletRepositoryProvider).ensureWalletExists(user.uid);
      }
    });
  }

  Future<void> requestStorePartnership({
    required String storeName,
    required String cnpj,
    required String category,
    required String monthlyRevenue,
    required String openingDate,
    required String address,
    required String legalResponsible,
    required String commercialEmail,
    required String loginEmail,
    required String whatsapp,
    required String password,
    required String whyParticipate,
    required int cashbackProposal,
  }) async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      final authRepo = ref.read(authRepositoryProvider);
      final userRepo = ref.read(userRepositoryProvider);
      final storeRequestRepo = ref.read(storeRequestRepositoryProvider);

      final credential = await authRepo.signUp(name: legalResponsible, email: loginEmail, phone: whatsapp, password: password, role: 'partner');

      final user = credential.user;

      if (user == null) {
        throw Exception('Erro ao criar usuário da loja.');
      }

      await user.sendEmailVerification();

      final now = DateTime.now();

      final profile = UserProfile(
        uid: user.uid,
        name: legalResponsible.trim(),
        email: loginEmail.trim().toLowerCase(),
        phone: whatsapp.trim(),
        photoUrl: '',
        role: 'partner',
        storeId: null,
        status: 'pending_approval',
        createdAt: now,
        updatedAt: now,
      );

      final request = StorePartnershipRequestDto(
        uid: user.uid,
        storeName: storeName,
        cnpj: cnpj,
        category: category,
        monthlyRevenue: monthlyRevenue,
        openingDate: openingDate,
        address: address,
        legalResponsible: legalResponsible,
        commercialEmail: commercialEmail,
        loginEmail: loginEmail,
        whatsapp: whatsapp,
        whyParticipate: whyParticipate,
        cashbackProposal: cashbackProposal,
        status: 'pending',
        createdAt: Timestamp.fromDate(now),
        updatedAt: Timestamp.fromDate(now),
      );

      await userRepo.createOrUpdateProfile(profile);

      await storeRequestRepo.createRequest(request);
    });
  }

  Future<void> sendPasswordResetEmail(String email) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final authRepo = ref.read(authRepositoryProvider);
      await authRepo.sendPasswordResetEmail(email);
    });
  }

  Future<void> signOut() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final authRepo = ref.read(authRepositoryProvider);
      await authRepo.signOut();
    });
  }

  Future<void> signInWithGoogle() async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      final authRepo = ref.read(authRepositoryProvider);
      final userRepo = ref.read(userRepositoryProvider);

      final credential = await authRepo.signInWithGoogle();
      final user = credential.user;

      if (user == null) {
        throw Exception('Erro ao entrar com Google.');
      }

      final existingProfile = await userRepo.getProfile(user.uid);

      if (existingProfile != null) {
        if (existingProfile.status == 'deactivated') {
          await authRepo.signOut();
          throw Exception('Esta conta foi desativada. Entre em contato com o suporte.');
        }

        if (existingProfile.role == 'customer') {
          await ref.read(customerWalletRepositoryProvider).ensureWalletExists(user.uid);
        }

        return;
      }

      final now = DateTime.now();

      final profile = UserProfile(
        uid: user.uid,
        name: user.displayName?.trim().isNotEmpty == true ? user.displayName!.trim() : 'Usuário',
        email: user.email?.trim().toLowerCase() ?? '',
        phone: user.phoneNumber ?? '',
        photoUrl: user.photoURL ?? '',
        role: 'customer',
        status: 'active',
        createdAt: now,
        updatedAt: now,
      );

      await userRepo.createOrUpdateProfile(profile);

      await ref.read(customerWalletRepositoryProvider).ensureWalletExists(user.uid);
    });
  }

  Future<UserProfile> getActiveProfileOrSignOut(String uid) async {
    final authRepo = ref.read(authRepositoryProvider);
    final userRepo = ref.read(userRepositoryProvider);

    final profile = await userRepo.getProfile(uid);

    if (profile == null) {
      await authRepo.signOut();
      throw Exception('Perfil do usuário não encontrado.');
    }

    if (profile.status == 'deactivated') {
      await authRepo.signOut();
      throw Exception('Esta conta foi desativada. Entre em contato com o suporte.');
    }

    return profile;
  }
}
