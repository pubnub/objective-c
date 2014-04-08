//
//  PNChannelPresenceView.h
//  pubnub
//
//  Created by Sergey Mamontov on 3/25/14.
//  Copyright (c) 2014 PubNub Inc. All rights reserved.
//

#import "PNInputFormView.h"


#pragma mark Public interface delcaration

@interface PNChannelPresenceView : PNInputFormView


#pragma mark - Instance methods

/**
 Configure view to show information for concrete channel.
 
 @param channel
 \b PNChannel instance which should be used for view configuration.
 */
- (void)configureForChannel:(PNChannel *)channel;

#pragma mark -


@end
