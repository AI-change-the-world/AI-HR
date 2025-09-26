import 'package:shared_preferences/shared_preferences.dart';

class AIConfig {
  static const String _aiEnabledKey = 'ai_enabled';
  static const String _baseUrlKey = 'base_url';
  static const String _apiKeyKey = 'api_key';
  static const String _modelNameKey = 'model_name';
  static const String _companyNameKey = 'company_name';
  static const String _companyDescriptionKey = 'company_description';
  static const String _aiSecretKey = 'ai_secret';

  static bool _aiEnabled = false;
  static String _baseUrl = '';
  static String _apiKey = '';
  static String _modelName = '';
  static String _companyName = '';
  static String _companyDescription = '';
  static String _aiSecret = '';

  // 初始化配置
  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _aiEnabled = prefs.getBool(_aiEnabledKey) ?? false;
    _baseUrl = prefs.getString(_baseUrlKey) ?? '';
    _apiKey = prefs.getString(_apiKeyKey) ?? '';
    _modelName = prefs.getString(_modelNameKey) ?? '';
    _companyName = prefs.getString(_companyNameKey) ?? '';
    _companyDescription = prefs.getString(_companyDescriptionKey) ?? '';
    _aiSecret = prefs.getString(_aiSecretKey) ?? '';
  }

  // 获取AI是否启用
  static bool get aiEnabled => _aiEnabled;

  // 获取Base URL
  static String get baseUrl => _baseUrl;

  // 获取API Key
  static String get apiKey => _apiKey;

  // 获取模型名称
  static String get modelName => _modelName;

  // 获取公司名称
  static String get companyName => _companyName;

  // 获取公司介绍
  static String get companyDescription => _companyDescription;

  // 获取加密的ai
  static String get aiSecret => _aiSecret;

  // 设置AI启用状态
  static Future<void> setAiEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_aiEnabledKey, enabled);
    _aiEnabled = enabled;
  }

  // 设置Base URL
  static Future<void> setBaseUrl(String url) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_baseUrlKey, url);
    _baseUrl = url;
  }

  // 设置API Key
  static Future<void> setApiKey(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_apiKeyKey, key);
    _apiKey = key;
  }

  // 设置模型名称
  static Future<void> setModelName(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_modelNameKey, name);
    _modelName = name;
  }

  // 设置公司名称
  static Future<void> setCompanyName(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_companyNameKey, name);
    _companyName = name;
  }

  // 设置公司介绍
  static Future<void> setCompanyDescription(String description) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_companyDescriptionKey, description);
    _companyDescription = description;
  }

  // 设置加密的AI
  static Future<void> setAISecret(String ai) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_aiSecretKey, ai);
    _aiSecret = ai;
  }
}
