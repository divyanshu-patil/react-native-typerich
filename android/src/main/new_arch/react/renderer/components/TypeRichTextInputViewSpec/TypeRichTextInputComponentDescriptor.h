#pragma once

#include "TypeRichTextInputMeasurementManager.h"
#include "TypeRichTextInputShadowNode.h"

#include <react/renderer/core/ConcreteComponentDescriptor.h>

namespace facebook::react {

class TypeRichTextInputComponentDescriptor final
    : public ConcreteComponentDescriptor<TypeRichTextInputShadowNode> {
public:
  TypeRichTextInputComponentDescriptor(
      const ComponentDescriptorParameters &parameters)
      : ConcreteComponentDescriptor(parameters),
        measurementsManager_(
            std::make_shared<TypeRichTextInputMeasurementManager>(
                contextContainer_)) {}

  void adopt(ShadowNode &shadowNode) const override {
    ConcreteComponentDescriptor::adopt(shadowNode);
    auto &editorShadowNode =
        static_cast<TypeRichTextInputShadowNode &>(shadowNode);

    // `TypeRichTextInputShadowNode` uses
    // `TypeRichTextInputMeasurementManager` to provide measurements to Yoga.
    editorShadowNode.setMeasurementsManager(measurementsManager_);
  }

private:
  const std::shared_ptr<TypeRichTextInputMeasurementManager>
      measurementsManager_;
};

} // namespace facebook::react
