import 'package:integration_test/integration_test.dart';

import 'basic_chat_test.dart' as basic_chat;
import 'controller_test.dart' as controller;
import 'input_options_test.dart' as input_options;
import 'loading_indicators_test.dart' as loading_indicators;
import 'streaming_text_test.dart' as streaming_text;
import 'welcome_message_test.dart' as welcome_message;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  basic_chat.main();
  controller.main();
  input_options.main();
  loading_indicators.main();
  streaming_text.main();
  welcome_message.main();
}
