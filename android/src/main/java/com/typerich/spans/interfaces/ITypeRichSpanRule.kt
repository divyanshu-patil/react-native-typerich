package com.typerich.spans.interfaces

import android.text.Editable

interface ITypeRichSpanRule {
  /** Regex that detects this styling */
  val regex: Regex

  /** Apply span for ONE match */
  fun apply(editable: Editable, match: MatchResult)

  /** Marker type for cleanup */
  val spanClass: Class<*>
}
