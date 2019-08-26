#import <Foundation/Foundation.h>


#pragma mark Class forward

@class PNUser;


NS_ASSUME_NONNULL_BEGIN

#pragma mark Interface declaration

/**
 * @brief Object which is used to represent \c space \c member.
 *
 * @author Serhii Mamontov
 * @version 4.10.0
 * @since 4.10.0
 * @copyright © 2010-2019 PubNub, Inc.
 */
@interface PNMember : NSObject


#pragma mark - Information

/**
 * @brief Additional information associated with \c user in context of his membership in \c space.
 */
@property (nonatomic, nullable, readonly, strong) NSDictionary *custom;

/**
 * @brief \c User which is listed in \c space's members list.
 *
 * @note This property will be set only if \b PNMembersIncludeFields.user has been added to
 * \c includeFields list during request.
 */
@property (nonatomic, nullable, readonly, strong) PNUser *user;

/**
 * @brief Identifier of \c user which is listed in \c space's members list.
 */
@property (nonatomic, readonly, strong) NSString *userId;

/**
 * @brief \c Space creation date.
 */
@property (nonatomic, readonly, copy) NSDate *created;

/**
 * @brief \c Space data modification date.
 */
@property (nonatomic, readonly, copy) NSDate *updated;

/**
 * @brief \c Member object version identifier.
 */
@property (nonatomic, readonly, copy) NSString *eTag;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
