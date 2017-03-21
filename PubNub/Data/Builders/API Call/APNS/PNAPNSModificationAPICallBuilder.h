#import "PNAPNSAPICallBuilder.h"


NS_ASSUME_NONNULL_BEGIN

/**
 @brief      APNS state modification API call builder.
 @discussion Class describe interface which allow to modify push notification enabled channels list.
 
 @author Sergey Mamontov
 @since 4.5.4
 @copyright © 2009-2017 PubNub, Inc.
 */
@interface PNAPNSModificationAPICallBuilder : PNAPNSAPICallBuilder


///------------------------------------------------
/// @name Configuration
///------------------------------------------------

/**
 @brief      Specify device push token against which push notification state manipulation should be done.
 @discussion On block call return block which consume \a NSData which represent received from APNS device push
             token.
 
 @since 4.5.4
 */
@property (nonatomic, readonly, strong) PNAPNSModificationAPICallBuilder *(^token)(NSData *token);

/**
 @brief      Specify list of channels for APNS state manupulation.
 @discussion On block call return block which consume list of channel names for which APNS state manipulation
             should be perfored.
 @warning    \b PubNub client will remove push notification state for all channels which is registered with 
             passed \c token if \c nil or \c empty list will be passed during \c disable.
 
 @since 4.5.4
 */
@property (nonatomic, readonly, strong) PNAPNSModificationAPICallBuilder *(^channels)(NSArray<NSString *> * _Nullable channels);


///------------------------------------------------
/// @name Execution
///------------------------------------------------

/**
 @brief      Perform composed API call.
 @discussion Execute API call and report processing results through passed comnpletion block.
 @discussion On block call return block which consume (\b not required) push notifications state modification 
             processing completion block which pass only one argument - request processing status to report
             about how data pushing was successful or not.
 
 @since 4.5.4
 */
@property (nonatomic, readonly, strong) void(^performWithCompletion)(PNPushNotificationsStateModificationCompletionBlock _Nullable block);

#pragma mark -


@end

NS_ASSUME_NONNULL_END
