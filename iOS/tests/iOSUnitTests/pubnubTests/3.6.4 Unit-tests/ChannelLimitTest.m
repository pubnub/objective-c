//
//  ChannelLimitTest.m
//  pubnub
//
//  Created by Valentin Tuller on 11/20/13.
//  Copyright (c) 2013 PubNub Inc. All rights reserved.
//
// Old results: Executed 1 test, with 0 failures (0 unexpected) in 171.068 (171.074) seconds

#import <SenTestingKit/SenTestingKit.h>
#import "PNBaseRequest.h"
#import "PNBaseRequest+Protected.h"
#import "PubNub.h"
#import "PubNub+Protected.h"
#import "PNConfiguration.h"
#import "PNWriteBuffer.h"
#import "PNConstants.h"

@interface ChannelLimitTest : SenTestCase <PNDelegate> {
	int clientUnsubscriptionDidCompleteNotificationCount;
}

@end

@implementation ChannelLimitTest {
    dispatch_group_t _resGroup;
}

-(void)resetConnection {
	[PubNub resetClient];
    
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
         
		 STAssertTrue( interval < [PubNub sharedInstance].configuration.subscriptionRequestTimeout+1, @"Timeout error, %d instead of %d", interval, [PubNub sharedInstance].configuration.subscriptionRequestTimeout);

		 STAssertFalse(messageSendingState==PNMessageSendingError, @"messageSendingState==PNMessageSendingError %@", data);
         
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

	NSMutableArray *arr = [NSMutableArray array];
	int i=0;
	for( ; i<20; i++ ) {
		NSString *channelName = [NSString stringWithFormat: @"%@ %d", [NSDate date], i];
		[arr addObject: channelName];
	}

	__block NSDate *start = [NSDate date];
    
    dispatch_group_t subscribeGroup = dispatch_group_create();
    
    dispatch_group_enter(subscribeGroup);
    
	[PubNub subscribeOnChannels: [PNChannel channelsWithNames: arr]
	withCompletionHandlingBlock:^(PNSubscriptionProcessState state, NSArray *channels, PNError *subscriptionError)
	 {
		 NSTimeInterval interval = -[start timeIntervalSinceNow];
		 NSLog(@"subscribed arr %f, error %@", interval, subscriptionError);
         
		 STAssertTrue( interval < [PubNub sharedInstance].configuration.subscriptionRequestTimeout+1, @"Timeout error, %d instead of %d", interval, [PubNub sharedInstance].configuration.subscriptionRequestTimeout);

		 STAssertNil( subscriptionError, @"arr subscriptionError %@", subscriptionError);
         
         dispatch_group_leave(subscribeGroup);
	 }];
    
	STAssertTrue(![GCDWrapper isGroup:subscribeGroup
                   timeoutFiredValue:[PubNub sharedInstance].configuration.subscriptionRequestTimeout+1], @"timout fired");

	__block int requestFinishedCount = 0;
	start = [NSDate date];
    
	NSString *message = [NSString stringWithFormat: @"%@", arr];
	message = [arr description];
	message = [message substringToIndex: 500];
    
	message = [message stringByReplacingOccurrencesOfString:@"\"" withString: @"\\\""];
    
    dispatch_group_t sendMessage = dispatch_group_create();

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
    
	for( ; i<10; i++ ) {
		NSString *channelName = [NSString stringWithFormat: @"%@ %d", [NSDate date], i];
		NSArray *arr = [PNChannel channelsWithNames: @[channelName]];
		NSDate *start = [NSDate date];
        
		NSLog(@"Start subscribe to channel %@", channelName);
        
		__block NSArray *subscribedChannels = nil;
        
        
        dispatch_group_enter(sendMessage);
        
		[PubNub subscribeOnChannels: arr
		withCompletionHandlingBlock:^(PNSubscriptionProcessState state, NSArray *channels, PNError *subscriptionError)
		 {
			 subscribedChannels = channels;
			 NSTimeInterval interval = -[start timeIntervalSinceNow];
			 NSLog(@"subscribed %f, %@", interval, subscriptionError);
			 STAssertTrue( interval < [PubNub sharedInstance].configuration.subscriptionRequestTimeout+1, @"Timeout error, %d instead of %d", interval, [PubNub sharedInstance].configuration.subscriptionRequestTimeout);

			 STAssertNil( subscriptionError, @"channel %@, \nsubscriptionError %@", channelName, subscriptionError);
             
            dispatch_group_leave(sendMessage);
		 }];
        
		STAssertTrue(![GCDWrapper isGroup:sendMessage
                       timeoutFiredValue:[PubNub sharedInstance].configuration.subscriptionRequestTimeout+1], @"timeout for channel name: %@", channelName);

		for( int j=0; j<subscribedChannels.count; j++ ) {
			if( [[subscribedChannels[j] name] isEqualToString: channelName] == YES ) {
				[self sendMessage: channelName toChannelWithName: channelName];
				break;
			}
		}
	}

	NSMutableArray *arrChannel = [NSMutableArray arrayWithArray: [PubNub subscribedChannels]];
    
	NSLog(@"[PubNub subscribedChannels] %@", [PubNub subscribedChannels]);
    
	for( int i=0; i < arrChannel.count; i++) {
        
		__block PNChannel *channel = arrChannel[i];
		__block int blockCount = 0;
        
        dispatch_group_t unsubGroup = dispatch_group_create();
        
        dispatch_group_enter(unsubGroup);
        
		NSLog(@"start unsubscribeFromChannels %@", channel);
		clientUnsubscriptionDidCompleteNotificationCount = 0;
		[PubNub unsubscribeFromChannels: @[channel] withCompletionHandlingBlock:^(NSArray *channels, PNError *unsubscribeError) {
			NSLog(@"unsubscribeFromChannels %@", channel);
			NSLog(@"block isSubscribedOnChannel %d", [PubNub isSubscribedOnChannel: channel]);
			STAssertNil( unsubscribeError, @"unsubscribeError %@", unsubscribeError);
			blockCount++;
		}];
        
        [GCDWrapper waitGroup:unsubGroup];
        
		STAssertTrue(clientUnsubscriptionDidCompleteNotificationCount>0, @"notification not called");
		STAssertFalse(clientUnsubscriptionDidCompleteNotificationCount>1, @"notification called repeatedly, %d", clientUnsubscriptionDidCompleteNotificationCount);
		STAssertTrue(blockCount>0, @"block not called");
		STAssertFalse(blockCount>1, @"block called repeatedly, %d", blockCount);
	}
}

-(void)kPNClientUnsubscriptionDidCompleteNotification:(NSNotification*)notification {
	clientUnsubscriptionDidCompleteNotificationCount++;
}

@end
