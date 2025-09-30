#import "PNClientStateGetResult.h"
#import "PNPresenceStateFetchResult.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Private interface declaration

/// `Fetch user presence for channels / channel groups` request processing result private extension.
@interface PNClientStateGetResult (Private)


#pragma mark - Initialization and Configuration

/// Create backward-compatible fetch presence state result object.
///
/// - Parameter state: Presence state result from request-based interface.
/// - Returns: Ready to use backward-compatible presence state result object.
+ (instancetype)legacyPresenceStateFromPresenceState:(PNPresenceStateFetchResult *)state;

#pragma mark -

@end

NS_ASSUME_NONNULL_END
