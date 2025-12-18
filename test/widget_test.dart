// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:rizz_assistant/main.dart';
import 'package:rizz_assistant/services/gemini_service.dart';
import 'package:rizz_assistant/providers/chat_provider.dart';
import 'package:provider/provider.dart';

void main() {
  testWidgets('Rizz Assistant smoke test', (WidgetTester tester) async {
    final geminiService = GeminiService('dummy_key');

    // Build our app and trigger a frame.
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => ChatProvider(geminiService)),
        ],
        child: const RizzAssistantApp(),
      ),
    );

    // Verify that our app starts with the title.
    expect(find.text('Rizz Assistant'), findsOneWidget);
  });
}
