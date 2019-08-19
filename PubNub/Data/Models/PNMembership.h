#import <Foundation/Foundation.h>


#pragma mark Class forward

@class PNSpace;


NS_ASSUME_NONNULL_BEGIN

#pragma mark - Interface declaration

/**
 * @brief Object which is used to represent \c user's membership in \c space.
 *
 * @author Serhii Mamontov
 * @version 4.10.0
 * @since 4.10.0
 * @copyright © 2010-2019 PubNub, Inc.
 */
@interface PNMembership : NSObject


#pragma mark - Information

/**
 * @brief Additional information associated with \c user in context of his membership in \c space.
 */
@property (nonatomic, nullable, readonly, strong) NSDictionary *custom;

/**
 * @brief \c Space with which \c user linked through membership.
 *
 * @note This property will be set only if \b PNMembershipsIncludeFields.space has been added to
 * \c includeFields list during request.
 */
@property (nonatomic, nullable, readonly, strong) PNSpace *space;

/**
 * @brief Identifier of \c space with which \c user linked through membership.
 */
@property (nonatomic, readonly, strong) NSString *spaceId;

/**
 * @brief \c Membership creation date.
 */
@property (nonatomic, readonly, copy) NSDate *created;

/**
 * @brief \c Membership data modification date.
 */
@property (nonatomic, readonly, copy) NSDate *updated;

/**
 * @brief \c Membership object version identifier.
 */
@property (nonatomic, readonly, copy) NSString *eTag;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
