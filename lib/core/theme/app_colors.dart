import 'package:flutter/material.dart';

/// Classe de constantes de cores do aplicativo.
/// Centraliza todas as cores utilizadas para manter consistência visual.
class AppColors {
  AppColors._();

  // Cores primárias azuis do tema principal
  static const Color primaryDark = Color(0xFF196AAB);
  static const Color primaryLight = Color(0xFF3695D2);

  // Accent orange para login page
  static const Color accent = Color(0xFFFEAE88);

  // Surface / background shades
  static const Color background = Color(0xFF196AAB);
  static const Color surface = Color(0xFF1A5A8F);
  static const Color surfaceLight = Color(0xFF2178B5);
  static const Color cardBackground = Color(0xFF15567A);

  // Text colors
  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Color(0xCCFFFFFF);
  static const Color textHint = Color(0x99FFFFFF);

  // Gradient para avatars/stories
  static const List<Color> storyGradient = [
    Color(0xFFFEAE88),
    Color(0xFF3695D2),
    Color(0xFF196AAB),
  ];

  // gradient
  static const LinearGradient buttonGradient = LinearGradient(
    colors: [Color(0xFF3695D2), Color(0xFF196AAB)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  // Danger
  static const Color danger = Color(0xFFE74C3C);

  // Success
  static const Color success = Color(0xFF2ECC71);
}
