#import "PNGenerateFileUploadURLRequest.h"
#import "PNBaseRequest+Private.h"
#import "PNTransportRequest.h"
#import "PNFunctions.h"
#import "PNHelpers.h"
#import "PNError.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Private interface declaration

/// `File upload URL` request private extension.
@interface PNGenerateFileUploadURLRequest ()


#pragma mark - Properties

/// Request post body.
@property(strong, nullable, nonatomic) NSData *body;

/// Name of channel to which \c data should be uploaded.
@property (nonatomic, copy) NSString *channel;


#pragma mark - Initialization and Configuration

/// Initialize `Upload data URL generation` request.
///
/// - Parameters:
///   - channel: Name of channel to which `data` should be uploaded.
///   - name File name which will be used to store uploaded `data`.
/// - Returns: Initialized `upload data URL generation` request.
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

- (TransportMethod)httpMethod {
    return TransportPOSTMethod;
}

- (NSDictionary *)query {
    NSMutableDictionary *query = [NSMutableDictionary new];
    
    if (self.arbitraryQueryParameters.count) [query addEntriesFromDictionary:self.arbitraryQueryParameters];
    
    return query.count ? query : nil;
}

- (NSDictionary *)headers {
    NSMutableDictionary *headers =[([super headers] ?: @{}) mutableCopy];
    headers[@"Content-Type"] = @"application/json";
    
    return headers;
}

- (NSString *)path {
    return PNStringFormat(@"/v1/files/%@/channels/%@/generate-upload-url", self.subscribeKey, self.channel);
}


#pragma mark - Initialization and Configuration

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


#pragma mark - Prepare

- (PNError *)validate {
    NSDictionary *payload = nil;
    NSError *error = nil;
    
    if (self.channel.length == 0) return  [self missingParameterError:@"channel" forObjectRequest:@"Request"];
    if (!self.filename) return [self missingParameterError:@"filename" forObjectRequest:@"Request"];
    else payload = @{ @"name": [PNString percentEscapedString:self.filename] };
    
    if ([NSJSONSerialization isValidJSONObject:payload]) {
        self.body = [NSJSONSerialization dataWithJSONObject:payload options:(NSJSONWritingOptions)0 error:&error];
    } else {
        NSDictionary *userInfo = @{
            NSLocalizedDescriptionKey: @"Unable to serialize to JSON string",
            NSLocalizedFailureReasonErrorKey: @"Provided object contains unsupported data type instances."
        };
        
        error = [NSError errorWithDomain:NSCocoaErrorDomain code:NSPropertyListWriteInvalidError userInfo:userInfo];
    }
    
    if (error) {
        NSDictionary *userInfo = @{
            NSLocalizedDescriptionKey: @"File information serialization did fail",
            NSUnderlyingErrorKey: error
        };
        
        return [PNError errorWithDomain:PNAPIErrorDomain code:PNAPIErrorUnacceptableParameters userInfo:userInfo];
    }
    
    
    
    return nil;
}

#pragma mark -


@end
