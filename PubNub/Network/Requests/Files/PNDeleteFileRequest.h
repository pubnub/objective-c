#import <PubNub/PNBaseRequest.h>


NS_ASSUME_NONNULL_BEGIN

#pragma mark Interface declaration

/// `Delete file` request.
@interface PNDeleteFileRequest : PNBaseRequest


#pragma mark - Properties

/// Arbitrary percent encoded query parameters which should be sent along with original API call.
@property(strong, nullable, nonatomic) NSDictionary *arbitraryQueryParameters;


#pragma mark - Initialization and Configuration

/// Create `Delete file` request.
///
/// - Parameters:
///   - channel: Name of channel from which `file` with `name` should be `deleted`.
///   - identifier Unique `file` identifier which has been assigned during `file` upload.
///   - name Name under which uploaded `file` is stored for `channel`.
/// - Returns: Ready to use `delete file` request.
+ (instancetype)requestWithChannel:(NSString *)channel identifier:(NSString *)identifier name:(NSString *)name;

/// Forbids request initialization.
///
/// - Returns: Initialized request.
/// - Throws: Interface not available exception and requirement to use provided constructor method.
- (instancetype)init NS_UNAVAILABLE;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
