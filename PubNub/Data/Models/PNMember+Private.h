#import "PNMember.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Private interface declaration

/**
 * @brief Private \c member extension to provide ability to set data from service response.
 *
 * @author Serhii Mamontov
 * @version 4.10.0
 * @since 4.10.0
 * @copyright © 2010-2019 PubNub, Inc.
 */
@interface PNMember (Private)


#pragma mark - Initialization & Configuration

/**
 * @brief Create and configure \c member data model from dictionary.
 *
 * @param data Dictionary with information about \c member from Objects API.
 *
 * @return Configured and ready to use \c member member model.
 */
+ (instancetype)memberFromDictionary:(NSDictionary *)data;

/**
 * @brief Create and configure \c member data model.
 *
 * @param identifier Identifier of \c user which is listed in \c space's members list.
 * @param user \c User listed in \c space's members list.
 *
 * @return Configured and ready to use \c member representation model.
 */
+ (instancetype)memberWithUserId:(NSString *)identifier user:(nullable PNUser *)user;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
