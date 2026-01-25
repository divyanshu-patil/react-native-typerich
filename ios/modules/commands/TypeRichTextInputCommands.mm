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
    
    // Serial queue for commands
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

/// setText(text) - diff-based with proper cursor tracking, non-undoable
- (void)setText:(NSString *)text
{
    UITextView *tv = _textView;
    TypeRichTextInputView *owner = _owner;
    if (!tv || !owner) return;

    dispatch_async(dispatch_get_main_queue(), ^{
        if (tv.markedTextRange) return;
        
        NSString *newText = text ?: @"";
        NSString *currentText = tv.text ?: @"";
        
        // if text is same, do nothing.
        if ([currentText isEqualToString:newText]) {
            return;
        }

        owner.blockEmitting = YES;
        
        NSRange oldSelection = tv.selectedRange;
        NSRange diffRange = [self calculateDiffRange:currentText newText:newText];
        
        NSInteger newLength = newText.length - (currentText.length - diffRange.length);
        NSString *replacementText = (newLength > 0)
            ? [newText substringWithRange:NSMakeRange(diffRange.location, newLength)]
            : @"";
        
        UITextPosition *start = [tv positionFromPosition:tv.beginningOfDocument offset:diffRange.location];
        UITextPosition *end = [tv positionFromPosition:tv.beginningOfDocument offset:NSMaxRange(diffRange)];
        
        if (start && end) {
            UITextRange *range = [tv textRangeFromPosition:start toPosition:end];
            
            // text replacement
            [tv replaceRange:range withText:replacementText];
            
            // if the user is typing at the end of the selection,
            // and we just inserted text that matches what the system expected,
            // we should only jump the cursor if the JS-provided state differs
            // from the current internal state.
            
            NSInteger delta = replacementText.length - diffRange.length;
            BOOL cursorWasAtEnd = (oldSelection.location == currentText.length);
            
            if (cursorWasAtEnd) {
                tv.selectedRange = NSMakeRange(newText.length, 0);
            } else {
                // If the change happened at or before the cursor, shift it
                if (diffRange.location <= oldSelection.location) {
                    NSInteger newPos = oldSelection.location + delta;
                    newPos = MAX(0, MIN(newPos, newText.length));
                    
                    // IMPORTANT: Only set the range if it's actually different.
                    // Setting selectedRange unnecessarily resets the keyboard's internal state.
                    if (tv.selectedRange.location != newPos) {
                        tv.selectedRange = NSMakeRange(newPos, 0);
                    }
                }
            }
        } else {
            tv.text = newText;
        }
        
        owner.blockEmitting = NO;
        [owner updatePlaceholderVisibilityFromCommand];
        
        if (tv.scrollEnabled) {
            [owner invalidateTextLayoutFromCommand];
            [tv scrollRangeToVisible:tv.selectedRange];
        }
        
        [owner dispatchSelectionChangeIfNeeded];
    });
}

// Helper: Calculate minimal diff range between two strings
- (NSRange)calculateDiffRange:(NSString *)oldText newText:(NSString *)newText {
  NSInteger oldLen = oldText.length;
  NSInteger newLen = newText.length;
  
  // Find common prefix
  NSInteger prefixLen = 0;
  NSInteger minLen = MIN(oldLen, newLen);
  
  while (prefixLen < minLen &&
         [oldText characterAtIndex:prefixLen] == [newText characterAtIndex:prefixLen]) {
    prefixLen++;
  }
  
  // Find common suffix
  NSInteger suffixLen = 0;
  while (suffixLen < (minLen - prefixLen) &&
         [oldText characterAtIndex:(oldLen - suffixLen - 1)] ==
         [newText characterAtIndex:(newLen - suffixLen - 1)]) {
    suffixLen++;
  }
  
  // Return range in old text that needs to be replaced
  NSInteger location = prefixLen;
  NSInteger length = oldLen - prefixLen - suffixLen;
  
  return NSMakeRange(location, length);
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
//    if ([owner isHandlingUserInput]) return;
    
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

- (NSDictionary *)baseAttributesForTextView:(UITextView *)tv {
  if (tv.typingAttributes.count > 0) {
    return tv.typingAttributes;
  }

  if (tv.textStorage.length > 0) {
    return [tv.textStorage attributesAtIndex:0 effectiveRange:nil];
  }

  return @{
    NSFontAttributeName: tv.font ?: [UIFont systemFontOfSize:14],
    NSForegroundColorAttributeName: tv.textColor ?: UIColor.blackColor
  };
}

/// setText() - legacy, buggy and non undoable
//- (void)setText:(NSString *)text
//{
//  UITextView *tv = _textView;
//  TypeRichTextInputView *owner = _owner;
//  if (!tv || !owner) return;
//
//
//    dispatch_async(dispatch_get_main_queue(), ^{
//      if (tv.markedTextRange) return;
//      if (owner.isUserTyping) return;
//
//      NSString *newText = text ?: @"";
//
//      owner.blockEmitting = YES;
//
//      NSTextStorage *storage = tv.textStorage;
//
//      NSRange oldSelection = tv.selectedRange;
//
//      NSDictionary *attrs = [self baseAttributesForTextView:tv];
//
//      NSAttributedString *attrText =
//        [[NSAttributedString alloc] initWithString:newText
//                                        attributes:attrs];
//
//      [storage beginEditing];
//      [storage setAttributedString:attrText];
//      [storage endEditing];
//
//      // Clamp & restore selection
//      NSInteger max = newText.length;
//      NSInteger loc = MIN(oldSelection.location, max);
//      NSInteger len = MIN(oldSelection.length, max - loc);
//      tv.selectedRange = NSMakeRange(loc, len);
//
//      owner.blockEmitting = NO;
//
//      [owner updatePlaceholderVisibilityFromCommand];
//      [owner invalidateTextLayoutFromCommand];
//      [owner dispatchSelectionChangeIfNeeded];
////
////    // Restore cursor (clamped)
////    NSInteger safeOffset = MIN(cursorOffset, newText.length);
////    UITextPosition *pos =
////      [tv positionFromPosition:tv.beginningOfDocument
////                        offset:safeOffset];
////
////    if (pos) {
////      tv.selectedTextRange =
////        [tv textRangeFromPosition:pos toPosition:pos];
////    }
////
////    owner.blockEmitting = NO;
////
////    [owner updatePlaceholderVisibilityFromCommand];
////    [owner invalidateTextLayoutFromCommand];
////    [owner dispatchSelectionChangeIfNeeded];
//  });
//}


/// setText(text) — undoable, cursor-safe, IME-safe
//- (void)setText:(NSString *)text
//{
//  UITextView *tv = _textView;
//  TypeRichTextInputView *owner = _owner;
//  if (!tv || !owner) return;
//
//  dispatch_async(dispatch_get_main_queue(), ^{
//    // Never touch text while IME composing
//    if (tv.markedTextRange) return;
//
//    NSString *newText = text ?: @"";
//    NSString *oldText = tv.text ?: @"";
//
//    // No-op fast path
//    if ([oldText isEqualToString:newText]) {
//      return;
//    }
//
//    owner.blockEmitting = YES;
//
//    // Save selection (cursor)
//    NSRange oldSelection = tv.selectedRange;
//
//    // Compute minimal diff range
//    NSRange replaceRange = DiffRange(oldText, newText);
//
//    NSInteger insertStart = replaceRange.location;
//    NSInteger insertLength =
//      newText.length - (oldText.length - replaceRange.length);
//
//    NSString *insertText =
//      insertLength > 0
//        ? [newText substringWithRange:
//            NSMakeRange(insertStart, insertLength)]
//        : @"";
//
//    // Convert NSRange → UITextRange
//    UITextPosition *start =
//      [tv positionFromPosition:tv.beginningOfDocument
//                        offset:replaceRange.location];
//    UITextPosition *end =
//      [tv positionFromPosition:tv.beginningOfDocument
//                        offset:NSMaxRange(replaceRange)];
//
//    if (!start || !end) {
//      owner.blockEmitting = NO;
//      return;
//    }
//
//    UITextRange *uiRange =
//      [tv textRangeFromPosition:start toPosition:end];
//
//    // THIS IS THE KEY LINE (undo-safe)
//    [tv replaceRange:uiRange withText:insertText];
//
//    // ---- Restore selection correctly ----
//    NSInteger delta = insertText.length - replaceRange.length;
//
//    NSInteger newLoc = oldSelection.location;
//    NSInteger newLen = oldSelection.length;
//
//    if (oldSelection.location > replaceRange.location) {
//      newLoc = MAX(0, newLoc + delta);
//    }
//
//    NSInteger max = tv.text.length;
//    newLoc = MIN(newLoc, max);
//    newLen = MIN(newLen, max - newLoc);
//
//    tv.selectedRange = NSMakeRange(newLoc, newLen);
//
//    owner.blockEmitting = NO;
//
//    [owner updatePlaceholderVisibilityFromCommand];
//    [owner invalidateTextLayoutFromCommand];
//    [owner dispatchSelectionChangeIfNeeded];
//  });
//}

@end
