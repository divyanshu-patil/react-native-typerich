#import "TypeRichTextInputView.h"

// Fabric / Codegen
#import <react/renderer/components/TypeRichTextInputViewSpec/Props.h>
#import <react/renderer/components/TypeRichTextInputViewSpec/RCTComponentViewHelpers.h>
#import "cpp/TypeRichTextInputViewComponentDescriptor.h"
#import "RCTFabricComponentsPlugins.h"

// React utils
#import <React/RCTConversions.h>
#import <react/utils/ManagedObjectWrapper.h>

using namespace facebook::react;

#pragma mark - Helpers

/// Convert C++ std::string (from Props) → NSString
static inline NSString *NSStringFromCppString(const std::string &str) {
  return str.empty() ? @"" : [NSString stringWithUTF8String:str.c_str()];
}

#pragma mark - Private interface

@interface TypeRichTextInputView () <
  RCTTypeRichTextInputViewViewProtocol,
  UITextViewDelegate
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

    // ---------------------------
    // UITextView FIRST
    // ---------------------------
    _textView = [[UITextView alloc] initWithFrame:CGRectZero];
    _textView.delegate = self;
    _textView.scrollEnabled = YES;
    _textView.backgroundColor = UIColor.clearColor;
    _textView.textContainerInset = UIEdgeInsetsZero;
    _textView.textContainer.lineFragmentPadding = 0;

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
    
    // Also set initial font in initWithFrame if not already done:
    // In initWithFrame method, after creating _textView and _placeholderLabel:
    UIFont *defaultFont = [UIFont systemFontOfSize:14];
    _textView.font = defaultFont;
    _placeholderLabel.font = defaultFont;

    // ---------------------------
    // Fabric contentView
    // ---------------------------
    self.contentView = _textView;

    [self updatePlaceholderVisibility];
  }
  return self;
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

  // ---------------------------
  // Text value (controlled)
  // ---------------------------
  if (!oldPropsPtr || newProps.value != oldPropsPtr->value) {
    _textView.text = NSStringFromCppString(newProps.value);
  }

  // defaultValue (mount only)
  if (oldProps == nullptr && !newProps.defaultValue.empty()) {
    _textView.text = NSStringFromCppString(newProps.defaultValue);
  }

  // ---------------------------
  // Placeholder
  // ---------------------------
  if (!oldPropsPtr || newProps.placeholder != oldPropsPtr->placeholder) {
    _placeholderLabel.text =
      NSStringFromCppString(newProps.placeholder);
    [self updatePlaceholderVisibility];
  }

  // placeholder text color
  if (!oldPropsPtr || newProps.placeholderTextColor != oldPropsPtr->placeholderTextColor) {
    if (isColorMeaningful(newProps.placeholderTextColor)) {
      _placeholderColor =
        RCTUIColorFromSharedColor(newProps.placeholderTextColor);
      _placeholderLabel.textColor = _placeholderColor;
    }
  }


  // ---------------------------
  // Editable
  // ---------------------------
  if (!oldPropsPtr || newProps.editable != oldPropsPtr->editable) {
    _textView.editable = newProps.editable;
  }

  // ---------------------------
  // Text color
  // ---------------------------
  if (!oldPropsPtr || newProps.color != oldPropsPtr->color) {
    if (isColorMeaningful(newProps.color)) {
      _textView.textColor = RCTUIColorFromSharedColor(newProps.color);
    }
  }

  // ---------------------------
  // Font
  // ---------------------------
  // Check if font props changed
  BOOL fontChanged = !oldPropsPtr ||
                     newProps.fontSize != oldPropsPtr->fontSize ||
                     newProps.fontFamily != oldPropsPtr->fontFamily;

  if (fontChanged) {
    // Extract fontSize (use 14 as default if not set or is 0)
    CGFloat size = newProps.fontSize > 0 ? (CGFloat)newProps.fontSize : 14.0;
    
    // Extract fontFamily
    NSString *family = nil;
    if (!newProps.fontFamily.empty()) {
      family = NSStringFromCppString(newProps.fontFamily);
    }

    // Create font
    UIFont *font = nil;
    if (family) {
      font = [UIFont fontWithName:family size:size];
      // Fallback if custom font not found
      if (!font) {
        NSLog(@"Font '%@' not found, using system font", family);
        font = [UIFont systemFontOfSize:size];
      }
    } else {
      font = [UIFont systemFontOfSize:size];
    }

    // Apply to both textView and placeholder
    _textView.font = font;
    _placeholderLabel.font = font;
    
    NSLog(@"Font updated: size=%.1f, family=%@", size, family ?: @"system");
  }

  
  // ---------------------------
  // Auto focus
  // ---------------------------
  if (oldProps == nullptr && newProps.autoFocus) {
    [_textView becomeFirstResponder];
  }

  // Update placeholder visibility
  [self updatePlaceholderVisibility];
  [self invalidateTextLayout];
  [super updateProps:props oldProps:oldProps];
}

#pragma mark - Measurement (ShadowNode → View)

/// Fabric calls this to measure height for given width
- (CGSize)measureSize:(CGFloat)maxWidth {
  UIEdgeInsets inset = _textView.textContainerInset;

  CGFloat availableWidth =
    MAX(0, maxWidth - inset.left - inset.right);

  CGSize fitting =
    [_textView sizeThatFits:
      CGSizeMake(availableWidth, CGFLOAT_MAX)];

  // IMPORTANT:
  // sizeThatFits already includes textContainerInset
  CGFloat height = ceil(fitting.height);

  return CGSizeMake(maxWidth, height);
}

#pragma mark - Layout invalidation

/// Forces UITextView to re-layout text and notifies Fabric to re-measure
- (void)invalidateTextLayout {
  if (!_textView) {
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
  _state->updateState(
    TypeRichTextInputViewState(_heightRevision, selfRef)
  );
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

#pragma mark - UITextViewDelegate

- (void)textViewDidChange:(UITextView *)textView {
  [self updatePlaceholderVisibility];
  // ---------------------------
  // Emit JS onChangeText
  // ---------------------------
  auto emitter = [self getEventEmitter];
  if (emitter) {
    emitter->onChangeText({
      .value = std::string(textView.text.UTF8String ?: "")
    });
  }

  // Update placeholder
  [self updatePlaceholderVisibility];

  [self invalidateTextLayout];
}

#pragma mark - Placeholder helpers

/// Show placeholder only when text is empty
- (void)updatePlaceholderVisibility {
  _placeholderLabel.hidden = _textView.text.length > 0;
}

/// Layout placeholder to match text position
//- (void)layoutSubviews {
//  [super layoutSubviews];
//
//  CGFloat width = _textView.bounds.size.width;
//  CGSize size =
//    [_placeholderLabel sizeThatFits:
//      CGSizeMake(width, CGFLOAT_MAX)];
//
//  _placeholderLabel.frame =
//    CGRectMake(0, 0, width, size.height);
//}

#pragma mark - Event emitter

- (std::shared_ptr<TypeRichTextInputViewEventEmitter>)getEventEmitter {
  if (_eventEmitter == nullptr) {
    return nullptr;
  }

  auto const &emitter =
    static_cast<TypeRichTextInputViewEventEmitter const &>(*_eventEmitter);

  return std::make_shared<TypeRichTextInputViewEventEmitter>(emitter);
}

@end
