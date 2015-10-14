//
//  PNHeartbeatTests.m
//  PubNub Tests
//
//  Created by Jordan Zucker on 6/30/15.
//
//

#import <PubNub/PubNub.h>
#import "PNBasicSubscribeTestCase.h"

@interface PNHeartbeatTests : PNBasicSubscribeTestCase

@end


@implementation PNHeartbeatTests

- (PNConfiguration *)overrideClientConfiguration:(PNConfiguration *)configuration {
    
    configuration.presenceHeartbeatInterval = 5;
    configuration.presenceHeartbeatValue = 60;
    return configuration;
}

- (BOOL)isRecording{
    return NO;
}

- (void)testSimpleHeartbeat {
    PNConfiguration *configuration = [PNConfiguration configurationWithPublishKey:@"demo-36"
                                                                     subscribeKey:@"demo-36"];
    XCTAssertNotNil(configuration);
    configuration.presenceHeartbeatInterval = 5;
    PubNub *heartbeatClient = [PubNub clientWithConfiguration:configuration];
    XCTAssertNotNil(heartbeatClient);
}

- (void)testHeartbeatCallbackFail {
    
    PNWeakify(self);
    XCTestExpectation *heartbeatExpectation = [self expectationWithDescription:@"heartbeatFailure"];
    self.didReceiveStatusAssertions = ^(PubNub *client, PNStatus *status) {
        PNStrongify(self);
        if (status.operation == PNSubscribeOperation) {
            
            XCTAssertFalse(status.isError, @"Subscription should be successful to test heartbeat.");
            [self.subscribeExpectation fulfill];
        }
        else if (status.operation == PNHeartbeatOperation) {
            
            XCTAssertTrue(status.isError, @"Only failed heartbeat status should be passed.");
            [heartbeatExpectation fulfill];
        }
    };
    [self PNTest_subscribeToChannels:@[@"heartbeat-test"] withPresence:NO];
}

@end
