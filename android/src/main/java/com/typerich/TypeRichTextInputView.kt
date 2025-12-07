package com.typerich

import android.content.Context
import android.graphics.BlendMode
import android.graphics.BlendModeColorFilter
import android.graphics.Color
import android.graphics.Rect
import android.graphics.text.LineBreaker
import android.os.Build
import android.text.Editable
import android.text.InputType
import android.text.TextWatcher
import android.util.AttributeSet
import android.util.TypedValue
import android.view.Gravity
import android.view.MotionEvent
import android.view.inputmethod.InputMethodManager
import androidx.appcompat.widget.AppCompatEditText
import com.facebook.react.bridge.ReactContext
import com.facebook.react.common.ReactConstants
import com.facebook.react.uimanager.PixelUtil
import com.facebook.react.uimanager.StateWrapper
import com.facebook.react.uimanager.UIManagerHelper
import com.facebook.react.views.text.ReactTypefaceUtils.applyStyles
import com.facebook.react.views.text.ReactTypefaceUtils.parseFontStyle
import com.facebook.react.views.text.ReactTypefaceUtils.parseFontWeight
import com.typerich.events.OnChangeTextEvent
import com.typerich.events.OnInputBlurEvent
import com.typerich.events.OnInputFocusEvent
import kotlin.math.ceil

class TypeRichTextInputView : AppCompatEditText {
  var stateWrapper: StateWrapper? = null

  lateinit var layoutManager: TypeRichTextInputViewLayoutManager

  var isDuringTransaction: Boolean = false
  var isRemovingMany: Boolean = false
  var scrollEnabled: Boolean = true

  var experimentalSynchronousEvents: Boolean = false

  var fontSize: Float? = null
  private var autoFocus = false
  private var typefaceDirty = false
  private var didAttachToWindow = false
  private var detectScrollMovement = false
  private var fontFamily: String? = null
  private var fontStyle: Int = ReactConstants.UNSET
  private var fontWeight: Int = ReactConstants.UNSET
  private var defaultValue: CharSequence? = null
  private var defaultValueDirty: Boolean = false

  private var inputMethodManager: InputMethodManager? = null

  constructor(context: Context) : super(context) {
    prepareComponent()
  }

  constructor(context: Context, attrs: AttributeSet) : super(context, attrs) {
    prepareComponent()
  }

  constructor(context: Context, attrs: AttributeSet, defStyleAttr: Int) : super(
    context,
    attrs,
    defStyleAttr
  ) {
    prepareComponent()
  }

  init {
    inputMethodManager = context.getSystemService(Context.INPUT_METHOD_SERVICE) as InputMethodManager
  }

  private fun prepareComponent() {
    isSingleLine = false
    isHorizontalScrollBarEnabled = false
    isVerticalScrollBarEnabled = true
    gravity = Gravity.TOP or Gravity.START
    inputType = InputType.TYPE_CLASS_TEXT or InputType.TYPE_TEXT_FLAG_MULTI_LINE

    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
      breakStrategy = LineBreaker.BREAK_STRATEGY_HIGH_QUALITY
    }

    setPadding(0, 0, 0, 0)
    setBackgroundColor(Color.TRANSPARENT)

    layoutManager = TypeRichTextInputViewLayoutManager(this)

    addTextChangedListener(object : TextWatcher {
      override fun beforeTextChanged(s: CharSequence?, start: Int, count: Int, after: Int) {}

      override fun onTextChanged(s: CharSequence?, start: Int, before: Int, count: Int) {
        if (!isDuringTransaction) {
          val reactContext = context as ReactContext
          val surfaceId = UIManagerHelper.getSurfaceId(reactContext)
          val dispatcher =
            UIManagerHelper.getEventDispatcherForReactTag(reactContext, id)

          dispatcher?.dispatchEvent(
            OnChangeTextEvent(
              surfaceId,
              id,
              s?.toString() ?: "",
              experimentalSynchronousEvents
            )
          )
        }
        layoutManager.invalidateLayout()

      }
      override fun afterTextChanged(s: Editable?) {}
    })
  }

  override fun onTouchEvent(ev: MotionEvent): Boolean {
    when (ev.action) {
      MotionEvent.ACTION_DOWN -> {
        detectScrollMovement = true
        parent.requestDisallowInterceptTouchEvent(true)
      }

      MotionEvent.ACTION_MOVE ->
        if (detectScrollMovement) {
          if (!canScrollVertically(-1) &&
            !canScrollVertically(1) &&
            !canScrollHorizontally(-1) &&
            !canScrollHorizontally(1)
          ) {
            parent.requestDisallowInterceptTouchEvent(false)
          }
          detectScrollMovement = false
        }
    }

    return super.onTouchEvent(ev)
  }

  override fun canScrollVertically(direction: Int): Boolean {
    return scrollEnabled
  }

  override fun canScrollHorizontally(direction: Int): Boolean {
    return scrollEnabled
  }

  override fun onSelectionChanged(selStart: Int, selEnd: Int) {
    super.onSelectionChanged(selStart, selEnd)
    // you can later dispatch OnChangeSelectionEvent here if needed
  }

  override fun clearFocus() {
    super.clearFocus()
    inputMethodManager?.hideSoftInputFromWindow(windowToken, 0)
  }

  override fun onFocusChanged(focused: Boolean, direction: Int, previouslyFocusedRect: Rect?) {
    super.onFocusChanged(focused, direction, previouslyFocusedRect)
    val reactContext = context as ReactContext
    val surfaceId = UIManagerHelper.getSurfaceId(reactContext)
    val dispatcher = UIManagerHelper.getEventDispatcherForReactTag(reactContext, id)

    if (focused) {
      dispatcher?.dispatchEvent(
        OnInputFocusEvent(
          surfaceId,
          id,
          experimentalSynchronousEvents
        )
      )
    } else {
      dispatcher?.dispatchEvent(
        OnInputBlurEvent(
          surfaceId,
          id,
          experimentalSynchronousEvents
        )
      )
    }
  }

  fun requestFocusProgrammatically() {
    requestFocus()
    inputMethodManager?.showSoftInput(this, 0)
    setSelection(text?.length ?: 0)
  }

  fun setMultiline(enabled: Boolean) {
    // enable multi-line behavior
    if(enabled){
      inputType = InputType.TYPE_CLASS_TEXT
      isSingleLine = true
      return
    }
    inputType = InputType.TYPE_TEXT_FLAG_MULTI_LINE
    isSingleLine = false
  }

  fun setNumberOfLines(lines: Int) {
    maxLines = lines
    minLines = 1

    // Optional: Ensure proper scrolling when maxLines is reached
//    if (lines > 0) {
//      setLines(lines) // Only if you want fixed height
//      isVerticalScrollBarEnabled = true
//    }
  }


  fun setValue(value: CharSequence?) {
    if (value == null) return

    runAsATransaction {
      setText(value.toString())
      setSelection(text?.length ?: 0)
    }
  }

  fun setAutoFocus(autoFocus: Boolean) {
    this.autoFocus = autoFocus
  }

  fun setPlaceholder(placeholder: String?) {
    if (placeholder == null) return
    hint = placeholder
  }

  fun setPlaceholderTextColor(colorInt: Int?) {
    if (colorInt == null) return
    setHintTextColor(colorInt)
  }

  fun setSelectionColor(colorInt: Int?) {
    if (colorInt == null) return
    highlightColor = colorInt
  }

  fun setCursorColor(colorInt: Int?) {
    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
      val cursorDrawable = textCursorDrawable ?: return

      if (colorInt != null) {
        cursorDrawable.colorFilter =
          BlendModeColorFilter(colorInt, BlendMode.SRC_IN)
      } else {
        cursorDrawable.clearColorFilter()
      }

      textCursorDrawable = cursorDrawable
    }
  }

  fun setColor(colorInt: Int?) {
    if (colorInt == null) {
      setTextColor(Color.BLACK)
      return
    }
    setTextColor(colorInt)
  }

  fun setFontSize(size: Float) {
    if (size == 0f) return

    val sizePx = ceil(PixelUtil.toPixelFromSP(size))
    fontSize = sizePx
    setTextSize(TypedValue.COMPLEX_UNIT_PX, sizePx)
  }

  fun setFontFamily(family: String?) {
    if (family != fontFamily) {
      fontFamily = family
      typefaceDirty = true
    }
  }

  fun setFontWeight(weight: String?) {
    val fontWeight = parseFontWeight(weight)
    if (fontWeight != fontStyle) {
      this.fontWeight = fontWeight
      typefaceDirty = true
    }
  }

  fun setFontStyle(style: String?) {
    val fontStyle = parseFontStyle(style)
    if (fontStyle != this.fontStyle) {
      this.fontStyle = fontStyle
      typefaceDirty = true
    }
  }

  fun setAutoCapitalize(flagName: String?) {
    val flag = when (flagName) {
      "none" -> InputType.TYPE_NULL
      "sentences" -> InputType.TYPE_TEXT_FLAG_CAP_SENTENCES
      "words" -> InputType.TYPE_TEXT_FLAG_CAP_WORDS
      "characters" -> InputType.TYPE_TEXT_FLAG_CAP_CHARACTERS
      else -> InputType.TYPE_NULL
    }

    inputType =
      (inputType and
        InputType.TYPE_TEXT_FLAG_CAP_CHARACTERS.inv() and
        InputType.TYPE_TEXT_FLAG_CAP_WORDS.inv() and
        InputType.TYPE_TEXT_FLAG_CAP_SENTENCES.inv()
        ) or if (flag == InputType.TYPE_NULL) 0 else flag
  }

  override fun isLayoutRequested(): Boolean {
    return false
  }

  fun afterUpdateTransaction() {
    updateTypeface()
    updateDefaultValue()
  }

  fun setDefaultValue(value: CharSequence?) {
    defaultValue = value
    defaultValueDirty = true
  }

  private fun updateDefaultValue() {
    if (!defaultValueDirty) return
    defaultValueDirty = false
   setText(defaultValue?.toString() ?: "")
  }

  private fun updateTypeface() {
    if (!typefaceDirty) return
    typefaceDirty = false

    val newTypeface =
      applyStyles(typeface, fontStyle, fontWeight, fontFamily, context.assets)
    typeface = newTypeface
    paint.typeface = newTypeface
  }

  fun runAsATransaction(block: () -> Unit) {
    try {
      isDuringTransaction = true
      block()
    } finally {
      isDuringTransaction = false
    }
  }

  override fun onAttachedToWindow() {
    super.onAttachedToWindow()

    if (autoFocus && !didAttachToWindow) {
      requestFocusProgrammatically()
    }

    didAttachToWindow = true
  }

  companion object {
    const val CLIPBOARD_TAG = "react-native-typerich-clipboard"
  }
}
