import {
  type Component,
  type RefObject,
  useImperativeHandle,
  useRef,
} from 'react';
import TypeRichTextInputNativeComponent, {
  Commands,
  type NativeProps,
  type OnChangeSelectionEvent,
  type OnChangeTextEvent,
} from './TypeRichTextInputViewNativeComponent';
import type {
  ColorValue,
  HostInstance,
  MeasureInWindowOnSuccessCallback,
  MeasureLayoutOnSuccessCallback,
  MeasureOnSuccessCallback,
  NativeMethods,
  NativeSyntheticEvent,
  TextStyle,
  ViewProps,
  ViewStyle,
} from 'react-native';

export interface TypeRichTextInputInstance extends NativeMethods {
  // General commands
  focus: () => void;
  blur: () => void;
  setValue: (value: string) => void;
}

export interface TypeRichTextInputProps extends Omit<ViewProps, 'children'> {
  ref?: RefObject<TypeRichTextInputInstance | null>;
  autoFocus?: boolean;
  editable?: boolean;
  mentionIndicators?: string[];
  defaultValue?: string;
  placeholder?: string;
  placeholderTextColor?: ColorValue;
  cursorColor?: ColorValue;
  selectionColor?: ColorValue;
  autoCapitalize?: 'none' | 'sentences' | 'words' | 'characters';
  style?: ViewStyle | TextStyle;
  scrollEnabled?: boolean;
  onFocus?: () => void;
  onBlur?: () => void;
  onChangeText?: (e: NativeSyntheticEvent<OnChangeTextEvent>) => void;
  onChangeSelection?: (e: NativeSyntheticEvent<OnChangeSelectionEvent>) => void;
  /**
   * If true, Android will use experimental synchronous events.
   * This will prevent from input flickering when updating component size.
   * However, this is an experimental feature, which has not been thoroughly tested.
   * We may decide to enable it by default in a future release.
   * Disabled by default.
   */
  androidExperimentalSynchronousEvents?: boolean;
}

const nullthrows = <T,>(value: T | null | undefined): T => {
  if (value == null) {
    throw new Error('Unexpected null or undefined value');
  }

  return value;
};

type ComponentType = (Component<NativeProps, {}, any> & NativeMethods) | null;

export const TypeRichTextInput = ({
  ref,
  autoFocus,
  editable = true,
  defaultValue,
  placeholder,
  placeholderTextColor,
  cursorColor,
  selectionColor,
  style,
  autoCapitalize = 'sentences',
  onFocus,
  onBlur,
  onChangeText,
  onChangeSelection,
  androidExperimentalSynchronousEvents = false,
  scrollEnabled = true,
  ...rest
}: TypeRichTextInputProps) => {
  const nativeRef = useRef<ComponentType | null>(null);

  useImperativeHandle(ref, () => ({
    measureInWindow: (callback: MeasureInWindowOnSuccessCallback) => {
      nullthrows(nativeRef.current).measureInWindow(callback);
    },
    measure: (callback: MeasureOnSuccessCallback) => {
      nullthrows(nativeRef.current).measure(callback);
    },
    measureLayout: (
      relativeToNativeComponentRef: HostInstance | number,
      onSuccess: MeasureLayoutOnSuccessCallback,
      onFail?: () => void
    ) => {
      nullthrows(nativeRef.current).measureLayout(
        relativeToNativeComponentRef,
        onSuccess,
        onFail
      );
    },
    setNativeProps: (nativeProps: object) => {
      nullthrows(nativeRef.current).setNativeProps(nativeProps);
    },
    focus: () => {
      Commands.focus(nullthrows(nativeRef.current));
    },
    blur: () => {
      Commands.blur(nullthrows(nativeRef.current));
    },
    setValue: (value: string) => {
      Commands.setValue(nullthrows(nativeRef.current), value);
    },
  }));

  return (
    <TypeRichTextInputNativeComponent
      ref={nativeRef}
      editable={editable}
      autoFocus={autoFocus}
      defaultValue={defaultValue}
      placeholder={placeholder}
      placeholderTextColor={placeholderTextColor}
      cursorColor={cursorColor}
      selectionColor={selectionColor}
      style={style}
      autoCapitalize={autoCapitalize}
      onInputFocus={onFocus}
      onInputBlur={onBlur}
      onChangeText={onChangeText}
      onChangeSelection={onChangeSelection}
      androidExperimentalSynchronousEvents={
        androidExperimentalSynchronousEvents
      }
      scrollEnabled={scrollEnabled}
      {...rest}
    />
  );
};
