#import "TypeRichTextInputView.h"

#import <react/renderer/components/TypeRichTextInputViewSpec/Props.h>
#import <react/renderer/components/TypeRichTextInputViewSpec/RCTComponentViewHelpers.h>
#import "cpp/TypeRichTextInputViewComponentDescriptor.h"
#import "RCTFabricComponentsPlugins.h"
#import <React/RCTLog.h>

using namespace facebook::react;

@interface TypeRichTextInputView () <RCTTypeRichTextInputViewViewProtocol>
@end

@implementation TypeRichTextInputView {
  UIView *_content;
}

+ (ComponentDescriptorProvider)componentDescriptorProvider {
  return concreteComponentDescriptorProvider<
      TypeRichTextInputViewComponentDescriptor>();
}

- (instancetype)initWithFrame:(CGRect)frame {
  if (self = [super initWithFrame:frame]) {
    _content = [[UIView alloc] init];
    _content.backgroundColor = UIColor.clearColor;
    self.contentView = _content;

    self.blockEmitting = NO;
  }
  return self;
}


- (void)updateProps:(Props::Shared const &)props
           oldProps:(Props::Shared const &)oldProps {
  RCTLogInfo(
    @"[TypeRichTextInput] Hello"
  );
  [super updateProps:props oldProps:oldProps];
}

- (CGSize)measureSize:(CGFloat)maxWidth {
  // minimal deterministic height
  return CGSizeMake(maxWidth, 40);
}

@end

Class<RCTComponentViewProtocol> TypeRichTextInputViewCls(void) {
  return TypeRichTextInputView.class;
}
