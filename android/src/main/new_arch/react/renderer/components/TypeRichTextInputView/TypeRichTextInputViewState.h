#pragma once

#include <folly/dynamic.h>

namespace facebook::react {

class TypeRichTextInputViewState {
public:
  TypeRichTextInputViewState() : forceHeightRecalculationCounter_(0) {}

  // Used by Kotlin to set current text value
  TypeRichTextInputViewState(TypeRichTextInputViewState const &previousState,
                             folly::dynamic data)
      : forceHeightRecalculationCounter_(
            (int)data["forceHeightRecalculationCounter"].getInt()) {};
  folly::dynamic getDynamic() const { return {}; };

  int getForceHeightRecalculationCounter() const;

private:
  const int forceHeightRecalculationCounter_{};
};

} // namespace facebook::react
