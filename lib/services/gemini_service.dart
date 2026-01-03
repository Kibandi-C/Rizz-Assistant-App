import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

class GeminiService {
  static const String _endpoint =
      'https://generativelanguage.googleapis.com/v1/models/gemini-2.5-flash:generateContent';

  final String apiKey;
  GeminiService(this.apiKey);

  Future<List<String>> generateResponses(String prompt) async {
    if (apiKey.isEmpty) {
      throw Exception('API key missing');
    }

    int attempts = 0;
    const int maxRetries = 5;

    while (true) {
      try {
        final response = await http
            .post(
          Uri.parse('$_endpoint?key=$apiKey'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'contents': [
              {
                'parts': [
                  {'text': prompt}
                ]
              }
            ],
            'generationConfig': {
              'candidateCount': 3,
            }
          }),
        )
            .timeout(const Duration(seconds: 15));

        if (response.statusCode == 200) {
          final decoded = jsonDecode(response.body);
          final candidates = decoded['candidates'];

          if (candidates == null || candidates.isEmpty) {
            return _fallbackResponses();
          }

          final responses = <String>[];

          for (final c in candidates) {
            final text = c['content']?['parts']?[0]?['text'];
            if (text != null && text.toString().trim().isNotEmpty) {
              responses.add(text.toString().trim());
            }
          }

          return responses.isEmpty
              ? _fallbackResponses()
              : responses.take(3).toList();
        }

        // Quota exceeded
        if (response.statusCode == 429) {
          throw GeminiQuotaException();
        }

        throw Exception('Gemini error ${response.statusCode}');
      } on TimeoutException {
        if (++attempts > maxRetries) {
          throw Exception('Request timed out');
        }
      } on GeminiQuotaException {
        rethrow;
      } catch (e) {
        if (++attempts > maxRetries) {
          throw Exception('AI unavailable');
        }
      }
    }
  }

  List<String> _fallbackResponses() => [
    "Hmm… say something playful and confident 😉",
    "Keep it light and curious.",
    "A simple, genuine reply works best."
  ];
}

class GeminiQuotaException implements Exception {}
