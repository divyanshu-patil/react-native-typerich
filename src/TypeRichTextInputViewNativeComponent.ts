import type {
  DirectEventHandler,
  Float,
  Int32,
} from 'react-native/Libraries/Types/CodegenTypes';
import {} from 'react-native';
import { codegenNativeCommands, codegenNativeComponent } from 'react-native';

import type { ColorValue, HostComponent, ViewProps } from 'react-native';
import React from 'react';

export interface OnChangeTextEvent {
  value: string;
}

export interface OnChangeSelectionEvent {
  start: Int32;
  end: Int32;
  text: string;
}

export interface NativeProps extends ViewProps {
  // base props
  autoFocus?: boolean;
  editable?: boolean;
  defaultValue?: string;
  placeholder?: string;
  placeholderTextColor?: ColorValue;
  cursorColor?: ColorValue;
  selectionColor?: ColorValue;
  autoCapitalize?: string;
  scrollEnabled?: boolean;

  // event callbacks
  onInputFocus?: DirectEventHandler<null>;
  onInputBlur?: DirectEventHandler<null>;
  onChangeText?: DirectEventHandler<OnChangeTextEvent>;
  onChangeSelection?: DirectEventHandler<OnChangeSelectionEvent>;

  // Style related props - used for generating proper setters in component's manager
  // These should not be passed as regular props
  color?: ColorValue;
  fontSize?: Float;
  fontFamily?: string;
  fontWeight?: string;
  fontStyle?: string;

  // Experimental
  androidExperimentalSynchronousEvents: boolean;
}

type ComponentType = HostComponent<NativeProps>;

interface NativeCommands {
  // General commands
  focus: (viewRef: React.ElementRef<ComponentType>) => void;
  blur: (viewRef: React.ElementRef<ComponentType>) => void;
  setValue: (viewRef: React.ElementRef<ComponentType>, text: string) => void;
}

export const Commands: NativeCommands = codegenNativeCommands<NativeCommands>({
  supportedCommands: [
    // General commands
    'focus',
    'blur',
    'setValue',
  ],
});

export default codegenNativeComponent<NativeProps>('TypeRichTextInputView', {
  interfaceOnly: true,
}) as HostComponent<NativeProps>;
