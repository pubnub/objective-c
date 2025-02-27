#import "PNSetUUIDMetadataRequest.h"
#import "PNBaseObjectsRequest+Private.h"
#import "PNBaseRequest+Private.h"
#import "PNTransportRequest.h"
#import "PNDictionary.h"
#import "PNFunctions.h"
#import "PNError.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Private interface declaration

/// `Set UUID metadata` request private extension.
@interface PNSetUUIDMetadataRequest ()


#pragma mark - Properties

/// Request post body.
@property(strong, nullable, nonatomic) NSData *body;

#pragma mark -


@end

NS_ASSUME_NONNULL_END


#pragma mark - Interface implementation

@implementation PNSetUUIDMetadataRequest


#pragma mark - Properties

- (PNOperationType)operation {
    return PNSetUUIDMetadataOperation;
}

- (TransportMethod)httpMethod {
    return TransportPATCHMethod;
}

- (NSDictionary *)headers {
    NSMutableDictionary *headers =[([super headers] ?: @{}) mutableCopy];
    headers[@"Content-Type"] = @"application/json";

    if (self.ifMatchesEtag) headers[@"If-Match"] = self.ifMatchesEtag;

    return headers;
}


#pragma mark - Initialization and Configuration

+ (instancetype)new {
    return [self requestWithUUID:nil];
}

+ (instancetype)requestWithUUID:(NSString *)uuid {
    return [[self alloc] initWithObject:@"UUID" identifier:uuid];
}

- (instancetype)initWithObject:(NSString *)objectType identifier:(NSString *)identifier {
    if ((self = [super initWithObject:objectType identifier:identifier])) _includeFields = PNUUIDCustomField;
    return self;
}

- (instancetype)init {
    [self throwUnavailableInitInterface];

    return nil;
}


#pragma mark - Prepare

- (PNError *)validate {
    PNError *error = [super validate];
    if (error) return error;
    
    NSArray<Class> *clss = @[[NSString class], [NSNumber class]];
    
    if (self.custom.count && ![PNDictionary isDictionary:self.custom containValueOfClasses:clss]) {
        NSString *reason = PNStringFormat(@"'custom' object for '%@' contain not allowed data types (only NSString and "
                                          "NSNumber allowed).", self.identifier);
        NSDictionary *userInfo = @{
            NSLocalizedDescriptionKey: @"Metadata additional information serialization did fail",
            NSLocalizedFailureReasonErrorKey: reason,
        };
        
        return [PNError errorWithDomain:PNAPIErrorDomain code:PNAPIErrorUnacceptableParameters userInfo:userInfo];
    }
    
    NSMutableDictionary *info = [NSMutableDictionary new];
    
    if (self.name) info[@"name"] = self.name;
    if (self.externalId.length) info[@"externalId"] = self.externalId;
    if (self.profileUrl.length) info[@"profileUrl"] = self.profileUrl;
    if (self.status.length) info[@"status"] = self.status;
    if (self.custom.count) info[@"custom"] = self.custom;
    if (self.email.length) info[@"email"] = self.email;
    if (self.type.length) info[@"type"] = self.type;

    if ([NSJSONSerialization isValidJSONObject:info]) {
        self.body = [NSJSONSerialization dataWithJSONObject:info options:(NSJSONWritingOptions)0 error:&error];
    } else {
        NSDictionary *userInfo = @{
            NSLocalizedDescriptionKey: @"Unable to serialize to JSON string",
            NSLocalizedFailureReasonErrorKey: @"Provided object contains unsupported data type instances."
        };
        
        error = [PNError errorWithDomain:NSCocoaErrorDomain  code:NSPropertyListWriteInvalidError userInfo:userInfo];
    }
    
    if (error) {
        NSDictionary *userInfo = @{
            NSLocalizedDescriptionKey: @"Metadata information serialization did fail",
            NSUnderlyingErrorKey: error
        };
        
        return [PNError errorWithDomain:PNAPIErrorDomain code:PNAPIErrorUnacceptableParameters userInfo:userInfo];
    }
    
    return nil;
}

#pragma mark -


@end
