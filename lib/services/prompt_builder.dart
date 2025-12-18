import '../models/chat_message.dart';
import '../models/tone.dart';

class PromptBuilder {
  static String buildReplyPrompt({
    required List<ChatMessage> history,
    required Tone tone,
    required double riskLevel,
  }) {
    final historyContext = history.map((m) {
      final sender = m.sender == MessageSender.me ? 'User' : 'Other Person';
      return '$sender: ${m.text}';
    }).join('\n');

    return '''
You are a "Rizz Assistant". Based on the chat history below, generate 3 potential replies the User could send.

Chat History:
$historyContext

Requirements:
- Tone: ${tone.label}
- Risk Level: $riskLevel/100 (0=safe/boring, 100=extreme/bold)
- Return EXACTLY 3 lines.
- No numbering (e.g., do NOT start with 1. 2. 3.).
- No explanations or additional text.
- Use natural texting language (lowercase, slang if appropriate, emojis sparingly).
- Each response on a new line.
''';
  }

  static String buildPickupLinePrompt({
    required Tone tone,
    required double riskLevel,
    String? topic,
  }) {
    final topicContext = topic != null ? 'Topic: $topic' : 'No specific topic';

    return '''
You are a "Rizz Assistant". Generate 3 original pickup lines.

Context:
$topicContext

Requirements:
- Tone: ${tone.label}
- Risk Level: $riskLevel/100 (0=safe, 100=bold/cheeky)
- Return EXACTLY 3 lines.
- No numbering.
- No explanations.
- Natural texting language.
- Each response on a new line.
''';
  }
}
