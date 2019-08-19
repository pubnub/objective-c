#import "PNBaseObjectsRequest.h"

NS_ASSUME_NONNULL_BEGIN

#pragma mark Private interface declaration

/**
 * @brief Private \c base request extension to provide access to identifiable instance
 * initialization.
 *
 * @author Serhii Mamontov
 * @version 4.10.0
 * @since 4.10.0
 * @copyright © 2010-2019 PubNub, Inc.
 */
@interface PNBaseObjectsRequest (Private)


#pragma mark - Information

/**
 * @brief Unique \c object identifier.
 */
@property (nonatomic, readonly, copy) NSString *identifier;


#pragma mark - Initialization & Configuration

/**
 * @brief Initialize \c base request for identifiable object.
 *
 * @param objectType Name of object type (so far known: \c Space and \c User).
 * @param identifier Identifier of \c object for which request created.
 *
 * @return Initialized and ready to use \c request.
 */
- (instancetype)initWithObject:(NSString *)objectType identifier:(NSString *)identifier;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
