//
//  PNSubscribeLoopTestCase.h
//  PubNub Tests
//
//  Created by Jordan Zucker on 4/21/16.
//
//

#import "PNClientTestCase.h"

typedef void (^PNClientDidReceiveStatusHandler)(PubNub *client, PNStatus *status);
typedef void (^PNClientDidReceiveMessageHandler)(PubNub *client, PNMessageResult *message);
typedef void (^PNClientDidReceivePresenceEventHandler)(PubNub *client, PNPresenceEventResult *event);

@interface PNSubscribeLoopTestCase : PNClientTestCase <PNObjectEventListener>

@property (nonatomic, copy) PNClientDidReceiveStatusHandler didReceiveStatusHandler;
@property (nonatomic, copy) PNClientDidReceiveMessageHandler didReceiveMessageHandler;
@property (nonatomic, copy) PNClientDidReceivePresenceEventHandler didReceivePresenceEventHandler;

- (NSArray<NSString *> *)subscribedChannels;
- (NSArray<NSString *> *)subscribedChannelGroups;
- (BOOL)shouldSubscribeWithPresence;
- (BOOL)shouldRunSetUp;
- (BOOL)shouldRunTearDown;

@end
