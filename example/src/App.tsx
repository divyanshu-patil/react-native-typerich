import {
  View,
  StyleSheet,
  Text,
  // type NativeSyntheticEvent,
  ScrollView,
  Pressable,
  TextInput,
  Image,
} from 'react-native';
import {
  TypeRichTextInput,
  // type OnChangeTextEvent,
  // type OnChangeSelectionEvent,
  type TypeRichTextInputRef,
} from 'react-native-typerich';
import { useRef, useState } from 'react';

// Enabling this prop fixes input flickering while auto growing.
// However, it's still experimental and not tested well.
// Disabled for now, as it's causing some strange issues.
// See: https://github.com/divyanshu-patil/react-native-typerich/issues/229
// const ANDROID_EXPERIMENTAL_SYNCHRONOUS_EVENTS = false;

export default function App() {
  const ref = useRef<TypeRichTextInputRef>(null);
  const [image, setImage] = useState<any | null>(null);

  // const handleChangeText = (e: NativeSyntheticEvent<OnChangeTextEvent>) => {
  //   console.log('Text changed:', e?.nativeEvent.value);
  // };

  const handleFocus = () => {
    ref.current?.focus();
  };

  const handleBlur = () => {
    ref.current?.blur();
  };

  const handleFocusEvent = () => {
    console.log('Input focused');
  };

  const handleBlurEvent = () => {
    console.log('Input blurred');
  };

  // const handleSelectionChangeEvent = (
  //   e: NativeSyntheticEvent<OnChangeSelectionEvent>
  // ) => {
  //   console.log('selection event', e.nativeEvent);
  // };

  return (
    <>
      <ScrollView
        style={styles.container}
        contentContainerStyle={styles.content}
      >
        <Text style={styles.label}>TypeRich cdshjc Text Input</Text>
        {image && (
          <Image source={{ uri: image.uri }} width={200} height={200} />
        )}
        <View style={styles.editor}>
          <TypeRichTextInput
            ref={ref}
            style={styles.editorInput}
            placeholder="Type something here..."
            placeholderTextColor="rgb(0, 26, 114)"
            selectionColor="deepskyblue"
            cursorColor="dodgerblue"
            autoCapitalize="words"
            onChangeText={(text) => console.log(text)}
            onFocus={handleFocusEvent}
            onBlur={handleBlurEvent}
            onChangeSelection={(e) => console.log(e)}
            // androidExperimentalSynchronousEvents={
            //   ANDROID_EXPERIMENTAL_SYNCHRONOUS_EVENTS
            // }
            multiline
            numberOfLines={4}
            onPasteImageData={(e) => {
              setImage(e);
              console.log(e);
            }}
          />
        </View>
        <TextInput
          placeholder="hello"
          // eslint-disable-next-line react-native/no-inline-styles
          style={{ borderColor: 'black', borderWidth: 1, width: '100%' }}
          // multiline={false}
          // numberOfLines={2}
        />
        <View style={styles.buttonStack}>
          <Pressable onPress={handleFocus} style={styles.button}>
            <Text style={styles.label2}>Focus</Text>
          </Pressable>
          <Pressable onPress={handleBlur} style={styles.button}>
            <Text style={styles.label2}>Blur</Text>
          </Pressable>
        </View>
      </ScrollView>
    </>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: 'white',
  },
  content: {
    flexGrow: 1,
    padding: 16,
    paddingTop: 100,
    alignItems: 'center',
  },
  editor: {
    width: '100%',
  },
  label: {
    fontSize: 24,
    fontWeight: 'bold',
    textAlign: 'center',
    color: 'rgb(0, 26, 114)',
  },
  label2: {
    color: 'white',
  },
  buttonStack: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    width: '100%',
  },
  button: {
    width: '45%',
    backgroundColor: 'rgb(0, 26, 114)',
    justifyContent: 'center',
    alignItems: 'center',
    padding: 15,
    borderRadius: 25,
    marginVertical: 25,
  },
  valueButton: {
    width: '100%',
  },
  editorInput: {
    marginTop: 24,
    width: '100%',
    // maxHeight: 180,
    backgroundColor: 'gainsboro',
    // fontSize: 34,
    fontFamily: 'Nunito-Regular',
    paddingVertical: 12,
    paddingHorizontal: 14,
  },
  scrollPlaceholder: {
    marginTop: 24,
    width: '100%',
    height: 1000,
    backgroundColor: 'rgb(0, 26, 114)',
  },
});
