#import "PNURLSessionTransportResponse.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Private interface declaration

/// `NSURLSession`-based transport response module private extension.
@interface PNURLSessionTransportResponse ()


#pragma mark - Properties

/// Service response headers.
///
/// > Important: Header names are in lowercase.
@property(strong, nullable, nonatomic) NSDictionary<NSString *, NSString *> *headers;

/// Remote resource request response.
@property(strong, nullable, nonatomic) NSHTTPURLResponse *response;

/// Remote resource request response data.
@property(strong, nullable, nonatomic) NSData *data;


#pragma mark - Initialization and Configuration

/// Initialize transport response object from `NSURLResponse`.
///
/// - Parameters:
///   - response: Remote resource request response.
///   - data: Remote resource request response data.
/// - Returns: Initialized transport response object.
- (instancetype)initWithNSURLResponse:(nullable NSURLResponse *)response data:(nullable NSData *)data;

#pragma mark -


@end

NS_ASSUME_NONNULL_END


#pragma mark - Interface implementation

@implementation PNURLSessionTransportResponse


#pragma mark - Properties

- (NSInputStream *)bodyStream {
    return nil;
}

- (BOOL)bodyStreamAvailable {
    return NO;
}

- (NSUInteger)statusCode {
    return self.response.statusCode;
}

- (NSString *)MIMEType {
    return self.response.MIMEType;
}

- (NSString *)url {
    return self.response.URL.absoluteString;
}

- (NSData *)body {
    return self.data;
}


#pragma mark - Initialization and Configuration

+ (instancetype)responseWithNSURLResponse:(NSURLResponse *)response data:(NSData *)data {
    return [[self alloc] initWithNSURLResponse:response data:data];
}

- (instancetype)initWithNSURLResponse:(NSURLResponse *)response data:(NSData *)data {
    if ((self = [super init])) {
        _response = (NSHTTPURLResponse *)response;
        _data = data;
        
        NSDictionary *responseHeaders = _response.allHeaderFields;
        NSMutableDictionary *headers = [NSMutableDictionary dictionaryWithCapacity:responseHeaders.count];
        for (NSString *header in responseHeaders.allKeys) headers[header.lowercaseString] = responseHeaders[header];
        _headers = headers;
    }
    
    return self;
}

#pragma mark -

@end
