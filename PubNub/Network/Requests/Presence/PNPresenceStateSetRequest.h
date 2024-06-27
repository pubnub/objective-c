#import <PubNub/PNBaseRequest.h>


NS_ASSUME_NONNULL_BEGIN

#pragma mark Interface declaration

/// `Set presence state` request.
@interface PNPresenceStateSetRequest : PNBaseRequest


#pragma mark - Properties

/// Arbitrary percent encoded query parameters which should be sent along with original API call.
@property(strong, nullable, nonatomic) NSDictionary *arbitraryQueryParameters;

/// List of channel groups which will store provided state information for `userId`.
@property(copy, nullable, nonatomic) NSArray<NSString *> *channelGroups;

/// List of channels which will store provided state information for `userId`.
@property(copy, nullable, nonatomic) NSArray<NSString *> *channels;

/// `NSDictionary` with data which should be associated with `uuidId` on `channel`.
///
/// > Note: Data will be removed if `state` not set.
@property(copy, nullable, nonatomic) NSDictionary *state;

/// Unique identifier of the user with which `state` should be associated.
@property(copy, nonatomic, readonly) NSString *userId;


#pragma mark - Initialization and Configuration

/// Create `Set presence state` request.
///
/// - Parameter userId: Unique identifier of the user with which `state` should be associated.
/// - Returns: Ready to use `Set presence state` request.
+ (instancetype)requestWithUserId:(NSString *)userId;

/// Forbids request initialization.
///
/// - Returns: Initialized request.
/// - Throws: Interface not available exception and requirement to use provided constructor method.
- (instancetype)init NS_UNAVAILABLE;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
