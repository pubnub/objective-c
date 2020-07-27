/**
 * @author Serhii Mamontov
 * @version 4.15.0
 * @since 4.15.0
 * @copyright © 2010-2020 PubNub, Inc.
 */
#import "PNSendFileRequest+Private.h"
#import "PNRequest+Private.h"
#import "PNErrorCodes.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Protected interface declaration

@interface PNSendFileRequest ()


#pragma mark - Information

/**
 * @brief Input stream with data which should be uploaded to remote storage server / service.
 */
@property (nonatomic, strong) NSInputStream *stream;

/**
 * @brief Size of data which can be read from \c stream.
 */
@property (nonatomic, assign) NSUInteger size;

/**
 * @brief Name of channel to which \c data should be uploaded.
 */
@property (nonatomic, copy) NSString *channel;


#pragma mark - Initialization & Configuration

/**
 * @brief Initialize \c upload from \c stream request.
 *
 * @param channel Name of channel to which \c data should be uploaded.
 * @param name File name which will be used to store uploaded \c data.
 * @param stream Stream to file on file system or memory which should be uploaded.
 * @param error Request initialization error.
 *
 * @return Initialized and ready to use \c upload from \c stream request.
 */
- (instancetype)initWithChannel:(NSString *)channel
                       fileName:(NSString *)name
                         stream:(nullable NSInputStream *)stream
                           size:(NSUInteger)size
                          error:(nullable NSError *)error;

#pragma mark -


@end

NS_ASSUME_NONNULL_END


#pragma mark - Interface implementation

@implementation PNSendFileRequest


#pragma mark - Information

- (PNOperationType)operation {
    return PNSendFileOperation;
}

- (NSString *)httpMethod {
    return @"POST";
}

- (PNRequestParameters *)requestParameters {
    PNRequestParameters *parameters = [super requestParameters];
    
    return parameters;
}


#pragma mark - Initialization & Configuration

+ (instancetype)requestWithChannel:(NSString *)channel fileURL:(NSURL *)url {
    NSFileManager *fileManager = NSFileManager.defaultManager;
    NSString *fileName = url.lastPathComponent;
    NSString *fileURL = url.absoluteString;
    NSInputStream *inputStream = nil;
    NSUInteger fileSize = 0;
    BOOL isDirectory = NO;
    NSError *error = nil;
    
    if (!fileURL || ![fileManager fileExistsAtPath:fileURL isDirectory:&isDirectory] || isDirectory) {
        NSString *reason = isDirectory ? @"URL points to directory" : @"Target file not found";
        NSString *filePath = fileURL ?: @"path is missing";
        error = [NSError errorWithDomain:kPNAPIErrorDomain
                                    code:kPNAPIUnacceptableParameters
                                userInfo:@{
                                    NSLocalizedDescriptionKey: @"Unable to send file",
                                    NSLocalizedFailureReasonErrorKey: reason,
                                    NSFilePathErrorKey: filePath
                                }];
    } else {
        NSDictionary *fileAttributes = [fileManager attributesOfItemAtPath:fileURL error:nil];
        fileSize = ((NSNumber *)fileAttributes[NSFileSize]).unsignedIntegerValue;
        
        inputStream = [NSInputStream inputStreamWithURL:[[NSURL alloc] initFileURLWithPath:fileURL]];
    }
    
    return [[self alloc] initWithChannel:channel
                                fileName:fileName
                                  stream:inputStream
                                    size:fileSize
                                   error:error];
}

+ (instancetype)requestWithChannel:(NSString *)channel
                          fileName:(NSString *)name
                              data:(NSData *)data {
    
    NSInputStream *inputStream = nil;
    NSError *error = nil;
    
    if (data.length == 0) {
        NSString *reason = @"Data object is empty";
        error = [NSError errorWithDomain:kPNAPIErrorDomain
                                    code:kPNAPIUnacceptableParameters
                                userInfo:@{
                                    NSLocalizedDescriptionKey: @"Unable to send binary",
                                    NSLocalizedFailureReasonErrorKey: reason
                                }];
    } else {
        inputStream = [NSInputStream inputStreamWithData:data];
    }
    
    return [[self alloc] initWithChannel:channel
                                fileName:name
                                  stream:inputStream
                                    size:data.length
                                   error:error];
}

+ (instancetype)requestWithChannel:(NSString *)channel
                          fileName:(NSString *)name
                            stream:(NSInputStream *)stream
                              size:(NSUInteger)size {
    
    NSError *error = nil;
    
    if (stream.streamStatus != NSStreamStatusNotOpen) {
        NSString *reason = @"Stream should be closed.";
        error = [NSError errorWithDomain:kPNAPIErrorDomain
                                    code:kPNAPIUnacceptableParameters
                                userInfo:@{
                                    NSLocalizedDescriptionKey: @"Unable to send data from stream",
                                    NSLocalizedFailureReasonErrorKey: reason
                                }];
    } else if (size == 0) {
        NSString *reason = @"Unable to send empty data object.";
        error = [NSError errorWithDomain:kPNAPIErrorDomain
                                    code:kPNAPIUnacceptableParameters
                                userInfo:@{
                                    NSLocalizedDescriptionKey: @"Unable to send data from stream",
                                    NSLocalizedFailureReasonErrorKey: reason
                                }];
    }
    
    return [[self alloc] initWithChannel:channel
                                fileName:name
                                  stream:stream
                                    size:size
                                   error:error];
}

- (instancetype)initWithChannel:(NSString *)channel
                       fileName:(NSString *)name
                         stream:(NSInputStream *)stream
                           size:(NSUInteger)size
                          error:(NSError *)error {
    
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

#pragma mark -


@end
