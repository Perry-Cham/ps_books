# UI/UX Roadmap (Frontend-First)

This roadmap focuses strictly on UI/UX surfaces for `flutter_gen_ai_chat_ui`. Logic/orchestration (LLM providers, agents, analytics) is intentionally deferred to later phases. We will build on existing components to avoid bloat.

## Principles

- UI-first, backend-agnostic. All new pieces are optional.
- Headless-friendly: prebuilt widgets plus builder hooks.
- Themeable: `ThemeExtension` + design tokens.
- Accessibility, RTL, and 60fps performance are baseline requirements.

## Phases (UI only)

### Phase 0 — Baseline polish and unlocks

- Align SDK to use `flutter_streaming_text_markdown ^1.3.1` (visual parity and performance).
- Reconcile duplicated `CHANGELOG` entries; remove stray backup files.
- Fix version drift in related packages (no API changes).

### Phase 1 — Core chat surfaces

- `AiChatScaffold`: responsive layout, max-width, gutters.
- `ChatMessageList`: virtualization-aware builder; sticky dividers; system banners.
- `ChatMessageBubble` presets: Modern, Minimal, Glass, Compact.
- Adornments: timestamps, avatars, roles, reactions, collapsible long content.
- Empty/error/skeleton states with shimmer.

### Phase 2 — Input & suggestions UX

- `InlineAutocompleteTextField`: ghost text + Tab accept (provider-agnostic).
- `AiSuggestionsBar`: chips above input (accepts a suggestions stream; no logic inside).
- `QuickPromptChips`: persistent prompts with overflow and keyboard navigation.
- Micro-interactions: animated send, typing indicators, refined attachment affordances.

### Phase 3 — Sidecar and popup patterns

- `AiSidePanel`: collapsible/resizable assistant panel.
- `AiPopup`: floating popover attached to triggers (selection, button, field focus).
- `AiOverlayCommandPalette`: command palette overlay with fuzzy filtering (UI only).

### Phase 4 — Result renderers (UI-only)

- `ResultRendererRegistry` (UI mapping): map simple `kind` strings to widgets.
- Built-ins: `ResultCard`, `KeyValueList`, `DataTableLite`, `MarkdownCard`, `CodeResult`, `FilePreview`, `Callout`.

### Phase 5 — Parameter forms (UI-only)

- `ActionParamForm`: form auto-built from a simple JSON-like schema (text/number/enum/toggle/array/object).
- Inline validation visuals, segmented controls, switches.

### Phase 6 — Design tokens & theming

- Tokens: color, type, radius, elevation, spacing, motion.
- `ChatThemeExtension`: presets (Modern, Minimal, Glass, HighContrast) + density (compact/comfortable).
- Material 3 alignment, system color harmonization.

### Phase 7 — Accessibility, i18n, RTL

- Full semantics: bubbles, input, chips; focus management; keyboard traversal.
- Contrast-checked palettes; reduced motion; large text.
- RTL correctness; leverage `flutter_kurdish` where relevant.

### Phase 8 — Performance + goldens

- Target 60fps with large threads; minimize rebuilds.
- Golden tests per component state; stress tests (long code, large lists, images).

### Phase 9 — Voice affordances (UI wrappers only)

- Inline `voice_flow_ui` wrappers: `MicButton`, `ListeningIndicator`, `TranscriptChip`.
- Non-invasive: no audio logic, only visual states.

### Phase 10 — Docs & gallery

- Recipes: drop-in suggestions, command palette, sidecar assistant, result cards, param forms.
- Theming cookbook with tokens; accessibility checklist.
- Gallery example toggling themes/densities and surfaces.

## Component Inventory (deliverables)

- Thread: `AiChatScaffold`, `ChatMessageList`, `ChatDayDivider`, `SystemBanner`.
- Bubbles: `ChatMessageBubble` + presets, `MessageMetadataRow`, `ReactionsRow`, `CollapsibleBlock`.
- Input: `InlineAutocompleteTextField`, `AiSuggestionsBar`, `QuickPromptChips`, `AttachmentTray`.
- Surfaces: `AiSidePanel`, `AiPopup`, `AiOverlayCommandPalette`.
- Results: `ResultCard`, `KeyValueList`, `DataTableLite`, `MarkdownCard`, `CodeResult`, `FilePreview`, `Callout`.
- Params: `ActionParamForm` (schema-driven UI only).
- Voice: wrappers for visual states from `voice_flow_ui`.
- Dev UX (UI-only): `DevConsolePanel` showing example UI events (no analytics wiring).

## Extensibility (UI-only contracts)

- All widgets accept theme overrides via `ThemeExtension`.
- Builder hooks: `bubbleBuilder`, `metadataBuilder`, `resultRenderer`, `paramFieldBuilder`.
- Provider-agnostic interfaces (no implementations):
  - `SuggestionsProvider` → stream of suggestions for `AiSuggestionsBar` and `InlineAutocompleteTextField`.
  - `ParamSchema` (simple JSON-like) → drives `ActionParamForm` fields.
  - `ResultRendererRegistry` → maps `kind` to widget builders.

## Acceptance Criteria

- 60fps on long lists; <16ms average frame on mid-range devices.
- Zero analyzer warnings; a11y checks pass (semantics, contrast, focus).
- Each component documented with examples; golden tests for default states.
- No required backend to render any UI component.

## Non-Bloat Policy

- Build upon existing `AiChatWidget`/bubbles; new widgets are opt-in.
- No heavy deps; keep footprint minimal.
- Prefer small, composable widgets over monoliths.

## Immediate Next (non-invasive)

- Add `AiSuggestionsBar` + `InlineAutocompleteTextField` (provider-agnostic stubs).
- Introduce `ChatThemeExtension` tokens and two presets (Modern, Minimal).
- Update example to showcase suggestions bar and theme presets.
