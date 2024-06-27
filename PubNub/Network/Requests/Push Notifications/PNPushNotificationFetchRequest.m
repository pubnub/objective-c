#import "PNPushNotificationFetchRequest.h"
#import "PNBaseRequest+Private.h"
#import "PNFunctions.h"


#pragma nark Interface implementation

@implementation PNPushNotificationFetchRequest


#pragma mark - Properties

- (PNOperationType)operation {
    return self.pushType == PNAPNS2Push ? PNPushNotificationEnabledChannelsV2Operation
                                        : PNPushNotificationEnabledChannelsOperation;
}

#pragma mark -


@end
