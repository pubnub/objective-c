#import "PNPushNotificationManageRequest.h"
#import "PNBasePushNotificationsRequest+Private.h"
#import "PNBaseRequest+Private.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Private interface declaration

/// `Push Notifications Manage` request private extension.
@interface PNPushNotificationManageRequest ()


#pragma mark - Properties

/// List of channel names for which push notifications should be managed.
@property(strong, nullable, nonatomic) NSArray<NSString *> *channels;

/// Type of request operation.
///
/// One of PubNub REST API endpoints or third-party endpoint.
@property (assign, nonatomic) PNOperationType operation;

#pragma mark -


@end

NS_ASSUME_NONNULL_END


#pragma mark - Interface implementation

@implementation PNPushNotificationManageRequest


#pragma mark - Properties

- (NSDictionary *)query {
    NSMutableDictionary *query = [([super query] ?: @{}) mutableCopy];
    PNOperationType operation = self.operation;
    NSString *manageType;
    
    if (operation == PNAddPushNotificationsOnChannelsOperation || 
        operation == PNAddPushNotificationsOnChannelsV2Operation) {
        manageType = @"add";
    } else if (operation == PNRemovePushNotificationsFromChannelsOperation ||
              operation == PNRemovePushNotificationsFromChannelsV2Operation) {
        manageType = @"remove";
    }
    
    if (manageType) query[manageType] = [self.channels componentsJoinedByString:@","];
    
    return query;
}


#pragma mark - Initialization and Configuration

+ (instancetype)requestToAddChannels:(NSArray<NSString *> *)channels
                   toDeviceWithToken:(id)token
                            pushType:(PNPushType)pushType {
    PNPushNotificationManageRequest *request = [self requestWithDevicePushToken:token pushType:pushType];
    request.channels = channels;
                                
    if (pushType == PNAPNS2Push) request.operation = PNAddPushNotificationsOnChannelsV2Operation;
    else request.operation = PNAddPushNotificationsOnChannelsOperation;
                                
    return request;
}


+ (instancetype)requestToRemoveChannels:(NSArray<NSString *> *)channels 
                    fromDeviceWithToken:(id)token
                               pushType:(PNPushType)pushType {
    PNPushNotificationManageRequest *request = [self requestWithDevicePushToken:token pushType:pushType];
    request.channels = channels;
                                
    if (pushType == PNAPNS2Push) request.operation = PNRemovePushNotificationsFromChannelsV2Operation;
    else request.operation = PNRemovePushNotificationsFromChannelsOperation;
    
    return request;
}

+ (instancetype)requestToRemoveDeviceWithToken:(id)token pushType:(PNPushType)pushType {
    PNPushNotificationManageRequest *request = [self requestWithDevicePushToken:token pushType:pushType];
                                
    if (pushType == PNAPNS2Push) request.operation = PNRemoveAllPushNotificationsV2Operation;
    else request.operation = PNRemoveAllPushNotificationsOperation;
    
    
    return request;
}


#pragma mark - Prepare

- (PNError *)validate {
    PNError *error = [super validate];
    if (error) return error;
    
    PNOperationType operation = self.operation;
    
    if (self.channels.count == 0 &&
        (operation != PNRemoveAllPushNotificationsOperation && operation != PNRemoveAllPushNotificationsV2Operation)) {
        return [self missingParameterError:@"channels" forObjectRequest:@"Request"];
    }

    if (self.pushType == PNAPNS2Push && self.topic.length == 0) {
        return [self missingParameterError:@"topic" forObjectRequest:@"Request"];
    }

    return nil;
}

#pragma mark -


@end
