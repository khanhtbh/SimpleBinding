//
//  NSData+NSValue.h
//  BetterKVO
//
//  Created by Khanh Bao Ha Trinh on 1/9/17.
//  Copyright © 2017 Kei. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSData (NSValue)

+ (instancetype)dataWithValue:(NSValue *)value;

- (NSValue *)valueWithObjCType:(const char *)type;

@end
