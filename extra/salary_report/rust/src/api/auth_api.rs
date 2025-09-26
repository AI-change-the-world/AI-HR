use flutter_rust_bridge::frb;

use crate::auth::auth_ai::AiInfo;

#[frb(sync)]
pub fn decrypt(secret_str: String) -> Option<AiInfo> {
    let obj = crate::auth::auth_ai::decrypt_ai_info(&secret_str);
    match obj {
        Ok(obj) => Some(obj),
        Err(_e) => {
            println!("decrypt error: {}", _e);
            return None;
        }
    }
}
