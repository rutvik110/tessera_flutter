pub mod tessera;

/// Called once from `RustLib.init` before any extractor is loaded.
#[flutter_rust_bridge::frb(init)]
pub fn init_app() {
    flutter_rust_bridge::setup_default_user_utils();
}
