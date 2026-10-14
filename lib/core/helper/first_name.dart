String firstNameFrom(String fullName) {
  final cleanName = fullName.trim();

  if (cleanName.isEmpty) {
    return 'Usuário';
  }

  return cleanName.split(RegExp(r'\s+')).first;
}
