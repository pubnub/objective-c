#import <PubNub/PNBaseRequest.h>


NS_ASSUME_NONNULL_BEGIN

#pragma mark Interface implementation

/// `Delete messages` request.
@interface PNHistoryMessagesDeleteRequest : PNBaseRequest


#pragma mark - Properties

/// Arbitrary percent encoded query parameters which should be sent along with original API call.
@property(strong, nullable, nonatomic) NSDictionary *arbitraryQueryParameters;

/// Name of the channel from which events should be removed.
@property(copy, nonatomic, readonly) NSString *channel;

/// Removed interval start timetoken.
///
/// Timetoken for oldest event starting from which events should be removed.
/// Value will be converted to required precision internally. If no `end` value provided, will be removed all events
/// till specified `start` date (not inclusive).
@property(strong, nullable, nonatomic) NSNumber *start;

/// Removed interval end timetoken
///
/// Timetoken for latest event till which events should be removed.
/// Value will be converted to required precision internally. If no `start` value provided, will be removed all events
/// starting from specified `end` date (inclusive).
@property(strong, nullable, nonatomic) NSNumber *end;


#pragma mark - Initialization and Constructor

/// Create `Delete messages` request.
///
/// - Parameter channel: Name of the channel from which events should be removed.
/// - Returns: Ready to use `Delete messages` request.
+ (instancetype)requestWithChannel:(NSString *)channels;

/// Forbids request initialization.
///
/// - Returns: Initialized request.
/// - Throws: Interface not available exception and requirement to use provided constructor method.
- (instancetype)init NS_UNAVAILABLE;


#pragma mark -

@end

NS_ASSUME_NONNULL_END
