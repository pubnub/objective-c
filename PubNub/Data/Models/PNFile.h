#import <Foundation/Foundation.h>


NS_ASSUME_NONNULL_BEGIN

#pragma mark Interface declaration

/**
 * @brief Object which is used to represent \c uploaded \c file.
 *
 * @author Serhii Mamontov
 * @version 4.15.0
 * @since 4.15.0
 * @copyright © 2010-2020 PubNub, Inc.
 */
@interface PNFile : NSObject


#pragma mark - Information

/**
 * @brief URL which can be used to download file.
 */
@property (nonatomic, readonly, strong) NSURL *downloadURL;

/**
 * @brief Unique uploaded file identifier.
 */
@property (nonatomic, readonly, copy) NSString *identifier;

/**
 * @brief Date when file has been uploaded.
 *
 * @note This information is set only when file retrieved from history.
 */
@property (nonatomic, readonly, strong) NSDate *created;

/**
 * @brief Uploaded file size.
 *
 * @note This information is set only when file retrieved from history.
 */
@property (nonatomic, readonly, assign) NSUInteger size;

/**
 * @brief Name with which file has been uploaded.
 */
@property (nonatomic, readonly, copy) NSString *name;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
