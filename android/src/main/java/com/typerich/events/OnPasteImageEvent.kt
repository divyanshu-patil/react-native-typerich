package com.typerich.events

import com.facebook.react.bridge.Arguments
import com.facebook.react.bridge.WritableMap
import com.facebook.react.uimanager.events.Event

class OnPasteImageEvent(
  surfaceId: Int,
  viewId: Int,
  private val uri: String,
  private val type: String,
  private val fileName: String,
  private val fileSize: Double,  // RN Int32 maps to Kotlin Int
  private val errorMessage: String? = null,
  private val experimentalSynchronousEvents: Boolean
) : Event<OnPasteImageEvent>(surfaceId, viewId) {

  override fun getEventName() = EVENT_NAME
  override fun canCoalesce() = false

  override fun getEventData(): WritableMap {
    val map = Arguments.createMap()

    map.putString("uri", uri)
    map.putString("type", type)
    map.putString("fileName", fileName)
    map.putDouble("fileSize", fileSize)

    if (errorMessage != null) {
      val errorMap = Arguments.createMap()
      errorMap.putString("message", errorMessage)
      map.putMap("error", errorMap)
    }

    return map
  }

  override fun experimental_isSynchronous(): Boolean {
    return experimentalSynchronousEvents
  }

  companion object {
    const val EVENT_NAME = "onPasteImage"
  }
}
