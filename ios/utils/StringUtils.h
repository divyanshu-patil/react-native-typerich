//
//  StringUtils.h
//  Pods
//
//  Created by Div on 27/12/25.
//

#import <Foundation/Foundation.h>

#ifdef __cplusplus
#include <string>
#endif

NS_ASSUME_NONNULL_BEGIN

/// Convert C++ std::string → NSString
NSString *NSStringFromCppString(const std::string &str);

NS_ASSUME_NONNULL_END
