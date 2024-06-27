#import <PubNub/PNChannelGroupClientStateResult.h>
#import <PubNub/PNPresenceStateFetchResult.h>


NS_ASSUME_NONNULL_BEGIN

#pragma mark Private interface declaration

/// `Fetch user presence state for channel group` request processing result private extension.
@interface PNChannelGroupClientStateResult (Private)


#pragma mark - Initialization and Configuration

/// Create backward-compatible here now result object.
///
/// - Parameter presence: Here now result from request-based interface.
/// - Returns: Ready to use backward-compatible here now result object.
+ (instancetype)legacyPresenceFromPresence:(PNPresenceStateFetchResult *)presence;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
