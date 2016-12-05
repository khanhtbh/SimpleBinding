//
//  Header.h
//  BetterKVO
//
//  Created by Khanh Bao Ha Trinh on 12/2/16.
//  Copyright © 2016 Kei. All rights reserved.
//

#import <Foundation/Foundation.h>

/* Pointer reference */

#define weakify(var) __weak typeof(var) AHKWeak_##var = var;

#define strongify(var) \
_Pragma("clang diagnostic push") \
_Pragma("clang diagnostic ignored \"-Wshadow\"") \
__strong typeof(var) var = AHKWeak_##var; \
_Pragma("clang diagnostic pop")


/* CPU Architecture */

#define Is64BitArch __LP64__ ||\
(TARGET_OS_EMBEDDED && !TARGET_OS_IPHONE) ||\
TARGET_OS_WIN32 || NS_BUILD_32_LIKE_64
