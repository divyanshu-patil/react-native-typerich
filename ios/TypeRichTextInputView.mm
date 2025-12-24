#import "TypeRichTextInputView.h"

#import <react/renderer/components/TypeRichTextInputViewSpec/Props.h>
#import <react/renderer/components/TypeRichTextInputViewSpec/RCTComponentViewHelpers.h>
#import "cpp/TypeRichTextInputViewComponentDescriptor.h"
#import "RCTFabricComponentsPlugins.h"

#import <React/RCTConversions.h>

using namespace facebook::react;

@interface TypeRichTextInputView () <RCTTypeRichTextInputViewViewProtocol>
@end

@implementation TypeRichTextInputView {
  UITextView *_textView;
  UILabel *_placeholderLabel;
  UIColor *_placeholderColor;
  BOOL _emitFocusBlur;
}

+ (ComponentDescriptorProvider)componentDescriptorProvider {
  return concreteComponentDescriptorProvider<
      TypeRichTextInputViewComponentDescriptor>();
}

static inline NSString *NSStringFromCppString(const std::string &str) {
  return str.empty() ? @"" : [NSString stringWithUTF8String:str.c_str()];
}

static const UIEdgeInsets kDefaultTextInsets = {8, 5, 8, 5};

- (instancetype)initWithFrame:(CGRect)frame {
  if (self = [super initWithFrame:frame]) {
    _emitFocusBlur = YES;

    _textView = [[UITextView alloc] initWithFrame:CGRectZero];
    _textView.delegate = self;
    _textView.backgroundColor = UIColor.clearColor;
    _textView.scrollEnabled = YES;
    _textView.textContainerInset = kDefaultTextInsets;
    _textView.textContainer.lineFragmentPadding = 0;

    _placeholderLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _placeholderLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _placeholderLabel.hidden = YES;

    [_textView addSubview:_placeholderLabel];

    [NSLayoutConstraint activateConstraints:@[
      [_placeholderLabel.leadingAnchor constraintEqualToAnchor:_textView.leadingAnchor],
      [_placeholderLabel.trailingAnchor constraintEqualToAnchor:_textView.trailingAnchor],
      [_placeholderLabel.topAnchor constraintEqualToAnchor:_textView.topAnchor],
    ]];

    self.contentView = _textView;
    self.blockEmitting = NO;
  }
  return self;
}

#pragma mark - Props

- (void)updateProps:(Props::Shared const &)props
           oldProps:(Props::Shared const &)oldProps {

  const auto &newProps =
      *std::static_pointer_cast<TypeRichTextInputViewProps const>(props);
  static const TypeRichTextInputViewProps kEmptyProps{};

  const auto &oldPropsTyped =
    oldProps
      ? *std::static_pointer_cast<TypeRichTextInputViewProps const>(oldProps)
      : kEmptyProps;

  // value
  if (newProps.value != oldPropsTyped.value) {
    _textView.text = _textView.text = NSStringFromCppString(newProps.value);
  }

  // defaultValue (only on mount)
  if (oldProps == nullptr && !newProps.defaultValue.empty()) {
    _textView.text = NSStringFromCppString(newProps.defaultValue);
  }

  // editable
  if (newProps.editable != oldPropsTyped.editable) {
    _textView.editable = newProps.editable;
  }

  // placeholder
  if (newProps.placeholder != oldPropsTyped.placeholder) {
    _placeholderLabel.text = NSStringFromCppString(newProps.placeholder);
    [self updatePlaceholderVisibility];
  }

  // placeholderTextColor
  if (newProps.placeholderTextColor != oldPropsTyped.placeholderTextColor) {
    if (isColorMeaningful(newProps.placeholderTextColor)) {
      _placeholderColor =
          RCTUIColorFromSharedColor(newProps.placeholderTextColor);
      _placeholderLabel.textColor = _placeholderColor;
    }
  }

  // text color
  if (newProps.color != oldPropsTyped.color) {
    if (isColorMeaningful(newProps.color)) {
      _textView.textColor = RCTUIColorFromSharedColor(newProps.color);
    }
  }

  // font
  if (newProps.fontSize || !newProps.fontFamily.empty()) {
    CGFloat size = newProps.fontSize ? newProps.fontSize : 14;
    NSString *family = newProps.fontFamily.empty()
      ? nil
      : NSStringFromCppString(newProps.fontFamily);


    UIFont *font = family
        ? [UIFont fontWithName:family size:size]
        : [UIFont systemFontOfSize:size];

    _textView.font = font;
    _placeholderLabel.font = font;
  }

  // selection color (cursor)
  if (newProps.selectionColor != oldPropsTyped.selectionColor) {
    if (isColorMeaningful(newProps.selectionColor)) {
      _textView.tintColor =
          RCTUIColorFromSharedColor(newProps.selectionColor);
    }
  }

  // scrollEnabled
  if (newProps.scrollEnabled != oldPropsTyped.scrollEnabled) {
    _textView.scrollEnabled = newProps.scrollEnabled;
  }

  // autoCapitalize
  if (newProps.autoCapitalize != oldPropsTyped.autoCapitalize) {
    NSString *mode = NSStringFromCppString(newProps.autoCapitalize);

    if ([mode isEqualToString:@"none"]) {
      _textView.autocapitalizationType = UITextAutocapitalizationTypeNone;
    } else if ([mode isEqualToString:@"sentences"]) {
      _textView.autocapitalizationType = UITextAutocapitalizationTypeSentences;
    } else if ([mode isEqualToString:@"words"]) {
      _textView.autocapitalizationType = UITextAutocapitalizationTypeWords;
    } else if ([mode isEqualToString:@"characters"]) {
      _textView.autocapitalizationType = UITextAutocapitalizationTypeAllCharacters;
    }
  }

  // autoFocus
  if (oldProps == nullptr && newProps.autoFocus) {
    [_textView becomeFirstResponder];
  }

  [super updateProps:props oldProps:oldProps];
}

#pragma mark - Measurement

- (CGSize)measureSize:(CGFloat)maxWidth {
  // Ensure font exists
  UIFont *font = _textView.font ?: [UIFont systemFontOfSize:14];

  // Text to measure (use placeholder when empty)
  NSString *textToMeasure =
      _textView.text.length > 0
        ? _textView.text
        : (_placeholderLabel.text ?: @" ");

  // Text width minus insets
  UIEdgeInsets inset = _textView.textContainerInset;
  CGFloat availableWidth = MAX(0, maxWidth - inset.left - inset.right);

  CGRect boundingRect =
    [textToMeasure boundingRectWithSize:CGSizeMake(availableWidth, CGFLOAT_MAX)
                                options:NSStringDrawingUsesLineFragmentOrigin
                             attributes:@{ NSFontAttributeName: font }
                                context:nil];

  CGFloat height =
    ceil(boundingRect.size.height) +
    inset.top +
    inset.bottom;

  // Guarantee minimum one-line height
  CGFloat minHeight =
    ceil(font.lineHeight + inset.top + inset.bottom);

  return CGSizeMake(maxWidth, MAX(height, minHeight));
}


#pragma mark - Placeholder

- (void)updatePlaceholderVisibility {
  _placeholderLabel.hidden = _textView.text.length > 0;
}

#pragma mark - UITextViewDelegate

- (void)textViewDidBeginEditing:(UITextView *)textView {
  auto emitter = [self getEventEmitter];
  if (emitter && _emitFocusBlur) {
    emitter->onInputFocus({});
  }
}

- (void)textViewDidEndEditing:(UITextView *)textView {
  auto emitter = [self getEventEmitter];
  if (emitter && _emitFocusBlur) {
    emitter->onInputBlur({});
  }
}

- (void)textViewDidChange:(UITextView *)textView {
  [self updatePlaceholderVisibility];

  auto emitter = [self getEventEmitter];
  if (emitter && ! self.blockEmitting ) {
    emitter->onChangeText({
      .value = std::string(textView.text.UTF8String ?: "")
    });
  }


  [self invalidateIntrinsicContentSize];
}

- (void)textViewDidChangeSelection:(UITextView *)textView {
  auto emitter = [self getEventEmitter];
  if (emitter) {
    emitter->onChangeSelection({
      .start = (int)textView.selectedRange.location,
      .end = (int)(textView.selectedRange.location + textView.selectedRange.length),
      .text = std::string(textView.text.UTF8String ?: "")
    });
  }
}

- (std::shared_ptr<TypeRichTextInputViewEventEmitter>)getEventEmitter {
  if (_eventEmitter == nullptr) {
    return nullptr;
  }

  auto const &emitter =
      static_cast<TypeRichTextInputViewEventEmitter const &>(*_eventEmitter);

  return std::make_shared<TypeRichTextInputViewEventEmitter>(emitter);
}


#pragma mark - Paste (stub)

- (BOOL)textView:(UITextView *)textView
    shouldChangeTextInRange:(NSRange)range
            replacementText:(NSString *)text {
  // Image paste will be implemented later
  return YES;
}

@end

Class<RCTComponentViewProtocol> TypeRichTextInputViewCls(void) {
  return TypeRichTextInputView.class;
}
