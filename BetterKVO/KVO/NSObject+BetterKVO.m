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

#pragma mark - Observer Implementation
- (KVOObserver *)subcribe:(NSObject *)object forChanges:(NSArray *)propertyKeys handleChanges:(void(^)(NSObject *observedObject, NSDictionary *observedProperties))handleObservedProperties {
    
    //Get the KVOObserver which is observing changes of passed object
    NSMutableDictionary *managedObservers = [[self managedKvoObservers] mutableCopy];
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
    
    //Store KVOObserver
    managedObservers[hashID] = addedObserver;
    
    //Set all observers to associcated with subcriber
    objc_setAssociatedObject(self, @selector(managedKvoObservers), managedObservers, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    NSMutableArray *subcribers = [[object subcribers] mutableCopy];
    if ([subcribers indexOfObject:addedObserver] == NSNotFound) {
        [subcribers addObject:addedObserver];
        objc_setAssociatedObject(object, @selector(subcribers), subcribers, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        
    }
    
    return addedObserver;
}


/**
 The Index Dictionary for added KVOObserver object

 @return Dictionary of KVOObserver
 */
- (NSDictionary *)managedKvoObservers {
    NSDictionary *managedObservers = objc_getAssociatedObject(self, @selector(managedKvoObservers));
    if (!managedObservers) {
        managedObservers = @{};
    }
    return managedObservers;
}


/**
 The Array of Subcriber which is subcribing self's changes

 @return Subcriber array
 */
- (NSArray *)subcribers {
    NSArray *subcribers =  objc_getAssociatedObject(self, @selector(subcribers));
    if (!subcribers) {
        subcribers = @[];
        [self swizzleDealloc];
    }
    return subcribers;
}

- (void)stopListening:(KVOObserver *)kvoObserver {
    NSLog(@"Remove kvo object: %@", kvoObserver.observedId);
    NSMutableDictionary *managedObservers = [[self managedKvoObservers] mutableCopy];
    [managedObservers removeObjectForKey:kvoObserver.observedId];
    objc_setAssociatedObject(self, @selector(managedKvoObservers), managedObservers, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

#pragma mark - Swizzle method

- (void)swizzleDealloc {
    if ([NSObject alreadySwizzleForClass:self.class]) return;
    Method newMethod = class_getInstanceMethod(self.class, @selector(newDealloc));
    IMP newMethodImp = method_getImplementation(newMethod);
    const char* returnTypes = method_getTypeEncoding(newMethod);
    
    
    Method originMethod = class_getInstanceMethod(self.class, NSSelectorFromString(@"dealloc"));
    if (originMethod) {
        IMP originalDeallocImp = method_setImplementation(originMethod, newMethodImp);
        [NSObject reserveDeallocImp:originalDeallocImp forClass:self.class];
    } else {
        class_addMethod(self.class, NSSelectorFromString(@"dealloc"), newMethodImp, returnTypes);
    }
}

- (void)newDealloc {
    for (KVOObserver *observer in self.subcribers) {
        
        for (NSString *observingKey in observer.observingKeyPaths) {
            [self removeObserver:observer forKeyPath:observingKey];
        }
        
        observer.observedObject = nil;
        
        [observer removeObserver:observer forKeyPath:OBSERVED_OBJECT_KEY];
    }
    if ([NSObject alreadySwizzleForClass:self.class]) {
        IMP originalDeallocImp = [NSObject originalDeallocImpOfClass:self.class];
        ((void(*)(id,SEL))originalDeallocImp)(self, _cmd);
    }
}

#pragma mark - Dealloc IMP manage

+ (NSMutableDictionary *)reservedDeallocImps {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        reservedDeallocImps = [@{} mutableCopy];
    });
    return reservedDeallocImps;
}

+ (BOOL)alreadySwizzleForClass:(Class)class {
    NSDictionary *_reservedDeallocImps = [NSObject reservedDeallocImps];
    return _reservedDeallocImps[NSStringFromClass(class)];
}

+ (IMP)originalDeallocImpOfClass:(Class)class {
    if ([NSObject alreadySwizzleForClass:class]) {
        NSDictionary *_reservedDeallocImps = [NSObject reservedDeallocImps];
        NSValue *impValue = _reservedDeallocImps[NSStringFromClass(class)];
        return [impValue pointerValue];
    }
    return nil;
}

+ (void)reserveDeallocImp:(IMP)imp forClass:(Class)class {
    NSMutableDictionary *_reservedDeallocImps = [NSObject reservedDeallocImps];
    _reservedDeallocImps[NSStringFromClass(class)] = [NSValue valueWithPointer:imp];

}


@end
