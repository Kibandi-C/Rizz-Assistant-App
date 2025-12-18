import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/chat_provider.dart';
import 'services/gemini_service.dart';
import 'screens/home_screen.dart';

void main() {
  // TODO: Replace with your actual Gemini API Key
  const String geminiApiKey = 'AIzaSyBdPTVtOAZyeBfdMA4XCsTIOigIzaOPHxU';
  
  final geminiService = GeminiService(geminiApiKey);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ChatProvider(geminiService)),
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
