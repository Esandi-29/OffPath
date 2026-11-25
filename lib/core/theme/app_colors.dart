import 'package:material_ui/material_ui.dart';

/// OffPath's raw palette (from the visual style guide).
/// Screens never use these directly. They use the roles in
/// ColorScheme (Theme.of(context).colorScheme) or OffPathColors (context.offPath).
abstract final class AppPalette {
  // Purples: brand / primary
  static const purple1 = Color(0xFF6255D2);
  static const purple2 = Color(0xFF706CE9);
  static const purple3 = Color(0xFF8587F8);

  // Yellows: Hidden Gem badge, highlights, ratings
  static const yellow1 = Color(0xFFF4BB00);
  static const yellow2 = Color(0xFFFFCD3A);
  static const yellow3 = Color(0xFFFFDD34);

  // Blues: Culture category, links
  static const blue1 = Color(0xFF75A5FD);
  static const blue2 = Color(0xFF84BAFA);

  // Greens: Nature category, success / synced
  static const green1 = Color(0xFF39EBAD);
  static const green2 = Color(0xFF27DC9D);
  static const green3 = Color(0xFF19BE9D);

  // Pinks: Food category, favourite heart, errors
  static const pink1 = Color(0xFFC90673);
  static const pink2 = Color(0xFFE01A88);
  static const pink3 = Color(0xFFF3329E);

  // Limes: Adventure category, itinerary timeline
  static const lime1 = Color(0xFFCDF76B);
  static const lime2 = Color(0xFFBEE75E);
  static const lime3 = Color(0xFFA7DC2B);

  // iOS-style neutrals (the palette has no greys)
  static const ink = Color(0xFF111114); // dark text, also used on bright fills
  static const lightPage = Color(0xFFF2F2F7);
  static const lightCard = Color(0xFFFFFFFF);
  static const lightTrack = Color(0xFFE5E5EA);
  static const lightTextSecondary = Color(0xFF6C6C70);
  static const darkPage = Color(0xFF000000);
  static const darkCard = Color(0xFF1C1C1E);
  static const darkTrack = Color(0xFF2C2C2E);
  static const darkElevated = Color(0xFF3A3A3C);
  static const darkTextSecondary = Color(0xFFAEAEB2);
}