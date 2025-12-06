#include "TypeRichTextInputViewShadowNode.h"

#include "conversions.h"
#include <android/log.h>
#include <folly/json.h>
#include <react/renderer/core/LayoutContext.h>

namespace facebook::react {
extern const char TypeRichTextInputViewComponentName[] =
    "TypeRichTextInputView";
void TypeRichTextInputViewShadowNode::setMeasurementsManager(
    const std::shared_ptr<TypeRichTextInputViewMeasurementManager>
        &measurementsManager) {
  ensureUnsealed();
  measurementsManager_ = measurementsManager;
}

// Mark layout as dirty after state has been updated
// Once layout is marked as dirty, `measureContent` will be called in order to
// recalculate layout
void TypeRichTextInputViewShadowNode::dirtyLayoutIfNeeded() {
  const auto state = this->getStateData();
  const auto counter = state.getForceHeightRecalculationCounter();

  if (forceHeightRecalculationCounter_ != counter) {
    forceHeightRecalculationCounter_ = counter;

    dirtyLayout();
  }
}

Size TypeRichTextInputViewShadowNode::measureContent(
    const LayoutContext &layoutContext,
    const LayoutConstraints &layoutConstraints) const {

  const auto &props = getConcreteProps();

  try {
    folly::dynamic dyn = toDynamic(props);
    std::string json = folly::toJson(dyn);
    __android_log_print(ANDROID_LOG_INFO, "TypeRichCpp",
                        "toDynamic(props) = %s", json.c_str());
  } catch (const std::exception &e) {
    __android_log_print(ANDROID_LOG_ERROR, "TypeRichCpp",
                        "toDynamic() threw: %s", e.what());
  }
  auto size = measurementsManager_->measure(getSurfaceId(), getTag(), props,
                                            layoutConstraints);

  float lineHeight = measurementsManager_->measureSingleLineHeight(props);

  // -------------------------------
  // 1) SINGLE LINE MODE
  // -------------------------------

  __android_log_print(ANDROID_LOG_INFO, "TypeRichCpp", "numberOfLines = %d",
                      props.numberOfLines);
  __android_log_print(ANDROID_LOG_INFO, "TypeRichCpp", "multiline = %s",
                      props.multiline ? "true" : "false");

  if (!props.multiline) {
    size.height = lineHeight;
    return size;
  }

  // -------------------------------
  // 2) MULTILINE WITHOUT LIMIT
  // -------------------------------
  if (props.numberOfLines <= 0) {
    return size; // natural Android height
  }

  // -------------------------------
  // 3) MULTILINE WITH LIMIT
  // auto-grow until X, then clamp
  // -------------------------------
  // Extract padding (React Native provides it inside props.style)
  // Read padding from Fabric LayoutMetrics (RN 0.75+)
  const auto &layoutMetrics = getLayoutMetrics();
  float paddingTop = layoutMetrics.contentInsets.top;
  float paddingBottom = layoutMetrics.contentInsets.bottom;

  float naturalHeight = size.height;

  // Remove padding to calculate pure text height
  float contentHeight = naturalHeight - paddingTop - paddingBottom;
  contentHeight = std::max(0.f, contentHeight);

  // Compute natural line count
  float rawLines = contentHeight / lineHeight;
  int naturalLines = std::max(1, (int)std::floor(rawLines + 0.001f));

  // Clamp based on numberOfLines
  int finalLines = std::min(naturalLines, props.numberOfLines);

  // Reapply padding
  size.height = paddingTop + paddingBottom + lineHeight * finalLines;

  return size;
}

} // namespace facebook::react
