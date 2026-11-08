import 'package:flutter/material.dart';

class DefaultColorSheet {
  // Existing palette constants (preserved for backward compatibility)
  static const Color grey400 = Color(0xFFB9C1BE);
  static const Color grey300 = Color(0xFFA8B0AF);
  static const Color grey200 = Color(0xFFD6E4E0);
  static const Color grey100 = Color.fromRGBO(205, 209, 208, 0.2);
  static const Color grey500 = Color(0xFF797C7B);
  static const Color grey600 = Color(0xFFF5F6F6);
  static const Color white200 = Color(0xFFF2F7FB);
  static const Color primary = Color(0xFF24786D);
  static const Color disbaledButton = Color(0xFFF3F6F6);
  static const Color error = Color(0xFFFF2D1B);
  static const Color white100 = Color(0xFFEEFAF8);
  static const Color lightBlack = Color(0xFF000E08);
  static const Color red100 = Color(0xFFF04A4C);
  static const Color activeGreen = Color(0xFF2BEF83);
  static const Color green500 = Color(0xFF20A090);
  static const Color green400 = Color(0xFF24786D);
  static const Color green100 = Color(0xFFF2F8F7);
  static const Color green200 = Color(0xFF051D13);
  static const Color blue200 = Color(0xFFF1F6FA);

  // --- Centralized Palette Constants ---
  // Chat Wallpapers
  static const Color lightChatBackground = Color(0xFFECE5DD);
  static const Color darkChatBackground = Color(0xFF0B141B);

  // Surfaces & Containers
  static const Color darkBackground = Color(0xFF0B141B);
  static const Color darkCard = Color(0xFF111B21);
  static const Color darkSurface = Color(0xFF1F2C34);
  static const Color darkInput = Color(0xFF2A3942);
  static const Color lightInput = Color(0xFFF0F2F5);
  static const Color darkDivider = Color(0xFF222E35);
  static const Color lightDivider = Color(0xFFF0F2F5);

  // Text Colors
  static const Color darkTextPrimary = Color(0xFFE9EDEF);
  static const Color darkTextSecondary = Color(0xFF8696A0);
  static const Color lightTextPrimary = Color(0xFF111B21);
  static const Color lightTextSecondary = Color(0xFF667781);

  // Chat Bubbles
  static const Color lightSenderBubble = Color(0xFFE7FFDB);
  static const Color darkSenderBubble = Color(0xFF005C4B);
  static const Color lightReceiverBubble = Colors.white;
  static const Color darkReceiverBubble = Color(0xFF202C33);

  // Timeline Banners / System Pills
  static const Color lightBannerBg = Color(0xFFE9EDEF);
  static const Color darkBannerBg = Color(0xFF182229);
  static const Color lightBannerText = Color(0xFF54656F);
  static const Color darkBannerText = Color(0xFF8696A0);

  // Status / Ticks
  static const Color blueTick = Color(0xFF4FC3F7);
  static const Color accentGreen = Color(0xFF00A884);
  static const Color accentGreenLight = Color(0xFFE8F5E9);

  // --- Context-Aware Semantic Color Helpers ---
  static bool isDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  // Backgrounds
  static Color scaffoldBg(BuildContext context) =>
      isDark(context) ? darkBackground : Colors.white;

  static Color chatBg(BuildContext context) =>
      isDark(context) ? darkChatBackground : lightChatBackground;

  static Color containerBg(BuildContext context) =>
      isDark(context) ? darkCard : Colors.white;

  static Color surfaceBg(BuildContext context) =>
      isDark(context) ? darkSurface : Colors.white;

  static Color cardBg(BuildContext context) =>
      isDark(context) ? darkSurface : Colors.white;

  // App Bar
  static Color appBarBg(BuildContext context) =>
      isDark(context) ? darkSurface : Colors.white;

  static Color appBarIcon(BuildContext context) =>
      isDark(context) ? darkTextPrimary : lightBlack;

  static Color appBarTitle(BuildContext context) =>
      isDark(context) ? darkTextPrimary : lightBlack;

  // Text
  static Color textPrimary(BuildContext context) =>
      isDark(context) ? darkTextPrimary : lightBlack;

  static Color textSecondary(BuildContext context) =>
      isDark(context) ? darkTextSecondary : grey500;

  static Color textMuted(BuildContext context) =>
      isDark(context) ? darkTextSecondary : grey400;

  // Inputs
  static Color inputContainerBg(BuildContext context) =>
      isDark(context) ? darkSurface : Colors.white;

  static Color inputFieldBg(BuildContext context) =>
      isDark(context) ? darkInput : lightInput;

  static Color inputTextColor(BuildContext context) =>
      isDark(context) ? darkTextPrimary : lightBlack;

  static Color inputHintColor(BuildContext context) =>
      isDark(context) ? darkTextSecondary : grey500;

  // Chat Bubbles
  static Color bubbleSender(BuildContext context) =>
      isDark(context) ? darkSenderBubble : lightSenderBubble;

  static Color bubbleReceiver(BuildContext context) =>
      isDark(context) ? darkReceiverBubble : lightReceiverBubble;

  static Color bubbleText(BuildContext context) =>
      isDark(context) ? darkTextPrimary : lightTextPrimary;

  static Color bubbleTime(BuildContext context, {bool isSender = false}) {
    if (isDark(context)) {
      return isSender ? Colors.white70 : darkTextSecondary;
    }
    return lightTextSecondary;
  }

  // Timeline Banners
  static Color bannerBg(BuildContext context) =>
      isDark(context) ? darkBannerBg : lightBannerBg;

  static Color bannerText(BuildContext context) =>
      isDark(context) ? darkBannerText : lightBannerText;

  // Dividers & Borders
  static Color divider(BuildContext context) =>
      isDark(context) ? darkDivider : lightDivider;

  static Color dividerColor(BuildContext context) => divider(context);

  static Color border(BuildContext context) =>
      isDark(context) ? darkDivider : grey200;

  // Icons
  static Color iconColor(BuildContext context) =>
      isDark(context) ? darkTextPrimary : lightBlack;

  static Color iconPrimary(BuildContext context) => iconColor(context);

  static Color iconSecondary(BuildContext context) =>
      isDark(context) ? darkTextSecondary : grey500;

  // Selection & Splash
  static Color tileSelection(BuildContext context) =>
      isDark(context) ? darkSurface : blue200;

  // Bottom Nav
  static Color bottomNavBg(BuildContext context) =>
      isDark(context) ? darkSurface : Colors.white;

  static Color bottomNavInactive(BuildContext context) =>
      isDark(context) ? darkTextSecondary : grey500;

  // --- Theme Data ---
  static ThemeData get lightTheme => ThemeData(
        fontFamily: "Caros",
        useMaterial3: false,
        brightness: Brightness.light,
        scaffoldBackgroundColor: Colors.white,
        primaryColor: primary,
        cardColor: Colors.white,
        dividerColor: lightDivider,
        iconTheme: const IconThemeData(color: lightBlack),
        colorScheme: const ColorScheme.light(
          primary: primary,
          secondary: green500,
          surface: Colors.white,
          onSurface: lightBlack,
          outline: grey300,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          elevation: 0,
          foregroundColor: lightBlack,
          iconTheme: IconThemeData(color: lightBlack),
          titleTextStyle: TextStyle(
            color: lightBlack,
            fontSize: 18,
            fontWeight: FontWeight.w600,
            fontFamily: "Caros",
          ),
        ),
      );

  static ThemeData get darkTheme => ThemeData(
        fontFamily: "Caros",
        useMaterial3: false,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: darkBackground,
        primaryColor: primary,
        cardColor: darkCard,
        dividerColor: darkDivider,
        iconTheme: const IconThemeData(color: darkTextPrimary),
        colorScheme: const ColorScheme.dark(
          primary: primary,
          secondary: green500,
          surface: darkCard,
          onSurface: darkTextPrimary,
          outline: darkDivider,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: darkSurface,
          elevation: 0,
          foregroundColor: darkTextPrimary,
          iconTheme: IconThemeData(color: darkTextPrimary),
          titleTextStyle: TextStyle(
            color: darkTextPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w600,
            fontFamily: "Caros",
          ),
        ),
      );
}
