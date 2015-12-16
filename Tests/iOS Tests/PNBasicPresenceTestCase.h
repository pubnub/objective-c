//
//  PNBasicPresenceTestCase.h
//  PubNub Tests
//
//  Created by Jordan Zucker on 12/10/15.
//
//

#import <PubNub/PubNub.h>
#import "PNBasicSubscribeTestCase.h"

@interface PNBasicPresenceTestCase : PNBasicSubscribeTestCase <PNObjectEventListener>
@property (nonatomic) PubNub *otherClient;
- (NSString *)otherClientChannelName;
- (NSString *)channelGroupName;
@property (nonatomic, copy) PNClientDidReceivePresenceEventAssertions otherClientPresenceEventAssertions;
@property (nonatomic, strong) XCTestExpectation *presenceEventExpectation;

// should call one or the other of these, result of calling both is unexpected
- (void)setUpChannelSubscription;
- (void)setUpChannelGroupSubscription;
@end
