//
//  PNPresenceObservationHelper.h
//  pubnub
//
//  Created by Sergey Mamontov on 4/1/14.
//  Copyright (c) 2014 PubNub Inc. All rights reserved.
//

#import <Foundation/Foundation.h>


#pragma mark Public interface declaration

@interface PNPresenceObservationHelper : NSObject


#pragma mark - Properties

/**
 Stores value which describe whether helper is working to enable presence on concrete channels or not.
 */
@property (nonatomic, assign, getter = isEnablingPresenceObservation) BOOL enablingPresenceObservation;


#pragma mark - Instance methods

/**
 Add specified channel to the list which will be used for presence manipulation.
 
 @param channel
 \b PNChannel instance for which presence observation will be enabled in future.
 */
- (void)addChannel:(PNChannel *)channel;

/**
 Remove concrete channel from list of channels for presence manipulation.
 
 @param channel
 \b PNChannel instance which shouldn't take part in presence manipulation.
 */
- (void)removeChannel:(PNChannel *)channel;

/**
 Checking whether provided channel is in list for presence manipulation or not.
 
 @return \c YES if channel has been prevously added through \c -addChannel: method.
 */
- (BOOL)willChangePresenceStateForChanne:(PNChannel *)channel;

/**
 Return reference on channels which can be used for presence observation.
 
 @return List of \b PNChannel instance which can be used for presence manipulation process.
 */
- (NSArray *)channels;

/**
 Check whether helper has all required data for presence manipulation.
 
 @return \c YES if helper can modify channel's presence state.
 */
- (BOOL)isAbleToChangePresenceState;

/**
 Perform channels presence state manipulation.
 
 @param handlerBlock
 Block which will be called when process will be completed and pass two parameters: reference on list of channels and
 error (if request failed).
 */
- (void)performRequestWithBlock:(void(^)(NSArray *, PNError *))handlerBlock;

/**
 Reset all cached helper's data.
 */
- (void)reset;

#pragma mark -


@end
