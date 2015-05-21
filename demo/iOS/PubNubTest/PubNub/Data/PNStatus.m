/**
 @author Sergey Mamontov
 @since 4.0
 @copyright © 2009-2015 PubNub, Inc.
 */
#import "PNStatus+Private.h"
#import <AFURLResponseSerialization.h>
#import "PNPrivateStructures.h"
#import "PNStatus+Private.h"
#import "PNResult+Private.h"
#import "PNResponse.h"
#import "PNLog.h"


#pragma mark Private interface

@interface PNStatus ()


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
- (NSDictionary *)dataFromError:(NSError *)error;

#pragma mark -


@end


#pragma mark - Interface implementation

@implementation PNStatus

+ (instancetype)statusForOperation:(PNOperationType)operation category:(PNStatusCategory)category {
    
    PNStatus *status = [PNStatus new];
    status.operation = operation;
    status.category = category;
    status->_subCategory = category;
    if (status.category == PNConnectedCategory || status.category == PNDisconnectedCategory ||
        status.category == PNUnexpectedDisconnectCategory || status.category == PNCancelledCategory ||
        status.category == PNAcknowledgmentCategory) {
        
        status.error = NO;
        status.statusCode = 200;
    }
    else {
        
        status.statusCode = (status.category == PNAccessDeniedCategory ? 403 : 400);
    }
    
    return status;
}

+ (instancetype)statusFromResult:(PNResult *)result {

    return [[self alloc] initForRequest:result.requestObject
                              withError:result.requestObject.response.error];
}

+ (instancetype)statusForRequest:(PNRequest *)request withError:(NSError *)error {
    
    return [[self alloc] initForRequest:request withError:error];
}

- (instancetype)initForRequest:(PNRequest *)request withError:(NSError *)error {
    
    // Check whether initialization has been successful or not.
    if ((self = [super initForRequest:request])) {
        
        NSError *processingError = (error?: request.response.error);
        
        // Check whether status should represent acknowledgment or not.
        if (self.statusCode == 200 && !processingError) {
            
            self.category = PNAcknowledgmentCategory;
        }
        else if (self.category == PNUnknownCategory) {
            
            // Try extract category basing on response status codes.
            self.category = [self categoryTypeFromStatusCode:self.statusCode];

            // Extract status category from passed error object.
            if (self.category == PNUnknownCategory) {
                
                self.category = [self categoryTypeFromError:processingError];
            }
        }
        _subCategory = self.category;
        self.error = (self.category != PNAcknowledgmentCategory);
        if (self.isError && ![self.data count]) {
            
            self.data = ([self dataParsedAsError:request.response.data]?: [self dataFromError:error]);
        }
        self.data = (([self.data count] ? self.data : [self dataFromError:error]) ?: request.response.data);
    }
    
    return self;
}

- (void)setCategory:(PNStatusCategory)category {
    
    _category = category;
    if (_category == PNDecryptionErrorCategory) {
        
        self.error = YES;
    }
    else if (_category == PNDisconnectedCategory || _category == PNUnexpectedDisconnectCategory ||
             _category == PNReconnectedCategory) {
        
        self.error = NO;
    }
}

- (void)revertToOriginalCategory {
    
    if (self.subCategory != PNUnknownCategory) {
        
        self.category = self.subCategory;
    }
}

- (id)copyWithZone:(NSZone *)zone {
    
    PNStatus *status = [[[self class] allocWithZone:zone] init];
    status.clientRequest = self.clientRequest;
    status.headers = self.headers;
    status.response = self.response;
    status.statusCode = self.statusCode;
    status.operation = self.operation;
    status.origin = self.origin;
    status.data = self.data;
    status.category = self.category;
    status->_subCategory = self.subCategory;
    status.TLSEnabled = self.isTLSEnabled;
    status.channels = self.channels;
    status.channelGroups = self.channelGroups;
    status.uuid = self.uuid;
    status.authKey = self.authKey;
    status.state = self.state;
    status.error = self.isError;
    status.currentTimetoken = self.currentTimetoken;
    status.previousTimetoken = self.previousTimetoken;
    status.automaticallyRetry = self.willAutomaticallyRetry;
    status.retryBlock = self.retryBlock;
    status.retryCancelBlock = self.retryCancelBlock;
    
    return status;
}


#pragma mark - Recovery

- (void)retry {

    if (self.retryBlock) {

        self.retryBlock();
    }
}

- (void)cancelAutomaticRetry {

    if (self.retryCancelBlock) {

        self.retryCancelBlock();
    }
}


#pragma mark - Interpretation

- (PNStatusCategory)categoryTypeFromStatusCode:(NSInteger)statusCode {
    
    PNStatusCategory category = PNUnknownCategory;
    if (statusCode == 403) {
        
        category = PNAccessDeniedCategory;
    }
    
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
    else if ([error.domain isEqualToString:AFURLResponseSerializationErrorDomain]) {
        
        switch (error.code) {
            case NSURLErrorBadServerResponse:
                
                category = PNMalformedResponseCategory;
                break;
                
            default:
                break;
        }
    }
    
    return category;
}

- (NSDictionary *)dataFromError:(NSError *)error {
    
    NSDictionary *data = nil;
    NSString *information = error.userInfo[NSLocalizedDescriptionKey];
    if (!information) {
        
        information = error.userInfo[@"NSDebugDescription"];
    }
    
    if (information) {
        
        data = @{@"information":information};
    }
    
    return data;
}


#pragma mark - Misc

- (NSDictionary *)dictionaryRepresentation {
    
    NSMutableDictionary *status = [[super dictionaryRepresentation] mutableCopy];
    [status addEntriesFromDictionary:@{@"Category": PNStatusCategoryStrings[self.category],
                                       @"Secure": (self.isTLSEnabled ? @"YES" : @"NO"),
                                       @"UUID": (self.uuid?: @"uknonwn"),
                                       @"Authorization": (self.authKey?: @"not set"),
                                       @"Time": @{@"Current": (self.currentTimetoken?: @(0)),
                                                  @"Previous": (self.previousTimetoken?: @(0))},
                                       @"Error": (self.isError ? @"YES" : @"NO")}];
    if ([self.channels count] || [self.channelGroups count]) {
        
        status[@"Objects"] = [NSMutableDictionary new];
        if ([self.channels count]) {
            
            status[@"Objects"][@"Channels"] = self.channels;
        }
        if ([self.channelGroups count]) {
            
            status[@"Objects"][@"Channel groups"] = self.channelGroups;
        }
    }
    
    return [status copy];
}

@end
