#pragma once

#include <folly/dynamic.h>
#include <react/renderer/components/TypeRichTextInputViewSpec/Props.h>

namespace facebook::react {

inline folly::dynamic toDynamic(const TypeRichTextInputViewProps &props) {
  folly::dynamic d = folly::dynamic::object();
  d["defaultValue"] = props.defaultValue;
  d["placeholder"] = props.placeholder;
  d["fontSize"] = props.fontSize;
  d["fontWeight"] = props.fontWeight;
  d["fontStyle"] = props.fontStyle;
  d["fontFamily"] = props.fontFamily;
  d["multiline"] = props.multiline;
  d["numberOfLines"] = props.numberOfLines;
  return d;
}

} // namespace facebook::react
