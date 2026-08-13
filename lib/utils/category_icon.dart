import 'package:flutter/material.dart';

/// Ikon kategori berdasarkan nama — konsisten di form & manajemen kategori.
IconData categoryIconFor(String name) {
  final lower = name.toLowerCase();
  if (lower.contains('listrik')) {
    return Icons.electrical_services;
  }
  if (lower.contains('ac') || lower.contains('pendingin')) {
    return Icons.ac_unit;
  }
  if (lower.contains('sanitasi') ||
      lower.contains('air') ||
      lower.contains('toilet')) {
    return Icons.water_drop_outlined;
  }
  if (lower.contains('furniture') ||
      lower.contains('meja') ||
      lower.contains('kursi')) {
    return Icons.chair_outlined;
  }
  if (lower.contains('jaringan') || lower.contains('internet')) {
    return Icons.wifi;
  }
  return Icons.build_outlined;
}
