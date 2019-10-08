#import "PNAPICallBuilder.h"
#import "PNStructures.h"


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
 * @brief Channel name addition block.
 *
 * @param channel Name of the channel for which events should be pulled out from storage.
 *
 * @return API call configuration builder.
 *
 * @since 4.5.4
 */
@property (nonatomic, readonly, strong) PNHistoryAPICallBuilder * (^channel)(NSString *channel);

/**
 * @brief Channel names list addition block.
 *
 * @param channels List of channel names for which events should be pulled out from storage.
 *     Maximum \c 500 channels.
 *
 * @return API call configuration builder.
 *
 * @since 4.5.6
 */
@property (nonatomic, readonly, strong) PNHistoryAPICallBuilder * (^channels)(NSArray<NSString *> *channels);

/**
 * @brief Search interval start timetoken addition block.
 *
 * @param start Timetoken for oldest event starting from which next should be returned events.
 *     Value will be converted to required precision internally.
 *
 * @return API call configuration builder.
 *
 * @since 4.5.4
 */
@property (nonatomic, readonly, strong) PNHistoryAPICallBuilder * (^start)(NSNumber *start);

/**
 * @brief Search interval end timetoken addition block.
 *
 * @param end Timetoken for latest event till which events should be pulled out.
 *     Value will be converted to required precision internally.
 *
 * @return API call configuration builder.
 *
 * @since 4.5.4
 */
@property (nonatomic, readonly, strong) PNHistoryAPICallBuilder * (^end)(NSNumber *end);

/**
 * @brief Maximum number of events addition block.
 *
 * @param limit Maximum number of events which should be returned in response.
 *     Maximum \c 100 if \c channel is set and \c 25 if \c channels is set.
 *
 * @return API call configuration builder.
 *
 * @since 4.5.4
 */
@property (nonatomic, readonly, strong) PNHistoryAPICallBuilder * (^limit)(NSUInteger limit);

/**
 * @brief Events' time tokens presence flag addition block.
 *
 * @note Each fetched entry will contain published data under 'message' key and message publish
 * \c timetoken will be available under 'timetoken' key.
 *
 * @param includeTimeToken Whether event dates (time tokens) should be included in response or
 *     not.
 *
 * @return API call configuration builder.
 *
 * @since 4.5.4
 */
@property (nonatomic, readonly, strong) PNHistoryAPICallBuilder * (^includeTimeToken)(BOOL includeTimeToken);

/**
 * @brief Events' metadata presence flag addition block.
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
 * @brief Events' actions presence flag addition block.
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
 * @brief Events sorting order reverse flag addition block.
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
 * @brief Arbitrary query parameters addition block.
 *
 * @param params List of arbitrary percent encoded query parameters which should be sent along with
 *     original API call.
 *
 * @return API call configuration builder.
 *
 * @since 4.8.2
 */
@property (nonatomic, readonly, strong) PNHistoryAPICallBuilder * (^queryParam)(NSDictionary *params);

#pragma mark -


@end

NS_ASSUME_NONNULL_END
