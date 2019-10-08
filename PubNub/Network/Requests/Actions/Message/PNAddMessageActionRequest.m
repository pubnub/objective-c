/**
 * @author Serhii Mamontov
 * @version 4.11.0
 * @since 4.11.0
 * @copyright © 2010-2019 PubNub, Inc.
 */
#import "PNBaseMessageActionRequest+Private.h"
#import "PNAddMessageActionRequest.h"
#import "PNRequest+Private.h"
#import "PNErrorCodes.h"


#pragma mark Interface implementation

@implementation PNAddMessageActionRequest


#pragma mark - Information

- (PNOperationType)operation {
    return PNAddMessageActionOperation;
}

- (NSString *)httpMethod {
    return @"POST";
}


#pragma mark - Information

- (NSData *)bodyData {
    if (!self.type || ([self.type isKindOfClass:[NSString class]] && !self.type.length)) {
        self.parametersError = [self missingParameterError:@"type"
                forObjectRequest:@"Message action"];
    } else if (self.type.length > 15) {
        self.parametersError = [self valueTooLongErrorForParameter:@"type"
                                                   ofObjectRequest:@"Message action"
                                                        withLength:self.type.length
                                                     maximumLength:15];
    } else if (!self.value || ([self.value isKindOfClass:[NSString class]] && !self.value.length)) {
        self.parametersError = [self missingParameterError:@"value"
                forObjectRequest:@"Message action"];
    }
    
    if (self.parametersError) {
        return nil;
    }
    
    NSDictionary *actionData = @{ @"type": self.type, @"value": self.value };
    NSError *error = nil;
    NSData *data = nil;
    
    if ([NSJSONSerialization isValidJSONObject:actionData]) {
        data = [NSJSONSerialization dataWithJSONObject:actionData
                                               options:(NSJSONWritingOptions)0
                                                 error:&error];
    } else {
        NSDictionary *errorInformation = @{
            NSLocalizedDescriptionKey: @"Unable to serialize to JSON string",
            NSLocalizedFailureReasonErrorKey: @"Provided 'value' has unexpected data type."
        };
        
        error = [NSError errorWithDomain:NSCocoaErrorDomain
                                    code:NSPropertyListWriteInvalidError
                                userInfo:errorInformation];
    }
    
    if (error) {
        NSDictionary *errorInformation = @{
            NSLocalizedDescriptionKey: @"Message action data serialization did fail",
            NSUnderlyingErrorKey: error
        };
        
        self.parametersError = [NSError errorWithDomain:kPNAPIErrorDomain
                                                   code:kPNAPIUnacceptableParameters
                                               userInfo:errorInformation];
    }
    
    return data;
}


#pragma mark - Initialization & Configuration

+ (instancetype)requestWithChannel:(NSString *)channel
                  messageTimetoken:(NSNumber *)messageTimetoken {
    
    return [[self alloc] initWithChannel:channel messageTimetoken:messageTimetoken];
}

- (instancetype)init {
    [self throwUnavailableInitInterface];
    
    return nil;
}

#pragma mark -


@end
