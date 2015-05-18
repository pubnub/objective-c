/**
 @author Sergey Mamontov
 @since 4.0
 @copyright © 2009-2015 PubNub, Inc.
 */
#import "PNResult+Private.h"
#import "PNRequest+Private.h"
#import "PNPrivateStructures.h"


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
        _response = [[NSString alloc] initWithFormat:@"%@\n%@", [response allHeaderFields], data];
        _response = [_response stringByReplacingOccurrencesOfString:@"\n" withString:@"\n\t"];
        _statusCode = response.statusCode;
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

- (NSString *)debugDescription {
    
    NSString *request = [self.request.URL absoluteString];
    return [NSString stringWithFormat:@"\n<Result\n\tOperation: %@\n\tRequest: %@ %@%@"
                                       "\n\tResponse: %@\n\tStatus code: %@\n\tOrigin: %@"
                                       "\n\tData: %@\n>",
            PNOperationTypeStrings[[self operation]], self.request.HTTPMethod,
            [request stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding],
            ([self.request.HTTPBody length] ? [NSString stringWithFormat:@" (%@)",
                                               @([self.request.HTTPBody length])] : @""),
            self.response, @(self.statusCode), self.origin,
            [[self.data description] stringByReplacingOccurrencesOfString:@"\n"
                                                               withString:@"\n\t"]];
}

#pragma mark -


@end
