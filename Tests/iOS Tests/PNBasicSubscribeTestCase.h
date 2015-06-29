//
//  PNBasicSubscribeTestCase.h
//  PubNub Tests
//
//  Created by Jordan Zucker on 6/16/15.
//
//
#import <PubNub/PubNub.h>

#import "PNBasicClientTestCase.h"

typedef void (^PNClientDidReceiveMessageAssertions)(PubNub *client, PNMessageResult *message);
typedef void (^PNClientDidReceivePresenceEventAssertions)(PubNub *client, PNPresenceEventResult *event);
typedef void (^PNClientDidReceiveStatusAssertions)(PubNub *client, PNSubscribeStatus *status);

@class XCTestExpectation;

@interface PNBasicSubscribeTestCase : PNBasicClientTestCase <PNObjectEventListener>

@property (nonatomic) XCTestExpectation *subscribeExpectation;

@property (nonatomic, copy) PNClientDidReceiveMessageAssertions didReceiveMessageAssertions;
@property (nonatomic, copy) PNClientDidReceivePresenceEventAssertions didReceivePresenceEventAssertions;
@property (nonatomic, copy) PNClientDidReceiveStatusAssertions didReceiveStatusAssertions;

@end
