#import "PNStructures.h"
#import "PNRequest.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Interface declaration

/**
 * @brief \c Fetch \c message \c actions request.
 *
 * @author Serhii Mamontov
 * @version 4.11.0
 * @since 4.11.0
 * @copyright © 2010-2019 PubNub, Inc.
 */
@interface PNFetchMessageActionsRequest : PNRequest


#pragma mark - Information

/**
 * @brief \c Message \c action timetoken denoting the start of the range requested.
 *
 * @note Return values will be less than start.
 */
@property (nonatomic, nullable, copy) NSNumber *start;

/**
 * @brief \c Message \c action timetoken denoting the end of the range requested.
 *
 * @note Return values will be greater than or equal to end.
 */
@property (nonatomic, nullable, copy) NSNumber *end;

/**
 * @brief Number of \c message \c actions to return in response.
 */
@property (nonatomic, assign) NSUInteger limit;


#pragma mark - Initialization & Configuration

/**
 * @brief Create and configure \c fetch \c message \c actions request.
 *
 * @param channel Name of channel from which list of \c message \c actions should be retrieved.
 *
 * @return Configured and ready to use \c fetch \c messages \c actions request.
 */
+ (instancetype)requestWithChannel:(NSString *)channel;

/**
 * @brief Forbids request initialization.
 *
 * @throws Interface not available exception and requirement to use provided constructor method.
 *
 * @return Initialized request.
 */
- (instancetype)init NS_UNAVAILABLE;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
