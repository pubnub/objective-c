#import "PNAPNSAPICallBuilder.h"


NS_ASSUME_NONNULL_BEGIN

/**
 @brief      APNS state audit API call builder.
 @discussion Class describe interface which allow to audit current push notification state (retrieve push
             notification enabled channels list).
 
 @author Sergey Mamontov
 @since 4.5.4
 @copyright © 2009-2017 PubNub, Inc.
 */
@interface PNAPNSAuditAPICallBuilder : PNAPNSAPICallBuilder


///------------------------------------------------
/// @name Configuration
///------------------------------------------------

/**
 @brief      Specify device push token against which push notification state manipulation should be done.
 @discussion On block call return block consume \a NSData which represent received from APNS device push 
             token.
 
 @since 4.5.4
 */
@property (nonatomic, readonly, strong) PNAPNSAuditAPICallBuilder *(^token)(NSData *token);


///------------------------------------------------
/// @name Execution
///------------------------------------------------

/**
 @brief      Perform composed API call.
 @discussion Execute API call and report processing results through passed comnpletion block.
 @discussion On block call return block which consume (\b required) push notifications status processing 
             completion block which pass two arguments: \c result - in case of successful request processing 
             \c data field will contain results of push notifications audit operation; \c status - in case if 
             error occurred during request processing.
 
 @since 4.5.4
 */
@property (nonatomic, readonly, strong) void(^performWithCompletion)(PNPushNotificationsStateAuditCompletionBlock block);

#pragma mark -


@end

NS_ASSUME_NONNULL_END
