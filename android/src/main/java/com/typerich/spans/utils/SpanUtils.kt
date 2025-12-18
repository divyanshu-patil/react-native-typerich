package com.typerich.spans.utils

import android.text.Editable
import com.typerich.spans.interfaces.ESpanPriority
import com.typerich.spans.interfaces.ITypeRichInternalSpan
import com.typerich.spans.interfaces.ITypeRichSemanticSpan

object SpanUtils {

  fun addSpans(editable: Editable){
    val text = editable.toString()

    // semantic pass
    SpanRegistry.rules
      .filter { it.priority == ESpanPriority.SEMANTIC }
      .forEach { rule ->
        rule.regex.findAll(text).forEach { rule.apply(editable, it) }
      }

    // styling pass
    SpanRegistry.rules
      .filter { it.priority == ESpanPriority.STYLING }
      .forEach { rule ->
        rule.regex.findAll(text).forEach { match ->
          val (start, end) = SpanUtils.getRange(match)

          // skipping semantic regions
          if (hasSemanticSpan(editable, start, end)) return@forEach

          rule.apply(editable, match)
        }
      }
  }

  fun clearSpans(editable: Editable, start: Int, end: Int) {
    SpanRegistry.rules.forEach { rule ->
      editable.getSpans(start, end, rule.spanClass)
        .forEach { span -> editable.removeSpan(span) }
    }
  }

  fun getRange(match: MatchResult): Pair<Int, Int> {
    val full = match.groupValues[0]
    val content = match.groupValues[1]

    val start = match.range.first + full.indexOf(content)
    val end = start + content.length

    return start to end
  }

  fun hasSemanticSpan(editable: Editable, start: Int, end: Int): Boolean {
    return editable.getSpans(start, end, ITypeRichInternalSpan::class.java)
      .any { it is ITypeRichSemanticSpan }
  }

}
