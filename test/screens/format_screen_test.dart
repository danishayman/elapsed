import 'package:elapsed/screens/format_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class _FormatHarness extends StatefulWidget {
  const _FormatHarness();

  @override
  State<_FormatHarness> createState() => _FormatHarnessState();
}

class _FormatHarnessState extends State<_FormatHarness> {
  String result = 'none';

  Future<void> _openFormat() async {
    final selected = await Navigator.of(context).push<String>(
      MaterialPageRoute(
        builder: (_) => const FormatScreen(selectedFormat: 'Days'),
      ),
    );

    setState(() {
      result = selected ?? 'null';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          ElevatedButton(onPressed: _openFormat, child: const Text('open')),
          Text('result:$result'),
        ],
      ),
    );
  }
}

void main() {
  testWidgets('returns the selected format when back is pressed', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: _FormatHarness()));

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Weeks'));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();

    expect(find.text('result:Weeks'), findsOneWidget);
  });
}
