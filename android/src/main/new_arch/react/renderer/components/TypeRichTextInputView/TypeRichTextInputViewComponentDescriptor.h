#pragma once

#include "TypeRichTextInputViewMeasurementManager.h"
#include "TypeRichTextInputViewShadowNode.h"

#include <react/renderer/core/ConcreteComponentDescriptor.h>

namespace facebook::react {

class TypeRichTextInputViewComponentDescriptor final
    : public ConcreteComponentDescriptor<TypeRichTextInputViewShadowNode> {
public:
  TypeRichTextInputViewComponentDescriptor(
      const ComponentDescriptorParameters &parameters)
      : ConcreteComponentDescriptor(parameters),
        measurementsManager_(
            std::make_shared<TypeRichTextInputViewMeasurementManager>(
                contextContainer_)) {}

  void adopt(ShadowNode &shadowNode) const override {
    ConcreteComponentDescriptor::adopt(shadowNode);
    auto &editorShadowNode =
        static_cast<TypeRichTextInputViewShadowNode &>(shadowNode);

    // `TypeRichTextInputViewShadowNode` uses
    // `TypeRichTextInputViewMeasurementManager` to provide measurements to
    // Yoga.
    editorShadowNode.setMeasurementsManager(measurementsManager_);
  }

private:
  const std::shared_ptr<TypeRichTextInputViewMeasurementManager>
      measurementsManager_;
};

} // namespace facebook::react
