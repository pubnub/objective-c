/**
 * @author Serhii Mamontov
 * @version 4.12.0
 * @since 4.12.0
 * @copyright © 2010-2019 PubNub, Inc.
 */
#import "PNRemovePushNotificationsRequest.h"
#import "PNRequest+Private.h"
#import "PNHelpers.h"


#pragma nark Interface implementation

@implementation PNRemovePushNotificationsRequest


#pragma mark - Information

- (PNOperationType)operation {
    return self.pushType == PNAPNS2Push ? PNRemovePushNotificationsFromChannelsV2Operation
                                        : PNRemovePushNotificationsFromChannelsOperation;
}

- (BOOL)returnsResponse {
    return NO;
}

- (PNRequestParameters *)requestParameters {
    PNRequestParameters *parameters = [super requestParameters];
    
    if (self.channels.count == 0) {
        self.parametersError = [self missingParameterError:@"channels" forObjectRequest:@"Request"];
    }
    
    if (self.parametersError) {
        [parameters removePathComponentForPlaceholder:@"{token}"];
        
        return parameters;
    }
    
    [parameters addQueryParameter:[PNChannel namesForRequest:self.channels] forFieldName:@"remove"];
    
    return parameters;
}

#pragma mark -


@end
