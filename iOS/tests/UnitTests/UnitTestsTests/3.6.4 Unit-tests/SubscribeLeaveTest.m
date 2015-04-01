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

@interface SubscribeLeaveTest : XCTestCase <PNDelegate> {
    
	int leaveDelegateCount;
	int joinDelegateCount;
	int timeoutDelegateCount;
	int leaveNotificationCount;
	int joinNotificationCount;
	int timeoutNotificationCount;
    
	NSMutableArray *_channelNames;
	int didReceiveMessageCount;
    
    NSMutableArray *_events;
    
    GCDGroup *_resGroup;
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

- (void)test10SubscribeOnChannels {
    
    _channelNames = [NSMutableArray array];
    
    // generate channel names
    for( int i = 0; i < 10; i++ ) {
        [_channelNames addObject:[NSString stringWithFormat: @"ch%d", i]];
    }
    
//    [PubNub resetClient];
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
    
    /*
    joinDelegateCount = 0;
    leaveDelegateCount = 0;
    timeoutDelegateCount = 0;
    joinNotificationCount = 0;
    leaveNotificationCount = 0;
    timeoutNotificationCount = 0;
    didReceiveMessageCount = 0;
     */
    
    _resGroup = [GCDGroup group];
    [_resGroup enter];
    
    for(int i = 0; i < _channelNames.count; i++ ) {
        [self subscribeOnChannels:@[[PNChannel channelWithName: _channelNames[i] shouldObservePresence:YES]]
                withPresenceEvent:YES];
        NSString *message = [NSString stringWithFormat:@"text-%@", @(i)];
        
        NSLog(@"Send message: %@ to channel: %@", message, _channelNames[i]);
        
        [PubNub sendMessage:message
                  toChannel: [PNChannel channelWithName: _channelNames[i]] ];
    }
    
    if ([GCDWrapper isGCDGroup:_resGroup timeoutFiredValue:kTestTestTimout]) {
        XCTFail(@"Timeout to connect to PubNub service");
        return;
    }
    
    XCTAssertTrue( didReceiveMessageCount == [_channelNames count], @"%@ <> %@", @(didReceiveMessageCount), @([_channelNames count]));
    NSLog(@"%@ <> %@", @(didReceiveMessageCount), @([_channelNames count]));
    
    XCTAssertTrue( joinNotificationCount == _channelNames.count, @"joinDelegateCount: %@ channelNames.count: %@", @(joinNotificationCount), @(_channelNames.count));
    XCTAssertTrue( leaveDelegateCount == 0, @"leaveDelegateCount: %@ channelNames.count: %@", @(joinNotificationCount), @(_channelNames.count));
    
    XCTAssertTrue( joinNotificationCount == _channelNames.count, @"joinNotificationCount: %@ channelNames.count: %@", @(joinNotificationCount), @(_channelNames.count));
    XCTAssertTrue( leaveNotificationCount == 0, @"leaveNotificationCount: %@ channelNames.count %@", @(joinNotificationCount), @(_channelNames.count));
    
    XCTAssertTrue( timeoutDelegateCount == 0, @"timeoutCount %@", @(timeoutDelegateCount));
    XCTAssertTrue( timeoutNotificationCount == 0, @"timeoutCount %@", @(timeoutDelegateCount));
    
    // unsubscribe case
    
    joinDelegateCount = 0;
    leaveDelegateCount = 0;
    joinNotificationCount = 0;
    leaveNotificationCount = 0;
    timeoutDelegateCount = 0;
    
    for( int i=0; i<_channelNames.count; i++ )
        [self unsubscribeOnChannels:[PNChannel channelsWithNames: @[_channelNames[i]]] withPresenceEvent: YES];
    
    for( int i=0; i<10; i++ )
        [[NSRunLoop currentRunLoop] runUntilDate: [NSDate dateWithTimeIntervalSinceNow: 1.0] ];
    
    
    XCTAssertTrue( joinDelegateCount == 0, @"joinDelegateCount:%@ channelNames.count: %@", @(joinNotificationCount), @(_channelNames.count));
    XCTAssertTrue( leaveDelegateCount == 0, @"leaveDelegateCount:%@ channelNames.count: %@", @(joinNotificationCount), @(_channelNames.count));
    
    XCTAssertTrue( joinNotificationCount == 0, @"joinNotificationCount %d, channelNames.count %d", joinNotificationCount, _channelNames.count);
    XCTAssertTrue( leaveNotificationCount == 0, @"leaveNotificationCount %d, channelNames.count %d", joinNotificationCount, _channelNames.count);
    
    XCTAssertTrue( timeoutDelegateCount == 0, @"timeoutCount %d", timeoutDelegateCount);
    //	[self unsubscribeOnChannels: pnChannels2 withPresenceEvent: NO];
}

-(void)kPNClientDidReceivePresenceEventNotification:(NSNotification*)notification {
    
	NSLog(@"\n\nkPNClientDidReceivePresenceEventNotification %@\n\n", notification.userInfo);
    
    PNPresenceEvent *event = (PNPresenceEvent*)notification.userInfo;
    if( event.type == PNPresenceEventJoin ) {
        joinNotificationCount++;
    }
    if( event.type == PNPresenceEventLeave ) {
        leaveNotificationCount++;
    }
    if( event.type == PNPresenceEventTimeout ) {
        timeoutNotificationCount++;
    }
}

#pragma mark - Private

- (void)handleClientDidReceiveMessage:(NSNotification *)notification {
    NSLog(@"*** %@ handleClientDidReceiveMessage: %@", @(didReceiveMessageCount), [(PNMessage *)notification.userInfo message]);

    
    NSLog(@"%d Channel name: <%@>", didReceiveMessageCount, [[(PNMessage *)notification.userInfo channel] name]);
    
    didReceiveMessageCount++;
    
    if ([_resGroup isEntered] && [[_channelNames lastObject] isEqualToString:[[(PNMessage *)notification.userInfo channel] name]]) {
        [_resGroup leave];
    }
}

- (void)subscribeOnChannels:(NSArray*)pnChannels withPresenceEvent:(BOOL)presenceEvent {
    NSLog(@"subscribeOnChannels");
    __block BOOL isCompletionBlockCalled = NO;
    //	[PubNub subscribeOnChannel: pnChannels[0] withCompletionHandlingBlock: ^(PNSubscriptionProcessState state, NSArray *channels, PNError *subscriptionError) {
    [PubNub subscribeOnChannel:pnChannels[0] withCompletionHandlingBlock:^(PNSubscriptionProcessState state, NSArray *channels, PNError *subscriptionError) {
        NSLog(@"subscribeOnChannels end");
        isCompletionBlockCalled = YES;
        XCTAssertNil( subscriptionError, @"subscriptionError %@", subscriptionError);
        if( pnChannels.count != channels.count ) {
            NSLog( @"pnChannels.count \n%@\n%@", pnChannels, channels);
        }
        XCTAssertEqualObjects( @(pnChannels.count), @(channels.count), @"pnChannels.count %d, channels.count %d", pnChannels.count, channels.count);
    }];
    NSLog(@"subscribeOnChannels runloop");
    for( int i=0; i<[PubNub sharedInstance].configuration.subscriptionRequestTimeout+1 && isCompletionBlockCalled == NO; i++ )
        [[NSRunLoop currentRunLoop] runUntilDate: [NSDate dateWithTimeIntervalSinceNow: 1.0] ];
    XCTAssertTrue( isCompletionBlockCalled, @"completion block not called");
}

- (void)unsubscribeOnChannels:(NSArray*)pnChannels withPresenceEvent:(BOOL)presenceEvent {
    NSLog(@"unsubscribeOnChannels");
    __block BOOL isCompletionBlockCalled = NO;
    
    [PubNub unsubscribeFromChannels:pnChannels withCompletionHandlingBlock:^(NSArray *channels, PNError *unsubscribeError) {
        NSLog(@"unsubscribeOnChannels end");
        isCompletionBlockCalled = YES;
        XCTAssertNil( unsubscribeError, @"unsubscribeError %@", unsubscribeError);
        XCTAssertEqualObjects( @(pnChannels.count), @(channels.count), @"pnChannels.count %d, channels.count %d", pnChannels.count, channels.count);
    }];
    NSLog(@"unsubscribeOnChannels runloop");
    for( int i=0; i<[PubNub sharedInstance].configuration.subscriptionRequestTimeout+1 &&
        isCompletionBlockCalled == NO; i++ )
        [[NSRunLoop currentRunLoop] runUntilDate: [NSDate dateWithTimeIntervalSinceNow: 1.0] ];
    XCTAssertTrue( isCompletionBlockCalled, @"completion block not called");
}

#pragma mark - PNDelegate

- (void)pubnubClient:(PubNub *)client didReceivePresenceEvent:(PNPresenceEvent *)event {
    
    NSLog(@"\n\npubnubClient didReceivePresenceEvent %@\n\n", event);
    if( event.type == PNPresenceEventJoin ) {
        joinDelegateCount++;
    }
    
    if( event.type == PNPresenceEventLeave ) {
        leaveDelegateCount++;
    }
    
    if( event.type == PNPresenceEventTimeout ) {
        timeoutDelegateCount++;
    }
}

@end
