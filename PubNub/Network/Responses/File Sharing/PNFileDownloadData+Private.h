#import <PubNub/PNFileDownloadData.h>


NS_ASSUME_NONNULL_BEGIN

#pragma mark Private interface declaration

/// `Download file` request response private extension.
@interface PNFileDownloadData (Private)


#pragma mark - Initialization and Configuration

/// Create `Download file` request response.
///
/// - Parameters:
///   - location: Location where downloaded file can be found.
///   - temporarily: Whether file is temporary or not.
/// - Returns: Ready to use `Download File` request response.
+ (instancetype)dataForFileAtLocation:(NSURL *)location temporarily:(BOOL)temporarily;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
