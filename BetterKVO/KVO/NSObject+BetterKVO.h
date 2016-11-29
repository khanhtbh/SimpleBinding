//
//  NSObject+BetterKVO.h
//  BetterKVO
//
//  Created by Khanh Bao Ha Trinh on 6/21/16.
//  Copyright © 2016 Kei. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (BetterKVO)

- (void)subcribeChangesForProperties:(NSArray *)keyPaths ofObject:(NSObject *)object withHandleBlock:(void(^)(NSObject *observedObject, NSDictionary *observedProperties))handleObservedProperties;

- (void)removeObserver:(NSObject *)observer;

@end
