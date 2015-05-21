//
//  PNPresenceTests.m
//  PubNubTest
//
//  Created by Sergey Kazanskiy on 5/18/15.
//  Copyright (c) 2015 PubNub, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "PubNub.h"

#import "TestConfigurator.h"

@interface PNPresenceTests : XCTestCase

@end

@implementation PNPresenceTests {
    
    PubNub *_pubNub;
    BOOL _isTestError;
}

- (void)setUp {
    
    [super setUp];
    
    _pubNub = [PubNub clientWithPublishKey:[[TestConfigurator shared] mainPubKey] andSubscribeKey:[[TestConfigurator shared] mainSubKey]];
    _pubNub.uuid = @"testUUID";
}

- (void)tearDown {
    
    _pubNub =nil;
    [super tearDown];
}

#pragma mark - Tests

- (void)testPresenceForChannel {
   
    [self setState:@{@"name":@"James", @"sername":@"Bond"} onChannel:@"testChannel"];
    [self subscribeOnChannel:@"testChannel"];
    
     // Here now occupancy
    XCTestExpectation *_hereNowOccupancyExpectation = [self expectationWithDescription:@"Getting hereNowOccupancy"];
     __block long resultOccupancy;
    
    [_pubNub hereNowData:PNHereNowOccupancy forChannel:@"testChannel" withCompletion:^(PNResult *result, PNStatus *status) {
  
        if (status.isError) {
            
            XCTFail(@"Error");
            _isTestError = YES;
        } else {

            resultOccupancy = [(NSNumber *)[result.data objectForKey:@"occupancy"] longValue];
        }
        [_hereNowOccupancyExpectation fulfill];
    }];

#warning Sametimes resultUUID = NULL
    
    // Here now UUID
    XCTestExpectation *_hereNowUUIDExpectation = [self expectationWithDescription:@"Getting hereNowUUID"];
    __block NSString *resultUUID;
    
    [_pubNub hereNowData:PNHereNowUUID forChannel:@"testChannel" withCompletion:^(PNResult *result, PNStatus *status) {
        
        if (status.isError) {
            
            XCTFail(@"Error");
            _isTestError = YES;
        } else {
            
            resultUUID = [(NSArray *)[result.data objectForKey:@"uuids"] lastObject];
        }
        [_hereNowUUIDExpectation fulfill];
    }];

#warning PNHereNowState have to return participants identifier names along with state information at specified remote data objects live feeds
    
    // Here now State
    XCTestExpectation *_hereNowStateExpectation = [self expectationWithDescription:@"Getting hereNowState"];
    __block NSDictionary *resultState;
    
    [_pubNub hereNowData:PNHereNowState forChannel:@"testChannel" withCompletion:^(PNResult *result, PNStatus *status) {
        
        if (status.isError) {
            
            XCTFail(@"Error");
            _isTestError = YES;
        } else {
            
            resultState = (NSDictionary *)[result.data objectForKey:@"state"];
        }
        [_hereNowStateExpectation fulfill];
    }];
    
    // Waiting for expectations
    [self waitForExpectationsWithTimeout:[[TestConfigurator shared] testTimeout] handler:^(NSError *error) {
        
        if (error) {
            
            XCTFail(@"Timeout is fired");
            _isTestError = YES;
        }
    }];
    
    if (_isTestError) {
        
        XCTFail(@"Error");
        return;
    }
    
    // Check results
    XCTAssertTrue(resultOccupancy == 1, @"Error incorrect occupancy: %ld", resultOccupancy);
    XCTAssertTrue([resultUUID isEqual:@"testUUID"], @"Error incorrect UUID: %@", resultUUID);
//    XCTAssertTrue([resultState isEqual:testState], @"Error incorrect state: %@", resultState);
}

- (void)testPresenceForChannelGroup {
    
    [self setState:@{@"name":@"James", @"sername":@"Bond"} onChannel:@"testChannel"];
    [self createGroup:@"testGroup" withChannel:@"testChannel"];
    [self subscribeOnChannel:@"testChannel"];
    
    // Here now occupancy
    XCTestExpectation *_hereNowOccupancyExpectation = [self expectationWithDescription:@"Getting hereNowOccupancy"];
    __block long resultOccupancy;
    
    [_pubNub hereNowData:PNHereNowOccupancy forChannelGroup:@"testChannel" withCompletion:^(PNResult *result, PNStatus *status) {
        
        if (status.isError) {
            
            XCTFail(@"Error");
            _isTestError = YES;
        } else {
            
            resultOccupancy = [(NSNumber *)[result.data objectForKey:@"occupancy"] longValue];
        }
        [_hereNowOccupancyExpectation fulfill];
    }];
    
#warning Sametimes resultUUID = NULL
    
    // Here now UUID
    XCTestExpectation *_hereNowUUIDExpectation = [self expectationWithDescription:@"Getting hereNowUUID"];
    __block NSString *resultUUID;
    
    [_pubNub hereNowData:PNHereNowUUID forChannelGroup:@"testChannel" withCompletion:^(PNResult *result, PNStatus *status) {
        
        if (status.isError) {
            
            XCTFail(@"Error");
            _isTestError = YES;
        } else {
            
            resultUUID = [(NSArray *)[result.data objectForKey:@"uuids"] lastObject];
        }
        [_hereNowUUIDExpectation fulfill];
    }];
    
#warning PNHereNowState have to return participants identifier names along with state information at specified remote data objects live feeds
    
    // Here now State
    XCTestExpectation *_hereNowStateExpectation = [self expectationWithDescription:@"Getting hereNowState"];
    __block NSDictionary *resultState;
    
    [_pubNub hereNowData:PNHereNowState forChannelGroup:@"testChannel" withCompletion:^(PNResult *result, PNStatus *status) {
        
        if (status.isError) {
            
            XCTFail(@"Error");
            _isTestError = YES;
        } else {
            
            resultState = (NSDictionary *)[result.data objectForKey:@"state"];
        }
        [_hereNowStateExpectation fulfill];
    }];
    
    // Waiting for expectations
    [self waitForExpectationsWithTimeout:[[TestConfigurator shared] testTimeout] handler:^(NSError *error) {
        
        if (error) {
            
            XCTFail(@"Timeout is fired");
            _isTestError = YES;
        }
    }];
    
    if (_isTestError) {
        
        XCTFail(@"Error");
        return;
    }
    
    // Check results
    XCTAssertTrue(resultOccupancy == 1, @"Error incorrect occupancy: %ld", resultOccupancy);
    XCTAssertTrue([resultUUID isEqual:@"testUUID"], @"Error incorrect UUID: %@", resultUUID);
    //    XCTAssertTrue([resultState isEqual:testState], @"Error incorrect state: %@", resultState);
}


#pragma mark - Private methods

- (void)subscribeOnChannel:(NSString *)channelName {
    
    XCTestExpectation *_subscribeExpectation = [self expectationWithDescription:@"Subscribing"];
    
    [_pubNub subscribeToChannels:@[@"testChannel"] withPresence:YES clientState:nil andCompletion:^(PNStatus *status) {
        
        if (status.isError) {
            
            XCTFail(@"Error occurs during subscription %@", status.error);
            _isTestError = YES;
        }
        [_subscribeExpectation fulfill];
    }];
    
     [self waitForExpectationsWithTimeout:[[TestConfigurator shared] testTimeout] handler:^(NSError *error) {
        
        if (error) {
            
            XCTFail(@"Timeout is fired");
            _isTestError = YES;
        }
    }];
}

- (void)setState:(NSDictionary *)state onChannel:(NSString *)channelName {
    
    XCTestExpectation *_stateExpectation = [self expectationWithDescription:@"Setting state"];
    
    [_pubNub setState:state forUUID:@"testUUID" onChannel:channelName withCompletion:^(PNStatus *status) {
        
        if (status.isError) {
            
            XCTFail(@"Error");
            _isTestError = YES;
        }
        [_stateExpectation fulfill];
    }];
    
    // Waiting for expectations
    [self waitForExpectationsWithTimeout:[[TestConfigurator shared] testTimeout] handler:^(NSError *error) {
        
        if (error) {
            
            XCTFail(@"Timeout is fired");
            _isTestError = YES;
        }
    }];
}

- (void)createGroup:(NSString *)groupName withChannel:(NSString *)channelName {
    
    XCTestExpectation *_addChannelsExpectation = [self expectationWithDescription:@"Adding channels"];
    
    [_pubNub addChannels:@[channelName] toGroup:groupName withCompletion:^(PNStatus *status) {
        
        if (status.isError) {
            
            NSLog(@"!!! Error occurs during adding channels %@", status.data);
            _isTestError = YES;
        }
        [_addChannelsExpectation fulfill];
    }];
    
    // Waiting for expectations
    [self waitForExpectationsWithTimeout:[[TestConfigurator shared] testTimeout] handler:^(NSError *error) {
        
        if (error) {
            
            XCTFail(@"Timeout is fired");
            _isTestError = YES;
        }
    }];
}

@end
