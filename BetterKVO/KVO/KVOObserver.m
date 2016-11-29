//
//  KVOObserver.m
//  BetterKVO
//
//  Created by Khanh Bao Ha Trinh on 6/21/16.
//  Copyright © 2016 Kei. All rights reserved.
//

#import "KVOObserver.h"
#import "KVOBindCheck.h"

@interface KVOObserver()

@property (weak, nonatomic) NSObject *observedObject;

@property (weak, nonatomic) NSObject *observer;

@property (strong, nonatomic) NSMutableArray *observingKeyPaths;

@property (strong, nonatomic) ObservedPropertiesBlock handlePropertiesBlock;

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
    //Listener for the change of observer property
    [self addObserver:self forKeyPath:@"observer" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionInitial context:nil];
}

- (NSString *)observerId {
    return [NSString stringWithFormat:@"%ld", _observer.hash];
}

- (void)startListening:(NSObject *)object forProperties:(NSArray *)propertyNames handleBlock:(void (^)(NSObject *, NSDictionary *))handleBlock {
    _handlePropertiesBlock = handleBlock;
    _observedObject = object;
    for (NSString *keyPath in propertyNames) {
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

- (void)addListeningProperties:(NSArray *)propertyNames {
    for (NSString *keyPath in propertyNames) {
        if ([_observingKeyPaths indexOfObject:keyPath] == NSNotFound) {
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
        if ([keyPath isEqualToString:@"observer"]) {
            if (!_observer) {
                //observer deallocated, remove listener
                if ([_observedObject respondsToSelector:@selector(stopListening:)]) {
                    [_observedObject performSelector:@selector(stopListening:) withObject:self];
                }
                
            }
        }
    } else if (_handlePropertiesBlock) {
        @try {
            /*
             TODO: 
                Currently this code lock on [Object -> Object] level.
                We need to define key to lock on property level
             */
            NSString *lockKey = [NSString stringWithFormat:@"%ld_%ld", _observedObject.hash, _observer.hash];
            if (![[KVOBindCheck checker] isKeyLocked:lockKey]) {
                //We lock the flow that if _observedObject also subcribe for the changes of _observer's properties
                //So in the KVO Observer of _observedObject, the _observer will be observedObject and _observedObject will be observer
                NSString *key = [NSString stringWithFormat:@"%ld_%ld", _observer.hash, _observedObject.hash];
                [[KVOBindCheck checker] lockChangeForKey:key];
                _handlePropertiesBlock(_observedObject, [_observedObject dictionaryWithValuesForKeys:_observingKeyPaths]);
                [[KVOBindCheck checker] unlockChangeForKey:key];
            }

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
        NSString *key = [NSString stringWithFormat:@"%ld_%ld", _observer.hash, _observedObject.hash]; //Lock observer-->observedObject
        [[KVOBindCheck checker] removeKey:key];
    }
}

+ (KVOObserver *)object:(NSObject *)object startListening:(NSObject *)observedObject forProperties:(NSArray *)propertyNames handleBlock:(void (^)(NSObject *, NSDictionary *))handleBlock {
    KVOObserver *kvoObject = [[KVOObserver alloc] init];
    kvoObject.observer = object;
    [kvoObject startListening:observedObject forProperties:propertyNames handleBlock:handleBlock];
    NSString *key = [NSString stringWithFormat:@"%ld_%ld", object.hash, observedObject.hash]; //Lock observer-->observedObject
    [[KVOBindCheck checker] addKey:key];
    
    return kvoObject;
}

@end
