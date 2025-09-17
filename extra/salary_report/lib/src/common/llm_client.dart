import 'package:openai_dart/openai_dart.dart';
import 'package:salary_report/src/common/ai_config.dart';
import 'package:salary_report/src/common/logger.dart'; // 添加日志导入

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

  Future<String> getAnswer(String question, {ResponseFormat? format}) async {
    if (_client != null) {
      logger.info("getAnswer: $question");
      try {
        final messages = [
          ChatCompletionMessage.user(
            content: ChatCompletionUserMessageContent.string(question),
          ),
        ];
        final res = await _client!.createChatCompletion(
          request: CreateChatCompletionRequest(
            model: ChatCompletionModel.modelId(AIConfig.modelName),
            messages: messages,
            responseFormat: format,
          ),
        );
        return res.choices.first.message.content ?? "";
      } catch (e) {
        logger.info('调用AI接口时出错: $e');
        return "";
      }
    }

    return "";
  }
}
