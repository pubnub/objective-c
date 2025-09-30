#import "PNSendFileRequest+Private.h"
#import "PNBaseRequest+Private.h"
#import "PNTransportRequest.h"
#import "PNError.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Private interface declaration

/// `Upload file` request private extension.
@interface PNSendFileRequest ()


#pragma mark - Properties

/// Request configuration error.
@property(strong, nullable, nonatomic) PNError *parametersError;

/// Input stream with data which should be uploaded to remote storage server / service.
@property(strong, nonatomic) NSInputStream *stream;

/// Size of data which can be read from `stream`.
@property(assign, nonatomic) NSUInteger size;

/// Name of channel to which `data` should be uploaded.
@property(copy, nonatomic) NSString *channel;


#pragma mark - Initialization and configuration

/// Initialize `stream data upload` request instance.
///
/// Request can upload `stream` data.
///
/// - Parameters:
///   - channel: Name of channel to which `stream data` should be uploaded.
///   - name: File name which will be used to store uploaded `stream data`.
///   - stream: Stream to file on local file system or memory which should be uploaded.
///   - size: Size of data which can be read from `stream`.
///   - error: Request initialization error.
/// - Returns: Initialized `stream data upload` request.
- (instancetype)initWithChannel:(NSString *)channel
                       fileName:(NSString *)name
                         stream:(nullable NSInputStream *)stream
                           size:(NSUInteger)size
                          error:(nullable PNError *)error;

#pragma mark -


@end

NS_ASSUME_NONNULL_END


#pragma mark - Interface implementation

@implementation PNSendFileRequest


#pragma mark - Properties

- (PNOperationType)operation {
    return PNSendFileOperation;
}

- (TransportMethod)httpMethod {
    return TransportPOSTMethod;
}

- (BOOL)bodyStreamAvailable {
    return self.stream != nil;
}

- (NSInputStream *)bodyStream {
    return self.stream;
}

- (NSDictionary *)query {
    NSMutableDictionary *query = [NSMutableDictionary new];
    
    if (self.arbitraryQueryParameters.count) [query addEntriesFromDictionary:self.arbitraryQueryParameters];
    
    return query.count ? query : nil;
}


#pragma mark - Initialization and Configuration

+ (instancetype)requestWithChannel:(NSString *)channel fileURL:(NSURL *)url {
    NSURL *fileURL = url.isFileURL ? url : [NSURL fileURLWithPath:url.path];
    NSFileManager *fileManager = NSFileManager.defaultManager;
    NSString *fileName = url.lastPathComponent;
    NSInputStream *inputStream = nil;
    NSString *filePath = url.path;
    NSUInteger fileSize = 0;
    BOOL isDirectory = NO;
    PNError *error = nil;

    if (!filePath || ![fileManager fileExistsAtPath:filePath isDirectory:&isDirectory] || isDirectory) {
        NSString *reason = isDirectory ? @"URL points to directory" : @"Target file not found";
        filePath = filePath ?: @"path is missing";
        error = [PNError errorWithDomain:PNAPIErrorDomain
                                    code:PNAPIErrorUnacceptableParameters
                                userInfo:@{
            NSLocalizedDescriptionKey: @"Unable to send file",
            NSLocalizedFailureReasonErrorKey: reason,
            NSFilePathErrorKey: filePath
        }];
    } else {
        NSDictionary *fileAttributes = [fileManager attributesOfItemAtPath:filePath error:nil];
        fileSize = ((NSNumber *)fileAttributes[NSFileSize]).unsignedIntegerValue;
        
        inputStream = [NSInputStream inputStreamWithURL:fileURL];
    }
    
    return [[self alloc] initWithChannel:channel fileName:fileName stream:inputStream size:fileSize error:error];
}

+ (instancetype)requestWithChannel:(NSString *)channel fileName:(NSString *)name data:(NSData *)data {
    NSInputStream *inputStream = nil;
    PNError *error = nil;
    
    if (data.length != 0) inputStream = [NSInputStream inputStreamWithData:data];
    else {
        NSString *reason = @"Data object is empty";
        error = [PNError errorWithDomain:PNAPIErrorDomain
                                    code:PNAPIErrorUnacceptableParameters
                                userInfo:@{
            NSLocalizedDescriptionKey: @"Unable to send binary",
            NSLocalizedFailureReasonErrorKey: reason
        }];
    }
    
    return [[self alloc] initWithChannel:channel fileName:name stream:inputStream size:data.length error:error];
}

+ (instancetype)requestWithChannel:(NSString *)channel
                          fileName:(NSString *)name
                            stream:(NSInputStream *)stream
                              size:(NSUInteger)size {
    PNError *error = nil;

    if (stream.streamStatus != NSStreamStatusNotOpen) {
        NSString *reason = @"Stream should be closed.";
        error = [PNError errorWithDomain:PNAPIErrorDomain
                                    code:PNAPIErrorUnacceptableParameters
                                userInfo:@{
            NSLocalizedDescriptionKey: @"Unable to send data from stream",
            NSLocalizedFailureReasonErrorKey: reason
        }];
    } else if (size == 0) {
        NSString *reason = @"Unable to send empty data object.";
        error = [PNError errorWithDomain:PNAPIErrorDomain
                                    code:PNAPIErrorUnacceptableParameters
                                userInfo:@{
            NSLocalizedDescriptionKey: @"Unable to send data from stream",
            NSLocalizedFailureReasonErrorKey: reason
        }];
    }
    
    return [[self alloc] initWithChannel:channel fileName:name stream:stream size:size error:error];
}

- (instancetype)initWithChannel:(NSString *)channel
                       fileName:(NSString *)name
                         stream:(NSInputStream *)stream
                           size:(NSUInteger)size
                          error:(PNError *)error {
    if ((self = [super init])) {
        self.parametersError = error;
        _channel = [channel copy];
        _fileMessageStore = YES;
        _filename = [name copy];
        _stream = stream;
        _size = size;
    }
    
    return self;
}

- (instancetype)init {
    [self throwUnavailableInitInterface];

    return nil;
}


#pragma mark - Prepare

- (PNError *)validate {
    return self.parametersError;
}


#pragma mark - Misc

- (NSDictionary *)dictionaryRepresentation {
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithDictionary:@{
        @"fileMessageTTL": @(self.fileMessageTTL),
        @"filename": self.filename ?: @"missing",
        @"channel": self.channel ?: @"missing",
    }];
    
    if (self.arbitraryQueryParameters) dictionary[@"arbitraryQueryParameters"] = self.arbitraryQueryParameters;
    if (self.fileMessageMetadata) dictionary[@"fileMessageMetadata"] = self.fileMessageMetadata;
    if (self.customMessageType) dictionary[@"customMessageType"] = self.customMessageType;
    if (self.fileMessageStore) dictionary[@"fileMessageStore"] = @(self.fileMessageStore);
    if (self.cryptoModule) {
        if ([self.cryptoModule respondsToSelector:@selector(dictionaryRepresentation)])
            dictionary[@"cryptoModule"] = [self.cryptoModule performSelector:@selector(dictionaryRepresentation)];
        else dictionary[@"cryptoModule"] = NSStringFromClass(self.cryptoModule.class);
    }
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    if (self.cipherKey) dictionary[@"cipherKey"] = self.cipherKey;
#pragma clang diagnostic pop
    if (self.message) dictionary[@"message"] = self.message;
    if (self.stream) {
        NSString *streamStatus = @"closed";
        if (self.stream.streamStatus == NSStreamStatusAtEnd) streamStatus = @"atEnd";
        else if (self.stream.streamStatus == NSStreamStatusError) streamStatus = @"error";
        else if (self.stream.streamStatus == NSStreamStatusNotOpen) streamStatus = @"not open";
        else if (self.stream.streamStatus == NSStreamStatusOpen) streamStatus = @"open";
        else if (self.stream.streamStatus == NSStreamStatusOpening) streamStatus = @"opening";
        else if (self.stream.streamStatus == NSStreamStatusReading) streamStatus = @"reading";
        else if (self.stream.streamStatus == NSStreamStatusWriting) streamStatus = @"writing";
        
        NSMutableDictionary *streamDictionary = [NSMutableDictionary dictionaryWithDictionary:@{
            @"hasBytesAvailable": @(self.stream.hasBytesAvailable),
            @"streamStatus": streamStatus
        }];
        if (self.stream.streamError) streamDictionary[@"error"] = self.stream.streamError;
        
        dictionary[@"stream"] = streamDictionary;
    }
    
    return dictionary;
}

#pragma mark -


@end
