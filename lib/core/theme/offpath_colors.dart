import 'package:material_ui/material_ui.dart';

import 'app_colors.dart';

/// OffPath's own colour roles, added to the theme as a ThemeExtension.
/// Category colours are FILLS with dark `onAccent` text on top
/// (all pass WCAG contrast that way, in light and dark mode).
@immutable
class OffPathColors extends ThemeExtension<OffPathColors> {
  const OffPathColors({
    required this.nature,
    required this.culture,
    required this.food,
    required this.adventure,
    required this.hiddenGem,
    required this.favourite,
    required this.success,
    required this.onAccent,
  });

  final Color nature;
  final Color culture;
  final Color food;
  final Color adventure;
  final Color hiddenGem;
  final Color favourite;
  final Color success;
  final Color onAccent;

  static const light = OffPathColors(
    nature: AppPalette.green3,
    culture: AppPalette.blue1,
    food: AppPalette.pink3,
    adventure: AppPalette.lime3,
    hiddenGem: AppPalette.yellow2,
    favourite: AppPalette.pink2,
    success: AppPalette.green3,
    onAccent: AppPalette.ink,
  );

  static const dark = OffPathColors(
    nature: AppPalette.green3,
    culture: AppPalette.blue1,
    food: AppPalette.pink3,
    adventure: AppPalette.lime3,
    hiddenGem: AppPalette.yellow2,
    favourite: AppPalette.pink3,
    success: AppPalette.green1,
    onAccent: AppPalette.ink,
  );

  @override
  OffPathColors copyWith({
    Color? nature,
    Color? culture,
    Color? food,
    Color? adventure,
    Color? hiddenGem,
    Color? favourite,
    Color? success,
    Color? onAccent,
  }) {
    return OffPathColors(
      nature: nature ?? this.nature,
      culture: culture ?? this.culture,
      food: food ?? this.food,
      adventure: adventure ?? this.adventure,
      hiddenGem: hiddenGem ?? this.hiddenGem,
      favourite: favourite ?? this.favourite,
      success: success ?? this.success,
      onAccent: onAccent ?? this.onAccent,
    );
  }

  @override
  OffPathColors lerp(covariant OffPathColors? other, double t) {
    if (other == null) return this;
    return OffPathColors(
      nature: Color.lerp(nature, other.nature, t)!,
      culture: Color.lerp(culture, other.culture, t)!,
      food: Color.lerp(food, other.food, t)!,
      adventure: Color.lerp(adventure, other.adventure, t)!,
      hiddenGem: Color.lerp(hiddenGem, other.hiddenGem, t)!,
      favourite: Color.lerp(favourite, other.favourite, t)!,
      success: Color.lerp(success, other.success, t)!,
      onAccent: Color.lerp(onAccent, other.onAccent, t)!,
    );
  }
}

/// Shortcut so screens can write `context.offPath.nature`.
extension OffPathThemeX on BuildContext {
  OffPathColors get offPath => Theme.of(this).extension<OffPathColors>()!;
}