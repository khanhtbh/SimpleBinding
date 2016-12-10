# Simple Binding
An example of Data Binding implementation for iOS. 


## Features

  - A BetterKVO category for NSObject to subscribe the changes of properties.
  - A BIND macro and a Binder object for databinding.
  - Example app with usage code.

### Installation

- Download or clone this project.
- Grab the source code in Bind and KVO groups to your project.
- Check the usage below


### Usage

1. Subcribe the changes of an object's properties.
```objective-c
#import "NSObject+BetterKVO.h"
//...

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //Init Models code...
    
    [self subcribeObject:_model
              forChanges:@[@"stringProperty"]
               handleChanges:^(NSObject *observedObject, NSDictionary *observedProperties) {
        NSString *newValue = observedProperties[@"stringProperty"];
        weakSelf.testLabel.text = newValue;
    }];
}
```

2. Binding
```objective-c
#import "BIND.h"
//...

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    _model = [[TestModel alloc] init];
    _model2 = [[TestModelNumber alloc] init];
    __weak typeof(&*self) weakSelf = self;
    
    /*
    <>: two way binding
    ~>: bind left object's property to right object's property
    <~: bind right object's property to left object's property
    This is a full call with filter and transform value blocks. 
    filter and transform calls are optional.
    */
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
}
```


### Todos

 - Write Tests
 - Write better macros for subscribe actions
 - Add Code Comments
 - Add Night Mode

License
----

MIT


**Free Software, Hell Yeah!**

