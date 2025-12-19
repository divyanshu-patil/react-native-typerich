/* eslint-disable react-native/no-inline-styles */
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
  type onPasteImageEventData,
  type TypeRichTextInputRef,
} from 'react-native-typerich';
import { useEffect, useRef, useState } from 'react';

// Enabling this prop fixes input flickering while auto growing.
// However, it's still experimental and not tested well.
// Disabled for now, as it's causing some strange issues.
// See: https://github.com/software-mansion/react-native-enriched/issues/229
// const ANDROID_EXPERIMENTAL_SYNCHRONOUS_EVENTS = false;

export default function App() {
  const inputRef = useRef<TypeRichTextInputRef>(null);
  const textRef = useRef('hello world');
  const [image, setImage] = useState<onPasteImageEventData | null>(null);

  // const handleChangeText = (e: NativeSyntheticEvent<OnChangeTextEvent>) => {
  //   console.log('Text changed:', e?.nativeEvent.value);
  // };

  const handleFocus = () => {
    inputRef.current?.focus();
  };

  const handleBlur = () => {
    inputRef.current?.blur();
  };

  const handleSetValue = () => {
    const multilineValue = `hello
    div
    multiline`;
    inputRef.current?.setValue(multilineValue);
  };

  const handleSetSelection = () => {
    inputRef.current?.setSelection(2, 9);
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

  useEffect(() => {
    inputRef.current?.setValue('draft simulation test');
    textRef.current = 'draft simulation test'; // Update textRef too
  }, []);

  return (
    <>
      <ScrollView
        style={styles.container}
        contentContainerStyle={styles.content}
      >
        <Text style={styles.label}>TypeRich Text Input library by div</Text>
        {image && (
          <>
            <ImageInfo image={image} />
            <Image source={{ uri: image.uri }} width={200} height={200} />
          </>
        )}
        <View style={styles.editor}>
          <TypeRichTextInput
            ref={inputRef}
            style={styles.editorInput}
            placeholder="custom textinput with paste support..."
            placeholderTextColor="rgb(0, 26, 114)"
            selectionColor="deepskyblue"
            cursorColor="dodgerblue"
            autoCapitalize="words"
            onChangeText={(text: string) => {
              console.log('text changed ========', text);
              textRef.current = text;
              inputRef.current?.setValue(text);
            }}
            onFocus={handleFocusEvent}
            onBlur={handleBlurEvent}
            onChangeSelection={(e) => {
              console.log('start', e);
            }}
            // androidExperimentalSynchronousEvents={
            //   ANDROID_EXPERIMENTAL_SYNCHRONOUS_EVENTS
            // }
            multiline
            numberOfLines={4}
            onPasteImageData={(e) => {
              setImage(e);
              console.log(e);
            }}
            defaultValue={textRef.current}
            keyboardAppearance="dark"
            lineHeight={22}
          />
        </View>
        <TextInput
          placeholder="default text input"
          style={{
            borderColor: 'black',
            borderWidth: 1,
            width: '100%',
            marginVertical: 20,
          }}
          // multiline={false}
          // numberOfLines={2}
        />
        <View>
          <View style={styles.buttonStack}>
            <Pressable onPress={handleFocus} style={styles.button}>
              <Text style={styles.label2}>Focus</Text>
            </Pressable>
            <Pressable onPress={handleBlur} style={styles.button}>
              <Text style={styles.label2}>Blur</Text>
            </Pressable>
          </View>
          <View style={styles.buttonStack}>
            <Pressable onPress={handleSetValue} style={styles.button}>
              <Text style={styles.label2}>Set value to hello div</Text>
            </Pressable>
            <Pressable onPress={handleSetSelection} style={styles.button}>
              <Text style={styles.label2}>set selection</Text>
            </Pressable>
          </View>
          <View style={styles.buttonStack}>
            <Pressable
              style={styles.button}
              onPress={() => {
                const text = textRef.current;
                const start = 6; // before "world"
                const end = 11;

                const next =
                  text.slice(0, start) +
                  '*' +
                  text.slice(start, end) +
                  '*' +
                  text.slice(end);

                // this MUST preserve cursor after native fix
                inputRef.current?.setValue(next);
              }}
            >
              <Text style={styles.label2}>Wrap middle with * *</Text>
            </Pressable>
            <Pressable
              style={styles.button}
              onPress={() => {
                const ref: any = inputRef.current;
                console.log('JS ref:', ref);
                console.log('Native ref:', ref?.getNativeRef?.());
              }}
            >
              <Text style={styles.label2}>Debug Native Ref</Text>
            </Pressable>
          </View>
        </View>
      </ScrollView>
    </>
  );
}

const ImageInfo = ({ image }: { image: any }) => {
  return (
    <View>
      <Text style={{ color: 'red', fontWeight: 'bold' }}>
        filename:{' '}
        <Text
          style={{
            color: 'black',
            fontStyle: 'italic',
            fontWeight: 'regular',
          }}
        >
          {image.fileName}
        </Text>
      </Text>
      <Text style={{ color: 'red', fontWeight: 'bold' }}>
        fileSize:{' '}
        <Text
          style={{
            color: 'black',
            fontStyle: 'italic',
            fontWeight: 'regular',
          }}
        >
          {image.fileSize}
        </Text>
      </Text>
      <Text style={{ color: 'red', fontWeight: 'bold' }}>
        type:{' '}
        <Text
          style={{
            color: 'black',
            fontStyle: 'italic',
            fontWeight: 'regular',
          }}
        >
          {image.type}
        </Text>
      </Text>
      <Text style={{ color: 'red', fontWeight: 'bold' }}>
        source:{' '}
        <Text
          style={{
            color: 'black',
            fontStyle: 'italic',
            fontWeight: 'regular',
          }}
        >
          {image.source}
        </Text>
      </Text>
      <Text style={{ color: 'red', fontWeight: 'bold' }}>
        uri:{' '}
        <Text
          style={{
            color: 'black',
            fontStyle: 'italic',
            fontWeight: 'regular',
          }}
        >
          {image.uri}
        </Text>
      </Text>
      <Text style={{ color: 'red', fontWeight: 'bold' }}>
        error:{' '}
        <Text
          style={{
            color: 'black',
            fontStyle: 'italic',
            fontWeight: 'regular',
          }}
        >
          {image.error?.message ?? 'no error'}
        </Text>
      </Text>
    </View>
  );
};

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
