import 'package:cached_network_image/cached_network_image.dart';
import 'package:material_ui/material_ui.dart';

/// Wikimedia asks apps to identify themselves with a User-Agent header.
const _photoHeaders = {
  'User-Agent': 'OffPath/1.0 (Flutter student coursework app)',
};

/// A web photo that is cached on the device, so it still shows offline
/// once it has been viewed. Grey while loading, landscape icon if it fails.
class NetworkPhoto extends StatelessWidget {
  const NetworkPhoto({super.key, required this.url, this.fit = BoxFit.cover});

  final String url;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return CachedNetworkImage(
      imageUrl: url,
      httpHeaders: _photoHeaders,
      fit: fit,
      placeholder: (context, url) =>
          ColoredBox(color: scheme.surfaceContainerHighest),
      errorWidget: (context, url, error) => ColoredBox(
        color: scheme.surfaceContainerHighest,
        child: Icon(Icons.landscape_outlined,
            size: 40, color: scheme.onSurfaceVariant),
      ),
    );
  }
}