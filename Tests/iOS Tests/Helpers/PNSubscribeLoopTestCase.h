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

// these are properties so that they can be easily accessed with dot accessors with compiler autocomplete
@property (nonatomic, strong, readonly) NSArray<NSString *> *subscribedChannels; // default is empty array
@property (nonatomic, strong, readonly) NSArray<NSString *> *subscribedChannelGroups; // default is empty array
@property (nonatomic, assign, readonly) BOOL shouldSubscribeWithPresence; // default is `NO`
@property (nonatomic, assign, readonly) BOOL shouldRunSetUp; // default is `YES`
@property (nonatomic, assign, readonly) BOOL shouldrunTearDown; // default is `YES`

- (BOOL)expectedSubscribeChannelsMatches:(NSArray<NSString *> *)actualChannels; // this checks if presence is yes or no and includes those in assert

@end
