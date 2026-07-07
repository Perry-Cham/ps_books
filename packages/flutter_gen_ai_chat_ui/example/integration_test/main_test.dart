import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'app_test.dart' as app;
import 'controller_test.dart' as controller;
import 'input_options_test.dart' as input_options;
import 'loading_indicators_test.dart' as loading_indicators;
import 'streaming_text_test.dart' as streaming_text;
import 'welcome_message_test.dart' as welcome_message;

/// Main entry point for running all integration tests.
/// This runs all the tests in sequence.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('All Integration Tests', () {
    // Basic chat functionality tests
    app.main();

    // Controller tests
    controller.main();

    // Input options tests
    input_options.main();

    // Loading indicators tests
    loading_indicators.main();

    // Streaming text tests
    streaming_text.main();

    // Welcome message tests
    welcome_message.main();
  });
}
