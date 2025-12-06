import type { ColorValue } from 'react-native';
import {
  codegenNativeComponent,
  codegenNativeCommands,
  type ViewProps,
} from 'react-native';
import type { HostComponent } from 'react-native';
import type {
  DirectEventHandler,
  Float,
  Int32,
} from 'react-native/Libraries/Types/CodegenTypesNamespace';

export interface OnChangeTextEvent {
  value: string;
}

export interface OnChangeSelectionEvent {
  start: Int32;
  end: Int32;
  text: string;
}

export interface TypeRichTextInputNativeProps extends ViewProps {
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
  multiline?: boolean;
  numberOfLines?: Int32;

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

  // other
  androidExperimentalSynchronousEvents?: boolean;
}

type ComponentType = HostComponent<TypeRichTextInputNativeProps>;

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

export default codegenNativeComponent<TypeRichTextInputNativeProps>(
  'TypeRichTextInputView',
  {
    interfaceOnly: true,
  }
) as HostComponent<TypeRichTextInputNativeProps>;
