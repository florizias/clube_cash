import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../controllers/auth_controller.dart';
import '../models/partner_rewiew.dart';
import '../providers/auth_providers.dart';
import '../widgets/partner_approval_status_pop.dart';

class PartnerStatusGatePage extends ConsumerStatefulWidget {
  const PartnerStatusGatePage({super.key});

  @override
  ConsumerState<PartnerStatusGatePage> createState() => _PartnerStatusGatePageState();
}

class _PartnerStatusGatePageState extends ConsumerState<PartnerStatusGatePage> {
  bool _handled = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _handleStatus();
    });
  }

  Future<void> _handleStatus() async {
    if (_handled) return;
    _handled = true;

    final user = ref.read(firebaseUserProvider).value;

    if (user == null) {
      if (!mounted) return;
      context.go('/login');
      return;
    }

    final userRepo = ref.read(userRepositoryProvider);
    final profile = await userRepo.getProfile(user.uid);

    if (!mounted) return;

    if (profile == null) {
      await ref.read(authControllerProvider.notifier).signOut();

      if (!mounted) return;
      context.go('/login');
      return;
    }

    if (profile.role == 'partner' && profile.status == 'active') {
      context.go('/partner/home');
      return;
    }

    final snap = await FirebaseFirestore.instance.collection('store_requests').doc(user.uid).get();

    final data = snap.data() ?? <String, dynamic>{};

    final status = data['status']?.toString() ?? profile.status;

    final rejectionReason = data['rejectionReason']?.toString() ?? data['reason']?.toString() ?? '';

    final storeName = data['storeName']?.toString() ?? data['name']?.toString() ?? data['businessName']?.toString() ?? '';

    final email = data['email']?.toString() ?? data['commercialEmail']?.toString() ?? profile.email;

    if (!mounted) return;

    final action = await showPartnerApprovalStatusPop(
      context,
      status: status,
      rejectionReason: rejectionReason,
      storeName: storeName,
      userEmail: email,
    );

    if (!mounted) return;

    if (action == PartnerApprovalAction.edit && status == 'rejected') {
      context.go('/partner/request-review');
      return;
    }

    await ref.read(authControllerProvider.notifier).signOut();

    if (!mounted) return;
    context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFFFFFFFF),
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
