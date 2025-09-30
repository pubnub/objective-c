#import "PNFileSendData.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Private interface declaration

/// `File Upload` request response private extension.
@interface PNFileSendData (Private)


#pragma mark - Properties

/// Time token when the message with file information has been published.
@property(strong, nullable, nonatomic) NSNumber *timetoken;

/// Whether file uploaded or not.
///
/// > Note: This property should be used during error handling to identify whether send file request should be resend or
/// only file message publish.
@property(assign, nonatomic) BOOL fileUploaded;


#pragma mark - Initialization and Configuration

/// Create send file response data.
///
/// - Parameters:
///   - fileId: Unique identifier which has been assigned to file during upload.
///   - fileName: Name under which uploaded data has been stored.
/// - Returns: Ready to use send file response data.
+ (instancetype)fileDataWithId:(NSString *)fileId name:(NSString *)fileName;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
