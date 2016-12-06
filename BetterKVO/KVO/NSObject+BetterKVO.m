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

static IMP originalDeallocImp;

@implementation NSObject (BetterKVO)

//TODO: need to change all logic from saving the observers in observed object to saving them in observer object

- (KVOObserver *)subcribeChangesForProperties:(NSArray *)keyPaths ofObject:(NSObject *)object withHandleBlock:(void(^)(NSObject *observedObject, NSDictionary *observedProperties))handleObservedProperties {
    NSMutableDictionary *kvoObservers = [[self kvoObservers] mutableCopy];
    NSString *hashID = [NSString stringWithFormat:@"%ld", object.hash];
    KVOObserver *addedObserver = kvoObservers[hashID];
    
    if (!addedObserver) {
        addedObserver = [KVOObserver object:self startListening:object forProperties:keyPaths handleBlock:handleObservedProperties];
    } else {
        [addedObserver addListeningProperties:keyPaths];
    }
    kvoObservers[hashID] = addedObserver;
    //Set all observers to associcated with subcriber
    objc_setAssociatedObject(self, @selector(kvoObservers), kvoObservers, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    NSMutableArray *observers = [[object observers] mutableCopy];
    if ([observers indexOfObject:addedObserver] == NSNotFound) {
        [observers addObject:addedObserver];
        objc_setAssociatedObject(object, @selector(observers), observers, OBJC_ASSOCIATION_RETAIN_NONATOMIC);

    }
    
    return addedObserver;
}

- (NSDictionary *)kvoObservers {
    NSDictionary *kvoObservers =  objc_getAssociatedObject(self, @selector(kvoObservers));
    if (!kvoObservers) {
        kvoObservers = @{};
    }
    return kvoObservers;
}

- (NSArray *)observers {
    NSArray *observers =  objc_getAssociatedObject(self, @selector(observers));
    if (!observers) {
        observers = @[];
        [self swizzleDeallocOfObject];
    }
    return observers;
}

- (void)swizzleDeallocOfObject {
    if (originalDeallocImp) return;
    Method newMethod = class_getInstanceMethod(self.class, @selector(newDealloc));
    IMP newMethodImp = method_getImplementation(newMethod);
    const char* returnTypes = method_getTypeEncoding(newMethod);
    
    
    Method originMethod = class_getInstanceMethod(self.class, NSSelectorFromString(@"dealloc"));
    if (originMethod) {
        originalDeallocImp = method_setImplementation(originMethod, newMethodImp);
    } else {
        class_addMethod(self.class, NSSelectorFromString(@"dealloc"), newMethodImp, returnTypes);

    }
}

- (void)newDealloc {
    for (KVOObserver *observer in self.observers) {
        
        for (NSString *observingKey in observer.observingKeyPaths) {
            [self removeObserver:observer forKeyPath:observingKey];
        }
        
        observer.observedObject = nil;
        
        [observer removeObserver:observer forKeyPath:@"observedObject"];
    }
    if (originalDeallocImp) {
        ((void(*)(id,SEL))originalDeallocImp)(self, _cmd);
    }
}

- (void)stopListening:(KVOObserver *)kvoObserver {
    NSMutableDictionary *kvoObservers = [[self kvoObservers] mutableCopy];
    [kvoObservers removeObjectForKey:kvoObserver.observedId];
    objc_setAssociatedObject(self, @selector(kvoObservers), kvoObservers, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}


@end
