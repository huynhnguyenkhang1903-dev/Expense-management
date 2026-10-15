import 'package:flutter/material.dart';

class AppTheme {
  // Bảng màu đen sang trọng (Luxury Obsidian Dark Theme)
  static const Color background = Color(0xFF090D16); // Đen sâu Obsidian
  static const Color cardColor = Color(0xFF131B2A); // Thẻ tối cao cấp
  static const Color cardElevated = Color(0xFF1A2436); // Lớp nổi
  static const Color borderSubtle = Color(0xFF26334D); // Viền mảnh tinh tế

  // Màu điểm nhấn tài chính
  static const Color primary = Color(0xFF10B981); // Xanh Ngọc Lục Bảo (Emerald)
  static const Color primaryLight = Color(0xFF34D399);
  static const Color secondary = Color(0xFF6366F1); // Tím Indigo hiện đại
  static const Color vipGold = Color(0xFFF59E0B); // Vàng Hoàng Gia VIP
  static const Color vipPlatinum = Color(0xFF94A3B8); // Bạch Kim Private Banking
  
  // Màu trạng thái
  static const Color income = Color(0xFF10B981); // Thu nhập: Xanh mint
  static const Color expense = Color(0xFFF43F5E); // Chi tiêu: Đỏ san hô sang trọng
  static const Color warning = Color(0xFFF59E0B); // Cảnh báo: Vàng hổ phách
  static const Color info = Color(0xFF38BDF8); // Thông tin: Xanh dương Sky

  // Gradients VIP
  static const LinearGradient vipCardGradient = LinearGradient(
    colors: [Color(0xFF162032), Color(0xFF0F172A), Color(0xFF0B1120)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient goldBadgeGradient = LinearGradient(
    colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient emeraldGlowGradient = LinearGradient(
    colors: [Color(0xFF10B981), Color(0xFF059669)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Typography
  static const Color textPrimary = Color(0xFFF8FAFC);
  static const Color textSecondary = Color(0xFF94A3B8);
  static const Color textMuted = Color(0xFF64748B);

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: const ColorScheme.dark(
      primary: primary,
      secondary: secondary,
      surface: cardColor,
      onPrimary: Colors.black,
      onSurface: textPrimary,
    ),
    scaffoldBackgroundColor: background,
    appBarTheme: const AppBarTheme(
      backgroundColor: background,
      elevation: 0,
      centerTitle: true,
      scrolledUnderElevation: 0,
      titleTextStyle: TextStyle(
        color: textPrimary,
        fontSize: 18,
        fontWeight: FontWeight.bold,
        letterSpacing: 0.3,
      ),
      iconTheme: IconThemeData(color: textPrimary),
    ),
    cardTheme: CardThemeData(
      color: cardColor,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: borderSubtle, width: 1),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primary,
        foregroundColor: Colors.black,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFF111827),
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: borderSubtle, width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: borderSubtle, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: primary, width: 1.5),
      ),
      hintStyle: const TextStyle(color: textMuted),
      labelStyle: const TextStyle(color: textSecondary),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: const Color(0xFF0D131F),
      elevation: 0,
      indicatorColor: primary.withValues(alpha: 0.18),
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const TextStyle(color: primary, fontSize: 12, fontWeight: FontWeight.bold);
        }
        return const TextStyle(color: textMuted, fontSize: 12);
      }),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const IconThemeData(color: primary, size: 24);
        }
        return const IconThemeData(color: textMuted, size: 24);
      }),
    ),
  );
}
