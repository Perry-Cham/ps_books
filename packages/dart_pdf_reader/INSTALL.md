# Installing the fixed `dart_pdf_reader` as a drop-in replacement

This archive contains a patched version of `dart_pdf_reader` that fixes the
inconsistent PDF metadata retrieval bug. It is API-compatible with the
published `dart_pdf_reader: ^2.2.0` package — no source changes are required
in your project.

## What's fixed

See `CHANGELOG.md` for the full list. In short:

- **String decoding**: `PDFLiteralString.asString()` now uses the same
  algorithm as pdfjs's `stringToPDFString` — UTF-16BE/LE/UTF-8 BOM detection
  with PDFDocEncoding (Latin-1) fallback, plus language-escape stripping.
  This fixes "unknown" author values, truncated titles, and garbled non-ASCII
  metadata.
- **New metadata API**: `PDFDocument.getMetadata()` returns a `PDFMetadata`
  object with `title`, `author`, `subject`, `keywords`, `creator`,
  `producer`, `creationDate`, `modDate`, `version`, `language`, `custom`
  (non-standard Info keys), and `rawXmp`. Reads the trailer's `Info`
  dictionary first, then falls back to the catalog's XMP `Metadata` stream.
- **Date parsing**: `PDFMetadata.parseDate(String?)` parses PDF date strings
  (e.g. `D:20240101120000+02'00'`) into `DateTime`.

## Drop-in via `path` dependency (recommended)

1. Extract the archive somewhere stable on disk, e.g.:

   ```bash
   tar -xzf dart_pdf_reader-2.2.1-metadata-fix.tar.gz
   # Creates a directory named dart_pdf_reader/
   ```

2. In your project's `pubspec.yaml`, replace any existing
   `dart_pdf_reader: ^2.2.0` line with a `path` dependency:

   ```yaml
   dependencies:
     dart_pdf_reader:
       path: /absolute/path/to/dart_pdf_reader
   ```

   (A relative path also works, e.g. `path: ../dart_pdf_reader`.)

3. Run `dart pub get`.

4. Use the new metadata API (optional — your existing code continues to
   work unchanged):

   ```dart
   import 'package:dart_pdf_reader/dart_pdf_reader.dart';

   final stream = ByteStream(File(inputFile).readAsBytesSync());
   final doc = await PDFParser(stream).parse();
   final metadata = await doc.getMetadata();
   print(metadata.title);
   print(metadata.author);
   ```

## Drop-in via `dependency_overrides`

If you cannot change the `dependencies` block (e.g. another package pulls in
`dart_pdf_reader`), use `dependency_overrides`:

```yaml
dependencies:
  some_package_that_uses_dart_pdf_reader: ^x.y.z

dependency_overrides:
  dart_pdf_reader:
    path: /absolute/path/to/dart_pdf_reader
```

Then run `dart pub get`.

## Verifying the fix

The archive ships with the original test suite plus new regression tests.
From inside the extracted directory:

```bash
dart pub get
dart test
```

All 288 tests should pass (263 original + 25 new regression tests). The new
regression tests are in `test/metadata_regression_test.dart` and cover the
specific symptoms reported in the bug:

- "unknown" author when the value is stored as PDFDocEncoding
- truncated title when a non-ASCII byte appears in the middle of the string
- UTF-16LE BOM (previously only UTF-16BE was detected)

## Files changed

```
lib/dart_pdf_reader.dart                            (updated exports)
lib/src/model/pdf_types.dart                        (use decodePdfTextString)
lib/src/model/pdf_document.dart                     (added getMetadata())
lib/src/model/pdf_metadata.dart                     (NEW)
lib/src/utils/pdf_doc_encoding.dart                 (NEW)
pubspec.yaml                                        (version bump)
CHANGELOG.md                                        (changelog entry)
README.md                                           (metadata API docs)
test/metadata_regression_test.dart                  (NEW regression tests)
```

## Compatibility

- Dart SDK: `>=3.0.0 <4.0.0` (unchanged)
- No new dependencies added
- Public API is strictly additive — no breaking changes
- All 263 pre-existing tests still pass
