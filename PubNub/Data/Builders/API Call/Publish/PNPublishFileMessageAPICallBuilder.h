#import <PubNub/PNAPICallBuilder.h>
#import <PubNub/PNStructures.h>


NS_ASSUME_NONNULL_BEGIN

#pragma mark Interface declaration

/**
 * @brief Base publish API call builder.
 *
 * @author Serhii Mamontov
 * @version 4.15.0
 * @since 4.15.0
 * @copyright © 2010-2020 PubNub, Inc. 
 */
@interface PNPublishFileMessageAPICallBuilder : PNAPICallBuilder


#pragma mark - Configuration

/**
 * @brief Unique identifier provided during file upload.
 *
 * @discussion Unique file identifier.
 *
 * @return API call configuration builder.
 */
@property (nonatomic, readonly, strong) PNPublishFileMessageAPICallBuilder * (^fileIdentifier)(NSString *fileIdentifier);

/**
 * @brief Name with which uploaded data has been stored.
 *
 * @discussion Service-provided filename.
 *
 * @return API call configuration builder.
 */
@property (nonatomic, readonly, strong) PNPublishFileMessageAPICallBuilder * (^fileName)(NSString *fileName);

/**
 * @brief Target channel name.
 *
 * @discussion Name of the channel to which message should be published.
 *
 * @return API call configuration builder.
 */
@property (nonatomic, readonly, strong) PNPublishFileMessageAPICallBuilder * (^channel)(NSString *channel);

/**
 * @brief Message payload.
 *
 * @discussion Provided object will be serialized into JSON string before pushing to \b PubNub service. If client has been
 * configured with cipher key message will be encrypted as well.
 *
 * @discussion Object (\a NSString, \a NSNumber, \a NSArray, \a NSDictionary) which will be published.
 *
 * @return API call configuration builder.
 */
@property (nonatomic, readonly, strong) PNPublishFileMessageAPICallBuilder * (^message)(id message);

/**
 * @brief User-specified message type.
 *
 * \b Important: string limited by \b 3 - \b 50 case-sensitive alphanumeric characters with only \c - and \c _ special
 * characters allowed.
 *
 * @return API call configuration builder.
 */
@property (nonatomic, readonly, strong) PNPublishFileMessageAPICallBuilder * (^customMessageType)(NSString *customMessageType);

/**
 * @brief Message metadata.
 *
 * @discussion \b NSDictionary with values which should be used by \b PubNub service to filter messages.
 *
 * @return API call configuration builder.
 */
@property (nonatomic, readonly, strong) PNPublishFileMessageAPICallBuilder * (^metadata)(NSDictionary *metadata);

/**
 * @brief Message presence in storage flag.
 *
 * @discussion Whether message should be stored and available with history API or not.
 *
 * @return API call configuration builder.
 */
@property (nonatomic, readonly, strong) PNPublishFileMessageAPICallBuilder * (^shouldStore)(BOOL shouldStore);

/**
 * @brief Message maximum storage presence time.
 *
 * @discussion How long message should be stored in channel's storage. Pass \b 0 store message according to retention.
 *
 * @note Will be ignored if \c shouldStore is set to \c NO.
 *
 * @return API call configuration builder.
 */
@property (nonatomic, readonly, strong) PNPublishFileMessageAPICallBuilder * (^ttl)(NSUInteger ttl);

/**
 * @brief Message payload replication across the PubNub Real-Time Network flag.
 *
 * @discussion Whether message should be replicated across the PubNub Real-Time Network and sent simultaneously to all
 * subscribed clients on a channel.
 *
 * @return API call configuration builder.
 */
@property (nonatomic, readonly, strong) PNPublishFileMessageAPICallBuilder * (^replicate)(BOOL replicate);


#pragma mark - Execution

/**
 * @brief Perform API call.
 *
 * @discussion \c File \c message \c publish completion handler block.
 */
@property (nonatomic, readonly, strong) void(^performWithCompletion)(PNPublishCompletionBlock _Nullable block);


#pragma mark - Misc

/**
 * @brief Arbitrary query parameters addition block.
 *
 * @discussion List of arbitrary percent-encoded query parameters which should be sent along with
 * original API call.
 *
 * @return API call configuration builder.
 */
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wincompatible-property-type"
@property (nonatomic, readonly, strong) PNPublishFileMessageAPICallBuilder * (^queryParam)(NSDictionary *params);
#pragma clang diagnostic pop

#pragma mark -


@end

NS_ASSUME_NONNULL_END
