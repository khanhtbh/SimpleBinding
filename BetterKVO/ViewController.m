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

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    _model = [[TestModel alloc] init];
    __weak typeof(&*self) weakSelf = self;
    [_model addObserver:self forProperties:@[@"stringProperty"] withObserveBlock:^(NSObject *observedObject, NSDictionary *observedProperties) {
        NSString *stringProperty = observedProperties[@"stringProperty"];
        weakSelf.testLabel.text = stringProperty;
    }];
    _model.stringProperty = @"Test";
    [_testTextfield addObserver:self forProperties:@[@"text"] withObserveBlock:^(NSObject *observedObject, NSDictionary *observedProperties) {
        weakSelf.model.stringProperty = observedProperties[@"text"];
    }];
}
- (IBAction)textFieldValueChanged:(id)sender {
    _model.stringProperty = _testTextfield.text;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
