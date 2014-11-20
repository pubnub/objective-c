//
//  ChangingChannels.m
//  pubnub
//
//  Created by Valentin Tuller on 10/21/13.
//  Copyright (c) 2013 PubNub Inc. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "PNBaseRequest.h"
#import "PNBaseRequest+Protected.h"

#import "PubNub.h"
#import "PubNub+Protected.h"
#import "PNConfiguration.h"
#import "PNWriteBuffer.h"
#import "PNConstants.h"

static const NSUInteger kAmountOfChannels = 20;

@interface ChangingChannels : XCTestCase <PNDelegate>

@end

@implementation ChangingChannels {
    dispatch_group_t _resGroup;
}

- (void)setUp
{
    [super setUp];
    [PubNub setDelegate:self];
    
    [PubNub disconnect];
}

- (void)tearDown {
	[super tearDown];
    
    [PubNub disconnect];
}

#pragma mark - Tests

- (void)testConnect {
    
    dispatch_group_t resGroup = dispatch_group_create();
    
    dispatch_group_enter(resGroup);
    
    PNConfiguration *configuration = [PNConfiguration configurationForOrigin:@"pubsub.pubnub.com" publishKey:@"demo" subscribeKey:@"demo" secretKey: nil cipherKey: nil];
    [PubNub setConfiguration:configuration];

    [PubNub connectWithSuccessBlock:^(NSString *origin) {
        dispatch_group_leave(resGroup);
    }
                         errorBlock:^(PNError *connectionError) {
                             XCTFail(@"Error during connect to PubNub: %@", connectionError);
                            dispatch_group_leave(resGroup);
                         }];
    
    if ([GCDWrapper isGroup:resGroup timeoutFiredValue:20]) {
        XCTFail(@"Timeout to connect to PubNub service");
        dispatch_group_leave(resGroup);
        return;
    }
    
    resGroup = NULL;
    
	[self subscribeToNumberOfChannels:kAmountOfChannels];
}

-(void)subscribeToNumberOfChannels:(NSUInteger)amountOfChannels {
    
    NSMutableArray *channelNames = [NSMutableArray arrayWithCapacity:amountOfChannels];
    _resGroup = dispatch_group_create();
    
	for(int i = 0; i < amountOfChannels; i++) {
        
		NSString *channelName = [NSString stringWithFormat: @"%@ %d", [NSDate date], i];
        channelName = [channelName stringByReplacingOccurrencesOfString:@":" withString:@"-"];
        
        [channelNames addObject:channelName];
        
		NSArray *channels = [PNChannel channelsWithNames:@[channelName]];
        
		NSLog(@"Start subscribe to channel %@", channelName);
        
        dispatch_group_enter(_resGroup);
        
        // subscription time cannot be more than subscriptionRequestTimeout
        
        NSDate *startDate = [NSDate date];
        
        [PubNub subscribeOn:channels
    withCompletionHandlingBlock:^(PNSubscriptionProcessState state, NSArray *channels, PNError *error) {
        
        XCTAssertNil(error, @"subscriptionError %@", error);
        
        if(error == nil ) {
            
            BOOL isSubscribed = NO;
            for( int j = 0; j < channels.count; j++ ) {
                if ( [channelNames containsObject:[channels[j] name]]) {
                    isSubscribed = YES;
                    break;
                }
            }
            
            XCTAssertTrue( isSubscribed == YES, @"Channel is not subscribed");
        }
        
        if (state == PNSubscriptionProcessSubscribedState) {
            NSDate *finishDate = [NSDate date];
            
            NSTimeInterval interval = [finishDate timeIntervalSinceDate:startDate];
            NSLog(@"Subscribed %f, %@", interval, channels);
            
            XCTAssertTrue( interval < [PubNub sharedInstance].configuration.subscriptionRequestTimeout, @"Timeout error, %f instead of %f", interval, [PubNub sharedInstance].configuration.subscriptionRequestTimeout);
            
            dispatch_group_leave(_resGroup);
        }
    }];
        
    }
    
    if ([GCDWrapper isGroup:_resGroup timeoutFiredValue:30]) {
        XCTFail(@"It seems we didn't receive all completion blocks.");
    }
}

@end
