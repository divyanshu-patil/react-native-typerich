# react-native-type-rich-text-input

Drop in TextInput replacement with inbuilt support for Image Pasting and Gboard stickers
currently available only for android

## Installation

```sh
npm install react-native-typerich
```

## Usage

```js
import { TypeRichTextInput } from 'react-native-typerich';

// ...

<TypeRichTextInput
  ref={ref}
  style={styles.typeRichTextInput}
  placeholder="Type here..."
  placeholderTextColor="rgb(0, 26, 114)"
  selectionColor="red"
  cursorColor="green"
  autoCapitalize="words"
  onChangeText={(text: string) => console.log(text)}
  onFocus={() => console.log('focused')}
  onBlur={() => console.log('blurred')}
  onChangeSelection={(e: { start: number, end: number, text: string }) =>
    console.log(e)
  }
  androidExperimentalSynchronousEvents={true}
  multiline
  numberOfLines={5}
  onPasteImageData={(e) => {
    console.log(e);
  }}
  defaultValue="TypeRichTextInput"
  keyboardAppearance="dark" // ios only
/>;
```

## Contributing

- [Development workflow](CONTRIBUTING.md#development-workflow)
- [Sending a pull request](CONTRIBUTING.md#sending-a-pull-request)
- [Code of conduct](CODE_OF_CONDUCT.md)

## License

MIT

---

Made with [create-react-native-library](https://github.com/callstack/react-native-builder-bob)
