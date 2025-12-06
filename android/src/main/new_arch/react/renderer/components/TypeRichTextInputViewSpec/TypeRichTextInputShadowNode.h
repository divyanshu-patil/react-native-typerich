#pragma once

#include "TypeRichTextInputMeasurementManager.h"
#include "TypeRichTextInputState.h"

#include <react/renderer/components/TypeRichTextInputViewSpec/EventEmitters.h>
#include <react/renderer/components/TypeRichTextInputViewSpec/Props.h>
#include <react/renderer/components/view/ConcreteViewShadowNode.h>

namespace facebook::react {

JSI_EXPORT extern const char TypeRichTextInputComponentName[];
/*
 * `ShadowNode` for <TypeRichTextInputView> component.
 */
class TypeRichTextInputShadowNode final
    : public ConcreteViewShadowNode<
          TypeRichTextInputComponentName, TypeRichTextInputViewProps,
          TypeRichTextInputViewEventEmitter, TypeRichTextInputState> {
public:
  using ConcreteViewShadowNode::ConcreteViewShadowNode;

  // This constructor is called when we "update" shadow node, e.g. after
  // updating shadow node's state
  TypeRichTextInputShadowNode(ShadowNode const &sourceShadowNode,
                              ShadowNodeFragment const &fragment)
      : ConcreteViewShadowNode(sourceShadowNode, fragment) {
    dirtyLayoutIfNeeded();
  }

  static ShadowNodeTraits BaseTraits() {
    auto traits = ConcreteViewShadowNode::BaseTraits();
    traits.set(ShadowNodeTraits::Trait::LeafYogaNode);
    traits.set(ShadowNodeTraits::Trait::MeasurableYogaNode);
    return traits;
  }

  // Associates a shared `TypeRichTextInputMeasurementManager` with the node.
  void setMeasurementsManager(
      const std::shared_ptr<TypeRichTextInputMeasurementManager>
          &measurementsManager);

  void dirtyLayoutIfNeeded();

  Size
  measureContent(const LayoutContext &layoutContext,
                 const LayoutConstraints &layoutConstraints) const override;

private:
  int forceHeightRecalculationCounter_;
  std::shared_ptr<TypeRichTextInputMeasurementManager> measurementsManager_;
};
} // namespace facebook::react
