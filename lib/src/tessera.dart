import 'rust/api/tessera.dart';
import 'rust/frb_generated.dart';

/// On-device Tessera extractor.
///
/// [open] loads the weight bundle compiled into this plugin. Call [dispose]
/// when the app is finished with it. One instance can serve many calls.
class Tessera {
  Tessera._(this._extractor);

  final Extractor _extractor;
  static Future<void>? _ready;

  /// Loads the native library once, then the extractor.
  ///
  /// An empty [kinds] list serves every kind. Email and phone alone use
  /// validating rules and do not read the neural nets.
  static Future<Tessera> open({List<EntityKind> kinds = const []}) async {
    _ready ??= RustLib.init();
    await _ready;
    return Tessera._(await Extractor.load(kinds: kinds));
  }

  /// Kinds this extractor was loaded for, in taxonomy order.
  Future<List<EntityKind>> kinds() => _extractor.kinds();

  /// Every supported entity in [text], in document order.
  ///
  /// [countryHint] defaults to `US`, which is what the shipped model was
  /// evaluated with. Pass an empty list to infer regions from the document.
  /// Offsets are UTF-16 code units; [text].substring(start, end) returns the span.
  Future<List<TextEntity>> detect(
    String text, {
    List<String> countryHint = const ['US'],
    bool includeUncertain = false,
    InputFormat format = InputFormat.plain,
    MarkdownScan? markdown,
  }) {
    return _extractor.detect(
      text: text,
      options: _options(
        countryHint: countryHint,
        includeUncertain: includeUncertain,
        format: format,
        markdown: markdown,
      ),
    );
  }

  /// Entities from [detect], grouped into contacts.
  ///
  /// Details the grouper will not assign are returned in
  /// [ContactExtraction.unassigned]. That is a successful result.
  Future<ContactExtraction> extractContacts(
    String text, {
    List<String> countryHint = const ['US'],
    bool includeUncertain = false,
    InputFormat format = InputFormat.plain,
    MarkdownScan? markdown,
  }) {
    return _extractor.extractContacts(
      text: text,
      options: _options(
        countryHint: countryHint,
        includeUncertain: includeUncertain,
        format: format,
        markdown: markdown,
      ),
    );
  }

  /// Splits text already known to be one address.
  ///
  /// The input must be a single address of at most 256 non-whitespace tokens
  /// and 8 KiB. Offsets are relative to [text].
  Future<TextEntity> parseAddress(
    String text, {
    bool includeUncertain = false,
  }) {
    return _extractor.parseAddress(
      text: text,
      includeUncertain: includeUncertain,
    );
  }

  /// Releases the native extractor.
  void dispose() => _extractor.dispose();

  CallOptions _options({
    required List<String> countryHint,
    required bool includeUncertain,
    required InputFormat format,
    MarkdownScan? markdown,
  }) {
    return CallOptions(
      countryHint: countryHint,
      includeUncertain: includeUncertain,
      format: format,
      markdown:
          markdown ??
          MarkdownScan(includeCode: false, includeHtml: false, gfmTables: true),
    );
  }
}
