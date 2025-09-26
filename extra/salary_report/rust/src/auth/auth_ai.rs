use serde::{Deserialize, Serialize};
use serde_json;
// 引入加密相关的库
use aes_gcm::{
    aead::{Aead, KeyInit, OsRng},
    AeadCore, Aes256Gcm, Nonce,
};
use base64::{engine::general_purpose::STANDARD as BASE64_STANDARD, Engine as _};

const KEY: &'static str = "60009e83ae766e54cebccba1e0da67a734566ac6059767f49b773c661e5c79a5";

#[derive(Serialize, Deserialize, Debug, PartialEq)]
pub struct AiInfo {
    pub base_url: String,
    pub api_key: String,
    pub model_name: String,
    pub expired_time: i64,
}

impl AiInfo {
    pub fn is_valid(&self) -> bool {
        self.expired_time
            > std::time::SystemTime::now()
                .duration_since(std::time::UNIX_EPOCH)
                .unwrap()
                .as_secs() as i64
    }
}

/// 将 AiInfo 实例加密成一个 Hex 字符串
///
/// # Arguments
/// * `info` - 需要加密的 AiInfo 结构体实例
/// * `key` - 256位 (32字节) 的加密密钥
///
/// # Returns
/// 返回一个 Result，成功时是包含 Nonce 和密文的 Hex 字符串
pub fn encrypt_ai_info(info: &AiInfo) -> anyhow::Result<String> {
    let key: [u8; 32] = hex::decode(KEY)?.as_slice().try_into()?;

    // 1. 将结构体序列化为 JSON 字符串，然后转为字节
    let plaintext = serde_json::to_string(info)?;
    let plaintext_bytes = plaintext.as_bytes();

    // 2. 初始化 AES-256-GCM 加密器
    let cipher = Aes256Gcm::new(&key.into());

    // 3. 生成一个随机的、唯一的 Nonce (12字节)
    // 对于 GCM 模式，每次使用相同的密钥加密时，Nonce 都必须是唯一的！
    // 使用 OsRng 可以生成加密安全的随机数。
    let nonce = Aes256Gcm::generate_nonce(&mut OsRng);

    // 4. 加密数据
    let ciphertext = cipher.encrypt(&nonce, plaintext_bytes);

    if ciphertext.is_err() {
        anyhow::bail!("Failed to encrypt data.");
    }

    // 5. 将 Nonce 和密文拼接在一起 (nonce || ciphertext)
    let mut result = nonce.to_vec();
    result.extend_from_slice(&ciphertext.unwrap());

    // 6. 将拼接后的字节流编码为 Hex 字符串，方便存储
    Ok(BASE64_STANDARD.encode(result))
}

/// 将加密的 Hex 字符串解密回 AiInfo 实例
///
/// # Arguments
/// * `encrypted_hex` - 经过加密和 Hex 编码的字符串
/// * `key` - 用于加密的同一个 256位 (32字节) 密钥
///
/// # Returns
/// 返回一个 Result，成功时是解密后的 AiInfo 结构体实例
pub fn decrypt_ai_info(encrypted_hex: &str) -> anyhow::Result<AiInfo> {
    let key: [u8; 32] = hex::decode(KEY)?.as_slice().try_into()?;

    // 1. 从 Hex 字符串解码回字节流
    let encrypted_data = BASE64_STANDARD.decode(encrypted_hex)?;

    // Nonce 是 12 字节
    let nonce_size = 12;
    if encrypted_data.len() < nonce_size {
        anyhow::bail!("Invalid encrypted data.");
    }

    // 2. 从数据中分离 Nonce 和密文
    let (nonce_bytes, ciphertext) = encrypted_data.split_at(nonce_size);
    let nonce = Nonce::from_slice(nonce_bytes);

    // 3. 初始化解密器
    let cipher = Aes256Gcm::new(&key.into());

    // 4. 解密数据
    let decrypted_bytes = cipher.decrypt(nonce, ciphertext);
    if decrypted_bytes.is_err() {
        anyhow::bail!("Failed to decrypt data.");
    }

    // 5. 将解密后的字节转换回 UTF-8 字符串 (JSON)
    let decrypted_json = String::from_utf8(decrypted_bytes.unwrap())?;

    // 6. 将 JSON 字符串反序列化为 AiInfo 结构体
    let info: AiInfo = serde_json::from_str(&decrypted_json)?;

    if !info.is_valid() {
        anyhow::bail!("Invalid AI info.");
    }

    Ok(info)
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_encrypt_and_decrypt() -> anyhow::Result<()> {
        let current_time = std::time::SystemTime::now()
            .duration_since(std::time::UNIX_EPOCH)
            .unwrap()
            .as_secs() as i64;

        let thirty_days = 60 * 60 * 24 * 30;
        let expired_time = current_time + thirty_days;

        let info = AiInfo {
            base_url: "https://api.openai.com/v1/chat/completions".to_string(),
            api_key: "sk-xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx".to_string(),
            model_name: "gpt-3.5-turbo".to_string(),
            expired_time,
        };

        let encrypted = encrypt_ai_info(&info)?;

        println!("encrypted: {}", encrypted);

        let decrypted = decrypt_ai_info(&encrypted)?;

        assert_eq!(info, decrypted);

        anyhow::Ok(())
    }

    // cargo test test_encrypt_and_decrypt_env -- --nocapture
    #[test]
    fn test_encrypt_and_decrypt_env() -> anyhow::Result<()> {
        let current_time = std::time::SystemTime::now()
            .duration_since(std::time::UNIX_EPOCH)
            .unwrap()
            .as_secs() as i64;

        let thirty_days = 60 * 60 * 24 * 30;
        let expired_time = current_time + thirty_days;

        use std::env;
        let mut _api_key = String::new();
        if let Ok(temp) = env::var("OPENAI_API_KEY") {
            _api_key = temp;
        } else {
            anyhow::bail!("TEMP 环境变量未设置");
        }

        let info = AiInfo {
            base_url: "https://dashscope.aliyuncs.com/compatible-mode/v1".to_string(),
            api_key: _api_key,
            model_name: "qwen-max".to_string(),
            expired_time,
        };

        let encrypted = encrypt_ai_info(&info)?;

        eprintln!("encrypted: {}", encrypted);

        let decrypted = decrypt_ai_info(&encrypted)?;

        assert_eq!(info, decrypted);

        anyhow::Ok(())
    }
}
