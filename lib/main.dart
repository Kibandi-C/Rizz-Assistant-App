import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'providers/chat_provider.dart';
import 'services/gemini_service.dart';
import 'screens/home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  await dotenv.load(fileName: ".env");

  final geminiApiKey = dotenv.env['GEMINI_API_KEY'];

  if (geminiApiKey == null || geminiApiKey.isEmpty) {
    throw Exception('GEMINI_API_KEY not found in .env file');
  }

  final geminiService = GeminiService(geminiApiKey);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => ChatProvider(geminiService),
        ),
      ],
      child: const RizzAssistantApp(),
    ),
  );
}

class RizzAssistantApp extends StatelessWidget {
  const RizzAssistantApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Rizz Assistant',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark,
        ),
      ),
      home: const HomeScreen(),
    );
  }
}
