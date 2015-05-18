//
//  ViewController.m
//  AllMethods
//
//  Created by Vadim Osovets on 5/18/15.
//  Copyright (c) 2015 PubNub Ltd. All rights reserved.
//

#import "ViewController.h"
#import "BaseTest.h"

#import "CoreTest.h"

@interface ViewController ()

<BaseTestDelegate>

@property (nonatomic) NSMutableArray *results;
@property (nonatomic) NSMutableArray *tests;
@property (nonatomic) NSMutableArray *testsNames;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view, typically from a nib.
    
    // run tests
    
    self.testsNames = [@[@"CoreTest"] mutableCopy];
    self.results = [NSMutableArray arrayWithCapacity:[self.testsNames count]];
    self.tests = [NSMutableArray arrayWithCapacity:[self.testsNames count]];
    
    // initialize tests
    for (NSString *testName in _testsNames) {
        // TODO: add checking for correct names
        BaseTest *test = [NSClassFromString(testName) new];
        test.delegate = self;
        [self.tests addObject:test];
    }
    
    // run test
    [[self.tests firstObject] run];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - BaseTestDelegate

- (void)test:(id<BaseTestDelegate>)test finishedWithSuccess:(BOOL)res {
    
    NSString *className = NSStringFromClass([test class]);
    [self.results addObject:@{@"name": className, @"result": @(res)}];
    
    // check if it is last one
    if ([self.results count] == [self.tests count]) {
        
        // show final results
        [self showResults];
    } else {
        // run next test
        NSUInteger index = [self.testsNames indexOfObject:className];
        [[self.tests objectAtIndex:index + 1] run];
    }
}

- (void)test:(id<BaseTestDelegate>)test reachedTimeout:(BOOL)res {
    // TODO: indicate the reason of fail
    
    [self test:test finishedWithSuccess:res];
}

#pragma mark - Private

- (void)showResults {
    printf("\t\t\t Tests:\n");
    NSUInteger passed = 0;
    for (NSDictionary *test in self.results) {
        
        NSString *result = @"FAILED";
        if ([test[@"result"] boolValue]) {
            result = @"Passed";
            passed += 1;
        }
        
        printf("%s - %s\n", [test[@"name"] cStringUsingEncoding:NSUTF8StringEncoding], [result cStringUsingEncoding:NSUTF8StringEncoding]);
    }
    
    printf("\t\t\t Summary: \n\tPassed - %lu\n\tFailed - %lu", passed, [self.results count] - passed);
}

@end
