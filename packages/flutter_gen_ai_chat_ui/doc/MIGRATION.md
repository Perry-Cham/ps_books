# SDK and Compatibility Changes (Version 2.1.1)

## SDK Version Compatibility

Starting with version 2.1.1, Flutter Gen AI Chat UI now supports Dart SDK >= 2.19.0 (previously required Dart SDK >= 3.5.0). This change ensures the package works with a broader range of Flutter applications and reduces upgrade pressure.

## Color Extension Compatibility

The `withOpacityCompat` method has been updated to fix compatibility issues with older Dart SDKs. If you were experiencing errors like:

```
The method 'withValues' isn't defined for the class 'Color'.
```

Upgrading to version 2.1.1 will resolve these issues while maintaining the same API.

### Migration for Custom Extensions

If you've created your own extensions to the `ColorExtensions` class, be sure to update any implementations that rely on the `withValues` method to use the standard Flutter color manipulation methods instead.

# Migration Guide: From AiChatConfig to Direct Parameters

This guide helps you migrate from the older `AiChatConfig`-based API to the new, more intuitive direct parameter API in Flutter Gen AI Chat UI.

## Overview of Changes

The package has shifted from a centralized configuration object model to a more direct parameter approach, offering:

- More intuitive API design similar to Dila
- Better IDE autocompletion and discovery
- Easier access to core properties
- Improved type safety
- Cleaner code organization

## Basic Migration Example

### Old Approach (Using AiChatConfig)

```dart
AiChatWidget(
  config: AiChatConfig(
    userName: 'User',
    aiName: 'AI Assistant',
    hintText: 'Type a message...',
    enableAnimation: true,
    inputOptions: InputOptions(
      sendOnEnter: true,
    ),
    messageOptions: MessageOptions(
      showTime: true,
      containerColor: Colors.grey[200],
    ),
    loadingConfig: LoadingConfig(
      isLoading: false,
      typingIndicatorColor: Colors.blue,
    ),
    exampleQuestions: [
      ExampleQuestion(question: 'What can you do?'),
    ],
  ),
  currentUser: ChatUser(id: '1', firstName: 'User'),
  aiUser: ChatUser(id: '2', firstName: 'AI'),
  controller: ChatMessagesController(),
  onSendMessage: (message) async {
    // Handle message
  },
)
```

### New Approach (Direct Parameters)

```dart
AiChatWidget(
  // Required parameters
  currentUser: ChatUser(id: '1', firstName: 'User'),
  aiUser: ChatUser(id: '2', firstName: 'AI Assistant'),
  controller: ChatMessagesController(),
  onSendMessage: (message) async {
    // Handle message
  },

  // Optional parameters (previously in AiChatConfig)
  enableAnimation: true,
  inputOptions: InputOptions(
    unfocusOnTapOutside: false,
    sendOnEnter: true,
    hintText: 'Type a message...',
  ),
  messageOptions: MessageOptions(
    showTime: true,
    bubbleStyle: BubbleStyle(
      aiBubbleColor: Colors.grey[200],
    ),
  ),
  loadingConfig: LoadingConfig(
    isLoading: false,
    typingIndicatorColor: Colors.blue,
  ),
  exampleQuestions: [
    ExampleQuestion(question: 'What can you do?'),
  ],
)
```

## Detailed Migration by Feature

### 1. Basic Properties

| Old (in AiChatConfig)      | New (Direct Parameter)   |
|----------------------------|--------------------------|
| `config.userName`          | Use `currentUser.firstName` |
| `config.aiName`            | Use `aiUser.firstName`   |
| `config.hintText`          | Use `inputOptions.hintText` |
| `config.maxWidth`          | `maxWidth`               |
| `config.padding`           | `padding`                |
| `config.enableAnimation`   | `enableAnimation`        |
| `config.showTimestamp`     | Use `messageOptions.showTime` |
| `config.readOnly`          | `readOnly`               |

### 2. Message Management

| Old (in AiChatConfig)      | New (Direct Parameter)   |
|----------------------------|--------------------------|
| `config.exampleQuestions`  | `exampleQuestions`       |
| `config.persistentExampleQuestions` | `persistentExampleQuestions` |
| `config.welcomeMessageConfig` | `welcomeMessageConfig` |
| `config.markdownStyleSheet` | `markdownStyleSheet`    |

### 3. Streaming Options

| Old (in AiChatConfig)      | New (Direct Parameter)   |
|----------------------------|--------------------------|
| `config.enableMarkdownStreaming` | `enableMarkdownStreaming` |
| `config.streamingDuration` | `streamingDuration`      |

### 4. Specialized Configurations

These remain as separate configuration objects, but are passed directly to AiChatWidget:

| Old (in AiChatConfig)      | New (Direct Parameter)   |
|----------------------------|--------------------------|
| `config.inputOptions`      | `inputOptions`           |
| `config.messageOptions`    | `messageOptions`         |
| `config.messageListOptions` | `messageListOptions`    |
| `config.paginationConfig`  | `paginationConfig`       |
| `config.loadingConfig`     | `loadingConfig`          |
| `config.typingUsers`       | `typingUsers`            |

## Backwards Compatibility

The `AiChatConfig` class is still available but marked as deprecated. It will be removed in a future version. In the meantime, you can continue using it with a warning:

```dart
AiChatWidget(
  // Other parameters
  
  // Using the deprecated config (not recommended for new code)
  @Deprecated('Use direct parameters instead')
  config: AiChatConfig(...),
)
```

## Handling Deprecated Legacy Properties

Some properties from older versions are also deprecated even in the new API:

| Deprecated Property      | New Replacement                        |
|--------------------------|----------------------------------------|
| `loadingIndicator`       | `loadingConfig.loadingIndicator`       |
| `welcomeMessageBuilder`  | `welcomeMessageConfig.builder`         |
| `isLoading`              | `loadingConfig.isLoading`              |

## Special Notes on Configuration Objects

- **InputOptions**: Contains all input-related properties and styling
- **MessageOptions**: Message display, styles, and interaction settings
- **LoadingConfig**: Loading state and indicators
- **PaginationConfig**: Settings for message pagination
- **WelcomeMessageConfig**: Welcome message appearance and content

## Best Practices for Migration

1. **Start with required parameters**: Always begin with the four required parameters:
   - `currentUser`
   - `aiUser`
   - `controller`
   - `onSendMessage`

2. **Group related options**: Keep related configurations together for readability

3. **Use factory constructors**: For input styling, prefer factory constructors like:
   - `InputOptions.minimal()`
   - `InputOptions.glassmorphic()`
   - `InputOptions.custom()`

4. **Remove unnecessary configs**: If you're not using certain configurations, remove them completely rather than passing empty or default objects

5. **Update controllers**: Make sure any controller code is updated to use the new methods and patterns

## Example: Complete Migration

### Before

```dart
AiChatWidget(
  config: AiChatConfig(
    userName: 'User',
    aiName: 'Assistant',
    hintText: 'Ask me anything...',
    maxWidth: 800,
    padding: const EdgeInsets.all(16),
    enableAnimation: true,
    showTimestamp: true,
    persistentExampleQuestions: true,
    enableMarkdownStreaming: true,
    streamingDuration: const Duration(milliseconds: 50),
    inputOptions: InputOptions(
      sendOnEnter: true,
      margin: const EdgeInsets.all(16),
    ),
    messageOptions: MessageOptions(
      showTime: true,
      showUserName: true,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
      ),
    ),
    loadingConfig: LoadingConfig(
      isLoading: _isLoading,
      typingIndicatorColor: Colors.blue,
    ),
    exampleQuestions: [
      ExampleQuestion(question: 'What is AI?'),
      ExampleQuestion(question: 'How do you work?'),
    ],
    welcomeMessageConfig: WelcomeMessageConfig(
      title: 'Welcome to AI Chat',
      containerPadding: const EdgeInsets.all(16),
    ),
  ),
  currentUser: _currentUser,
  aiUser: _aiUser,
  controller: _chatController,
  onSendMessage: _handleSendMessage,
)
```

### After

```dart
AiChatWidget(
  // Required parameters
  currentUser: _currentUser,
  aiUser: _aiUser,
  controller: _chatController,
  onSendMessage: _handleSendMessage,
  
  // Layout and behavior
  maxWidth: 800,
  padding: const EdgeInsets.all(16),
  enableAnimation: true,
  enableMarkdownStreaming: true,
  streamingDuration: const Duration(milliseconds: 50),
  
  // Message display and organization
  messageOptions: MessageOptions(
    showTime: true,
    showUserName: true,
    decoration: BoxDecoration(
      color: Colors.grey[200],
      borderRadius: BorderRadius.circular(12),
    ),
  ),
  
  // Input configuration
  inputOptions: InputOptions(
    unfocusOnTapOutside: false,
    sendOnEnter: true,
    hintText: 'Ask me anything...',
    margin: const EdgeInsets.all(16),
  ),
  
  // Loading configuration
  loadingConfig: LoadingConfig(
    isLoading: _isLoading,
    typingIndicatorColor: Colors.blue,
  ),
  
  // Onboarding elements
  exampleQuestions: [
    ExampleQuestion(question: 'What is AI?'),
    ExampleQuestion(question: 'How do you work?'),
  ],
  persistentExampleQuestions: true,
  welcomeMessageConfig: WelcomeMessageConfig(
    title: 'Welcome to AI Chat',
    containerPadding: const EdgeInsets.all(16),
  ),
)
``` 