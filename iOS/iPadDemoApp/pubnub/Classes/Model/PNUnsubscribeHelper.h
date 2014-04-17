//
//  PNUnsubscribeHelper.h
//  pubnub
//
//  Created by Sergey Mamontov on 3/27/14.
//  Copyright (c) 2014 PubNub Inc. All rights reserved.
//

#import <Foundation/Foundation.h>


#pragma mark Public interface declaration

@interface PNUnsubscribeHelper : NSObject


#pragma mark - Instance methods

/**
 Place specified channel into list which will be used for unsubscription request.
 
 @param channel
 \b PNChannel instance from which \b PubNub client will unsubscribe.
 */
- (void)addChannelForUnsubscription:(PNChannel *)channel;

/**
 Remove concrete channel from list of channels from which \b PubNub client will unsubscribe.
 */
- (void)removeChannel:(PNChannel *)channel;

/**
 Validate wheter channel marked for unsubscription or not.
 
 @param channel
 \b PNChannel instance against which check should be performed.
 
 @return \c YES if channel already marked for unsubscription.
 */
- (BOOL)willUnsubscribeFromChannel:(PNChannel *)channel;

/**
 List of channels which can be used for unsubscription.
 
 @return List of \b PNChannel instances which depict channels on which client subscribed at this moment.
 */
- (NSArray *)channelsForUnsubscription;

/**
 Validate wheter helper is able to issue unsubscribe request or not.
 
 @return \c YES in case if there at least one channel marked for unsubscription.
 */
- (BOOL)canUnsubscribe;

/**
 Perform unsubscription request.
 
 @param handlerBlock
 Block which will be called by \b PubNub client in case of success / error and will pass two values: list of channels and
 in case of error will pass \b PNError instance.
 */
- (void)unsubscribeWithBlock:(PNClientChannelUnsubscriptionHandlerBlock)handlerBlock;

#pragma mark -


@end
