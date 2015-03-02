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

static const NSUInteger kAmountOfChannels = 15;

@interface ChangingChannels : XCTestCase <PNDelegate>

@end

@implementation ChangingChannels {
    GCDGroup *_resGroup;
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
    
    GCDGroup *resGroup = [GCDGroup group];
    
    [resGroup enter];
    
    PNConfiguration *configuration = [PNConfiguration defaultConfiguration];
    [PubNub setConfiguration:configuration];

    [PubNub connectWithSuccessBlock:^(NSString *origin) {
        [resGroup leave];
    }
                         errorBlock:^(PNError *connectionError) {
                             XCTFail(@"Error during connect to PubNub: %@", connectionError);
                             [resGroup leave];
                         }];
    
    if ([GCDWrapper isGCDGroup:resGroup timeoutFiredValue:10]) {
        XCTFail(@"Timeout to connect to PubNub service");
        return;
    }
    
	[self subscribeToNumberOfChannels:kAmountOfChannels];
}

-(void)subscribeToNumberOfChannels:(NSUInteger)amountOfChannels {
    
    NSMutableArray *channelNames = [NSMutableArray arrayWithCapacity:amountOfChannels];
    _resGroup = [GCDGroup group];
    
	for(int i = 0; i < amountOfChannels; i++) {
        
		NSString *channelName = [NSString stringWithFormat: @"channel%d", i];
        [channelNames addObject:channelName];
        
		NSArray *channels = [PNChannel channelsWithNames:@[channelName]];
        
        [_resGroup enter];
        
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
            
            [_resGroup leave];
        }
    }];
    }
    
    if ([GCDWrapper isGCDGroup:_resGroup timeoutFiredValue:30]) {
        XCTFail(@"It seems we didn't receive all completion blocks: %d", [_resGroup timesEntered]);
    }
    
    _resGroup = nil;
}

@end
