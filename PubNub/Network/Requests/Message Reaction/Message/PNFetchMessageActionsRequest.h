#import <PubNub/PNBaseRequest.h>


NS_ASSUME_NONNULL_BEGIN

#pragma mark Interface declaration

/// `Fetch message actions` request.
///
/// Retrieve list of reactions attached to the message identifier by its timetoken.
@interface PNFetchMessageActionsRequest : PNBaseRequest


#pragma mark - Properties

/// `Message action` timetoken denoting the start of the range requested.
///
/// > Note: Returned values will be less than start.
@property (nonatomic, nullable, copy) NSNumber *start;

/// `Message action` timetoken denoting the end of the range requested.
///
/// > Note: Returned values will be greater than or equal to end.
@property (nonatomic, nullable, copy) NSNumber *end;

/// Number of `message actions` to return in response.
@property (nonatomic, assign) NSUInteger limit;


#pragma mark - Initialization and Configuration

/// Create `fetch message actions` request.
///
/// - Parameter channel: Name of channel from which list of `message actions` should be retrieved.
/// - Returns: Ready to use `fetch messages actions` request.
+ (instancetype)requestWithChannel:(NSString *)channel;

/// Forbids request initialization.
///
/// - Returns: Initialized request.
/// - Throws: Interface not available exception and requirement to use provided constructor method.
- (instancetype)init NS_UNAVAILABLE;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
