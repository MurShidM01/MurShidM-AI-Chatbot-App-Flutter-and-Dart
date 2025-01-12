import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../config/app_config.dart';
import '../utils/network_util.dart';

class GeminiService {
  static final GeminiService _instance = GeminiService._internal();
  late final GenerativeModel _model;
  static const int maxRetries = 3;
  
  static const List<String> promptVariations = [
    "Please provide a unique response to: ",
    "Could you help me understand: ",
    "I'd like your perspective on: ",
    "What are your thoughts about: ",
    "How would you explain: "
  ];

  factory GeminiService() {
    return _instance;
  }

  GeminiService._internal() {
    _model = GenerativeModel(
      model: 'gemini-pro',
      apiKey: AppConfig.geminiApiKey,
    );
  }

  String _getRandomPromptVariation() {
    return promptVariations[DateTime.now().millisecondsSinceEpoch % promptVariations.length];
  }

  Future<String> getResponse(String prompt, {int retryCount = 0}) async {
    try {
      // Check network connectivity first
      final bool isConnected = await NetworkUtil.checkInternetConnection();
      if (!isConnected) {
        throw Exception('No internet connection. Please check your network settings and try again.');
      }

      // Add variation to the prompt if retrying
      final enhancedPrompt = retryCount > 0 
          ? '${_getRandomPromptVariation()}$prompt\nPlease provide a unique and original response.'
          : prompt;

      final content = [Content.text(enhancedPrompt)];
      final response = await _model.generateContent(content);
      
      if (response.text == null || response.text!.isEmpty) {
        throw Exception('Failed to generate response. Please try again.');
      }

      return response.text!.trim();
    } catch (e) {
      if (e.toString().contains('API key')) {
        throw Exception('API key error. Please check your configuration.');
      } 
      // Handle recitation error with retry
      else if (e.toString().contains('recitation') && retryCount < maxRetries) {
        // Wait briefly before retrying
        await Future.delayed(Duration(milliseconds: 500 * (retryCount + 1)));
        return getResponse(prompt, retryCount: retryCount + 1);
      }
      // If we've exhausted retries or it's a different error
      else if (e.toString().contains('recitation')) {
        throw Exception(
          'I apologize, but I need to rephrase my response to be more original. '
          'Please try asking your question differently or provide more specific details.'
        );
      }
      
      throw Exception(e.toString());
    }
  }

  Future<String> generateTitle(String firstMessage) async {
    try {
      const titlePrompt = '''
Generate a very short, unique title (3-4 words) that captures the essence of this conversation.
Message: """;

Keep the title concise, creative, and relevant.
Title only, no quotes or explanations.
""";
''';

      final content = [Content.text('$titlePrompt$firstMessage')];
      final response = await _model.generateContent(content);
      
      if (response.text == null || response.text!.isEmpty) {
        return 'New Chat ${DateTime.now().toString().substring(11, 16)}';
      }

      return response.text!.trim();
    } catch (_) {
      // For titles, just generate a timestamp-based one if there's any error
      return 'Chat ${DateTime.now().toString().substring(11, 16)}';
    }
  }
}
