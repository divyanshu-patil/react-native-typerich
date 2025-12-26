#import <React/RCTViewComponentView.h>
#import <react/renderer/core/State.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TypeRichTextInputView : RCTViewComponentView <UITextViewDelegate>

@property(nonatomic, assign) BOOL blockEmitting;

- (CGSize)measureSize:(CGFloat)maxWidth;

@end

NS_ASSUME_NONNULL_END
