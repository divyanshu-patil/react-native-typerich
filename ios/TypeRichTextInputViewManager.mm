#import <React/RCTViewManager.h>
#import <React/RCTComponentViewFactory.h>
#import "TypeRichTextInputView.h"

@interface TypeRichTextInputViewManager : NSObject <RCTComponentViewProtocol>
@end

@implementation TypeRichTextInputViewManager

+ (NSString *)componentName
{
  return @"TypeRichTextInputView";
}

+ (Class)componentViewClass
{
  return [TypeRichTextInputView class];
}

@end
