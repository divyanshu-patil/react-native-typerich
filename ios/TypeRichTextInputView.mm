// TypeRichTextInputView.mm
#import "TypeRichTextInputView.h"

#ifdef RCT_NEW_ARCH_ENABLED
#import <React/RCTConversions.h>
#import <React/RCTFabricComponentsPlugins.h>
#import <react/renderer/components/TypeRichTextInputViewSpec/ComponentDescriptors.h>
#import <react/renderer/components/TypeRichTextInputViewSpec/EventEmitters.h>
#import <react/renderer/components/TypeRichTextInputViewSpec/Props.h>
#import <react/renderer/components/TypeRichTextInputViewSpec/RCTComponentViewHelpers.h>

using namespace facebook::react;

@interface TypeRichTextInputView () <RCTTypeRichTextInputViewViewProtocol>
@end

#endif

@implementation TypeRichTextInputView

#ifdef RCT_NEW_ARCH_ENABLED

+ (ComponentDescriptorProvider)componentDescriptorProvider
{
  return concreteComponentDescriptorProvider<TypeRichTextInputViewComponentDescriptor>();
}

- (instancetype)initWithFrame:(CGRect)frame
{
  if (self = [super initWithFrame:frame]) {
    static const auto defaultProps = std::make_shared<const TypeRichTextInputViewProps>();
    _props = defaultProps;
  }
  return self;
}

- (void)updateProps:(Props::Shared const &)props oldProps:(Props::Shared const &)oldProps
{
  [super updateProps:props oldProps:oldProps];
}

- (void)handleCommand:(const NSString *)commandName args:(const NSArray *)args
{
  RCTTypeRichTextInputViewHandleCommand(self, commandName, args);
}

- (void)focus
{
  // Implement focus
}

- (void)blur
{
  // Implement blur
}

- (void)setValue:(NSString *)text
{
  // Implement setValue
}

Class<RCTComponentViewProtocol> TypeRichTextInputViewCls(void)
{
  return TypeRichTextInputView.class;
}

#else

- (instancetype)initWithFrame:(CGRect)frame
{
  if (self = [super initWithFrame:frame]) {
    self.backgroundColor = [UIColor clearColor];
  }
  return self;
}

#endif

@end
