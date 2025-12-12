#import <React/RCTViewComponentView.h>
#import <React/RCTComponentViewFactory.h>

@interface TypeRichTextInputView : RCTViewComponentView
@end

@implementation TypeRichTextInputView


+ (NSString *)componentName
{
  return @"TypeRichTextInputView";
}

- (instancetype)initWithFrame:(CGRect)frame
{
  if (self = [super initWithFrame:frame]) {
    self.backgroundColor = [UIColor clearColor];
  }
  return self;
}

@end
