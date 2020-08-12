#import <Foundation/Foundation.h>
#import "PNKeyValueStorage.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Interfaces declaration

/**
 * @brief In-memory \c key/value storage.
 *
 * @note For macOS store commands write information to file in \c Application \c Support folder.
 *
 * @author Serhii Mamontov
 * @version 4.15.3
 * @since 4.15.3
 * @copyright © 2010-2020 PubNub, Inc.
 */
@interface PNInMemoryStorage : NSObject <PNKeyValueStorage>


#pragma mark - Initialization & Configuration

/**
 * @brief Create and configure \c key/value in-memory storage.
 *
 * @param identifier Unique identifier with which managed values should be \c "linked".
 * @param queue Resources access serialisation queue.
 *
 * @return Configured and ready to use \c key/value  in-memory storage.
 */
+ (instancetype)storageWithIdentifier:(NSString *)identifier queue:(dispatch_queue_t)queue;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
