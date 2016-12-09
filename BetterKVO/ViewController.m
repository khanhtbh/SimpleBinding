//
//  ViewController.m
//  BetterKVO
//
//  Created by Khanh Bao Ha Trinh on 6/21/16.
//  Copyright © 2016 Kei. All rights reserved.
//

#import "ViewController.h"
#import "NSObject+BetterKVO.h"
#import "TestModel.h"
#import "TestModelNumber.h"


@interface ViewController ()

@property (weak, nonatomic) IBOutlet UITextField *testTextfield;
@property (weak, nonatomic) IBOutlet UILabel *testLabel;
@property (strong, nonatomic) TestModel *model;
@property (strong, nonatomic) TestModelNumber *model2;

@property (strong, nonatomic) Binder *testBinder;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    _model = [[TestModel alloc] init];
    _model2 = [[TestModelNumber alloc] init];
    __weak typeof(&*self) weakSelf = self;
    
    BIND(_model, stringProperty, <>, _model2, numberProperty)//Two ways binding
    .filterLeft(^BOOL(id property) {//Validate left object property
        return YES;
    })
    .filterRight(^BOOL(id property) {//Validate right object property
        NSNumber *number = property;
        BOOL result = (number.integerValue % 2 == 0);
        NSLog(@"number.integerValue %% 2 = %ld, %d", number.integerValue % 2, result);
        return result;
    })
    .transformLeft(^id(id property) {//transform left object property to new value which will be set to right object property
        NSString *value = property;
        return @(value.length);
    })
    .transformRight(^id(id property){//transform right object property to new value which will be set to left object property
        NSNumber *value = property;
        return [NSString stringWithFormat:@"%ld", value.integerValue];
    })
    .action(^void (id leftProperty, id rightProperty){//call when objects' properties changed. These are raw properties
        NSLog(@"Binding action");
        
        NSLog(@"Model 2 property: %@ - Model 1 property: %@", weakSelf.model2.numberProperty, weakSelf.model.stringProperty);
        
        NSLog(@"Model 1 property: %@ - Model 2 property: %@", weakSelf.model.stringProperty, weakSelf.model2.numberProperty);
    });
    
    
    
    [self subcribeObject:_model
              forChanges:@[@"stringProperty"]
               handleChanges:^(NSObject *observedObject, NSDictionary *observedProperties) {
        NSString *newValue = observedProperties[@"stringProperty"];
        weakSelf.testLabel.text = newValue;
    }];
}

- (IBAction)textFieldValueChanged:(id)sender {
   _model.stringProperty = _testTextfield.text;
}
- (IBAction)randBtnAction:(id)sender {
    NSInteger randValue = arc4random();
    _model2.numberProperty = @(randValue);
}
- (IBAction)removeModel1Action:(id)sender {
    _model = nil;
    _model2 = nil;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
