/**
 * @author Serhii Mamontov
 * @version 4.11.0
 * @since 4.11.0
 * @copyright © 2010-2019 PubNub, Inc.
 */
#import "PNBaseMessageActionRequest+Private.h"
#import "PNRemoveMessageActionRequest.h"
#import "PNRequest+Private.h"


#pragma nark Interface implementation

@implementation PNRemoveMessageActionRequest


#pragma mark - Information

- (PNOperationType)operation {
    return PNRemoveMessageActionOperation;
}

- (NSString *)httpMethod {
    return @"DELETE";
}


#pragma mark - Information

- (PNRequestParameters *)requestParameters {
    PNRequestParameters *parameters = [super requestParameters];
    
    if (self.actionTimetoken.unsignedIntegerValue == 0) {
        self.parametersError = [self missingParameterError:@"actionTimetoken"
                                          forObjectRequest:@"Message action"];
    }
    
    if (self.parametersError) {
        return parameters;
    }
    
    [parameters addPathComponent:self.actionTimetoken.stringValue
                  forPlaceholder:@"{action-timetoken}"];
    
    return parameters;
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
