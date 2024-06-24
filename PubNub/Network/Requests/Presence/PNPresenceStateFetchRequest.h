#import <PubNub/PNBaseRequest.h>


NS_ASSUME_NONNULL_BEGIN

#pragma mark Interface declaration

/// `Fetch presence state` request.
@interface PNPresenceStateFetchRequest : PNBaseRequest


#pragma mark - Properties

/// Arbitrary percent encoded query parameters which should be sent along with original API call.
@property(strong, nullable, nonatomic) NSDictionary *arbitraryQueryParameters;

/// List of channel groups which will store provided state information for `userId`.
@property(copy, nullable, nonatomic) NSArray<NSString *> *channelGroups;

/// List of channels which will store provided state information for `userId`.
@property(copy, nullable, nonatomic) NSArray<NSString *> *channels;

/// Unique identifier of the user with which `state` should be associated.
@property(copy, nonatomic, readonly) NSString *userId;


#pragma mark - Initialization and Configuration

/// Create `Fetch presence state` request.
///
/// - Parameter userId: Unique identifier of the user for which associated state should be retrieved.
/// - Returns: Ready to use `Fetch presence state` request.
+ (instancetype)requestWithUserId:(NSString *)userId;

/// Forbids request initialization.
///
/// - Returns: Initialized request.
/// - Throws: Interface not available exception and requirement to use provided constructor method.
- (instancetype)init NS_UNAVAILABLE;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
