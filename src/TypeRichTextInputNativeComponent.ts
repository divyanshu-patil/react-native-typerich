import type { ColorValue } from 'react-native';
import {
  codegenNativeComponent,
  codegenNativeCommands,
  type ViewProps,
} from 'react-native';
import type { HostComponent } from 'react-native';
import type {
  BubblingEventHandler,
  Double,
  WithDefault,
  DirectEventHandler,
  Float,
  Int32,
} from 'react-native/Libraries/Types/CodegenTypes';

export interface OnChangeTextEvent {
  value: string;
}

export interface OnChangeSelectionEvent {
  start: Int32;
  end: Int32;
  text: string;
}
export interface onPasteImageEventData {
  uri: string;
  type: string;
  fileName: string;
  fileSize: Double;
  source: 'keyboard' | 'clipboard' | 'context_menu';
  error?: { message: string };
}

export interface TypeRichTextInputNativeProps extends ViewProps {
  // base props
  value?: string;
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
  secureTextEntry?: boolean;
  keyboardAppearance?: WithDefault<'default' | 'light' | 'dark', 'default'>; // ios only

  // Todo
  // disableImagePasting?: boolean

  // event callbacks
  onInputFocus?: DirectEventHandler<null>;
  onInputBlur?: DirectEventHandler<null>;
  onChangeText?: DirectEventHandler<OnChangeTextEvent>;
  onChangeSelection?: DirectEventHandler<OnChangeSelectionEvent>;
  onPasteImage?: BubblingEventHandler<onPasteImageEventData>;

  // Style related props - used for generating proper setters in component's manager
  // These should not be passed as regular props
  color?: ColorValue;
  fontSize?: Float;
  fontFamily?: string;
  fontWeight?: string;
  fontStyle?: string;
  lineHeight?: Float;

  // other
  androidExperimentalSynchronousEvents?: boolean;
}

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
