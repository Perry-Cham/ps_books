# P's Books — App

This is the main Flutter application for the P's Books monorepo. See the [root README](../README.md) for full project documentation, architecture overview, and development setup.

## Quick Start

```bash
cd app
flutter run
```

Requires the monorepo to be bootstrapped first (`melos bootstrap` from the root).

## Data Export / Import

App data can be exported through **Settings → Export** as `.pbf` archives (ZIP-compressed). The `DataHandler` service at `lib/services/data_handler.dart` manages:

| Method | Description |
|--------|-------------|
| `exportPBF()` | Full backup — books, covers, timetable, targets, notes, saved books |
| `exportTimetable()` | Timetable-only `.pbf` |
| `exportTargets()` | Targets-only `.pbf` |
| `exportNotes()` | Notes-only `.pbf` |
| `exportBooks()` | Simple book file copy (original behaviour) |
| `importPBF(path)` | Restore from any `.pbf` archive; imports whichever data types are present in the manifest |

The `.pbf` format is a ZIP archive containing a `Data/` directory with `manifest.json` mapping each data type to its JSON file path (or `null` if not included). Timetable import overwrites the existing timetable; notes and targets use UUID + timestamp matching for conflict resolution; books and saved books are matched by name+author to avoid duplicates. Imported books are reprocessed through `processBook()` for metadata extraction.
