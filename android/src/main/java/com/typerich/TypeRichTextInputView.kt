package com.typerich

import android.content.Context
import android.content.ClipboardManager
import android.net.Uri
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
import android.view.inputmethod.EditorInfo
import android.view.inputmethod.InputConnection
import android.view.inputmethod.InputMethodManager
import androidx.appcompat.widget.AppCompatEditText
import androidx.core.view.inputmethod.EditorInfoCompat
import androidx.core.view.inputmethod.InputConnectionCompat
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
import com.typerich.events.OnChangeSelectionEvent
import com.typerich.events.OnPasteImageEvent
import com.typerich.utils.EnumPasteSource
import java.io.File
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
  private var keyboardAppearance: String = "default"
  private var inputMethodManager: InputMethodManager? = null
  private var lineHeightPx: Int? = null

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
    isSingleLine = true
    isHorizontalScrollBarEnabled = false
    isVerticalScrollBarEnabled = true
    gravity = Gravity.TOP or Gravity.START
    inputType = InputType.TYPE_CLASS_TEXT

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

  // https://developer.android.com/develop/ui/views/touch-and-input/image-keyboard
  // for gboard stickers and images
  override fun onCreateInputConnection(outAttrs: EditorInfo): InputConnection? {
    val ic = super.onCreateInputConnection(outAttrs) ?: return null

    EditorInfoCompat.setContentMimeTypes(
      outAttrs,
      arrayOf("image/png", "image/jpg", "image/jpeg", "image/gif", "image/webp")
    )

    return InputConnectionCompat.createWrapper(ic, outAttrs, onCommitContent)
  }

  private val onCommitContent = InputConnectionCompat.OnCommitContentListener { info, flags, _ ->
    try {
      // request permission if needed
      if ((flags and InputConnectionCompat.INPUT_CONTENT_GRANT_READ_URI_PERMISSION) != 0) {
        try {
          info.requestPermission()
        } catch (ex: Exception) {
          // permission failed
        }
      }

      val uri = info.contentUri

      // SAFE mime extraction: check mimeTypeCount; fallback if none
      val mime = try {
        val desc = info.description
        if (desc != null && desc.mimeTypeCount > 0) {
          desc.getMimeType(0) ?: "image/*"
        } else {
          "image/*"
        }
      } catch (ex: Exception) {
        "image/*"
      }

      val source = EnumPasteSource.KEYBOARD.value

      val meta = buildMetaForUri(uri, mime, source)
      dispatchImagePasteEvent(meta)

      if ((flags and InputConnectionCompat.INPUT_CONTENT_GRANT_READ_URI_PERMISSION) != 0) {
        try { info.releasePermission() } catch (_: Exception) {}
      }

      true
    } catch (e: Exception) {
      e.printStackTrace()
      false
    }
  }

  // paste handler
  override fun onTextContextMenuItem(id: Int): Boolean {
    if (id == android.R.id.paste || id == android.R.id.pasteAsPlainText) {
      val clipboard = context.getSystemService(Context.CLIPBOARD_SERVICE) as? ClipboardManager
        ?: return super.onTextContextMenuItem(id)

      val clip = clipboard.primaryClip ?: return super.onTextContextMenuItem(id)
      val item = clip.getItemAt(0)

      // uri
      item.uri?.let { uri ->
        val source = EnumPasteSource.CLIPBOARD.value
        val mime = context.contentResolver.getType(uri) ?: "image/*"
        dispatchImagePasteEvent(buildMetaForUri(uri, mime, source))
        return true
      }

      // intent
      item.intent?.data?.let { uri ->
        val source = EnumPasteSource.CLIPBOARD.value
        val mime = context.contentResolver.getType(uri) ?: "image/*"
        dispatchImagePasteEvent(buildMetaForUri(uri, mime, source))
        return true
      }

      // text
      val text = item.coerceToText(context).toString()
      this.append(text)
      return true
    }

    return super.onTextContextMenuItem(id)
  }

  // --- helper: convert content URI to cached file metadata ---
  private data class PasteImageMeta(val fileName: String, val fileSize: Long,val source: String, val type: String, val uri: String)

  private fun buildMetaForUri(srcUri: Uri, mime: String,source: String): PasteImageMeta {
    val ext = when (mime) {
      "image/png" -> ".png"
      "image/jpeg", "image/jpg" -> ".jpg"
      "image/webp" -> ".webp"
      "image/gif" -> ".gif"
      else -> ".bin"
    }

    val temp = File(context.cacheDir, "typerich_${System.nanoTime()}$ext")
    context.contentResolver.openInputStream(srcUri)?.use { input ->
      temp.outputStream().use { out -> input.copyTo(out) }
    }

    return PasteImageMeta(
      fileName = temp.name,
      fileSize = temp.length(),
      type = mime,
      uri = Uri.fromFile(temp).toString(),
      source = source
    )
  }

  private fun dispatchImagePasteEvent(meta: PasteImageMeta) {
    val reactContext = context as ReactContext
    val dispatcher = UIManagerHelper.getEventDispatcherForReactTag(reactContext, id)
    val surfaceId = UIManagerHelper.getSurfaceId(reactContext)
    try {
      dispatcher?.dispatchEvent(
        OnPasteImageEvent(surfaceId, id, meta.uri,meta.type,meta.fileName,meta.fileSize.toDouble(),meta.source,null,experimentalSynchronousEvents)
      )
    } catch (e: Exception) {
      e.printStackTrace()
    }
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

    val reactContext = context as? ReactContext ?: return
    val dispatcher = UIManagerHelper.getEventDispatcherForReactTag(reactContext, id)
      ?: return

    val surfaceId = UIManagerHelper.getSurfaceId(reactContext)

    dispatcher.dispatchEvent(
      OnChangeSelectionEvent(
        surfaceId,
        id,
        selStart,
        selEnd,
        text?.toString() ?: "",
        experimentalSynchronousEvents
      )
    )
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
    isSingleLine = !enabled
    if (enabled) {
      inputType = inputType or InputType.TYPE_TEXT_FLAG_MULTI_LINE
    } else {
      inputType = inputType and InputType.TYPE_TEXT_FLAG_MULTI_LINE.inv()
    }
  }
  fun setNumberOfLines(lines: Int) {
    maxLines = lines
    minLines = 1

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

  fun setSecureTextEntry(isSecure: Boolean) {
    transformationMethod =
      if (isSecure)
        android.text.method.PasswordTransformationMethod.getInstance()
      else
        null

    // Prevent text from showing in suggestions/autofill if secure
    isLongClickable = !isSecure
    setTextIsSelectable(!isSecure)
  }

  fun setLineHeightReact(lineHeight: Float) {
    if (lineHeight <= 0f) return

    // RN sends lineHeight in DIP
    val px = ceil(PixelUtil.toPixelFromDIP(lineHeight)).toInt()
    lineHeightPx = px
    applyLineHeight()
  }

  private fun applyLineHeight() {
    val lh = lineHeightPx ?: return

    val fontMetrics = paint.fontMetricsInt
    val fontHeight = fontMetrics.descent - fontMetrics.ascent

    val extra = lh - fontHeight
    if (extra > 0) {
      // same logic as ReactTextView
      setLineSpacing(extra.toFloat(), 1f)
    }
  }

  override fun isLayoutRequested(): Boolean {
    return false
  }

  fun afterUpdateTransaction() {
    updateTypeface()
    updateDefaultValue()
    applyLineHeight()
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
