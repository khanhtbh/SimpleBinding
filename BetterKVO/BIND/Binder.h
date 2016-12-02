//
//  Binder.h
//  BetterKVO
//
//  Created by Khanh Bao Ha Trinh on 12/2/16.
//  Copyright © 2016 Kei. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, BindDirection) {
    BindDirectionToRight = 0,
    BindDirectionToLeft = 1,
    BindDirectionTwoWay = 2,
};

@class Binder;

typedef BOOL (^FilterProperty)(id property);

typedef id (^TransformProperty)(id property);

typedef void (^BindAction)(id leftProperty, id rightProperty);

@interface Binder : NSObject

@property (strong, nonatomic) Binder* (^filterLeft)(FilterProperty);

@property (strong, nonatomic) Binder* (^filterRight)(FilterProperty);

@property (strong, nonatomic) Binder* (^transformLeft)(TransformProperty);

@property (strong, nonatomic) Binder* (^transformRight)(TransformProperty);

@property (strong, nonatomic) void (^action)(BindAction);

- (id)initWithLeftObject:(NSObject *)leftObj
            leftProperty:(NSString *)leftProp
             rightObject:(NSObject *)rightObj
           rightProperty:(NSString *)rightProp
           bindDirection:(BindDirection)direction;

@end
