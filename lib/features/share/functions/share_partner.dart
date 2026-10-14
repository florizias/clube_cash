import 'package:flutter/foundation.dart';
import 'package:share_plus/share_plus.dart';

String partnerRoute(String slug) => '/home/partner/$slug';

String buildPartnerShareUrl(String slug) {
  if (kIsWeb) {
    final origin = Uri.base.origin;
    return '$origin/#${partnerRoute(slug)}';
  }
  return partnerRoute(slug);
}

Future<void> sharePartnerPage(String partnerName, String slug) async {
  final url = buildPartnerShareUrl(slug);

  await SharePlus.instance.share(ShareParams(text: 'Confira a loja $partnerName:\n$url', subject: partnerName));
}
