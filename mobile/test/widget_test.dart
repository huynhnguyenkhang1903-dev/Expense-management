import 'package:flutter_test/flutter_test.dart';
import 'package:moneyflow/main.dart';

void main() {
  testWidgets('MoneyFlow app smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const MoneyFlowApp());
    expect(find.text('MoneyFlow'), findsWidgets);
  });
}
