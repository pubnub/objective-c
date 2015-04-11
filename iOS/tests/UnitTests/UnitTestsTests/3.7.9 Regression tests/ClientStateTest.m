//
//  ClientStateTest.m
//  UnitTests
//
//  Created by Vadim Osovets on 3/11/15.
//  Copyright (c) 2015 Vadim Osovets. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>

@interface ClientStateTest : XCTestCase <PNDelegate>

@end

@implementation ClientStateTest {
    XCTestExpectation *_silentUpdateClientStateExpectation;
}

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

#pragma mark - Tests

- (void)testUpdateStateCrash {
    [PubNub setConfiguration:[PNConfiguration defaultTestConfiguration]];
    [PubNub connect];
    [PubNub subscribeOn:@[[PNChannel channelWithName:@"swifty_state_check"]] withClientState:@{@"version": @"1.0"}];
    
     [PubNub updateClientState:[PubNub clientIdentifier]
                         state:@{@"version": @"1.5"}
                     forObject:[PNChannel channelWithName:@"swifty_state_check"]];
    
     [GCDWrapper sleepForSeconds:6];
}

- (void)testSingletone {
    // This is an example of a functional test case.
    
    NSDictionary *clientState1 = @{@"1": @"1.1", @"2": @"2.2"};
    NSDictionary *clientState2 = @{@"2": @"2.1", @"2": @"2.2"};
    
    XCTestExpectation *connectExpectation = [self expectationWithDescription:@"PubNub connect"];
    XCTestExpectation *writeExpectation = [self expectationWithDescription:@"Write client state"];
    XCTestExpectation *readExpectation = [self expectationWithDescription:@"Read client state"];
    _silentUpdateClientStateExpectation = [self expectationWithDescription:@"Silent Read client state"];
    
    [PubNub setConfiguration:[PNConfiguration defaultTestConfiguration]];
    
    [PubNub connectWithSuccessBlock:^(NSString *origin) {
        NSLog(@"Connect: %@", origin);
        [connectExpectation fulfill];
    } errorBlock:^(PNError *error) {
        [connectExpectation fulfill];
        XCTFail(@"Error occured during connect: %@", [error localizedDescription]);
    }];
    
    PNChannel *channel = [PNChannel channelWithName:@"test_ios_states"];
    
    [PubNub subscribeOn:@[channel]
        withClientState:nil];
    
    [PubNub setDelegate:self];
    
    [PubNub updateClientState:[PubNub clientIdentifier]
                        state:clientState1
                    forObject:channel];
    

    [PubNub requestClientState:[PubNub clientIdentifier]
                     forObject:channel];
    
    // add observing for check this case
    
    [PubNub updateClientState:[PubNub clientIdentifier]
                        state:clientState2
                    forObject:channel
  withCompletionHandlingBlock:^(PNClient *client, PNError *error) {
      [writeExpectation fulfill];

      if (error) {
          XCTFail(@"Fail during update client state");
      }
  }];

    [PubNub requestClientState:[PubNub clientIdentifier]
                     forObject:channel
   withCompletionHandlingBlock:^(PNClient *client, PNError *error) {
       if (error) {
          XCTFail(@"Fail during read client state");
       }
       
       [readExpectation fulfill];
   }];
    
    [self waitForExpectationsWithTimeout:kTestTestTimout
                                 handler:^(NSError *error) {
                                     if (error) {
                                         XCTFail(@"Error: %@", error);
                                     }
                                 }];
}

- (void)testInstanceVersion {
    // This is an example of a functional test case.
    
    NSDictionary *clientState1 = @{@"1": @"1.1", @"2": @"2.2"};
    NSDictionary *clientState2 = @{@"2": @"2.1", @"2": @"2.2"};
    
    XCTestExpectation *connectExpectation = [self expectationWithDescription:@"PubNub connect"];
    XCTestExpectation *writeExpectation = [self expectationWithDescription:@"Write client state"];
    XCTestExpectation *readExpectation = [self expectationWithDescription:@"Read client state"];
    
    PubNub *pubNubClient = [PubNub connectingClientWithConfiguration:[PNConfiguration defaultTestConfiguration]
                                                     andSuccessBlock:^(NSString *origin) {
                                                         [connectExpectation fulfill];
                                                     } errorBlock:^(PNError *error) {
                                                         XCTFail(@"Error during connect: %@", [error localizedDescription]);
                                                         [connectExpectation fulfill];
                                                     }];
    
    PNChannel *channel = [PNChannel channelWithName:@"test_ios_states2"];
    
    
    [pubNubClient subscribeOn:@[channel]
              withClientState:nil];
    
    [pubNubClient updateClientState:[pubNubClient clientIdentifier]
                        state:clientState1
                    forObject:channel];
    
    
    [pubNubClient requestClientState:[PubNub clientIdentifier]
                     forObject:channel];
    
    // add observing for check this case
    
    [pubNubClient updateClientState:[pubNubClient clientIdentifier]
                        state:clientState2
                    forObject:channel
  withCompletionHandlingBlock:^(PNClient *client, PNError *error) {
      [writeExpectation fulfill];
      
      if (error) {
          XCTFail(@"Fail during update client state");
      }
  }];
    
    [pubNubClient requestClientState:[PubNub clientIdentifier]
                     forObject:channel
   withCompletionHandlingBlock:^(PNClient *client, PNError *error) {
       if (error) {
           XCTFail(@"Fail during read client state");
       }
       
       [readExpectation fulfill];
   }];
    
    [self waitForExpectationsWithTimeout:kTestTestTimout
                                 handler:^(NSError *error) {
                                     if (error) {
                                         XCTFail(@"Error: %@", error);
                                     }
                                 }];
}


#pragma mark - Delegates

- (void)pubnubClient:(PubNub *)client didReceiveClientState:(PNClient *)remoteClient {
    
    static BOOL x = 0;
    if (x == 0) {
        [_silentUpdateClientStateExpectation fulfill];
        x = 1;
    }
}

- (void)pubnubClient:(PubNub *)client clientStateRetrieveDidFailWithError:(PNError *)error {
    if (_silentUpdateClientStateExpectation) {
        [_silentUpdateClientStateExpectation fulfill];
    }
    
    XCTFail(@"clientStateRetrieveDidFailWithError: %@", [error localizedDescription]);
}

- (void)pubnubClient:(PubNub *)client clientStateUpdateDidFailWithError:(PNError *)error {
    if (_silentUpdateClientStateExpectation) {
        [_silentUpdateClientStateExpectation fulfill];
    }

    XCTFail(@"clientStateUpdateDidFailWithError: %@", [error localizedDescription]);
}

@end
