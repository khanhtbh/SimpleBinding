//
//  NSObject+BetterKVO.m
//  BetterKVO
//
//  Created by Khanh Bao Ha Trinh on 6/21/16.
//  Copyright © 2016 Kei. All rights reserved.
//

#import "NSObject+BetterKVO.h"
#import <objc/runtime.h>
#import "KVOObserver.h"

@implementation NSObject (BetterKVO)

- (void)subcribeChangesForProperties:(NSArray *)keyPaths ofObject:(NSObject *)object withHandleBlock:(void(^)(NSObject *observedObject, NSDictionary *observedProperties))handleObservedProperties {
    NSMutableDictionary *observers = [[object observers] mutableCopy];
    NSString *hashID = [NSString stringWithFormat:@"%ld", self.hash];
    KVOObserver *addedObserver = observers[hashID];
    
    if (!addedObserver) {
        addedObserver = [KVOObserver object:self startListening:object forProperties:keyPaths handleBlock:handleObservedProperties];
    } else {
        [addedObserver addListeningProperties:keyPaths];
    }
    observers[hashID] = addedObserver;
    objc_setAssociatedObject(object, @selector(observers), observers, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)removeObserver:(NSObject *)observer {
    NSMutableDictionary *observers = [[self observers] mutableCopy];
    NSString *hashID = [NSString stringWithFormat:@"%ld", observer.hash];
    KVOObserver *addedObserver = observers[hashID];
    [self stopListening:addedObserver];
}

- (id)observers {
    NSMutableDictionary *observers =  [objc_getAssociatedObject(self, @selector(observers)) mutableCopy];
    if (!observers) {
        observers = [@{} mutableCopy];
        objc_setAssociatedObject(self, @selector(observers), observers, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return observers;
}

- (void)stopListening:(KVOObserver *)kvoObserver {
    NSMutableDictionary *observers = [[self observers] mutableCopy];
    NSString *observerId = kvoObserver.observerId;
    if (observerId) {
        [observers removeObjectForKey:observerId];
        objc_setAssociatedObject(self, @selector(observers), observers, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
}

@end
