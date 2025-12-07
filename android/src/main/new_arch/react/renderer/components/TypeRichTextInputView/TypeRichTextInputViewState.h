#pragma once

#include <folly/dynamic.h>

namespace facebook::react {

class TypeRichTextInputViewState {
public:
  // match to declaration order
  TypeRichTextInputViewState()
      : lineCount(1), forceHeightRecalculationCounter_(0) {}

  // Used by Kotlin to set current text value
  TypeRichTextInputViewState(TypeRichTextInputViewState const &previousState,
                             folly::dynamic data)
      : lineCount((int)data["lineCount"].getInt()),
        forceHeightRecalculationCounter_(
            (int)data["forceHeightRecalculationCounter"].getInt()) {};
  folly::dynamic getDynamic() const { return {}; };

  int lineCount;
  int getForceHeightRecalculationCounter() const;

private:
  const int forceHeightRecalculationCounter_{};
};

} // namespace facebook::react
