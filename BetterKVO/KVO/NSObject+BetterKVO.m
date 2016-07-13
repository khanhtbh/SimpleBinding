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

- (void)addObserver:(NSObject *)observer forProperties:(NSArray *)keyPaths withObserveBlock:(void(^)(NSObject *observedObject, NSDictionary *observedProperties))handleObservedProperties {
    NSMutableDictionary *observers = [[self observers] mutableCopy];
    NSString *hashID = [NSString stringWithFormat:@"%d", observer.hash];
    KVOObserver *addedObserver = observers[hashID];

    if (!addedObserver) {
        addedObserver = [KVOObserver object:observer startListening:self forProperties:keyPaths handleBlock:handleObservedProperties];
    } else {
        [addedObserver addListeningProperties:keyPaths];
    }
    observers[hashID] = addedObserver;
    objc_setAssociatedObject(self, @selector(observers), observers, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)removeObserver:(NSObject *)observer {
    NSMutableDictionary *observers = [[self observers] mutableCopy];
    NSString *hashID = [NSString stringWithFormat:@"%d", observer.hash];
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
    NSString *hashID = [NSString stringWithFormat:@"%d", kvoObserver.observer.hash];
    if (hashID) {
        [observers removeObjectForKey:hashID];
        objc_setAssociatedObject(self, @selector(observers), observers, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
}

@end
