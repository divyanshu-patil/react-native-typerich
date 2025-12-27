//
//  TextUtils.m
//  ReactNativeTypeRich
//
//  Created by Div on 27/12/25.
//

#import "TextUtils.h"

UIFontWeight FontWeightFromString(NSString *weight) {
  if (weight.length == 0) {
    return UIFontWeightRegular;
  }

  if ([weight isEqualToString:@"100"]) return UIFontWeightUltraLight;
  if ([weight isEqualToString:@"200"]) return UIFontWeightThin;
  if ([weight isEqualToString:@"300"]) return UIFontWeightLight;
  if ([weight isEqualToString:@"400"] || [weight isEqualToString:@"normal"])
    return UIFontWeightRegular;
  if ([weight isEqualToString:@"500"]) return UIFontWeightMedium;
  if ([weight isEqualToString:@"600"]) return UIFontWeightSemibold;
  if ([weight isEqualToString:@"700"] || [weight isEqualToString:@"bold"])
    return UIFontWeightBold;
  if ([weight isEqualToString:@"800"]) return UIFontWeightHeavy;
  if ([weight isEqualToString:@"900"]) return UIFontWeightBlack;

  return UIFontWeightRegular;
}

