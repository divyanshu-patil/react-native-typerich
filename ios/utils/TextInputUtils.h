//
//  TextUtils.h
//  Pods
//
//  Created by Div on 27/12/25.
//

#import <UIKit/UIKit.h>
#import <react/renderer/components/TypeRichTextInputViewSpec/Props.h>

NS_ASSUME_NONNULL_BEGIN

/// Maps CSS-like fontWeight string → UIFontWeight
UIFontWeight FontWeightFromString(NSString *weight);

UITextAutocapitalizationType AutocapitalizeFromString(NSString *value);

UIKeyboardAppearance KeyboardAppearanceFromEnum(
  facebook::react::TypeRichTextInputViewKeyboardAppearance value
);
NS_ASSUME_NONNULL_END

