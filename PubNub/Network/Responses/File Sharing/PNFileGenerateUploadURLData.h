#import <PubNub/PNBaseOperationData.h>


NS_ASSUME_NONNULL_BEGIN

#pragma mark Interface declaration

/// `Generate file upload URL` request response.
@interface PNFileGenerateUploadURLData : PNBaseOperationData


#pragma mark - Properties

/// List of form-fields which should be prepended to user data in request body.
///
/// > Note: `multipart/form-data` `Content-Type` will be set in case if any fields is present in array.
@property(strong, nullable, nonatomic, readonly) NSArray<NSDictionary *> *formFields;

/// Unique file identifier.
@property(strong, nullable, nonatomic, readonly) NSString *fileIdentifier;

/// HTTP method which should be used during file upload request.
@property(strong, nullable, nonatomic, readonly) NSString *httpMethod;

/// Name which will be used to store user data on server.
@property(strong, nullable, nonatomic, readonly) NSString *filename;

/// URL which should be used to upload user data.
@property(strong, nullable, nonatomic, readonly) NSURL *requestURL;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
