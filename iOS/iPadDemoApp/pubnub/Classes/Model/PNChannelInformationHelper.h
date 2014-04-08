//
//  PNChannelInformationHelper.h
//  pubnub
//
//  Created by Sergey Mamontov on 3/22/14.
//  Copyright (c) 2014 PubNub Inc. All rights reserved.
//

#import <Foundation/Foundation.h>


#pragma mark - Public interface declaration

@interface PNChannelInformationHelper : NSObject


#pragma mark - Properties

/**
 Stores reference on channel name which will be used to create new instance.
 */
@property (nonatomic, strong) NSString *channelName;

/**
 Stores whether channel should observe for presence events or not.
 */
@property (nonatomic, assign, getter = shouldObservePresence) BOOL observePresence;

/**
 Stores reference on original channel state (which has been fetched before). This object will be used to compare it with
 one which is show in interface and in case if it has been changed, send update request (in case if client subscribed on
 channel).
 */
@property (nonatomic, strong) NSDictionary *state;


#pragma mark - Instance methods

/**
 Allow to check whether valid information has been provided for new channel creation or not.
 
 @return \c YES if provided data can be used to create new channel which can be used in future.
 */
- (BOOL)canCreateChannel;

/**
 Allow to check whether presence observation for channel should be changed or not.
 
 @return \c YES in case if presence observation has been changed by user.
 */
- (BOOL)shouldChangePresenceObservationState;

/**
 Allow to check whether channel state information changed and should be updated on server or not.
 
 @return \c YES if user altered client state or not.
 */
- (BOOL)shouldChangeChannelState;

/**
 Validate state which is provided for channel.
 
 @return \c YES if state conforms to all requirements and can be used or not.
 */
- (BOOL)isChannelStateValid;

/**
 Allow to check whether channel information changed or not.
 
 @return \c YES if any information for existing channel changed (presence observation state, state information).
 */
- (BOOL)isChannelInformationChanged;

/**
 Clean up any warnings which has been set during previous actions.
 */
- (void)resetWarnings;

#pragma mark -


@end
