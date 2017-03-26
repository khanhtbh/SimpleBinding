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

/**
 Subcribe for the changes of Object's Properties
 
 @param object Object which is going to be observed
 @param propertyKeys Array of property keys
 @param handleObservedProperties Block that handles the changes of Object's properties
 @return KVOObserver object - the observer
 */
- (KVOObserver *)subcribe:(NSObject *)object forChanges:(NSArray *)propertyKeys handleChanges:(void(^)(NSObject *observedObject, NSDictionary *observedProperties))handleObservedProperties;


/**
 The delegate funtion which define in KVOObserverDelegate protocol

 @param kvoObserver KVOObserver object
 */
- (void)stopListening:(KVOObserver *)kvoObserver;

@end
