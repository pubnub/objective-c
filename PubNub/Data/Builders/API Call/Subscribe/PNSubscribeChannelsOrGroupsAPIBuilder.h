#import "PNSubscribeAPIBuilder.h"


NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Subscribe API call builder.
 *
 * @author Serhii Mamontov
 * @since 4.5.4
 * @copyright © 2010-2018 PubNub, Inc.
 */
@interface PNSubscribeChannelsOrGroupsAPIBuilder : PNSubscribeAPIBuilder


#pragma mark - Configuration

/**
 * @brief Presence channels / channel groups usage flag addition block.
 *
 * @param withPresence Whether presence observation should be enabled for \c groups or not.
 *
 * @return API call configuration builder.
 *
 * @since 4.5.4
 */
@property (nonatomic, readonly, strong) PNSubscribeChannelsOrGroupsAPIBuilder * (^withPresence)(BOOL withPresence);

/**
 * @brief Catch up timetoken addition block.
 *
 * @param withTimetoken Time from which client should try to catch up on messages.
 *     Value will be converted to required precision internally.
 *
 * @since 4.5.4
 */
@property (nonatomic, readonly, strong) PNSubscribeChannelsOrGroupsAPIBuilder * (^withTimetoken)(NSNumber *withTimetoken);

/**
 * @brief User's presence state addition.
 *
 * @param state \a NSDictionary with key-value pairs based on channel group name and value which
 *     should be assigned to it.
 *
 * @since 4.5.4
 */
@property (nonatomic, readonly, strong) PNSubscribeChannelsOrGroupsAPIBuilder * (^state)(NSDictionary *state);


#pragma mark - Execution

/**
 * @brief Perform API call.
 *
 * @since 4.5.4
 */
@property (nonatomic, readonly, strong) dispatch_block_t perform;


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
@property (nonatomic, readonly, strong) PNSubscribeChannelsOrGroupsAPIBuilder * (^queryParam)(NSDictionary *params);

#pragma mark -


@end

NS_ASSUME_NONNULL_END
