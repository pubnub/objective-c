#import "PNStructures.h"
#import "PNRequest.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Interface declaration

/**
 * @brief Base class for all Object API endpoints which has shared query options.
 *
 * @author Serhii Mamontov
 * @version 4.14.0
 * @since 4.14.0
 * @copyright © 2010-2020 PubNub, Inc.
 */
@interface PNBaseObjectsRequest : PNRequest


#pragma mark - Information

/**
 * @brief Arbitrary percent encoded query parameters which should be sent along with original API
 * call.
 */
@property (nonatomic, nullable, strong) NSDictionary *arbitraryQueryParameters;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
