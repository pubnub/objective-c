/**
 * @author Serhii Mamontov
 * @version 4.15.0
 * @since 4.15.0
 * @copyright © 2010-2020 PubNub, Inc.
 */
#import "PNGenerateFileUploadURLRequest.h"
#import "PNRequest+Private.h"
#import "PNErrorCodes.h"
#import "PNHelpers.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Protected interface declaration

@interface PNGenerateFileUploadURLRequest ()


#pragma mark - Information

/**
 * @brief Name of channel to which \c data should be uploaded.
 */
@property (nonatomic, copy) NSString *channel;


#pragma mark - Initialization & Configuration

/**
 * @brief Initialize \c upload \c data \c URL \c generation request.
 *
 * @param channel Name of channel to which \c data should be uploaded.
 * @param name File name which will be used to store uploaded \c data.
 *
 * @return Initialized and ready to use \c \c upload \c data \c URL \c generation request.
 */
- (instancetype)initWithChannel:(NSString *)channel filename:(NSString *)name;

#pragma mark -


@end

NS_ASSUME_NONNULL_END


#pragma mark - Interface implementation

@implementation PNGenerateFileUploadURLRequest


#pragma mark - Information

- (PNOperationType)operation {
    return PNGenerateFileUploadURLOperation;
}

- (NSString *)httpMethod {
    return @"POST";
}

- (PNRequestParameters *)requestParameters {
    PNRequestParameters *parameters = [super requestParameters];

    if (self.parametersError) {
        return parameters;
    }

    if (self.channel.length) {
        [parameters addPathComponent:[PNString percentEscapedString:self.channel]
                      forPlaceholder:@"{channel}"];
    } else {
        self.parametersError = [self missingParameterError:@"channel" forObjectRequest:@"Request"];
    }

    return parameters;
}

- (NSData *)bodyData {
    if (self.parametersError) {
        return nil;
    }

    NSMutableDictionary *info = [NSMutableDictionary new];
    NSError *error = nil;
    NSData *data = nil;

    if (self.filename) {
        info[@"name"] = [PNString percentEscapedString:self.filename];
    } else {
        self.parametersError = [self missingParameterError:@"filename" forObjectRequest:@"Request"];
        return nil;
    }

    if ([NSJSONSerialization isValidJSONObject:info]) {
        data = [NSJSONSerialization dataWithJSONObject:info
                                               options:(NSJSONWritingOptions)0
                                                 error:&error];
    } else {
        NSDictionary *errorInformation = @{
            NSLocalizedDescriptionKey: @"Unable to serialize to JSON string",
            NSLocalizedFailureReasonErrorKey: @"Provided object contains unsupported data type instances."
        };

        error = [NSError errorWithDomain:NSCocoaErrorDomain
                                    code:NSPropertyListWriteInvalidError
                                userInfo:errorInformation];
    }

    if (error) {
        NSDictionary *errorInformation = @{
            NSLocalizedDescriptionKey: @"File information serialization did fail",
            NSUnderlyingErrorKey: error
        };

        self.parametersError = [NSError errorWithDomain:kPNAPIErrorDomain
                                                   code:kPNAPIUnacceptableParameters
                                               userInfo:errorInformation];
    }

    return data;
}


#pragma mark - Initialization & Configuration

+ (instancetype)requestWithChannel:(NSString *)channel filename:(NSString *)name {
    return [[self alloc] initWithChannel:channel filename:name];
}

- (instancetype)initWithChannel:(NSString *)channel filename:(NSString *)name {
    if ((self = [super init])) {
        _channel = [channel copy];
        _filename = [name copy];
    }
    
    return self;
}

- (instancetype)init {
    [self throwUnavailableInitInterface];

    return nil;
}

#pragma mark -


@end
