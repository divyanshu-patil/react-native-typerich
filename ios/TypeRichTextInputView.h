// TypeRichTextInputView.h
#import <React/RCTViewComponentView.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TypeRichTextInputView : RCTViewComponentView

@property(nonatomic, assign) BOOL blockEmitting;

// width → measured size
- (CGSize)measureSize:(CGFloat)maxWidth;

@end

NS_ASSUME_NONNULL_END
