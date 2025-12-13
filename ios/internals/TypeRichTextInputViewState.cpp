#include "TypeRichTextInputViewState.h"

namespace facebook::react {
int TypeRichTextInputViewState::getForceHeightRecalculationCounter() const {
  return forceHeightRecalculationCounter_;
}
std::shared_ptr<void> TypeRichTextInputViewState::getComponentViewRef() const {
  return componentViewRef_;
}
} // namespace facebook::react
