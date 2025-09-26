#[flutter_rust_bridge::frb(sync)] // Synchronous mode for simplicity of the demo
pub fn greet(name: String) -> String {
    format!("Hello, {name}!")
}

#[flutter_rust_bridge::frb(init)]
pub fn init_app() {
    // Default utilities - feel free to customize
    flutter_rust_bridge::setup_default_user_utils();
}

#[flutter_rust_bridge::frb(sync)]
pub fn beep() {
    if cfg!(windows) {
        beep_windows();
    }
}

#[cfg(target_os = "windows")]
fn beep_windows() {
    use windows_sys::Win32::System::Diagnostics::Debug::MessageBeep;
    use windows_sys::Win32::UI::WindowsAndMessaging::MB_ICONASTERISK;
    unsafe {
        // 播放提示音
        MessageBeep(MB_ICONASTERISK);
    }
}
