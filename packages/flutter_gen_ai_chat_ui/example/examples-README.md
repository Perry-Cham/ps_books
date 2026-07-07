# Flutter Gen AI Chat UI Examples

This directory contains various examples demonstrating the capabilities of the Flutter Gen AI Chat UI package.

## File Upload Example

The file upload example demonstrates how to implement and customize file upload functionality in your chat application.

### Running the Standalone File Upload Example

Due to some dependency issues in the main example app, we've created a standalone file upload example that can be run independently:

```bash
flutter run -d chrome -t lib/standalone_file_upload_example.dart
```

This example demonstrates:

1. Basic file upload button configuration
2. Dedicated photo upload button
3. Handling different types of media attachments:
   - Images
   - Documents (PDF, Excel, etc.)
   - Videos
   - Audio files

### Example Features

- **Message Examples**: View different types of media message implementations
- **File Upload Options**: See how to configure and customize the upload buttons
- **Interactive Demo**: Try sending messages and uploading files

## Project Organization

The examples are organized into feature-specific directories:

- `01_basic`: Simple implementation of the chat UI
- `02_intermediate`: More advanced features like markdown and streaming
- `03_advanced`: Full-featured implementation with custom styling
- `04_file_upload`: File and media attachment implementation 