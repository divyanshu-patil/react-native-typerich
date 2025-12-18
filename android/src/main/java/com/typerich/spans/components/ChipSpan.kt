package com.typerich.spans.components

import android.graphics.Canvas
import android.graphics.Paint
import android.graphics.RectF
import android.text.style.ReplacementSpan
import com.typerich.spans.interfaces.ITypeRichInternalSpan
import com.typerich.spans.interfaces.ITypeRichSemanticSpan

class ChipSpan(private val backgroundColor: Int,
               private val textColor: Int,
               private val cornerRadius: Float,
               private val horizontalPadding: Float,
               private val verticalPadding: Float): ReplacementSpan(), ITypeRichInternalSpan, ITypeRichSemanticSpan {
  private val rect = RectF()

  override fun getSize(
    paint: Paint,
    text: CharSequence?,
    start: Int,
    end: Int,
    fm: Paint.FontMetricsInt?
  ): Int {
    val textWidth = paint.measureText(text, start, end).toInt()
    fm?.let { block ->
      val original = paint.fontMetricsInt
      block.ascent = original.ascent
      block.descent = original.descent
      block.top = original.top
      block.bottom = original.bottom
    }

    return (textWidth + horizontalPadding * 2).toInt()
  }

  override fun draw(
    canvas: Canvas,
    text: CharSequence?,
    start: Int,
    end: Int,
    x: Float,
    top: Int,
    y: Int,
    bottom: Int,
    paint: Paint
  ) {
    val textWidth = paint.measureText(text, start, end)
    val textHeight = paint.fontMetrics.descent - paint.fontMetrics.ascent

    rect.set(
      x,
      y + paint.fontMetrics.ascent - verticalPadding,
      x + textWidth + horizontalPadding * 2,
      y + paint.fontMetrics.descent + verticalPadding
    )

    // Draw background
    val oldColor = paint.color
    paint.color = backgroundColor
    canvas.drawRoundRect(rect, cornerRadius, cornerRadius, paint)

    // Draw text
    paint.color = textColor
    if (text != null) {
      canvas.drawText(
        text,
        start,
        end,
        x + horizontalPadding,
        y.toFloat(),
        paint
      )
    }
    paint.color = oldColor
  }
}
