/**
 @author Sergey Mamontov
 @since 4.0
 @copyright © 2009-2017 PubNub, Inc.
 */
#import "PNStatus+Private.h"
#import "PNNetworkResponseSerializer.h"
#import "PNPrivateStructures.h"
#import "PNStatus+Private.h"
#import "PNResult+Private.h"
#import "PNDictionary.h"


#pragma mark Private interface

@interface PNStatus ()


#pragma mark - Initialization and configuration

/**
 @brief  Initializr minimal object to describe state using operation type and status category information.
 
 @param operation Type of operation for which this status report.
 @param category  Operation processing status category.
 @param error     Reference on processing error.
 
 @return Initialized and ready to use status object.
 
 @since 4.0
 */
- (instancetype)initForOperation:(PNOperationType)operation category:(PNStatusCategory)category
             withProcessingError:(NSError *)error;

/**
 @brief  Initialize result instance in response to successful task completion.
 
 @param operation     One of \b PNOperationType enum fields to describe what kind of operation has been 
                      processed.
 @param task          Reference on data task which has been used to communicate with \b PubNub network.
 @param processedData Reference on data which has been loaded and pre-processed by corresponding parser.
 @param error         Reference on processing error.
 
 @return Initialized and ready to use result instance.
 
 @since 4.0
 */
- (instancetype)initForOperation:(PNOperationType)operation completedWithTask:(NSURLSessionDataTask *)task
                   processedData:(NSDictionary<NSString *, id> *)processedData 
                 processingError:(NSError *)error;


#pragma mark - Interpretation

/**
 @brief Try interpret response status code meaningful status object state.

 @param statusCode HTTP response status code which should be used during interpretation.

 @since 4.0
 */
- (PNStatusCategory)categoryTypeFromStatusCode:(NSInteger)statusCode;

/**
 @brief Try interpret error object to meaningful status object state.

 @param error Reference on error which should be used during interpretation.

 @since 4.0
 */
- (PNStatusCategory)categoryTypeFromError:(NSError *)error;

/**
 @brief Try extract useful data from error object (in case if service provided some feedback).

 @param error Reference on error from which data should be pulled out.

 @since 4.0
 */
- (NSDictionary<NSString *, id> *)dataFromError:(NSError *)error;

#pragma mark -


@end


#pragma mark - Interface implementation

@implementation PNStatus


#pragma mark - Information

- (NSString *)stringifiedCategory {
    
    return PNStatusCategoryStrings[self.category];
}

- (void)updateCategory:(PNStatusCategory)category; {

    self.category = category;
}

- (void)setCategory:(PNStatusCategory)category {
    
    _category = category;
    if (_category == PNDecryptionErrorCategory) { self.error = YES; }
    else if (_category == PNConnectedCategory || _category == PNReconnectedCategory ||
             _category == PNDisconnectedCategory || _category == PNUnexpectedDisconnectCategory) {
        
        self.error = NO;
    }
}


#pragma mark - Initialization and configuration

+ (instancetype)statusForOperation:(PNOperationType)operation category:(PNStatusCategory)category
               withProcessingError:(NSError *)error {
    
    return [[self alloc] initForOperation:operation category:category withProcessingError:error];
}

- (instancetype)initForOperation:(PNOperationType)operation category:(PNStatusCategory)category
             withProcessingError:(NSError *)error {
    
    // Check whether initialization was successful or not.
    if ((self = [super initForOperation:operation completedWithTask:nil processedData:nil
                        processingError:error])) {
        
        _category = category;
        if (_category == PNConnectedCategory || _category == PNReconnectedCategory ||
            _category == PNDisconnectedCategory || _category == PNUnexpectedDisconnectCategory ||
            _category == PNCancelledCategory || _category == PNAcknowledgmentCategory) {
            
            _error = NO;
            self.statusCode = 200;
        }
        else if (_category != PNUnknownCategory) {
            
            _error = YES;
            self.statusCode = (_category == PNAccessDeniedCategory ? 403 : 400);
        }
    }
    
    return self;
}

- (instancetype)initForOperation:(PNOperationType)operation completedWithTask:(NSURLSessionDataTask *)task
                   processedData:(NSDictionary<NSString *, id> *)processedData 
                 processingError:(NSError *)error {
    
    // Check whether initialization was successful or not.
    if ((self = [super initForOperation:operation completedWithTask:task processedData:processedData
                        processingError:error])) {
        
        _error = (error != nil || self.statusCode != 200);
        if (_error && ![self.serviceData count]) {
            
            [self updateData:[self dataFromError:error]];
        }
        
        // Check whether status should represent acknowledgment or not.
        if (self.statusCode == 200 && !_error) {
            
            _category = PNAcknowledgmentCategory;
        }
        else if (_category == PNUnknownCategory) {
            
            // Try extract category basing on response status codes.
            _category = [self categoryTypeFromStatusCode:self.statusCode];
            
            // Extract status category from passed error object.
            _category = (_category == PNUnknownCategory ? [self categoryTypeFromError:error] : _category);
            _category = (_category == PNUnknownCategory && self.statusCode == 400 ?
                         PNBadRequestCategory : _category);
        }
        
        if (_category == PNCancelledCategory) {
            
            _error = NO;
        }
    }
    
    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    
    PNStatus *status = [super copyWithZone:zone];
    status.category = self.category;
    status.subscribedChannels = self.subscribedChannels;
    status.subscribedChannelGroups = self.subscribedChannelGroups;
    status.error = self.isError;
    status.currentTimetoken = self.currentTimetoken;
    status.lastTimeToken = self.lastTimeToken;
    status.currentTimeTokenRegion = self.currentTimeTokenRegion;
    status.lastTimeTokenRegion = self.lastTimeTokenRegion;
    status.automaticallyRetry = self.willAutomaticallyRetry;
    status.retryBlock = self.retryBlock;
    status.retryCancelBlock = self.retryCancelBlock;
    
    return status;
}


#pragma mark - Recovery

- (void)retry {

    if (self.retryBlock) { self.retryBlock(); }
}

- (void)cancelAutomaticRetry {

    if (self.retryCancelBlock) { self.retryCancelBlock(); }
}


#pragma mark - Interpretation

- (PNStatusCategory)categoryTypeFromStatusCode:(NSInteger)statusCode {
    
    PNStatusCategory category = PNUnknownCategory;
    if (statusCode == 403) { category = PNAccessDeniedCategory; }
    else if (statusCode == 481) { category = PNMalformedFilterExpressionCategory; }
    
    return category;
}

- (PNStatusCategory)categoryTypeFromError:(NSError *)error {

    PNStatusCategory category = PNUnknownCategory;
    if ([error.domain isEqualToString:NSURLErrorDomain]) {
        
        switch (error.code) {
            case NSURLErrorTimedOut:
                
                category = PNTimeoutCategory;
                break;
            case NSURLErrorCannotFindHost:
            case NSURLErrorCannotConnectToHost:
            case NSURLErrorNetworkConnectionLost:
            case NSURLErrorDNSLookupFailed:
            case NSURLErrorNotConnectedToInternet:

                category = PNNetworkIssuesCategory;
                break;
            case NSURLErrorCannotDecodeContentData:
            case NSURLErrorBadServerResponse:

                category = PNMalformedResponseCategory;
                break;
            case NSURLErrorBadURL:

                category = PNBadRequestCategory;
                break;
            case NSURLErrorCancelled:

                category = PNCancelledCategory;
                break;
            case NSURLErrorSecureConnectionFailed:

                category = PNTLSConnectionFailedCategory;
                break;
            case NSURLErrorServerCertificateUntrusted:
                
                category = PNTLSUntrustedCertificateCategory;
                break;
            default:
                break;
        }
    }
    else if ([error.domain isEqualToString:NSCocoaErrorDomain]) {
        
        switch (error.code) {
            case NSPropertyListReadCorruptError:
                
                category = PNMalformedResponseCategory;
                break;
                
            default:
                break;
        }
    }
    
    return category;
}

- (NSDictionary<NSString *, id> *)dataFromError:(NSError *)error {
    
    // Try to fetch server response if available.
    id errorDetails = nil;
    if (error.userInfo[kPNNetworkErrorResponseDataKey]) {
        
        // In most cases service provide JSON error response. Try de-serialize it.
        NSError *deSerializationError;
        NSData *errorData = error.userInfo[kPNNetworkErrorResponseDataKey];
        errorDetails = [NSJSONSerialization JSONObjectWithData:errorData
                                                       options:(NSJSONReadingOptions)0
                                                         error:&deSerializationError];
        
        // Check whether JSON de-serialization failed and try to pull regular string from response.
        if (!errorDetails) {
            
            errorDetails = [[NSString alloc] initWithData:errorData encoding:NSUTF8StringEncoding];
        }
        if (deSerializationError) { error = deSerializationError; }
    }
    
    if (!errorDetails) {
        
        NSString *information = error.userInfo[NSLocalizedDescriptionKey];
        if (!information) { information = error.userInfo[@"NSDebugDescription"]; }
        if (information) { errorDetails = @{@"information": information}; }
    }
    // Check whether error details represented with expected format or not.
    else if (![errorDetails isKindOfClass:[NSDictionary class]]) {
        
        errorDetails = @{@"information": errorDetails};
    }
    
    return errorDetails;
}


#pragma mark - Misc

- (NSDictionary *)dictionaryRepresentation {
    
    NSMutableDictionary *status = [[super dictionaryRepresentation] mutableCopy];
    [status addEntriesFromDictionary:@{@"Category": PNStatusCategoryStrings[self.category],
                                       @"Error": (self.isError ? @"YES" : @"NO")}];
    if ([self.subscribedChannels count] || [self.subscribedChannelGroups count]) {
        
        status[@"Time"] = @{@"Current": (self.currentTimetoken?: @(0)),
                            @"Previous": (self.lastTimeToken?: @(0))};
        status[@"Region"] = @{@"Current": (self.currentTimeTokenRegion?: @"<empty>"),
                            @"Previous": (self.lastTimeTokenRegion?: @"<empty>")};
        status[@"Objects"] = [NSMutableDictionary new];
        if ([self.subscribedChannels count]) {
            
            status[@"Objects"][@"Channels"] = self.subscribedChannels;
        }
        if ([self.subscribedChannelGroups count]) {
            
            status[@"Objects"][@"Channel groups"] = self.subscribedChannelGroups;
        }
    }
    
    return [status copy];
}

#pragma mark -


@end
