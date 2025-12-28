#import <React/RCTViewComponentView.h>
#import <react/renderer/core/State.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TypeRichTextInputView : RCTViewComponentView <UITextViewDelegate>

@property(nonatomic, assign) BOOL blockEmitting;

- (CGSize)measureSize:(CGFloat)maxWidth;

@end

#ifdef __cplusplus
// INTERNAL — do not use outside native layer
@interface TypeRichTextInputView (Internal)
- (void)emitPasteImageEventWith:(NSString *)uri
                              type:(NSString *)type
                          fileName:(NSString *)fileName
                          fileSize:(NSUInteger)fileSize;
@end
#endif

NS_ASSUME_NONNULL_END
