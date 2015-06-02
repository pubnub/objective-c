#import "PNResult.h"
#import "PNStructures.h"


/**
 @brief      Class which is used to describe error response from server or any non-request related
             client state changes.
 @discussion In case of error this instance may contain service response in \c data. Also this 
             object hold additional information about current client state.
 
 @author Sergey Mamontov
 @since 4.0
 @copyright © 2009-2015 PubNub, Inc.
 */
@interface PNStatus : PNResult <NSCopying>


///------------------------------------------------
/// @name Information
///------------------------------------------------

/**
 @brief  One of \b PNStatusCategory fields which provide information about for which status this
         instance has been created.

 @since 4.0
*/
@property (nonatomic, readonly, assign) PNStatusCategory category;

/**
 @brief  Whether status object represent error or not.
 
 @since 4.0
 */
@property (nonatomic, readonly, assign, getter = isError) BOOL error;

/**
 @brief      Stores whether client will try to resend request associated with status or not.
 @discussion In most cases client will keep retry request sending till it won't be successful or
             canceled with \c -cancelAutomaticRetry method.

 @since 4.0
 */
@property (nonatomic, readonly, assign, getter = willAutomaticallyRetry) BOOL automaticallyRetry;

/**
 @brief  Stores reference on time token which has been used to establish current subscription cycle.
 
 @since 4.0
 */
@property (nonatomic, readonly, strong) NSNumber *currentTimetoken;

/**
 @brief  Stores reference on previous key which has been used in subscription cycle to receive
         \c currentTimetoken along with other events.
 
 @since 4.0
 */
@property (nonatomic, readonly, strong) NSNumber *lastTimetoken;

/**
 @brief  Stores reference on list of channels on which client currently subscribed.
 
 @since 4.0
 */
@property (nonatomic, readonly, copy) NSArray *subscribedChannels;

/**
 @brief  Stores reference on channel group names list on which client currently subscribed.
 
 @since 4.0
 */
@property (nonatomic, readonly, copy) NSArray *subscribedChannelGroups;


#pragma mark - Recovery

/**
 @brief      Try to resend request associated with processing status object.
 @discussion Some operations which perform automatic retry attempts will ignore method call.

 @since 4.0
 */
- (void)retry;

/**
 @brief  For some requests client try to resend them to \b PubNub for processing.
 @discussion This method can be performed only on operations which respond with \c YES on
             \c willAutomaticallyRetry property. Other operation types will ignore method call.

 @since 4.0
 */
- (void)cancelAutomaticRetry;

#pragma mark -


@end
