#pragma once
#include <TypeRichTextInput/TypeRichTextInputViewState.h>
#include <jsi/jsi.h>
#include <react/renderer/components/TypeRichTextInputViewSpec/EventEmitters.h>
#include <react/renderer/components/TypeRichTextInputViewSpec/Props.h>
#include <react/renderer/components/view/ConcreteViewShadowNode.h>
#include <react/renderer/core/LayoutConstraints.h>

namespace facebook::react {

JSI_EXPORT extern const char TypeRichTextInputViewComponentName[];

/*
 * `ShadowNode` for <TypeRichTextInputView> component.
 */
class TypeRichTextInputViewShadowNode
    : public ConcreteViewShadowNode<
          TypeRichTextInputViewComponentName, TypeRichTextInputViewProps,
          TypeRichTextInputViewEventEmitter, TypeRichTextInputViewState> {
public:
  using ConcreteViewShadowNode::ConcreteViewShadowNode;
  TypeRichTextInputViewShadowNode(const ShadowNodeFragment &fragment,
                                  const ShadowNodeFamily::Shared &family,
                                  ShadowNodeTraits traits);
  TypeRichTextInputViewShadowNode(const ShadowNode &sourceShadowNode,
                                  const ShadowNodeFragment &fragment);
  void dirtyLayoutIfNeeded();
  Size
  measureContent(const LayoutContext &layoutContext,
                 const LayoutConstraints &layoutConstraints) const override;

  static ShadowNodeTraits BaseTraits() {
    auto traits = ConcreteViewShadowNode::BaseTraits();
    traits.set(ShadowNodeTraits::Trait::LeafYogaNode);
    traits.set(ShadowNodeTraits::Trait::MeasurableYogaNode);
    return traits;
  }

private:
  int localForceHeightRecalculationCounter_;
  id setupMockTextInputView_() const;
};

} // namespace facebook::react
