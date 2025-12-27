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
#import "utils/TextUtils.h"

using namespace facebook::react;

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

#pragma mark - Base Props
  
  // Text value (controlled)
  if (!oldPropsPtr || newProps.value != oldPropsPtr->value) {
    _textView.text = NSStringFromCppString(newProps.value);
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

    _textView.attributedText = attributedText;

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
