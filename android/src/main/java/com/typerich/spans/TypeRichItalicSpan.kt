package com.typerich.spans

import android.graphics.Typeface
import android.text.Editable
import android.text.style.StyleSpan
import com.typerich.spans.interfaces.ITypeRichSpanRule
import com.typerich.spans.utils.SpanUtils

class TypeRichItalicSpan: ITypeRichSpanRule {
  override val regex = Regex("_(.+?)_",setOf(RegexOption.DOT_MATCHES_ALL)) // _text_

  override val spanClass = StyleSpan::class.java

  override fun apply(editable: Editable, match: MatchResult) {
    val (start, end) = SpanUtils.getRange(match)

    editable.setSpan(
      StyleSpan(Typeface.ITALIC),
      start,
      end,
      Editable.SPAN_EXCLUSIVE_EXCLUSIVE
    )
  }
}
