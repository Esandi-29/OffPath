import 'package:material_ui/material_ui.dart';

/// Shown briefly at start-up while Firebase restores the signed-in user.
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.landscape_rounded, size: 64, color: scheme.primary),
            const SizedBox(height: 8),
            Text('OffPath', style: Theme.of(context).textTheme.headlineLarge),
            const SizedBox(height: 24),
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}