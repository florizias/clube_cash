import 'package:flutter/material.dart';

Widget verifyImageUrl(String urlOrAsset) {
  final isNetwork = urlOrAsset.startsWith('http');
  if (isNetwork) {
    return Image.network(
      urlOrAsset,
      fit: BoxFit.cover,
      errorBuilder: (_, _, _) => Center(child: Icon(Icons.image_not_supported_outlined)),
    );
  }
  return Image.asset(urlOrAsset, fit: BoxFit.cover);
}
