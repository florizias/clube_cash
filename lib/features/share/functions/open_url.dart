import 'package:clubcash/app/variables.dart';
import 'package:url_launcher/url_launcher.dart';

Future<void> openUrl(String? url) async {
  if (url == null || url.isEmpty) return;

  final uri = Uri.parse(url);

  if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
    throw 'Não foi possível abrir $url';
  }
}

class SupportActions {
  static Future<bool> openPhoneCall() async {
    final uri = Uri(scheme: 'tel', path: Variables.phoneEmergency.replaceAll(RegExp(r'[^0-9]'), ''));

    if (!await canLaunchUrl(uri)) {
      return false;
    }

    return launchUrl(uri);
  }

  static Future<bool> openWhatsApp() async {
    final cleanPhone = Variables.phoneWhatsApp.replaceAll(RegExp(r'[^0-9]'), '');
    final encodedMessage = Uri.encodeComponent('Olá, preciso de suporte no ClubeCash.');

    final uri = Uri.parse('https://wa.me/$cleanPhone?text=$encodedMessage');

    if (!await canLaunchUrl(uri)) {
      return false;
    }

    return launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  static Future<bool> openEmail() async {
    final uri = Uri(
      scheme: 'mailto',
      path: Variables.emailEmergency,
      queryParameters: {'subject': 'Suporte ClubeCash', 'body': 'Olá, preciso de ajuda com minha conta.'},
    );

    if (!await canLaunchUrl(uri)) {
      return false;
    }

    return launchUrl(uri);
  }
}
