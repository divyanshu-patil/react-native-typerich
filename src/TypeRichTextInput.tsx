import { forwardRef, useImperativeHandle, useRef, type Ref } from 'react';

import type { ColorValue, ViewProps, NativeSyntheticEvent } from 'react-native';

import NativeTypeRichTextInput, {
  Commands,
  type onPasteImageEventData,
} from './TypeRichTextInputNativeComponent';

// Public facing props (same as NativeProps but events normalized)
export interface TypeRichTextInputProps extends ViewProps {
  autoFocus?: boolean;
  editable?: boolean;
  defaultValue?: string;
  placeholder?: string;
  placeholderTextColor?: ColorValue;
  cursorColor?: ColorValue;
  selectionColor?: ColorValue;
  autoCapitalize?: string;
  scrollEnabled?: boolean;
  multiline?: boolean;
  numberOfLines?: number;
  secureTextEntry?: boolean;

  // JS friendly event callbacks
  onFocus?: () => void;
  onBlur?: () => void;
  onChangeText?: (value: string) => void;
  onChangeSelection?: (start: number, end: number, text: string) => void;
  onPasteImageData?: (data: onPasteImageEventData) => void;

  // style props
  color?: ColorValue;
  fontSize?: number;
  fontFamily?: string;
  fontWeight?: string;
  fontStyle?: string;

  // other
  androidExperimentalSynchronousEvents?: boolean;
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

    return (
      <NativeTypeRichTextInput
        androidExperimentalSynchronousEvents={
          props.androidExperimentalSynchronousEvents
        }
        ref={nativeRef}
        {...props}
        onInputFocus={() => props.onFocus?.()}
        onInputBlur={() => props.onBlur?.()}
        onChangeText={(event) => props.onChangeText?.(event.nativeEvent.value)}
        onChangeSelection={(event) =>
          props.onChangeSelection?.(
            event.nativeEvent.start,
            event.nativeEvent.end,
            event.nativeEvent.text
          )
        }
        onPasteImage={handlePasteImage}
      />
    );
  }
);

export default TypeRichTextInput;
