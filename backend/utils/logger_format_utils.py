import json


def log_safe_json(logger, message, data):
    """安全记录包含 JSON 数据的日志"""
    if isinstance(data, str):  # 确保数据是字典
        json_str = data
    else:
        json_str = json.dumps(data, ensure_ascii=False)
    safe_json_str = json_str.replace('{', '{{').replace('}', '}}')
    logger.info(f"{message}: {safe_json_str}")