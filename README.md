# react-native-typerich

Drop in TextInput replacement with inbuilt support for Image Pasting and Gboard stickers
currently available only for android

## Installation

```sh
npm install react-native-typerich
```

## Usage

```jsx
import { TypeRichTextInput } from 'react-native-typerich';

// ...
<TypeRichTextInput
  ref={inputRef}
  value={value}
  style={styles.typeRichTextInput}
  placeholder="Type here..."
  placeholderTextColor="rgb(0, 26, 114)"
  editable={true}
  selectionColor="deepskyblue"
  cursorColor="dodgerblue"
  autoCapitalize="words"
  autoFocus
  onChangeText={(text: string) => console.log(text)}
  onFocus={() => console.log('focused')}
  onBlur={() => console.log('blurred')}
  onChangeSelection={(e: { start: number, end: number, text: string }) =>
    console.log(e)
  }
  onPasteImageData={(e) => {
    setImage(e);
    console.log(e);
  }}
  androidExperimentalSynchronousEvents={true} // not tested very well
  multiline
  numberOfLines={5}
  lineHeight={22}
  fontFamily="serif"
  fontStyle="italic"
  fontWeight={'700'}
  fontSize={26}
  color="darkgreen"
/>;
```

## Props

- **Props that works Same as React Native's Default `TextInput`:**

```ts
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
secureTextEntry?: boolean;
```

- **Styling Props you need to pass externally:**

```ts
color?: ColorValue;
fontSize?: Float;
fontFamily?: string;
fontWeight?: string;
fontStyle?: string;
lineHeight?: Float;
```

- **props that have some bugs:**

```ts
multiline?: boolean;
numberOfLines?: Int32;
```

> using this togather adds some extra height sometimes.
> use multline without numberOfLines and it works fine
> use `maxHeight` instead of number of lines

> [!NOTE]
> This is not a Major bug and the change is unnoticable

## Events

### 1. onFocus

callback signature

```ts
onFocus?: () => void;
```

### 2. onBlur

callback signature

```ts
onBlur?: () => void;
```

### 3. onChangeText

callback signature

```ts
onChangeText?: (value: string) => void;
```

### 4. onChangeSelection

callback signature

```ts
onChangeSelection?: (event: {
  start: number;
  end: number;
  text: string;
}) => void;
```

### 4. onPasteImageData

> fires on when user paste image

callback signature

```ts
onPasteImageData?: (data: {
  uri: string;
  type: string;
  fileName: string;
  fileSize: Double;
  source: 'keyboard' | 'clipboard' | 'context_menu'; // it never receives source as 'context_menu' and will be removed in future we suggest not using it
  error?: { message: string };
}) => void;
```

### Event props

- `uri`: uri of the image, can be directly used or passed to Image comp
- `type`: mime type of image
- `fileName`: File name of image (always starts with `typerich_` prefix)
- `fileSize`: File Size in bytes
- `source`: its enum with two possible values
  - `keyboard`: if its pasted from gboard's clipboard or is a sticker or something similar
  - `clipboard`: if its pasted from context menu (long press)
- `error`: error message if there is any

## Commands

### 1. focus()

> use to get programmatic focus on TextInput

Command signature

```ts
focus: () => void;
```

useage

```ts
inputRef.current?.focus();
```

### 2. blur()

> use to programmatically blur TextInput

Command signature

```ts
blur: () => void;
```

useage

```ts
inputRef.current?.blur();
```

### 3. setText(text)

> use to set the value of TextInput (replaces whole content)

> [!NOTE]
> it does not updates selection automatically use have to call `setSelection()`

Command signature

```ts
setText: (text: string) => void;
```

useage

```ts
inputRef.current?.setText('This is Text');
```

### 4. insertTextAt(start, end, text)

> use to insert value at specific position (keeps content of TextInput)

> [!NOTE]
> it preserves the cursor and updates the selection
> no need to call the `setSelection` after this

Command signature

```ts
insertTextAt: (start: number, end: number, text: string) => void;
```

useage

```ts
inputRef.current?.insertTextAt(4, 6, 'This is Text');
```

### 5. setSelection(start, end)

> use to set the value of TextInput (replaces whole content)

Command signature

```ts
setSelection: (start: number, end: number) => void;
```

useage

```ts
inputRef.current?.setSelection(4, 6);
```

### 6. getNativeRef()

> use to get the internal ref object of the TypeRichTextInput

> [!NOTE]
> you mostly does not need to use this
> only use this when you need to use the ref in certain cases like following

```ts
const hostRef = input?.getNativeRef?.();
const node = findNodeHandle(hostRef); // findNodeHandle is from 'react-native'
```

Command signature

```ts
getNativeRef: () => any | null;
```

useage

```ts
inputRef.current?.getNativeRef();
```

## Contributing

- [Development workflow](CONTRIBUTING.md#development-workflow)
- [Sending a pull request](CONTRIBUTING.md#sending-a-pull-request)
- [Code of conduct](CODE_OF_CONDUCT.md)

## License

MIT

---

Made with [create-react-native-library](https://github.com/callstack/react-native-builder-bob)
