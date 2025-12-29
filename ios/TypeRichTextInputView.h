#import <React/RCTViewComponentView.h>
#import <react/renderer/core/State.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TypeRichTextInputView : RCTViewComponentView <UITextViewDelegate>

@property(nonatomic, assign) BOOL blockEmitting;

- (CGSize)measureSize:(CGFloat)maxWidth;

// events
- (void)emitPasteImageEventWith:(NSString *)uri
                           type:(NSString *)type
                       fileName:(NSString *)fileName
                       fileSize:(NSUInteger)fileSize;

// commands
- (void)handleCommand:(NSString *)commandName
                 args:(NSArray *)args;

// helpers used by commands
- (BOOL)isTouchInProgress;
//- (BOOL)isHandlingUserInput;
- (void)invalidateTextLayoutFromCommand;
- (void)updatePlaceholderVisibilityFromCommand;
- (void)dispatchSelectionChangeIfNeeded;

@end
NS_ASSUME_NONNULL_END
