#import <React/RCTUIManager.h>
#import <React/RCTViewManager.h>

@interface TypeRichTextInputViewManager : RCTViewManager
@end

@implementation TypeRichTextInputViewManager

RCT_EXPORT_MODULE(TypeRichTextInputView)

RCT_EXPORT_VIEW_PROPERTY(defaultValue, NSString)

@end
