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


#pragma mark - Class methods

/**
 @brief Construct and configure view which can be used to view channel group presence information.
 
 @return Configured and ready to use channel group presence information view.
 
 @since 3.7.0
 */
+ (instancetype)viewFromNibForChannelGroup;


#pragma mark - Instance methods

/**
 Configure view to show information for concrete channel.
 
 @param object
 \b PNChannel or \b PNChannelGroup instance which should be used for view configuration.
 */
- (void)configureForObject:(id <PNChannelProtocol>)object;

#pragma mark -


@end
