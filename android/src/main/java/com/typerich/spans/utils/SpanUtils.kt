package com.typerich.spans.utils

import android.text.Editable

object SpanUtils {

  fun addSpans(editable: Editable){
    val text = editable.toString()
    SpanRegistry.rules.forEach { rule ->
      rule.regex.findAll(text).forEach { match ->
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
}
