#import "PNChannelClientStateResult.h"
#import "PNPresenceStateFetchResult.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Private interface declaration

@interface PNChannelClientStateResult (Private)


#pragma mark - Initialization and Configuration

/// Create backward-compatible here now result object.
///
/// - Parameter presence: Here now result from request-based interface.
/// - Returns: Ready to use backward-compatible here now result object.
+ (instancetype)legacyPresenceFromPresence:(PNPresenceStateFetchResult *)presence;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
