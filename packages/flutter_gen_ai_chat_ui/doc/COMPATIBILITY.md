# Compatibility Guide

## Dart and Flutter SDK Requirements

Flutter Gen AI Chat UI has the following SDK requirements:

- **Dart SDK**: `>=2.19.0 <4.0.0`
- **Flutter**: `>=3.7.0`

## Optional Features Implementation

### Speech Recognition

As of version 2.1.2, speech-to-text functionality is **fully optional** and not included in the core package. If you want to implement speech-to-text in your app:

1. **Add the necessary dependencies** to your app's pubspec.yaml:

```yaml
dependencies:
  speech_to_text: ^6.6.1  # Or your preferred version
  permission_handler: ^12.0.0+1  # Or a version compatible with your Dart SDK
```

2. **Configure the appropriate permissions** for your platforms:

#### Android

Add the following permissions to your `AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.RECORD_AUDIO" />
<uses-permission android:name="android.permission.INTERNET" />
```

#### iOS

Add the following permissions to your `Info.plist`:

```xml
<key>NSMicrophoneUsageDescription</key>
<string>This app needs access to your microphone for speech recognition</string>
<key>NSSpeechRecognitionUsageDescription</key>
<string>This app needs access to speech recognition to convert your speech to text</string>
```

#### macOS

For macOS apps, add the following to your `Info.plist`:

```xml
<key>NSMicrophoneUsageDescription</key>
<string>This app needs access to your microphone for speech recognition</string>
<key>NSSpeechRecognitionUsageDescription</key>
<string>This app needs access to speech recognition to convert your speech to text</string>
```

3. **Implement permission handling and speech-to-text** integration in your app:

```dart
// Example implementation
import 'package:speech_to_text/speech_to_text.dart';
import 'package:permission_handler/permission_handler.dart';

class SpeechImplementation {
  final SpeechToText _speech = SpeechToText();
  
  Future<bool> initializeSpeech() async {
    // Request microphone permission
    await Permission.microphone.request();
    
    // Initialize speech recognition
    bool available = await _speech.initialize();
    return available;
  }
  
  // Add methods for starting/stopping listening, etc.
}
```

## Common Compatibility Issues

### Color Extensions

If you're using the color extensions provided by this package (`withValues` or `withOpacityCompat`), ensure you're on version 2.1.1 or later to avoid compatibility issues with older Dart SDKs.

### Theme Compatibility

When using custom themes, make sure to use the `withOpacityCompat` method for color opacity modifications to ensure compatibility across all supported Dart SDKs.

## Testing Your Integration

We recommend testing your integration on multiple SDK versions if your application supports a wide range of Flutter/Dart versions.

For any specific compatibility questions, please file an issue on our [GitHub repository](https://github.com/hooshyar/flutter_gen_ai_chat_ui/issues). 