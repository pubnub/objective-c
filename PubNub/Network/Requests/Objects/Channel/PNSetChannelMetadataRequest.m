#import "PNSetChannelMetadataRequest.h"
#import "PNBaseObjectsRequest+Private.h"
#import "PNBaseRequest+Private.h"
#import "PNTransportRequest.h"
#import "PNDictionary.h"
#import "PNFunctions.h"
#import "PNError.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Private interface declaration

@interface PNSetChannelMetadataRequest ()


#pragma mark - Properties

/// Request post body.
@property(strong, nullable, nonatomic) NSData *body;

#pragma mark -

@end


NS_ASSUME_NONNULL_END


#pragma mark - Interface implementation

@implementation PNSetChannelMetadataRequest


#pragma mark - Properties

- (PNOperationType)operation {
    return PNSetChannelMetadataOperation;
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

+ (instancetype)requestWithChannel:(NSString *)channel {
    return [[self alloc] initWithObject:@"Channel" identifier:channel];
}

- (instancetype)initWithObject:(NSString *)objectType identifier:(NSString *)identifier {
    if ((self = [super initWithObject:objectType identifier:identifier])) {
        _includeFields |= PNChannelCustomField|PNChannelStatusField|PNChannelTypeField;
    }
    
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
        NSString *reason = PNStringFormat(@"'custom' object for '%@' channel metadata contain not allowed data types "
                                          "(only NSString and NSNumber allowed).", self.identifier);
        NSDictionary *userInfo = @{
            NSLocalizedDescriptionKey: @"Channel metadata additional information serialization did fail",
            NSLocalizedFailureReasonErrorKey: reason,
        };
        
        return [PNError errorWithDomain:PNAPIErrorDomain code:PNAPIErrorUnacceptableParameters userInfo:userInfo];
    }
    
    NSMutableDictionary *info = [NSMutableDictionary new];
    
    if (self.name) info[@"name"] = self.name;
    if (self.information.length) info[@"description"] = self.information;
    if (self.status.length) info[@"status"] = self.status;
    if (self.custom.count) info[@"custom"] = self.custom;
    if (self.type.length) info[@"type"] = self.type;

    if ([NSJSONSerialization isValidJSONObject:info]) {
        self.body = [NSJSONSerialization dataWithJSONObject:info options:(NSJSONWritingOptions)0 error:&error];
    } else {
        NSDictionary *userInfo = @{
            NSLocalizedDescriptionKey: @"Unable to serialize to JSON string",
            NSLocalizedFailureReasonErrorKey: @"Provided object contains unsupported data type instances."
        };
        
        error = [PNError errorWithDomain:NSCocoaErrorDomain code:NSPropertyListWriteInvalidError userInfo:userInfo];
    }
    
    if (error) {
        NSDictionary *userInfo = @{
            NSLocalizedDescriptionKey: @"Channel metadata information serialization did fail",
            NSUnderlyingErrorKey: error
        };
        
        return [PNError errorWithDomain:PNAPIErrorDomain code:PNAPIErrorUnacceptableParameters userInfo:userInfo];
    }
    
    return nil;
}


#pragma mark - Misc

- (NSDictionary *)dictionaryRepresentation {
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithDictionary:[super dictionaryRepresentation]];
    
    if (self.ifMatchesEtag) dictionary[@"ifMatchesEtag"] = self.ifMatchesEtag;
    if (self.information) dictionary[@"information"] = self.information;
    if (self.custom) dictionary[@"custom"] = self.custom;
    if (self.status) dictionary[@"status"] = self.status;
    if (self.name) dictionary[@"name"] = self.name;
    if (self.type) dictionary[@"type"] = self.type;
    
    return dictionary;
}

#pragma mark -


@end
