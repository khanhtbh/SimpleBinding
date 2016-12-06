//
//  NSObject+BetterKVO.h
//  BetterKVO
//
//  Created by Khanh Bao Ha Trinh on 6/21/16.
//  Copyright © 2016 Kei. All rights reserved.
//

#import <Foundation/Foundation.h>

@class KVOObserver;

@interface NSObject (BetterKVO)

- (KVOObserver *)subcribeChangesForProperties:(NSArray *)keyPaths ofObject:(NSObject *)object withHandleBlock:(void(^)(NSObject *observedObject, NSDictionary *observedProperties))handleObservedProperties;

- (NSDictionary *)kvoObservers;

- (NSArray *)observers;

- (void)stopListening:(KVOObserver *)kvoObserver;

@end
