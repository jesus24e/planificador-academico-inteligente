import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primarios
  static const Color primary      = Color(0xFF1E3A5F);  // Azul profundo
  static const Color primaryLight = Color(0xFF2E5490);  // Azul medio
  static const Color accent       = Color(0xFFFFC107);  // Amarillo ámbar

  // Fondos
  static const Color background   = Color(0xFFF5F7FA);  // Gris muy claro
  static const Color surface      = Color(0xFFFFFFFF);  // Blanco
  static const Color cardBg       = Color(0xFFFFFFFF);

  // Texto
  static const Color textPrimary   = Color(0xFF1A1A2E);  // Casi negro
  static const Color textSecondary = Color(0xFF6B7280);  // Gris medio
  static const Color textLight     = Color(0xFFFFFFFF);  // Blanco

  // Estado
  static const Color success  = Color(0xFF10B981);  // Verde
  static const Color warning  = Color(0xFFF59E0B);  // Naranja
  static const Color error    = Color(0xFFEF4444);  // Rojo
  static const Color info     = Color(0xFF3B82F6);  // Azul claro

  // Tarjetas del Home (las 3 del wireframe)
  static const Color cardPending  = Color(0xFFFFF3CD);  // Amarillo suave
  static const Color cardToday    = Color(0xFFD1FAE5);  // Verde suave
  static const Color cardSubjects = Color(0xFFDBEAFE);  // Azul suave
}