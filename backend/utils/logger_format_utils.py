import json


def log_safe_json(logger, message, data):
    """安全记录包含 JSON 数据的日志"""
    json_str = json.dumps(data, ensure_ascii=False)
    safe_json_str = json_str.replace('{', '{{').replace('}', '}}')
    logger.info(f"{message}: {safe_json_str}")