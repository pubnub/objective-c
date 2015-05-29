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
    
    PNChannel *_testChannel;
    NSDictionary *_testState;
    
    XCTestExpectation *_presenceReceivingExpectation;
}

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    
    _pubNub = [PubNub clientWithConfiguration:[PNConfiguration defaultTestConfiguration] andDelegate:nil];
    
    _extraClient = [PubNub clientWithConfiguration:[PNConfiguration defaultTestConfiguration] andDelegate:self];
    
    [_pubNub connect];
    [_extraClient connect];
    
    _testState = @{@"1": @{@"1-2": @{@"1-3": @"4"}}};
    _testChannel = [PNChannel channelWithName:[TestConfigurator uniqueString] shouldObservePresence:YES];
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
    
    NSDictionary *nestedClientState = @{@"1": @"2"};
    
    [_pubNub subscribeOn:@[_testChannel]];
    
    [_pubNub updateClientState:[_pubNub clientIdentifier]
                         state:nestedClientState
                     forObject:_testChannel
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

- (void)testUpdateClientNestedState {
    // This is an example of a functional test case.
    
    XCTestExpectation *testExpectation = [self expectationWithDescription:@"PubNub updateClientState"];
    
    [_pubNub subscribeOn:@[_testChannel]];
    
    [_pubNub updateClientState:[_pubNub clientIdentifier]
                         state:_testState
                     forObject:_testChannel
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

- (void)testPresenceReceivingNestedState {
    // This is an example of a functional test case.
    
    XCTestExpectation *testExpectation = [self expectationWithDescription:@"PubNub updateClientState"];
    
    _presenceReceivingExpectation = [self expectationWithDescription:@"PubNub receive change state during presence"];
    
    [_extraClient subscribeOn:@[_testChannel]];
    [_pubNub subscribeOn:@[_testChannel]];
    
    [_pubNub updateClientState:[_pubNub clientIdentifier]
                         state:_testState
                     forObject:_testChannel
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
    
//    _extraClient = [PubNub clientWithConfiguration:[PNConfiguration defaultTestConfiguration]];
//    [_extraClient connect];
    
    XCTestExpectation *testExpectation = [self expectationWithDescription:@"PubNub updateClientState"];
    
    XCTestExpectation *checkExpectation = [self expectationWithDescription:@"PubNub updateClientState"];
    
    [_pubNub subscribeOn:@[_testChannel]
            withClientState:_testState
    andCompletionHandlingBlock:^(PNSubscriptionProcessState state, NSArray *channels, PNError *error) {
        if (error) {
            XCTFail(@"Error during update Client state: %@", error);
        }
        
        [testExpectation fulfill];
    }];
    
    [_extraClient subscribeOn:@[_testChannel]];
    
    [_extraClient requestClientState:[_pubNub clientIdentifier]
                           forObject:_testChannel
         withCompletionHandlingBlock:^(PNClient *client, PNError *error) {
             if (error) {
                 XCTFail(@"Error during update Client state: %@", error);
                 return ;
             }
             
             if (![[client stateForChannel:_testChannel] isEqualToDictionary:_testState])  {
                 XCTFail(@"States are not equal: %@ <> %@", [client stateForChannel:_testChannel], _testState);
                 
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

- (void)testSubscribeOnChannelWithNestedStateBasedOnGroup {
    
    GCDGroup *group = [GCDGroup group];
    [group enterTimes:6];
    
    PNChannel *channel = [PNChannel channelWithName:@"TestVadimChannel"];
    
    NSDictionary *nestedClientState = @{@"testSimple": @"one"};
    NSDictionary *nestedClientState2 = @{@"testSimple2": @"three"};
    NSDictionary *nestedClientState3 = @{@"testSimple3": @"four"};
    
    [_pubNub subscribeOn:@[channel] withClientState:nestedClientState andCompletionHandlingBlock:^(PNSubscriptionProcessState state, NSArray *channels, PNError *error) {
        if (error) {
            XCTFail(@"Error during update Client state: %@", error);
        }
        
        [group leave];
    }];
    
    [_pubNub requestClientState:[_pubNub clientIdentifier]
                           forObject:channel
         withCompletionHandlingBlock:^(PNClient *client, PNError *error) {
             if (error) {
                 XCTFail(@"Error during update Client state: %@", error);
                 return ;
             }
             
             if (![[client stateForChannel:channel] isEqualToDictionary:nestedClientState])  {
                 XCTFail(@"States are not equal: %@ <> %@", [client stateForChannel:channel], nestedClientState);
                 
                 NSLog(@"States are not equal: %@ <> %@", [client stateForChannel:channel], nestedClientState);
             }
             
             [group leave];
         }];
    
    
    [_pubNub updateClientState:[_pubNub clientIdentifier]
                         state:nestedClientState2
                     forObject:channel
   withCompletionHandlingBlock:^(PNClient *client, PNError *error) {
       if (![[client stateForChannel:channel] isEqualToDictionary:nestedClientState2])  {
           XCTFail(@"States are not equal: %@ <> %@", [client stateForChannel:channel], nestedClientState2);
           
           NSLog(@"States are not equal: %@ <> %@", [client stateForChannel:channel], nestedClientState2);
       }
       
       [group leave];
   }];
    
    [_pubNub requestClientState:[_pubNub clientIdentifier]
                      forObject:channel
    withCompletionHandlingBlock:^(PNClient *client, PNError *error) {
        if (error) {
            XCTFail(@"Error during update Client state: %@", error);
            return ;
        }
        
        if (![[client stateForChannel:channel] isEqualToDictionary:nestedClientState2])  {
            XCTFail(@"States are not equal: %@ <> %@", [client stateForChannel:channel], nestedClientState2);
            
            NSLog(@"States are not equal: %@ <> %@", [client stateForChannel:channel], nestedClientState2);
        }
        
        [group leave];
    }];
    
    [_pubNub updateClientState:[_pubNub clientIdentifier]
                         state:nestedClientState3
                     forObject:channel
   withCompletionHandlingBlock:^(PNClient *client, PNError *error) {
       if (![[client stateForChannel:channel] isEqualToDictionary:nestedClientState3])  {
           XCTFail(@"States are not equal: %@ <> %@", [client stateForChannel:channel], nestedClientState3);
           
           NSLog(@"States are not equal: %@ <> %@", [client stateForChannel:channel], nestedClientState3);
       }
       
       [group leave];
   }];
    
    
    [_pubNub requestClientState:[_pubNub clientIdentifier]
                      forObject:channel
    withCompletionHandlingBlock:^(PNClient *client, PNError *error) {
        if (error) {
            XCTFail(@"Error during update Client state: %@", error);
            return ;
        }
        
        if (![[client stateForChannel:channel] isEqualToDictionary:nestedClientState3])  {
            XCTFail(@"States are not equal: %@ <> %@", [client stateForChannel:channel], nestedClientState3);
            
            NSLog(@"States are not equal: %@ <> %@", [client stateForChannel:channel], nestedClientState3);
        }
        
        [group leave];
    }];
    
    if ([GCDWrapper isGCDGroup:group timeoutFiredValue:kTestTestTimout]) {
        XCTFail(@"Timeout fired");
    }
}

#pragma mark - PNDelegate

- (void)pubnubClient:(PubNub *)client didReceivePresenceEvent:(PNPresenceEvent *)event {
    NSLog(@"Event: %@", event);
    
    if (event.type == PNPresenceEventStateChanged) {
        if ([[event.client identifier] isEqual:[_pubNub clientIdentifier]]) {
            if (![[event.client stateForChannel:_testChannel] isEqualToDictionary:_testState]) {
                XCTFail(@"Failed to receive state: %@ <> %@", [event.client stateForChannel:_testChannel], _testState);
            }
            [_presenceReceivingExpectation fulfill];
        }
    }
}


@end
