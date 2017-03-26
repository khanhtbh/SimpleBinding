//
//  KVOObserver.m
//  BetterKVO
//
//  Created by Khanh Bao Ha Trinh on 6/21/16.
//  Copyright © 2016 Kei. All rights reserved.
//

#import "KVOObserver.h"
#import <objc/runtime.h>

@interface KVOObserver()

@end

@implementation KVOObserver

- (id)init {
    self = [super init];
    if (self) {
        _observer = nil;
        _observingKeyPaths = [@[] mutableCopy];
    }
    return self;
}

- (void)setObserver:(NSObject *)observer {
    _observer = observer;
}

- (void)startListening:(NSObject *)object forProperties:(NSArray *)propertyNames handleBlock:(void (^)(NSObject *, NSDictionary *))handleBlock {
    _handlePropertiesBlock = handleBlock;
    _observedObject = object;
    if (_observedObject) {
        for (NSString *keyPath in propertyNames) {
            if (class_getProperty(_observedObject.class, keyPath.UTF8String)) {
                @try {
                    [_observedObject addObserver:self forKeyPath:keyPath options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionInitial context:nil];
                    [_observingKeyPaths addObject:keyPath];
                } @catch (NSException *exception) {
                    NSLog(@"There was an exception when adding observer for key path %@ - e: %@", keyPath, exception);
                } @finally {
                    NSLog(@"Adding property %@", keyPath);
                }
            }
        }
        _observedId = [NSString stringWithFormat:@"%ld", object.hash];
        [self addObserver:self forKeyPath:OBSERVED_OBJECT_KEY options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionInitial context:nil];
    }
}

- (void)addListeningProperties:(NSArray *)propertyNames {
    for (NSString *keyPath in propertyNames) {
        if ([_observingKeyPaths indexOfObject:keyPath] == NSNotFound && class_getProperty(_observedObject.class, keyPath.UTF8String)) {
            @try {
                [_observedObject addObserver:self forKeyPath:keyPath options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionInitial context:nil];
                [_observingKeyPaths addObject:keyPath];
            } @catch (NSException *exception) {
                NSLog(@"There was an exception when adding observer for key path %@ - e: %@", keyPath, exception);
            } @finally {
                NSLog(@"Adding property %@", keyPath);
            }
        }
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    if ([object isEqual:self]) {
        if ([keyPath isEqualToString:OBSERVED_OBJECT_KEY]) {
            if (!_observedObject) {
                //observer deallocated, remove listener
                if ([_observer respondsToSelector:@selector(stopListening:)]) {
                    [_observer performSelector:@selector(stopListening:) withObject:self];
                }
                
            }
        }
    } else if (_handlePropertiesBlock) {
        @try {
            _handlePropertiesBlock(_observedObject, [_observedObject dictionaryWithValuesForKeys:_observingKeyPaths]);

        } @catch (NSException *exception) {
            NSLog(@"There was an exception when getting observed properties with key path %@ - e: %@", keyPath, exception);
        } @finally {
            
        }
    }
}

- (void)dealloc {
    if (_observedObject) {
        for (NSString *keyPath in _observingKeyPaths) {
            @try {
                [_observedObject removeObserver:self forKeyPath:keyPath];
            } @catch (NSException *exception) {
                NSLog(@"There was an exception when remove observer for key path %@ - e: %@", keyPath, exception);
            } @finally {
                NSLog(@"Remove property %@", keyPath);
            }
        }
        [self removeObserver:self forKeyPath:OBSERVED_OBJECT_KEY];
    }
}

+ (KVOObserver *)object:(NSObject *)object startListening:(NSObject *)observedObject forProperties:(NSArray *)propertyNames handleBlock:(void (^)(NSObject *, NSDictionary *))handleBlock {
    KVOObserver *kvoObject = [[KVOObserver alloc] init];
    kvoObject.observer = object;
    [kvoObject startListening:observedObject forProperties:propertyNames handleBlock:handleBlock];
    
    return kvoObject;
}


@end
