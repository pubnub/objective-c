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

- (BOOL)isRecording{
    return NO;
}

- (void)testSimpleHeartbeat {
    PNConfiguration *configuration = [PNConfiguration configurationWithPublishKey:@"demo-36" subscribeKey:@"demo-36"];
    XCTAssertNotNil(configuration);
    configuration.presenceHeartbeatInterval = 5;
    PubNub *heartbeatClient = [PubNub clientWithConfiguration:configuration];
    XCTAssertNotNil(heartbeatClient);
}

@end
