# tessera_flutter

Flutter plugin that runs [Tessera](https://github.com/theiskaa/tessera) on device through [flutter_rust_bridge](https://cjycode.com/flutter_rust_bridge/). Other apps depend on this package and call Dart; the Rust extractor and its weight bundle are compiled into the plugin.

Tessera finds people, organizations, postal addresses, emails, and phone numbers. It returns the matching text, UTF-16 offsets (`text.substring(start, end)`), confidence, and, for addresses, labelled components. Related details can be grouped into contacts.

The current model is experimental and was evaluated on English United States text. Pass `countryHint: ['US']` (the default on the `Tessera` class) so national phone numbers are recognized. No text leaves the device.

## Layout

This plugin expects the Tessera checkout as a sibling directory:

```
projects/
  tessera/            # git clone of https://github.com/theiskaa/tessera
  tessera_flutter/    # this plugin
```

`rust/Cargo.toml` depends on `../../tessera/tessera`. The Safetensors bundle shipped in `rust/models/` is compiled into the native library. Weights are CC BY 4.0; see `third_party/tessera/NOTICE`.

## Use it from an app

```yaml
dependencies:
  tessera_flutter:
    path: ../tessera_flutter
```

```dart
import 'package:tessera_flutter/tessera_flutter.dart';

final tessera = await Tessera.open();
final text =
    'Jordan Avery\nAcme Corporation\n500 Main St, Springfield, IL 62701\njordan@acme.example';
final entities = await tessera.detect(text);
final contacts = await tessera.extractContacts(text);
final address = await tessera.parseAddress('400 Broad St, Seattle, WA 98109');
tessera.dispose();
```

`Tessera.open` loads every kind. Pass `kinds: [EntityKind.email, EntityKind.phone]` for the rules-only extractor, which does not need the neural nets.

`detect` and `extractContacts` take:

- `countryHint` — region codes for numbers written without a country code. Defaults to `['US']`. Pass an empty list to let Tessera infer regions from the document.
- `includeUncertain` — also return low-confidence results. Internal detector thresholds still apply.
- `format` — `InputFormat.plain` or `InputFormat.markdown`. Markdown scans prose and `mailto:` / `tel:` link destinations. Tune that with `markdown`.

Offsets are UTF-16 code units and `end` is exclusive. Each entity also carries its own `text`.

This package is set up for iOS and macOS. Building an app that depends on it requires [rustup](https://rustup.rs/) (Rust 1.96, pinned by `rust-toolchain.toml`). Cargokit compiles the Rust crate into a static library during the Xcode build.

Regenerate the bridge after changing `rust/src/api`:

```shell
flutter_rust_bridge_codegen generate
```

## Example

```shell
cd example
flutter run -d macos
```
