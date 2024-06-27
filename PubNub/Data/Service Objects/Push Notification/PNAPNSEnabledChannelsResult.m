#import "PNAPNSEnabledChannelsResult.h"
#import "PNOperationResult+Private.h"


#pragma mark Interface implementation

@implementation PNAPNSEnabledChannelsResult


#pragma mark - Properties

+ (Class)responseDataClass {
    return [PNPushNotificationFetchData class];
}

- (PNPushNotificationFetchData *)data {
    return self.responseData;
}

#pragma mark - 


@end
