package com.typerich

import com.facebook.react.bridge.Arguments

class TypeRichTextInputViewLayoutManager(private val view: TypeRichTextInputView) {
  private var forceHeightRecalculationCounter: Int = 0

  fun invalidateLayout() {
    val text = view.text
    val paint = view.paint

    val needUpdate = MeasurementStore.store(view.id, text, paint)
    if (!needUpdate) return

    val counter = forceHeightRecalculationCounter
    forceHeightRecalculationCounter++
    val state = Arguments.createMap()
    state.putInt("forceHeightRecalculationCounter", counter)
    view.stateWrapper?.updateState(state)
  }

  fun releaseMeasurementStore() {
    MeasurementStore.release(view.id)
  }
}
