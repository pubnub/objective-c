#import "PNConfiguration.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Private interface declaration

/// **PubNub** client configuration wrapper private extension.
@interface PNConfiguration (Private)


#pragma mark - Information

/// Token which is used along with every request to **PubNub** service to identify client user.
///
/// **PubNub** service provide **PAM** (PubNub Access Manager) functionality which allow to specify access rights to
/// access **PubNub** service with provided `publishKey` and `subscribeKey` keys.
/// Access can be limited to concrete users. **PAM** system use this key to check whether client user has rights to
/// access to required service or not.
///
/// > Important: If `authToken` is set if till be used instead of `authKey`.
///
/// This property not set by default.
@property (nonatomic, nullable, copy) NSString *authToken;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
