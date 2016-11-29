//
//  KVOObserver.h
//  BetterKVO
//
//  Created by Khanh Bao Ha Trinh on 6/21/16.
//  Copyright © 2016 Kei. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^ObservedPropertiesBlock) (NSObject *observedObject, NSDictionary *properties);

@protocol KVOObserverDelegate;

@interface KVOObserver : NSObject

+ (KVOObserver *)object:(NSObject *)object startListening:(NSObject *)object forProperties:(NSArray *)propertyNames handleBlock:(void(^)(NSObject *observedObject, NSDictionary *properties))handleBlock;

- (NSString *)observerId;

- (void)startListening:(NSObject *)object forProperties:(NSArray *)propertyNames handleBlock:(void(^)(NSObject *observedObject, NSDictionary *properties))handleBlock;

- (void)addListeningProperties:(NSArray *)propertyNames;

@end

@protocol KVOObserverDelegate <NSObject>

@optional
- (void)stopListening:(KVOObserver *)observer;

@end
