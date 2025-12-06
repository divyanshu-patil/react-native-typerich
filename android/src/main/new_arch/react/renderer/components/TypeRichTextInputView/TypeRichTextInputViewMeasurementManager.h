#pragma once

#include <react/renderer/components/TypeRichTextInputViewSpec/Props.h>
#include <react/renderer/core/LayoutConstraints.h>
#include <react/utils/ContextContainer.h>

namespace facebook::react {

class TypeRichTextInputViewMeasurementManager {
public:
  TypeRichTextInputViewMeasurementManager(
      const std::shared_ptr<const ContextContainer> &contextContainer)
      : contextContainer_(contextContainer) {}

  Size measure(SurfaceId surfaceId, int viewTag,
               const TypeRichTextInputViewProps &props,
               LayoutConstraints layoutConstraints) const;

private:
  const std::shared_ptr<const ContextContainer> contextContainer_;
};

} // namespace facebook::react
