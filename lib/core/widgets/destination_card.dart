import 'package:material_ui/material_ui.dart';

import '../theme/app_colors.dart';
import '../theme/offpath_colors.dart';
import 'hidden_gem_badge.dart';
import 'network_photo.dart';

/// Photo card for a destination: name and country over a dark fade,
/// optional Hidden Gem badge (top-left) and save heart (top-right).
class DestinationCard extends StatelessWidget {
  const DestinationCard({
    super.key,
    required this.name,
    required this.country,
    required this.imageUrl,
    this.onTap,
    this.isSaved = false,
    this.onSaveToggle,
    this.showHiddenGemBadge = false,
    this.height = 200,
  });

  final String name;
  final String country;
  final String imageUrl;
  final VoidCallback? onTap;
  final bool isSaved;
  final VoidCallback? onSaveToggle;
  final bool showHiddenGemBadge;
  final double height;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return SizedBox(
      height: height,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          fit: StackFit.expand,
          children: [
            NetworkPhoto(url: imageUrl),

            // Dark fade at the bottom so white text stays readable on any photo.
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: [0.45, 1.0],
                  colors: [Colors.transparent, Color(0xB3000000)],
                ),
              ),
            ),

            Positioned(
              left: 16,
              right: 16,
              bottom: 14,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: text.titleLarge?.copyWith(color: Colors.white),
                  ),
                  Text(
                    country,
                    style: text.bodyMedium?.copyWith(color: Colors.white70),
                  ),
                ],
              ),
            ),

            // Tap anywhere on the card (drawn above the photo so the ripple shows).
            Positioned.fill(
              child: Material(
                type: MaterialType.transparency,
                child: InkWell(onTap: onTap),
              ),
            ),

            if (showHiddenGemBadge)
              const Positioned(top: 12, left: 12, child: HiddenGemBadge()),

            if (onSaveToggle != null)
              Positioned(
                top: 8,
                right: 8,
                child: Material(
                  color: Colors.white.withValues(alpha: 0.85),
                  shape: const CircleBorder(),
                  child: IconButton(
                    onPressed: onSaveToggle,
                    tooltip: isSaved ? 'Remove from saved' : 'Save',
                    icon: Icon(
                      isSaved ? Icons.favorite : Icons.favorite_border,
                      size: 20,
                      color: isSaved ? context.offPath.favourite : AppPalette.ink,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}