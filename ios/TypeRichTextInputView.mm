#import "TypeRichTextInputView.h"

#import <react/renderer/components/TypeRichTextInputViewSpec/EventEmitters.h>
#import <react/renderer/components/TypeRichTextInputViewSpec/Props.h>
#import <react/renderer/components/TypeRichTextInputViewSpec/RCTComponentViewHelpers.h>

#import "RCTFabricComponentsPlugins.h"

using namespace facebook::react;

@interface TypeRichTextInputView () <RCTTypeRichTextInputViewViewProtocol>
@end

@implementation TypeRichTextInputView {
    UIView *_view;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        static const auto defaultProps = std::make_shared<const TypeRichTextInputViewProps>();
        _props = defaultProps;

        _view = [[UIView alloc] init];
        _view.backgroundColor = [UIColor lightGrayColor]; // Visual indicator it's a dummy view

        self.contentView = _view;
    }

    return self;
}

- (void)updateProps:(Props::Shared const &)props oldProps:(Props::Shared const &)oldProps
{
    const auto &oldViewProps = *std::static_pointer_cast<TypeRichTextInputViewProps const>(_props);
    const auto &newViewProps = *std::static_pointer_cast<TypeRichTextInputViewProps const>(props);

    // No-op: just accept props without doing anything
    
    [super updateProps:props oldProps:oldProps];
}

// Dummy command implementations (no-op)
- (void)handleCommand:(NSString *)commandName args:(NSArray *)args
{
    // Commands like focus, blur, setValue, setSelection do nothing
}

@end

Class<RCTComponentViewProtocol> TypeRichTextInputViewCls(void)
{
    return TypeRichTextInputView.class;
}