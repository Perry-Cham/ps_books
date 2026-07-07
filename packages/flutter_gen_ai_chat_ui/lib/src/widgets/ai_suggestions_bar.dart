import 'package:flutter/material.dart';

/// A simple, non-invasive suggestions bar that displays suggestion chips above the input.
///
/// This widget is UI-only. It accepts a list of suggestions and exposes callbacks for
/// selection and refresh. Logic and providers are intentionally kept out to avoid bloat.
class AiSuggestionsBar extends StatelessWidget {
  /// Suggestions to display as chips.
  final List<String> suggestions;

  /// Callback when a suggestion is tapped.
  final ValueChanged<String>? onSelect;

  /// Optional trailing action (e.g., refresh button) with tooltip.
  final VoidCallback? onRefresh;
  final String? refreshTooltip;

  /// Controls layout density and maximum visible rows.
  final EdgeInsetsGeometry padding;
  final double chipSpacing;
  final double runSpacing;
  final int maxLines;

  /// Optional style overrides.
  final TextStyle? chipTextStyle;
  final Color? chipBackgroundColor;
  final Color? chipSelectedColor;

  const AiSuggestionsBar({
    super.key,
    required this.suggestions,
    this.onSelect,
    this.onRefresh,
    this.refreshTooltip,
    this.padding = const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
    this.chipSpacing = 6.0,
    this.runSpacing = 6.0,
    this.maxLines = 1,
    this.chipTextStyle,
    this.chipBackgroundColor,
    this.chipSelectedColor,
  });

  @override
  Widget build(BuildContext context) {
    if (suggestions.isEmpty) {
      return const SizedBox.shrink();
    }

    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final defaultChipBg =
        chipBackgroundColor ?? colorScheme.surfaceContainerHighest;
    final defaultTextStyle = chipTextStyle ?? textTheme.labelLarge;

    // Wrap in Semantics for accessibility
    return Semantics(
      label: 'Suggestions',
      child: Padding(
        padding: padding,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _SuggestionsWrap(
                suggestions: suggestions,
                onSelect: onSelect,
                chipSpacing: chipSpacing,
                runSpacing: runSpacing,
                maxLines: maxLines,
                chipBackgroundColor: defaultChipBg,
                chipTextStyle: defaultTextStyle,
              ),
            ),
            if (onRefresh != null)
              Padding(
                padding: const EdgeInsets.only(left: 4.0),
                child: Tooltip(
                  message: refreshTooltip ?? 'Refresh suggestions',
                  child: IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: onRefresh,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _SuggestionsWrap extends StatelessWidget {
  final List<String> suggestions;
  final ValueChanged<String>? onSelect;
  final double chipSpacing;
  final double runSpacing;
  final int maxLines;
  final Color chipBackgroundColor;
  final TextStyle? chipTextStyle;

  const _SuggestionsWrap({
    required this.suggestions,
    required this.onSelect,
    required this.chipSpacing,
    required this.runSpacing,
    required this.maxLines,
    required this.chipBackgroundColor,
    required this.chipTextStyle,
  });

  @override
  Widget build(BuildContext context) {
    // Constrain vertical size by lines using a LayoutBuilder + Wrap.
    return LayoutBuilder(
      builder: (context, constraints) {
        // Render as simple Wrap. Consumers can put this inside a scroll view if needed.
        return Wrap(
          spacing: chipSpacing,
          runSpacing: runSpacing,
          children: suggestions.map((s) {
            return _SuggestionChip(
              label: s,
              backgroundColor: chipBackgroundColor,
              textStyle: chipTextStyle,
              onTap: () => onSelect?.call(s),
            );
          }).toList(growable: false),
        );
      },
    );
  }
}

class _SuggestionChip extends StatelessWidget {
  final String label;
  final Color backgroundColor;
  final TextStyle? textStyle;
  final VoidCallback? onTap;

  const _SuggestionChip({
    required this.label,
    required this.backgroundColor,
    required this.textStyle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveStyle = textStyle ?? Theme.of(context).textTheme.labelLarge;
    return Semantics(
      button: true,
      label: 'Suggestion: $label',
      child: Material(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Text(label, style: effectiveStyle),
          ),
        ),
      ),
    );
  }
}
