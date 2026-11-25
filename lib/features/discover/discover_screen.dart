import 'package:material_ui/material_ui.dart';
import 'package:go_router/go_router.dart';

class DiscoverScreen extends StatelessWidget {
  const DiscoverScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Discover')),
      body: Center(
        child: FilledButton(
          // Temporary test: opens a pushed screen over the bottom bar.
          onPressed: () => context.push('/destination/narangala'),
          child: const Text('Open a sample destination'),
        ),
      ),
    );
  }
}