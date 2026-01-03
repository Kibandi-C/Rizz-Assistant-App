import 'package:flutter/material.dart';
import '../models/chat_message.dart';
import '../models/tone.dart';
import '../services/gemini_service.dart';
import '../services/prompt_builder.dart';

class ChatProvider extends ChangeNotifier {
  final GeminiService _geminiService;
  
  final List<ChatMessage> _messages = [];
  List<String> _generatedResponses = [];
  Tone _selectedTone = Tone.witty;
  double _riskLevel = 50.0;
  bool _isLoading = false;

  ChatProvider(this._geminiService);

  DateTime? _lastRequestTime;
  static const int _cooldownSeconds = 6;


  // Getters
  List<ChatMessage> get messages => _messages;
  List<String> get generatedResponses => _generatedResponses;
  Tone get selectedTone => _selectedTone;
  double get riskLevel => _riskLevel;
  bool get isLoading => _isLoading;

  // Setters
  bool get canSendRequest {
    if (_lastRequestTime == null) return true;
    return DateTime.now()
        .difference(_lastRequestTime!)
        .inSeconds >= _cooldownSeconds;
  }

  void setSelectedTone(Tone tone) {
    _selectedTone = tone;
    notifyListeners();
  }

  void setRiskLevel(double level) {
    _riskLevel = level;
    notifyListeners();
  }

  void addManualMessage(String text, MessageSender sender) {
    _messages.add(ChatMessage(text: text, sender: sender));
    notifyListeners();
  }

  void removeMessage(int index) {
    if (index >= 0 && index < _messages.length) {
      _messages.removeAt(index);
      notifyListeners();
    }
  }

  Future<void> generateReplies() async {
    if (_messages.isEmpty || !canSendRequest) return;

    _isLoading = true;
    _generatedResponses = [];
    notifyListeners();

    try {
      _lastRequestTime = DateTime.now();

      final prompt = PromptBuilder.buildReplyPrompt(
        history: _messages,
        tone: _selectedTone,
        riskLevel: _riskLevel,
      );

      _generatedResponses =
      await _geminiService.generateResponses(prompt);
    } on GeminiQuotaException {
      _generatedResponses = [
        "AI limit reached. Try again later.",
        "",
        ""
      ];
    } catch (_) {
      _generatedResponses = [
        "AI is temporarily unavailable.",
        "",
        ""
      ];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }


  Future<void> generatePickupLines({String? topic}) async {
    _isLoading = true;
    _generatedResponses = [];
    notifyListeners();
    
    try {
      final prompt = PromptBuilder.buildPickupLinePrompt(
        tone: _selectedTone,
        riskLevel: _riskLevel,
        topic: topic,
      );
      
      _generatedResponses = await _geminiService.generateResponses(prompt);
    } catch (e) {
      _generatedResponses = ["Error generating pickup lines: $e", "", ""];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

    void clearMessages() {
    _messages.clear();
    notifyListeners();
    }
  }

