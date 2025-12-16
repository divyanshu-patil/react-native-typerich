package com.typerich.spans

object SpanRegistry {

  // Add new rules here ONCE — no other code changes
  val rules: List<ITypeRichSpanRule> = listOf(
    TypeRichBoldSpan(),
    TypeRichItalicSpan(),
    TypeRichStrikeSpan()
  )
}
