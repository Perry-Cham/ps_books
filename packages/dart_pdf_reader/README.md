[![Version](https://img.shields.io/pub/v/dart_pdf_reader.svg)](https://pub.dev/packages/dart_pdf_reader) [![codecov](https://codecov.io/gh/NicolaVerbeeck/dart_pdf_reader/graph/badge.svg?token=20CAT9JC3Y)](https://codecov.io/gh/NicolaVerbeeck/dart_pdf_reader)[![OpenSSF Scorecard](https://api.securityscorecards.dev/projects/github/NicolaVerbeeck/dart_pdf_reader/badge)](https://securityscorecards.dev/viewer/?uri=github.com/NicolaVerbeeck/dart_pdf_reader)

## Features

'Simple' PDF reader package. Does not do a lot of interpretation of the data
that is being read, but it does provide a way to read the data from a PDF file

## Getting started

1) Create `RandomAccessStream` from either bytes `ByteStream` or file `FileStream`
2) Create `PDFParser` using the stream from step 1
3) Read the PDF file using the `PDFParser` from step 2 `await parser.parse()`

## Example
```dart
final stream = ByteStream(File(inputFile).readAsBytesSync());
final doc = await PDFParser(stream).parse();

final catalog = await doc.catalog;
final pages = await catalog.getPages();
final outlines = await catalog.getOutlines();
final firstPage = pages.getPageAtIndex(0);
```

## Reading document metadata

Use `PDFDocument.getMetadata()` to read Title, Author, Subject, Keywords,
Creator, Producer, creation/modification dates, plus any custom Info-dictionary
entries, with automatic fallback to the catalog's XMP `Metadata` stream:

```dart
final stream = ByteStream(File(inputFile).readAsBytesSync());
final doc = await PDFParser(stream).parse();
final metadata = await doc.getMetadata();

print(metadata.title);        // e.g. "My Document"
print(metadata.author);       // e.g. "Jose Author"
print(metadata.subject);
print(metadata.keywords);
print(metadata.creator);
print(metadata.producer);
print(metadata.creationDate); // raw PDF date string
print(metadata.modDate);
print(metadata.version);
print(metadata.language);
print(metadata.custom);       // map of non-standard Info-dictionary keys
print(metadata.rawXmp);       // raw XMP XML, if present

// Parse a PDF date string into a DateTime (UTC if a TZ offset is present):
final created = PDFMetadata.parseDate(metadata.creationDate);
```

The metadata reader is robust against malformed PDFs: any field that cannot
be resolved is left `null`, and the call always returns a non-null
`PDFMetadata` object. Internally it mirrors pdfjs's algorithm — Info
dictionary first, XMP stream as a supplement, and catalog-level
Version/Lang as a last resort.

### String decoding

PDF text strings (Title, Author, etc.) are decoded using the same algorithm
as pdfjs's `stringToPDFString`:

1. UTF-16BE BOM (`FE FF`) → UTF-16BE
2. UTF-16LE BOM (`FF FE`) → UTF-16LE
3. UTF-8 BOM (`EF BB BF`) → UTF-8 (BOM stripped)
4. Otherwise → PDFDocEncoding (with Latin-1 fallback for undefined slots)

Language escape sequences bracketed by `0x1B` bytes (PDF spec §7.9.2.2) are
stripped from non-Unicode strings.

You can use the public `decodePdfTextString(Uint8List)` helper directly to
decode raw PDF text-string bytes if you have them outside of a
`PDFLiteralString` / `PDFHexString` object.

## Using this package as a path dependency

After extracting the bundled `dart_pdf_reader-2.2.1-metadata-fix.tar.gz`
archive, point your project's `pubspec.yaml` at the extracted directory:

```yaml
dependencies:
  dart_pdf_reader:
    path: /path/to/dart_pdf_reader-2.2.1-metadata-fix
```

Then run `dart pub get`. The fixed library is a drop-in replacement for the
published `dart_pdf_reader: ^2.2.0` package — the public API is backwards
compatible, and all pre-existing tests continue to pass.
