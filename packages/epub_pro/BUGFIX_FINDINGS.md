# epub_pro Cover Image Bug — Findings & Fix

## Problem Description

When calling `EpubBookRef.readCover()` on certain EPUB 3 books, the method returns the **first image in the archive** instead of the actual cover image. This was observed with two test EPUBs:

1. **Head First Algorithms and Data Structures** (EPUB 3.0)
2. **Stardust** by Neil Gaiman (EPUB 3.0)

In both cases, unzipping the EPUB reveals the cover images are present and correctly referenced in the OPF manifest — the issue is purely a library bug.

## How EPUB Covers Are Specified

There are **three** standard mechanisms for identifying a cover image in an EPUB:

| # | Mechanism | EPUB Version | Specification |
|---|-----------|-------------|---------------|
| 1 | `<meta name="cover" content="manifest-item-id"/>` in `<metadata>` | EPUB 2.0 (legacy) | The `content` attribute references a manifest item `id` |
| 2 | `<item ... properties="cover-image" .../>` in `<manifest>` | EPUB 3.0 | The `properties` attribute on a manifest item contains `cover-image` |
| 3 | `<reference type="cover" href="..."/>` in `<guide>` | EPUB 2.0/3.0 (optional) | A guide entry with `type="cover"` pointing to a cover XHTML page |

## Root Cause Analysis

The bug is in **`lib/src/readers/book_cover_reader.dart`** and **`lib/src/readers/package_reader.dart`**.

### Bug 1: `BookCoverReader` — Missing EPUB 3 `properties="cover-image"` support

**File:** `lib/src/readers/book_cover_reader.dart` (lines 11–45)

The `readBookCover` method only implements strategy #1 (EPUB 2 `<meta name="cover">`). It has **no** check for strategy #2 (EPUB 3 `properties="cover-image"` on manifest items).

```dart
// CURRENT CODE — only checks EPUB 2 meta items
final coverMetaItem = metaItems.firstWhereOrNull((metaItem) =>
    metaItem.name != null && metaItem.name!.toLowerCase() == 'cover');
```

When this lookup fails (which it always does for EPUB 3 — see Bug 2), the code falls through to the **dangerous fallback** on line 38–41:

```dart
// CURRENT CODE — blind fallback to first image
if (bookRef.content?.images.isNotEmpty == true) {
  var firstImage = bookRef.content!.images.values.first;
  var imageContent = await firstImage.readContentAsBytes();
  return images.decodeImage(Uint8List.fromList(imageContent));
}
```

This returns whatever image happens to be first in the manifest — which is almost never the cover.

### Bug 2: `PackageReader` — EPUB 3 meta parser drops the `name` attribute

**File:** `lib/src/readers/package_reader.dart` (lines 310–341)

When the EPUB version is 3.0, `<meta>` elements are parsed by `readMetadataMetaVersion3()`. This method reads `id`, `refines`, `property`, `scheme`, and `content` (inner text), but **it never reads the `name` attribute**:

```dart
static EpubMetadataMeta readMetadataMetaVersion3(XmlElement metadataMetaNode) {
    final attributes = <String, String>{};
    String? id, refines, property, scheme, content;
    for (var metadataMetaNodeAttribute in metadataMetaNode.attributes) {
      final attributeValue = metadataMetaNodeAttribute.value;
      final name = metadataMetaNodeAttribute.name.local.toLowerCase();
      attributes[name] = attributeValue;
      switch (name) {
        case 'id':       id = attributeValue;
        case 'refines':  refines = attributeValue;
        case 'property': property = attributeValue;
        case 'scheme':   scheme = attributeValue;
        // ⚠️ NO case 'name' — the attribute is lost!
      }
    }
    content = metadataMetaNode.innerText;
    return EpubMetadataMeta(
      id: id, refines: refines, property: property,
      scheme: scheme, content: content, attributes: attributes,
    );
}
```

This means that for any EPUB 3.0 book that includes the legacy `<meta name="cover" content="cover-image"/>` for backward compatibility (as our Head First test EPUB does), the `name` field is always `null` — so `BookCoverReader`'s check `metaItem.name!.toLowerCase() == 'cover'` can never match.

### Failure Trace for Each EPUB

#### Head First Algorithms and Data Structures (EPUB 3.0)

- OPF declares: `<meta name="cover" content="cover-image"/>`
- OPF manifest declares: `<item id="cover-image" href="assets/cover_ER.png" properties="cover-image" media-type="image/png"/>`
- **Actual cover:** `assets/cover_ER.png`
- **Returned instead:** `css_assets/titlepage_footer_ebook.png` (first image in the manifest map)
- **Why:**
  1. `readMetadataMetaVersion3()` parses the `<meta name="cover">` but drops the `name` attribute → `metaItem.name == null`
  2. `BookCoverReader` check `metaItem.name!.toLowerCase() == 'cover'` fails
  3. Falls back to `images.values.first` → `css_assets/titlepage_footer_ebook.png`

#### Stardust by Neil Gaiman (EPUB 3.0)

- OPF has **no** `<meta name="cover">` element at all
- OPF manifest declares: `<item id="cover" href="images/cover.jpg" properties="cover-image" media-type="image/jpeg"/>`
- **Actual cover:** `images/cover.jpg`
- **Returned instead:** `images/blackdingbat.jpg` (first image in the manifest map)
- **Why:**
  1. No `<meta name="cover">` exists → EPUB 2 lookup fails immediately
  2. `BookCoverReader` never checks `properties="cover-image"` on manifest items
  3. Falls back to `images.values.first` → `images/blackdingbat.jpg`

## Fix Plan

### Fix 1: `book_cover_reader.dart` — Add EPUB 3 manifest `properties` check

Between the existing EPUB 2 meta check and the first-image fallback, add a new block that scans the manifest items for one whose `properties` attribute contains `cover-image`:

```dart
// NEW: EPUB 3 strategy — look for properties="cover-image" on manifest items
final manifestItems = bookRef.schema?.package?.manifest?.items;
if (manifestItems != null && manifestItems.isNotEmpty) {
  final coverManifestItem = manifestItems.firstWhereOrNull(
    (item) => item.properties?.toLowerCase().contains('cover-image') == true,
  );
  if (coverManifestItem != null &&
      bookRef.content?.images.containsKey(coverManifestItem.href) == true) {
    var coverImageContentFileRef =
        bookRef.content!.images[coverManifestItem.href];
    var coverImageContent =
        await coverImageContentFileRef!.readContentAsBytes();
    return images.decodeImage(Uint8List.fromList(coverImageContent));
  }
}
```

### Fix 2: `package_reader.dart` — Parse the `name` attribute in EPUB 3 meta reader

Add a `case 'name'` to the switch statement in `readMetadataMetaVersion3()` so that legacy `<meta name="cover" content="...">` elements are correctly parsed even in EPUB 3 books:

```dart
case 'name':
  name = attributeValue;
```

This requires adding a `name` variable to the method, passing it to the constructor, and ensuring `EpubMetadataMeta` already accepts it (it does — the field already exists).

## Files Changed

| File | Lines Changed | Change |
|------|--------------|--------|
| `lib/src/readers/book_cover_reader.dart` | 37 (insert new block) | Add EPUB 3 `properties="cover-image"` manifest check |
| `lib/src/readers/package_reader.dart` | 312–313, 335 | Add `name` variable and `case 'name'` in EPUB 3 meta parser |