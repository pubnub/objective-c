/**
 * @author Serhii Mamontov
 * @version 4.17.0
 * @since 4.17.0
 * @copyright © 2010-2021 PubNub, Inc.
 */
#import "PNPAMToken.h"


NS_ASSUME_NONNULL_BEGIN

@interface PNPAMToken (Private)


#pragma mark Initialization & Configuration

/**
 * @brief Create and configure PubNub access token description object.
 *
 * @param string PAM token encoded as Base64 string.
 *
 * @return Configured and ready to use \c token representation model.
 */
+ (instancetype)tokenFromBase64String:(NSString *)string;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
