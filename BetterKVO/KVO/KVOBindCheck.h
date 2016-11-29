//
//  KVOBindCheck.h
//  BetterKVO
//
//  Created by Khanh Bao Ha Trinh on 11/29/16.
//  Copyright © 2016 Kei. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KVOBindCheck : NSObject

+ (KVOBindCheck *)checker;

- (void)addKey:(NSString *)key;

- (void)removeKey:(NSString *)key;

- (BOOL)isKeyLocked:(NSString *)key;

- (void)lockChangeForKey:(NSString *)key;

- (void)unlockChangeForKey:(NSString *)key;

@end
