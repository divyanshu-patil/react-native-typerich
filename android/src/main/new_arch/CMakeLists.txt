cmake_minimum_required(VERSION 3.13)
set(CMAKE_VERBOSE_MAKEFILE on)

# The JS spec name → codegen outputs react_codegen_<name>
set(LIB_SPEC_LITERAL TypeRichTextInputViewSpec)

# Your actual custom C++ folder name
set(LIB_CUSTOM_LITERAL TypeRichTextInputView)

set(LIB_TARGET_NAME react_codegen_${LIB_SPEC_LITERAL})

# Directories
set(LIB_ANDROID_DIR ${CMAKE_CURRENT_SOURCE_DIR}/../../..)
set(LIB_ANDROID_GENERATED_JNI_DIR ${LIB_ANDROID_DIR}/generated/android/app/build/generated/source/codegen/jni)
set(LIB_ANDROID_GENERATED_COMPONENTS_DIR ${LIB_ANDROID_GENERATED_JNI_DIR}/react/renderer/components/${LIB_SPEC_LITERAL})

set(LIB_CUSTOM_DIR ${CMAKE_CURRENT_SOURCE_DIR}/react/renderer/components/${LIB_CUSTOM_LITERAL})

# Custom handwritten C++ code
file(GLOB LIB_CUSTOM_SRCS CONFIGURE_DEPENDS
    ${LIB_CUSTOM_DIR}/*.cpp
)

# Codegen generated files
file(GLOB LIB_CODEGEN_SRCS CONFIGURE_DEPENDS
    ${LIB_ANDROID_GENERATED_COMPONENTS_DIR}/*.cpp
)

add_library(
        ${LIB_TARGET_NAME}
        SHARED
        ${CMAKE_CURRENT_SOURCE_DIR}/TypeRichTextInputViewSpec.cpp
        ${LIB_CUSTOM_SRCS}
        ${LIB_CODEGEN_SRCS}
)

target_include_directories(
        ${LIB_TARGET_NAME}
        PUBLIC
        .
        ${LIB_CUSTOM_DIR}
        ${LIB_ANDROID_GENERATED_JNI_DIR}
        ${LIB_ANDROID_GENERATED_COMPONENTS_DIR}
)

find_package(fbjni REQUIRED CONFIG)
find_package(ReactAndroid REQUIRED CONFIG)

target_link_libraries(
        ${LIB_TARGET_NAME}
        fbjni::fbjni
        ReactAndroid::jsi
        ReactAndroid::reactnative
        log
)

if(ReactAndroid_VERSION_MINOR GREATER_EQUAL 80)
  target_compile_reactnative_options(${LIB_TARGET_NAME} PRIVATE)
else()
  target_compile_options(
          ${LIB_TARGET_NAME}
          PRIVATE
          -fexceptions
          -frtti
          -Wall
  )
endif()

target_include_directories(
        ${CMAKE_PROJECT_NAME}
        PUBLIC
        ${CMAKE_CURRENT_SOURCE_DIR}
)
