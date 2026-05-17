import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Bảng màu Pastel chuẩn phong cách Nhật Bản nhẹ nhàng
  static const Color primaryPink = Color(0xFFFFAFCC);
  static const Color secondaryPink = Color(0xFFFFC8DD);

  // ---> THÊM DÒNG NÀY: Hồng trầm/vỏ đỗ để đảm bảo độ tương phản cho chữ và icon
  static const Color deepPink = Color(0xFFD8648B);

  static const Color backgroundCream = Color(0xFFFFFDF9);
  static const Color surfaceWhite = Color(0xFFFFFFFF);
  static const Color textMain = Color(0xFF4A403A);
  static const Color textLight = Color(0xFF9E928A);

  static ThemeData get lightTheme {
    // Sử dụng font Quicksand cho toàn bộ app (nét chữ tròn, dễ thương)
    final textTheme = GoogleFonts.quicksandTextTheme().apply(
      bodyColor: textMain,
      displayColor: textMain,
    );

    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: backgroundCream,
      primaryColor: primaryPink,
      hoverColor: secondaryPink.withOpacity(0.2),
      splashColor: secondaryPink.withOpacity(0.3),
      textTheme: textTheme,

      // Định nghĩa bảng màu tổng thể
      colorScheme: const ColorScheme.light(
        primary: primaryPink,
        secondary: secondaryPink,
        surface: surfaceWhite,
        background: backgroundCream,
        onPrimary: Colors.white,
        onSurface: textMain,
      ),

      // Style chung cho các thẻ (Card) - Đã cập nhật thành CardThemeData
      cardTheme: CardThemeData(
        color: surfaceWhite,
        elevation: 2,
        shadowColor: secondaryPink.withOpacity(0.2), // Đổ bóng màu hồng mờ
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24), // Bo góc tròn trịa
        ),
      ),

      // Style chung cho Nút bấm (ElevatedButton)
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryPink,
          foregroundColor: Colors.white,
          elevation: 0, // Nút phẳng hiện đại
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16), // Bo góc nút
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),

      // Style chung cho Ô nhập liệu (TextField)
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: secondaryPink.withOpacity(
          0.1,
        ), // Nền ô nhập liệu hơi hồng nhẹ
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none, // Bỏ viền để trông sạch sẽ hơn
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: primaryPink, width: 2),
        ),
        hintStyle: const TextStyle(color: textLight),
      ),
    );
  }
}
