#import "PNBaseRequest.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Interface declaration

/// `File download URL generate` request.
@interface PNGenerateFileDownloadURLRequest : PNBaseRequest


#pragma mark - Initialization and Configuration

/// Create `File download URL generate` request.
///
/// - Parameters:
///   - channel: Name of the channel where file with ``fileIdentifier`` ID has been shared.
///   - fileId: Unique file identifier.
///   - fileName: Name which will be used to store user data on server.
/// - Returns: Ready to use `File download URL generate` request.
+ (instancetype)requestWithChannel:(NSString *)channel fileIdentifier:(NSString *)fileId fileName:(NSString *)fileName;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
