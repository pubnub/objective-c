#import "PNFileGenerateUploadURLData.h"
#import <PubNub/PNTransportRequest.h>
#import <PubNub/PNCodable.h>


NS_ASSUME_NONNULL_BEGIN

#pragma mark Private interface declaration

/// `Generate file upload URL` request response private extension.
@interface PNFileGenerateUploadURLData () <PNCodable>


#pragma mark - Properties

/// List of form-fields which should be prepended to user data in request body.
///
/// > Note: `multipart/form-data` `Content-Type` will be set in case if any fields is present in array.
@property(strong, nullable, nonatomic) NSArray<NSDictionary *> *formFields;

/// Unique file identifier.
@property(strong, nullable, nonatomic) NSString *fileIdentifier;

/// HTTP method which should be used during file upload request.
@property(strong, nullable, nonatomic) NSString *httpMethod;

/// Name which will be used to store user data on server.
@property(strong, nullable, nonatomic) NSString *filename;

/// URL which should be used to upload user data.
@property(strong, nullable, nonatomic) NSURL *requestURL;


#pragma mark - Initialization and Configuration

/// Initialize `Generate file upload URL` data object.
///
/// - Parameters:
///   - fileId: Unique file identifier.
///   - fileName: Actual file name under which file has been stored.
/// - Returns: Initialized `Generate file upload URL` data object.
- (instancetype)initWithId:(NSString *)fileId name:(NSString *)fileName;

#pragma mark -


@end

NS_ASSUME_NONNULL_END


#pragma mark - Interface implementation

@implementation PNFileGenerateUploadURLData


#pragma mark - Initialization and Configuration

- (instancetype)initWithId:(NSString *)fileId name:(NSString *)fileName {
    if ((self = [super init])) {
        _fileIdentifier = [fileId copy];
        _filename = [fileName copy];
    }

    return self;
}

- (instancetype)initObjectWithCoder:(id<PNDecoder>)coder {
    NSDictionary *payload = [coder decodeObjectOfClass:[NSDictionary class]];
    if (![payload isKindOfClass:[NSDictionary class]] || !payload[@"data"] || !payload[@"file_upload_request"]) {
        return nil;
    }

    NSDictionary *requestData = payload[@"file_upload_request"];
    NSDictionary *fileData = payload[@"data"];

    if (![fileData isKindOfClass:[NSDictionary class]] || ![requestData isKindOfClass:[NSDictionary class]]) return nil;

    PNFileGenerateUploadURLData *data = [self initWithId:fileData[@"id"] name:fileData[@"name"]];
    data.httpMethod = ((NSString *)requestData[@"method"]).lowercaseString;
    data.requestURL = [NSURL URLWithString:requestData[@"url"]];
    data.formFields = requestData[@"form_fields"];

    return data;
}

#pragma mark -


@end
