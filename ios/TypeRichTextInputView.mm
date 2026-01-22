#import "TypeRichTextInputView.h"

// Fabric / Codegen
#import <react/renderer/components/TypeRichTextInputViewSpec/Props.h>
#import <react/renderer/components/TypeRichTextInputViewSpec/RCTComponentViewHelpers.h>
#import "cpp/TypeRichTextInputViewComponentDescriptor.h"
#import "RCTFabricComponentsPlugins.h"

// React utils
#import <React/RCTConversions.h>
#import <react/utils/ManagedObjectWrapper.h>

// local utils
#import "utils/StringUtils.h"
#import "utils/TextInputUtils.h"
#import "inputTextView/TypeRichUITextView.h"

// local modules for code splitting
#import "modules/commands/TypeRichTextInputCommands.h"


using namespace facebook::react;

#pragma mark - Private interface

@interface TypeRichTextInputView () <
  RCTTypeRichTextInputViewViewProtocol,
  UITextViewDelegate,
  UIScrollViewDelegate
>
@end

#pragma mark - Implementation

@implementation TypeRichTextInputView {
  /// Native text input
  UITextView *_textView;

  /// Placeholder label (RN-style, not UITextView.placeholder)
  UILabel *_placeholderLabel;
  UIColor *_placeholderColor;

  /// Fabric state reference (owned by ShadowNode)
  TypeRichTextInputViewShadowNode::ConcreteState::Shared _state;

  /// Incremented whenever text height changes to force re-measure
  int _heightRevision;
  
  /// Flag to prevent layout updates during touch handling
  BOOL _isTouchInProgress;
  
  /// Commands to call from js side
  TypeRichTextInputCommands *_commandHandler;
//  BOOL _isHandlingUserInput;
  
  /// Disabling Image Pasing
  BOOL _disableImagePasting;
}

#pragma mark - Fabric registration

/// Registers this view with Fabric
+ (ComponentDescriptorProvider)componentDescriptorProvider {
  return concreteComponentDescriptorProvider<
    TypeRichTextInputViewComponentDescriptor>();
}

/// Required entry point for Fabric
Class<RCTComponentViewProtocol> TypeRichTextInputViewCls(void) {
  return TypeRichTextInputView.class;
}

#pragma mark - Init

- (instancetype)initWithFrame:(CGRect)frame {
  if (self = [super initWithFrame:frame]) {
    _heightRevision = 0;
    _isTouchInProgress = NO;

    // ---------------------------
    // UITextView FIRST
    // ---------------------------
    TypeRichUITextView *tv =
      [[TypeRichUITextView alloc] initWithFrame:CGRectZero];
    tv.owner = self;
    _textView = tv;

    _textView.delegate = self;
    _textView.scrollEnabled = YES;
    _textView.backgroundColor = UIColor.clearColor;
    _textView.textContainerInset = UIEdgeInsetsZero;
    _textView.textContainer.lineFragmentPadding = 0;

    // KEY FIX: Allow text container to grow beyond visible bounds
    _textView.textContainer.heightTracksTextView = NO;
    
    // Disable delaysContentTouches to prevent scroll conflicts
    _textView.delaysContentTouches = NO;
    
    // initialise commandHandler
    _commandHandler =
      [[TypeRichTextInputCommands alloc] initWithTextView:_textView
                                                    owner:self];
    
    // ---------------------------
    // Placeholder label (ONCE)
    // ---------------------------
    _placeholderLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _placeholderLabel.hidden = YES;
    _placeholderLabel.numberOfLines = 0;
    _placeholderLabel.translatesAutoresizingMaskIntoConstraints = NO;

    _placeholderColor = [UIColor colorWithWhite:0 alpha:0.3];
    _placeholderLabel.textColor = _placeholderColor;

    [_textView addSubview:_placeholderLabel];

    // Constraints (match text layout)
    [NSLayoutConstraint activateConstraints:@[
      [_placeholderLabel.leadingAnchor constraintEqualToAnchor:_textView.leadingAnchor],
      [_placeholderLabel.trailingAnchor constraintEqualToAnchor:_textView.trailingAnchor],
      [_placeholderLabel.topAnchor constraintEqualToAnchor:_textView.topAnchor]
    ]];
    
    // Set initial font
    UIFont *defaultFont = [UIFont systemFontOfSize:14];
    _textView.font = defaultFont;
    _placeholderLabel.font = defaultFont;

    _disableImagePasting = NO;
    
    // Add textView as subview (not contentView)
    self.contentView = _textView;
  
    [self updatePlaceholderVisibility];
  }
  return self;
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
  // Allow simultaneous recognition with RN's gesture recognizers
  return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldBeRequiredToFailByGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
  // UITextView's pan gesture should not block other gestures
  return NO;
}

#pragma mark - Touch Handling

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
  _isTouchInProgress = YES;
  [super touchesBegan:touches withEvent:event];
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
  _isTouchInProgress = NO;
  [super touchesEnded:touches withEvent:event];
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
  _isTouchInProgress = NO;
  [super touchesCancelled:touches withEvent:event];
}

#pragma mark - Props (JS → Native)

- (void)updateProps:(Props::Shared const &)props
           oldProps:(Props::Shared const &)oldProps
{
  const auto &newProps =
    *std::static_pointer_cast<TypeRichTextInputViewProps const>(props);

  const auto *oldPropsPtr =
    oldProps
      ? std::static_pointer_cast<TypeRichTextInputViewProps const>(oldProps).get()
      : nullptr;

#pragma mark - Base Props
  
  // Text value (controlled)
  if (!oldPropsPtr || newProps.value != oldPropsPtr->value) {
    NSString *newText = NSStringFromCppString(newProps.value);
    NSString *currentText = _textView.text ?: @"";

    if (![currentText isEqualToString:newText]) {
      NSRange prevSelection = _textView.selectedRange;

      self.blockEmitting = YES;
      _textView.text = newText;

      NSInteger len = newText.length;
      NSInteger start = MIN(prevSelection.location, len);
      NSInteger end   = MIN(prevSelection.location + prevSelection.length, len);

      _textView.selectedRange = NSMakeRange(start, end - start);
      self.blockEmitting = NO;
    }
    [self invalidateTextLayout];
  }

  // defaultValue (mount only)
  if (oldProps == nullptr && !newProps.defaultValue.empty()) {
    _textView.text = NSStringFromCppString(newProps.defaultValue);
  }

  // Placeholder
  if (!oldPropsPtr || newProps.placeholder != oldPropsPtr->placeholder) {
    _placeholderLabel.text =
      NSStringFromCppString(newProps.placeholder);
    [self updatePlaceholderVisibility];
  }

  // placeholderTextColor
  if (!oldPropsPtr || newProps.placeholderTextColor != oldPropsPtr->placeholderTextColor) {
    if (isColorMeaningful(newProps.placeholderTextColor)) {
      _placeholderColor =
        RCTUIColorFromSharedColor(newProps.placeholderTextColor);
      _placeholderLabel.textColor = _placeholderColor;
    }
  }
  
  // Editable
  if (!oldPropsPtr || newProps.editable != oldPropsPtr->editable) {
    _textView.editable = newProps.editable;
  }
  
  // Auto focus
  if (oldProps == nullptr && newProps.autoFocus) {
    [_textView becomeFirstResponder];
  }
  
  // cursor color
  if (!oldPropsPtr || newProps.cursorColor != oldPropsPtr->cursorColor) {
    if (isColorMeaningful(newProps.cursorColor)) {
      _textView.tintColor =
        RCTUIColorFromSharedColor(newProps.cursorColor);
    }
  }

  // selectionColor
  if (!oldPropsPtr || newProps.selectionColor != oldPropsPtr->selectionColor) {
    if (isColorMeaningful(newProps.selectionColor)) {
      _textView.tintColor =
        RCTUIColorFromSharedColor(newProps.selectionColor);
    }
  }

  // autoCapitalise
  if (!oldPropsPtr || newProps.autoCapitalize != oldPropsPtr->autoCapitalize) {
    if (!newProps.autoCapitalize.empty()) {
      _textView.autocapitalizationType =
        AutocapitalizeFromString(
          NSStringFromCppString(newProps.autoCapitalize)
        );
    }
  }

  // scrollEnabled
  if (!oldPropsPtr || newProps.scrollEnabled != oldPropsPtr->scrollEnabled) {
    _textView.scrollEnabled = newProps.scrollEnabled;
    _textView.showsVerticalScrollIndicator = newProps.scrollEnabled;
    
    // KEY FIX: Control text container height tracking
    _textView.textContainer.heightTracksTextView = !newProps.scrollEnabled;
  }

  // multiline
  if (!oldPropsPtr || newProps.multiline != oldPropsPtr->multiline) {
    // Do NOT set maximumNumberOfLines here - handle it in numberOfLines
    // This prevents premature line limiting
  }
  
  if (!oldPropsPtr ||
        newProps.numberOfLines != oldPropsPtr->numberOfLines ||
        newProps.multiline != oldPropsPtr->multiline ||
      newProps.scrollEnabled != oldPropsPtr->scrollEnabled) {
    
    if (newProps.multiline && newProps.numberOfLines > 0) {
      // KEY FIX: Only limit lines when scrolling is DISABLED
      // When scrolling is enabled, all content should be laid out
      if (!newProps.scrollEnabled) {
        _textView.textContainer.maximumNumberOfLines = newProps.numberOfLines;
      } else {
        // Allow unlimited lines when scrolling
        _textView.textContainer.maximumNumberOfLines = 0;
      }
    } else if (newProps.multiline) {
      _textView.textContainer.maximumNumberOfLines = 0;
    } else {
      _textView.textContainer.maximumNumberOfLines = 1;
    }
    [self invalidateTextLayout];
  }
  
  // keyboardAppearance
  if (!oldPropsPtr ||
      newProps.keyboardAppearance != oldPropsPtr->keyboardAppearance) {

    _textView.keyboardAppearance =
      KeyboardAppearanceFromEnum(
        newProps.keyboardAppearance
      );
  }
  
  // disableImagePasting
  if (!oldPropsPtr || newProps.disableImagePasting != oldPropsPtr->disableImagePasting) {
    _disableImagePasting = newProps.disableImagePasting;
  }
  
#pragma mark - Style Props
  
  // Text color
  if (!oldPropsPtr || newProps.color != oldPropsPtr->color) {
    if (isColorMeaningful(newProps.color)) {
      _textView.textColor = RCTUIColorFromSharedColor(newProps.color);
    }
  }

  // Font Block ------------------------------------------------------------------
  BOOL fontChanged = !oldPropsPtr ||
                     newProps.fontSize != oldPropsPtr->fontSize ||
                     newProps.fontFamily != oldPropsPtr->fontFamily ||
                     newProps.fontWeight != oldPropsPtr->fontWeight ||
                     newProps.fontStyle != oldPropsPtr->fontStyle;


  if (fontChanged) {
    
    // Font size
    CGFloat size =
      newProps.fontSize > 0 ? (CGFloat)newProps.fontSize : 14.0;

    // font family
    NSString *family = nil;
    if (!newProps.fontFamily.empty()) {
      family = NSStringFromCppString(newProps.fontFamily);
    }

    // Resolve font weight
    // Values: "100"–"900", "normal", "bold
    NSString *weightStr = nil;
    if (!newProps.fontWeight.empty()) {
      weightStr = NSStringFromCppString(newProps.fontWeight);
    }

    // font style
    // Values: "italic" | "normal"
    NSString *styleStr = @"normal";
    if (!newProps.fontStyle.empty()) {
      styleStr = NSStringFromCppString(newProps.fontStyle);
    }

    
    // Create Base UIFont
    UIFont *font = nil;

    if (family) {
      // Custom font family
      font = [UIFont fontWithName:family size:size];

      // Fallback if custom font not found
      if (!font) {
        NSLog(@"Font '%@' not found, using system font", family);
        font = [UIFont systemFontOfSize:size];
      }
    } else {
      // System font path with weight support
      UIFontWeight weight =
        weightStr ? FontWeightFromString(weightStr)
                  : UIFontWeightRegular;

      font = [UIFont systemFontOfSize:size weight:weight];
    }

    // Apply fontStyle (italic / normal) with font descriptor
    UIFontDescriptorSymbolicTraits traits =
       font.fontDescriptor.symbolicTraits;

     if ([styleStr isEqualToString:@"italic"]) {
       traits |= UIFontDescriptorTraitItalic;
     } else {
       // Explicitly remove italic when switching back to "normal"
       traits &= ~UIFontDescriptorTraitItalic;
     }
    UIFontDescriptor *descriptor =
        [font.fontDescriptor fontDescriptorWithSymbolicTraits:traits];

      if (descriptor) {
        font = [UIFont fontWithDescriptor:descriptor size:size];
      }
    
#pragma mark - Setting font
    // Apply font to UITextView and placeholder
    _textView.font = font;
    _placeholderLabel.font = font;

    NSLog(
      @"Font updated: size=%.1f, family=%@, weight=%@, style=%@",
      size,
      family ?: @"system",
      weightStr ?: @"regular",
      styleStr ?: @"normal"
    );
  }
  // End Font Block ------------------------------------------------------------------
  
  //  lineheight
  BOOL lineHeightChanged =
    !oldPropsPtr || newProps.lineHeight != oldPropsPtr->lineHeight;

  if (lineHeightChanged && newProps.lineHeight > 0) {
    CGFloat lineHeight = newProps.lineHeight;
    UIFont *font = _textView.font;

    // do not go below fontsize's lineheight
    if (lineHeight < font.lineHeight) {
      lineHeight = font.lineHeight;
    }

    NSMutableParagraphStyle *paragraphStyle =
      [[NSMutableParagraphStyle alloc] init];

    paragraphStyle.minimumLineHeight = lineHeight;
    paragraphStyle.maximumLineHeight = lineHeight;

    // Baseline fix (prevents overlap)
    CGFloat baselineOffset =
      (lineHeight - font.lineHeight) / 2.0;

    NSDictionary *attributes = @{
      NSFontAttributeName: font,
      NSParagraphStyleAttributeName: paragraphStyle,
      NSBaselineOffsetAttributeName: @(baselineOffset)
    };

    // Always update typingAttributes (safe)
     _textView.typingAttributes = attributes;

     // Do not touch attributedText during composition
     if (_textView.markedTextRange != nil) {
       return;
     }
    
    // Apply to existing text
    NSMutableAttributedString *attributedText =
      [[NSMutableAttributedString alloc]
        initWithString:_textView.text ?: @""
            attributes:attributes];

    _textView.typingAttributes = attributes;

    if (!_textView.isFirstResponder &&
        _textView.markedTextRange == nil) {

      NSRange sel = _textView.selectedRange;

      NSMutableAttributedString *attr =
        [[NSMutableAttributedString alloc]
          initWithString:_textView.text ?: @""
              attributes:attributes];

      _textView.attributedText = attr;
      _textView.selectedRange = sel;
    }


    // Apply to future typing
    _textView.typingAttributes = attributes;
  }

#pragma mark - updating props
  // Update placeholder visibility
  [self updatePlaceholderVisibility];
  [self invalidateTextLayout];
  [super updateProps:props oldProps:oldProps];
}

#pragma mark - Measurement (ShadowNode → View)

/// Fabric calls this to measure height for given width
- (CGSize)measureSize:(CGFloat)maxWidth {
  UIEdgeInsets inset = _textView.textContainerInset;
  CGFloat availableWidth = MAX(0, maxWidth - inset.left - inset.right);

  // Get the props to check numberOfLines and scrollEnabled
  if (_eventEmitter) {
    auto props = std::static_pointer_cast<const TypeRichTextInputViewProps >(_props);
    
    // If scrollEnabled with numberOfLines, return fixed height
    if (props->scrollEnabled && props->multiline && props->numberOfLines > 0) {
      // Calculate height for specified number of lines
      UIFont *font = _textView.font ?: [UIFont systemFontOfSize:14];
      CGFloat lineHeight = font.lineHeight;
      
      // Apply custom lineHeight if set
      if (props->lineHeight > 0) {
        lineHeight = MAX(props->lineHeight, font.lineHeight);
      }
      
      CGFloat height = lineHeight * props->numberOfLines;
      return CGSizeMake(maxWidth, ceil(height));
    }
  }

  // For non-scrollable or unlimited lines, measure actual content
  CGSize fitting = [_textView sizeThatFits:CGSizeMake(availableWidth, CGFLOAT_MAX)];
  return CGSizeMake(maxWidth, ceil(fitting.height));
}

#pragma mark - Layout invalidation

/// Forces UITextView to re-layout text and notifies Fabric to re-measure
- (void)invalidateTextLayout {
  if (!_textView ||
      _isTouchInProgress ||
      _textView.isFirstResponder) {
    return;
  }

  // ---- UIKit layout invalidation ----
  NSLayoutManager *layoutManager = _textView.layoutManager;
  NSTextStorage *textStorage = _textView.textStorage;

  NSRange fullRange = NSMakeRange(0, textStorage.length);

  // Invalidate glyphs & layout
  [layoutManager invalidateLayoutForCharacterRange:fullRange
                              actualCharacterRange:NULL];
  [layoutManager invalidateDisplayForCharacterRange:fullRange];

  // Ensure layout is recalculated immediately
  [layoutManager ensureLayoutForCharacterRange:fullRange];

  // ---- Force UITextView to recompute contentSize ----
  [_textView setNeedsLayout];
  [_textView layoutIfNeeded];

  // ---- Notify Fabric to re-measure ----
  if (_state == nullptr) {
    return;
  }

  _heightRevision++;

  auto selfRef = wrapManagedObjectWeakly(self);
  dispatch_async(dispatch_get_main_queue(), ^{
    if (self->_state == nullptr || self->_isTouchInProgress) {
      return;
    }

    self->_heightRevision++;
    self->_state->updateState(
      TypeRichTextInputViewState(self->_heightRevision, selfRef)
    );
  });
}

- (void)invalidateTextLayoutDuringTyping {
  if (!_textView || _isTouchInProgress) {
    return;
  }

  if (_state == nullptr) {
    return;
  }

  _heightRevision++;

  auto selfRef = wrapManagedObjectWeakly(self);
  dispatch_async(dispatch_get_main_queue(), ^{
    if (self->_state == nullptr) {
      return;
    }

    self->_state->updateState(
      TypeRichTextInputViewState(self->_heightRevision, selfRef)
    );
  });
}


#pragma mark - State (ShadowNode → View)

/// Store state reference so we can update it later
- (void)updateState:(State::Shared const &)state
           oldState:(State::Shared const &)oldState
{
  _state =
    std::static_pointer_cast<
      const TypeRichTextInputViewShadowNode::ConcreteState
    >(state);
}

#pragma mark - Events (UITextViewDelegate)

#pragma mark -- Text Changed event
- (void)textViewDidChange:(UITextView *)textView {
  
  if (self.blockEmitting) return;
//  _isHandlingUserInput = YES;
  
  self.isUserTyping = YES;
  self.lastTypingTime = CACurrentMediaTime();
  
  [self updatePlaceholderVisibility];
  
  // Emit JS onChangeText
  auto emitter = [self getEventEmitter];
  if (emitter) {
    emitter->onChangeText({
      .value = std::string(textView.text.UTF8String ?: "")
    });
  }

   // Ensure cursor stays visible when scrolling
   if (textView.scrollEnabled) {
     [textView scrollRangeToVisible:textView.selectedRange];
   }
  
  [self updatePlaceholderVisibilityFromCommand];
  [self invalidateTextLayoutDuringTyping];
  
//  dispatch_async(dispatch_get_main_queue(), ^{
//    self->_isHandlingUserInput = NO;
//  });
}

#pragma mark -- focus / blur event
- (void)textViewDidBeginEditing:(UITextView *)textView {
  auto emitter = [self getEventEmitter];
  if (emitter) {
    emitter->onInputFocus({});
  }
}

- (void)textViewDidEndEditing:(UITextView *)textView {
  auto emitter = [self getEventEmitter];
  if (emitter) {
    emitter->onInputBlur({});
  }
}

#pragma mark -- Selection event

- (void)textViewDidChangeSelection:(UITextView *)textView {
  if (self.blockEmitting) return;
  
  self.isUserTyping = NO;
  
  auto emitter = [self getEventEmitter];
  if (!emitter) {
    return;
  }

  NSRange range = textView.selectedRange;

  emitter->onChangeSelection({
    .start = (int)range.location,
    .end   = (int)(range.location + range.length),
    .text  = std::string(textView.text.UTF8String ?: "")
  });
}

#pragma mark - Paste Image

- (void)emitPasteImageEventWith:(NSString *)uri
                              type:(NSString *)type
                          fileName:(NSString *)fileName
                          fileSize:(NSUInteger)fileSize {
  auto emitter = [self getEventEmitter];
  if (!emitter) {
    return;
  }

  emitter->onPasteImage({
    .uri = std::string(uri.UTF8String),
    .type = std::string(type.UTF8String),
    .fileName = std::string(fileName.UTF8String),
    .fileSize = (double)fileSize,
    .source =
      TypeRichTextInputViewEventEmitter::OnPasteImageSource::Clipboard
  });
}

#pragma mark - Commands

- (void)handleCommand:(const NSString *)commandName
                 args:(const NSArray *)args{
  if (!_commandHandler) {
    return;
  }
  
  if ([commandName isEqualToString:@"focus"]) {
    [_commandHandler focus];
    return;
  }

  if ([commandName isEqualToString:@"blur"]) {
    [_commandHandler blur];
    return;
  }
  
  if ([commandName isEqualToString:@"setText"]) {
      NSString *text = args.count > 0 ? args[0] : @"";
      [_commandHandler setText:text];
      return;
  }

  if ([commandName isEqualToString:@"setSelection"]) {
    if (args.count >= 2) {
      [_commandHandler setSelectionStart:[args[0] integerValue]
                                     end:[args[1] integerValue]];
    }
    return;
  }

  if ([commandName isEqualToString:@"insertTextAt"]) {
    if (args.count >= 3) {
      [_commandHandler insertTextAtStart:[args[0] integerValue]
                                     end:[args[1] integerValue]
                                    text:args[2]];
    }
    return;
  }
}


#pragma mark - UIScrollViewDelegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
  _isTouchInProgress = YES;
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
  if (!decelerate) {
    _isTouchInProgress = NO;
  }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
  _isTouchInProgress = NO;
}

#pragma mark - Placeholder helpers

/// Show placeholder only when text is empty
- (void)updatePlaceholderVisibility {
  _placeholderLabel.hidden = _textView.text.length > 0;
}

#pragma mark - Event emitter

- (std::shared_ptr<TypeRichTextInputViewEventEmitter>)getEventEmitter {
  if (_eventEmitter == nullptr) {
    return nullptr;
  }

  auto const &emitter =
    static_cast<TypeRichTextInputViewEventEmitter const &>(*_eventEmitter);

  return std::make_shared<TypeRichTextInputViewEventEmitter>(emitter);
}

#pragma mark - Helpers

- (BOOL)isTouchInProgress {
  return _isTouchInProgress;
}

- (void)invalidateTextLayoutFromCommand {
  if (_isTouchInProgress) {
    return;
  }

  // layout invalidation after setting text via commands
  [self invalidateTextLayoutDuringTyping];
}

- (void)updatePlaceholderVisibilityFromCommand {
  if (_isTouchInProgress) {
    return;
  }

  // placeholder updation after setting text via commands
  [self updatePlaceholderVisibility];
}

- (void)dispatchSelectionChangeIfNeeded {
  if (self.blockEmitting) {
    return;
  }

  auto emitter = [self getEventEmitter];
  if (!emitter) {
    return;
  }

  UITextView *tv = _textView;
  if (!tv) {
    return;
  }

  NSRange range = tv.selectedRange;

  emitter->onChangeSelection({
    .start = (int)range.location,
    .end   = (int)(range.location + range.length),
    .text  = std::string(tv.text.UTF8String ?: "")
  });
}

//- (BOOL)isHandlingUserInput {
//  return _isHandlingUserInput;
//}

- (BOOL)isDisableImagePasting{
  return _disableImagePasting;
}
@end
