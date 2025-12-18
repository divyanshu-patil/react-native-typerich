package com.typerich.spans.utils

import com.typerich.spans.interfaces.ITypeRichSpanRule
import com.typerich.spans.TypeRichBoldSpan
import com.typerich.spans.TypeRichChannelSpan
import com.typerich.spans.TypeRichItalicSpan
import com.typerich.spans.TypeRichMentionSpan
import com.typerich.spans.TypeRichStrikeSpan

object SpanRegistry {

  // Add new rules here ONCE — no other code changes
  //  todo toggle which spans to support
  val rules: List<ITypeRichSpanRule> = listOf(
    TypeRichBoldSpan(),
    TypeRichItalicSpan(),
    TypeRichStrikeSpan(),
    TypeRichMentionSpan(),
    TypeRichChannelSpan()
  )
}
