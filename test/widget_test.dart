import 'package:flutter_test/flutter_test.dart';
import 'package:inventory_manager/main.dart';

void main() {
  testWidgets('application starts at login screen', (tester) async {
    await tester.pumpWidget(const InventoryApp());
    await tester.pump();

    expect(find.text('مخزني'), findsOneWidget);
    expect(find.text('دخول'), findsOneWidget);
  });
}
