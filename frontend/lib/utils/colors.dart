import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors
  static const Color primary = Color(0xFF7C3AED);
  static const Color primaryDark = Color(0xFF6D28D9);
  static const Color primaryLight = Color(0xFF8B5CF6);
  
  // Background Colors
  static const Color background = Color(0xFF0F0F23);
  static const Color card = Color(0xFF1A1A2E);
  static const Color cardLight = Color(0xFF252542);
  
  // Surface Colors
  static const Color surface = Color(0xFF16213E);
  static const Color surfaceDark = Color(0xFF0F172A);
  
  // Accent Colors
  static const Color accentGreen = Color(0xFF10B981);
  static const Color accentRed = Color(0xFFEF4444);
  static const Color accentBlue = Color(0xFF3B82F6);
  static const Color accentYellow = Color(0xFFF59E0B);
  static const Color accentPurple = Color(0xFF8B5CF6);
  
  // Text Colors
  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Color(0xFF94A3B8);
  static const Color textGrey = Color(0xFF64748B);
  
  // State Colors
  static const Color success = Color(0xFF10B981);
  static const Color error = Color(0xFFEF4444);
  static const Color warning = Color(0xFFF59E0B);
  
  // Gradient
  static const Gradient primaryGradient = LinearGradient(
    colors: [Color(0xFF7C3AED), Color(0xFF4F46E5)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const Gradient cardGradient = LinearGradient(
    colors: [Color(0xFF1E293B), Color(0xFF334155)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}