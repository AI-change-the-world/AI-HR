import 'package:openai_dart/openai_dart.dart';
import 'package:salary_report/src/common/ai_config.dart';

class LLMClient {
  // ignore: avoid_init_to_null
  late OpenAIClient? _client = null;
  LLMClient() {
    if (AIConfig.aiEnabled) {
      if (AIConfig.baseUrl != "" && AIConfig.apiKey != "") {
        _client = OpenAIClient(
          apiKey: AIConfig.apiKey,
          baseUrl: AIConfig.baseUrl,
        );
      }
    }
  }

  Future<String> getAnswer(String question) async {
    if (_client != null) {
      final messages = [
        ChatCompletionMessage.user(
          content: ChatCompletionUserMessageContent.string(question),
        ),
      ];
      final res = await _client!.createChatCompletion(
        request: CreateChatCompletionRequest(
          model: ChatCompletionModel.modelId(AIConfig.modelName),
          messages: messages,
        ),
      );
      return res.choices.first.message.content ?? "";
    }

    return "";
  }
}
