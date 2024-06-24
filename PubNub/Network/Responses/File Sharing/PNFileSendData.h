#import <PubNub/PNBaseOperationData.h>


NS_ASSUME_NONNULL_BEGIN

#pragma mark Interface declaration

/// `File Upload` request response.
@interface PNFileSendData : PNBaseOperationData


#pragma mark - Properties

/// Unique identifier which has been assigned to file during upload.
@property(strong, nullable, nonatomic, readonly) NSString *fileIdentifier;

/// Time token when the message with file information has been published.
@property(strong, nullable, nonatomic, readonly) NSNumber *timetoken;

/// Name under which uploaded data has been stored.
@property(strong, nullable, nonatomic, readonly) NSString *fileName;

/// Whether file uploaded or not.
///
/// > Note: This property should be used during error handling to identify whether send file request should be resend or
/// only file message publish.
@property(assign, nonatomic, readonly) BOOL fileUploaded;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
