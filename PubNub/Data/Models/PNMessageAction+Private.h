/**
 * @author Serhii Mamontov
 * @version 4.11.0
 * @since 4.11.0
 * @copyright © 2010-2019 PubNub, Inc.
 */
#import "PNMessageAction.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Private interface declaration

/**
 * @brief Private \c message \c action extension to provide ability to set data from service
 * response.
 *
 * @author Serhii Mamontov
 * @version 4.11.0
 * @since 4.11.0
 * @copyright © 2010-2019 PubNub, Inc.
 */
@interface PNMessageAction (Private)


#pragma mark - Initialization & Configuration

/**
 * @brief Create and configure \c message \c action data model from dictionary.
 *
 * @param data Dictionary with information about \c message \c action from 'Message Action' API.
 *
 * @return Configured and ready to use \c message \c action representation model.
 */
+ (instancetype)actionFromDictionary:(NSDictionary *)data;

#pragma mark -

@end

NS_ASSUME_NONNULL_END
