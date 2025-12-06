#pragma once

#include "TypeRichTextInputViewMeasurementManager.h"
#include "TypeRichTextInputViewState.h"

#include <react/renderer/components/TypeRichTextInputViewSpec/EventEmitters.h>
#include <react/renderer/components/TypeRichTextInputViewSpec/Props.h>
#include <react/renderer/components/view/ConcreteViewShadowNode.h>

namespace facebook::react {

JSI_EXPORT extern const char TypeRichTextInputViewComponentName[];
/*
 * `ShadowNode` for <TypeRichTextInputView> component.
 */
class TypeRichTextInputViewShadowNode final
    : public ConcreteViewShadowNode<
          TypeRichTextInputViewComponentName, TypeRichTextInputViewProps,
          TypeRichTextInputViewEventEmitter, TypeRichTextInputViewState> {
public:
  using ConcreteViewShadowNode::ConcreteViewShadowNode;

  // This constructor is called when we "update" shadow node, e.g. after
  // updating shadow node's state
  TypeRichTextInputViewShadowNode(ShadowNode const &sourceShadowNode,
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

  // Associates a shared `TypeRichTextInputViewMeasurementManager` with the
  // node.
  void setMeasurementsManager(
      const std::shared_ptr<TypeRichTextInputViewMeasurementManager>
          &measurementsManager);

  void dirtyLayoutIfNeeded();

  Size
  measureContent(const LayoutContext &layoutContext,
                 const LayoutConstraints &layoutConstraints) const override;

private:
  int forceHeightRecalculationCounter_;
  std::shared_ptr<TypeRichTextInputViewMeasurementManager> measurementsManager_;
};
} // namespace facebook::react
