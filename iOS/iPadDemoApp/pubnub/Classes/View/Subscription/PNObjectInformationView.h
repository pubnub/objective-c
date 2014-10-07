//
//  PNObjectInformationView.h
//  pubnub
//
//  Created by Sergey Mamontov on 2/28/14.
//  Copyright (c) 2014 PubNub Inc. All rights reserved.
//

#import "PNInputFormView.h"
#import "PNObjectInformationDelegate.h"


#pragma mark Class forward

@class PNChannel;


#pragma mark - Public interface implementation

@interface PNObjectInformationView : PNInputFormView


#pragma mark - Properties

/**
 Stores reference on delegate which will accept all events from channel information view.
 */
@property (nonatomic, pn_desired_weak) id<PNObjectInformationDelegate> delegate;

/**
 Stores whether view should allow some data editing or not.
 */
@property (nonatomic, assign, getter = shouldAllowEditing) BOOL allowEditing;


#pragma mark - Class methods

/**
 @brief Construct and configure view which can be used to view and edit channel group information.
 
 @return Configured and ready to use channel group information view.
 
 @since <#version number#>
 */
+ (instancetype)viewFromNibForChannelGroup;


#pragma mark - Instance methods

/**
 Update interface for concrete channel and it's state.
 
 @param object
 Object which represent remote data feed for which this view has been constructed.
 
 @param clientState
 \b NSDictionary instance which represent client's state on provided channel.
 
 @param shouldObservePresence
 Whether channel is made to observer presence observation.
 */
- (void)configureForObject:(id <PNChannelProtocol>)object withState:(NSDictionary *)channelState
    andPresenceObservation:(BOOL)shouldObservePresence;

#pragma mark -


@end
