//
//  FirstViewControllerTestCase.m
//  PubNubIntegrationTests
//
//  Created by Jordan Zucker on 5/26/15.
//  Copyright (c) 2015 pubnub. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import <KIF/KIF.h>
#import <KIF/KIFUITestActor-IdentifierTests.h>

@interface FirstViewControllerTestCase : KIFTestCase

@end

@implementation FirstViewControllerTestCase

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testPublishSpecificString {
    // This is an example of a functional test case.
    NSString *testString = @"test this!";
    [self publishSpecificString:testString];
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
        [self publishSpecificString:@"test this too"];
    }];
}

- (void)publishSpecificString:(NSString *)publishString {
    [tester clearTextFromAndThenEnterText:publishString intoViewWithAccessibilityIdentifier:@"textField"];
    [tester tapViewWithAccessibilityIdentifier:@"sendButton"];
    //    [tester waitForViewWithAccessibilityLabel:@"messageLabel" value:testString traits:UIAccessibilityTraitStaticText];
    UIView *view = [tester waitForViewWithAccessibilityIdentifier:@"messageLabel"];
    UILabel *label = (UILabel *)view;
    XCTAssertTrue([label.text isEqualToString:publishString]);
}

@end
