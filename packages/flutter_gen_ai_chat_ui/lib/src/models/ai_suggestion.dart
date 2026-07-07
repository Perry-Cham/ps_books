/// Represents an AI text suggestion for enhanced input fields
/// Equivalent to CopilotKit's text enhancement suggestions
class AiSuggestion {
  final String id;
  final String text;
  final String replacementText;
  final int startIndex;
  final int endIndex;
  final AiSuggestionType type;
  final double confidence;
  final Map<String, dynamic>? metadata;

  const AiSuggestion({
    required this.id,
    required this.text,
    required this.replacementText,
    required this.startIndex,
    required this.endIndex,
    required this.type,
    this.confidence = 1.0,
    this.metadata,
  });

  AiSuggestion copyWith({
    String? id,
    String? text,
    String? replacementText,
    int? startIndex,
    int? endIndex,
    AiSuggestionType? type,
    double? confidence,
    Map<String, dynamic>? metadata,
  }) {
    return AiSuggestion(
      id: id ?? this.id,
      text: text ?? this.text,
      replacementText: replacementText ?? this.replacementText,
      startIndex: startIndex ?? this.startIndex,
      endIndex: endIndex ?? this.endIndex,
      type: type ?? this.type,
      confidence: confidence ?? this.confidence,
      metadata: metadata ?? this.metadata,
    );
  }
}

/// Types of AI suggestions available
enum AiSuggestionType {
  completion, // Autocomplete current word/sentence
  enhancement, // Improve existing text
  grammar, // Grammar corrections
  style, // Style improvements
  draft, // Generate complete draft
}

/// Configuration for AI-enhanced text input behavior
class AiTextInputConfig {
  final bool enableAutoComplete;
  final bool enableSmartEdits;
  final bool enableAutoDrafts;
  final bool enableGrammarCheck;
  final Duration suggestionDelay;
  final int minCharactersForSuggestion;
  final int maxSuggestions;
  final List<AiSuggestionType> enabledSuggestionTypes;

  const AiTextInputConfig({
    this.enableAutoComplete = true,
    this.enableSmartEdits = true,
    this.enableAutoDrafts = false,
    this.enableGrammarCheck = true,
    this.suggestionDelay = const Duration(milliseconds: 500),
    this.minCharactersForSuggestion = 3,
    this.maxSuggestions = 3,
    this.enabledSuggestionTypes = const [
      AiSuggestionType.completion,
      AiSuggestionType.enhancement,
      AiSuggestionType.grammar,
    ],
  });

  AiTextInputConfig copyWith({
    bool? enableAutoComplete,
    bool? enableSmartEdits,
    bool? enableAutoDrafts,
    bool? enableGrammarCheck,
    Duration? suggestionDelay,
    int? minCharactersForSuggestion,
    int? maxSuggestions,
    List<AiSuggestionType>? enabledSuggestionTypes,
  }) {
    return AiTextInputConfig(
      enableAutoComplete: enableAutoComplete ?? this.enableAutoComplete,
      enableSmartEdits: enableSmartEdits ?? this.enableSmartEdits,
      enableAutoDrafts: enableAutoDrafts ?? this.enableAutoDrafts,
      enableGrammarCheck: enableGrammarCheck ?? this.enableGrammarCheck,
      suggestionDelay: suggestionDelay ?? this.suggestionDelay,
      minCharactersForSuggestion:
          minCharactersForSuggestion ?? this.minCharactersForSuggestion,
      maxSuggestions: maxSuggestions ?? this.maxSuggestions,
      enabledSuggestionTypes:
          enabledSuggestionTypes ?? this.enabledSuggestionTypes,
    );
  }
}

/// State for AI text input suggestions
class AiTextInputState {
  final String text;
  final List<AiSuggestion> suggestions;
  final AiSuggestion? activeSuggestion;
  final bool isLoading;
  final String? error;

  const AiTextInputState({
    this.text = '',
    this.suggestions = const [],
    this.activeSuggestion,
    this.isLoading = false,
    this.error,
  });

  AiTextInputState copyWith({
    String? text,
    List<AiSuggestion>? suggestions,
    AiSuggestion? activeSuggestion,
    bool? isLoading,
    String? error,
  }) {
    return AiTextInputState(
      text: text ?? this.text,
      suggestions: suggestions ?? this.suggestions,
      activeSuggestion: activeSuggestion,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}
