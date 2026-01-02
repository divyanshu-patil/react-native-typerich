import type { TypeRichTextInputNativeProps } from '../TypeRichTextInputNativeComponent';
import type { onPasteImageEventData } from '../TypeRichTextInputNativeComponent';

// normalised events
/**
 * JavaScript-level props for `TypeRichTextInput`.
 *
 * These props normalize native events into ergonomic,
 * idiomatic JavaScript callbacks.
 */
export interface TypeRichTextInputProps
  extends Omit<
    TypeRichTextInputNativeProps,
    | 'onChangeText'
    | 'onChangeSelection'
    | 'onInputFocus'
    | 'onInputBlur'
    | 'onPasteImage'
  > {
  /**
   * Called when the input receives focus.
   */
  onFocus?: () => void;

  /**
   * Called when the input loses focus.
   */
  onBlur?: () => void;

  /**
   * Called whenever the text content changes.
   *
   * This callback is **informational only** and should not
   * be used to drive controlled input behavior.
   *
   * Use imperative commands (`setText`, `insertTextAt`)
   * to update the text.
   */
  onChangeText?: (value: string) => void;

  /**
   * Called when the text selection or cursor position changes.
   */
  onChangeSelection?: (event: {
    /**
     * Start index of the selection (inclusive).
     */
    start: number;

    /**
     * End index of the selection (exclusive).
     */
    end: number;

    /**
     * Full text content at the time of the selection change.
     */
    text: string;
  }) => void;

  /**
   * Called when an image is pasted into the input.
   *
   * The payload conforms to {@link onPasteImageEventData}.
   */
  onPasteImageData?: (data: onPasteImageEventData) => void;
}

/**
 * Imperative handle exposed via `ref`.
 *
 * This component is **imperative-first**.
 * Text mutations must be performed using these methods.
 */
export interface TypeRichTextInputRef {
  /**
   * Focuses the input programmatically.
   */
  focus: () => void;

  /**
   * Removes focus from the input.
   */
  blur: () => void;

  /**
   * Replaces the entire text content of the input.
   *
   * This is the primary and recommended way to update text.
   * does not updates selection
   */
  setText: (text: string) => void;

  /**
   * Inserts text at the specified range.
   *
   * Replaces the text between `start` and `end` with `text`.
   *
   * it updates selection automatically
   */
  insertTextAt: (start: number, end: number, text: string) => void;

  /**
   * Updates the current text selection.
   *
   * must be called after setText()
   */
  setSelection: (start: number, end: number) => void;

  /**
   * Returns the underlying native view reference, if available.
   *
   * Intended for advanced or debugging use cases only.
   */
  getNativeRef: () => any | null;
}
