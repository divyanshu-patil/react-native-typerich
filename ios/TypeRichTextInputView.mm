#import "TypeRichTextInputView.h"

#import <react/renderer/components/TypeRichTextInputViewSpec/ComponentDescriptors.h>
#import <react/renderer/components/TypeRichTextInputViewSpec/EventEmitters.h>
#import <react/renderer/components/TypeRichTextInputViewSpec/Props.h>
#import <react/renderer/components/TypeRichTextInputViewSpec/RCTComponentViewHelpers.h>

#import "RCTFabricComponentsPlugins.h"

using namespace facebook::react;

@interface TypeRichTextInputView () <RCTTypeRichTextInputViewViewProtocol>

@end

@implementation TypeRichTextInputView {
    UIView * _view;
}

+ (ComponentDescriptorProvider)componentDescriptorProvider
{
    return concreteComponentDescriptorProvider<TypeRichTextInputViewComponentDescriptor>();
}

- (instancetype)initWithFrame:(CGRect)frame
{
  if (self = [super initWithFrame:frame]) {
    static const auto defaultProps = std::make_shared<const TypeRichTextInputViewProps>();
    _props = defaultProps;

    _view = [[UIView alloc] init];

    self.contentView = _view;
  }

  return self;
}

- (void)updateProps:(Props::Shared const &)props oldProps:(Props::Shared const &)oldProps
{
    const auto &oldViewProps = *std::static_pointer_cast<TypeRichTextInputViewProps const>(_props);
    const auto &newViewProps = *std::static_pointer_cast<TypeRichTextInputViewProps const>(props);

    [super updateProps:props oldProps:oldProps];
}

Class<RCTComponentViewProtocol> TypeRichTextInputViewCls(void)
{
    return TypeRichTextInputView.class;
}

@end