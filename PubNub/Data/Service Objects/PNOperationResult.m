#import "PNOperationResult+Private.h"
#import "PNPrivateStructures.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Private interface declaration

/// General operation (request or client generated) result object private extension.
@interface PNOperationResult ()


#pragma mark - Properties

/// Processed operation outcome data object.
@property(strong, nullable, nonatomic) id responseData;

/// Type of operation for which result object has been created.
@property(assign, nonatomic) PNOperationType operation;


#pragma mark - Properties (deprecated)

/// Whether secured connection has been used to send request or not.
@property(assign, nonatomic, getter = isTLSEnabled) BOOL TLSEnabled
    DEPRECATED_MSG_ATTRIBUTE("This property deprecated and will be removed with the next major update. The actual value"
                             " can be retrieved from the client configuration object (`PNConfiguration`).");

/// Copy of the original request which has been used to fetch or push data to **PubNub** network.
///
/// > Important: This information not available anymore because property has been deprecated.
@property(copy, nonatomic, nullable) NSURLRequest *clientRequest
DEPRECATED_MSG_ATTRIBUTE("This property deprecated and will be removed with the next major update.");

/// Authorisation key / token which is used to get access to protected remote resources.
///
/// Some resources can be protected by **PAM** functionality and access done using this authorisation key.
@property(copy, nonatomic, nullable) NSString *authKey
DEPRECATED_MSG_ATTRIBUTE("This property deprecated and will be removed with the next major update. The actual value"
                         " can be retrieved from the client configuration object (`PNConfiguration`).");

/// **PubNub** network host name or IP address against which `request` has been called.
@property(copy, nullable, nonatomic) NSString *origin
    DEPRECATED_MSG_ATTRIBUTE("This property deprecated and will be removed with the next major update. The actual value"
                             " can be retrieved from the client configuration object (`PNConfiguration`).");

/// UUID which is currently used by client to identify user in **PubNub** network.
@property(copy, nullable, nonatomic) NSString *userID
    DEPRECATED_MSG_ATTRIBUTE("This property deprecated and will be removed with the next major update. The actual value"
                             " can be retrieved from the client configuration object (`PNConfiguration`).");

/// HTTP status code with which `request` completed processing with **PubNub** service.
@property(assign, nonatomic) NSInteger statusCode
    DEPRECATED_MSG_ATTRIBUTE("This property deprecated and will be removed with the next major update.");

#pragma mark -


@end

NS_ASSUME_NONNULL_END


#pragma mark - Interface implementation

@implementation PNOperationResult


#pragma mark - Properties

- (NSString *)stringifiedOperation {
    return self.operation >= PNSubscribeOperation ? PNOperationTypeStrings[self.operation] : @"Unknown";
}


#pragma mark - Propeties (deprecated)

- (NSString *)uuid {
    return self.userID;
}


#pragma mark - Initialization and Configuration

+ (instancetype)objectWithOperation:(PNOperationType)operation response:(id)response {
    return [[self alloc] initWithOperation:operation response:response];
}

- (instancetype)initWithOperation:(PNOperationType)operation response:(id)response {
    if ((self = [super init])) {
        _responseData = response;
        _operation = operation;
    }
    
    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    PNOperationResult *result = [[[self class] allocWithZone:zone] initWithOperation:self.operation
                                                                            response:self.responseData];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    result.statusCode = self.statusCode;
    result.TLSEnabled = self.isTLSEnabled;
    result.userID = self.userID;
    result.authKey = self.authKey;
    result.origin = self.origin;
    result.clientRequest = self.clientRequest;
#pragma clang diagnostic pop

    return self;

}


#pragma mark - Misc

- (NSDictionary *)dictionaryRepresentationWithSerializer:(id<PNObjectSerializer>)serializer {
    id processedData = self.responseData;

    if (serializer && processedData) {
        NSError *err;
        NSData *serializedData = [serializer dataOfClass:[NSDictionary class] fromObject:processedData withError:&err];
        NSDictionary *serializedDictionary = [serializer.jsonSerializer JSONObjectWithData:serializedData error:&err];
        if (serializedDictionary) processedData = serializedDictionary;
    }
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    NSMutableDictionary *response = [@{
        @"Status code": @(self.statusCode),
        @"Processed data": processedData ?: @"no data"
    } mutableCopy];

    return @{@"Operation": PNOperationTypeStrings[self.operation],
             @"Request": @{
                 @"Method": self.clientRequest.HTTPMethod ?: @"GET",
                 @"URL": [self.clientRequest.URL absoluteString] ?: @"null",
                 @"POST Body size": [self.clientRequest valueForHTTPHeaderField:@"content-length"] ?: @0,
                 @"Secure": (self.isTLSEnabled ? @"YES" : @"NO"),
                 @"UUID": (self.uuid?: @"unknown"),
                 @"Authorization": (self.authKey?: @"not set"),
                 @"Origin": (self.origin?: @"unknown")
             },
             @"Response": response
    };
#pragma clang diagnostic pop
}

- (NSString *)stringifiedRepresentationWithSerializer:(id<PNObjectSerializer>)serializer {
    NSDictionary *dictionary = [self dictionaryRepresentationWithSerializer:serializer];
    NSData *dictinaryData = [serializer.jsonSerializer dataWithJSONObject:dictionary error:nil];

    return [[NSString alloc] initWithData:dictinaryData encoding:NSUTF8StringEncoding];
}

#pragma mark -


@end
