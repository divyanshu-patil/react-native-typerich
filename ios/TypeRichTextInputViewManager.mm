#import <React/RCTViewManager.h>
#import <React/RCTUIManager.h>
#import "RCTFabricComponentsPlugins.h"

@interface TypeRichTextInputViewManager : RCTViewManager
@end

@implementation TypeRichTextInputViewManager

RCT_EXPORT_MODULE(TypeRichTextInputView)

+ (BOOL)requiresMainQueueSetup
{
    return NO;
}

- (UIView *)view
{
    // For Paper (old architecture) - return a simple UIView
    UIView *view = [[UIView alloc] init];
    view.backgroundColor = [UIColor lightGrayColor];
    return view;
}

@end

Class<RCTComponentViewProtocol> TypeRichTextInputViewCls(void);