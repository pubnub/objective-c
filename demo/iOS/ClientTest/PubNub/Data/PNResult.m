/**
 @author Sergey Mamontov
 @since 4.0
 @copyright © 2009-2015 PubNub, Inc.
 */
#import "PNResult+Private.h"
#import "PNRequest+Private.h"
#import "PNPrivateStructures.h"
#import "PNJSON.h"


#pragma mark Interface implementation

@implementation PNResult


#pragma mark - Initialization and configuration

+ (instancetype)resultForRequest:(PNRequest *)request withResponse:(NSHTTPURLResponse *)response
                         andData:(id)data {
    
    return [[self alloc] initForRequest:request withResponse:response andData:data];
}

- (instancetype)initForRequest:(PNRequest *)request withResponse:(NSHTTPURLResponse *)response
                       andData:(id)data {
    
    // Check whether initialization has been successful or not
    if ((self = [super init])) {

        self.requestObject = request;

        _request = [request.request copy];
        _headers = [[response allHeaderFields] copy];
        _response = [data copy];
        _statusCode = (response ? response.statusCode : 200);
        _origin = [[_request URL] host];

        // Call parse block which has been passed by calling API to pre-process
        // received data before returning it to te user.
        if (data) {
            
            if (self.requestObject.parseBlock) {
                
                _data = [(self.requestObject.parseBlock(data)?:[self dataParsedAsError:data]) copy];
            }
            else {
                
                _data = [[self dataParsedAsError:data] copy];
            }
        }
    }
    
    return self;
}

- (instancetype)copyWithData:(id)data {
    
    PNResult *result = [[self class] resultForRequest:self.requestObject withResponse:nil
                                              andData:nil];
    result->_headers = [self.headers copy];
    result->_response = [self.response copy];
    result->_statusCode = self.statusCode;
    result->_origin = [self.origin copy];
    result->_data = [data copy];
    
    return result;
}

- (PNOperationType)operation {
    
    return self.requestObject.operation;
}


#pragma mark - Processing

- (NSDictionary *)dataParsedAsError:(id <NSObject, NSCopying>)data {
    
    NSMutableDictionary *errorData = nil;
    if ([data isKindOfClass:[NSDictionary class]]) {
        
        errorData = [NSMutableDictionary new];
        if (data[@"message"]) {
            
            errorData[@"information"] = data[@"message"];
        }
        else if (data[@"error"]) {
            
            errorData[@"message"] = data[@"error"];
        }
        if (data[@"payload"]) {
            
            if (data[@"payload"][@"channels"]) {
                
                errorData[@"channels"] = data[@"payload"][@"channels"];
            }
            if (data[@"payload"][@"channel-groups"]) {
                
                errorData[@"channel-groups"] = data[@"payload"][@"channel-groups"];
            }
        }
    }
    
    return [errorData copy];
}


#pragma mark - Misc

- (NSDictionary *)dictionaryRepresentation {
    
    return @{@"Operation": PNOperationTypeStrings[[self operation]],
             @"Request": @{@"Method": (self.request.HTTPMethod?: @"GET"),
                           @"URL": ([self.request.URL absoluteString]?: @"null"),
                           @"POST Body size": @([self.request.HTTPBody length]),
                           @"Origin": (self.origin?: @"unknown")},
             @"Response": @{@"Status code": @(self.statusCode),
                            @"Headers": (self.headers?: @"no headers"),
                            @"Raw data": (self.response?: @"no response"),
                            @"Processed data": (self.data?: @"no data")}};
}

- (NSString *)stringifiedRepresentation {
    
    return [PNJSON JSONStringFrom:[self dictionaryRepresentation] withError:NULL];
}

- (NSString *)debugDescription {
    
    return [[self dictionaryRepresentation] description];
}

#pragma mark -


@end
