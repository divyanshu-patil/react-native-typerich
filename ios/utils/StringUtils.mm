//
//  StringUtils.m
//  ReactNativeTypeRich
//
//  Created by Div on 27/12/25.
//

#import "StringUtils.h"

NSString *NSStringFromCppString(const std::string &str) {
  if (str.empty()) {
    return @"";
  }
  return [NSString stringWithUTF8String:str.c_str()];
}
