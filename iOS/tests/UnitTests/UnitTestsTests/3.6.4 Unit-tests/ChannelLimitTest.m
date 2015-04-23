//
//  ChannelLimitTest.m
//  pubnub
//
//  Created by Sergey Kazanskiy on 12/10/14.
//  Copyright (c) 2014 PubNub Inc. All rights reserved.
//
// Old results: Executed 1 test, with 0 failures (0 unexpected) in 171.068 (171.074) seconds

#import <XCTest/XCTest.h>
#import "PNBaseRequest.h"
#import "PNBaseRequest+Protected.h"
#import "PubNub.h"
#import "PubNub+Protected.h"
#import "PNConfiguration.h"
#import "PNWriteBuffer.h"
#import "PNConstants.h"

@interface ChannelLimitTest : XCTestCase <PNDelegate> {
	int clientUnsubscriptionDidCompleteNotificationCount;
}

@end

@implementation ChannelLimitTest {
    dispatch_group_t _resGroup;
}

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    
    [PubNub disconnect];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [PubNub disconnect];
    
    [super tearDown];
}

#pragma mark - Tests

-(void)resetConnection {
    
    dispatch_group_t resetGroup = dispatch_group_create();
    dispatch_group_enter(resetGroup);
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [PubNub setDelegate:self];
		[PubNub setConfiguration: [PNConfiguration defaultConfiguration]];
        
		[PubNub connectWithSuccessBlock:^(NSString *origin) {
            
			dispatch_group_leave(resetGroup);
		}
							 errorBlock:^(PNError *connectionError) {
			dispatch_group_leave(resetGroup);
							 }];
    });
    
    [GCDWrapper waitGroup:resetGroup];
}

-(void)sendMessage:(NSString*)message toChannelWithName:(NSString*)channelName
{
	PNChannel *channel = [PNChannel channelWithName: channelName];
	NSDate *start = [NSDate date];
    
    dispatch_group_t sendMessageGroup = dispatch_group_create();
    dispatch_group_enter(sendMessageGroup);
    
	[PubNub sendMessage: message toChannel: channel withCompletionBlock:^(PNMessageState messageSendingState, id data)
	 {
		 if( messageSendingState == PNMessageSending )
			 return;
         
		 NSTimeInterval interval = -[start timeIntervalSinceNow];
         
		 XCTAssertTrue( interval < [PubNub sharedInstance].configuration.subscriptionRequestTimeout+1, @"Timeout error, %f instead of %f", interval, [PubNub sharedInstance].configuration.subscriptionRequestTimeout);

		 XCTAssertFalse(messageSendingState==PNMessageSendingError, @"messageSendingState==PNMessageSendingError %@", data);
         
         dispatch_group_leave(sendMessageGroup);
	 }];

    [GCDWrapper waitGroup:sendMessageGroup];
}

- (void)test60SubscribeOnChannelsByTurns {
	[self resetConnection];

	NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
	[notificationCenter addObserver:self
						   selector:@selector(kPNClientUnsubscriptionDidCompleteNotification:)
							   name:kPNClientUnsubscriptionDidCompleteNotification
							 object:nil];
    
//    Array of channels
	NSMutableArray *arr = [NSMutableArray array];
	int i = 0;
	for( ; i<20; i++ ) {
		NSString *channelName = [NSString stringWithFormat: @"Channel%d", i];
		[arr addObject: channelName];
	}
    NSArray *_channels = [PNChannel channelsWithNames:arr];
    
//    Subscribe on channels
    dispatch_group_t subscribeGroup = dispatch_group_create();
    dispatch_group_enter(subscribeGroup);
	__block NSDate *start = [NSDate date];
    
 	[PubNub subscribeOn:_channels
	withCompletionHandlingBlock:^(PNSubscriptionProcessState state, NSArray *channels, PNError *subscriptionError)
	 {
         switch (state) {
             case PNSubscriptionProcessNotSubscribedState:
                 break;
             case PNSubscriptionProcessSubscribedState:
                 dispatch_group_leave(subscribeGroup);
                 break;
             case PNSubscriptionProcessWillRestoreState:
                 break;
             case PNSubscriptionProcessRestoredState:
                 break;
         }

		 NSTimeInterval interval = -[start timeIntervalSinceNow];
		 NSLog(@"subscribed arr %f, error %@", interval, subscriptionError);
         
		 XCTAssertTrue( interval < [PubNub sharedInstance].configuration.subscriptionRequestTimeout+1, @"Timeout error, %f instead of %f", interval, [PubNub sharedInstance].configuration.subscriptionRequestTimeout);
		 XCTAssertNil( subscriptionError, @"arr subscriptionError %@", subscriptionError);
         
	 }];
    
	XCTAssertTrue(![GCDWrapper isGroup:subscribeGroup
                   timeoutFiredValue:[PubNub sharedInstance].configuration.subscriptionRequestTimeout+1], @"timout fired");
    
//    Send message
    dispatch_group_t sendMessage = dispatch_group_create();
    
    __block int requestFinishedCount = 0;
	start = [NSDate date];
    
	NSString *message = [NSString stringWithFormat: @"%@", arr];
	message = [arr description];
	message = [message substringToIndex: 50];
 	message = [message stringByReplacingOccurrencesOfString:@"\"" withString: @"\\\""];
    
 
	for( int i=0; i<arr.count; i++ ) {
        
        dispatch_group_enter(sendMessage);

		[PubNub sendMessage: message toChannel: [PNChannel channelWithName: arr[i]]
		withCompletionBlock:^(PNMessageState messageSendingState, id data) {
			if( messageSendingState == PNMessageSending) {
				start = [NSDate date];
				return;
			}
			requestFinishedCount++;
			NSTimeInterval interval = -[start timeIntervalSinceNow];
			NSLog( @"test50SendMessageTimeout, index %d, time %f, %@", i, interval, (messageSendingState==PNMessageSendingError) ? data : @"" );
            
            dispatch_group_leave(sendMessage);
		}];
    }
    
    [GCDWrapper waitGroup:sendMessage];
    
//    Unsubscribe from channels
    dispatch_group_t unsubscribeGroup = dispatch_group_create();
    dispatch_group_enter(unsubscribeGroup);
    
    [PubNub unsubscribeFrom:_channels withCompletionHandlingBlock:^(NSArray *channels, PNError *error) {
        if (!error)
            dispatch_group_leave(unsubscribeGroup);
    }];
    
    [GCDWrapper waitGroup:unsubscribeGroup];

//    Subscribe on channels in order
	for( int i=0; i<10; i++ ) {
        
        NSString *channelName = [NSString stringWithFormat: @"Channel%d", i];
		NSArray *arr = [PNChannel channelsWithNames: @[channelName]];
		__block NSArray *subscribedChannels = nil;
         dispatch_group_enter(sendMessage);
        
        [PubNub subscribeOn: arr
        withCompletionHandlingBlock:^(PNSubscriptionProcessState state, NSArray *channels, PNError *subscriptionError)
		 {
			 subscribedChannels = channels;
			 NSTimeInterval interval = -[start timeIntervalSinceNow];
			 NSLog(@"subscribed %f, %@", interval, subscriptionError);
//			 XCTAssertTrue( interval < [PubNub sharedInstance].configuration.subscriptionRequestTimeout+1, @"Timeout error, %f instead of %f", interval, [PubNub sharedInstance].configuration.subscriptionRequestTimeout);

			 XCTAssertNil( subscriptionError, @"channel %@, \nsubscriptionError %@", channelName, subscriptionError);
            dispatch_group_leave(sendMessage);
		 }];
        
		XCTAssertTrue(![GCDWrapper isGroup:sendMessage
                       timeoutFiredValue:[PubNub sharedInstance].configuration.subscriptionRequestTimeout+1], @"timeout for channel name: %@", channelName);

		for( int j=0; j<subscribedChannels.count; j++ ) {
			if( [[subscribedChannels[j] name] isEqualToString: channelName] == YES ) {
				[self sendMessage: channelName toChannelWithName: channelName];
				break;
			}
		}
	}

//    Unsubscribe from channels in order
    dispatch_group_t unsubGroup = dispatch_group_create();
    NSMutableArray *arrChannel = [NSMutableArray arrayWithArray: [PubNub subscribedObjectsList]];
    
	for( int i=0; i < arrChannel.count; i++) {
        dispatch_group_enter(unsubGroup);
       
		PNChannel *channel = arrChannel[i];
		NSLog(@"start unsubscribeFromChannels %@", channel);
		clientUnsubscriptionDidCompleteNotificationCount = 0;

		[PubNub unsubscribeFrom: @[channel] withCompletionHandlingBlock:^(NSArray *channels, PNError *unsubscribeError) {
			NSLog(@"block isSubscribedOnChannel %d", [PubNub isSubscribedOn: channel]);
			XCTAssertNil( unsubscribeError, @"unsubscribeError %@", unsubscribeError);
            dispatch_group_leave(unsubGroup);
		}];
        
        
		XCTAssertFalse(clientUnsubscriptionDidCompleteNotificationCount=0, @"notification not called");
		XCTAssertFalse(clientUnsubscriptionDidCompleteNotificationCount>1, @"notification called repeatedly, %d", clientUnsubscriptionDidCompleteNotificationCount);
	}
    [GCDWrapper waitGroup:unsubGroup];
}

-(void)kPNClientUnsubscriptionDidCompleteNotification:(NSNotification*)notification {
	clientUnsubscriptionDidCompleteNotificationCount++;
}

@end
