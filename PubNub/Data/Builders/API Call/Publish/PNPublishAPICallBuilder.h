#import "PNAPICallBuilder.h"
#import "PNStructures.h"


NS_ASSUME_NONNULL_BEGIN

/**
 @brief      Publish API call builder.
 @discussion Class describe interface which provide access to publish API.
 
 @author Sergey Mamontov
 @since 4.5.4
 @copyright © 2009-2017 PubNub, Inc.
 */
@interface PNPublishAPICallBuilder : PNAPICallBuilder


///------------------------------------------------
/// @name Configuration
///------------------------------------------------

/**
 @brief      Specify name of channel.
 @discussion On block call return block which consume (\b required) name of \c channel to which \c message 
             should be sent.
 
 @since 4.5.4
 */
@property (nonatomic, readonly, strong) PNPublishAPICallBuilder *(^channel)(NSString *channel);

/**
 @brief      Specify message.
 @discussion On block call return block which consume Foundation object (\a NSString, \a NSNumber, \a NSArray,
             \a NSDictionary) which will be published.
 @discussion Provided object will be serialized into JSON string before pushing to \b PubNub service. If 
             client has been configured with cipher key message will be encrypted as well.
 @note       Objects can be pushed only to regular channels.
 
 @since 4.5.4
 */
@property (nonatomic, readonly, strong) PNPublishAPICallBuilder *(^message)(id message);

/**
 @brief      Specify message metadata.
 @discussion On block call return block which consume \b NSDictionary with values which should be used by 
             \b PubNub service to filter messages.
 
 @since 4.5.4
 */
@property (nonatomic, readonly, strong) PNPublishAPICallBuilder *(^metadata)(NSDictionary *metadata);

/**
 @brief      Specify whether published \c message should be stored or not.
 @discussion On block call return block which consume \a BOOL and specify wheter published \c message should 
             be stored in history / storage or not.
 
 @since 4.5.4
 */
@property (nonatomic, readonly, strong) PNPublishAPICallBuilder *(^shouldStore)(BOOL shouldStore);

/**
 @brief      Specify for how many hours published \c message should be stored.
 @discussion On block call return block which consume \a NSUInteger and specify for how many hours published 
             message should be stored in channel's storage.
 @note       If \c shouldStore is set to \c NO this value will be ignored. If value is \b 0 then message will
             be stored in channel's storage or \b N hours (if non-zero value passed).
 
 @since 4.5.5
 */
@property (nonatomic, readonly, strong) PNPublishAPICallBuilder *(^ttl)(NSUInteger ttl);

/**
 @brief      Specify whether published \c message should be compressed or not.
 @discussion On block call return block which consume \a BOOL and specify wheter published \c message should 
             be compressed and sent with \c POST request or not.
 
 @since 4.5.4
 */
@property (nonatomic, readonly, strong) PNPublishAPICallBuilder *(^compress)(BOOL compress);

/**
 @brief  Specify whether published \c message should be replicated across the PubNub Real-Time Network and 
         sent simultaneously to all subscribed clients on a channel.
 
 @since 4.5.4
 */
@property (nonatomic, readonly, strong) PNPublishAPICallBuilder *(^replicate)(BOOL replicate);

/**
 @brief      Specify message push payloads.
 @discussion On block call return block which consume \b NSDictionary with payloads for different vendors 
             (Apple with "apns" key and Google with "gcm") which is used to deliver updates while application 
             not in foreground.
 
 @since 4.5.4
 */
@property (nonatomic, readonly, strong) PNPublishAPICallBuilder *(^payloads)(NSDictionary *payload);


///------------------------------------------------
/// @name Execution
///------------------------------------------------

/**
 @brief      Perform composed API call.
 @discussion Execute API call and report processing results through passed comnpletion block.
 @discussion On block call return block which consume (\b not required) publish processing completion block 
             which pass only one argument - request processing status to report about how data pushing was 
             successful or not.
 
 @since 4.5.4
 */
@property (nonatomic, readonly, strong) void(^performWithCompletion)(PNPublishCompletionBlock _Nullable block);

#pragma mark -


@end

NS_ASSUME_NONNULL_END
