#import <PubNub/PNFileListFetchData.h>


NS_ASSUME_NONNULL_BEGIN

#pragma mark Interface declaration

/// `List files` request response private extension.
@interface PNFileListFetchData (Private)


#pragma mark - Helpers

/// Compute file download URL for each of ``files`` entry.
///
/// - Parameter block: File download URL generator block;
- (void)setFilesDownloadURLWithBlock:(NSURL *(^)(NSString *identifier, NSString *name))block;

#pragma mark -

@end

NS_ASSUME_NONNULL_END
