#import "PNOperationDataParser.h"
#import <PubNub/PNErrorStatus.h>
#import "PNBaseOperationData+Private.h"
#import "PNOperationResult+Private.h"
#import "PNErrorData+Private.h"
#import "PNStatus+Private.h"
#import "PNFunctions.h"
#import "PNXMLParser.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Private interface declaration

@interface PNOperationDataParseResult<ResultType, StatusType> ()


#pragma mark - Properties

/// API request processing result with de-serialized response data object.
///
/// If there is no error and it is expected to have result data which object will be parsed from the service response.
@property(strong, nullable, nonatomic) ResultType result;

/// API request processing status with de-serialized request status data.
///
/// In case of error or non-fetching requests which object may contain request processing status data.
@property(strong, nullable, nonatomic) StatusType status;


#pragma mark - Initialization and Configuration

/// Initialize parse result object.
///
/// - Parameters:
///   - result: API request processing result with de-serialized response data object.
///   - status: API request processing status with de-serialized request status data.
/// - Returns: Initialized parse result object.
- (instancetype)initWithResult:(ResultType)result status:(StatusType)status;

#pragma mark -


@end

/// Remote service response parser private extension.
@interface PNOperationDataParser ()


#pragma mark - Properties

/// Service response data serializer to map response to the data model.
@property(strong, nonatomic, readonly) id<PNObjectSerializer> serializer;

/// Additional information which can be used by `aClass` custom initializer.
@property(strong, nullable, nonatomic) NSDictionary *additionalData;

/// Class of object which represents API result (for data fetching requests).
@property(strong, nonatomic, readonly) Class resultClass;

/// Class of object which represents API request processing status (for non-data fetching requests) or error status data.
@property(strong, nonatomic, readonly) Class statusClass;


#pragma mark - Initialization and Configuration

/// Initialize operation data parser.
///
/// - Parameters:
///   - serializer: Service response data serializer to map response to the data model.
///   - resultClass: Class of object which represents API result (for data fetching requests).
///   - statusClass: Class of object which represents API request processing status (for non-data fetching requests) or
///   error status data.
///   - additionalData: Additional information which can be used by `aClass` custom initializer.
/// - Returns: Initialized operation data parser.
- (instancetype)initWithSerializer:(id<PNObjectSerializer>)serializer
                            result:(nullable Class)resultClass
                            status:(nullable Class)statusClass
                withAdditionalData:(nullable NSDictionary *)additionalData;


#pragma mark - Helpers

/// Create unexpected content type error data object.
///
/// - Parameter error: Transport-related request processing error (network issues, cancelled or timeout request, and
/// etc.).
/// - Returns: Ready to use unexpected content type error data object.
- (PNErrorData *)errorDataWithUnexpectedServiceResponseError:(nullable PNError *)error;

/// Create malformed service response error data.
///
/// Parser wasn't able to map response to any of provided data classes.
///
/// - Parameter error: Response de-serialization error.
/// - Returns: Ready to use malformed service response error data object.
- (PNErrorData *)errorDataWithMalformedServiceResponseError:(nullable PNError *)error;

/// Create malformed service response error data.
///
/// Parser wasn't able to map response to any of provided data classes.
///
/// - Parameters:
///   - data: Service binary response in with XML data.
///   - error: Transport-related request processing error (network issues, cancelled or timeout request, and etc.).
/// - Returns: Ready to use malformed service response error data object.
- (PNErrorData *)errorDataWithXMLResponse:(NSData *)data error:(nullable PNError *)error;

/// Check whether `response` contains JSON data or not.
///
/// - Parameter response: Remote origin response with results of access to the resource.
/// - Returns: `YES` if content can be read as JSON data.
- (BOOL)isJSONResponse:(id<PNTransportResponse>)response;

/// Check whether `response` contains XML data or not.
///
/// - Parameter response: Remote origin response with results of access to the resource.
/// - Returns: `YES` if content can be read as XML data.
- (BOOL)isXMLResponse:(id<PNTransportResponse>)response;

#pragma mark - 


@end

NS_ASSUME_NONNULL_END


#pragma mark - Interface implementation

@implementation PNOperationDataParseResult

#pragma mark - Initialization and Configuration

- (instancetype)initWithResult:(id)result status:(id)status {
    if ((self = [super init])) {
        _result = result;
        _status = status;
    }

    return self;
}

#pragma mark -


@end


@implementation PNOperationDataParser


#pragma mark - Properties 

#pragma mark - Initialization and Configuration

+ (instancetype)parserWithSerializer:(id<PNObjectSerializer>)serializer
                              result:(Class)resultClass
                              status:(Class)statusClass
                  withAdditionalData:(nullable NSDictionary *)additionalData {
    return [[self alloc] initWithSerializer:serializer
                                     result:resultClass
                                     status:statusClass
                         withAdditionalData:additionalData];
}

- (instancetype)initWithSerializer:(id<PNObjectSerializer>)serializer 
                            result:(Class)resultClass
                            status:(Class)statusClass
                withAdditionalData:(NSDictionary *)additionalData {
    if ((self = [super init])) {
        _additionalData = additionalData;
        _resultClass = resultClass;
        _statusClass = statusClass;
        _serializer = serializer;
    }

    return self;
}


#pragma mark - Processing

- (PNOperationDataParseResult *)parseOperation:(PNOperationType)operation
                                   withRequest:(PNTransportRequest *)request
                                      response:(nullable id<PNTransportResponse>)response
                                          data:(nullable NSData *)data
                                         error:(nullable PNError *)error {
    BOOL ignoreBody = self.errorOnly && response.statusCode < 400;
    NSDictionary *additional = self.additionalData;
    BOOL expectingResult = self.resultClass != nil;
    BOOL isJSON = [self isJSONResponse:response];
    BOOL isXML = !isJSON && [self isXMLResponse:response];
    BOOL malformedResponse = NO;
    id resultData;
    id statusData;
    id result;
    id status;

    if (error) statusData = [PNErrorData dataWithError:error];
    else if (!isJSON && !isXML && !ignoreBody) statusData = [self errorDataWithUnexpectedServiceResponseError:error];
    else if (isJSON && response.statusCode >= 400) {
        statusData = [self.serializer objectOfClass:[PNErrorData class]
                                           fromData:data
                                     withAdditional:additional
                                              error:&error];
    } else if (isJSON) {
        error = nil;

        if (expectingResult) {
            Class dataClass = [self.resultClass responseDataClass];
            resultData = [self.serializer objectOfClass:dataClass fromData:data withAdditional:additional error:&error];
        }

        if (error || (!expectingResult && !resultData)) {
            Class dataClass = [self.statusClass statusDataClass];
            statusData = [self.serializer objectOfClass:dataClass fromData:data withAdditional:additional error:&error];
            if (error) malformedResponse = YES;
        }

        // Fallback for case when only status expected but it can't be deserialized to the provided data class object.
        if (error && !expectingResult) {
            Class dataClass = [PNErrorData class];
            statusData = [self.serializer objectOfClass:dataClass fromData:data withAdditional:additional error:&error];
            if (malformedResponse) ((PNErrorData *)statusData).category = PNMalformedResponseCategory;
        }

        if (!resultData && !statusData) statusData = [self errorDataWithMalformedServiceResponseError:error];
    } else if (response.statusCode >= 400 && isXML) {
        statusData = [self errorDataWithXMLResponse:data error:error];
    } else if (!ignoreBody) statusData = [self errorDataWithMalformedServiceResponseError:error];

    if (ignoreBody && !expectingResult && !statusData) {
        statusData = [PNErrorData new];
        ((PNErrorData *)statusData).category = PNAcknowledgmentCategory;
    }

    if (resultData) result = [self.resultClass objectWithOperation:operation response:resultData];
    else if (statusData) {
        PNStatusCategory category = ((PNBaseOperationData *)statusData).category;
        status = [self.statusClass objectWithOperation:operation category:category response:statusData];
    }

    return [[PNOperationDataParseResult alloc] initWithResult:result status:status];
}


#pragma mark - Helpers

- (PNErrorData *)errorDataWithUnexpectedServiceResponseError:(nullable PNError *)error {
    NSDictionary *userInfo = PNErrorUserInfo(
        @"Unexpected response data type.",
        @"Received data with unexpected content type.",
        @"Check response status code, request parameters and service status.",
        error
    );

    return [PNErrorData dataWithError:[PNError errorWithDomain:PNAPIErrorDomain
                                                          code:PNAPIErrorMalformedServiceResponse
                                                      userInfo:userInfo]];
}

- (PNErrorData *)errorDataWithMalformedServiceResponseError:(PNError *)error {
    NSMutableArray<NSString *> *types = [NSMutableArray new];

    if ([self.resultClass responseDataClass]) [types addObject:NSStringFromClass([self.resultClass responseDataClass])];
    if ([self.statusClass statusDataClass]) [types addObject:NSStringFromClass([self.statusClass statusDataClass])];

    NSDictionary *userInfo = PNErrorUserInfo(
        @"Malformed service response.",
        PNStringFormat(@"Received content can't be deserialized as: %@", [types componentsJoinedByString:@", "]),
        @"Ensure that provided data type match to the used service.",
        error
    );

    return [PNErrorData dataWithError:[PNError errorWithDomain:PNAPIErrorDomain
                                                          code:PNAPIErrorMalformedServiceResponse
                                                      userInfo:userInfo]];
}

- (PNErrorData *)errorDataWithXMLResponse:(NSData *)data error:(nullable PNError *)error {
    PNXMLParser *parser = [PNXMLParser parserWithData:data];
    PNXML *parsedXML = [parser parse];
    NSString *errorMessage = [parsedXML valueForKeyPath:@"Error.Message"];
    NSString *failureReason = nil;

    if (errorMessage) failureReason = errorMessage;
    else failureReason = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];

    NSDictionary *userInfo = PNErrorUserInfo(
        @"Shared file storage error.",
        failureReason,
        @"Ensure that provided data type match to the used service.",
        error
    );

    return [PNErrorData dataWithError:[PNError errorWithDomain:PNStorageErrorDomain
                                                          code:PNStorageErrorAccess
                                                      userInfo:userInfo]];
}

- (BOOL)isJSONResponse:(id<PNTransportResponse>)response {
    NSString *contentType = response.headers[@"content-type"];
    static NSArray<NSString *> *_jsonContentTypes;
    static dispatch_once_t onceToken;
    BOOL isJSONResponse = NO;

    dispatch_once(&onceToken, ^{
        _jsonContentTypes = @[@"application/json", @"text/json", @"text/javascript"];
    });

    for (NSString *type in _jsonContentTypes) {
        if ((isJSONResponse = [contentType containsString:type])) break;
    }

    return isJSONResponse;
}

- (BOOL)isXMLResponse:(id<PNTransportResponse>)response {
    NSString *contentType = response.headers[@"content-type"];
    static NSArray<NSString *> *_xmlContentTypes;
    static dispatch_once_t onceToken;
    BOOL isXMLResponse = NO;

    dispatch_once(&onceToken, ^{
        _xmlContentTypes = @[@"application/xml", @"text/xml"];
    });

    for (NSString *type in _xmlContentTypes) {
        if ((isXMLResponse = [contentType containsString:type])) break;
    }

    return isXMLResponse;
}

#pragma mark -


@end
