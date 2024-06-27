#import <PubNub/PNBaseRequest.h>
#import <PubNub/PNCryptoProvider.h>


NS_ASSUME_NONNULL_BEGIN

/// `File data upload` request.
@interface PNFileUploadRequest : PNBaseRequest


#pragma mark - Properties

/// Crypto module which should be used for uploaded data `encryption`.
///
/// This property allows setting up data `encryption` using a different crypto module than the one set during **PubNub**
/// client instance configuration.
@property(strong, nullable, nonatomic) id<PNCryptoProvider> cryptoModule;

/// Stream with data which should be uploaded.
@property(strong, nonatomic) NSInputStream *bodyStream;

/// Actual size of uploaded data (passes by user only for stream-based uploads).
@property(assign, nonatomic) NSUInteger dataSize;

/// Name with which uploaded file should be stored.
@property(strong, nonatomic) NSString *filename;


#pragma mark - Initialization and Configuration

/// Create `File Upload` request.
///
/// - Parameters:
///   - url: File upload URL (with origin and path).
///   - method: HTTP method which should be used to put file to remote storage.
///   - formData: List of fields which should be sent as `multipart/form-data` fields.
/// - Returns: Ready to use `File Upload` request.
+ (instancetype)requestWithURL:(NSURL *)url httpMethod:(NSString *)method formData:(NSArray<NSDictionary *> *)formData;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
