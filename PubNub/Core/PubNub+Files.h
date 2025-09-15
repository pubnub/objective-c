#import <PubNub/PubNub+Core.h>

// Request
#import <PubNub/PNDownloadFileRequest.h>
#import <PubNub/PNDeleteFileRequest.h>
#import <PubNub/PNListFilesRequest.h>
#import <PubNub/PNSendFileRequest.h>

// Response
#import <PubNub/PNDownloadFileResult.h>
#import <PubNub/PNListFilesResult.h>
#import <PubNub/PNSendFileStatus.h>

// Deprecated
#import <PubNub/PNFileDownloadURLAPICallBuilder.h>
#import <PubNub/PNDownloadFileAPICallBuilder.h>
#import <PubNub/PNDeleteFileAPICallBuilder.h>
#import <PubNub/PNListFilesAPICallBuilder.h>
#import <PubNub/PNSendFileAPICallBuilder.h>
#import <PubNub/PNFilesAPICallBuilder.h>


NS_ASSUME_NONNULL_BEGIN

#pragma mark Interface implementation

/// **PubNub** `File Share` APIs.
///
/// A set of APIs that let you share, download files, and get a list of shared files.
@interface PubNub (Files)


#pragma mark - Files API builder interface (deprecated)

/// Files API access builder.
@property (nonatomic, readonly, strong) PNFilesAPICallBuilder * (^files)(void)
    DEPRECATED_MSG_ATTRIBUTE("Builder-based interface deprecated. Please use corresponding request-based interfaces.");


#pragma mark - File upload

/// Upload file / data to specified `channel`.
///
/// #### Example:
/// ```objc
/// NSURL *localFileURL = ...;
/// PNSendFileRequest *request = [PNSendFileRequest requestWithChannel:@"channel" fileURL:localFileURL];
///
/// [self.client sendFileWithRequest:request completion:^(PNSendFileStatus *status) {
///     if (!status.isError) {
///         // File upload successfully completed.
///         // Uploaded file information available here:
///         //   `status.data.fileIdentifier` - unique file identifier
///         //   `status.data.fileName` - name which has been used to store file
///     } else {
///         // Handle send file error. Check `category` property to find out possible issue because of which request did
///         // fail.
///     }
/// }];
/// ```
///
/// - Parameters:
///   - request: `Send file` request with all information about file and where is should be uploaded.
///   - block: `Send file` request completion block.
- (void)sendFileWithRequest:(PNSendFileRequest *)request completion:(nullable PNSendFileCompletionBlock)block;


#pragma mark - List files

/// Retrieve list of files uploaded to `channel`.
///
/// #### Example:
/// ```objc
/// PNListFilesRequest *request = [PNListFilesRequest requestWithChannel:@"channel"];
/// request.limit = 20;
/// request.next = ...;
///
/// [self.client listFilesWithRequest:request completion:^(PNListFilesResult *result, PNErrorStatus *status) {
///     if (!status.isError) {
///         // Uploaded files list successfully fetched.
///         //   `result.data.files` - list of uploaded files (information)
///         //   `result.data.next` - cursor value to navigate to next fetched result page.
///         //   `result.data.count` - total number of files uploaded to channel.
///     } else {
///         // Handle fetch files list error. Check `category` property to find out possible issue because of which
///         // request did fail.
///     }
/// }];
/// ```
///
/// - Parameters:
///   - request: `List files` request with all information which should be used to fetch channel's files list.
///   - block: `List files` request completion block.
- (void)listFilesWithRequest:(PNListFilesRequest *)request completion:(PNListFilesCompletionBlock)block;


#pragma mark - Download files

/// Generate URL which can be used to download file from target `channel`.
///
/// #### Example:
/// ```objc
/// // Generate URL which can be used to download file.
/// NSURL *url = [self.client downloadURLForFileWithName:@"<file-name>"
///                                           identifier:@"<file-identifier>"
///                                            inChannel:@"lobby"];
/// ```
///
/// - Parameters:
///   - name: Name under which uploaded `file` is stored for `channel`.
///   - identifier: Unique `file` identifier which has been assigned during `file` upload.
///   - channel: Name of channel within which `file` with `name` has been uploaded.
/// - Returns: URL which can be used to download remote file with specified `name` and `identifier`.
- (nullable NSURL *)downloadURLForFileWithName:(NSString *)name
                                    identifier:(NSString *)identifier
                                     inChannel:(NSString *)channel;

/// `Download` requested `file` (and decrypt it, if it will be required).
///
/// #### Example:
/// ```objc
/// NSURL *localFileURL = ...;
/// PNDownloadFileRequest *request = [PNDownloadFileRequest requestWithChannel:@"lobby"
///                                                                 identifier:@"<file-identifier>"
///                                                                       name:@"<file-name>"];
/// request.targetURL = ...;
///
/// [self.client downloadFileWithRequest:request completion:^(PNDownloadFileResult *result, PNErrorStatus *status) {
///     if (!status.isError) {
///         // File successfully has been downloaded.
///         //   `status.data.location` - location where downloaded file can be found
///         //   `status.data.temporary` - whether file has been downloaded to temporary storage and will be removed on
///         //                             completion block return.
///     } else {
///         // Handle file download error. Check `category` property to find out possible issue because of which request
///         // did fail.
///     }
/// }];
/// ```
///
/// - Parameters:
///   - request: `Download file` request with information about file which should be downloaded.
///   - block: `Download file` request completion block.
- (void)downloadFileWithRequest:(PNDownloadFileRequest *)request completion:(PNDownloadFileCompletionBlock)block;


#pragma mark - Delete files

/// `Delete file` from `channel`.
///
/// #### Example:
/// ```objc
/// PNDeleteFileRequest *request = [PNDeleteFileRequest requestWithChannel:@"channel"
///                                                             identifier:@"<file-identifier>"
///                                                                   name:@"<file-name>"];
///
/// [self.client deleteFileWithRequest:request completion:^(PNAcknowledgmentStatus *status) {
///     if (!status.isError) {
///         // File successfully has been deleted.
///     } else {
///         // Handle file delete error. Check `category` property to find out possible issue because of which request
///         // did fail.
///     }
/// }];
/// ```
///
/// - Parameters:
///   - request: `Delete file` request with all information about file for removal.
///   - block: `Delete file` request completion block.
- (void)deleteFileWithRequest:(PNDeleteFileRequest *)request completion:(nullable PNDeleteFileCompletionBlock)block;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
