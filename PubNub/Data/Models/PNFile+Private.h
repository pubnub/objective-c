#import "PNFile.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Private interface declaration

/**
 * @brief Private \c uploaded \c file extension to provide ability to set data from service
 * response.
 *
 * @author Serhii Mamontov
 * @version 4.15.0
 * @since 4.15.0
 * @copyright © 2010-2020 PubNub, Inc.
 */
@interface PNFile (Private)


#pragma mark - Initialization & Configuration

/**
 * @brief Create and configure \c uploaded \c file data model from dictionary.
 *
 * @param data Dictionary with information about \c uploaded \c file from Files API.
 *
 * @return Configured and ready to use \c uploaded \c file representation model.
 */
+ (instancetype)fileFromDictionary:(NSDictionary *)data;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
