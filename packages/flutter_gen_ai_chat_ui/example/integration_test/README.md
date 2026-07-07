# Integration Tests for Flutter Gen AI Chat UI Example

This directory contains integration tests for the Flutter Gen AI Chat UI example app. These tests verify that the chat UI components work correctly by testing user interactions and validating the UI behavior.

## Test Structure

The tests are organized into several categories:

1. **Basic Chat Functionality**: Tests basic message sending, display, and user interactions.
2. **Welcome Message & Example Questions**: Tests the display and functionality of welcome messages and example questions.
3. **Streaming Text & Markdown**: Tests streaming text animations and markdown rendering.
4. **Input Field Customization**: Tests various input field customization options.
5. **Loading & Typing Indicators**: Tests loading and typing indicators.
6. **Message Controller**: Tests the ChatMessagesController functionality.

## Running the Tests

You can run all tests or individual test files:

### Running All Tests

```bash
flutter test integration_test/main_test.dart -d <device_id>
```

Replace `<device_id>` with your target device. For example:

```bash
# Run on Chrome
flutter test integration_test/main_test.dart -d chrome

# Run on an iOS simulator
flutter test integration_test/main_test.dart -d "iPhone 16"
```

### Running Individual Test Files

You can run specific test files:

```bash
flutter test integration_test/app_test.dart -d <device_id>
flutter test integration_test/welcome_message_test.dart -d <device_id>
```

## Test Utilities

The tests use utilities in the `utils/test_utils.dart` file:

- `createTestApp()`: Creates a test app with the AiChatWidget.
- `createController()`: Creates a ChatMessagesController.
- `generateUserMessage()` and `generateAiMessage()`: Create test messages.
- `findChatInputField()`, `findSendButton()`, etc.: Finders for UI elements.
- `sendMessage()`: Helper to send a message in the UI.

## Adding New Tests

To add new tests:

1. Create a new test file or add to an existing one.
2. Use the `TestUtils` class to simplify test setup.
3. Follow the Arrange-Act-Assert pattern in test cases.
4. Import your test file in `main_test.dart` to include it in the full test suite.

## Coverage

The tests aim to cover all major features:

- Message display and interaction
- Input field functionality
- Welcome messages
- Example questions
- Streaming text and markdown rendering
- Loading and typing indicators
- Controller operations

For more detailed test information, refer to the individual test files. 