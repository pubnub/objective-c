#import <PubNub/PNBaseRequest.h>


NS_ASSUME_NONNULL_BEGIN

#pragma mark Interface declaration

/// `File upload URL` request.
@interface PNGenerateFileUploadURLRequest : PNBaseRequest


#pragma mark - Properties

/// Arbitrary percent encoded query parameters which should be sent along with original API call.
@property(strong, nullable, nonatomic) NSDictionary *arbitraryQueryParameters;

/// Name which should be used to store uploaded data.
@property(copy, nonatomic) NSString *filename;


#pragma mark - Initialization and Configuration

/// Create `Upload data URL generation` request.
///
/// - Parameters:
///   - channel: Name of channel to which `data` should be uploaded.
///   - name File name which will be used to store uploaded `data`.
/// - Returns: Ready to use `upload data URL generation` request.
+ (instancetype)requestWithChannel:(NSString *)channel filename:(NSString *)name;

/// Forbids request initialization.
///
/// - Returns: Initialized request.
/// - Throws: Interface not available exception and requirement to use provided constructor method.
- (instancetype)init NS_UNAVAILABLE;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
