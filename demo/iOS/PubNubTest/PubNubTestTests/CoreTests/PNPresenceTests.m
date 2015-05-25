//
//  PNPresenceTests.m
//  PubNubTest
//
//  Created by Sergey Kazanskiy on 5/18/15.
//  Copyright (c) 2015 PubNub, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import <PubNub/PubNub.h>
#import "TestConfigurator.h"

@interface PNPresenceTests : XCTestCase

@end

@implementation PNPresenceTests {
    
    PubNub *_pubNub;
    NSString *_testChannel;
    NSString *_testGroup;
    NSDictionary *_testState;
    
    BOOL _isTestError;
}

- (void)setUp {
    
    [super setUp];
    
    _pubNub = [PubNub clientWithPublishKey:[[TestConfigurator shared] mainPubKey] andSubscribeKey:[[TestConfigurator shared] mainSubKey]];
    _pubNub.uuid = @"testUUID";

    _testChannel = @"testChannel";
    _testGroup = @"testGroup";
    _testState = @{@"name":@"James", @"sername":@"Bond"};
}

- (void)tearDown {
    
    _pubNub =nil;
    [super tearDown];
}


#pragma mark - Tests presence for channel

- (void)testPresenceForChannelHereNowOccupancy {
    
    // Preparing date
    [self subscribeOnChannels:@[_testChannel]];
    
    // Getting here now occupancy
    XCTestExpectation *_hereNowOccupancyExpectation = [self expectationWithDescription:@"Getting hereNowOccupancy"];
    __block long resultOccupancy;
    
    [_pubNub hereNowData:PNHereNowOccupancy forChannel:_testChannel withCompletion:^(PNResult *result, PNStatus *status) {
        
        if (status.isError) {
            
            XCTFail(@"Error");
        } else {
            
            resultOccupancy = [(NSNumber *)[result.data objectForKey:@"occupancy"] longValue];
        }
        [_hereNowOccupancyExpectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:[[TestConfigurator shared] testTimeout] handler:^(NSError *error) {
        
        if (error) {
            XCTFail(@"Timeout is fired");
         }
    }];

    // Checking result
    XCTAssertTrue(resultOccupancy == 1, @"Error incorrect occupancy: %ld", resultOccupancy);
}

#warning Sametimes resultUUID = NULL

- (void)testPresenceForChannelHereNowUUID {
    
    // Preparing date
    [self subscribeOnChannels:@[_testChannel]];
    
    // Getting here now UUID
    XCTestExpectation *_hereNowUUIDExpectation = [self expectationWithDescription:@"Getting hereNowUUID"];
    __block NSString *resultUUID;
    
    [_pubNub hereNowData:PNHereNowUUID forChannel:_testChannel withCompletion:^(PNResult *result, PNStatus *status) {
        
        if (status.isError) {
            
            XCTFail(@"Error");
        } else {
            
            resultUUID = [(NSArray *)[result.data objectForKey:@"uuids"] lastObject];
        }
        [_hereNowUUIDExpectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:[[TestConfigurator shared] testTimeout] handler:^(NSError *error) {
        
        if (error) {
            XCTFail(@"Timeout is fired");
        }
    }];

    // Checking result
     XCTAssertTrue([resultUUID isEqual:@"testUUID"], @"Error incorrect UUID: %@", resultUUID);
}

#warning PNHereNowState have to return participants identifier names along with state information at specified remote data objects live feeds

- (void)testPresenceForChannelHereNowState {
    
    // Preparing date
    [self setState:_testState onChannel:_testChannel];
    [self subscribeOnChannels:@[_testChannel]];
    
    // Getting here now state
    XCTestExpectation *_hereNowStateExpectation = [self expectationWithDescription:@"Getting hereNowState"];
    __block NSDictionary *resultState;
    
    [_pubNub hereNowData:PNHereNowState forChannel:_testChannel withCompletion:^(PNResult *result, PNStatus *status) {
        
        if (status.isError) {
            
            XCTFail(@"Error");
        } else {
            
            resultState = (NSDictionary *)[result.data objectForKey:@"state"];
        }
        [_hereNowStateExpectation fulfill];
    }];

    [self waitForExpectationsWithTimeout:[[TestConfigurator shared] testTimeout] handler:^(NSError *error) {
        
        if (error) {
            XCTFail(@"Timeout is fired");
        }
    }];
    
    // Checking result
    XCTAssertTrue([resultState isEqual:_testState], @"Error incorrect state: %@", resultState);
}


#pragma mark - Tests presence for channelgroup

- (void)testPresenceForGroupHereNowOccupancy {
    
    // Preparing date
    [self createGroup:_testGroup withChannel:_testChannel];
    [self subscribeOnChannelGroups:@[_testGroup]];
    
    // Getting here now occupancy
    XCTestExpectation *_hereNowOccupancyExpectation = [self expectationWithDescription:@"Getting hereNowOccupancy"];
    __block long resultOccupancy;
    
    [_pubNub hereNowData:PNHereNowOccupancy forChannelGroup:_testGroup withCompletion:^(PNResult *result, PNStatus *status) {
        
        if (status.isError) {
            
            XCTFail(@"Error");
        } else {
            
            resultOccupancy = [(NSNumber *)[result.data objectForKey:@"total_occupancy"] longValue];
        }
        [_hereNowOccupancyExpectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:[[TestConfigurator shared] testTimeout] handler:^(NSError *error) {
        
        if (error) {
            XCTFail(@"Timeout is fired");
        }
    }];
    
    // Checking result
    XCTAssertTrue(resultOccupancy > 1, @"Error incorrect occupancy: %ld", resultOccupancy);
}

#warning get resultUUID unposible, do not matches documentation

- (void)testPresenceForGroupHereNowUUID {
    
    // Preparing date
    [self createGroup:_testGroup withChannel:_testChannel];
    [self subscribeOnChannelGroups:@[_testGroup]];
    
    // Getting here now UUID
    XCTestExpectation *_hereNowUUIDExpectation = [self expectationWithDescription:@"Getting hereNowUUID"];
    __block NSString *resultUUID;
    
    [_pubNub hereNowData:PNHereNowUUID forChannelGroup:_testGroup withCompletion:^(PNResult *result, PNStatus *status) {
        
        if (status.isError) {
            
            XCTFail(@"Error");
        } else {
            
            resultUUID = [(NSArray *)[result.data objectForKey:@"uuids"] lastObject];
        }
        [_hereNowUUIDExpectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:[[TestConfigurator shared] testTimeout] handler:^(NSError *error) {
        
        if (error) {
            XCTFail(@"Timeout is fired");
        }
    }];
    
    // Checking result
    XCTAssertTrue([resultUUID isEqual:@"testUUID"], @"Error incorrect UUID: %@", resultUUID);
}

#warning PNHereNowState have to return participants identifier names along with state information at specified remote data objects live feeds need to investigate, objectForKey:@"state" - wrong

- (void)testPresenceForGroupHereNowState {
    
    // Preparing date
    [self createGroup:_testGroup withChannel:_testChannel];
    [self setState:_testState onChannelGroup:_testChannel];
    [self subscribeOnChannelGroups:@[_testGroup]];
    
    // Getting here now state
    XCTestExpectation *_hereNowStateExpectation = [self expectationWithDescription:@"Getting hereNowState"];
    __block NSDictionary *resultState;
    
    [_pubNub hereNowData:PNHereNowState forChannelGroup:_testGroup withCompletion:^(PNResult *result, PNStatus *status) {
        
        if (status.isError) {
            
            XCTFail(@"Error");
        } else {
            
            resultState = (NSDictionary *)[result.data objectForKey:@"state"];
        }
        [_hereNowStateExpectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:[[TestConfigurator shared] testTimeout] handler:^(NSError *error) {
        
        if (error) {
            XCTFail(@"Timeout is fired");
        }
    }];
    
    // Checking result
    XCTAssertTrue([resultState isEqual:_testState], @"Error incorrect state: %@", resultState);
}


#pragma mark - Private methods

- (void)subscribeOnChannels:(NSArray *)channels {
    
    
    XCTestExpectation *subscribeExpectation = [self expectationWithDescription:@"Subscribing"];
    __block NSArray *statusChannels;
    
    [_pubNub subscribeToChannels:channels withPresence:YES
                     clientState:nil andCompletion:^(PNStatus *status) {
                         
                         if (status.isError) {
                             
                             XCTFail(@"Error occurs during subscription %@", status.data);
                             _isTestError = YES;
                         } else {
                             
                             statusChannels = status.channels;
                         }
                         [subscribeExpectation fulfill];
                     }];
    
    [self waitForExpectationsWithTimeout:[[TestConfigurator shared] testTimeout] handler:^(NSError *error) {
        
        if (error) {
            
            XCTFail(@"Timeout is fired");
            _isTestError = YES;
        }
    }];
    
    // Checking received from PNStatus channels
    NSSet *channelsSet = [[NSSet alloc] initWithArray:channels];
    NSSet *statusChannelsSet = [[NSSet alloc] initWithArray:statusChannels];
    XCTAssertTrue([channelsSet isSubsetOfSet:statusChannelsSet]);
    
    // Checking isSubscribedOn
    for (NSString *testChannel in channels) {
        
        if (![_pubNub isSubscribedOn:testChannel]) {
            
            XCTFail(@"Error client didn't subscribe on all specified channels");
            _isTestError = YES;
        }
    }
    
    if (_isTestError) {
        return;
    }
}

- (void)subscribeOnChannelGroups:(NSArray *)groups {
    
    XCTestExpectation *subscribeExpectation = [self expectationWithDescription:@"Subscribing"];
    __block NSArray *statusGroups;
    
    [_pubNub subscribeToChannelGroups:groups withPresence:YES andCompletion:^(PNStatus *status) {
        
        if (status.isError) {
            
            XCTFail(@"Error occurs during subscription %@", status.data);
            _isTestError = YES;
        } else {
            
            statusGroups = status.channelGroups;
        }
        [subscribeExpectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:[[TestConfigurator shared] testTimeout] handler:^(NSError *error) {
        
        if (error) {
            
            XCTFail(@"Timeout is fired");
            _isTestError = YES;
        }
    }];
    
    // Checking received from PNStatus channels
    NSSet *groupsSet = [[NSSet alloc] initWithArray:groups];
    NSSet *statusGroupsSet = [[NSSet alloc] initWithArray:statusGroups];
    XCTAssertTrue([groupsSet isSubsetOfSet:statusGroupsSet]);
    
    // Checking isSubscribedOn
    for (NSString *testGroup in groups) {
        
        if (![_pubNub isSubscribedOn:testGroup]) {
            
            XCTFail(@"Error client didn't subscribe on all specified channels");
            _isTestError = YES;
        }
    }
    
    if (_isTestError) {
        
        return;
    }
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


- (void)setState:(NSDictionary *)state onChannelGroup:(NSString *)group {
    
    XCTestExpectation *_stateExpectation = [self expectationWithDescription:@"Setting state"];
    
    [_pubNub setState:state forUUID:@"testUUID" onChannelGroup:group withCompletion:^(PNStatus *status) {
        
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
            
            XCTFail(@"Error occurs during adding channels %@", status.data);
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
