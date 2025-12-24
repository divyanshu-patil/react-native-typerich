#import "TypeRichTextInputViewShadowNode.h"
#import "CoreText/CoreText.h"
#import <TypeRichTextInputView.h>
#import <React/RCTShadowView+Layout.h>
#import <react/utils/ManagedObjectWrapper.h>
#import <yoga/Yoga.h>

namespace facebook::react {

extern const char TypeRichTextInputViewComponentName[] =
    "TypeRichTextInputView";

TypeRichTextInputViewShadowNode::TypeRichTextInputViewShadowNode(
    const ShadowNodeFragment &fragment, const ShadowNodeFamily::Shared &family,
    ShadowNodeTraits traits)
    : ConcreteViewShadowNode(fragment, family, traits) {
  localForceHeightRecalculationCounter_ = 0;
}

// mock input is used for the first measure calls that need to be done when the
// real input isn't defined yet
id TypeRichTextInputViewShadowNode::setupMockTextInputView_() const {
  // it's rendered far away from the viewport
  const int veryFarAway = 20000;
  const int mockSize = 1000;
  TypeRichTextInputView *mockTextInputView_ = [[TypeRichTextInputView alloc]
      initWithFrame:(CGRectMake(veryFarAway, veryFarAway, mockSize, mockSize))];
  const auto props = this->getProps();
  mockTextInputView_.blockEmitting = YES;
  [mockTextInputView_ updateProps:props oldProps:nullptr];
  return mockTextInputView_;
}

TypeRichTextInputViewShadowNode::TypeRichTextInputViewShadowNode(
    const ShadowNode &sourceShadowNode, const ShadowNodeFragment &fragment)
    : ConcreteViewShadowNode(sourceShadowNode, fragment) {
  dirtyLayoutIfNeeded();
}

void TypeRichTextInputViewShadowNode::dirtyLayoutIfNeeded() {
  const auto state = this->getStateData();
  const int receivedCounter = state.getForceHeightRecalculationCounter();

  if (receivedCounter > localForceHeightRecalculationCounter_) {
    localForceHeightRecalculationCounter_ = receivedCounter;
    YGNodeMarkDirty(&yogaNode_);
  }
}

Size TypeRichTextInputViewShadowNode::measureContent(
    const LayoutContext &layoutContext,
    const LayoutConstraints &layoutConstraints) const {
  const auto state = this->getStateData();
  const auto componentRef = state.getComponentViewRef();
  RCTInternalGenericWeakWrapper *weakWrapper =
      (RCTInternalGenericWeakWrapper *)unwrapManagedObject(componentRef);

  if (weakWrapper != nullptr) {
    id componentObject = weakWrapper.object;
    TypeRichTextInputView *typedComponentObject =
        (TypeRichTextInputView *)componentObject;

    if (typedComponentObject != nullptr) {
      __block CGSize estimatedSize;

      // synchronously dispatch to main thread if needed
      if ([NSThread isMainThread]) {
        estimatedSize = [typedComponentObject
            measureSize:layoutConstraints.maximumSize.width];
      } else {
        dispatch_sync(dispatch_get_main_queue(), ^{
          estimatedSize = [typedComponentObject
              measureSize:layoutConstraints.maximumSize.width];
        });
      }

      return {estimatedSize.width,
              MIN(estimatedSize.height, layoutConstraints.maximumSize.height)};
    }
  } else {
    __block CGSize estimatedSize;

    // synchronously dispatch to main thread if needed
    if ([NSThread isMainThread]) {
      TypeRichTextInputView *mockTextInputView = setupMockTextInputView_();
      estimatedSize =
          [mockTextInputView measureSize:layoutConstraints.maximumSize.width];
    } else {
      dispatch_sync(dispatch_get_main_queue(), ^{
        TypeRichTextInputView *mockTextInputView = setupMockTextInputView_();
        estimatedSize =
            [mockTextInputView measureSize:layoutConstraints.maximumSize.width];
      });
    }

    return {estimatedSize.width,
            MIN(estimatedSize.height, layoutConstraints.maximumSize.height)};
  }

  return Size();
}

} // namespace facebook::react
