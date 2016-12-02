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

@implementation Binder

- (id)initWithLeftObject:(NSObject *)leftObj
            leftProperty:(NSString *)leftProp
             rightObject:(NSObject *)rightObj
           rightProperty:(NSString *)rightProp
           bindDirection:(BindDirection)direction {
    self = [super init];
    if (self) {
//TODO: Add a checking function to make sure that the properties exists in binding objects
    }
    return self;
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

@end
