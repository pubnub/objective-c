#import "PNAPICallBuilder.h"
#import "PNStructures.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Interface declaration

/**
 * @brief \c Space \c user API call builder.
 *
 * @author Serhii Mamontov
 * @version 4.10.0
 * @since 4.10.0
 * @copyright © 2010-2019 PubNub, Inc.
 */
@interface PNDeleteSpaceAPICallBuilder : PNAPICallBuilder


#pragma mark - Configuration

/**
 * @brief Target \c space identifier.
 *
 * @param userId Identifier of \c space which should be removed.
 *
 * @return API call configuration builder.
 */
@property (nonatomic, readonly, strong) PNDeleteSpaceAPICallBuilder * (^spaceId)(NSString *spaceId);


#pragma mark - Execution

/**
 * @brief Perform API call.
 *
 * @param block \c Space \c delete completion handler block.
 */
@property (nonatomic, readonly, strong) void(^performWithCompletion)(PNDeleteSpaceCompletionBlock block);


#pragma mark - Misc

/**
 * @brief Arbitrary query parameters addition block.
 *
 * @param params List of arbitrary percent-encoded query parameters which should be sent along with
 * original API call.
 *
 * @return API call configuration builder.
 */
@property (nonatomic, readonly, strong) PNDeleteSpaceAPICallBuilder * (^queryParam)(NSDictionary *params);


#pragma mark -


@end

NS_ASSUME_NONNULL_END
