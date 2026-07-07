/// Types of context data that can be provided to AI
enum AiContextType {
  /// User profile and preferences
  userProfile,

  /// Application state (shopping cart, form data, etc.)
  applicationState,

  /// Current page or screen context
  navigationContext,

  /// Business logic state (inventory, account balance, etc.)
  businessContext,

  /// UI state (selected items, form values, etc.)
  uiState,

  /// Custom context types
  custom,
}

/// Priority levels for context data
enum AiContextPriority {
  /// Low priority - background information
  low,

  /// Normal priority - standard context
  normal,

  /// High priority - important for current conversation
  high,

  /// Critical priority - essential for AI responses
  critical,
}

/// A piece of contextual information that the AI can access
class AiContextData {
  /// Unique identifier for this context data
  final String id;

  /// Human-readable name for this context
  final String name;

  /// Type of context data
  final AiContextType type;

  /// Priority level for AI consideration
  final AiContextPriority priority;

  /// The actual context data
  final dynamic data;

  /// Description of what this context represents
  final String description;

  /// Categories or tags for filtering context
  final List<String> categories;

  /// When this context was last updated
  final DateTime lastUpdated;

  /// Whether this context should be included in AI prompts
  final bool enabled;

  /// Custom serializer for AI consumption
  final String Function(dynamic data)? serializer;

  /// Optional expiration time for context data
  final DateTime? expiresAt;

  AiContextData({
    required this.id,
    required this.name,
    required this.type,
    required this.data,
    required this.description,
    this.priority = AiContextPriority.normal,
    this.categories = const [],
    DateTime? lastUpdated,
    this.enabled = true,
    this.serializer,
    this.expiresAt,
  }) : lastUpdated = lastUpdated ?? DateTime.now();

  /// Create context for user profile data
  factory AiContextData.userProfile({
    required String id,
    required String name,
    required Map<String, dynamic> profileData,
    String? description,
    AiContextPriority priority = AiContextPriority.high,
    List<String> categories = const [],
  }) {
    return AiContextData(
      id: id,
      name: name,
      type: AiContextType.userProfile,
      data: profileData,
      description: description ?? 'User profile information',
      priority: priority,
      categories: categories,
    );
  }

  /// Create context for application state
  factory AiContextData.applicationState({
    required String id,
    required String name,
    required dynamic stateData,
    String? description,
    AiContextPriority priority = AiContextPriority.normal,
    List<String> categories = const [],
    String Function(dynamic data)? serializer,
  }) {
    return AiContextData(
      id: id,
      name: name,
      type: AiContextType.applicationState,
      data: stateData,
      description: description ?? 'Application state data',
      priority: priority,
      categories: categories,
      serializer: serializer,
    );
  }

  /// Create context for navigation/page context
  factory AiContextData.navigationContext({
    required String id,
    required String currentPage,
    Map<String, dynamic>? pageData,
    String? description,
    AiContextPriority priority = AiContextPriority.high,
  }) {
    return AiContextData(
      id: id,
      name: 'Current Page',
      type: AiContextType.navigationContext,
      data: {
        'currentPage': currentPage,
        'pageData': pageData ?? {},
        'timestamp': DateTime.now().toIso8601String(),
      },
      description: description ?? 'Current navigation context',
      priority: priority,
      categories: ['navigation', 'routing'],
    );
  }

  /// Create context for business logic state
  factory AiContextData.businessContext({
    required String id,
    required String name,
    required dynamic businessData,
    String? description,
    AiContextPriority priority = AiContextPriority.normal,
    List<String> categories = const [],
  }) {
    return AiContextData(
      id: id,
      name: name,
      type: AiContextType.businessContext,
      data: businessData,
      description: description ?? 'Business context data',
      priority: priority,
      categories: categories,
    );
  }

  /// Create custom context data
  factory AiContextData.custom({
    required String id,
    required String name,
    required dynamic data,
    required String description,
    AiContextPriority priority = AiContextPriority.normal,
    List<String> categories = const [],
    String Function(dynamic data)? serializer,
    DateTime? expiresAt,
  }) {
    return AiContextData(
      id: id,
      name: name,
      type: AiContextType.custom,
      data: data,
      description: description,
      priority: priority,
      categories: categories,
      serializer: serializer,
      expiresAt: expiresAt,
    );
  }

  /// Check if this context data is still valid (not expired)
  bool get isValid {
    if (expiresAt == null) return true;
    return DateTime.now().isBefore(expiresAt!);
  }

  /// Serialize context data for AI consumption
  String toAiString() {
    if (serializer != null) {
      return serializer!(data);
    }

    // Default serialization based on data type
    if (data is Map) {
      final entries = (data as Map<String, dynamic>)
          .entries
          .where((e) => e.value != null)
          .map((e) => '${e.key}: ${e.value}')
          .join(', ');
      return '$name: {$entries}';
    } else if (data is List) {
      final items = (data as List).map((item) => item.toString()).join(', ');
      return '$name: [$items]';
    } else {
      return '$name: ${data.toString()}';
    }
  }

  /// Create a copy with updated data
  AiContextData copyWith({
    String? id,
    String? name,
    AiContextType? type,
    AiContextPriority? priority,
    dynamic data,
    String? description,
    List<String>? categories,
    DateTime? lastUpdated,
    bool? enabled,
    String Function(dynamic data)? serializer,
    DateTime? expiresAt,
  }) {
    return AiContextData(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      priority: priority ?? this.priority,
      data: data ?? this.data,
      description: description ?? this.description,
      categories: categories ?? this.categories,
      lastUpdated: lastUpdated ?? DateTime.now(),
      enabled: enabled ?? this.enabled,
      serializer: serializer ?? this.serializer,
      expiresAt: expiresAt ?? this.expiresAt,
    );
  }

  /// Convert to JSON for debugging/logging
  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'type': type.toString().split('.').last,
        'priority': priority.toString().split('.').last,
        'description': description,
        'categories': categories,
        'lastUpdated': lastUpdated.toIso8601String(),
        'enabled': enabled,
        'data': data.toString(), // Don't expose raw data in JSON
        if (expiresAt != null) 'expiresAt': expiresAt!.toIso8601String(),
      };

  @override
  String toString() => 'AiContextData(id: $id, name: $name, type: $type)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AiContextData &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}

/// Event types for context updates
enum AiContextEventType {
  /// Context data was added
  added,

  /// Context data was updated
  updated,

  /// Context data was removed
  removed,

  /// Context was cleared
  cleared,
}

/// Event emitted when context changes
class AiContextEvent {
  /// Type of context event
  final AiContextEventType type;

  /// The context data involved in the event
  final AiContextData? contextData;

  /// Optional previous state for update events
  final AiContextData? previousData;

  /// Timestamp of the event
  final DateTime timestamp;

  /// Optional metadata about the event
  final Map<String, dynamic>? metadata;

  AiContextEvent({
    required this.type,
    this.contextData,
    this.previousData,
    DateTime? timestamp,
    this.metadata,
  }) : timestamp = timestamp ?? DateTime.now();

  @override
  String toString() =>
      'AiContextEvent(type: $type, context: ${contextData?.id}, time: $timestamp)';
}
