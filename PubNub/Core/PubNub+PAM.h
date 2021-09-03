#import "PubNub+Core.h"
#import "PNPAMToken.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark API group interface

/**
 * @brief \b PubNub client core class extension to provide access to 'PAM' API group.
 *
 * @discussion Set of API which allow to change access token used by client.
 *
 * @author Serhii Mamontov
 * @version 4.17.0
 * @since 4.17.0
 * @copyright © 2010-2021 PubNub, Inc.
 */
@interface PubNub (PAM)


#pragma mark - PAM

/**
 * @brief Decode an existing token and returns the object containing permissions embedded in that token. The client may use this method for debugging.
 *
 * @param token Base64-encoded PubNub access token.
 *
 * @return Decoded token representation instance.
 */
- (nullable PNPAMToken *)parseAuthToken:(NSString *)token;

/**
 * @brief Set PubNub access token which should be used to authorize REST API calls.
 *
 * @code
 * [self.client setToken:@"access-token"];
 * @endcode
 *
 * @param token Base64-encoded PubNub access token.
 */
- (void)setAuthToken:(NSString *)token;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
