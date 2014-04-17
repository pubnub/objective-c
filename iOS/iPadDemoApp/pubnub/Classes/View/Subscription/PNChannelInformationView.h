//
//  PNChannelInformationView.h
//  pubnub
//
//  Created by Sergey Mamontov on 2/28/14.
//  Copyright (c) 2014 PubNub Inc. All rights reserved.
//

#import "PNInputFormView.h"
#import "PNChannelInformationDelegate.h"


#pragma mark Class forward

@class PNChannel;


#pragma mark - Public interface implementation

@interface PNChannelInformationView : PNInputFormView


#pragma mark - Properties

/**
 Stores reference on delegate which will accept all events from channel information view.
 */
@property (nonatomic, pn_desired_weak) id<PNChannelInformationDelegate> delegate;

/**
 Stores whether view should allow some data editing or not.
 */
@property (nonatomic, assign, getter = shouldAllowEditing) BOOL allowEditing;


#pragma mark - Instance methods

/**
 Update interface for concrete channel and it's state.
 
 @param channel
 \b PNChannel instance for which this information view has been constructed.
 
 @param clientState
 \b NSDictionary instance which represent client's state on provided channel.
 
 @param shouldObservePresence
 Whether channel is made to observer presence observation.
 */
- (void)configureForChannel:(PNChannel *)channel withState:(NSDictionary *)channelState andPresenceObservation:(BOOL)shouldObservePresence;

#pragma mark -


@end
