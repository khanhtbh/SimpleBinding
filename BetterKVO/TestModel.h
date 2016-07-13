//
//  TestModel.h
//  BetterKVO
//
//  Created by Khanh Bao Ha Trinh on 6/22/16.
//  Copyright © 2016 Kei. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TestModel : NSObject

@property (strong, nonatomic) NSString *stringProperty;
@property (strong, nonatomic) NSNumber *numberProperty;
@property (nonatomic) NSInteger intProperty;
@property (nonatomic) BOOL boolProperty;

@end
