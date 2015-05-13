/**
 @author Sergey Mamontov
 @since 4.0
 @copyright © 2009-2015 PubNub, Inc.
 */
#import "PNStatus+Private.h"
#import <AFURLResponseSerialization.h>
#import "PNPrivateStructures.h"
#import "PNResult+Private.h"


#pragma mark Private interface

@interface PNStatus ()


#pragma mark - Interpretation

/**
 @brief Try interpret error object to meaningful status object state.

 @param error Reference on error which should be used during interpretation.

 @since 4.0
 */
- (PNStatusCategory)categoryTypeFromError:(NSError *)error;

/**
 @brief Try interpret response status code meaningful status object state.

 @param statusCode HTTP response status code which should be used during interpretation.

 @since 4.0
 */
- (PNStatusCategory)categoryTypeFromStatusCode:(NSInteger)statusCode;

/**
 @brief Correlate previously stored category information with operation type.

 @param type One of \b PNOperationType fields which should be translated to category.

 @since 4.0
 */
- (PNStatusCategory)correlateCategoryToOperationType:(PNOperationType)type;

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

+ (instancetype)statusFromResult:(PNResult *)result {

    PNStatus *status = [[self alloc] initForRequest:result.requestObject withResponse:nil error:nil
                                            andData:result.data];
    
    return status;
}

+ (instancetype)statusForRequest:(PNRequest *)request withResponse:(NSHTTPURLResponse *)response
                           error:(NSError *)error andData:(id <NSObject, NSCopying>)data {
    
    return [[self alloc] initForRequest:request withResponse:response error:error andData:data];
}

- (instancetype)initForRequest:(PNRequest *)request withResponse:(NSHTTPURLResponse *)response
                         error:(NSError *)error andData:(id <NSObject, NSCopying>)data {
    
    // Check whether initialization has been successful or not.
    if ((self = [super initForRequest:request withResponse:response andData:data])) {

        self.category = [self categoryTypeFromStatusCode:response.statusCode];
        if (self.category == PNUnknownCategory) {
            
            self.category = [self categoryTypeFromError:error];
        }
        self.category = [self correlateCategoryToOperationType:request.operation];
        self.error = ((response && response.statusCode != 200) ||
                      self.category == PNUnexpectedDisconnectCategory);

        self.data = (([self.data count] ? self.data : [self dataFromError:error])?: data);
        
    }
    
    
    return self;
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

                category = PNCancelledCategory;
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
            case 403:
                
                category = PNAccessDeniedCategory;
                break;
                
            default:
                break;
        }
    }
    
    return category;
}

- (PNStatusCategory)categoryTypeFromStatusCode:(NSInteger)statusCode {
    
    PNStatusCategory category = PNUnknownCategory;
    if (statusCode == 403) {
        
        category = PNAccessDeniedCategory;
    }
    
    return category;
}

- (PNStatusCategory)correlateCategoryToOperationType:(PNOperationType)type {

    PNStatusCategory category = PNUnknownCategory;
    if ((type == PNSubscribeOperation || type == PNUnsubscribeOperation)) {

        if (self.category == PNUnknownCategory) {

            category = (type == PNSubscribeOperation ? PNConnectedCategory:PNDisconnectedCategory);
        }
        else if (type != PNUnsubscribeOperation){

            if (self.category != PNCancelledCategory && self.category != PNConnectedCategory &&
                self.category != PNDisconnectedCategory && self.category != PNUnexpectedDisconnectCategory) {

                category = PNUnexpectedDisconnectCategory;
            }
        }
    }

    return (category == PNUnknownCategory ? self.category : category);
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
                                       @"Secure": (self.isSSLEnabled ? @"YES" : @"NO"),
                                       @"Objects": @{@"Channels": (self.channels?: @"no channels"),
                                                     @"Channel groups": (self.groups?: @"no groups")},
                                       @"UUID": (self.uuid?: @"uknonwn"),
                                       @"Authorization": (self.authorizationKey?: @"not set"),
                                       @"Time": @{@"Current": self.currentTimetoken,
                                                  @"Previous": self.previousTimetoken}}];
    
    return [status copy];
}

@end
