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

@interface Binder : NSObject

@property (weak, nonatomic) NSObject *leftHandObject;

@property (strong, nonatomic) NSString *lhObjectProperty;

@property (weak, nonatomic) NSObject *rightHandObject;

@property (strong, nonatomic) NSString *rhObjectProperty;

@property (nonatomic) BindDirection bindDirection;

- (id)initWithLeftObject:(NSObject *)leftObj
            leftProperty:(NSString *)leftProp
             rightObject:(NSObject *)rightObj
           rightProperty:(NSString *)rightProp
           bindDirection:(BindDirection)direction;

- (Binder *)filterLeft:(BOOL (^)(id leftProperty))filterLeft;

- (Binder *)filterRight:(BOOL (^)(id rightProperty))filterLeft;

- (Binder *)transformLeft:(id (^)(id leftProperty))transformLeft;

- (Binder *)transformRight:(id (^)(id rightProperty))transformRight;
@end
