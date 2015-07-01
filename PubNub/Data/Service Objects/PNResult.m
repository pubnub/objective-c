/**
 @author Sergey Mamontov
 @since 4.0
 @copyright © 2009-2015 PubNub, Inc.
 */
#import "PNResult+Private.h"
#import "PNPrivateStructures.h"
#import "PNStatus.h"
#import "PNJSON.h"


#pragma mark Protected interface declaration

@interface PNResult () <NSCopying>


///------------------------------------------------
/// @name Information
///------------------------------------------------

@property (nonatomic, assign) NSInteger statusCode;
@property (nonatomic, assign) PNOperationType operation;
@property (nonatomic, assign, getter = isTLSEnabled) BOOL TLSEnabled;
@property (nonatomic, copy) NSString *uuid;
@property (nonatomic, copy) NSString *authKey;
@property (nonatomic, copy) NSString *origin;
@property (nonatomic, copy) NSURLRequest *clientRequest;
@property (nonatomic, copy) NSDictionary *serviceData;

#pragma mark -


@end


#pragma mark Interface implementation

@implementation PNResult


#pragma mark - Initialization and Configuration

+ (instancetype)objectForOperation:(PNOperationType)operation
                 completedWithTaks:(NSURLSessionDataTask *)task
                     processedData:(NSDictionary *)processedData processingError:(NSError *)error {
    
    return [[self alloc] initForOperation:operation completedWithTaks:task
                            processedData:processedData processingError:error];
}

- (instancetype)initForOperation:(PNOperationType)operation
               completedWithTaks:(NSURLSessionDataTask *)task
                   processedData:(NSDictionary *)processedData
                 processingError:(NSError *)__unused error {
    
    // Check whether initialization was successful or not.
    if ((self = [super init])) {
        
        _statusCode = (task ? ((NSHTTPURLResponse *)task.response).statusCode : 200);
        _operation = operation;
        _clientRequest = [task.currentRequest copy];
        if ([processedData[@"status"] isKindOfClass:[NSNumber class]]) {
            
            NSMutableDictionary *dataForUpdate = [processedData mutableCopy];
            NSNumber *statusCode = [dataForUpdate[@"status"] copy];
            [dataForUpdate removeObjectForKey:@"status"];
            processedData = [dataForUpdate copy];
            _statusCode = (([statusCode integerValue] > 200) ? [statusCode integerValue] : _statusCode);
        }
        _serviceData = [processedData copy];
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
    result.serviceData = self.serviceData;
    
    return result;
}

- (instancetype)copyWithMutatedData:(id)data {
    
    PNResult *result = [self copy];
    result->_serviceData = [data copy];
    
    return result;
}

- (void)updateData:(id)data {
    
    _serviceData = [data copy];
}


#pragma mark - Misc

- (NSMethodSignature *)methodSignatureForSelector:(SEL)__unused selector {
    
    return [[self class] instanceMethodSignatureForSelector:@selector(doNothing)];
}

- (void)forwardInvocation:(NSInvocation *)__unused invocation {
    
}

- (void)doNothing {
    
}

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
                            @"Processed data": (self.serviceData?: @"no data")}};
}

- (NSString *)stringifiedRepresentation {
    
    return [PNJSON JSONStringFrom:[self dictionaryRepresentation] withError:NULL];
}

- (NSString *)debugDescription {
    
    return [[self dictionaryRepresentation] description];
}

#pragma mark -


@end
