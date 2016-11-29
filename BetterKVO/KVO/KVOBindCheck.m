//
//  KVOBindCheck.m
//  BetterKVO
//
//  Created by Khanh Bao Ha Trinh on 11/29/16.
//  Copyright © 2016 Kei. All rights reserved.
//

#import "KVOBindCheck.h"

static KVOBindCheck *checker;

@interface KVOBindCheck()

@property (strong, nonatomic) NSMutableDictionary *keys;

@end

@implementation KVOBindCheck

+ (KVOBindCheck *)checker {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        checker = [[KVOBindCheck alloc] init];
    });
    return checker;
}

- (id)init {
    self = [super init];
    if (self) {
        _keys = [@{} mutableCopy];
    }
    return self;
}

- (void)addKey:(NSString *)key {
    if (!_keys[key]) {
        [self unlockChangeForKey:key];
    }
}

- (BOOL)isKeyLocked:(NSString *)key {
    NSNumber *check = _keys[key];
    return check.boolValue;
}

- (void)removeKey:(NSString *)key {
    [_keys removeObjectForKey:key];
}

- (void)lockChangeForKey:(NSString *)key {
    _keys[key] = @(YES);
}

- (void)unlockChangeForKey:(NSString *)key {
    _keys[key] = @(NO);
}

@end
