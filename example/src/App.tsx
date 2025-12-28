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
  Platform,
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
  const selectionRef = useRef<{ start: number; end: number }>({
    start: 0,
    end: 0,
  });
  const [image, setImage] = useState<onPasteImageEventData | null>(null);
  const [value, setValue] = useState<string>('hhh');

  const multilineValue = `hello
    div
    multiline`;

  // const handleChangeText = (e: NativeSyntheticEvent<OnChangeTextEvent>) => {
  //   console.log('Text changed:', e?.nativeEvent.value);
  // };

  const handleFocus = () => {
    inputRef.current?.focus();
  };

  const handleBlur = () => {
    inputRef.current?.blur();
  };

  const handleSetValue = (value = 'default value') => {
    textRef.current = value;
    inputRef.current?.setText(value);
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
    const testText = 'draft simulation test';
    inputRef.current?.setText(testText);
    textRef.current = testText; // Update textRef too
    // inputRef.current?.setSelection(
    //   textRef.current.length,
    //   textRef.current.length
    // );
    inputRef.current?.setSelection(testText.length, testText.length);
  }, []);

  function handleSelectionChange(e: {
    start: number;
    end: number;
    text: string;
  }): void {
    console.log('selectionChange called', e);
    selectionRef.current = { start: e.start, end: e.end };
  }

  const handleInsertTextAtCursor = () => {
    const textToInsert = 'Test';
    inputRef.current?.insertTextAt(
      selectionRef.current.start,
      selectionRef.current.end,
      textToInsert
    );
  };

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
            value={value}
            // defaultValue={textRef.current}
            style={styles.editorInput}
            placeholder="custom textinput"
            placeholderTextColor="rgb(0, 26, 114)"
            selectionColor="green"
            cursorColor="red"
            autoCapitalize="words"
            autoFocus
            onChangeText={(text: string) => {
              console.log('text changed ========', text);
              textRef.current = text;
              setValue(text); // controlled by value
              // inputRef.current?.setText(text); // controlled by command
            }}
            onFocus={handleFocusEvent}
            onBlur={handleBlurEvent}
            onChangeSelection={handleSelectionChange}
            // androidExperimentalSynchronousEvents={
            //   ANDROID_EXPERIMENTAL_SYNCHRONOUS_EVENTS
            // }
            multiline
            // numberOfLines={5} // prefer maxHeight on iOS
            scrollEnabled
            onPasteImageData={(e) => {
              setImage(e);
              console.log(e);
            }}
            keyboardAppearance="dark"
            editable={true}
            lineHeight={22}
            fontFamily={Platform.select({ ios: 'georgia', android: 'serif' })} // fontweight won't work unless this is used
            fontStyle="italic"
            fontWeight={'200'}
            fontSize={24}
            color="darkgreen"
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
          // multiline
          // numberOfLines={4}
        />
        <View style={styles.btnContainer}>
          <View style={styles.buttonStack}>
            <Pressable onPress={handleFocus} style={[styles.button]}>
              <Text style={styles.label2}>Focus</Text>
            </Pressable>
            <Pressable onPress={handleBlur} style={styles.button}>
              <Text style={styles.label2}>Blur</Text>
            </Pressable>
          </View>
          <View style={styles.buttonStack}>
            <Pressable onPress={() => handleSetValue('')} style={styles.button}>
              <Text style={styles.label2}>clear Text</Text>
            </Pressable>
            <Pressable onPress={handleInsertTextAtCursor} style={styles.button}>
              <Text style={styles.label2}>insert "Test" at cursor</Text>
            </Pressable>
          </View>
          <View style={styles.buttonStack}>
            <Pressable
              onPress={() => handleSetValue(multilineValue)}
              style={styles.button}
            >
              <Text style={styles.label2}>Set value to hello div</Text>
            </Pressable>
            <Pressable onPress={handleSetSelection} style={styles.button}>
              <Text style={styles.label2}>set selection</Text>
            </Pressable>
          </View>
          <View style={styles.buttonStack}>
            <Pressable
              onPress={() => {
                console.log('setvalue');
                console.log(value);
                setValue('controlled value');
              }}
              style={styles.button}
            >
              <Text style={styles.label2}>set controlled Value</Text>
            </Pressable>
            <Pressable
              disabled
              onPress={() => {}}
              style={[styles.button, { backgroundColor: 'gray' }]}
            >
              <Text style={styles.label2}>Todo</Text>
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
                inputRef.current?.setText(next);
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
  btnContainer: {
    rowGap: 16,
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
  },
  valueButton: {
    width: '100%',
  },
  editorInput: {
    marginTop: 24,
    width: '100%',
    maxHeight: 280,
    backgroundColor: 'gainsboro',
    // fontSize: 34,
    fontFamily: 'Nunito-Regular',
    // paddingVertical: 12,
    // paddingHorizontal: 14,
  },
  scrollPlaceholder: {
    marginTop: 24,
    width: '100%',
    height: 1000,
    backgroundColor: 'rgb(0, 26, 114)',
  },
});
