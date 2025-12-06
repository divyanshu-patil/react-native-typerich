import { forwardRef, useImperativeHandle, useRef, type Ref } from 'react';

import type { ColorValue, ViewProps } from 'react-native';

import NativeTypeRichTextInput, {
  Commands,
} from './TypeRichTextInputViewNativeComponent';

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

  // JS friendly event callbacks
  onFocus?: () => void;
  onBlur?: () => void;
  onChangeText?: (value: string) => void;
  onChangeSelection?: (start: number, end: number, text: string) => void;

  // style props
  color?: ColorValue;
  fontSize?: number;
  fontFamily?: string;
  fontWeight?: string;
  fontStyle?: string;

  // other
  androidExperimentalSynchronousEvents?: boolean;
}

// Imperative API exposed to parent components
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

    return (
      <NativeTypeRichTextInput
        androidExperimentalSynchronousEvents={
          props.androidExperimentalSynchronousEvents
        }
        ref={nativeRef}
        {...props}
        // EVENT MAPPING → normalize nativeEvent
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
      />
    );
  }
);

export default TypeRichTextInput;
