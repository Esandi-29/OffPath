import 'package:material_ui/material_ui.dart';

import '../theme/offpath_colors.dart';

/// Yellow "★ Hidden Gem" pill used on cards and Destination Details.
class HiddenGemBadge extends StatelessWidget {
  const HiddenGemBadge({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.offPath;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: colors.hiddenGem,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.star_rounded, size: 14, color: colors.onAccent),
          const SizedBox(width: 4),
          Text(
            'Hidden Gem',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: colors.onAccent,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}