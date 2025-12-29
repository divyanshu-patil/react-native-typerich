//
//  TypeRichTextInputCommands.m
//  ReactNativeTypeRich
//
//  Created by Div on 29/12/25.
//

#import "TypeRichTextInputCommands.h"
#import "TypeRichTextInputView.h"

@implementation TypeRichTextInputCommands {
  __weak UITextView *_textView;
  __weak TypeRichTextInputView *_owner;
}

- (instancetype)initWithTextView:(UITextView *)textView
                           owner:(TypeRichTextInputView *)owner {
  if (self = [super init]) {
    _textView = textView;
    _owner = owner;
    
    // KEY FIX: Serial queue for commands
    _commandQueue = [[NSOperationQueue alloc] init];
    _commandQueue.maxConcurrentOperationCount = 1;
    _commandQueue.qualityOfService = NSQualityOfServiceUserInteractive;
  }
  return self;
}

#pragma mark - Focus / Blur

/// focus()
- (void)focus
{
  UITextView *tv = _textView;
  if (!tv || tv.isFirstResponder || !tv.editable) {
    return;
  }

  dispatch_async(dispatch_get_main_queue(), ^{
    [tv becomeFirstResponder];
  });
}

/// blur()
- (void)blur
{
  UITextView *tv = _textView;
  if (!tv || !tv.isFirstResponder) {
    return;
  }

  dispatch_async(dispatch_get_main_queue(), ^{
    [tv resignFirstResponder];
  });
}

#pragma mark - Text Commands

/// setText(text)
- (void)setText:(NSString *)text
{
  UITextView *tv = _textView;
  TypeRichTextInputView *owner = _owner;
  if (!tv || !owner) return;

  dispatch_async(dispatch_get_main_queue(), ^{
    if (tv.markedTextRange) return;

    owner.blockEmitting = YES;

    NSString *newText = text ?: @"";

    // Capture cursor offset
    UITextRange *selection = tv.selectedTextRange;
    NSInteger cursorOffset = 0;

    if (selection) {
      cursorOffset =
        [tv offsetFromPosition:tv.beginningOfDocument
                    toPosition:selection.start];
    }

    // Preserve typing attributes
    NSDictionary *attrs = tv.typingAttributes;
    if (!attrs && tv.textStorage.length > 0) {
      attrs = [tv.textStorage attributesAtIndex:0 effectiveRange:NULL];
    }
    if (attrs) {
      tv.typingAttributes = attrs;
    }

    // Replace all text
    UITextRange *fullRange =
      [tv textRangeFromPosition:tv.beginningOfDocument
                     toPosition:tv.endOfDocument];

    [tv replaceRange:fullRange withText:newText];

    // Restore cursor (clamped)
    NSInteger safeOffset = MIN(cursorOffset, newText.length);
    UITextPosition *pos =
      [tv positionFromPosition:tv.beginningOfDocument
                        offset:safeOffset];

    if (pos) {
      tv.selectedTextRange =
        [tv textRangeFromPosition:pos toPosition:pos];
    }

    owner.blockEmitting = NO;

    [owner updatePlaceholderVisibilityFromCommand];
    [owner invalidateTextLayoutFromCommand];
    [owner dispatchSelectionChangeIfNeeded];
  });
}


/// setSelection(start, end)
- (void)setSelectionStart:(NSInteger)start end:(NSInteger)end {
  UITextView *tv = _textView;
  TypeRichTextInputView *owner = _owner;
  if (!tv || !owner) return;

  dispatch_async(dispatch_get_main_queue(), ^{
    if ([owner isTouchInProgress]) return;

    owner.blockEmitting = YES;

    NSInteger length = tv.text.length;
    NSInteger s = MAX(0, MIN(start, length));
    NSInteger e = MAX(s, MIN(end, length));

    tv.selectedRange = NSMakeRange(s, e - s);

    owner.blockEmitting = NO;
    [owner dispatchSelectionChangeIfNeeded];
  });
}

/// insertTextAt(start, end, text)
- (void)insertTextAtStart:(NSInteger)start
                      end:(NSInteger)end
                     text:(NSString *)text
{
  UITextView *tv = _textView;
  TypeRichTextInputView *owner = _owner;
  if (!tv || !owner || !text) return;

  dispatch_async(dispatch_get_main_queue(), ^{
    if ([owner isTouchInProgress]) return;
    if (tv.markedTextRange) return;

    owner.blockEmitting = YES;

    UITextPosition *s =
      [tv positionFromPosition:tv.beginningOfDocument offset:start];
    UITextPosition *e =
      [tv positionFromPosition:tv.beginningOfDocument offset:end];

    if (!s || !e) {
      owner.blockEmitting = NO;
      return;
    }

    UITextRange *range = [tv textRangeFromPosition:s toPosition:e];

    // Preserve formatting
    if (tv.typingAttributes) {
      tv.typingAttributes = tv.typingAttributes;
    }

    [tv replaceRange:range withText:text];

    owner.blockEmitting = NO;

    [owner updatePlaceholderVisibilityFromCommand];
    [owner invalidateTextLayoutFromCommand];
    [owner dispatchSelectionChangeIfNeeded];
  });
}
@end
