#pragma once
#include <TypeRichTextInput/TypeRichTextInputViewShadowNode.h>
#include <react/debug/react_native_assert.h>
#include <react/renderer/components/TypeRichTextInputViewSpec/Props.h>
#include <react/renderer/core/ConcreteComponentDescriptor.h>

namespace facebook::react {
class TypeRichTextInputViewComponentDescriptor final
    : public ConcreteComponentDescriptor<TypeRichTextInputViewShadowNode> {
public:
  using ConcreteComponentDescriptor::ConcreteComponentDescriptor;
  void adopt(ShadowNode &shadowNode) const override {
    react_native_assert(
        dynamic_cast<TypeRichTextInputViewShadowNode *>(&shadowNode));
    ConcreteComponentDescriptor::adopt(shadowNode);
  }
};

} // namespace facebook::react
