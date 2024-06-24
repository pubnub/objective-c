#import <PubNub/PNBaseRequest.h>
#import <PubNub/PNPresenceWhereNowFetchData.h>


NS_ASSUME_NONNULL_BEGIN

#pragma mark Interface declaration

/// `User presence` request.
@interface PNWhereNowRequest : PNBaseRequest


#pragma mark - Properties

/// Arbitrary percent encoded query parameters which should be sent along with original API call.
@property(strong, nullable, nonatomic) NSDictionary *arbitraryQueryParameters;

/// Unique identifer of the user for which presence information should be retrieved.
@property(copy, nonatomic, readonly) NSString *userId;


#pragma mark - Initialization and Configuration

/// Create `User presence` request.
///
/// - Parameter userId: Unique identifer of the user for which presence information should be retrieved.
/// - Returns: Ready to use `User presence` request.
+ (instancetype)requestForUserId:(NSString *)userId;

/// Forbids request initialization.
///
/// - Returns: Initialized request.
/// - Throws: Interface not available exception and requirement to use provided constructor method.
- (instancetype)init NS_UNAVAILABLE;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
