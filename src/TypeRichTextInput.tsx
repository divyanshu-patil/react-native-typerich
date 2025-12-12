import { forwardRef, useImperativeHandle, useRef, type Ref } from 'react';

import type { NativeSyntheticEvent } from 'react-native';

import NativeTypeRichTextInput, {
  Commands,
  type OnChangeSelectionEvent,
  type OnChangeTextEvent,
  type onPasteImageEventData,
  type TypeRichTextInputNativeProps,
} from './TypeRichTextInputNativeComponent';

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
  setValue: (text: string) => void;
}

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
      setValue: (text: string) => {
        if (nativeRef.current) {
          Commands.setValue(nativeRef.current, text);
        }
      },
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
        androidExperimentalSynchronousEvents={
          props.androidExperimentalSynchronousEvents
        }
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
