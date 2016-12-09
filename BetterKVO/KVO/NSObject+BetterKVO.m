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

static NSMutableDictionary *reservedDeallocImps;

@implementation NSObject (BetterKVO)

- (KVOObserver *)subcribeObject:(NSObject *)object forChanges:(NSArray *)propertyKeys handleChanges:(void(^)(NSObject *observedObject, NSDictionary *observedProperties))handleObservedProperties {
    NSMutableDictionary *managedObservers = [[self managedObservers] mutableCopy];
    NSString *hashID = [NSString stringWithFormat:@"%ld", object.hash];
    KVOObserver *addedObserver = managedObservers[hashID];
    
    if (!addedObserver) {
        addedObserver = [KVOObserver object:self startListening:object forProperties:propertyKeys handleBlock:handleObservedProperties];
    } else {
        [addedObserver addListeningProperties:propertyKeys];//Subcribe more properties
        if (handleObservedProperties) { //Update handle block
            addedObserver.handlePropertiesBlock = handleObservedProperties;
        }
    }
    managedObservers[hashID] = addedObserver;
    //Set all observers to associcated with subcriber
    objc_setAssociatedObject(self, @selector(managedObservers), managedObservers, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    NSMutableArray *observers = [[object observers] mutableCopy];
    if ([observers indexOfObject:addedObserver] == NSNotFound) {
        [observers addObject:addedObserver];
        objc_setAssociatedObject(object, @selector(observers), observers, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        
    }
    
    return addedObserver;
}


- (NSDictionary *)managedObservers {
    NSDictionary *managedObservers =  objc_getAssociatedObject(self, @selector(managedObservers));
    if (!managedObservers) {
        managedObservers = @{};
    }
    return managedObservers;
}

- (NSArray *)observers {
    NSArray *observers =  objc_getAssociatedObject(self, @selector(observers));
    if (!observers) {
        observers = @[];
        [self swizzleDealloc];
    }
    return observers;
}

- (void)swizzleDealloc {
    if (!reservedDeallocImps) {
        reservedDeallocImps = [@{} mutableCopy];
    }
    if (reservedDeallocImps[NSStringFromClass(self.class)]) return;
    Method newMethod = class_getInstanceMethod([NSObject class], @selector(newDealloc));
    IMP newMethodImp = method_getImplementation(newMethod);
    const char* returnTypes = method_getTypeEncoding(newMethod);
    
    
    Method originMethod = class_getInstanceMethod(self.class, NSSelectorFromString(@"dealloc"));
    if (originMethod) {
        IMP originalDeallocImp = method_setImplementation(originMethod, newMethodImp);
        reservedDeallocImps[NSStringFromClass(self.class)] = [NSValue valueWithPointer:originalDeallocImp];
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
    if (reservedDeallocImps[NSStringFromClass(self.class)]) {
        IMP originalDeallocImp = [reservedDeallocImps[NSStringFromClass(self.class)] pointerValue];
        ((void(*)(id,SEL))originalDeallocImp)(self, _cmd);
    }
}

- (void)stopListening:(KVOObserver *)kvoObserver {
    NSLog(@"Remove kvo object: %@", kvoObserver.observedId);
    NSMutableDictionary *managedObservers = [[self managedObservers] mutableCopy];
    [managedObservers removeObjectForKey:kvoObserver.observedId];
    objc_setAssociatedObject(self, @selector(managedObservers), managedObservers, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}


@end
