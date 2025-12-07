package com.typerich

import android.content.Context
import com.facebook.react.bridge.ReadableMap
import com.facebook.react.module.annotations.ReactModule
import com.facebook.react.uimanager.*
import com.facebook.react.uimanager.annotations.ReactProp
import com.facebook.react.viewmanagers.TypeRichTextInputViewManagerDelegate
import com.facebook.react.viewmanagers.TypeRichTextInputViewManagerInterface
import com.facebook.yoga.YogaMeasureMode
import com.typerich.events.OnInputBlurEvent
import com.typerich.events.OnInputFocusEvent
import com.typerich.events.OnChangeSelectionEvent
import com.typerich.events.OnChangeTextEvent

@ReactModule(name = TypeRichTextInputViewManager.NAME)
class TypeRichTextInputViewManager :
  SimpleViewManager<TypeRichTextInputView>(),
  TypeRichTextInputViewManagerInterface<TypeRichTextInputView> {

  private val mDelegate: ViewManagerDelegate<TypeRichTextInputView> =
    TypeRichTextInputViewManagerDelegate(this)

  override fun getDelegate(): ViewManagerDelegate<TypeRichTextInputView>? = mDelegate

  override fun getName(): String = NAME

  override fun createViewInstance(context: ThemedReactContext): TypeRichTextInputView {
    return TypeRichTextInputView(context)
  }

  override fun updateState(
    view: TypeRichTextInputView,
    props: ReactStylesDiffMap?,
    stateWrapper: StateWrapper?
  ): Any? {
    view.stateWrapper = stateWrapper
    return super.updateState(view, props, stateWrapper)
  }

  override fun getExportedCustomDirectEventTypeConstants(): MutableMap<String, Any> =
    mutableMapOf(
      OnInputFocusEvent.EVENT_NAME to mapOf("registrationName" to OnInputFocusEvent.EVENT_NAME),
      OnInputBlurEvent.EVENT_NAME to mapOf("registrationName" to OnInputBlurEvent.EVENT_NAME),
      OnChangeTextEvent.EVENT_NAME to mapOf("registrationName" to OnChangeTextEvent.EVENT_NAME),
      OnChangeSelectionEvent.EVENT_NAME to mapOf("registrationName" to OnChangeSelectionEvent.EVENT_NAME),
    )

  @ReactProp(name = "defaultValue")
  override fun setDefaultValue(view: TypeRichTextInputView?, value: String?) {
    view?.setDefaultValue(value)
  }

  @ReactProp(name = "color")
  override fun setColor(view: TypeRichTextInputView, value: Int?) {
    if (value != null) view.setTextColor(value)
  }

  @ReactProp(name = "placeholder")
  override fun setPlaceholder(view: TypeRichTextInputView?, value: String?) {
    view?.setPlaceholder(value)
  }

  @ReactProp(name = "placeholderTextColor", customType = "Color")
  override fun setPlaceholderTextColor(view: TypeRichTextInputView?, color: Int?) {
    view?.setPlaceholderTextColor(color)
  }

  @ReactProp(name = "cursorColor", customType = "Color")
  override fun setCursorColor(view: TypeRichTextInputView?, color: Int?) {
    view?.setCursorColor(color)
  }

  @ReactProp(name = "selectionColor", customType = "Color")
  override fun setSelectionColor(view: TypeRichTextInputView?, color: Int?) {
    view?.setSelectionColor(color)
  }

  @ReactProp(name = "autoFocus", defaultBoolean = false)
  override fun setAutoFocus(view: TypeRichTextInputView?, autoFocus: Boolean) {
    view?.setAutoFocus(autoFocus)
  }

  @ReactProp(name = "editable", defaultBoolean = true)
  override fun setEditable(view: TypeRichTextInputView?, editable: Boolean) {
    view?.isEnabled = editable
  }

  @ReactProp(name = "fontSize", defaultFloat = ViewDefaults.FONT_SIZE_SP)
  override fun setFontSize(view: TypeRichTextInputView?, size: Float) {
    view?.setFontSize(size)
  }

  @ReactProp(name = "fontFamily")
  override fun setFontFamily(view: TypeRichTextInputView?, family: String?) {
    view?.setFontFamily(family)
  }

  @ReactProp(name = "fontWeight")
  override fun setFontWeight(view: TypeRichTextInputView?, weight: String?) {
    view?.setFontWeight(weight)
  }

  @ReactProp(name = "fontStyle")
  override fun setFontStyle(view: TypeRichTextInputView?, style: String?) {
    view?.setFontStyle(style)
  }

  @ReactProp(name = "scrollEnabled")
  override fun setScrollEnabled(view: TypeRichTextInputView, scrollEnabled: Boolean) {
    view.scrollEnabled = scrollEnabled
  }

  @ReactProp(name = "multiline")
  override fun setMultiline(view: TypeRichTextInputView?, value: Boolean) {
    view?.setMultiline(value)
  }

  @ReactProp(name = "numberOfLines")
  override fun setNumberOfLines(view: TypeRichTextInputView?, lines: Int) {
    view?.setNumberOfLines(lines)
  }

  override fun onAfterUpdateTransaction(view: TypeRichTextInputView) {
    super.onAfterUpdateTransaction(view)
    view.afterUpdateTransaction()
  }

  override fun setPadding(
    view: TypeRichTextInputView?,
    left: Int,
    top: Int,
    right: Int,
    bottom: Int
  ) {
    super.setPadding(view, left, top, right, bottom)
    view?.setPadding(left, top, right, bottom)
  }

  override fun setAutoCapitalize(view: TypeRichTextInputView?, flag: String?) {
    view?.setAutoCapitalize(flag)
  }

  override fun setAndroidExperimentalSynchronousEvents(
    view: TypeRichTextInputView?,
    value: Boolean
  ) {
    view?.experimentalSynchronousEvents = value
  }

  override fun focus(view: TypeRichTextInputView?) {
    view?.requestFocusProgrammatically()
  }

  override fun blur(view: TypeRichTextInputView?) {
    view?.clearFocus()
  }

  override fun setValue(view: TypeRichTextInputView?, text: String) {
  }

  override fun measure(
    context: Context,
    localData: ReadableMap?,
    props: ReadableMap?,
    state: ReadableMap?,
    width: Float,
    widthMode: YogaMeasureMode?,
    height: Float,
    heightMode: YogaMeasureMode?,
    attachmentsPositions: FloatArray?
  ): Long {
    val id = localData?.getInt("viewTag")
    return MeasurementStore.getMeasureById(context, id, width, props)
  }

  companion object {
    const val NAME = "TypeRichTextInputView"
  }
}
