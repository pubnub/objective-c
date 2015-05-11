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
@interface PNStatus : PNResult


///------------------------------------------------
/// @name Information
///------------------------------------------------

/**
 @brief  One of \b PNStatusCategory fields which provide information about for which status this
         instance has been created.

 @since 4.0
*/
@property (nonatomic, assign) PNStatusCategory category;

/**
 @brief  Stores whether client currently used secured connection or not.
 
 @since 4.0
 */
@property (nonatomic, assign, getter = isSSLEnabled) BOOL SSLEnabled;

/**
 @brief  Stores reference on list of channels on which client currently subscribed.
 
 @since 4.0
 */
@property (nonatomic, copy) NSArray *channels;

/**
 @brief  Stores reference on channel group names list on which client currently subscribed.
 
 @since 4.0
 */
@property (nonatomic, copy) NSArray *groups;

/**
 @brief  UUID which is currently used by client to identify user on \b PubNub service.
 
 @since 4.0
 */
@property (nonatomic, copy) NSString *uuid;

/**
 @brief      Authorization which is used to get access to protected remote resources.
 @discussion Some resources can be protected by \b PAM functionality and access done using this 
             authorization key.
 
 @since 4.0
 */
@property (nonatomic, copy) NSString *authorizationKey;

/**
 @brief      Reference on cached client state which is used for subscribe and heartbeat requests.
 @discussion To keep bound client state on remote service client should perform "heartbeat" requests
             to keep it there.
 
 @since 4.0
 */
@property (nonatomic, copy) NSDictionary *state;

/**
 @brief  Whether status object represent error or not.
 
 @since 4.0
 */
@property (nonatomic, readonly, assign, getter = isError) BOOL error;

/**
 @brief  Reference on object which can help with results processing.

 @since 4.0
 */
@property (nonatomic, readonly, strong) id associatedObject;

/**
 @brief  Stores reference on time token which has been used to establish current subscription cycle.
 
 @since 4.0
 */
@property (nonatomic, assign) NSNumber *currentTimetoken;

/**
 @brief  Stores reference on previous key which has been used in subscription cycle to receive
         \c currentTimetoken along with other events.
 
 @since 4.0
 */
@property (nonatomic, assign) NSNumber *previousTimetoken;

/**
 @brief      Stores whether client will try to resend request associated with status or not.
 @discussion In most cases client will keep retry request sending till it won't be successful or
             canceled with \c -cancelAutomaticRetry method.

 @since 4.0
 */
@property (nonatomic, readonly, assign, getter = willAutomaticallyRetry) BOOL automaticallyRetry;


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
