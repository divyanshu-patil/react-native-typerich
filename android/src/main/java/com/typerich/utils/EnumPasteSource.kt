package com.typerich.utils

enum class EnumPasteSource(val value: String) {
  KEYBOARD("keyboard"),
  CLIPBOARD("clipboard"),
  CONTEXT_MENU("context_menu");

  companion object {
    fun from(value: String): EnumPasteSource? =
      values().find { it.value == value }
  }
}
