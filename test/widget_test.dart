import 'package:flutter_test/flutter_test.dart';
import 'package:offpath/app.dart';

void main() {
  testWidgets('App opens on Discover and switches tabs', (tester) async {
    await tester.pumpWidget(const OffPathApp());
    await tester.pumpAndSettle();

    // Discover appears twice: the app bar title and the tab label.
    expect(find.text('Discover'), findsNWidgets(2));
    expect(find.text('Explore'), findsOneWidget);
    expect(find.text('Saved'), findsOneWidget);
    expect(find.text('Profile'), findsOneWidget);

    // Tap the Explore tab and check its screen is shown.
    await tester.tap(find.text('Explore'));
    await tester.pumpAndSettle();
    expect(find.text('Search and filters coming in 2.6'), findsOneWidget);
  });
}