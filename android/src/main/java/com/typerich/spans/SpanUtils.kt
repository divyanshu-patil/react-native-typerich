package com.typerich.spans

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

}
