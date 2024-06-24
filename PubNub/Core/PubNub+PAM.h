#import <PubNub/PubNub+Core.h>
#import <PubNub/PNPAMToken.h>


NS_ASSUME_NONNULL_BEGIN

#pragma mark Interface declaration

/// **PubNub** `File Share` APIs.
///
/// Set of API which allow to change access token used by client.
@interface PubNub (PAM)


#pragma mark - PAM

/// Decode an existing token and returns the object containing permissions embedded in that token. The client may use
/// this method for debugging.
///
/// - Parameter token: Base64-encoded PubNub access token.
/// - Returns: Decoded token representation instance.
- (nullable PNPAMToken *)parseAuthToken:(NSString *)token;

/// Set PubNub access token which should be used to authorize REST API calls.
///
/// #### Example:
/// ```objc
/// [self.client setAuthToken:@"access-token"];
/// ```
///
/// - Parameter token: Base64-encoded PubNub access token.
- (void)setAuthToken:(NSString *)token;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
