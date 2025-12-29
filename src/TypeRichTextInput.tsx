import { forwardRef, useImperativeHandle, useRef, type Ref } from 'react';

import type { NativeSyntheticEvent } from 'react-native';

import NativeTypeRichTextInput, {
  Commands,
  type OnChangeSelectionEvent,
  type OnChangeTextEvent,
  type onPasteImageEventData,
  type TypeRichTextInputNativeProps,
} from './TypeRichTextInputNativeComponent';

// let NativeTypeRichTextInput: any;

// if (Platform.OS === 'android') {
//   NativeTypeRichTextInput =
//     require('./TypeRichTextInputNativeComponent').default;
// } else {
//   // iOS fallback (temporary)
//   NativeTypeRichTextInput = View;
// }
type MaybeNativeEvent<T> = T | { nativeEvent: T };

export function normalizeEvent<T>(event: MaybeNativeEvent<T>): T {
  if (event && typeof event === 'object' && 'nativeEvent' in event) {
    return (event as { nativeEvent: T }).nativeEvent;
  }
  return event as T;
}

// Public facing props (same as NativeProps but events normalized)
export interface TypeRichTextInputProps
  extends Omit<
    TypeRichTextInputNativeProps,
    | 'onChangeText'
    | 'onChangeSelection'
    | 'onInputFocus'
    | 'onInputBlur'
    | 'onPasteImage'
  > {
  // JS-friendly callbacks
  onFocus?: () => void;
  onBlur?: () => void;
  onChangeText?: (value: string) => void;
  onChangeSelection?: (event: {
    start: number;
    end: number;
    text: string;
  }) => void;
  onPasteImageData?: (data: onPasteImageEventData) => void;
}

export interface TypeRichTextInputRef {
  focus: () => void;
  blur: () => void;
  setText: (text: string) => void;
  insertTextAt: (start: number, end: number, text: string) => void;
  setSelection: (start: number, end: number) => void;
  getNativeRef: () => any | null;
}

/**
 * TypeRichTextInput
 *
 * A high-performance rich text input component with:
 * - image pasting support
 * - Fabric-based rendering
 * - custom ShadowNode on Android
 *
 * iOS support is currently unavailable and renders a `View` comp as fallback
 * we are planning to add support for ios too soon
 */
const TypeRichTextInput = forwardRef(
  (props: TypeRichTextInputProps, ref: Ref<TypeRichTextInputRef>) => {
    const nativeRef = useRef(null);

    useImperativeHandle(ref, () => ({
      focus: () => {
        if (nativeRef.current) {
          Commands.focus(nativeRef.current);
        }
      },
      blur: () => {
        if (nativeRef.current) {
          Commands.blur(nativeRef.current);
        }
      },
      setText: (text: string) => {
        if (nativeRef.current) {
          Commands.setText(nativeRef.current, text);
        }
      },
      setSelection(start, end) {
        if (nativeRef.current) {
          Commands.setSelection(nativeRef.current, start, end);
        }
      },
      insertTextAt: (start: number, end: number, text: string) => {
        if (nativeRef.current) {
          Commands.insertTextAt(nativeRef.current, start, end, text);
        }
      },
      getNativeRef: () => nativeRef.current,
    }));

    /**
     todo: make this only for NativeSyntheticEvent
     */
    function handlePasteImage(
      event:
        | onPasteImageEventData
        | { nativeEvent: onPasteImageEventData }
        | NativeSyntheticEvent<onPasteImageEventData>
        | any
    ): void {
      // always getting nativeevent but will refactor later
      const data: onPasteImageEventData | undefined =
        event && typeof event === 'object'
          ? event.nativeEvent ?? event
          : undefined;

      if (data) {
        props.onPasteImageData?.(data as onPasteImageEventData);
      }
    }

    function handleOnChangeTextEvent(
      event: OnChangeTextEvent | { nativeEvent: OnChangeTextEvent }
    ) {
      const e = normalizeEvent(event);
      props.onChangeText?.(e.value);
    }

    function handleonChangeSelectionEvent(
      event: OnChangeSelectionEvent | { nativeEvent: OnChangeSelectionEvent }
    ) {
      const e = normalizeEvent(event);
      props.onChangeSelection?.({
        start: e.start,
        end: e.end,
        text: e.text,
      });
    }

    return (
      <NativeTypeRichTextInput
        ref={nativeRef}
        {...props}
        onInputFocus={() => props.onFocus?.()}
        onInputBlur={() => props.onBlur?.()}
        onChangeText={handleOnChangeTextEvent}
        onChangeSelection={handleonChangeSelectionEvent}
        onPasteImage={handlePasteImage}
      />
    );
  }
);

export default TypeRichTextInput;
