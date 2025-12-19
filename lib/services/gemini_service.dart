import 'dart:convert';
import 'package:http/http.dart' as http;

class GeminiService {
  final String _apiKey;

  static const String _endpoint =
      'https://generativelanguage.googleapis.com/v1/models/gemini-2.5-flash:generateContent';

  GeminiService(this._apiKey);

  Future<List<String>> generateResponses(String prompt) async {
    if (_apiKey.isEmpty) {
      throw Exception('Gemini API key is not set.');
    }

    final response = await http.post(
      Uri.parse('$_endpoint?key=$_apiKey'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "contents": [
          {
            "parts": [
              {"text": prompt}
            ]
          }
        ],
        "generationConfig": {
          "temperature": 0.9,
          "candidateCount": 3,
        }
      }),
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to load response: ${response.statusCode} ${response.body}',
      );
    }

    final data = jsonDecode(response.body);

    final candidates = data['candidates'] as List?;
    if (candidates == null || candidates.isEmpty) {
      return ['No response generated.', '', ''];
    }

    final text =
    candidates[0]['content']['parts'][0]['text'] as String;

    final lines = text
        .split('\n')
        .where((l) => l.trim().isNotEmpty)
        .take(3)
        .toList();

    while (lines.length < 3) {
      lines.add('');
    }

    return lines;
  }
}
