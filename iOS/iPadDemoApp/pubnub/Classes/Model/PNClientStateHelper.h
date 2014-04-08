//
//  PNClientStateHelper.h
//  pubnub
//
//  Created by Sergey Mamontov on 3/29/14.
//  Copyright (c) 2014 PubNub Inc. All rights reserved.
//

#import <Foundation/Foundation.h>


#pragma mark Public interface declaration

@interface PNClientStateHelper : NSObject


#pragma mark - Properties

/**
 Allow to specify whether view allow state edition or not.
 */
@property (nonatomic, assign, getter = isStateEditingAllowed) BOOL stateEditingAllowed;

/**
 Stores whether at this moment user editing client's state or not.
 */
@property (nonatomic, assign, getter = isEditingState) BOOL editingState;

/**
 Stores reference on name of the channel from which client's state should be pulled out.
 */
@property (nonatomic, strong) NSString *channelName;

/**
 Stores reference on client identifier which is used to make a linkage between owner and his data inside concrete channel.
 */
@property (nonatomic, copy) NSString *clientIdentifier;

/**
 Stores reference on updated client state or state which has been received from \b PubNub service.
 */
@property (nonatomic, strong) id state;


#pragma mark - Instance methods

/**
 Validate provided data.
 
 @return \c YES if client state manipulation request can be processed.
 */
- (BOOL)isValidChannelNameAdnIdentifier;

/**
 Validate whether client specified correct state.
 
 @return \c YES in case if user inputed correct state data for channel.
 */
- (BOOL)isValidClientState;

/**
 Retrieve list of channels which is currently used by \b PubNub client.
 
 @return list of \b PNChannel instances on which client subscribed at this moment.
 */
- (NSArray *)existingChannels;

/**
 Perform client state manipulation action.
 
 @param handlerBlock
 Block which will be called when process will be completed and pass two parameters: reference on client information and
 error (if request failed).
 */
- (void)performRequestWithBlock:(void(^)(PNClient *, PNError *))handlerBlock;

/**
 Clean up any warnings which has been set during previous actions.
 */
- (void)resetWarnings;

#pragma mark -


@end
