//
//  BMN.h
//  BetterKVO
//
//  Created by Khanh Bao Ha Trinh on 12/5/16.
//  Copyright © 2016 Kei. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BMNG : NSObject

+ (BMNG *)bmng;

- (void)addBindObject:(id)bindObject;

- (void)removeBindObject:(id)bindObject;

@end
