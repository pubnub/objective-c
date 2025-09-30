#import "PNConfiguration.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Private interface declaration

/// **PubNub** client configuration wrapper private extension.
@interface PNConfiguration (Private)


#pragma mark - Information

/// String representation of filtering expression which should be applied to decide which updates should reach client.
///
/// > Warning: If your filter expression is malformed, ``PNEventsListener`` won't receive any messages and presence
/// events from service (only error status).
@property(copy, nullable, nonatomic) NSString *filterExpression;

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
@property(copy, nullable, nonatomic) NSString *authToken;


#pragma mark - Misc

/// Serialize configuration object.
///
/// - Returns: Configuration object data represented as `NSDictionary`.
- (NSDictionary *)dictionaryRepresentation;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
