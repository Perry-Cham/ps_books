# Flutter Gen AI Chat UI Integration Tests

This directory contains integration tests for the Flutter Gen AI Chat UI package. These tests verify that all features of the package work correctly together.

## Test Structure

The tests are organized into the following categories:

1. **Basic Chat Functionality** (`basic_chat_test.dart`): Tests for displaying messages, sending messages, and clearing input fields.
2. **Welcome Message & Example Questions** (`welcome_message_test.dart`): Tests for welcome messages and example questions features.
3. **Streaming Text & Markdown** (`streaming_text_test.dart`): Tests for streaming text animations and markdown rendering.
4. **Input Field Customization** (`input_options_test.dart`): Tests for customizing the input field appearance and behavior.
5. **Loading & Typing Indicators** (`loading_indicators_test.dart`): Tests for loading indicators and typing indicators.
6. **Message Controller** (`controller_test.dart`): Tests for the ChatMessagesController functionality.

The `main_test.dart` file runs all tests together.

## Running the Tests

### Running on a Physical Device or Emulator

```bash
flutter test integration_test
```

### Running on Chrome

```bash
flutter test integration_test -d chrome
```

### Running a Specific Test File

```bash
flutter test integration_test/basic_chat_test.dart
```

## Test Utilities

The `utils/test_utils.dart` file provides helper functions for the tests, including:

- Creating test apps with configured widgets
- Generating test messages
- Finding UI elements
- Simulating user interactions

## Adding New Tests

When adding new features to the package, integration tests should be added to verify that the new functionality works correctly. Follow these guidelines:

1. Create a new test file in the `integration_test` directory or add to an existing file if appropriate.
2. Use the TestUtils class for common operations.
3. Follow the Arrange-Act-Assert pattern for test clarity.
4. Test both positive and negative scenarios.
5. Add the new test to `main_test.dart` if creating a new file.

## Coverage

These integration tests aim to cover all major features of the Flutter Gen AI Chat UI package, including:

- Message display and input
- Welcome messages
- Example questions
- Streaming text animations
- Markdown rendering
- Input field customization
- Loading and typing indicators
- Message controller operations 