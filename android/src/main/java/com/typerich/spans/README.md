## Important links

- [ANDROID Spans, Developer.android.com](https://developer.android.com/develop/ui/views/text-and-emoji/spans)
- [Android Spans, Tutorials point](https://www.tutorialspoint.com/text-styling-with-spans-in-android)

---

> **Note:** below content is AI generated and will be updated as per need, currently use this as guidance

---

# Android Spans Cheatsheet – When to Use What

This guide explains which Android text span to use for common rich-text and message-composer scenarios.

---

## StyleSpan

Use when you need bold or italic styling.

```kotlin
StyleSpan(Typeface.BOLD)
StyleSpan(Typeface.ITALIC)
StyleSpan(Typeface.BOLD_ITALIC)
```

Use cases:

- Markdown bold and italic

Do not use for:

- Font family changes
- Colors or click handling

---

## TypefaceSpan

Use when you want to change the font family.

```kotlin
TypefaceSpan("monospace")
```

Use cases:

- Inline code formatting
- Simple visual mentions

Limitations:

- No metadata storage
- No click handling

---

## ForegroundColorSpan / BackgroundColorSpan

Use when you want to apply color.

```kotlin
ForegroundColorSpan(Color.BLUE)
BackgroundColorSpan(Color.YELLOW)
```

Use cases:

- Mention highlighting
- Syntax highlighting

---

## ClickableSpan

Use when text should respond to taps.

```kotlin
ClickableSpan {
  // handle click
}
```

Notes:

- Requires `LinkMovementMethod`

Use cases:

- Mentions
- Custom links

---

## URLSpan

Use for simple hyperlinks.

```kotlin
URLSpan("https://example.com")
```

Use cases:

- Automatically opening URLs

Limitations:

- No custom click logic

---

## MetricAffectingSpan

Use when text measurement or font metrics change.
Usually extended, not used directly.

```kotlin
class CustomFontSpan(private val typeface: Typeface) : MetricAffectingSpan()
```

Use cases:

- Custom fonts
- Advanced typography

---

## ReplacementSpan

> links: [Android docs, Replacement Span](https://developer.android.com/reference/android/text/style/ReplacementSpan)

Use when text should behave as a single atomic unit.

```kotlin
class MentionSpan(...) : ReplacementSpan()
```

Use cases:

- Mentions
- Chips
- Inline emojis
- Preventing partial deletion

Notes:

- Commonly used in chat applications

---

## ImageSpan

Use for inline images.

```kotlin
ImageSpan(drawable)
```

Use cases:

- Emojis
- Inline media

---

## LeadingMarginSpan

Use for indentation or block formatting.

```kotlin
LeadingMarginSpan.Standard(40)
```

Use cases:

- Quotes
- Lists

---

## QuoteSpan

Use for block quotes.

```kotlin
QuoteSpan(Color.GRAY)
```

Use cases:

- Markdown-style quotes

---

## UnderlineSpan / StrikethroughSpan

Use for simple text decoration.

```kotlin
UnderlineSpan()
StrikethroughSpan()
```

Use cases:

- Underlined text
- Strikethrough text

---

## SpanWatcher

Use to observe span lifecycle events.

```kotlin
SpanWatcher
```

Use cases:

- Detect span deletion
- Enforce editor invariants

---

## Recommended Span Mapping for Rich Editors

| Feature            | Recommended Span    |
| ------------------ | ------------------- |
| Bold / Italic      | StyleSpan           |
| Inline code        | TypefaceSpan        |
| Mention (visual)   | ForegroundColorSpan |
| Mention (semantic) | ReplacementSpan     |
| URL                | ClickableSpan       |

---

## General Guidelines

- Spans are rendering tools, not semantic models
- Always validate spans after text changes
- Prefer start/endExclusive indices over inclusive ranges
- Use custom span classes for features like mentions
