#import "PNPushNotificationFetchRequest.h"
#import "PNBasePushNotificationsRequest+Private.h"
#import "PNBaseRequest+Private.h"
#import "PNFunctions.h"


#pragma nark Interface implementation

@implementation PNPushNotificationFetchRequest


#pragma mark - Properties

- (PNOperationType)operation {
    return self.pushType == PNAPNS2Push ? PNPushNotificationEnabledChannelsV2Operation
                                        : PNPushNotificationEnabledChannelsOperation;
}


#pragma mark - Initialization and Configuration

+ (instancetype)requestWithDevicePushToken:(id)pushToken pushType:(PNPushType)pushType {
    return [super requestWithDevicePushToken:pushToken pushType:pushType];
}

#pragma mark -


@end
