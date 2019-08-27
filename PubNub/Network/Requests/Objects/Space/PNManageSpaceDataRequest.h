#import "PNBaseObjectsRequest.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Interface declaration

/**
 * @brief Private \c create / \c update space request extension to provide ability specify data for
 * pre-defined fields.
 *
 * @author Serhii Mamontov
 * @version 4.10.0
 * @since 4.10.0
 * @copyright © 2010-2019 PubNub, Inc.
 */
@interface PNManageSpaceDataRequest : PNBaseObjectsRequest


#pragma mark - Information

/**
 * @brief \c Space description information.
 */
@property (nonatomic, nullable, copy) NSString *information;

/**
 * @brief Additional / complex attributes which should be associated to \c space with specified
 * \c identifier.
 */
@property (nonatomic, nullable, copy) NSDictionary *custom;

/**
 * @brief Name which should be associated to \c user with specified \c identifier.
 */
@property (nonatomic, copy) NSString *name;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
