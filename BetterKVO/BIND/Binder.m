//
//  Binder.m
//  BetterKVO
//
//  Created by Khanh Bao Ha Trinh on 12/2/16.
//  Copyright © 2016 Kei. All rights reserved.
//

#import "Binder.h"
#import "NSObject+BetterKVO.h"

@implementation Binder

- (id)initWithLeftObject:(NSObject *)leftObj leftProperty:(NSString *)leftProp rightObject:(NSObject *)rightObj rightProperty:(NSString *)rightProp bindDirection:(BindDirection)direction {
    self = [super init];
    if (self) {
//TODO: Add a checking function to make sure that the properties exists in binding objects
    }
    return self;
}



@end
