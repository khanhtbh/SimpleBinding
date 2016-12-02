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


@interface ViewController ()

@property (weak, nonatomic) IBOutlet UITextField *testTextfield;
@property (weak, nonatomic) IBOutlet UILabel *testLabel;
@property (strong, nonatomic) TestModel *model;
@property (strong, nonatomic) TestModel *model2;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    _model = [[TestModel alloc] init];
    _model2 = [[TestModel alloc] init];
    __weak typeof(&*self) weakSelf = self;
    
    Binder *bindObject = BIND(_model, stringProperty, ~>, _model2, stringProperty);
    
    [_model2 subcribeChangesForProperties:@[@"stringProperty"] ofObject:_model withHandleBlock:^(NSObject *observedObject, NSDictionary *observedProperties) {
        NSString *stringProperty = observedProperties[@"stringProperty"];
        if (stringProperty && stringProperty.class != [NSNull class]) {
            weakSelf.model2.stringProperty = [NSString stringWithFormat:@"model 2 - %@", stringProperty];
            NSLog(@"Model 2 property: %@ - Model 1 property: %@", weakSelf.model2.stringProperty, weakSelf.model.stringProperty);
        }
    }];
    
    
    
    [_model subcribeChangesForProperties:@[@"stringProperty"] ofObject:_model2 withHandleBlock:^(NSObject *observedObject, NSDictionary *observedProperties) {
        NSString *stringProperty = observedProperties[@"stringProperty"];
        if (stringProperty && stringProperty.class != [NSNull class]) {
            weakSelf.model.stringProperty = [NSString stringWithFormat:@"model 1 - %@", stringProperty];
            NSLog(@"Model 1 property: %@ - Model 2 property: %@", weakSelf.model.stringProperty, weakSelf.model2.stringProperty);
        }
    }];

}
- (IBAction)textFieldValueChanged:(id)sender {
   _model.stringProperty = _testTextfield.text;
}
- (IBAction)randBtnAction:(id)sender {
    NSInteger randValue = arc4random();
    _model2.stringProperty = [NSString stringWithFormat:@"%ld", randValue];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
