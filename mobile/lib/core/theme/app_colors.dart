import 'package:flutter/material.dart';

abstract class AppColors {
  // Paleta Fantasia Medieval / RPG
  static const Color primary = Color(0xFFB91C1C); // Carmesim de combate
  static const Color primaryDark = Color(0xFF7F1D1D);
  static const Color primaryLight = Color(0xFFDC2626);

  static const Color secondary = Color(0xFFD97706); // Ouro de aventureiro
  static const Color secondaryLight = Color(0xFFF59E0B);

  // Fundos e Superfícies (Tema Escuro Imersivo)
  static const Color background = Color(0xFF0F172A); // Slate profundo
  static const Color surface = Color(0xFF1E293B); // Slate intermediário
  static const Color surfaceVariant = Color(0xFF334155);
  static const Color border = Color(0xFF475569);

  // Textos
  static const Color textPrimary = Color(0xFFF8FAFC);
  static const Color textSecondary = Color(0xFF94A3B8);
  static const Color textMuted = Color(0xFF64748B);

  // Estados
  static const Color success = Color(0xFF10B981);
  static const Color error = Color(0xFFEF4444);
  static const Color warning = Color(0xFFF59E0B);
  static const Color info = Color(0xFF38BDF8);
}
