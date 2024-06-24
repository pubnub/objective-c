#import "NSError+PNTransport.h"
#import "PNFunctions.h"
#import "PNError.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Private interface declaration

/// `NSError` private extension for transport related errors.
@interface NSError (PNTransportPrivate)


#pragma mark - Initialization and Configuration

/// Create cancelled request error.
///
/// - Parameters:
///   - request: Request object which has been cancelled before receiving a response from remote origin.
///   - error: Cancellation error.
/// - Returns: Configured and ready to use error instance.
+ (instancetype)pn_errorWithCancelledRequest:(PNTransportRequest *)request error:(nullable NSError *)error;

/// Create error from JSON response.
///
/// - Parameters:
///   - request: Request object for which remote origin returned processing error.
///   - response: Remote origin response with results of access to the resource.
/// - Returns: Configured and ready to use error instance.
+ (instancetype)pn_errorWithRequest:(PNTransportRequest *)request jsonResponse:(id<PNTransportResponse>)response;

/// Create receiver's copy with additional fields in `userInfo`.
///
/// Attach information to the error created by the transport implementation about the `request` which has been processed
/// and `response`.
///
/// - Parameters:
///   - request: Request object for which remote origin returned processing error.
///   - response: Remote origin response with results of access to the resource.
/// - Returns: Configured and ready to use error instance.
- (instancetype)pn_errorWithRequest:(PNTransportRequest *)request response:(nullable id<PNTransportResponse>)response;


#pragma mark - Misc

/// Identify error code from request processing status code.
///
/// - Parameter statusCode: Status code returned by remote origin in response to remote resource access request.
/// - Returns: Known error code which correspond to the `statusCode`.
+ (NSInteger)pn_errorCodeFromStatusCode:(NSUInteger)statusCode;

/// Human-readable meaning of the error code.
///
/// - Parameter error: Identified error code.
/// - Returns: Human-readable error code description.
+ (NSString *)pn_errorDescriptionForErrorCode:(NSUInteger)error;

/// Human-readable reason of the error.
///
/// - Parameter error: Identified error code.
/// - Returns: Human-readable error reason by error code.
+ (nullable NSString *)pn_errorReasonForErrorCode:(NSUInteger)error;

/// Human-readable error recovery suggestion.
///
/// - Parameter error: Identified error code.
/// - Returns: Human-readable error recovery suggestion.
+ (nullable NSString *)pn_errorRecoveryForErrorCode:(NSUInteger)error;

/// Compose full request url.
///
/// - Parameter request: Request from which full URL should be retrieved.
/// - Returns: URL which has been composed from information available in `request`.
+ (NSString *)pn_fullURLFromRequest:(PNTransportRequest *)request;

/// Check whether `response` contains JSON data or not.
///
/// - Parameter response: Remote origin response with results of access to the resource.
/// - Returns: `YES` if content can be read as JSON data.
+ (BOOL)pn_isJSONResponse:(id<PNTransportResponse>)response;

#pragma mark -


@end

NS_ASSUME_NONNULL_END


#pragma mark - Interface implementation

@implementation NSError (PNTransport)


#pragma mark - Initialization and Configuration

+ (instancetype)pn_errorWithTransportRequest:(PNTransportRequest *)request 
                                    response:(id<PNTransportResponse>)response
                                       error:(NSError *)error {
    if (request.cancelled || error.code == NSURLErrorCancelled) {
        return [self pn_errorWithCancelledRequest:request error:error];
    } else if (error) return error;
    
    if ([self pn_isJSONResponse:response]) return [self pn_errorWithRequest:request jsonResponse:response];
    return nil;
}

+ (instancetype)pn_errorWithCancelledRequest:(PNTransportRequest *)request error:(NSError *)error {
    NSInteger errorCode = PNTransportErrorRequestCancelled;
    NSDictionary *userInfo = error.userInfo;
    
    if (!error) {
        NSMutableDictionary *info = [PNErrorUserInfo([self pn_errorDescriptionForErrorCode:errorCode],
                                                     [self pn_errorReasonForErrorCode:errorCode],
                                                     [self pn_errorRecoveryForErrorCode:errorCode],
                                                     error)
                                     mutableCopy];
        info[NSURLErrorFailingURLErrorKey] = [NSURL URLWithString:[self pn_fullURLFromRequest:request]];
        userInfo = info;
    }
    
    return [self errorWithDomain:PNTransportErrorDomain code:errorCode userInfo:userInfo];
}

+ (instancetype)pn_errorWithRequest:(PNTransportRequest *)request jsonResponse:(id<PNTransportResponse>)response {
    NSInteger errorCode = [self pn_errorCodeFromStatusCode:response.statusCode];
    NSURL *url = [NSURL URLWithString:[self pn_fullURLFromRequest:request]];
    NSData *body = response.body;
    
    if (body.length == 0) {
        NSMutableDictionary *info = [NSMutableDictionary dictionaryWithDictionary:PNErrorUserInfo(
            [self pn_errorDescriptionForErrorCode:errorCode],
            [self pn_errorReasonForErrorCode:errorCode],
            [self pn_errorRecoveryForErrorCode:errorCode],
            nil
        )];
        info[NSURLErrorFailingURLErrorKey] = url;
        
        return [NSError errorWithDomain:PNAPIErrorDomain code:errorCode userInfo:info];
    }
    
    NSError *jsonError = nil;
    id payload = [NSJSONSerialization JSONObjectWithData:body options:(NSJSONReadingOptions)0 error:&jsonError];
    NSDictionary *additionalDetails = nil;
    NSString *errorMessage = nil;
    NSString *errorReason = nil;
    
    if([payload isKindOfClass:[NSArray class]]) {
        NSArray *array = payload;
        if (array.count == 3) {
            if ([array[0] isKindOfClass:[NSString class]]) errorMessage = array[0];
            else if ([array[0] isKindOfClass:[NSNumber class]] && [array[1] isKindOfClass:[NSString class]]) {
                if ([array[0] isEqual:@0]) errorMessage = array[1];
            }
        }
    } else if([payload isKindOfClass:[NSDictionary class]]) {
        NSDictionary *dictionary = payload;
        id description = dictionary[@"error"];
        
        if ([description isKindOfClass:[NSString class]]) errorMessage = description;
        else if (!description || ([description isKindOfClass:[NSNumber class]] && ((NSNumber *)description).boolValue &&
                                  dictionary[@"error_message"])) {
            description = dictionary[@"error_message"];
        }
        
        if ([description isKindOfClass:[NSDictionary class]] && description[@"message"]) {
            NSMutableArray<NSDictionary *> *errorDetails = description[@"details"];
            errorReason = description[@"message"];
            
            if (errorDetails.count) {
                NSMutableArray<NSString *> *detailStrings = [NSMutableArray new];
                
                for (NSDictionary *details in errorDetails) {
                    NSString *detailString = @"";
                    
                    if (details[@"message"]) detailString = [@"- " stringByAppendingString:details[@"message"]];
                    if (details[@"location"]) {
                        detailString = [detailString stringByAppendingFormat:@"%@ Location: %@",
                                        detailString.length ? @"" : @"-", details[@"location"]];
                    }
                    
                    [detailStrings addObject:detailString];
                }
                
                if (detailStrings.count) {
                    errorReason = [errorReason stringByAppendingFormat:@" Details:\n%@",
                                   [detailStrings componentsJoinedByString:@"\n"]];
                }
            }
        }
        
        if (errorReason || dictionary[@"message"]) errorMessage = dictionary[@"message"] ?: errorReason;
        if ([dictionary[@"status"] isKindOfClass:[NSNumber class]]) {
            errorCode = [self pn_errorCodeFromStatusCode:((NSNumber *)dictionary[@"status"]).integerValue];
        }
        
        if (dictionary[@"payload"]) {
            NSMutableDictionary *details = [NSMutableDictionary dictionaryWithDictionary:@{
                @"channels": [dictionary valueForKeyPath:@"payload.channels"] ?: @[],
                @"channelGroups": [dictionary valueForKeyPath:@"payload.channel-groups"] ?: @[],
            }];

            if (((NSArray *)details[@"channels"]).count == 0 && ((NSArray *)details[@"channelGroups"]).count == 0) {
                [details removeAllObjects];
                details[@"data"] = dictionary[@"payload"];
            }
            
            additionalDetails = details;
        }
    }
    
    if ([errorMessage containsString:@"not enabled"]) errorCode = PNAPIErrorFeatureNotEnabled;
    if (!payload && body.length) payload = [[NSString alloc] initWithData:body encoding:NSUTF8StringEncoding];
    
    NSMutableDictionary *info = [NSMutableDictionary dictionaryWithDictionary:PNErrorUserInfo(
        [self pn_errorDescriptionForErrorCode:errorCode],
        errorMessage ?: [self pn_errorReasonForErrorCode:errorCode],
        [self pn_errorRecoveryForErrorCode:errorCode],
        nil
    )];

    info[NSURLErrorFailingURLErrorKey] = url;
    info[PNTransportResponseKey] = response;
    info[PNTransportRequestKey] = request;
    
    return [self errorWithDomain:PNAPIErrorDomain code:errorCode userInfo:info];
}

- (instancetype)pn_errorWithRequest:(PNTransportRequest *)request response:(id<PNTransportResponse>)response {
    NSMutableDictionary *userInfo = [(self.userInfo ?: @{}) mutableCopy];
    userInfo[PNTransportResponseKey] = response;
    userInfo[PNTransportRequestKey] = request;

    return [[[self class] alloc] initWithDomain:self.domain code:self.code userInfo:userInfo];
}


#pragma mark - Misc

+ (NSInteger)pn_errorCodeFromStatusCode:(NSInteger)statusCode {
    NSInteger errorCode = PNErrorUnknown;
    
    if (statusCode == 403) errorCode = PNAPIErrorAccessDenied;
    else if (statusCode == 411) errorCode = PNAPIErrorBadRequest;
    else if (statusCode == 414) errorCode = PNAPIErrorRequestURITooLong;
    else if (statusCode == 481) errorCode = PNAPIErrorMalformedFilterExpression;
    
    return errorCode;
}

+ (NSString *)pn_errorDescriptionForErrorCode:(NSUInteger)error {
    if (error != PNErrorUnknown) return @"Request processing error.";
    return @"Unkown request processing error.";
}

+ (NSString *)pn_errorReasonForErrorCode:(NSUInteger)error {
    if (error == PNAPIErrorFeatureNotEnabled) return @"Used feature not enabled for keys set.";
    else if (error == PNTransportErrorRequestCancelled) return @"Request explicitly has been cancelled.";
    else if (error == PNAPIErrorAccessDenied) return @"Insufficient permissions to access remote resource.";
    else if (error == PNAPIErrorAccessDenied) return @"Insufficient permissions to access remote resource.";
    else if (error == PNAPIErrorBadRequest) return @"Incomplete or malformed request path.";
    else if (error == PNAPIErrorRequestURITooLong) return @"Request URI is too long.";
    else if (error == PNAPIErrorMalformedFilterExpression) {
        return @"Malformed or invalid filter experssion used with subscribe request.";
    }
    
    return nil;
}

+ (nullable NSString *)pn_errorRecoveryForErrorCode:(NSUInteger)error {
    if (error == PNAPIErrorFeatureNotEnabled) {
        return @"Enable feature in PubNub dashboard for keys set used to configurate PubNub client instance.";
    } else if (error == PNAPIErrorAccessDenied) {
        return @"Check request parameters to include 'auth' with key which has required permissions.";
    } else if (error == PNAPIErrorRequestURITooLong) {
        return @"Use POST body if possible or reduce number of channels and groups used in subscribe request.";
    } else if (error == PNAPIErrorMalformedFilterExpression) {
        return @"Check syntax which has been used in filter expression during PubNub client configuration.";
    }
    
    return nil;
}

+ (NSString *)pn_fullURLFromRequest:(PNTransportRequest *)request {
    NSMutableArray *query = [NSMutableArray arrayWithCapacity:request.query.count];
    [request.query enumerateKeysAndObjectsUsingBlock:^(NSString *key, id value, BOOL *stop) {
        [query addObject:PNStringFormat(@"%@=%@", key, value)];
    }];
    
    NSString *queryString = query.count > 0 ? PNStringFormat(@"?%@", [query componentsJoinedByString:@"&"]) : @"";
    NSString *schema = PNStringFormat(@"http%@://", request.secure ? @"s" : @"");
    
    return PNStringFormat(@"%@%@%@%@", schema, request.origin, request.path, queryString);
}

+ (BOOL)pn_isJSONResponse:(id<PNTransportResponse>)response {
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

#pragma mark -


@end
