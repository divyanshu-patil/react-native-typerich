package com.typerich.spans

import android.graphics.Typeface
import android.text.Editable
import android.text.style.StyleSpan
import com.typerich.spans.interfaces.ESpanPriority
import com.typerich.spans.interfaces.ITypeRichInternalSpan
import com.typerich.spans.interfaces.ITypeRichSpanRule
import com.typerich.spans.utils.SpanUtils

class TypeRichItalicSpan: StyleSpan(Typeface.ITALIC), ITypeRichSpanRule, ITypeRichInternalSpan {
  override val regex = Regex("_(.+?)_",setOf(RegexOption.DOT_MATCHES_ALL)) // _text_

  override val spanClass = ITypeRichInternalSpan::class.java
  override val priority: ESpanPriority = ESpanPriority.STYLING

  override fun apply(editable: Editable, match: MatchResult) {
    val (start, end) = SpanUtils.getRange(match)

    // block styling inside semantic spans, must implement ITypeRichSemanticSpan
    if (SpanUtils.hasSemanticSpan(editable, start, end)) return

    editable.setSpan(
      TypeRichItalicSpan(),
      start,
      end,
      Editable.SPAN_EXCLUSIVE_EXCLUSIVE
    )
  }
}
