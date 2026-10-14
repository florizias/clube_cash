import 'dart:convert';

import 'package:http/http.dart' as http;

class CepAddress {
  final String cep;
  final String street;
  final String neighborhood;
  final String city;
  final String state;

  const CepAddress({required this.cep, required this.street, required this.neighborhood, required this.city, required this.state});
}

class CepHelper {
  static Future<CepAddress?> findAddressByCep(String cep) async {
    final cleanCep = cep.replaceAll(RegExp(r'[^0-9]'), '');

    if (cleanCep.length != 8) {
      return null;
    }

    final uri = Uri.parse('https://viacep.com.br/ws/$cleanCep/json/');

    final response = await http.get(uri);

    if (response.statusCode != 200) {
      return null;
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;

    if (data['erro'] == true) {
      return null;
    }

    return CepAddress(
      cep: data['cep']?.toString() ?? cep,
      street: data['logradouro']?.toString() ?? '',
      neighborhood: data['bairro']?.toString() ?? '',
      city: data['localidade']?.toString() ?? '',
      state: data['uf']?.toString() ?? '',
    );
  }
}
