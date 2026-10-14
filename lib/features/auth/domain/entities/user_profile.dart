class UserProfile {
  final String uid; // doc id
  final String name;
  final String email;
  final String phone;

  //final String cpf;
  final String photoUrl;
  final String role; // "customer" | "partner" | "admin"
  final String? storeId; // obrigatório se role=partner
  final String status; // "active" | "blocked" | "deactivated"
  final DateTime createdAt;
  final DateTime updatedAt;

  const UserProfile({
    required this.uid,
    required this.name,
    required this.email,
    required this.phone,
    required this.photoUrl,
    required this.role,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    //this.cpf = '',
    this.storeId,
  });

  bool get isPartner => role == 'partner';

  bool get isAdmin => role == 'admin';

  bool get isCustomer => role == 'customer';

  bool get isActive => status == 'active';

  bool get isDeactivated => status == 'deactivated';
}
