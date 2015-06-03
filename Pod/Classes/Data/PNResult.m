/**
 @author Sergey Mamontov
 @since 4.0
 @copyright © 2009-2015 PubNub, Inc.
 */
#import "PNResult+Private.h"
#import "PNPrivateStructures.h"
#import "PNStatus.h"
#import "PNJSON.h"


#pragma mark Interface implementation

@implementation PNResult


#pragma mark - Initialization and Configuration

+ (instancetype)objectForOperation:(PNOperationType)operation
                 completedWithTaks:(NSURLSessionDataTask *)task
                     processedData:(NSDictionary *)processedData {
    
    return [[self alloc] initForOperation:operation completedWithTaks:task
                            processedData:processedData];
}

- (instancetype)initForOperation:(PNOperationType)operation
               completedWithTaks:(NSURLSessionDataTask *)task
                   processedData:(NSDictionary *)processedData {
    
    // Check whether initialization was successful or not.
    if ((self = [super init])) {
        
        _statusCode = (task ? ((NSHTTPURLResponse *)task.response).statusCode : 200);
        _operation = operation;
        _clientRequest = [task.currentRequest copy];
        _data = [processedData copy];
        if ([_data[@"status"] isKindOfClass:[NSNumber class]] &&
            [(NSNumber *)_data[@"status"] integerValue] > 200) {
            
            _statusCode = [(NSNumber *)_data[@"status"] integerValue];
        }
    }
    
    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    
    PNResult *result = [[[self class] allocWithZone:zone] init];
    result.statusCode = self.statusCode;
    result.operation = self.operation;
    result.TLSEnabled = self.isTLSEnabled;
    result.uuid = self.uuid;
    result.authKey = self.authKey;
    result.origin = self.origin;
    result.clientRequest = self.clientRequest;
    result.data = self.data;
    
    return result;
}

- (instancetype)copyWithMutatedData:(id)data {
    
    PNResult *result = [self copy];
    result->_data = [data copy];
    
    return result;
}


#pragma mark - Misc

- (NSDictionary *)dictionaryRepresentation {
    
    return @{@"Operation": PNOperationTypeStrings[[self operation]],
             @"Request": @{@"Method": (self.clientRequest.HTTPMethod?: @"GET"),
                           @"URL": ([self.clientRequest.URL absoluteString]?: @"null"),
                           @"POST Body size": @([self.clientRequest.HTTPBody length]),
                           @"Secure": (self.isTLSEnabled ? @"YES" : @"NO"),
                           @"UUID": (self.uuid?: @"uknonwn"),
                           @"Authorization": (self.authKey?: @"not set"),
                           @"Origin": (self.origin?: @"unknown")},
             @"Response": @{@"Status code": @(self.statusCode),
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
