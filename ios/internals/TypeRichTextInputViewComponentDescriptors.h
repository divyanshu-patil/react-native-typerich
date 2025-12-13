#pragma once

#include "TypeRichTextInputViewShadowNode.h"
#include <react/renderer/core/ConcreteComponentDescriptor.h>

namespace facebook::react {

class TypeRichTextInputViewComponentDescriptor final
    : public ConcreteComponentDescriptor<TypeRichTextInputViewShadowNode> {
public:
  TypeRichTextInputViewComponentDescriptor(
      ComponentDescriptorParameters const &parameters)
      : ConcreteComponentDescriptor(parameters) {}
};

} // namespace facebook::react
