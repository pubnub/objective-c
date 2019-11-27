/**
 * @author Serhii Mamontov
 * @version 4.12.0
 * @since 4.12.0
 * @copyright © 2010-2019 PubNub, Inc.
 */
#import "PNAuditPushNotificationsRequest.h"
#import "PNRequest+Private.h"


#pragma nark Interface implementation

@implementation PNAuditPushNotificationsRequest


#pragma mark - Information

- (PNOperationType)operation {
    return self.pushType == PNAPNS2Push ? PNPushNotificationEnabledChannelsV2Operation
                                        : PNPushNotificationEnabledChannelsOperation;
}

- (BOOL)returnsResponse {
    return YES;
}

#pragma mark -


@end
