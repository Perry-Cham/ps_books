import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter_gen_ai_chat_ui/flutter_gen_ai_chat_ui.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('AI Actions Integration Tests', () {
    testWidgets('should execute calculator action end-to-end', (tester) async {
      // Create test app with AI Actions
      await tester.pumpWidget(MaterialApp(
        home: TestAiActionsWidget(),
      ));

      // Wait for widget to build
      await tester.pumpAndSettle();

      // Find the action execution button
      final executeButton = find.byKey(const Key('execute_calculator'));
      expect(executeButton, findsOneWidget);

      // Tap the button to execute calculator action
      await tester.tap(executeButton);
      await tester.pumpAndSettle();

      // Wait for action execution to complete
      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();

      // Verify action result is displayed
      expect(find.textContaining('25'), findsOneWidget);
      expect(find.textContaining('10 + 15'), findsOneWidget);
    });

    testWidgets('should handle action execution with confirmation',
        (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: TestAiActionsWidget(),
      ));

      await tester.pumpAndSettle();

      // Execute action that requires confirmation
      final confirmButton = find.byKey(const Key('execute_with_confirmation'));
      await tester.tap(confirmButton);
      await tester.pumpAndSettle();

      // Verify confirmation dialog appears
      expect(find.text('Confirm Action'), findsOneWidget);
      expect(find.text('Are you sure you want to proceed?'), findsOneWidget);

      // Tap confirm
      await tester.tap(find.text('Confirm'));
      await tester.pumpAndSettle();

      // Wait for execution
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();

      // Verify action was executed
      expect(find.textContaining('Confirmed action executed'), findsOneWidget);
    });

    testWidgets('should handle action parameter validation', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: TestAiActionsWidget(),
      ));

      await tester.pumpAndSettle();

      // Try to execute action with invalid parameters
      final invalidButton = find.byKey(const Key('execute_invalid_params'));
      await tester.tap(invalidButton);
      await tester.pumpAndSettle();

      // Verify error message is displayed
      expect(find.textContaining('required_param is required'), findsOneWidget);
    });

    testWidgets('should stream action events', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: TestAiActionsWidget(),
      ));

      await tester.pumpAndSettle();

      // Execute action and listen for events
      final streamButton = find.byKey(const Key('test_event_stream'));
      await tester.tap(streamButton);
      await tester.pumpAndSettle();

      // Wait for events to be processed
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();

      // Verify event indicators are shown
      expect(find.byKey(const Key('execution_started')), findsOneWidget);

      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('execution_completed')), findsOneWidget);
    });
  });
}

class TestAiActionsWidget extends StatefulWidget {
  @override
  _TestAiActionsWidgetState createState() => _TestAiActionsWidgetState();
}

class _TestAiActionsWidgetState extends State<TestAiActionsWidget> {
  late ActionController _actionController;
  String _lastResult = '';
  String _lastError = '';
  bool _executionStarted = false;
  bool _executionCompleted = false;

  @override
  void initState() {
    super.initState();
    _actionController = ActionController();
    _setupActions();
    _listenToEvents();
  }

  void _setupActions() {
    // Calculator action
    _actionController.registerAction(AiAction(
      name: 'calculator',
      description: 'Perform calculation',
      parameters: [
        ActionParameter.number(
            name: 'a', description: 'First number', required: true),
        ActionParameter.number(
            name: 'b', description: 'Second number', required: true),
        ActionParameter.string(
          name: 'operation',
          description: 'Operation',
          required: true,
          enumValues: ['add', 'subtract', 'multiply', 'divide'],
        ),
      ],
      handler: (params) async {
        final a = params['a'] as num;
        final b = params['b'] as num;
        final operation = params['operation'] as String;

        await Future.delayed(const Duration(milliseconds: 500));

        double result;
        String symbol;

        switch (operation) {
          case 'add':
            result = a + b;
            symbol = '+';
            break;
          case 'subtract':
            result = a - b;
            symbol = '-';
            break;
          case 'multiply':
            result = a * b;
            symbol = '×';
            break;
          case 'divide':
            result = a / b;
            symbol = '÷';
            break;
          default:
            return ActionResult.createFailure('Invalid operation');
        }

        return ActionResult.createSuccess({
          'result': result,
          'expression': '$a $symbol $b = $result',
        });
      },
    ));

    // Action with confirmation
    _actionController.registerAction(AiAction(
      name: 'confirmed_action',
      description: 'Action requiring confirmation',
      parameters: [],
      confirmationConfig: const ActionConfirmationConfig(
        title: 'Confirm Action',
        message: 'Are you sure you want to proceed?',
        required: true,
      ),
      handler: (params) async {
        await Future.delayed(const Duration(milliseconds: 500));
        return ActionResult.createSuccess({
          'message': 'Confirmed action executed successfully',
        });
      },
    ));

    // Action with required parameters
    _actionController.registerAction(AiAction(
      name: 'param_validation',
      description: 'Action with parameter validation',
      parameters: [
        ActionParameter.string(
          name: 'required_param',
          description: 'Required parameter',
          required: true,
        ),
      ],
      handler: (params) async {
        return ActionResult.createSuccess({
          'message': 'Parameters validated successfully',
        });
      },
    ));
  }

  void _listenToEvents() {
    _actionController.events.listen((event) {
      setState(() {
        switch (event.type) {
          case ActionEventType.executionStarted:
            _executionStarted = true;
            break;
          case ActionEventType.executionCompleted:
            _executionCompleted = true;
            if (event.result != null) {
              _lastResult = event.result!.data.toString();
            }
            break;
          case ActionEventType.executionFailed:
            _lastError = event.error ?? 'Unknown error';
            break;
        }
      });
    });
  }

  Future<void> _executeCalculator() async {
    final result = await _actionController.executeAction('calculator', {
      'a': 10,
      'b': 15,
      'operation': 'add',
    });

    setState(() {
      if (result.success) {
        _lastResult = result.data['expression'];
      } else {
        _lastError = result.error ?? 'Unknown error';
      }
    });
  }

  Future<void> _executeWithConfirmation() async {
    final result = await _actionController.executeAction('confirmed_action', {},
        context: context);

    setState(() {
      if (result.success) {
        _lastResult = result.data['message'];
      } else {
        _lastError = result.error ?? 'Unknown error';
      }
    });
  }

  Future<void> _executeInvalidParams() async {
    final result =
        await _actionController.executeAction('param_validation', {});

    setState(() {
      if (result.success) {
        _lastResult = result.data['message'];
      } else {
        _lastError = result.error ?? 'Unknown error';
      }
    });
  }

  @override
  void dispose() {
    _actionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AI Actions Test')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ElevatedButton(
              key: const Key('execute_calculator'),
              onPressed: _executeCalculator,
              child: const Text('Execute Calculator'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              key: const Key('execute_with_confirmation'),
              onPressed: _executeWithConfirmation,
              child: const Text('Execute with Confirmation'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              key: const Key('execute_invalid_params'),
              onPressed: _executeInvalidParams,
              child: const Text('Execute Invalid Params'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              key: const Key('test_event_stream'),
              onPressed: _executeCalculator,
              child: const Text('Test Event Stream'),
            ),
            const SizedBox(height: 32),
            if (_lastResult.isNotEmpty) ...[
              const Text('Result:',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              Text(_lastResult),
              const SizedBox(height: 16),
            ],
            if (_lastError.isNotEmpty) ...[
              const Text('Error:',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.red)),
              Text(_lastError, style: const TextStyle(color: Colors.red)),
              const SizedBox(height: 16),
            ],
            if (_executionStarted)
              Container(
                key: const Key('execution_started'),
                child: const Text('Execution Started',
                    style: TextStyle(color: Colors.blue)),
              ),
            if (_executionCompleted)
              Container(
                key: const Key('execution_completed'),
                child: const Text('Execution Completed',
                    style: TextStyle(color: Colors.green)),
              ),
          ],
        ),
      ),
    );
  }
}
