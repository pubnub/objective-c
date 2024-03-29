#import <PubNub/PNAPICallBuilder.h>
#import <PubNub/PNStructures.h>


NS_ASSUME_NONNULL_BEGIN

#pragma mark Interface declaration

/**
 * @brief Publish message size calculation API call builder.
 *
 * @author Serhii Mamontov
 * @since 4.5.4
 * @copyright © 2010-2018 PubNub, Inc.
 */
@interface PNPublishSizeAPICallBuilder : PNAPICallBuilder


#pragma mark - Configuration

/**
 * @brief Channel name addition block.
 *
 * @param channel Name of the channel which should be used in size calculation.
 *
 * @return API call configuration builder.
 *
 * @since 4.5.4
 */
@property (nonatomic, readonly, strong) PNPublishSizeAPICallBuilder * (^channel)(NSString *channel);

/**
 * @brief Message payload addition block.
 *
 * @discussion Provided object will be serialized into JSON string before pushing to \b PubNub
 * service. If client has been configured with cipher key message will be encrypted as well.
 *
 * @param message Object (\a NSString, \a NSNumber, \a NSArray, \a NSDictionary) which will be
 *     used to calculate size.
 *
 * @return API call configuration builder.
 *
 * @since 4.5.4
 */
@property (nonatomic, readonly, strong) PNPublishSizeAPICallBuilder * (^message)(id message);

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
@property (nonatomic, readonly, strong) PNPublishSizeAPICallBuilder * (^metadata)(NSDictionary *metadata);

/**
 * @brief Message presence in storage flag addition block.
 *
 * @param shouldStore Whether message should be stored and available with history API or not.
 *
 * @return API call configuration builder.
 *
 * @since 4.5.4
 */
@property (nonatomic, readonly, strong) PNPublishSizeAPICallBuilder * (^shouldStore)(BOOL shouldStore);

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
@property (nonatomic, readonly, strong) PNPublishSizeAPICallBuilder * (^ttl)(NSUInteger ttl);

/**
 * @brief Message compression flag addition block.
 *
 * @param compress Whether message should be compressed before sending or not.
 *
 * @return API call configuration builder.
 *
 * @since 4.5.4
 */
@property (nonatomic, readonly, strong) PNPublishSizeAPICallBuilder * (^compress)(BOOL compress);

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
@property (nonatomic, readonly, strong) PNPublishSizeAPICallBuilder * (^replicate)(BOOL replicate);


#pragma mark - Execution

/**
 * @brief Perform API call.
 *
 * @param block Message size calculation completion block.
 *
 * @since 4.5.4
 */
@property (nonatomic, readonly, strong) void(^performWithCompletion)(PNMessageSizeCalculationCompletionBlock block);


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
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wincompatible-property-type"
@property (nonatomic, readonly, strong) PNPublishSizeAPICallBuilder * (^queryParam)(NSDictionary *params);
#pragma clang diagnostic pop

#pragma mark -


@end

NS_ASSUME_NONNULL_END
