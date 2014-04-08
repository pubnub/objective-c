//
//  PNChannelHistoryView.h
//  pubnub
//
//  Created by Sergey Mamontov on 4/3/14.
//  Copyright (c) 2014 PubNub Inc. All rights reserved.
//

#import "PNInputFormView.h"


#pragma mark - Public interface declaration

@interface PNChannelHistoryView : PNInputFormView


#pragma mark - Class methods

/**
 Retrieve reference on the view which will provide user UI to fetch full history for concrete channel.
 */
+ (instancetype)viewFromNibForFullChannelHistory;

/**
 Retrieve reference on the view which will provide user UI to fetch history for limited period in time for concrete channel.
 */
+ (instancetype)viewFromNibForChannelHistory;


#pragma mark - Instance methods

/**
 Prepare channel history UI for concrete channel.
 
 @param channel
 \b PNChannel instance which should be used for interface layout and data configurraiton.
 */
- (void)configureForChannel:(PNChannel *)channel;

#pragma mark -


@end
