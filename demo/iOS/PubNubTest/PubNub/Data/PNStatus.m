/**
 @author Sergey Mamontov
 @since 4.0
 @copyright © 2009-2015 PubNub, Inc.
 */
#import "PNStatus+Private.h"
#import <AFURLResponseSerialization.h>
#import "PNPrivateStructures.h"
#import "PNResult+Private.h"
#import "PNStructures.h"


#pragma mark Private interface

@interface PNStatus ()

- (PNStatusCategory)categoryTypeFromError:(NSError *)error;
- (PNStatusCategory)categoryTypeFromStatusCode:(NSInteger)statusCode;
- (NSDictionary *)dataFromError:(NSError *)error;

#pragma mark -


@end


#pragma mark - Interface implementation

@implementation PNStatus

+ (instancetype)statusForRequest:(PNRequest *)request withResponse:(NSHTTPURLResponse *)response
                           error:(NSError *)error andData:(id <NSObject, NSCopying>)data {
    
    return [[self alloc] initForRequest:request withResponse:response error:error andData:data];
}

- (instancetype)initForRequest:(PNRequest *)request withResponse:(NSHTTPURLResponse *)response
                         error:(NSError *)error andData:(id <NSObject, NSCopying>)data {
    
    // Check whether initialization has been successful or not.
    if ((self = [super initForRequest:request withResponse:response andData:data])) {
        
        // NSURLErrorDomain
        //// NSURLErrorTimedOut
        //// NSURLErrorCannotFindHost
        //// NSURLErrorCannotConnectToHost
        //// NSURLErrorNetworkConnectionLost
        //// NSURLErrorDNSLookupFailed
        //// NSURLErrorNotConnectedToInternet
        //// NSURLErrorBadServerResponse
        //// NSURLErrorSecureConnectionFailed
        //// NSURLErrorServerCertificateUntrusted
        //// NSURLErrorClientCertificateRequired
        
        // NSURLErrorDomain
        //// NSURLErrorBadURL
        self.error = (response.statusCode != 200);
        self.category = [self categoryTypeFromStatusCode:response.statusCode];
        if (self.category == PNUnknownCategory) {
            
            self.category = [self categoryTypeFromError:error];
        }
        self.data = (self.data ?: [self dataFromError:error]);
    }
    
    
    return self;
}

- (void)retry {


}

- (PNStatusCategory)categoryTypeFromError:(NSError *)error {
    
    PNStatusCategory category = PNUnknownCategory;
    if ([error.domain isEqualToString:NSURLErrorDomain]) {
        
        switch (error.code) {
            case NSURLErrorTimedOut:
                
                category = PNTimeoutCategory;
                break;
            case NSURLErrorCannotDecodeContentData:
                
                category = PNMalformedResponseCategory;
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

- (NSString *)debugDescription {
    
    NSString *request = [self.request.URL absoluteString];
    return [NSString stringWithFormat:@"\n<Result\n\tOperation: %@\n\tRequest: %@ %@%@"
                                       "\n\tResponse: %@\n\tStatus code: %@\n\tOrigin: %@"
                                       "\n\tCategory: %@\n\tSecure: %@\n\tChannels: %@"
                                       "\n\tGroups: %@\n\tUUID: %@\n\tCurrent token: %@"
                                       "\n\tPrevious token: %@\n\tAuthorization key: %@"
                                       "\n\tData: %@\n>",
            PNOperationTypeStrings[[self operation]], self.request.HTTPMethod,
            [request stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding],
            ([self.request.HTTPBody length] ? [NSString stringWithFormat:@" (%@)",
                                               @([self.request.HTTPBody length])] : @""),
            self.response, @(self.statusCode), self.origin,
            PNStatusCategoryStrings[self.category], (self.isSSLEnabled ? @"YES" : @"NO"),
            [self.channels componentsJoinedByString:@", "],
            [self.groups componentsJoinedByString:@", "], self.uuid, self.currentTimetoken,
            self.previousTimetoken,self.authorizationKey,
            [[self.data description] stringByReplacingOccurrencesOfString:@"\n"
                                                               withString:@"\n\t"]];
}

@end
