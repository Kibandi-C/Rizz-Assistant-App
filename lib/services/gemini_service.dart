import 'dart:convert';
import 'package:http/http.dart' as http;

class GeminiService {
  final String _apiKey;
  final String _baseUrl = "https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent";

  GeminiService(this._apiKey);

  Future<List<String>> generateResponses(String prompt) async {
    if (_apiKey == 'YOUR_GEMINI_API_KEY_HERE' || _apiKey.isEmpty) {
      throw Exception('Gemini API key is not set.');
    }

    final headers = {'Content-Type': 'application/json'};
    final body = json.encode({
      'contents': [
        {
          'parts': [{'text': prompt}]
        }
      ],
      'generationConfig': {
        'candidateCount': 3, // Request 3 responses
      },
    });

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl?key=$_apiKey'),
        headers: headers,
        body: body,
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        final candidates = jsonResponse['candidates'] as List;

        if (candidates.isEmpty) {
          return ['No responses generated.', '', ''];
        }

        // Extract and split the responses. The prompt builder ensures 3 lines.
        final List<String> extractedResponses = [];
        for (var candidate in candidates) {
          final text = candidate['content']['parts'][0]['text'] as String;
          extractedResponses.addAll(text.split('\n').where((s) => s.trim().isNotEmpty));
        }
        
        // Ensure exactly 3 responses, padding if necessary or truncating
        while (extractedResponses.length < 3) {
          extractedResponses.add('');
        }
        return extractedResponses.sublist(0, 3);

      } else {
        throw Exception(
            'Failed to load response: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      print("Error in GeminiService: $e"); // Log the error for debugging
      return ['Error: $e', '', ''];
    }
  }
}
