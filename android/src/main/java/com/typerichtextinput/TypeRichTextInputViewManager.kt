package com.typerichtextinput

import android.graphics.Color
import com.facebook.react.module.annotations.ReactModule
import com.facebook.react.uimanager.SimpleViewManager
import com.facebook.react.uimanager.ThemedReactContext
import com.facebook.react.uimanager.ViewManagerDelegate
import com.facebook.react.uimanager.annotations.ReactProp
import com.facebook.react.viewmanagers.TypeRichTextInputViewManagerInterface
import com.facebook.react.viewmanagers.TypeRichTextInputViewManagerDelegate

@ReactModule(name = TypeRichTextInputViewManager.NAME)
class TypeRichTextInputViewManager : SimpleViewManager<TypeRichTextInputView>(),
  TypeRichTextInputViewManagerInterface<TypeRichTextInputView> {
  private val mDelegate: ViewManagerDelegate<TypeRichTextInputView>

  init {
    mDelegate = TypeRichTextInputViewManagerDelegate(this)
  }

  override fun getDelegate(): ViewManagerDelegate<TypeRichTextInputView>? {
    return mDelegate
  }

  override fun getName(): String {
    return NAME
  }

  public override fun createViewInstance(context: ThemedReactContext): TypeRichTextInputView {
    return TypeRichTextInputView(context)
  }

  @ReactProp(name = "color")
  override fun setColor(view: TypeRichTextInputView?, color: String?) {
    view?.setBackgroundColor(Color.parseColor(color))
  }

  companion object {
    const val NAME = "TypeRichTextInputView"
  }
}
