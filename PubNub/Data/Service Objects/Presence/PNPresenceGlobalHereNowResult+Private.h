#import <PubNub/PNPresenceGlobalHereNowResult.h>
#import <PubNub/PNPresenceHereNowResult.h>


NS_ASSUME_NONNULL_BEGIN

#pragma mark Private interface declaration

/// Global presence response private extension.
@interface PNPresenceGlobalHereNowResult (Private)


#pragma mark - Initialization and Configuration

/// Create backward-compatible here now result object.
///
/// - Parameter presence: Here now result from request-based interface.
/// - Returns: Ready to use backward-compatible here now result object.
+ (instancetype)legacyPresenceFromPresence:(PNPresenceHereNowResult *)presence;

#pragma mark -

@end

NS_ASSUME_NONNULL_END
