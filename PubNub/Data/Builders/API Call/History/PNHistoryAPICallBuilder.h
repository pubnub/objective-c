#import <PubNub/PNAPICallBuilder.h>
#import <PubNub/PNStructures.h>


NS_ASSUME_NONNULL_BEGIN

/**
 * @brief History / storage API call builder.
 *
 * @author Serhii Mamontov
 * @version 4.11.0
 * @since 4.5.4
 * @copyright © 2010-2019 PubNub, Inc.
 */
@interface PNHistoryAPICallBuilder : PNAPICallBuilder


#pragma mark - Configuration

/**
 * @brief Channel name.
 *
 * @param channel Name of the channel for which events should be pulled out from storage.
 *
 * @return API call configuration builder.
 *
 * @since 4.5.4
 */
@property (nonatomic, readonly, strong) PNHistoryAPICallBuilder * (^channel)(NSString *channel);

/**
 * @brief Channel names list.
 *
 * @param channels List of channel names for which events should be pulled out from storage.
 *   Maximum \c 500 channels.
 *
 * @return API call configuration builder.
 *
 * @since 4.5.6
 */
@property (nonatomic, readonly, strong) PNHistoryAPICallBuilder * (^channels)(NSArray<NSString *> *channels);

/**
 * @brief Search interval start timetoken.
 *
 * @param start Timetoken for oldest event starting from which next should be returned events.
 *   Value will be converted to required precision internally.
 *
 * @return API call configuration builder.
 *
 * @since 4.5.4
 */
@property (nonatomic, readonly, strong) PNHistoryAPICallBuilder * (^start)(NSNumber *start);

/**
 * @brief Search interval end timetoken.
 *
 * @param end Timetoken for latest event till which events should be pulled out.
 *   Value will be converted to required precision internally.
 *
 * @return API call configuration builder.
 *
 * @since 4.5.4
 */
@property (nonatomic, readonly, strong) PNHistoryAPICallBuilder * (^end)(NSNumber *end);

/**
 * @brief Maximum number of events.
 *
 * @param limit Maximum number of events which should be returned in response.
 *   Maximum \c 100 if \c channel is set and \c 25 if \c channels is set.
 *
 * @return API call configuration builder.
 *
 * @since 4.5.4
 */
@property (nonatomic, readonly, strong) PNHistoryAPICallBuilder * (^limit)(NSUInteger limit);

/**
 * @brief Messages' custom type flag.
 *
 * @note Message / signal and file messages may contain user-provided type.
 *
 *@param includeCustomMessageType Whether custom message type should be included in response or not.
 *
 * @return API call configuration builder.
 */
@property (nonatomic, readonly, strong) PNHistoryAPICallBuilder * (^includeCustomMessageType)(BOOL includeCustomMessageType);

/**
 * @brief Events' time tokens presence flag.
 *
 * @note Each fetched entry will contain published data under 'message' key and message publish
 *   \c timetoken will be available under 'timetoken' key.
 *
 * @param includeTimeToken Whether event dates (time tokens) should be included in response or
 *   not.
 *
 * @return API call configuration builder.
 *
 * @since 4.5.4
 */
@property (nonatomic, readonly, strong) PNHistoryAPICallBuilder * (^includeTimeToken)(BOOL includeTimeToken);


/**
 * @brief Events' metadata presence flag.
 *
 * @note Each fetched entry will contain published data under 'message' key and published message
 * \c meta will be available under 'metadata' key.
 *
 * @param includeMetadata Whether event metadata should be included in response or not.
 *
 * @return API call configuration builder.
 *
 * @since 4.11.0
 */
@property (nonatomic, readonly, strong) PNHistoryAPICallBuilder * (^includeMetadata)(BOOL includeMetadata);

/**
 * @brief Events' type presence flag.
 *
 * @note Available only when message fetched for multiple channels or should include message actions.
 * @note Each fetched entry will contain published data under 'message' key and published message
 * \c message \c type will be available under 'messageType' key.
 *
 * @param includeMessageType Whether event type should be included in response or not.
 *   By default set to: \b YES. 
 *
 * @return API call configuration builder.
 *
 * @since 4.15.3
 */
@property (nonatomic, readonly, strong) PNHistoryAPICallBuilder * (^includeMessageType)(BOOL includeMessageType);

/**
 * @brief Events' publisher UUID presence flag.
 *
 * @note Available only when message fetched for multiple channels or should include message actions.
 * @note Each fetched entry will contain published data under 'message' key and published message
 * \c message \c publisher will be available under 'uuid' key.
 *
 * @param includeUUID Whether event publisher UUID should be included in response or not.
 *   By default set to: \b YES.
 *
 * @return API call configuration builder.
 *
 * @since 4.15.3
 */
@property (nonatomic, readonly, strong) PNHistoryAPICallBuilder * (^includeUUID)(BOOL includeUUID);

/**
 * @brief Events' actions presence flag.
 *
 * @note Each fetched entry will contain published data under 'message' key and added \c message
 * \c actions will be available under 'actions' key.
 *
 * @throw Exception in case if API called with more than one channel.
 *
 * @param includeMessageActions Whether event actions should be included in response or not.
 *
 * @return API call configuration builder.
 *
 * @since 4.11.0
 */
@property (nonatomic, readonly, strong) PNHistoryAPICallBuilder * (^includeMessageActions)(BOOL includeMessageActions);

/**
 * @brief Events sorting order reverse flag.
 *
 * @param reverse Whether events order in response should be reversed or not.
 *
 * @return API call configuration builder.
 *
 * @since 4.5.4
 */
@property (nonatomic, readonly, strong) PNHistoryAPICallBuilder * (^reverse)(BOOL reverse);


#pragma mark - Execution

/**
 * @brief Perform API call.
 *
 * @param block History pull completion block.
 *
 * @return API call configuration builder.
 *
 * @since 4.5.4
 */
@property (nonatomic, readonly, strong) void(^performWithCompletion)(PNHistoryCompletionBlock block);


#pragma mark - Misc

/**
 * @brief Arbitrary query parameters.
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
@property (nonatomic, readonly, strong) PNHistoryAPICallBuilder * (^queryParam)(NSDictionary *params);
#pragma clang diagnostic pop

#pragma mark -


@end

NS_ASSUME_NONNULL_END
