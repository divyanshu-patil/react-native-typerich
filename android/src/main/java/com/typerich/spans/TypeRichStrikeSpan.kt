package com.typerich.spans

import android.graphics.Typeface
import android.text.Editable
import android.text.style.StrikethroughSpan
import android.text.style.StyleSpan

class TypeRichStrikeSpan:ITypeRichSpanRule {
  override val regex = Regex("~(.+?)~",setOf(RegexOption.DOT_MATCHES_ALL)) // _text_

  override val spanClass = StrikethroughSpan::class.java

  override fun apply(editable: Editable, match: MatchResult) {
    val content = match.groupValues[1]

    val start = match.range.first + 1
    val end = start + content.length

    editable.setSpan(
      StrikethroughSpan(),
      start,
      end,
      Editable.SPAN_EXCLUSIVE_EXCLUSIVE
    )
  }
}
