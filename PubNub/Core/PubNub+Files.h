#import <PubNub/PubNub+Core.h>
#import <PubNub/PNDownloadFileRequest.h>
#import <PubNub/PNDeleteFileRequest.h>
#import <PubNub/PNListFilesRequest.h>
#import <PubNub/PNSendFileRequest.h>
#import <PubNub/PNFile.h>

#import <PubNub/PNDownloadFileResult.h>
#import <PubNub/PNListFilesResult.h>
#import <PubNub/PNSendFileStatus.h>

#import <PubNub/PNFileDownloadURLAPICallBuilder.h>
#import <PubNub/PNDownloadFileAPICallBuilder.h>
#import <PubNub/PNDeleteFileAPICallBuilder.h>
#import <PubNub/PNListFilesAPICallBuilder.h>
#import <PubNub/PNSendFileAPICallBuilder.h>
#import <PubNub/PNFilesAPICallBuilder.h>


NS_ASSUME_NONNULL_BEGIN

#pragma mark API group interface

/**
 * @brief \b PubNub client core class extension to provide access to 'Files' API group.
 *
 * @discussion Set of API which allow to upload / download files.
 *
 * @author Serhii Mamontov
 * @version 4.15.0
 * @since 4.15.0
 * @copyright © 2010-2020 PubNub, Inc.
 */
@interface PubNub (Files)


#pragma mark - API builder support

/**
 * @brief Files API access builder.
 *
 * @return API call configuration builder.
 */
@property (nonatomic, readonly, strong) PNFilesAPICallBuilder * (^files)(void);


#pragma mark - File upload

/**
 * @brief \c Send \c file to \c channel.
 *
 * @code
 * NSURL *localFileURL = ...;
 * PNSendFileRequest *request = [PNSendFileRequest requestWithChannel:@"channel"
 *                                                            fileURL:localFileURL];
 *
 * [self.client sendFileWithRequest:request completion:^(PNSendFileStatus *status) {
 *     if (!status.isError) {
 *         // File upload successfully completed.
 *         // Uploaded file information available here:
 *         //   status.data.fileIdentifier - unique file identifier
 *         //   status.data.fileName - name which has been used to store file
 *     } else {
 *         // Handle send file error. Check 'category' property to find out possible issue
 *         // because of which request did fail.
 *         //
 *         // Check 'status.data.fileUploaded' to figure out whether request should be resent or
 *         // only file message publish should be called.
 *     }
 * }];
 * @endcode
 *
 * @param request \c Send \c file request with all information about file and where is should be uploaded.
 * @param block \c Send \c file request completion block.
 */
- (void)sendFileWithRequest:(PNSendFileRequest *)request
                 completion:(nullable PNSendFileCompletionBlock)block;


#pragma mark - List files

/**
 * @brief Fetch uploaded \c files \c list.
 *
 * @code
 * PNListFilesRequest *request = [PNListFilesRequest requestWithChannel:@"channel"];
 * request.limit = 20;
 * request.next = ...;
 *
 * [self.client listFilesWithRequest:request
 *                        completion:^(PNListFilesResult *result, PNErrorStatus *status) {
 *
 *     if (!status.isError) {
 *         // Uploaded files list successfully fetched.
 *         //   result.data.files - list of uploaded files (information)
 *         //   result.data.next - cursor value to navigate to next fetched result page.
 *         //   result.data.count - total number of files uploaded to channel.
 *     } else {
 *         // Handle fetch files list error. Check 'category' property to find out possible issue
 *         // because of which request did fail.
 *         //
 *         // Request can be resent using: [status retry]
 *     }
 * }];
 * @endcode
 *
 * @param request \c List \c files request with all information which should be used to fetch channel's files list.
 * @param block \c List \c files request completion block.
 */
- (void)listFilesWithRequest:(PNListFilesRequest *)request
                  completion:(PNListFilesCompletionBlock)block;


#pragma mark - Download files

/**
 * @brief \c Get \c file \c download \c URL.
 *
 * @code
 * // Generate URL which can be used to download file.
 * NSURL *url = [self.client downloadURLForFileWithName:@"user_profile.png"
 *                                           identifier:@"<file-identifier>"
 *                                            inChannel:@"lobby"];
 * @endcode
 *
 * @param name Name under which uploaded \c file is stored for \c channel.
 * @param identifier Unique \c file identifier which has been assigned during \c file upload.
 * @param channel Name of channel within which \c file with \c name has been uploaded.
 *
 * @return URL which can be used to download remote file with specified \c name and \c identifier.
 */
- (nullable NSURL *)downloadURLForFileWithName:(NSString *)name
                                    identifier:(NSString *)identifier
                                     inChannel:(NSString *)channel;

/**
 * @brief \c Download requested \c file (and decrypt it, if it will be required).
 *
 * @code
 * NSURL *localFileURL = ...;
 * PNDownloadFileRequest *request = [PNDownloadFileRequest requestWithChannel:@"lobby"
 *                                                                 identifier:@"<file-identifier>"
 *                                                                       name:@"user_profile.png"];
 * request.targetURL = ...;
 *
 * [self.client downloadFileWithRequest:request completion:^(PNDownloadFileResult *result,
 *                                                           PNErrorStatus *status) {
 *                                                           
 *     if (!status.isError) {
 *         // File successfully has been downloaded.
 *         //   status.data.location - location where downloaded file can be found
 *         //   status.data.temporary - whether file has been downloaded to temporary storage and
 *         //                           will be removed on completion block return.
 *     } else {
 *         // Handle file download error. Check 'category' property to find out possible issue
 *         // because of which request did fail.
 *         //
 *         // Request can be resent using: [status retry]
 *     }
 * }];
 * @endcode
 *
 * @param request \c Download \c file request with information about file which should be downloaded.
 * @param block \c Download \c file request completion block.
 */
- (void)downloadFileWithRequest:(PNDownloadFileRequest *)request
                     completion:(PNDownloadFileCompletionBlock)block;


#pragma mark - Delete files

/**
 * @brief \c Delete \c file from \c channel.
 *
 * @code
 * PNDeleteFileRequest *request = [PNDeleteFileRequest requestWithChannel:@"channel"
 *                                                             identifier:@"<file-identifier>"
 *                                                                   name:@"greetings.txt"];
 *
 * [self.client deleteFileWithRequest:request completion:^(PNAcknowledgmentStatus *status) {
 *     if (!status.isError) {
 *         // File successfully has been deleted.
 *     } else {
 *         // Handle file delete error. Check 'category' property to find out possible issue
 *         // because of which request did fail.
 *         //
 *         // Request can be resent using: [status retry]
 *     }
 * }];
 * @endcode
 *
 * @param request \c Delete \c file request with all information about file for removal.
 * @param block \c Delete \c file request completion block.
 */
- (void)deleteFileWithRequest:(PNDeleteFileRequest *)request
                   completion:(nullable PNDeleteFileCompletionBlock)block;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
