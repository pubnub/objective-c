#import <Foundation/Foundation.h>


NS_ASSUME_NONNULL_BEGIN

#pragma mark Interface declaration

/**
 * @brief Object which is used to represent \c space.
 *
 * @author Serhii Mamontov
 * @version 4.10.0
 * @since 4.10.0
 * @copyright © 2010-2019 PubNub, Inc.
 */
@interface PNSpace : NSObject


#pragma mark - Information

/**
 * @brief Additional information about \c space.
 */
@property (nonatomic, nullable, readonly, copy) NSString *information;

/**
 * @brief Additional / complex attributes which has been associated with \c space.
 */
@property (nonatomic, nullable, readonly, copy) NSDictionary *custom;

/**
 * @brief \c Space identifier.
 */
@property (nonatomic, readonly, copy) NSString *identifier;

/**
 * @brief \c Space creation date.
 */
@property (nonatomic, readonly, copy) NSDate *created;

/**
 * @brief \c Space data modification date.
 */
@property (nonatomic, readonly, copy) NSDate *updated;

/**
 * @brief Name which has been associated with \c space.
 */
@property (nonatomic, readonly, copy) NSString *name;

/**
 * @brief \c Space object version identifier.
 */
@property (nonatomic, readonly, copy) NSString *eTag;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
