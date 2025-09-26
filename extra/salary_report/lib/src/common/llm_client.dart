import 'package:openai_dart/openai_dart.dart';
import 'package:salary_report/src/common/ai_config.dart';
import 'package:salary_report/src/common/logger.dart';
import 'package:salary_report/src/common/toast.dart';
import 'package:salary_report/src/rust/api/auth_api.dart';
import 'package:salary_report/src/rust/auth/auth_ai.dart'; // 添加日志导入

class LLMClient {
  // ignore: avoid_init_to_null
  late OpenAIClient? _client = null;
  late String _modelName = 'gpt-3.5-turbo';
  LLMClient() {
    if (AIConfig.aiEnabled) {
      // 优先使用加密的ai
      if (AIConfig.aiSecret != "") {
        AiInfo? aiInfo = decrypt(secretStr: AIConfig.aiSecret);
        if (aiInfo != null) {
          _client = OpenAIClient(
            baseUrl: AIConfig.baseUrl,
            apiKey: aiInfo.apiKey,
          );
          _modelName = aiInfo.modelName;
        } else {
          ToastUtils.error(
            null,
            title: "加密信息有误，无法启动AI",
            descryption: "若同时配置了明文信息，可以删除密文之后重试",
          );
        }
        return;
      }

      if (AIConfig.baseUrl != "" && AIConfig.apiKey != "") {
        _client = OpenAIClient(
          apiKey: AIConfig.apiKey,
          baseUrl: AIConfig.baseUrl,
        );
        _modelName = AIConfig.modelName;
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
            model: ChatCompletionModel.modelId(_modelName),
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
