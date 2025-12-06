declare module 'react-native/Libraries/Types/CodegenTypes' {
  export type Int32 = number;
  export type Float = number;
  export type Double = number;

  // eslint-disable-next-line @typescript-eslint/no-unused-vars
  export type WithDefault<T, DefaultT> = T;

  export type BubblingEventHandler<T> = (event: T) => void;
  export type DirectEventHandler<T> = (event: T) => void;
}
