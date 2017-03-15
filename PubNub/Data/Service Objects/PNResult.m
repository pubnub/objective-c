/**
 @author Sergey Mamontov
 @since 4.0
 @copyright © 2009-2017 PubNub, Inc.
 */
#import "PNResult+Private.h"
#import "PNPrivateStructures.h"
#import "PNStatus.h"
#import "PNJSON.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Protected interface declaration

@interface PNResult () <NSCopying>


#pragma mark - Information

@property (nonatomic, assign) NSInteger statusCode;
@property (nonatomic, assign) PNOperationType operation;
@property (nonatomic, assign, getter = isTLSEnabled) BOOL TLSEnabled;
@property (nonatomic, assign, getter = isUnexpectedServiceData) BOOL unexpectedServiceData;
@property (nonatomic, copy) NSString *uuid;
@property (nonatomic, nullable, copy) NSString *authKey;
@property (nonatomic, copy) NSString *origin;
@property (nonatomic, nullable, copy) NSURLRequest *clientRequest;
@property (nonatomic, nullable, copy) NSDictionary<NSString *, id> *serviceData;


#pragma mark - Misc

/**
 @brief  Create instance copy with additional adjustments on whether service data information should be copied
         sor not.
 
 @param shouldCopyServiceData Whether service data should be passed to new copy or not.
 
 @param Receiver's new copy.
 */
- (id)copyWithServiceData:(BOOL)shouldCopyServiceData;

/**
 @brief      Ensure what passed \c serviceData has required data type (dictionary). If \c serviceData has 
             different data type, it will be wrapped into dictionary.
 @discussion If unexpected data type will be passes, object will set corresponding flag, so it will be
             processed and printed out to log file for further investigation.
 
 @param serviceData Reference on data which should be verified and used for resulting object.
 
 @return \c Normalized service data dictionary.
 */
- (NSDictionary *)normalizedServiceData:(nullable id)serviceData;

#pragma mark -


@end

NS_ASSUME_NONNULL_END


#pragma mark Interface implementation

@implementation PNResult


#pragma mark - Information

- (NSString *)stringifiedOperation {
    
    return (self.operation >= PNSubscribeOperation ? PNOperationTypeStrings[self.operation] : @"Unknown");
}


#pragma mark - Initialization and Configuration

+ (instancetype)objectForOperation:(PNOperationType)operation completedWithTask:(NSURLSessionDataTask *)task
                     processedData:(NSDictionary<NSString *, id> *)processedData 
                   processingError:(NSError *)error {
    
    return [[self alloc] initForOperation:operation completedWithTask:task
                            processedData:processedData processingError:error];
}

- (instancetype)initForOperation:(PNOperationType)operation completedWithTask:(NSURLSessionDataTask *)task
                   processedData:(NSDictionary<NSString *, id> *)processedData 
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
        // Received unknown response from service.
        else if (processedData && ![processedData isKindOfClass:[NSDictionary class]]){
            
            _unexpectedServiceData = YES;
            processedData = [self normalizedServiceData:processedData];
        }
        _serviceData = [processedData copy];
    }
    
    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    
    return [self copyWithServiceData:YES];
}

- (instancetype)copyWithMutatedData:(id)data {
    
    PNResult *result = [self copyWithServiceData:NO];
    [result updateData:data];
    
    return result;
}

- (void)updateData:(id)data {
    
    _serviceData = [[self normalizedServiceData:data] copy];
    _unexpectedServiceData = ![_serviceData isEqual:data];
}


#pragma mark - Misc

- (id)copyWithServiceData:(BOOL)shouldCopyServiceData {
    
    PNResult *result = [[self class] new];
    result.statusCode = self.statusCode;
    result.operation = self.operation;
    result.TLSEnabled = self.isTLSEnabled;
    result.uuid = self.uuid;
    result.authKey = self.authKey;
    result.origin = self.origin;
    result.clientRequest = self.clientRequest;
    if (shouldCopyServiceData) {
        
        [result updateData:self.serviceData];
    }
    
    return result;
}

- (NSDictionary *)normalizedServiceData:(id)serviceData {
    
    NSDictionary *normalizedServiceData = serviceData;
    if (serviceData && ![serviceData isKindOfClass:[NSDictionary class]]) {
        
        normalizedServiceData = @{@"information": serviceData};
    }
    
    return normalizedServiceData;
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)__unused selector {
    
    return [[self class] instanceMethodSignatureForSelector:@selector(doNothing)];
}

- (void)forwardInvocation:(NSInvocation *)__unused invocation {
    
}

- (void)doNothing {
    
}

- (NSDictionary *)dictionaryRepresentation {
    
    id processedData = (self.serviceData[@"envelope"] ? [self.serviceData mutableCopy] : 
                        (self.serviceData?: @"no data"));
    if ([processedData isKindOfClass:[NSMutableDictionary class]]) {
        
        processedData[@"envelope"] = [self.serviceData[@"envelope"] valueForKey:@"dictionaryRepresentation"];
    }
    
    NSMutableDictionary *response = [@{@"Status code": @(self.statusCode),
                                       @"Processed data": processedData} mutableCopy];
    if (_unexpectedServiceData) { response[@"Unexpected"] = @(YES); }
    
    return @{@"Operation": PNOperationTypeStrings[[self operation]],
             @"Request": @{@"Method": (self.clientRequest.HTTPMethod?: @"GET"),
                           @"URL": ([self.clientRequest.URL absoluteString]?: @"null"),
                           @"POST Body size": @([self.clientRequest.HTTPBody length]),
                           @"Secure": (self.isTLSEnabled ? @"YES" : @"NO"),
                           @"UUID": (self.uuid?: @"unknown"),
                           @"Authorization": (self.authKey?: @"not set"),
                           @"Origin": (self.origin?: @"unknown")},
             @"Response": response};
}

- (NSString *)stringifiedRepresentation {
    
    return [PNJSON JSONStringFrom:[self dictionaryRepresentation] withError:NULL];
}

- (NSString *)debugDescription {
    
    return [[self dictionaryRepresentation] description];
}

#pragma mark -


@end
