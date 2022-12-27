#import <Foundation/Foundation.h>


NS_ASSUME_NONNULL_BEGIN

#pragma mark Interface declaration

/**
 * @brief Model which represent space into which message should be / has been published.
 *
 * @author Serhii Mamontov
 * @version 5.2.0
 * @since 5.2.0
 * @copyright © 2010-2022 PubNub Inc. All Rights Reserved.
 */
@interface PNSpaceId : NSObject


#pragma mark - Information

/**
 * @brief Space into which message should be / has been published
 */
@property(nonatomic, readonly, copy) NSString *value;


#pragma mark - Initialization and configuration

/**
 * @brief Create and configure space id instance.
 *
 * @param identifier Space id identifier.
 *
 * @return Configured and ready to use space id instance.
 */
+ (instancetype)spaceIdFromString:(NSString *)identifier;

/**
 * @brief Initialize space id instance.
 *
 * @note This method can't be used directly and will throw an exception.
 *
 * @return Space id instance.
 */
- (nullable instancetype)init NS_UNAVAILABLE;


#pragma mark - Helper

/**
 * @brief Check whether receiving space id is equal to another instance.
 *
 * @param otherSpaceId Second instance against which check should be done.
 *
 * @return \c YES if \c otherSpaceId is equal to receiver.
 */
- (BOOL)isEqualToSpaceId:(PNSpaceId *)otherSpaceId;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
