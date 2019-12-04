/**
 * @author Serhii Mamontov
 * @version 4.12.0
 * @since 4.12.0
 * @copyright © 2010-2019 PubNub, Inc.
 */
#import "PNRemoveAllPushNotificationsRequest.h"
#import "PNRequest+Private.h"


#pragma nark Interface implementation

@implementation PNRemoveAllPushNotificationsRequest


#pragma mark - Information

- (PNOperationType)operation {
    return self.pushType == PNAPNS2Push ? PNRemoveAllPushNotificationsV2Operation
                                        : PNRemoveAllPushNotificationsOperation;
}

- (BOOL)returnsResponse {
    return NO;
}

#pragma mark -


@end
