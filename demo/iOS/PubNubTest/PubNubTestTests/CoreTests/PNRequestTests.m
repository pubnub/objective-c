//
//  PubNubTestTests.m
//  PubNubTestTests
//
//  Created by Vadim Osovets on 5/8/15.
//  Copyright (c) 2015 PubNub Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>

#define HC_SHORTHAND
#import <OCHamcrest/OCHamcrest.h>

#define MOCKITO_SHORTHAND
#import <OCMockito/OCMockito.h>

#import "PNRequest+Private.h"
#import "PNRequest.h"

#import "PNResult.h"
#import "PNStatus.h"

@interface PNRequestTests : XCTestCase

@end

@implementation PNRequestTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

#pragma mark - Tests

- (void)testInitializationFabricMethod {
    
    // Init with nil-parametrs
    PNRequest *testRequest = [PNRequest requestWithPath:nil parameters:nil forOperation:0 withCompletion:nil];
    
    assertThat(testRequest, notNilValue());
    assertThat([testRequest resourcePath], equalTo nil);
    assertThat(testRequest, hasProperty(@"parameters", @{}));
    assertThatInteger([testRequest operation], equalToInteger(0));
    

    
    
    
    
    // Init with correct parametrs
    NSString *requestWithPath = @"https://pubsub.pubnub.com/time/0?";
    NSDictionary *parameters = @{@"test": @43};
    PNOperationType operationType = PNTimeOperation;
    void(^completionBlock)(PNResult *result, PNStatus *status) = ^void(PNResult *result, PNStatus *status){};

//    testRequest = [PNRequest requestWithPath:requestWithPath parameters:parameters forOperation:operationType withCompletion:completionBlock];
    
    assertThat(testRequest, notNilValue());
    assertThat([testRequest resourcePath], equalTo(requestWithPath));
    assertThat(testRequest, hasProperty(@"parameters", parameters));
    assertThatInteger([testRequest operation], equalToInteger(operationType));

    
    
    
    
    // Init with Uncorrect parametrs (has no control for input parameters !!!)
    requestWithPath = @"Hello world =+-";
    parameters = @{@"test": @{@"test2": @43}};
    operationType = 1000;
    
//    testRequest = [PNRequest requestWithPath:requestWithPath parameters:parameters forOperation:operationType withCompletion:completionBlock];
    
    assertThat(testRequest, notNilValue());
    assertThat([testRequest resourcePath], equalTo(requestWithPath));
    assertThat(testRequest, hasProperty(@"parameters", parameters));
    assertThatInteger([testRequest operation], equalToInteger(operationType));
}

- (void)testSimpleInitialization {
       
    NSString *path = @"test/path";
    NSDictionary *parameters = @{@"test": @43};
    PNOperationType operationType = PNTimeOperation;
    void(^completionBlock)(PNResult *result, PNStatus *status) = ^void(PNResult *result, PNStatus *status){};
    
////    PNRequest *testRequest = [[PNRequest alloc] initWithPath:path parameters:parameters forOperation:operationType withCompletion:completionBlock];
//    assertThat(testRequest, notNilValue());
//    
//    assertThat(testRequest, hasProperty(@"resourcePath", path));
//    assertThat(testRequest, hasProperty(@"parameters", parameters));
//    
//    assertThatInteger([testRequest operation], is(equalToInteger(operationType)));
//    assertThat([testRequest completionBlock], is(equalTo(completionBlock)));
}



@end
