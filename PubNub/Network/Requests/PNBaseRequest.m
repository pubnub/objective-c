#import "PNBaseRequest+Private.h"
#import "PNTransportRequest+Private.h"
#import "PNFunctions.h"
#import "PNError.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Private interface declaration

/// General request private extension.
@interface PNBaseRequest () <PNRequest>


#pragma mark - Properties

/// Current PubNub client configuration with keysey and active client user information.
@property(strong, nonatomic) PNConfiguration *configuration;


#pragma mark - Helpers

/// Whether request expexted to have data to push to the remote service or not.
- (BOOL)shouldHaveBody;

#pragma mark -


@end

NS_ASSUME_NONNULL_END


#pragma mark - Interface implementation

@implementation PNBaseRequest


#pragma mark - Properties

- (NSTimeInterval)nonSubscribeRequestTimeout {
    return self.configuration.nonSubscribeRequestTimeout;
}

- (NSTimeInterval)subscribeMaximumIdleTime {
    return self.configuration.subscribeMaximumIdleTime;
}

- (id<PNCryptoProvider>)cryptoModule {
    return self.configuration.cryptoModule;
}

- (NSInteger)presenceHeartbeatValue {
    return self.configuration.presenceHeartbeatValue;
}

- (PNTransportRequest *)request {
    NSMutableDictionary *headers = [(self.headers ?: @{}) mutableCopy];
    PNTransportRequest *request = [PNTransportRequest new];
    request.bodyStreamAvailable = self.bodyStreamAvailable;
    request.timeout = self.nonSubscribeRequestTimeout;
    request.compressBody = self.shouldCompressBody;
    request.responseAsFile = self.responseAsFile;
    request.method = self.httpMethod;
    request.origin = self.origin;
    request.query = self.query;
    request.path = self.path;

    if ([self shouldHaveBody]) {
        if (!self.bodyStreamAvailable) {
            request.body = self.body;
            headers[@"content-length"] = @(request.body.length).stringValue;
        } else request.bodyStream = self.bodyStream;
    }

    request.headers = headers;

    return request;
}

- (NSInputStream *)bodyStream {
    return nil;
}

- (TransportMethod)httpMethod {
    return TransportGETMethod;
}

- (BOOL)bodyStreamAvailable {
    return NO;
}

- (BOOL)shouldCompressBody {
    return NO;
}

- (NSString *)subscribeKey {
    return self.configuration.subscribeKey;
}

- (NSDictionary *)headers {
    return nil;
}

- (NSString *)publishKey {
    return self.configuration.publishKey;
}

- (NSDictionary *)query {
    return nil;
}

- (BOOL)responseAsFile {
    return NO;
}

- (NSString *)origin {
    return nil;
}

- (NSString *)path {
    @throw [NSException exceptionWithName:@"PNNotImplemented"
                                   reason:@"'path' not implemented by subclass"
                                 userInfo:nil];
}

- (NSData *)body {
    return nil;
}

- (PNOperationType)operation {
    @throw [NSException exceptionWithName:@"PNNotImplemented"
                                   reason:@"'operation' not implemented by subclass"
                                 userInfo:nil];
}



#pragma mark - Initialization and Configuration

- (void)setupWithClientConfiguration:(PNConfiguration *)configuration {
    _configuration = configuration;
}


#pragma mark - Prepare

- (PNError *)validate {
    @throw [NSException exceptionWithName:@"PNRequestValidation"
                                   reason:@"Not implemented by subclass"
                                 userInfo:nil];
}


#pragma mark - Helpers

- (BOOL)shouldHaveBody {
    return self.httpMethod == TransportPOSTMethod || self.httpMethod == TransportPATCHMethod;
}

- (PNError *)missingParameterError:(NSString *)parameter forObjectRequest:(NSString *)type {
    NSString *reason = PNStringFormat(@"%@'s '%@' parameter is missing or empty.", type.capitalizedString, parameter);
    
    return [PNError errorWithDomain:PNAPIErrorDomain
                               code:PNAPIErrorUnacceptableParameters
                           userInfo:PNErrorUserInfo(@"Request parameters error", reason, nil, nil)];
}

- (PNError *)valueTooShortErrorForParameter:(NSString *)parameter
                            ofObjectRequest:(NSString *)type
                                 withLength:(NSUInteger)actualLength
                              minimumLength:(NSUInteger)minimumLength {
    
    NSString *reason = PNStringFormat(@"%@'s '%@' parameter is too shorty (%@ when %@ minimum allowed).",
                                      type.capitalizedString, parameter, @(actualLength), @(minimumLength));
    
    return [PNError errorWithDomain:PNAPIErrorDomain
                               code:PNAPIErrorUnacceptableParameters
                           userInfo:PNErrorUserInfo(@"Request parameters error", reason, nil, nil)];
}

- (PNError *)valueTooLongErrorForParameter:(NSString *)parameter
                           ofObjectRequest:(NSString *)type
                                withLength:(NSUInteger)actualLength
                             maximumLength:(NSUInteger)maximumLength {
    
    NSString *reason = PNStringFormat(@"%@'s '%@' parameter is too long (%@ when %@  maximum allowed).",
                                      type.capitalizedString, parameter, @(actualLength), @(maximumLength));
    
    return [PNError errorWithDomain:PNAPIErrorDomain
                               code:PNAPIErrorUnacceptableParameters
                           userInfo:PNErrorUserInfo(@"Request parameters error", reason, nil, nil)];
}

- (void)throwUnavailableInitInterface {
    NSDictionary *errorInformation = @{ NSLocalizedRecoverySuggestionErrorKey: @"Use provided request constructor" };
    
    @throw [NSException exceptionWithName:@"PNInterfaceNotAvailable"
                                   reason:@"+new or -init methods unavailable."
                                 userInfo:errorInformation];
}

#pragma mark -


@end
