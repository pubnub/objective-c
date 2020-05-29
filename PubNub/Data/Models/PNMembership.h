#import <Foundation/Foundation.h>


#pragma mark Class forward

@class PNChannelMetadata;


NS_ASSUME_NONNULL_BEGIN

#pragma mark - Interface declaration

/**
 * @brief Object which is used to represent \c UUID's membership in \c channel.
 *
 * @author Serhii Mamontov
 * @version 4.14.0
 * @since 4.14.0
 * @copyright © 2010-2020 PubNub, Inc.
 */
@interface PNMembership : NSObject


#pragma mark - Information

/**
 * @brief \c Metadata associated with \c channel which is listed in \c UUID's memberships list.
 *
 * @note This property will be set only if \b PNMembershipChannelField has been added to
 * \c includeFields list during request.
 */
@property (nonatomic, nullable, readonly, strong) PNChannelMetadata *metadata;

/**
 * @brief Additional information from \c metadata which has been associated with \c UUID during
 * \c UUID \c membership \c add requests.
 */
@property (nonatomic, nullable, readonly, strong) NSDictionary *custom;

/**
 * @brief \c UUID's for which membership has been created / removed.
 *
 * @note This value is set only when object received as one of subscription events.
 */
@property (nonatomic, nullable, readonly, copy) NSString *uuid;

/**
 * @brief Name of channel which is listed in \c UUID's memberships list.
 */
@property (nonatomic, readonly, copy) NSString *channel;

/**
 * @brief \c Membership data modification date.
 */
@property (nonatomic, readonly, strong) NSDate *updated;

/**
 * @brief \c Membership object version identifier.
 */
@property (nonatomic, readonly, copy) NSString *eTag;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
