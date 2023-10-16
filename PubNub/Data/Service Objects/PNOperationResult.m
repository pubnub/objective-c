#import "PNOperationResult+Private.h"
#import "PNPrivateStructures.h"
#import "PNStatus.h"
#import "PNJSON.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Protected interface declaration

/// Service response representation object private extension.
@interface PNOperationResult () <NSCopying>


#pragma mark - Information

@property (nonatomic, assign) NSInteger statusCode;
@property (nonatomic, assign) PNOperationType operation;
@property (nonatomic, assign, getter = isTLSEnabled) BOOL TLSEnabled;
@property (nonatomic, assign, getter = isUnexpectedServiceData) BOOL unexpectedServiceData;
@property (nonatomic, copy) NSString *uuid
    DEPRECATED_MSG_ATTRIBUTE("This property deprecated and will be removed with next major update. Please use `userID` "
                             "instead.");
@property (nonatomic, copy) NSString *userID;
@property (nonatomic, nullable, copy) NSString *authKey;
@property (nonatomic, copy) NSString *origin;
@property (nonatomic, nullable, copy) NSURLRequest *clientRequest;
@property (nonatomic, nullable, copy) NSDictionary<NSString *, id> *serviceData;


#pragma mark - Helpers

/// Create instance copy with additional adjustments on whether service data information should be copied or not.
///
/// - Parameter shouldCopyServiceData: Whether service data should be passed to new copy or not.
/// - Returns: Receiver's new copy.
- (id)copyWithServiceData:(BOOL)shouldCopyServiceData;

/// Ensure what passed `serviceData` has required data type (dictionary). If `serviceData` has different data type, it
/// will be wrapped into dictionary.
///
/// If unexpected data type will be passes, object will set corresponding flag, so it will be processed and printed out
/// to log file for further investigation.
///
/// - Parameter serviceData: Reference on data which should be verified and used for resulting object.
/// - Returns: `Normalized` service data dictionary.
- (NSDictionary *)normalizedServiceData:(nullable id)serviceData;

#pragma mark -


@end

NS_ASSUME_NONNULL_END


#pragma mark Interface implementation

@implementation PNOperationResult


#pragma mark - Information

- (NSString *)stringifiedOperation {
    return self.operation >= PNSubscribeOperation ? PNOperationTypeStrings[self.operation] : @"Unknown";
}


#pragma mark - Initialization and Configuration

+ (instancetype)objectForOperation:(PNOperationType)operation
                 completedWithTask:(NSURLSessionDataTask *)task
                     processedData:(NSDictionary<NSString *, id> *)processedData 
                   processingError:(NSError *)error {
    return [[self alloc] initForOperation:operation
                        completedWithTask:task
                            processedData:processedData
                          processingError:error];
}

- (instancetype)initForOperation:(PNOperationType)operation
               completedWithTask:(NSURLSessionDataTask *)task
                   processedData:(NSDictionary<NSString *, id> *)processedData 
                 processingError:(NSError *)__unused error {
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
        } else if (processedData && ![processedData isKindOfClass:[NSDictionary class]]) {
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
    PNOperationResult *result = [self copyWithServiceData:NO];
    [result updateData:data];
    
    return result;
}

- (void)updateData:(id)data {
    _serviceData = [[self normalizedServiceData:data] copy];
    _unexpectedServiceData = ![_serviceData isEqual:data];
}


#pragma mark - Helpers

- (id)copyWithServiceData:(BOOL)shouldCopyServiceData {
    PNOperationResult *result = [[self class] new];
    result.statusCode = self.statusCode;
    result.operation = self.operation;
    result.TLSEnabled = self.isTLSEnabled;
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    result.uuid = self.uuid;
#pragma clang diagnostic pop
    result.userID = self.userID;
    result.authKey = self.authKey;
    result.origin = self.origin;
    result.clientRequest = self.clientRequest;
    if (shouldCopyServiceData) {
        
        [result updateData:self.serviceData];
    }
    
    return result;
}

- (NSDictionary *)normalizedServiceData:(id)serviceData {
    NSDictionary *normalizedServiceData = serviceData ?: @{};
    
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
    id processedData = ([self.serviceData mutableCopy]?: @"no data");

    if (self.serviceData[@"envelope"]) {
        processedData[@"envelope"] = [self.serviceData[@"envelope"] valueForKey:@"dictionaryRepresentation"];
    }
    
    NSMutableDictionary *response = [@{@"Status code": @(self.statusCode),
                                       @"Processed data": processedData
                                     } mutableCopy];
    if (_unexpectedServiceData) response[@"Unexpected"] = @(YES);
    
    return @{@"Operation": PNOperationTypeStrings[[self operation]],
             @"Request": @{@"Method": (self.clientRequest.HTTPMethod ?: @"GET"),
                           @"URL": ([self.clientRequest.URL absoluteString] ?: @"null"),
                           @"POST Body size": [self.clientRequest valueForHTTPHeaderField:@"content-length"] ?: @0,
                           @"Secure": (self.isTLSEnabled ? @"YES" : @"NO"),
                           @"User ID": (self.userID?: @"unknown"),
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
