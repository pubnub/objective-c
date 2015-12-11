//
//  PNBasicPresenceTestCase.m
//  PubNub Tests
//
//  Created by Jordan Zucker on 12/10/15.
//
//

#import <PubNub/PubNub.h>
#import "PNBasicPresenceTestCase.h"

@interface PNBasicPresenceTestCase () <PNObjectEventListener>
@property (nonatomic) XCTestExpectation *setUpExpectation;

@end
@implementation PNBasicPresenceTestCase

- (NSString *)otherClientChannelName {
    return @"2EC925F0-B996-47A4-AF54-A605E1A9AEBA";
}

- (void)setUp {
    [super setUp];
    self.setUpExpectation = [self expectationWithDescription:@"setUp"];
    PNConfiguration *config = [PNConfiguration configurationWithPublishKey:@"demo-36" subscribeKey:@"demo-36"];
    config.uuid = @"d063790a-5fac-4c7b-9038-b511b61eb23d";
    config.origin = @"msgfiltering-dev.pubnub.com";
    self.otherClient = [PubNub clientWithConfiguration:config];
    [self.otherClient addListener:self];
    [self.otherClient subscribeToChannels:@[[self otherClientChannelName]] withPresence:YES clientState:@{@"foo" : @"bar"}];
    [self waitForExpectationsWithTimeout:10 handler:^(NSError * _Nullable error) {
        if (error) {
            XCTFail(@"failed to set up");
        }
    }];
    
}

#pragma mark - PNObjectEventListener

- (void)client:(PubNub *)client didReceiveStatus:(PNStatus *)status {
    XCTAssertEqualObjects(self.otherClient, client);
    XCTAssertEqual(status.category, PNConnectedCategory);
    [self.setUpExpectation fulfill];
}

- (void)client:(PubNub *)client didReceivePresenceEvent:(PNPresenceEventResult *)event {
    NSLog(@"event: %@", event.debugDescription);
}

@end
