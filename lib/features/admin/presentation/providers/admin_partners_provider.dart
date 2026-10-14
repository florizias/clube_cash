import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../services/firebase/firebase_providers.dart';
import '../../../partners/models/partner_model.dart';
import '../../domain/repositories/admin_partners_repository.dart';

final adminPartnersRepositoryProvider = Provider<AdminPartnersRepository>((ref) {
  final db = ref.watch(firebaseFirestoreProvider);
  return AdminPartnersRepository(db);
});

final adminPartnerStoresProvider = StreamProvider<List<PartnerStore>>((ref) {
  final repository = ref.watch(adminPartnersRepositoryProvider);
  return repository.watchPartners();
});

final adminActivePartnerStoresProvider = Provider<AsyncValue<List<PartnerStore>>>((ref) {
  final partnersAsync = ref.watch(adminPartnerStoresProvider);

  return partnersAsync.whenData((partners) {
    return partners.where((partner) {
      return partner.role == 'partner' && partner.status == 'active';
    }).toList();
  });
});

final adminInactivePartnerStoresProvider = Provider<AsyncValue<List<PartnerStore>>>((ref) {
  final partnersAsync = ref.watch(adminPartnerStoresProvider);

  return partnersAsync.whenData((partners) {
    return partners.where((partner) {
      return partner.role == 'partner' && partner.status != 'active';
    }).toList();
  });
});
