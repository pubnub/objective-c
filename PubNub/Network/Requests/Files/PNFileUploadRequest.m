#import "PNFileUploadRequest.h"
#import "PNTransportRequest+Private.h"
#import "NSInputStream+PNCrypto.h"
#import "PNSequenceInputStream.h"
#import "PNBaseRequest+Private.h"
#import "PNFunctions.h"

#if __has_include(<UniformTypeIdentifiers/UniformTypeIdentifiers.h>)
#import <UniformTypeIdentifiers/UniformTypeIdentifiers.h>
#endif // __has_include(<UniformTypeIdentifiers/UniformTypeIdentifiers.h>)


NS_ASSUME_NONNULL_BEGIN

#pragma mark Private interface declaration

/// `File data upload` request private extension.
@interface PNFileUploadRequest ()


#pragma mark - Properties

/// Dictionary with default header values override.
@property(strong, nonatomic) NSMutableDictionary<NSString *, NSString *> *headersOverride;

/// Pre-processed body input stream.
@property(strong, nonatomic) NSInputStream *httpBodyInputStream;

/// List of fields which should be sent as `multipart/form-data` fields.
@property(strong, nonatomic) NSArray<NSDictionary *> *formData;

/// HTTP method which should be used to put file to remote storage.
@property(strong, nonatomic) NSString *method;

/// File upload URL (with origin and path).
@property(strong, nonatomic) NSURL *url;


#pragma mark - Initialization and Configuration

/// Initialize `File Upload` request.
///
/// - Parameters:
///   - url: File upload URL (with origin and path).
///   - method: HTTP method which should be used to put file to remote storage.
///   - formData: List of fields which should be sent as `multipart/form-data` fields.
/// - Returns: Initialized `File Upload` request.
- (instancetype)initWithURL:(NSURL *)url httpMethod:(NSString *)method formData:(NSArray<NSDictionary *> *)formData;


#pragma mark - Helpers

/// Create input stream with `multipart/form-data` stream-based data.
///
/// - Parameters:
///   - boundary: Boundary which should be used to separate `multipart/form-data` fields in POST body.
///   - stream: Input stream with data which should be uploaded.
///   - filename: Name which should be used to store uploaded data.
///   - cryptoModule: Crypto module for data _encryption_.
///   - fields: List of multipart/form-data fields which should be processed.
///   - streamsTotalSize: Pointer which is used to store overall input streams size.
/// - Returns: Initialized input stream with `multipart/form-data` stream-based data.
- (nullable NSInputStream *)multipartFormDataStreamWithBoundary:(NSString *)boundary
                                                dataInputStream:(NSInputStream *)stream
                                                       filename:(NSString *)filename
                                                   cryptoModule:(nullable id<PNCryptoProvider>)cryptoModule
                                                     fromFields:(NSArray<NSDictionary *> *)fields
                                                    streamsSize:(NSUInteger *)streamsTotalSize;

/// Prepare provided multipart/form-data fields to be sent with request POST body.
///
/// - Parameters:
///   - boundary: Separator for key/value pairs.
///   - fields: List of multipart/form-data fields which should be processed.
/// - Returns: Data object which can be sent with request post body or \c nil in case if there is no `fields` provided.
- (nullable NSData *)multipartFormDataWithBoundary:(NSString *)boundary fromFields:(NSArray<NSDictionary *> *)fields;

/// Prepare multipart/form-data file data to be sent with request POST body.
///
/// - Parameters:
///   - filename: Name under which uploaded data should be stored.
///   - boundary: Separator for key/value pairs.
/// - Returns: Data object which can be sent with request post body.
- (NSData *)multipartFormFile:(NSString *)filename dataWithBoundary:(NSString *)boundary;

/// Multipart form data end data.
///
/// - Parameter boundary: Separator for key/value pairs.
/// - Returns: Data object which should be send at the end of multipart/form-data HTTP body stream.
- (NSData *)multipartFormEndDataWithBoundary:(NSString *)boundary;

/// Identify file MIME type using file extension.
///
/// - Parameter filename: Name from which extension should be examined.
/// - Returns: Actual file MIME type or `application/octet-stream` if type can't be identified.
- (NSString *)mimeTypeFromFilename:(NSString *)filename;

#pragma mark -


@end

NS_ASSUME_NONNULL_END


#pragma mark - Interface implementation

@implementation PNFileUploadRequest


#pragma mark - Properties

- (PNOperationType)operation {
    return PNSendFileOperation;
}

- (PNTransportRequest *)request {
    PNTransportRequest *request = super.request;
    request.timeout = self.subscribeMaximumIdleTime;

    return request;
}

- (NSInputStream *)bodyStream {
    return self.httpBodyInputStream ?: _bodyStream;
}

- (TransportMethod)httpMethod {
    return [self.method.lowercaseString isEqualToString:@"post"] ? TransportPOSTMethod : TransportPATCHMethod;
}

- (BOOL)bodyStreamAvailable {
    return YES;
}

- (BOOL)shouldCompressBody {
    return NO;
}

- (NSDictionary *)headers {
    if (self.headersOverride.count == 0) return [super headers];

    NSMutableDictionary *headers = [([super headers] ?: @{}) mutableCopy];
    [headers addEntriesFromDictionary:self.headersOverride];

    return headers;
}

- (NSString *)origin {
    return PNStringFormat(@"%@://%@", self.url.scheme, self.url.host);
}

- (NSString *)path {
    return self.url.path;
}


#pragma mark - Initialization and Configuration

+ (instancetype)requestWithURL:(NSURL *)url httpMethod:(NSString *)method formData:(NSArray<NSDictionary *> *)formData {
    return [[self alloc] initWithURL:url httpMethod:method formData:formData];
}


#pragma mark - Initialization and Configuration

- (instancetype)initWithURL:(NSURL *)url httpMethod:(NSString *)method formData:(NSArray<NSDictionary *> *)formData {
    if ((self = [super init])) {
        _formData = formData;
        _method = method;
        _url = url;

    }

    return self;
}


#pragma mark - Prepare

- (PNError *)validate {
    if (self.formData.count && [self bodyStreamAvailable]) {
        NSString *boundary = [[NSUUID UUID].UUIDString stringByReplacingOccurrencesOfString:@"-" withString:@""];
        NSUInteger dataSize = self.dataSize;

        self.httpBodyInputStream = [self multipartFormDataStreamWithBoundary:boundary
                                                             dataInputStream:_bodyStream
                                                                    filename:self.filename
                                                                cryptoModule:self.cryptoModule
                                                                  fromFields:self.formData
                                                                 streamsSize:&dataSize];

        if (!self.httpBodyInputStream) {
            NSDictionary *userInfo = PNErrorUserInfo(
                @"Unable to create HTTP body stream",
                @"Provided data streams opened or file is missing",
                nil,
                nil
            );

            return [PNError errorWithDomain:PNAPIErrorDomain code:PNAPIErrorUnacceptableParameters userInfo:userInfo];
        } else {
            NSMutableDictionary *headers = [NSMutableDictionary new];
            headers[@"content-type"] = [@"multipart/form-data; boundary=" stringByAppendingString:boundary];
            headers[@"content-length"] = @(dataSize).stringValue;
            self.headersOverride = headers;
        }
    } else if ([self bodyStreamAvailable]) self.httpBodyInputStream = _bodyStream;

    return nil;
}


#pragma mark - Helpers

- (NSInputStream *)multipartFormDataStreamWithBoundary:(NSString *)boundary
                                       dataInputStream:(NSInputStream *)stream
                                              filename:(NSString *)filename
                                          cryptoModule:(id<PNCryptoProvider>)cryptoModule
                                            fromFields:(NSArray<NSDictionary *> *)fields
                                           streamsSize:(NSUInteger *)streamsTotalSize {
    NSString *fileMIMEType = [self mimeTypeFromFilename:filename];

    if (fileMIMEType.length) {
        NSMutableArray<NSDictionary *> *mutableFields = [fields mutableCopy];

        for (NSUInteger fieldIdx = 0; fieldIdx < fields.count; fieldIdx++) {
            if (![fields[fieldIdx][@"key"] isEqualToString:@"Content-Type"]) continue;
            NSMutableDictionary *mutableField = [fields[fieldIdx] mutableCopy];
            NSString *fieldValue = mutableField[@"value"];

            if (fieldValue.length == 0 || [fieldValue rangeOfString:@"octet-stream"].location != NSNotFound) {
                mutableField[@"value"] = fileMIMEType;
                mutableFields[fieldIdx] = mutableField;
                fields = [mutableFields copy];
            }

            break;
        }
    }

    NSData *multipartFormData = [self multipartFormDataWithBoundary:boundary fromFields:fields];
    NSData *fileFormData = [self multipartFormFile:filename dataWithBoundary:boundary];
    NSMutableArray<NSInputStream *> *inputStreams = [NSMutableArray new];
    NSMutableArray<NSNumber *> *streamLengths = [NSMutableArray new];
    NSInputStream *formDataStream = nil;

    if (multipartFormData) {
        [streamLengths addObject:@(multipartFormData.length)];
        [inputStreams addObject:[NSInputStream inputStreamWithData:multipartFormData]];
    }

    if (fileFormData) {
        [streamLengths addObject:@(fileFormData.length)];
        [inputStreams addObject:[NSInputStream inputStreamWithData:fileFormData]];
    }

    NSNumber *fileStreamSize = @(*streamsTotalSize);
    if (cryptoModule) {
        PNResult<NSInputStream *> *encryptResult = [cryptoModule encryptStream:stream dataLength:*streamsTotalSize];
        if (!encryptResult.isError) {
            stream = encryptResult.data;
            fileStreamSize = @(stream.pn_dataLength);
        }
    }
    [streamLengths addObject:fileStreamSize];
    [inputStreams addObject:stream];

    NSData *multipartFormEndData = [self multipartFormEndDataWithBoundary:boundary];
    [streamLengths addObject:@(multipartFormEndData.length)];
    [inputStreams addObject:[NSInputStream inputStreamWithData:multipartFormEndData]];

    if (inputStreams.count == 4) {
        formDataStream = [PNSequenceInputStream inputStreamWithInputStreams:inputStreams lengths:streamLengths];
        *streamsTotalSize = ((PNSequenceInputStream *)formDataStream).length;
    } else {
        *streamsTotalSize = 0;
    }

    return formDataStream;
}

- (NSData *)multipartFormDataWithBoundary:(NSString *)boundary fromFields:(NSArray<NSDictionary *> *)fields {
    NSMutableData *multipartFormData = [NSMutableData new];

    [fields enumerateObjectsUsingBlock:^(NSDictionary *fieldData, NSUInteger fieldDataIdx, BOOL *stop) {
        NSString *fieldValue = fieldData[@"value"];
        NSString *fieldName = fieldData[@"key"];

        [multipartFormData appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary]
                                       dataUsingEncoding:NSUTF8StringEncoding]];
        [multipartFormData appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n",
                                        fieldName]
                                       dataUsingEncoding:NSUTF8StringEncoding]];
        [multipartFormData appendData:[[NSString stringWithFormat:@"%@\r\n", fieldValue]
                                       dataUsingEncoding:NSUTF8StringEncoding]];
    }];

    return multipartFormData;
}

- (NSData *)multipartFormFile:(NSString *)filename dataWithBoundary:(NSString *)boundary {
    NSString *disposition = PNStringFormat(@"Content-Disposition: form-data; name=\"file\"; filename=\"%@\"\r\n\r\n",
                                           filename);
    NSMutableData *multipartFormFileData = [NSMutableData new];

    [multipartFormFileData appendData:[PNStringFormat(@"--%@\r\n", boundary) dataUsingEncoding:NSUTF8StringEncoding]];
    [multipartFormFileData appendData:[disposition dataUsingEncoding:NSUTF8StringEncoding]];

    return multipartFormFileData;
}

- (NSData *)multipartFormEndDataWithBoundary:(NSString *)boundary {
    return [[NSString stringWithFormat:@"\r\n--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding];
}

- (NSString *)mimeTypeFromFilename:(NSString *)filename {
#if __has_include(<UniformTypeIdentifiers/UniformTypeIdentifiers.h>)
    UTType *type = [UTType typeWithTag:filename.pathExtension tagClass:UTTagClassFilenameExtension conformingToType:nil];
    return type.preferredMIMEType ?: @"application/octet-stream";
#else
    return @"application/octet-stream";
#endif // __has_include(<UniformTypeIdentifiers/UniformTypeIdentifiers.h>)
}

#pragma mark -


@end
