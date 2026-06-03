import 'package:flutter_test/flutter_test.dart';
import 'package:snack_bazaar/app.dart';

void main() {
  testWidgets('Admin Portal smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const SnackBazaarApp());

    // Verify the admin portal loads with key elements
    expect(find.text('Admin Portal'), findsOneWidget);
    expect(find.text('Verification Queue'), findsOneWidget);
    expect(find.text('Nourish Naturals'), findsOneWidget);
  });
}
