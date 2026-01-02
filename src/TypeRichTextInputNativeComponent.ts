import { codegenNativeComponent, codegenNativeCommands } from 'react-native';
import type { HostComponent } from 'react-native';
import type { ColorValue, ViewProps } from 'react-native';
import type {
  BubblingEventHandler,
  WithDefault,
  DirectEventHandler,
  Float,
  Double,
  Int32,
} from 'react-native/Libraries/Types/CodegenTypes';

type ComponentType = HostComponent<TypeRichTextInputNativeProps>;

interface NativeCommands {
  // General commands
  focus: (viewRef: React.ElementRef<ComponentType>) => void;
  blur: (viewRef: React.ElementRef<ComponentType>) => void;
  setText: (viewRef: React.ElementRef<ComponentType>, text: string) => void;
  insertTextAt: (
    viewRef: React.ElementRef<ComponentType>,
    start: Int32,
    end: Int32,
    text: string
  ) => void;
  setSelection: (
    viewRef: React.ElementRef<ComponentType>,
    start: Int32,
    end: Int32
  ) => void;
}

export const Commands: NativeCommands = codegenNativeCommands<NativeCommands>({
  supportedCommands: [
    // General commands
    'focus',
    'blur',
    'setText',
    'setSelection',
    'insertTextAt',
  ],
});

export default codegenNativeComponent<TypeRichTextInputNativeProps>(
  'TypeRichTextInputView',
  {
    interfaceOnly: true,
  }
) as HostComponent<TypeRichTextInputNativeProps>;

// types ---------------------------------------------------
/**
 * Payload for the `onChangeText` event.
 *
 * Emitted whenever the text content of the input changes.
 */
export interface OnChangeTextEvent {
  /**
   * The current text value of the input.
   */
  value: string;
}

/**
 * Payload for the `onChangeSelection` event.
 *
 * Emitted when the text selection or cursor position changes.
 */
export interface OnChangeSelectionEvent {
  /**
   * Start index of the selection (inclusive).
   */
  start: Int32;

  /**
   * End index of the selection (exclusive).
   */
  end: Int32;

  /**
   * Full text content at the time of the selection change.
   */
  text: string;
}

/**
 * Payload for the `onPasteImage` event.
 *
 * Emitted when an image is pasted into the input from the clipboard,
 * keyboard, or context menu.
 */
export interface onPasteImageEventData {
  /**
   * Local URI of the pasted image.
   */
  uri: string;

  /**
   * MIME type of the image (e.g. `image/png`, `image/jpeg`).
   */
  type: string;

  /**
   * Original file name of the image, if available.
   */
  fileName: string;

  /**
   * File size of the image in bytes.
   */
  fileSize: Double;

  /**
   * Source from which the image was pasted.
   *
   * - `keyboard` — Inserted via keyboard image/GIF picker
   * - `clipboard` — Pasted directly from the system clipboard and context menu
   * - `context_menu` — Pasted via long-press context menu
   *
   * ⚠️ **Deprecation notice**
   * The `context_menu` source is **temporary** and will be
   * removed in a future release due to platform limitations
   */
  source: 'keyboard' | 'clipboard' | 'context_menu';

  /**
   * Optional error information if the image could not be processed.
   */
  error?: {
    /**
     * Human-readable error message.
     */
    message: string;
  };
}

export interface TypeRichTextInputNativeProps extends ViewProps {
  // base props ---------------------------------------------------------------
  /**
   * @deprecated
   * ⚠️ Do NOT use this for controlled input.
   *
   * This prop is **not reactive** after mount.
   * Use the `setText()` command instead.
   */
  value?: string;

  /**
   * Automatically focuses the input when it mounts.
   */
  autoFocus?: boolean;

  /**
   * Controls whether the input is editable.
   *
   * When set to `false`, the input becomes read-only and cannot be focused.
   */
  editable?: boolean;

  /**
   * Initial text value applied on mount.
   *
   * Unlike `value`, this is safe to use and does not imply controlled behavior.
   */
  defaultValue?: string;

  /**
   * Placeholder text displayed when the input is empty.
   */
  placeholder?: string;

  /**
   * Color of the placeholder text.
   */
  placeholderTextColor?: ColorValue;

  /**
   * Color of the text cursor (caret).
   * on iOS cursor color will be same as selection color
   */
  cursorColor?: ColorValue;

  /**
   * Color of the text selection highlight.
   */
  selectionColor?: ColorValue;

  /**
   * Controls automatic capitalization behavior.
   *
   * values: `"none"`, `"sentences"`, `"words"`, `"characters"`.
   */
  autoCapitalize?: string;

  /**
   * Enables or disables vertical scrolling.
   *
   * When disabled, the input will expand to fit its content.
   */
  scrollEnabled?: boolean;

  /**
   * Enables multiline text input.
   *
   * When `true`, the input can span multiple lines.
   */
  multiline?: boolean;

  /**
   * ⚠️ **Use with caution**
   *
   * Limits the number of visible text lines.
   *
   * In complex or rich-text scenarios, `numberOfLines` may cause
   * unexpected layout or scrolling issues—especially on iOS.
   *
   * **Recommended approach:**
   * - Set `multiline={true}`
   * - Control height using `maxHeight` instead
   */
  numberOfLines?: Int32;

  /**
   * **Android only**
   *
   * Enables secure text entry (password mode).
   * Characters are obscured as the user types.
   */
  secureTextEntry?: boolean; // Android only

  /**
   * **iOS only**
   *
   * Controls the keyboard appearance.
   *
   * - `default` — System default appearance
   * - `light` — Light keyboard
   * - `dark` — Dark keyboard
   */
  keyboardAppearance?: WithDefault<'default' | 'light' | 'dark', 'default'>; // ios only

  /**
   * Disables pasting images from the clipboard.
   *
   * - **iOS:** The “Paste” option is removed from the context menu
   *   when the clipboard contains only images.
   * - **Android:** Stickers and GIF inputs are disabled, but the
   *   paste option may still appear due to platform limitations.
   */
  disableImagePasting?: boolean;

  // event callbacks ---------------------------------------------------------------
  /**
   * Called when the input receives focus.
   */
  onInputFocus?: DirectEventHandler<null>;

  /**
   * Called when the input loses focus.
   */
  onInputBlur?: DirectEventHandler<null>;

  /**
   * Called whenever the text content changes.
   */
  onChangeText?: DirectEventHandler<OnChangeTextEvent>;

  /**
   * Called when the text selection changes.
   */
  onChangeSelection?: DirectEventHandler<OnChangeSelectionEvent>;

  /**
   * Called when an image is pasted from the clipboard.
   * Emits {@link onPasteImageEventData}.
   */
  onPasteImage?: BubblingEventHandler<onPasteImageEventData>;

  // Style related props - used for generating proper setters in component's manager
  // These should not be passed as regular props

  /**
   * Text color.
   */
  color?: ColorValue;

  /**
   * Font size of the text.
   */
  fontSize?: Float;

  /**
   * Font family name.
   */
  fontFamily?: string;

  /**
   * Font weight.
   *
   * Example values: `"normal"`, `"bold"`, `"100"`–`"900"`.
   */
  fontWeight?: string;

  /**
   * Font style.
   *
   * Example values: `"normal"`, `"italic"`.
   */
  fontStyle?: string;

  /**
   * Line height of the text.
   */
  lineHeight?: Float;

  /**
   * ⚠️ **Use with caution**
   * Enabling this prop fixes input flickering while auto growing.
   * However, it's still experimental and not tested well.
   * it's causing some strange issues.
   * See: https://github.com/software-mansion/react-native-enriched/issues/229
   * const ANDROID_EXPERIMENTAL_SYNCHRONOUS_EVENTS = false;
   */
  androidExperimentalSynchronousEvents?: boolean;
}
