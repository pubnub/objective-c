#import <Foundation/Foundation.h>


#pragma mark Class forward

@class PNUUIDMetadata;


NS_ASSUME_NONNULL_BEGIN

#pragma mark Interface declaration

/**
 * @brief Object which is used to represent \c chanel \c member.
 *
 * @author Serhii Mamontov
 * @version 4.14.0
 * @since 4.14.0
 * @copyright © 2010-2020 PubNub, Inc.
 */
@interface PNMember : NSObject


#pragma mark - Information

/**
 * @brief \c Metadata associated with \c UUID which is listed in \c channel's members list.
 *
 * @note This property will be set only if \b PNMemberUUIDField has been added to
 * \c includeFields list during request.
 */
@property (nonatomic, nullable, readonly, strong) PNUUIDMetadata *metadata;

/**
 * @brief Additional information from \c metadata which has been associated with \c UUID during
 * \c channel \c member \c add requests.
 */
@property (nonatomic, nullable, readonly, strong) NSDictionary *custom;

/**
 * @brief \c Member data modification date.
 */
@property (nonatomic, readonly, strong) NSDate *updated;

/**
 * @brief Identifier which is listed in \c channel's members list.
 */
@property (nonatomic, readonly, copy) NSString *uuid;

/**
 * @brief \c Member object version identifier.
 */
@property (nonatomic, readonly, copy) NSString *eTag;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
