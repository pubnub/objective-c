#import "PNAPICallBuilder.h"
#import "PNStructures.h"


NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Publish API call builder.
 *
 * @author Serhii Mamontov
 * @since 4.5.4
 * @copyright © 2010-2018 PubNub, Inc.
 */
@interface PNPublishAPICallBuilder : PNAPICallBuilder


#pragma mark - Configuration

/**
 * @brief Channel name addition block.
 *
 * @param channel Name of the channel to which message should be published.
 *
 * @return API call configuration builder.
 *
 * @since 4.5.4
 */
@property (nonatomic, readonly, strong) PNPublishAPICallBuilder * (^channel)(NSString *channel);

/**
 * @brief Message payload addition block.
 *
 * @discussion Provided object will be serialized into JSON string before pushing to \b PubNub
 * service. If client has been configured with cipher key message will be encrypted as well.
 *
 * @param message Object (\a NSString, \a NSNumber, \a NSArray, \a NSDictionary) which will be
 *     published.
 *
 * @return API call configuration builder.
 *
 * @since 4.5.4
 */
@property (nonatomic, readonly, strong) PNPublishAPICallBuilder * (^message)(id message);

/**
 * @brief Message metadata addition block.
 *
 * @param metadata \b NSDictionary with values which should be used by \b PubNub service to filter
 *     messages.
 *
 * @return API call configuration builder.
 *
 * @since 4.5.4
 */
@property (nonatomic, readonly, strong) PNPublishAPICallBuilder * (^metadata)(NSDictionary *metadata);

/**
 * @brief Message presence in storage flag addition block.
 *
 * @param shouldStore Whether message should be stored and available with history API or not.
 *
 * @return API call configuration builder.
 *
 * @since 4.5.4
 */
@property (nonatomic, readonly, strong) PNPublishAPICallBuilder * (^shouldStore)(BOOL shouldStore);

/**
 * @brief Message maximum storage presence time addition block.
 *
 * @note Will be ignored if \c shouldStore is set to \c NO.
 *
 * @param ttl How long message should be stored in channel's storage. Pass \b 0 store message
 *     forever.
 *
 * @return API call configuration builder.
 *
 * @since 4.5.5
 */
@property (nonatomic, readonly, strong) PNPublishAPICallBuilder * (^ttl)(NSUInteger ttl);

/**
 * @brief Message compression flag addition block.
 *
 * @param compress Whether message should be compressed before sending or not.
 *
 * @return API call configuration builder.
 *
 * @since 4.5.4
 */
@property (nonatomic, readonly, strong) PNPublishAPICallBuilder * (^compress)(BOOL compress);

/**
 * @brief Message payload replication across the PubNub Real-Time Network flag addition block.
 *
 * @param replicate Whether message should be replicated across the PubNub Real-Time Network and
 *     sent simultaneously to all subscribed clients on a channel.
 *
 * @return API call configuration builder.
 *
 * @since 4.5.4
 */
@property (nonatomic, readonly, strong) PNPublishAPICallBuilder * (^replicate)(BOOL replicate);

/**
 * @brief Message push payloads addition block.
 *
 * @param payload Dictionary with payloads for different vendors (Apple with "apns" key and Google
 *     with "gcm").
 *
 * @return API call configuration builder.
 *
 * @since 4.5.4
 */
@property (nonatomic, readonly, strong) PNPublishAPICallBuilder * (^payloads)(NSDictionary *payload);


#pragma mark - Execution

/**
 * @brief Perform API call.
 *
 * @param block Publish completion block.
 *
 * @since 4.5.4
 */
@property (nonatomic, readonly, strong) void(^performWithCompletion)(PNPublishCompletionBlock _Nullable block);


#pragma mark - Misc

/**
 * @brief Arbitrary query parameters addition block.
 *
 * @param params List of arbitrary percent encoded query parameters which should be sent along with
 *     original API call.
 *
 * @return API call configuration builder.
 *
 * @since 4.8.2
 */
@property (nonatomic, readonly, strong) PNPublishAPICallBuilder * (^queryParam)(NSDictionary *params);

#pragma mark -


@end

NS_ASSUME_NONNULL_END
