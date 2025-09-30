#import "PNAddMessageActionRequest.h"
#import "PNBaseMessageActionRequest+Private.h"
#import "PNBaseRequest+Private.h"
#import "PNFunctions.h"
#import "PNHelpers.h"
#import "PNError.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Private interface declaration

/// `Add message action` request private extension.
@interface PNAddMessageActionRequest ()


#pragma mark - Properties

/// Request post body.
@property(strong, nullable, nonatomic) NSData *body;

#pragma mark -


@end

NS_ASSUME_NONNULL_END


#pragma mark - Interface implementation

@implementation PNAddMessageActionRequest


#pragma mark - Properties

- (PNOperationType)operation {
    return PNAddMessageActionOperation;
}

- (TransportMethod)httpMethod {
    return TransportPOSTMethod;
}

- (NSDictionary *)headers {
    NSMutableDictionary *headers =[([super headers] ?: @{}) mutableCopy];
    headers[@"Content-Type"] = @"application/json";
    
    return headers;
}

- (NSString *)path {
    return PNStringFormat(@"/v1/message-actions/%@/channel/%@/message/%@",
                          self.subscribeKey, [PNString percentEscapedString:self.channel], self.messageTimetoken);
}


#pragma mark - Initialization & Configuration

+ (instancetype)requestWithChannel:(NSString *)channel messageTimetoken:(NSNumber *)messageTimetoken {
    return [[self alloc] initWithChannel:channel messageTimetoken:messageTimetoken];
}


#pragma mark - Prepare

- (PNError *)validate {
    PNError *error = [super validate];
    if (error) return error;
    
    if (!self.type || ([self.type isKindOfClass:[NSString class]] && !self.type.length)) {
        return [self missingParameterError:@"type" forObjectRequest:@"PNAddMessageActionRequest"];
    } else if (self.type.length > 15) {
        return [self valueTooLongErrorForParameter:@"type"
                                   ofObjectRequest:@"PNAddMessageActionRequest"
                                        withLength:self.type.length
                                     maximumLength:15];
    } else if (!self.value || ([self.value isKindOfClass:[NSString class]] && !self.value.length)) {
        return [self missingParameterError:@"value" forObjectRequest:@"PNAddMessageActionRequest"];
    }

    NSDictionary *actionData = @{ @"type": self.type, @"value": self.value };
    
    if ([NSJSONSerialization isValidJSONObject:actionData]) {
        self.body = [NSJSONSerialization dataWithJSONObject:actionData options:(NSJSONWritingOptions)0 error:&error];
    } else {
        NSDictionary *info = PNErrorUserInfo(
            @"Unable to serialize to JSON string",
            @"Provided 'value' has unexpected data type.",
            nil,
            nil
        );

        error = [PNError errorWithDomain:NSCocoaErrorDomain code:NSPropertyListWriteInvalidError userInfo:info];
    }
    
    if (error) {
        NSDictionary *info = PNErrorUserInfo(@"Message action data serialization did fail", nil, nil, error);
        return [PNError errorWithDomain:PNAPIErrorDomain code:PNAPIErrorUnacceptableParameters userInfo:info];
    }
    
    return nil;
}


#pragma mark - Misc

- (NSDictionary *)dictionaryRepresentation {
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithDictionary:[super dictionaryRepresentation]];
    dictionary[@"value"] = self.value ?: @"missing";
    dictionary[@"type"] = self.type ?: @"missing";
    
    return dictionary;
}

#pragma mark -


@end
