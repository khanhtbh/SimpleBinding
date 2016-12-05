//
//  Binder.m
//  BetterKVO
//
//  Created by Khanh Bao Ha Trinh on 12/2/16.
//  Copyright © 2016 Kei. All rights reserved.
//

#import "Binder.h"
#import "Macros.h"
#import "NSObject+BetterKVO.h"
#import <libkern/OSAtomic.h>

@interface Binder()

@property (weak, nonatomic) NSObject *leftHandObject;

@property (strong, nonatomic) NSString *lhObjectProperty;

@property (weak, nonatomic) NSObject *rightHandObject;

@property (strong, nonatomic) NSString *rhObjectProperty;

@property (nonatomic) BindDirection bindDirection;

@property (strong, nonatomic) FilterProperty filterLeftProperty;

@property (strong, nonatomic) FilterProperty filterRightProperty;

@property (strong, nonatomic) TransformProperty transformLeftProperty;

@property (strong, nonatomic) TransformProperty transformRightProperty;

@property (strong, nonatomic) BindAction bindAction;


@end

@implementation Binder {
    #if Is64BitArch
    __volatile int64_t allowToRightWay;
    __volatile int64_t allowToLeftWay;
    #else
    __volatile int32_t allowToRightWay;
    __volatile int32_t allowToLeftWay;
    #endif
}

- (id)initWithLeftObject:(NSObject *)leftObj
            leftProperty:(NSString *)leftProp
             rightObject:(NSObject *)rightObj
           rightProperty:(NSString *)rightProp
           bindDirection:(BindDirection)direction {
    self = [super init];
    if (self) {
        
        //Setup the lock way
        allowToLeftWay = direction == BindDirectionToLeft || direction == BindDirectionTwoWay ? 1 : 0;
        allowToRightWay = direction == BindDirectionToRight || direction == BindDirectionTwoWay ? 1 : 0;
//TODO: Add a checking function to make sure that the properties exists in binding objects
        _leftHandObject = leftObj;
        _lhObjectProperty = leftProp;
        _rightHandObject = rightObj;
        _rhObjectProperty = rightProp;
        _bindDirection = direction;
        weakify(self);
        switch (_bindDirection) {
            case BindDirectionTwoWay: {
                
                [self subcribeChangesForProperties:@[leftProp] ofObject:leftObj withHandleBlock:^(NSObject *observedObject, NSDictionary *observedProperties) {
                    strongify(self);
                    [self handleTheChangesFrom:observedObject];
                }];
                
                [self subcribeChangesForProperties:@[rightProp] ofObject:rightObj withHandleBlock:^(NSObject *observedObject, NSDictionary *observedProperties) {
                    strongify(self);
                    [self handleTheChangesFrom:observedObject];
                }];
            }
                break;
            case BindDirectionToLeft: {
                //Subcribe the change of Right Object to get new value and set it to left object
                [self subcribeChangesForProperties:@[rightProp] ofObject:rightObj withHandleBlock:^(NSObject *observedObject, NSDictionary *observedProperties) {
                    strongify(self);
                    [self handleTheChangesFrom:observedObject];
                }];
            }
                break;
                
            case BindDirectionToRight: {
                //Subcribe the change of Left Object to get new value and set it to Right Object
                [self subcribeChangesForProperties:@[leftProp] ofObject:leftObj withHandleBlock:^(NSObject *observedObject, NSDictionary *observedProperties) {
                    strongify(self);
                    [self handleTheChangesFrom:observedObject];
                }];
            }
                break;
            default:
                break;
        }
        [self setupBlockProperty];
        

    }
    return self;
}

+ (BindDirection)convertBindDirectionFromString:(NSString *)bindString {
    if ([bindString isEqualToString:@"~>"]) {
        return BindDirectionToRight;
    } else if ([bindString isEqualToString:@"<~"]) {
        return BindDirectionToLeft;
    }
    return BindDirectionTwoWay;
}

- (void)setupBlockProperty {
    weakify(self);
    
    _filterLeft = ^Binder* (FilterProperty filterProperty) {
        strongify(self);
        self.filterLeftProperty = filterProperty;
        return self;
    };
    
    _filterRight = ^Binder* (FilterProperty filterProperty) {
        strongify(self);
        self.filterRightProperty = filterProperty;
        return self;
    };
    
    _transformLeft = ^Binder* (TransformProperty transformProperty) {
        strongify(self);
        self.transformLeftProperty = transformProperty;
        return self;
    };
    
    _transformRight = ^Binder* (TransformProperty transformProperty) {
        strongify(self);
        self.transformRightProperty = transformProperty;
        return self;
    };
    
    _action = ^void (BindAction bindAction) {
        strongify(self);
        self.bindAction = bindAction;
    };
}

- (void)handleTheChangesFrom:(NSObject *)object {
    if ([object isEqual:_leftHandObject]) {
        BOOL isToRightAllow = [self getValueForBindDirection:BindDirectionToRight];
        id leftValue = [_leftHandObject valueForKey:_lhObjectProperty];
        if (_filterLeftProperty && _filterLeftProperty(leftValue)) {
            if (isToRightAllow) {
                [self getAndSetValue:NO forBindDirection:BindDirectionToLeft];
                if (_transformLeftProperty) {
                    leftValue = _transformLeftProperty(leftValue);
                }
                [_rightHandObject setValue:leftValue forKey:_rhObjectProperty];
                [self getAndSetValue:YES forBindDirection:BindDirectionToLeft];
            }
        } else {
            if (isToRightAllow) {
                [self getAndSetValue:NO forBindDirection:BindDirectionToLeft];
                if (_transformLeftProperty) {
                    leftValue = _transformLeftProperty(leftValue);
                }
                [_rightHandObject setValue:leftValue forKey:_rhObjectProperty];
                [self getAndSetValue:YES forBindDirection:BindDirectionToLeft];
            }
        }
    } else if ([object isEqual:_rightHandObject]) {
        BOOL isToLeftAllow = [self getValueForBindDirection:BindDirectionToLeft];
        id rightValue = [_rightHandObject valueForKey:_rhObjectProperty];
        if (_filterRightProperty && _filterRightProperty(rightValue)) {
            if (isToLeftAllow) {
                [self getAndSetValue:NO forBindDirection:BindDirectionToRight];
                if (_transformRightProperty) {
                    rightValue = _transformRightProperty(rightValue);
                }
                [_leftHandObject setValue:rightValue forKey:_lhObjectProperty];
                [self getAndSetValue:YES forBindDirection:BindDirectionToRight];
            }
        } else {
            if (isToLeftAllow) {
                [self getAndSetValue:NO forBindDirection:BindDirectionToRight];
                if (_transformRightProperty) {
                    rightValue = _transformRightProperty(rightValue);
                }
                [_leftHandObject setValue:rightValue forKey:_lhObjectProperty];
                [self getAndSetValue:YES forBindDirection:BindDirectionToRight];
            }
        }
    }
    if (_bindAction) {
        _bindAction([_leftHandObject valueForKey:_lhObjectProperty], [_rightHandObject valueForKey:_rhObjectProperty]);
    }
}

#pragma mark Atomic value access

- (BOOL)getValueForBindDirection:(BindDirection)bindDirection {
    if (bindDirection == BindDirectionToRight)
        return allowToRightWay != 0;
    return allowToLeftWay != 0;
}

- (void)setValue:(BOOL)value forBindDirection:(BindDirection)bindDirection {
    if (bindDirection == BindDirectionToRight)
        allowToRightWay = value ? 1 : 0;
    else
        allowToLeftWay = value ? 1: 0;
}

- (BOOL)compareTo:(BOOL)expected andSetValue:(BOOL)value forBindDirection:(BindDirection)bindDirection {
    if (bindDirection == BindDirectionToRight)
#if Is64BitArch
        return OSAtomicCompareAndSwap64((expected ? 1 : 0),
                                        (value ? 1 : 0),
                                        &allowToRightWay);
#else
        return OSAtomicCompareAndSwap32((expected ? 1 : 0),
                                        (value ? 1 : 0),
                                        &allowToRightWay);
#endif
    else
#if Is64BitArch
        return OSAtomicCompareAndSwap64((expected ? 1 : 0),
                                        (value ? 1 : 0),
                                        &allowToLeftWay);
#else
        return OSAtomicCompareAndSwap32((expected ? 1 : 0),
                                        (value ? 1 : 0),
                                        &allowToLeftWay);
#endif
    
}

- (BOOL)getAndSetValue:(BOOL)value forBindDirection:(BindDirection)bindDirection {
    // Optimistic "locking" (spinlock.)
    // If this loop looks weird, here's some Science™:
    // http://stackoverflow.com/a/17732545/366091
    while (true) {
        BOOL current = [self getValueForBindDirection:bindDirection];
        if ([self compareTo:current andSetValue:value forBindDirection:bindDirection]) {
            return current;
        }
    }
}



@end
