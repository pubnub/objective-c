#import <PubNub/PNBaseRequest.h>


NS_ASSUME_NONNULL_BEGIN

#pragma mark Interface declaration

/// `List files` request.
@interface PNListFilesRequest : PNBaseRequest


#pragma mark - Properties

/// Arbitrary percent encoded query parameters which should be sent along with original API call.
@property(strong, nullable, nonatomic) NSDictionary *arbitraryQueryParameters;

/// Name of channel for which list of files should be fetched.
@property(copy, nonatomic, readonly) NSString *channel;

/// Previously-returned cursor bookmark for fetching the next page.
@property(copy, nullable, nonatomic) NSString *next;

/// Number of files to return in response.
///
/// > Note: Will be set to `100` (which is also maximum value) if not specified.
@property(assign, nonatomic) NSUInteger limit;


#pragma mark - Initialization and Configuration

/// Create `List files` request.
///
/// - Parameter channel: Name of channel for which files list should be retrieved.
/// - Returns: Ready to use `list files` request.
+ (instancetype)requestWithChannel:(NSString *)channel;

/// Forbids request initialization.
///
/// - Returns: Initialized request.
/// - Throws: Interface not available exception and requirement to use provided constructor method.
- (instancetype)init NS_UNAVAILABLE;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
