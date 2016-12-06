//
//  BMN.m
//  BetterKVO
//
//  Created by Khanh Bao Ha Trinh on 12/5/16.
//  Copyright © 2016 Kei. All rights reserved.
//

#import "BMNG.h"

static BMNG *bmng;

@interface BMNG()

@property (strong, nonatomic) NSMutableArray *bindObjects;

@end

@implementation BMNG

+ (BMNG *)bmng {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        bmng = [[BMNG alloc] init];
    });
    return bmng;
}

- (void)addBindObject:(id)bindObject {
    if (!_bindObjects) {
        _bindObjects = [@[] mutableCopy];
    }
    //TODO: Add thread-safe function here
    [_bindObjects addObject:bindObject];
}

- (void)removeBindObject:(id)bindObject {
    [_bindObjects removeObject:bindObject];
}



@end
