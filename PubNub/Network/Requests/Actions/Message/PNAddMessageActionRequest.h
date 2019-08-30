#import "PNStructures.h"
#import "PNRequest.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Interface declaration

/**
 * @brief \c Add \c message \c action request.
 *
 * @author Serhii Mamontov
 * @version 4.11.0
 * @since 4.11.0
 * @copyright © 2010-2019 PubNub, Inc.
 */
@interface PNAddMessageActionRequest : PNRequest


#pragma mark - Initialization & Configuration

/**
 * @brief Create and configure \c create \c user request.
 *
 * @param identifier Unique identifier for new \c user entry.
 * @param name Name which should be associated with new \c user entry.
 *
 * @return Configured and ready to use \c create \c user request.
 */
+ (instancetype)requestWithUserID:(NSString *)identifier name:(NSString *)name
    NS_SWIFT_NAME(init(userID:name:));
+ (instancetype)e;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
