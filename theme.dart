import 'package:flutter/material.dart';

class AppTheme {
  static const Color primary = Color(0xFF075E54);
  static const Color primaryLight = Color(0xFF128C7E);
  static const Color chatBackground = Color(0xFFE5DDD5);
  static const Color darkChatBackground = Color(0xFF0B141A);
  static const Color outgoingBubble = Color(0xFFDCF8C6);
  static const Color incomingBubble = Color(0xFFFFFFFF);
  static const Color tealAccent = Color(0xFF25D366);
  static const Color lightText = Color(0xFFE9EDEF);
  static const Color secondaryText = Color(0xFF8696A0);
  static const Color unreadBadge = Color(0xFF25D366);

  static ThemeData lightTheme = ThemeData(
    useMaterial3: false,
    primaryColor: primary,
    scaffoldBackgroundColor: Colors.white,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primary,
      primary: primary,
      secondary: primaryLight,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: primary,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
    ),
    iconTheme: const IconThemeData(color: Colors.white),
    inputDecorationTheme: const InputDecorationTheme(
      border: InputBorder.none,
      hintStyle: TextStyle(color: Colors.white70),
    ),
    textTheme: const TextTheme(
      bodyMedium: TextStyle(fontSize: 15, color: Colors.black87),
      bodySmall: TextStyle(fontSize: 13, color: Colors.black54),
    ),
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: false,
    primaryColor: primary,
    scaffoldBackgroundColor: darkChatBackground,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primary,
      brightness: Brightness.dark,
      primary: primary,
      secondary: primaryLight,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF1F2C34),
      foregroundColor: lightText,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        color: lightText,
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
    ),
    textTheme: const TextTheme(
      bodyMedium: TextStyle(fontSize: 15, color: lightText),
      bodySmall: TextStyle(fontSize: 13, color: secondaryText),
    ),
  );
}

/// A subtle doodle-style chat wallpaper built from a simple repeating pattern.
class ChatPatternPainter extends CustomPainter {
  final Color color;
  ChatPatternPainter({this.color = const Color(0x14000000)});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    const step = 28.0;
    for (double x = 0; x < size.width; x += step) {
      for (double y = 0; y < size.height; y += step) {
        canvas.drawCircle(Offset(x, y), 1.2, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
