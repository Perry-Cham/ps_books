import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter_gen_ai_chat_ui/flutter_gen_ai_chat_ui.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('AI Context Integration Tests', () {
    testWidgets('should provide and access context throughout widget tree',
        (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: TestContextAwareApp(),
      ));

      await tester.pumpAndSettle();

      // Verify context is automatically provided
      expect(find.textContaining('User: John Doe'), findsOneWidget);
      expect(find.textContaining('Page: /dashboard'), findsOneWidget);
      expect(find.textContaining('Items in cart: 2'), findsOneWidget);
    });

    testWidgets('should update context when state changes', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: TestContextAwareApp(),
      ));

      await tester.pumpAndSettle();

      // Change user profile
      final updateProfileButton = find.byKey(const Key('update_profile'));
      await tester.tap(updateProfileButton);
      await tester.pumpAndSettle();

      // Verify context was updated
      expect(find.textContaining('User: Jane Smith'), findsOneWidget);
    });

    testWidgets('should integrate actions with context awareness',
        (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: TestContextAwareApp(),
      ));

      await tester.pumpAndSettle();

      // Execute context-aware action
      final contextActionButton = find.byKey(const Key('context_aware_action'));
      await tester.tap(contextActionButton);
      await tester.pumpAndSettle();

      // Wait for action execution
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();

      // Verify action used context data
      expect(find.textContaining('Hello John Doe'), findsOneWidget);
      expect(find.textContaining('dashboard'), findsOneWidget);
    });

    testWidgets('should filter context by priority and type', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: TestContextAwareApp(),
      ));

      await tester.pumpAndSettle();

      // Test context filtering
      final filterButton = find.byKey(const Key('filter_context'));
      await tester.tap(filterButton);
      await tester.pumpAndSettle();

      // Verify filtered context is displayed
      expect(find.textContaining('High Priority Context'), findsOneWidget);
      expect(find.textContaining('User Profile Context'), findsOneWidget);
    });

    testWidgets('should clean up expired context', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: TestContextAwareApp(),
      ));

      await tester.pumpAndSettle();

      // Add expired context
      final addExpiredButton = find.byKey(const Key('add_expired_context'));
      await tester.tap(addExpiredButton);
      await tester.pumpAndSettle();

      // Verify expired context is not included in summary
      final checkSummaryButton = find.byKey(const Key('check_summary'));
      await tester.tap(checkSummaryButton);
      await tester.pumpAndSettle();

      expect(find.textContaining('Expired Context'), findsNothing);
    });

    testWidgets('should stream context events', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: TestContextAwareApp(),
      ));

      await tester.pumpAndSettle();

      // Add context and verify event
      final addContextButton = find.byKey(const Key('add_context'));
      await tester.tap(addContextButton);
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('context_added_event')), findsOneWidget);

      // Update context and verify event
      final updateContextButton = find.byKey(const Key('update_context'));
      await tester.tap(updateContextButton);
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('context_updated_event')), findsOneWidget);
    });
  });
}

class TestContextAwareApp extends StatefulWidget {
  @override
  _TestContextAwareAppState createState() => _TestContextAwareAppState();
}

class _TestContextAwareAppState extends State<TestContextAwareApp> {
  late AiContextController _contextController;
  late ActionController _actionController;
  late ValueNotifier<Map<String, dynamic>> _userProfile;
  late ValueNotifier<String> _currentPage;
  late ValueNotifier<List<String>> _shoppingCart;

  String _lastActionResult = '';
  String _contextSummary = '';
  List<String> _events = [];

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _setupInitialContext();
    _setupActions();
    _listenToEvents();
  }

  void _initializeControllers() {
    _contextController = AiContextController(
      config: const AiContextConfig(enableLogging: true),
    );
    _actionController = ActionController();
    _actionController.contextController = _contextController;
  }

  void _setupInitialContext() {
    // User profile
    _userProfile = ValueNotifier({
      'name': 'John Doe',
      'email': 'john@example.com',
      'role': 'user',
    });

    _contextController.watchNotifier(
      contextId: 'user_profile',
      contextName: 'User Profile',
      notifier: _userProfile,
      type: AiContextType.userProfile,
      priority: AiContextPriority.high,
      categories: ['user', 'profile'],
    );

    // Current page
    _currentPage = ValueNotifier('/dashboard');
    _contextController.watchNotifier(
      contextId: 'current_page',
      contextName: 'Current Page',
      notifier: _currentPage,
      type: AiContextType.navigationContext,
      priority: AiContextPriority.high,
      categories: ['navigation'],
    );

    // Shopping cart
    _shoppingCart = ValueNotifier(['item1', 'item2']);
    _contextController.watchNotifier(
      contextId: 'shopping_cart',
      contextName: 'Shopping Cart',
      notifier: _shoppingCart,
      type: AiContextType.applicationState,
      priority: AiContextPriority.normal,
      categories: ['shopping', 'cart'],
    );
  }

  void _setupActions() {
    _actionController.registerAction(AiAction(
      name: 'greet_user',
      description: 'Greet user with context awareness',
      parameters: [],
      handler: (params) async {
        final context = _contextController.getContextForPrompt();
        final userProfile = context['user_profile'] as Map<String, dynamic>?;
        final currentPage = context['current_page'] as Map<String, dynamic>?;

        final userName = userProfile?['data']['name'] ?? 'User';
        final page = currentPage?['data'] ?? 'unknown page';

        await Future.delayed(const Duration(milliseconds: 500));

        return ActionResult.createSuccess({
          'greeting': 'Hello $userName! I see you\'re on the $page.',
        });
      },
    ));
  }

  void _listenToEvents() {
    _contextController.events.listen((event) {
      setState(() {
        _events.add('${event.type.name}: ${event.contextData?.id}');
      });
    });
  }

  void _updateProfile() {
    _userProfile.value = {
      'name': 'Jane Smith',
      'email': 'jane@example.com',
      'role': 'admin',
    };
  }

  Future<void> _executeContextAwareAction() async {
    final result = await _actionController.executeAction('greet_user', {});
    setState(() {
      _lastActionResult =
          result.success ? result.data['greeting'] : result.error ?? 'Error';
    });
  }

  void _filterContext() {
    final summary = _contextController.getContextSummary(
      priorities: [AiContextPriority.high],
      types: [AiContextType.userProfile],
      maxItems: 2,
    );
    setState(() {
      _contextSummary = summary;
    });
  }

  void _addExpiredContext() {
    _contextController.setContext(AiContextData.custom(
      id: 'expired_context',
      name: 'Expired Context',
      data: 'This should not appear',
      description: 'Context that expires immediately',
      expiresAt: DateTime.now().subtract(const Duration(seconds: 1)),
    ));
  }

  void _checkSummary() {
    final summary = _contextController.getContextSummary();
    setState(() {
      _contextSummary = summary;
    });
  }

  void _addContext() {
    _contextController.setContext(AiContextData.custom(
      id: 'new_context',
      name: 'New Context',
      data: 'New data',
      description: 'Newly added context',
    ));
  }

  void _updateContext() {
    _contextController.updateContext('new_context', 'Updated data');
  }

  @override
  void dispose() {
    _contextController.dispose();
    _actionController.dispose();
    _userProfile.dispose();
    _currentPage.dispose();
    _shoppingCart.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AiContextProvider(
      controller: _contextController,
      config: const AiContextProviderConfig(
        autoNavigationContext: true,
        autoThemeContext: true,
      ),
      child: AiActionProvider(
        config: AiActionConfig(actions: []),
        controller: _actionController,
        child: Scaffold(
          appBar: AppBar(title: const Text('Context Integration Test')),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Current context display
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Current Context:',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        Text('User: ${_userProfile.value['name']}'),
                        Text('Page: ${_currentPage.value}'),
                        Text('Items in cart: ${_shoppingCart.value.length}'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Action buttons
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ElevatedButton(
                      key: const Key('update_profile'),
                      onPressed: _updateProfile,
                      child: const Text('Update Profile'),
                    ),
                    ElevatedButton(
                      key: const Key('context_aware_action'),
                      onPressed: _executeContextAwareAction,
                      child: const Text('Context Aware Action'),
                    ),
                    ElevatedButton(
                      key: const Key('filter_context'),
                      onPressed: _filterContext,
                      child: const Text('Filter Context'),
                    ),
                    ElevatedButton(
                      key: const Key('add_expired_context'),
                      onPressed: _addExpiredContext,
                      child: const Text('Add Expired Context'),
                    ),
                    ElevatedButton(
                      key: const Key('check_summary'),
                      onPressed: _checkSummary,
                      child: const Text('Check Summary'),
                    ),
                    ElevatedButton(
                      key: const Key('add_context'),
                      onPressed: _addContext,
                      child: const Text('Add Context'),
                    ),
                    ElevatedButton(
                      key: const Key('update_context'),
                      onPressed: _updateContext,
                      child: const Text('Update Context'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Results display
                if (_lastActionResult.isNotEmpty) ...[
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Action Result:',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          Text(_lastActionResult),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                if (_contextSummary.isNotEmpty) ...[
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Context Summary:',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          Text(_contextSummary),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Event indicators
                if (_events.contains('added: new_context'))
                  Container(
                    key: const Key('context_added_event'),
                    child: const Text('Context Added Event',
                        style: TextStyle(color: Colors.green)),
                  ),
                if (_events.contains('updated: new_context'))
                  Container(
                    key: const Key('context_updated_event'),
                    child: const Text('Context Updated Event',
                        style: TextStyle(color: Colors.blue)),
                  ),

                // Debug info
                if (_events.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Events:',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          ...(_events.take(5).map((event) => Text('• $event'))),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
