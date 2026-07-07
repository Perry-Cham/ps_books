import 'pdf_constants.dart';
import 'pdf_document_catalog.dart';
import 'pdf_metadata.dart';
import 'pdf_types.dart';
import '../parser/object_resolver.dart';

/// Holds the data for the PDF document.
class PDFDocument {
  /// The document main trailer
  final PDFDictionary mainTrailer;
  final ObjectResolver _objectResolver;

  /// Extracts the [PDFDocumentCatalog] from the document
  Future<PDFDocumentCatalog> get catalog async {
    final dict = await resolve<PDFDictionary>(mainTrailer[PDFNames.root]);
    return PDFDocumentCatalog(this, dict!, _objectResolver);
  }

  /// Create a new instance of [PDFDocument]
  PDFDocument({
    required this.mainTrailer,
    required ObjectResolver objectResolver,
  }) : _objectResolver = objectResolver;

  /// Resolves the [PDFObject] to its actual value, reading it from the document
  /// as needed
  Future<T?> resolve<T extends PDFObject>(PDFObject? toResolve) {
    return _objectResolver.resolve(toResolve);
  }

  /// Reads the document-level metadata (title, author, subject, keywords,
  /// creator, producer, creation/modification dates, plus any custom entries)
  /// from the trailer's `Info` dictionary, with fallback to the catalog's
  /// XMP `Metadata` stream.
  ///
  /// Robust against malformed PDFs: returns a non-null [PDFMetadata] with
  /// whatever fields could be read; fields that could not be read are `null`.
  Future<PDFMetadata> getMetadata() => readPdfMetadata(this);
}
