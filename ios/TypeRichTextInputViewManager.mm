// TypeRichTextInputViewManager.mm
#import <React/RCTViewManager.h>
#import <React/RCTUIManager.h>

@interface TypeRichTextInputViewManager : RCTViewManager
@end

@implementation TypeRichTextInputViewManager

RCT_EXPORT_MODULE(TypeRichTextInputView)

#ifdef RCT_NEW_ARCH_ENABLED
- (UIView *)view
{
  return [[UIView alloc] init];
}
#else
- (UIView *)view
{
  UIView *view = [[UIView alloc] init];
  view.backgroundColor = [UIColor clearColor];
  return view;
}
#endif

RCT_EXPORT_VIEW_PROPERTY(autoFocus, BOOL)
RCT_EXPORT_VIEW_PROPERTY(editable, BOOL)
RCT_EXPORT_VIEW_PROPERTY(defaultValue, NSString)
RCT_EXPORT_VIEW_PROPERTY(placeholder, NSString)
RCT_EXPORT_VIEW_PROPERTY(multiline, BOOL)

RCT_EXPORT_VIEW_PROPERTY(onInputFocus, RCTDirectEventBlock)
RCT_EXPORT_VIEW_PROPERTY(onInputBlur, RCTDirectEventBlock)
RCT_EXPORT_VIEW_PROPERTY(onChangeText, RCTDirectEventBlock)

@end