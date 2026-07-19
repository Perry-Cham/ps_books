// =============================================================================
// mangodl_flutter — Educational Flutter port of mangodl-nodejs.
// See lib/parsers/base.dart for the project-wide disclaimer.
// =============================================================================

// -----------------------------------------------------------------------------
// lib/parsers/registry.dart — Parser registry.
//
// Direct port of `src/parsers/index.js`. The only meaningful difference
// is that Dart uses a class with static methods rather than a module
// with exported functions — Dart's module system is more restrictive
// than ESM, and static-method-on-a-class is the idiomatic way to
// expose module-level state.
// -----------------------------------------------------------------------------

import 'base.dart';
import 'weebcentral.dart';

class ParserRegistry {
  static final Map<String, BaseParser> _parsers = {};
  static bool _initialized = false;

  /// Ensure built-in parsers are registered. Safe to call multiple
  /// times — idempotent. We call this from every public method so
  /// tests that import the library without ever calling [register]
  /// still see the built-in parsers.
  static void _ensureInitialized() {
    if (_initialized) return;
    _initialized = true;
    // Register built-in parsers. New parsers should be added here.
    _parsers[WeebCentralParser().key] = WeebCentralParser();
  }

  /// Register a parser instance. Throws if a parser with the same key
  /// is already registered.
  static void register(BaseParser parser) {
    _ensureInitialized();
    if (_parsers.containsKey(parser.key)) {
      throw StateError('Parser "${parser.key}" is already registered');
    }
    _parsers[parser.key] = parser;
  }

  /// Look up a parser by key. Throws if not found.
  static BaseParser get(String key) {
    _ensureInitialized();
    final p = _parsers[key];
    if (p == null) throw ArgumentError('Unknown parser: $key');
    return p;
  }

  /// Return all registered parsers as a list of {key, displayName} maps.
  /// Used by the UI to populate the parser dropdown.
  static List<Map<String, String>> all() {
    _ensureInitialized();
    return _parsers.values
        .map((p) => {'key': p.key, 'displayName': p.displayName})
        .toList();
  }

  /// Convenience: the default parser. Currently hardcoded to
  /// WeebCentral — same as the JS version.
  static BaseParser defaultParser() => get('weebcentral');
}
