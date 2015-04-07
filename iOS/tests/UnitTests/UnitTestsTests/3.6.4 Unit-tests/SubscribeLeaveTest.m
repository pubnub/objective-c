//
//  SubscribeLeaveTest.m
//  pubnub
//
//  Created by Valentin Tuller on 3/4/14.
//  Copyright (c) 2014 PubNub Inc. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "PubNub.h"
#import "PubNub+Protected.h"
#import "PNConfiguration.h"
#import "PNWriteBuffer.h"
#import "PNConstants.h"
#import "PNNotifications.h"
#import "PNPresenceEvent.h"

// TODO: Investigate why test fails when we
// increase number of channels to more than 5.

static const NSUInteger kNumberOfTestChannels = 5;

@interface SubscribeLeaveTest : XCTestCase <PNDelegate> {
    
	int leaveDelegateCount;
	int joinDelegateCount;
	int timeoutDelegateCount;
	int leaveNotificationCount;
	int joinNotificationCount;
	int timeoutNotificationCount;
	int didReceiveMessageCount;
    
    NSMutableArray *_events;
    
    GCDGroup *_receiveMessageGroup;
    GCDGroup *_unsubscribeGroup;
    
    // to observe leave events
    PubNub *_pubNubClient;
    
    NSMutableArray *_channels;
}

@end

@implementation SubscribeLeaveTest

- (void)tearDown {
    [PubNub disconnect];
    
    [super tearDown];
}

- (void)setUp {
    [super setUp];
    
    [PubNub disconnect];
    
    _events = [NSMutableArray array];
}

#pragma mark - Tests

- (void)testSubscribeOnChannels {
    
    _channels = [NSMutableArray arrayWithCapacity:kNumberOfTestChannels];
    
    // generate channel names
    for( int i = 0; i < kNumberOfTestChannels; i++ ) {
        [_channels addObject:[PNChannel channelWithName:[NSString stringWithFormat: @"ch%d", i] shouldObservePresence:YES]];
    }
    
    [PubNub setDelegate:self];
    
    // subscribe to all notifications
    
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter addObserver:self
                           selector:@selector(kPNClientDidReceivePresenceEventNotification:)
                               name:kPNClientDidReceivePresenceEventNotification
                             object:nil];
    [notificationCenter addObserver:self
                           selector:@selector(handleClientDidReceiveMessage:)
                               name:kPNClientDidReceiveMessageNotification
                             object:nil];
    
    PNConfiguration *configuration = [PNConfiguration defaultTestConfiguration];
    [PubNub setConfiguration:configuration];
    
    GCDGroup *resGroup = [GCDGroup group];
    
    [resGroup enter];
    
    [PubNub connectWithSuccessBlock:^(NSString *origin) {
        NSLog(@"{BLOCK} PubNub client connected to: %@", origin);
        [resGroup leave];
    }
                         errorBlock:^(PNError *connectionError) {
                             NSLog(@"connectionError %@", connectionError);
                             [resGroup leave];
                             XCTFail(@"connectionError %@", connectionError);
                         }];
    
    if ([GCDWrapper isGCDGroup:resGroup timeoutFiredValue:kTestTestTimout]) {
        XCTFail(@"Timeout to connect to PubNub service");
        return;
    }
    
    _receiveMessageGroup = [GCDGroup group];
    [_receiveMessageGroup enter];
    
    for (PNChannel *channel in _channels) {
        [self subscribeOnChannels:@[channel]];
        
        NSString *message = [NSString stringWithFormat:@"text-%@", @([_channels indexOfObject:channel])];
        
        NSLog(@"Send message: %@ to channel: %@", message, channel);
        
        [PubNub sendMessage:message
                  toChannel:channel];
    }
    
    if ([GCDWrapper isGCDGroup:_receiveMessageGroup timeoutFiredValue:kTestTestTimout]) {
        XCTFail(@"Timeout to connect to PubNub service");
        return;
    }
    
    XCTAssertTrue( didReceiveMessageCount == [_channels count], @"%@ <> %@", @(didReceiveMessageCount), @([_channels count]));
    NSLog(@"%@ <> %@", @(didReceiveMessageCount), @([_channels count]));
    
    XCTAssertTrue( joinNotificationCount == _channels.count, @"joinDelegateCount: %@ channelNames.count: %@", @(joinNotificationCount), @(_channels.count));
    XCTAssertTrue( leaveDelegateCount == 0, @"leaveDelegateCount: %@ channelNames.count: %@", @(joinNotificationCount), @(_channels.count));
    
    XCTAssertTrue( joinNotificationCount == _channels.count, @"joinNotificationCount: %@ channelNames.count: %@", @(joinNotificationCount), @(_channels.count));
    XCTAssertTrue( leaveNotificationCount == 0, @"leaveNotificationCount: %@ channelNames.count %@", @(joinNotificationCount), @(_channels.count));
    
    XCTAssertTrue( timeoutDelegateCount == 0, @"timeoutCount %@", @(timeoutDelegateCount));
    XCTAssertTrue( timeoutNotificationCount == 0, @"timeoutCount %@", @(timeoutDelegateCount));
    
    
    // to observe leave events we should receive when singletone will unsubscribe
    
    _pubNubClient = [PubNub clientWithConfiguration:configuration
                                        andDelegate:self];
    
    [_pubNubClient connect];
    
    GCDGroup *subscribeGroup = [GCDGroup group];
    
    [subscribeGroup enter];
    
    [_pubNubClient subscribeOn:_channels
withCompletionHandlingBlock:^(PNSubscriptionProcessState state, NSArray *channels, PNError *subscriptionError) {
        NSLog(@"subscribeOnChannels end");
        XCTAssertNil( subscriptionError, @"subscriptionError %@", subscriptionError);
        
        [subscribeGroup leave];
    }];
    
    if ([GCDWrapper isGCDGroup:subscribeGroup timeoutFiredValue:kTestTestTimout]) {
        XCTFail(@"Timeout during second subscribe on request.");
        return;
    }

    // unsubscribe case
    
    _unsubscribeGroup = [GCDGroup group];
    
    [_unsubscribeGroup enterTimes:2];
    
    for (PNChannel *channel in _channels) {
        [self unsubscribeOnChannels:@[channel]];
    }
    
    if ([GCDWrapper isGCDGroup:_unsubscribeGroup timeoutFiredValue:kTestTestTimout]) {
        XCTFail(@"Timeout till waiting unsubscribe.");
        return;
    }
    
   XCTAssertTrue( joinDelegateCount == kNumberOfTestChannels, @"joinDelegateCount:%@ channelNames.count: %@", @(joinDelegateCount), @(_channels.count));
    XCTAssertTrue( leaveDelegateCount == kNumberOfTestChannels, @"leaveDelegateCount:%@ channelNames.count: %@", @(joinNotificationCount), @(_channels.count));
    XCTAssertTrue( joinNotificationCount == kNumberOfTestChannels, @"joinNotificationCount: %@, channelNames.count: %@", @(joinNotificationCount), @(_channels.count));
    XCTAssertTrue( leaveNotificationCount == kNumberOfTestChannels, @"leaveNotificationCount:%@ channelNames.count %@", @(joinNotificationCount), @(_channels.count));
    
    XCTAssertTrue( timeoutDelegateCount == 0, @"timeoutCount %@", @(timeoutDelegateCount));
    
    [_pubNubClient disconnect];
}

- (void)testSubscribeUnsubscribe {
    
    PNChannel *channel = [PNChannel channelWithName:@"ch0" shouldObservePresence:YES];
    
    PNConfiguration *configuration = [PNConfiguration defaultTestConfiguration];
    [PubNub setConfiguration:configuration];
        
    GCDGroup *resGroup = [GCDGroup group];
        
    [resGroup enterTimes:3];
        
    [PubNub connectWithSuccessBlock:^(NSString *origin) {
            NSLog(@"{BLOCK} PubNub client connected to: %@", origin);
            [resGroup leave];
        }
                             errorBlock:^(PNError *connectionError) {
                                 NSLog(@"connectionError %@", connectionError);
                                 [resGroup leave];
                                 XCTFail(@"connectionError %@", connectionError);
                             }];
    
    [PubNub subscribeOn:@[channel]
withCompletionHandlingBlock:^(PNSubscriptionProcessState state, NSArray *channels, PNError *error) {
    switch (state) {
        case PNSubscriptionProcessNotSubscribedState:
            
            // There should be a reason because of which subscription failed and it can be found in 'error' instance
            // Update user interface to let user know that something went wrong and do something to recover from this
            // state.
            //
            // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use
            // -localizedDescription / -localizedFailureReason and -localizedRecoverySuggestion to get human readable
            // description for error). 'error.associatedObject' contains array of PNChannel instances on which PubNub
            //client was unable to subscribe.
            [resGroup leave];
            XCTFail(@"Cannot subscribe to channel.");
            break;
        case PNSubscriptionProcessSubscribedState:
            
            // PubNub client completed subscription on specified set of channels.
            [resGroup leave];
            break;
        default:
            break;
    }
}];
    
    [PubNub sendMessage:@"Test Message"
              toChannel:channel
             compressed:YES
    withCompletionBlock:^(PNMessageState state, id data) {
        switch (state) {
            case PNMessageSending:
                
                // PubNub client is sending message at this moment. 'data' stores reference on PNMessage instance which is processing at this moment.
                break;
            case PNMessageSendingError:
                
                // PubNub client failed to send message and reason is in 'data' object.
            {
                [resGroup leave];
                XCTFail(@"Cannot send message.");
            }
                break;
            case PNMessageSent:
                
                // PubNub client successfully sent message to specified channel. 'data' stores reference on PNMessage instance which has been sent.
                [resGroup leave];
                break;
        }
    }];
    
    
    if ([GCDWrapper isGCDGroup:resGroup timeoutFiredValue:kTestTestTimout]) {
        XCTFail(@"Timeout to connect to PubNub service");
        return;
    }
    
    resGroup = [GCDGroup group];
    [resGroup enter];
    
    [PubNub unsubscribeFrom:@[[PNChannel channelWithName:@"ch0" shouldObservePresence:YES]]
withCompletionHandlingBlock:^(NSArray *channels, PNError *error) {
    NSLog(@"Channels: %@", channels);
    NSLog(@"Error: %@", error);
    [resGroup leave];
}];
    
    if ([GCDWrapper isGCDGroup:resGroup timeoutFiredValue:kTestTestTimout]) {
        XCTFail(@"Timeout during unsubscirbe from PubNub service");
        return;
    }
    
    NSLog(@"Finish test");
}


#pragma mark - Private

- (void)handleClientDidReceiveMessage:(NSNotification *)notification {
    NSLog(@"*** %@ handleClientDidReceiveMessage: %@", @(didReceiveMessageCount), [(PNMessage *)notification.userInfo message]);

    
    NSLog(@"%d Channel name: <%@>", didReceiveMessageCount, [[(PNMessage *)notification.userInfo channel] name]);
    
    didReceiveMessageCount++;
    
    if ([_receiveMessageGroup isEntered] && [[[_channels lastObject] name] isEqualToString:[[(PNMessage *)notification.userInfo channel] name]] && didReceiveMessageCount == [_channels count]) {
        [_receiveMessageGroup leave];
    }
}

- (void)subscribeOnChannels:(NSArray*)pnChannels {
    NSLog(@"subscribeOnChannels");
    
    GCDGroup *resGroup = [GCDGroup group];
    
    [resGroup enter];
    
    [PubNub subscribeOn:@[pnChannels[0]]
withCompletionHandlingBlock:^(PNSubscriptionProcessState state, NSArray *channels, PNError *subscriptionError) {
        NSLog(@"subscribeOnChannels end");
        XCTAssertNil( subscriptionError, @"subscriptionError %@", subscriptionError);
        if( pnChannels.count != channels.count ) {
            NSLog( @"pnChannels.count \n%@\n%@", pnChannels, channels);
        }
    
        [resGroup leave];
    
        XCTAssertEqualObjects( @(pnChannels.count), @(channels.count), @"pnChannels.count: %@ channels.count: %@", @(pnChannels.count), @(channels.count));
    }];
    NSLog(@"subscribeOnChannels runloop");
    
    if ([GCDWrapper isGCDGroup:resGroup timeoutFiredValue:kTestTestTimout]) {
        XCTFail(@"Timeout during subscribe on request.");
        return;
    }
}

- (void)unsubscribeOnChannels:(NSArray*)pnChannels {
    NSLog(@"unsubscribeFrom: %@", pnChannels);
    
    GCDGroup *resGroup = [GCDGroup group];
    
    [resGroup enter];
    
    NSLog(@"Channels: %@", pnChannels);
    
    [PubNub unsubscribeFrom:pnChannels
withCompletionHandlingBlock:^(NSArray *channels, PNError *unsubscribeError) {
        NSLog(@"unsubscribeOnChannel: %@", channels);
        NSLog(@"Error: %@", unsubscribeError);
    
        [resGroup leave];
    
        XCTAssertNil( unsubscribeError, @"unsubscribeError %@", unsubscribeError);
        XCTAssertEqualObjects( @(pnChannels.count), @(channels.count), @"pnChannels.count %@, channels.count: %@", @(pnChannels.count), @(channels.count));
    }];
    
    NSLog(@"unsubscribeOnChannels runloop");
    
    if ([GCDWrapper isGCDGroup:resGroup timeoutFiredValue:kTestTestTimout]) {
        XCTFail(@"Timeout during unsubscribe on request.");
        return;
    }
}

#pragma mark - PNDelegate

- (void)pubnubClient:(PubNub *)client didReceivePresenceEvent:(PNPresenceEvent *)event {
    
    NSLog(@"\n\npubnubClient didReceivePresenceEvent %@\n\n", event);
    if( event.type == PNPresenceEventJoin && [event.client.identifier isEqualToString:[PubNub clientIdentifier]]) {
        joinDelegateCount++;
    }
    
    if( event.type == PNPresenceEventLeave  && [event.client.identifier isEqualToString:[PubNub clientIdentifier]]) {
        leaveDelegateCount++;
        
        if (_unsubscribeGroup && leaveDelegateCount == [_channels count]) {
            [_unsubscribeGroup leave];
        }
    }
    
    if( event.type == PNPresenceEventTimeout  && [event.client.identifier isEqualToString:[PubNub clientIdentifier]]) {
        timeoutDelegateCount++;
    }
}

#pragma mark - Notifications

-(void)kPNClientDidReceivePresenceEventNotification:(NSNotification*)notification {
    
    NSLog(@"\n\nkPNClientDidReceivePresenceEventNotification %@\n\n", notification.userInfo);
    
    PNPresenceEvent *event = (PNPresenceEvent*)notification.userInfo;
    if( event.type == PNPresenceEventJoin  && [event.client.identifier isEqualToString:[PubNub clientIdentifier]]) {
        joinNotificationCount++;
    }
    if( event.type == PNPresenceEventLeave  && [event.client.identifier isEqualToString:[PubNub clientIdentifier]]) {
        leaveNotificationCount++;
        
        if (_unsubscribeGroup && leaveNotificationCount == [_channels count]) {
            [_unsubscribeGroup leave];
        }
    }
    if( event.type == PNPresenceEventTimeout  && [event.client.identifier isEqualToString:[PubNub clientIdentifier]]) {
        timeoutNotificationCount++;
    }
}

@end
