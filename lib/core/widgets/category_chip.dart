import 'package:material_ui/material_ui.dart';

import '../theme/offpath_colors.dart';

/// Maps a category id to its colour role ('all' uses the brand purple).
Color categoryColor(BuildContext context, String categoryId) {
  final colors = context.offPath;
  return switch (categoryId) {
    'nature' => colors.nature,
    'culture' => colors.culture,
    'food' => colors.food,
    'adventure' => colors.adventure,
    _ => Theme.of(context).colorScheme.primary,
  };
}

/// Pill-shaped filter chip. When selected it fills with its category colour.
class CategoryChip extends StatelessWidget {
  const CategoryChip({
    super.key,
    required this.label,
    required this.categoryId,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final String categoryId;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final fill = categoryColor(context, categoryId);
    // Purple needs onPrimary text; the bright category fills need dark text.
    final selectedText =
    categoryId == 'all' ? scheme.onPrimary : context.offPath.onAccent;

    return Material(
      color: selected ? fill : scheme.surface,
      shape: StadiumBorder(
        side: BorderSide(color: selected ? fill : scheme.outlineVariant),
      ),
      child: InkWell(
        customBorder: const StadiumBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            label,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: selected ? selectedText : scheme.onSurface,
            ),
          ),
        ),
      ),
    );
  }
}