/**
 * @author Serhii Mamontov
 * @version 4.17.0
 * @since 4.17.0 
 * @copyright © 2010-2021 PubNub, Inc.
 */
#import "PubNub+PAM.h"
#import "PNRequestParameters.h"


NS_ASSUME_NONNULL_BEGIN

@interface PubNub (PAMPrivate)


#pragma mark - Request helper

/**
 * @brief Add required authorization parameter (auth token or auth key) parameter to request.
 *
 * @param parameters Object which holds set of parameters required to perform request.
 */
- (void)addAuthParameter:(PNRequestParameters *)parameters;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
