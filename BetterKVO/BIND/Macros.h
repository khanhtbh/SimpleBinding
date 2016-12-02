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
