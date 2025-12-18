package com.typerich.spans

import android.graphics.Color
import android.text.Editable
import com.typerich.spans.components.ChipSpan
import com.typerich.spans.interfaces.ITypeRichSpanRule
import com.typerich.spans.utils.SpanUtils
import androidx.core.graphics.toColorInt
import com.typerich.spans.interfaces.ESpanPriority

class TypeRichChannelSpan: ITypeRichSpanRule {
  /*  ?= : positive lookahead
   *  match only if next character matches
   *  but do not consume the character
  */
  override val regex = Regex("""(?<!\S)#([a-zA-Z0-9_-]+)(?=\s)""")

  override val spanClass = ChipSpan::class.java
  override val priority: ESpanPriority = ESpanPriority.SEMANTIC

  val backgroundColor = "#4577f5".toColorInt()
  val textColor = Color.WHITE
  val cornerRadius: Float = 12.0f
  val horizontalPadding: Float = 8.0f
  val verticalPadding: Float = 0.0f


  override fun apply(editable: Editable, match: MatchResult) {
    val (start, end) = SpanUtils.getRange(match)
    editable.setSpan(
      ChipSpan(backgroundColor,textColor,cornerRadius,horizontalPadding,verticalPadding),
      start -1 , // include the # into the span
      end,
      Editable.SPAN_EXCLUSIVE_EXCLUSIVE
    )
  }
}
