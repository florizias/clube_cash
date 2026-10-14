import 'package:flutter/material.dart';

Widget sectionCard({required Widget child, double margin = 0, Color color = const Color(0xFFFFFFFF)}) {
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.all(14),
    margin: EdgeInsets.symmetric(horizontal: margin),
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: Color(0xFFE6ECF3)),
    ),
    child: child,
  );
}
