package com.typerich.spans

import android.text.Editable
import android.text.style.StrikethroughSpan
import com.typerich.spans.interfaces.ITypeRichSpanRule
import com.typerich.spans.utils.SpanUtils

class TypeRichStrikeSpan: ITypeRichSpanRule {
  override val regex = Regex("~(.+?)~",setOf(RegexOption.DOT_MATCHES_ALL)) // _text_

  override val spanClass = StrikethroughSpan::class.java

  override fun apply(editable: Editable, match: MatchResult) {
    val (start, end) = SpanUtils.getRange(match)

    editable.setSpan(
      StrikethroughSpan(),
      start,
      end,
      Editable.SPAN_EXCLUSIVE_EXCLUSIVE
    )
  }
}
