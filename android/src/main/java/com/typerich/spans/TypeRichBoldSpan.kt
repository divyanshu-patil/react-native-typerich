package com.typerich.spans

import android.graphics.Typeface
import android.text.Editable
import android.text.style.StyleSpan

class TypeRichBoldSpan : ITypeRichSpanRule {
  override val regex = Regex("""\*(.+?)\*""",setOf(RegexOption.DOT_MATCHES_ALL)) // *text*

  override val spanClass = StyleSpan::class.java

  override fun apply(editable: Editable, match: MatchResult) {
    val content = match.groupValues[1]

    val start = match.range.first + 1
    val end = start + content.length

    editable.setSpan(
      StyleSpan(Typeface.BOLD),
      start,
      end,
      Editable.SPAN_EXCLUSIVE_EXCLUSIVE
    )
  }
}
