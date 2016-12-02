//
//  BindMacros.h
//  BetterKVO
//
//  Created by Khanh Bao Ha Trinh on 12/2/16.
//  Copyright © 2016 Kei. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Binder.h"

#define VALID_BIND_DIRECTION(direction) assert([direction isEqualToString:@"~>"] || [direction isEqualToString:@"<~"] || [direction isEqualToString:@"<>"])

static inline BindDirection getDirection(NSString *direction) {
    VALID_BIND_DIRECTION(direction);
    if ([direction isEqualToString:@"~>"]) {
        return BindDirectionToRight;
    } else if ([direction isEqualToString:@"<~"]) {
        return BindDirectionToLeft;
    }
    return BindDirectionTwoWay;
}

static inline Binder *CREATE_BINDER(NSObject *leftObj, NSString *leftObjProperty, NSString *direction, NSObject *rightObj, NSString *rightObjProperty) {
    BindDirection bindDirection = getDirection(direction);
    Binder *binder = [[Binder alloc] initWithLeftObject:leftObj leftProperty:leftObjProperty rightObject:rightObj rightProperty:rightObjProperty bindDirection:bindDirection];
    return binder;
}

#define BIND(LeftObj, LeftObjProperty, Direction, RightObj, RightObjProperty)\
CREATE_BINDER(LeftObj, @(#LeftObjProperty), @(#Direction), RightObj, @(#RightObjProperty))\
