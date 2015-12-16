//
//  PNBasicPresenceTestCase.m
//  PubNub Tests
//
//  Created by Jordan Zucker on 12/10/15.
//
//

//#import <PubNub/PubNub.h>
#import "PNBasicPresenceTestCase.h"

@interface PNBasicPresenceTestCase ()
@property (nonatomic) XCTestExpectation *setUpExpectation;
@end
@implementation PNBasicPresenceTestCase

- (NSString *)otherClientChannelName {
    return @"2EC925F0-B996-47A4-AF54-A605E1A9AEBA";
}

- (NSString *)channelGroupName {
    return @"testGroup";
}

- (void)setUp {
    [super setUp];
    PNConfiguration *config = [PNConfiguration configurationWithPublishKey:@"demo-36" subscribeKey:@"demo-36"];
//    config.uuid = @"d063790a-5fac-4c7b-9038-b511b61eb23d";
    config.uuid = @"58A6FB32-4323-45BE-97BF-2D070A3F8912";
    config.origin = @"msgfiltering-dev.pubnub.com";
    config.presenceHeartbeatValue = 0;
    self.otherClient = [PubNub clientWithConfiguration:config];
    [self.otherClient addListener:self];
//    [self.otherClient subscribeToChannels:@[[self otherClientChannelName]] withPresence:YES clientState:@{@"foo" : @"bar"}];
//    [self waitForExpectationsWithTimeout:60 handler:^(NSError * _Nullable error) {
//        if (error) {
//            XCTFail(@"failed to set up");
//        }
//    }];
    
}

- (void)setUpChannelSubscription {
    self.setUpExpectation = [self expectationWithDescription:@"setUp"];
    [self.otherClient subscribeToChannels:@[[self otherClientChannelName]] withPresence:YES clientState:@{@"foo" : @"bar"}];
    [self waitForExpectationsWithTimeout:60 handler:^(NSError * _Nullable error) {
        if (error) {
            XCTFail(@"failed to set up");
        }
    }];
}

- (void)setUpChannelGroupSubscription {
    self.setUpExpectation = [self expectationWithDescription:@"setUp"];
    [self.otherClient subscribeToChannelGroups:@[[self channelGroupName]] withPresence:YES];
    [self waitForExpectationsWithTimeout:20 handler:^(NSError * _Nullable error) {
        if (error) {
            XCTFail(@"failed to set up channel group subscription");
        }
    }];
}

- (void)tearDown {
    self.presenceEventExpectation = nil;
    self.otherClient = nil;
    [super tearDown];
}

#pragma mark - PNObjectEventListener

- (void)client:(PubNub *)client didReceiveStatus:(PNStatus *)status {
    [super client:client didReceiveStatus:status];
    // just verifying self.otherClient is properly configured during set up
    if ([client isEqual:self.otherClient]) {
        XCTAssertEqual(status.category, PNConnectedCategory);
        [self.setUpExpectation fulfill];
    }
}

- (void)client:(PubNub *)client didReceivePresenceEvent:(PNPresenceEventResult *)event {
    [super client:client didReceivePresenceEvent:event];
    if (self.otherClientPresenceEventAssertions) {
        self.otherClientPresenceEventAssertions(client, event);
    }
}

@end
