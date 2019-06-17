/**
 * @author Serhii Mamontov
 * @since 4.0
 * @copyright © 2010-2018 PubNub, Inc.
 */
#import "PubNub+APNS.h"
#import "PNAPICallBuilder+Private.h"
#import "PNRequestParameters.h"
#import "PubNub+CorePrivate.h"
#import "PNStatus+Private.h"
#import "PNKeychain.h"
#import "PNHelpers.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark - Protected interface declaration

@interface PubNub (APNSProtected)


#pragma mark - Push notifications state manipulation

/**
 * @brief Final designated method which allow to modify push notifications state on set of channels
 * for device specified by \c pushToken.
 *
 * @param shouldEnabled Whether push notification should be enabled or disabled on \c channels.
 * @param channels List of channels for which notification state should be changed.
 * @param gateway Name / type of service for which channels modification should be done
 *     ('apns' or 'gcm').
 * @param token Device push token for which on specified \c channels push notifications will be
 *     enabled or disabled.
 * @param queryParameters List arbitrary query parameters which should be sent along with original
 *     API call.
 * @param block Push notifications state modification on channels completion block.
 *
 * @since 4.8.2
 */
- (void)enablePushNotification:(BOOL)shouldEnabled
                    onChannels:(nullable NSArray<NSString *> *)channels
                   withGateway:(NSString *)gateway
                   deviceToken:(id)token
               queryParameters:(nullable NSDictionary *)queryParameters
                 andCompletion:(nullable PNPushNotificationsStateModificationCompletionBlock)block;


#pragma mark - Push notifications state audit

/**
 * @brief Request for all channels on which push notification has been enabled using specified
 * \c pushToken.
 *
 * @param gateway Name / type of service for which channels audit should be done ('apns' or 'gcm').
 * @param token Device push token against which search should be performed.
 * @param queryParameters List arbitrary query parameters which should be sent along with original
 *     API call.
 *     \b Required: optional
 * @param block Push notifications status fetch completion block.
 *
 * @since 4.8.2
 */
- (void)pushNotificationEnabledChannelsForGateway:(NSString *)gateway
                                  withDeviceToken:(id)token
                                  queryParameters:(nullable NSDictionary *)queryParameters
                                    andCompletion:(PNPushNotificationsStateAuditCompletionBlock)block;

#pragma mark - 


@end

NS_ASSUME_NONNULL_END


#pragma mark - Interface implementation

@implementation PubNub (APNS)


#pragma mark - API Builder support

- (PNAPNSAPICallBuilder * (^)(void))push {
    
    PNAPNSAPICallBuilder *builder = nil; 
    builder = [PNAPNSAPICallBuilder builderWithExecutionBlock:^(NSArray<NSString *> *flags,
                                                                NSDictionary *parameters) {
        
        NSData *apnsToken = parameters[NSStringFromSelector(@selector(apnsToken))];
        NSString *fcmToken = parameters[NSStringFromSelector(@selector(fcmToken))];
        NSDictionary *queryParam = parameters[@"queryParam"];
        id block = parameters[@"block"];
        
        if ([flags containsObject:NSStringFromSelector(@selector(audit))]) {
            [self pushNotificationEnabledChannelsForGateway:(apnsToken ? @"apns" : @"gcm")
                                            withDeviceToken:(apnsToken ?: fcmToken)
                                            queryParameters:queryParam
                                              andCompletion:block];
        } else {
            NSArray<NSString *> *channels = parameters[NSStringFromSelector(@selector(channels))];
            BOOL enabling = [flags containsObject:NSStringFromSelector(@selector(enable))];
            
            [self enablePushNotification:enabling
                              onChannels:(channels.count ? channels : nil)
                             withGateway:(apnsToken ? @"apns" : @"gcm")
                             deviceToken:(apnsToken ?: fcmToken)
                         queryParameters:queryParam
                           andCompletion:block];
        }
    }];
    
    return ^PNAPNSAPICallBuilder * {
        return builder;
    };
}


#pragma mark - Push notifications state manipulation

- (void)addPushNotificationsOnChannels:(NSArray<NSString *> *)channels
                   withDevicePushToken:(NSData *)pushToken
                         andCompletion:(PNPushNotificationsStateModificationCompletionBlock)block {
    
    [self enablePushNotification:YES
                      onChannels:channels
                     withGateway:@"apns"
                     deviceToken:pushToken
                 queryParameters:nil
                   andCompletion:block];
}

- (void)removePushNotificationsFromChannels:(NSArray<NSString *> *)channels
                    withDevicePushToken:(NSData *)pushToken
                          andCompletion:(PNPushNotificationsStateModificationCompletionBlock)block {
    
    [self enablePushNotification:NO
                      onChannels:channels
                     withGateway:@"apns"
                     deviceToken:pushToken
                 queryParameters:nil
                   andCompletion:block];
}

- (void)removeAllPushNotificationsFromDeviceWithPushToken:(NSData *)pushToken
                          andCompletion:(PNPushNotificationsStateModificationCompletionBlock)block {
    
    [self enablePushNotification:NO
                      onChannels:nil
                     withGateway:@"apns"
                     deviceToken:pushToken
                 queryParameters:nil
                   andCompletion:block];
}

- (void)enablePushNotification:(BOOL)shouldEnabled
                    onChannels:(NSArray<NSString *> *)channels
                   withGateway:(NSString *)gateway
                   deviceToken:(id)token
               queryParameters:(NSDictionary *)queryParameters
                 andCompletion:(PNPushNotificationsStateModificationCompletionBlock)block{

    PNOperationType operationType = PNRemoveAllPushNotificationsOperation;
    PNRequestParameters *parameters = [PNRequestParameters new];
    BOOL removeAllChannels = !shouldEnabled && !channels.count;
    NSString *deviceToken = token;
    gateway = gateway ?: @"apns";

    [parameters addQueryParameters:@{@"type": gateway.lowercaseString}];
    [parameters addQueryParameters:queryParameters];
    
    if ([gateway.lowercaseString isEqualToString:@"apns"] && ((NSData *)token).length) {
        deviceToken = [PNData HEXFromDevicePushToken:token];
    }
    
    if (deviceToken.length) {
        [parameters addPathComponent:deviceToken.lowercaseString forPlaceholder:@"{token}"];
    }

    if (!removeAllChannels) {
        operationType = (shouldEnabled ? PNAddPushNotificationsOnChannelsOperation
                                       : PNRemovePushNotificationsFromChannelsOperation);
        
        if (channels.count) {
            [parameters addQueryParameter:[PNChannel namesForRequest:channels]
                             forFieldName:(shouldEnabled ? @"add" : @"remove")];
        } else if (operationType == PNAddPushNotificationsOnChannelsOperation) {
            [parameters removePathComponentForPlaceholder:@"{token}"];
        }

        PNLogAPICall(self.logger, @"<PubNub::API> %@ push notifications for device '%@': %@.",
            (shouldEnabled ? @"Enable" : @"Disable"),
            deviceToken.lowercaseString,
            [PNChannel namesForRequest:channels]);
    } else {
        PNLogAPICall(self.logger, @"<PubNub::API> Disable push notifications for device '%@'.",
            deviceToken.lowercaseString);
    }

    __weak __typeof(self) weakSelf = self;
    [self processOperation:operationType
            withParameters:parameters
           completionBlock:^(PNStatus *status) {

        if (status.isError) {
            status.retryBlock = ^{
                [weakSelf enablePushNotification:shouldEnabled
                                      onChannels:channels
                                     withGateway:gateway
                                     deviceToken:token
                                 queryParameters:queryParameters
                                   andCompletion:block];
            };
        }
        
        [weakSelf callBlock:block status:YES withResult:nil andStatus:status];
    }];
}


#pragma mark - Push notifications state audit

- (void)pushNotificationEnabledChannelsForDeviceWithPushToken:(NSData *)pushToken
                                 andCompletion:(PNPushNotificationsStateAuditCompletionBlock)block {

    [self pushNotificationEnabledChannelsForGateway:@"apns"
                                    withDeviceToken:pushToken
                                    queryParameters:nil
                                      andCompletion:block];
}

- (void)pushNotificationEnabledChannelsForGateway:(NSString *)gateway
                                  withDeviceToken:(id)token
                                  queryParameters:(NSDictionary *)queryParameters
                                    andCompletion:(PNPushNotificationsStateAuditCompletionBlock)block {

    PNRequestParameters *parameters = [PNRequestParameters new];
    NSString *deviceToken = token;
    gateway = gateway ?: @"apns";

    [parameters addQueryParameters:@{@"type": gateway.lowercaseString}];
    [parameters addQueryParameters:queryParameters];
    
    if ([gateway.lowercaseString isEqualToString:@"apns"] && ((NSData *)token).length) {
        deviceToken = [PNData HEXFromDevicePushToken:token];
    }
    
    if (deviceToken.length) {
        [parameters addPathComponent:deviceToken.lowercaseString forPlaceholder:@"{token}"];
    }
    
    PNLogAPICall(self.logger, @"<PubNub::API> Push notification enabled channels for device '%@'.",
        deviceToken.lowercaseString);

    __weak __typeof(self) weakSelf = self;
    [self processOperation:PNPushNotificationEnabledChannelsOperation
            withParameters:parameters
           completionBlock:^(PNResult *result, PNStatus *status) {
               
        if (status.isError) {
            status.retryBlock = ^{
                [weakSelf pushNotificationEnabledChannelsForGateway:gateway
                                                    withDeviceToken:token
                                                    queryParameters:queryParameters
                                                      andCompletion:block];
            };
        }

        [weakSelf callBlock:block status:NO withResult:result andStatus:status];
    }];
}

#pragma mark -


@end
