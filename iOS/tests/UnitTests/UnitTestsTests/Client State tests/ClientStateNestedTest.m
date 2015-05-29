//
//  ClientStateNestedTest.m
//  UnitTests
//
//  Created by Vadim Osovets on 5/28/15.
//  Copyright (c) 2015 Vadim Osovets. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>

#import "TestConfigurator.h"

@interface ClientStateNestedTest : XCTestCase <PNDelegate>

@end

@implementation ClientStateNestedTest {
    PubNub *_pubNub;
    PubNub *_extraClient;
}

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    
    _pubNub = [PubNub clientWithConfiguration:[PNConfiguration defaultTestConfiguration] andDelegate:self];
    
    [_pubNub connect];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [_pubNub disconnect];
    _pubNub = nil;
    
    [_extraClient disconnect];
    _extraClient = nil;
    
    [super tearDown];
}

#pragma mark - Tests

- (void)testUpdateClientState {
    // This is an example of a functional test case.
    
    XCTestExpectation *testExpectation = [self expectationWithDescription:@"PubNub updateClientState"];
    
    PNChannel *channel = [PNChannel channelWithName:[TestConfigurator uniqueString] shouldObservePresence:YES];
    
    NSDictionary *nestedClientState = @{@"1": @{@"1-2": @{@"1-3": @"4"}}};
    
    [_pubNub subscribeOn:@[channel]];
    
    [_pubNub updateClientState:[_pubNub clientIdentifier]
                         state:nestedClientState
                     forObject:channel
   withCompletionHandlingBlock:^(PNClient *client, PNError *error) {
       if (error) {
           XCTFail(@"Error during update Client state: %@", error);
       }
       
       [testExpectation fulfill];
   }];
    
    [self waitForExpectationsWithTimeout:kTestTestTimout
                                 handler:^(NSError *error) {
                                     if (error) {
                                         XCTFail(@"Error: %@", error);
                                     }
                                 }];
}

- (void)testSubscribeOnChannelWithNestedState {
    
    _extraClient = [PubNub clientWithConfiguration:[PNConfiguration defaultTestConfiguration]];
    [_extraClient connect];
    
    XCTestExpectation *testExpectation = [self expectationWithDescription:@"PubNub updateClientState"];
    
    XCTestExpectation *checkExpectation = [self expectationWithDescription:@"PubNub updateClientState"];
    
    PNChannel *channel = [PNChannel channelWithName:[TestConfigurator uniqueString] shouldObservePresence:YES];
    
//    NSDictionary *nestedClientState = @{@"1": @{@"1-2": @{@"1-3": @(423432423)}}};
    
    NSDictionary *nestedClientState = @{@"testSimple": @"one"};

    
    [_pubNub subscribeOn:@[channel] withClientState:nestedClientState andCompletionHandlingBlock:^(PNSubscriptionProcessState state, NSArray *channels, PNError *error) {
        if (error) {
            XCTFail(@"Error during update Client state: %@", error);
        }
        
        [testExpectation fulfill];
    }];
    
    [_extraClient subscribeOn:@[channel]];
    
    [_extraClient requestClientState:[_pubNub clientIdentifier]
                           forObject:channel
         withCompletionHandlingBlock:^(PNClient *client, PNError *error) {
             if (error) {
                 XCTFail(@"Error during update Client state: %@", error);
                 return ;
             }
             
             if (![[client stateForChannel:channel] isEqualToDictionary:nestedClientState])  {
                 XCTFail(@"States are not equal: %@ <> %@", [client stateForChannel:channel], nestedClientState);
                 
                 [checkExpectation fulfill];
             }
             
         }];
    
    [self waitForExpectationsWithTimeout:kTestTestTimout
                                 handler:^(NSError *error) {
                                     if (error) {
                                         XCTFail(@"Error: %@", error);
                                     }
                                 }];
    
}

@end
