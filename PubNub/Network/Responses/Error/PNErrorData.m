#import "PNErrorData+Private.h"
#import "PNBaseOperationData+Private.h"
#import "PNCodable.h"
#import "PNError.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Private interface declaration

/// Error status object additional information private extension.
@interface PNErrorData () <PNCodable>


#pragma mark - Properties

/// List of channel groups for which error has been triggered.
@property(strong, nullable, nonatomic) NSArray<NSString *> *channelGroups;

/// List of channels for which error has been triggered.
@property(strong, nullable, nonatomic) NSArray<NSString *> *channels;

/// Service-provided information about error.
@property(strong, nonatomic) NSString *information;

/// Service-provided additional information about error.
@property(strong, nullable, nonatomic) id data;


#pragma mark - Initialization and Configuration

/// Initialize error status data from error.
///
/// - Parameter error: Transport or parser error object.
/// - Returns: Initialized error status data object.
- (instancetype)initWithError:(NSError *)error;


#pragma mark - Parse error information

/// Process error information received from transport implementation or parsers.
///
/// - Parameter error: Transport or parser error object.
- (void)parseFromError:(NSError *)error;

/// Process error information received from remote service.
///
/// - Parameter payload: JSON response with error information.
- (void)parseFromPayload:(id)payload;

#pragma mark -


@end


NS_ASSUME_NONNULL_END

#pragma mark - Interface implementation

@implementation PNErrorData


#pragma mark - Properties

+ (NSArray<NSString *> *)optionalKeys {
    return @[@"channelGroups", @"channels", @"information", @"error", @"data"];
}


#pragma mark - Initialization and Configuration

+ (instancetype)dataWithError:(NSError *)error {
    return [[self alloc] initWithError:error];
}

- (instancetype)initWithError:(NSError *)error {
    if ((self = [super init])) [self parseFromError:error];
    
    return self;
}

- (instancetype)initObjectWithCoder:(id<PNDecoder>)coder {
    if ((self = [super init])) {
        [self parseFromPayload:[coder decodeObjectOfClasses:@[[NSDictionary class], [NSArray class]]]];
    }
    
    return self;
}


#pragma mark - Parse error information

- (void)parseFromError:(NSError *)error {
    self.category = PNUnknownCategory;

    if ([error.domain isEqualToString:PNStorageErrorDomain]) {
        self.category = PNDownloadErrorCategory;
    } else if (error.code == PNTransportErrorRequestTimeout) self.category = PNTimeoutCategory;
    else if (error.code == PNTransportErrorRequestCancelled) self.category = PNCancelledCategory;
    else if (error.code == PNTransportErrorNetworkIssues) self.category = PNNetworkIssuesCategory;
    else if (error.code == PNAPIErrorUnacceptableParameters || error.code == PNAPIErrorBadRequest) {
        self.category = PNBadRequestCategory;
    } else if (error.code == PNAPIErrorFeatureNotEnabled || error.code == PNAPIErrorAccessDenied) {
        self.category = PNAccessDeniedCategory;
    } else if (error.code == PNAPIErrorRequestURITooLong) self.category = PNRequestURITooLongCategory;
    else if(error.code == PNAPIErrorMalformedServiceResponse) self.category = PNMalformedResponseCategory;
    else if(error.code == PNAPIErrorMalformedFilterExpression) self.category = PNMalformedFilterExpressionCategory;
    else if(error.code == PNCryptorErrorInsufficientMemory || error.code == PNCryptorErrorDecryption) {
        self.category = PNDecryptionErrorCategory;
    }

    self.information = [error.localizedFailureReason copy];
}

- (void)parseFromPayload:(id)payload {
    if ([payload isKindOfClass:[NSArray class]]) {
        NSArray *array = payload;
        
        if (array.count == 2) {
            if ([array[0] isKindOfClass:[NSNumber class]] && [array[0] isEqual:@0]) {
                _information = array[1];
                self.category = PNBadRequestCategory;
            }
        } else if (array.count == 3 && [array[0] isKindOfClass:[NSNumber class]] && [array[0] isEqual:@0]) {
            if ([array[1] isKindOfClass:[NSString class]]) {
                _information = array[1];
                self.category = PNBadRequestCategory;
            }
        }
    } else if ([payload isKindOfClass:[NSDictionary class]]) {
        NSDictionary *dictionary = payload;
        id description = dictionary[@"error"];
        
        if ([description isKindOfClass:[NSString class]]) _information = description;
        else if (!description || ([description isKindOfClass:[NSNumber class]] && ((NSNumber *)description).boolValue &&
                                  dictionary[@"error_message"])) {
            description = dictionary[@"error_message"];
        }
        
        if ([description isKindOfClass:[NSDictionary class]] && description[@"message"]) {
            NSMutableArray<NSDictionary *> *errorDetails = description[@"details"];
            _information = description[@"message"];
            
            if (errorDetails.count) {
                NSMutableArray<NSString *> *detailStrings = [NSMutableArray new];
                
                for (NSDictionary *details in errorDetails) {
                    NSString *detailString = @"";
                    
                    if (details[@"message"]) detailString = [@"- " stringByAppendingString:details[@"message"]];
                    if (details[@"location"]) {
                        detailString = [detailString stringByAppendingFormat:@"%@ Location: %@",
                                        detailString.length ? @"" : @"-", details[@"location"]];
                    }
                    
                    [detailStrings addObject:detailString];
                }
                
                if (detailStrings.count) {
                    _information = [_information stringByAppendingFormat:@" Details:\n%@",
                                    [detailStrings componentsJoinedByString:@"\n"]];
                }
            }
        }
        
        if (_information || dictionary[@"message"]) _information = dictionary[@"message"] ?: _information;
        if ([dictionary[@"status"] isKindOfClass:[NSNumber class]]) {
            NSUInteger statusCode = ((NSNumber *)dictionary[@"status"]).unsignedIntegerValue;
            self.category = PNUnknownCategory;
            
            if (statusCode == 400) self.category = PNBadRequestCategory;
            else if (statusCode == 403) self.category = PNAccessDeniedCategory;
            else if (statusCode == 404) self.category = PNResourceNotFoundCategory;
            else if (statusCode == 411) self.category = PNBadRequestCategory;
            else if (statusCode == 414) self.category = PNRequestURITooLongCategory;
            else if (statusCode == 481) self.category = PNMalformedFilterExpressionCategory;
        }
        
        if (dictionary[@"payload"]) {
            _channelGroups = [dictionary valueForKeyPath:@"payload.channel-groups"] ?: @[];
            _channels = [dictionary valueForKeyPath:@"payload.channels"] ?: @[];
            
            if (_channels.count == 0 && _channels.count == 0) _data = dictionary[@"payload"];
        }
        
        if ([_information containsString:@"not enabled"]) self.category = PNAccessDeniedCategory;
    } else {
        _information = @"Malformed service response.";
        self.category = PNMalformedResponseCategory;
    }
}

#pragma mark -


@end
