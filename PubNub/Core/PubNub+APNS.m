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


#pragma mark Static

/**
 * @brief Name of key under which previous device push token is stored in persistent storage.
 *
 * @since 4.x.1
 */
static NSString * const kPNAPNSDevicePushTokenStoreKey = @"PNAPNSDevicePushToken";


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
           withDevicePushToken:(NSData *)token
               queryParameters:(nullable NSDictionary *)queryParameters
                 andCompletion:(nullable PNPushNotificationsStateModificationCompletionBlock)block;


#pragma mark - Push notifications state audit

/**
 * @brief Request for all channels on which push notification has been enabled using specified
 * \c pushToken.
 *
 * @param pushToken Device push token against which search should be performed.
 * @param queryParameters List arbitrary query parameters which should be sent along with original
 *     API call.
 *     \b Required: optional
 * @param block Push notifications status fetch completion block.
 *
 * @since 4.8.2
 */
- (void)pushNotificationEnabledChannelsForDeviceWithPushToken:(NSData *)pushToken
                               queryParameters:(nullable NSDictionary *)queryParameters
                                 andCompletion:(PNPushNotificationsStateAuditCompletionBlock)block;


#pragma mark - Misc

/**
 * @brief Receive device push token stored in persistent storage.
 *
 * @discussion Try to receive device push token which has been during previous channels registration
 * from Keychain storage.
 *
 * @since 4.x.1
 */
- (NSData *)storedDevicePushToken;

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
        
        NSData *pushToken = parameters[NSStringFromSelector(@selector(token))];
        NSDictionary *queryParam = parameters[@"queryParam"];
        id block = parameters[@"block"];
        
        if ([flags containsObject:NSStringFromSelector(@selector(audit))]) {
            [self pushNotificationEnabledChannelsForDeviceWithPushToken:pushToken
                                                        queryParameters:queryParam
                                                          andCompletion:block];
        } else {
            NSArray<NSString *> *channels = parameters[NSStringFromSelector(@selector(channels))];
            BOOL enabling = [flags containsObject:NSStringFromSelector(@selector(enable))];
            
            [self enablePushNotification:enabling
                              onChannels:(channels.count ? channels : nil)
                     withDevicePushToken:pushToken
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
             withDevicePushToken:pushToken
                 queryParameters:nil
                   andCompletion:block];
}

- (void)removePushNotificationsFromChannels:(NSArray<NSString *> *)channels
                    withDevicePushToken:(NSData *)pushToken
                          andCompletion:(PNPushNotificationsStateModificationCompletionBlock)block {
    
    [self enablePushNotification:NO
                      onChannels:channels
             withDevicePushToken:pushToken
                 queryParameters:nil
                   andCompletion:block];
}

- (void)removeAllPushNotificationsFromDeviceWithPushToken:(NSData *)pushToken
                          andCompletion:(PNPushNotificationsStateModificationCompletionBlock)block {
    
    [self enablePushNotification:NO
                      onChannels:nil
             withDevicePushToken:pushToken
                 queryParameters:nil
                   andCompletion:block];
}

- (void)enablePushNotification:(BOOL)shouldEnabled
                    onChannels:(NSArray<NSString *> *)channels
           withDevicePushToken:(NSData *)token
               queryParameters:(NSDictionary *)queryParameters
                 andCompletion:(PNPushNotificationsStateModificationCompletionBlock)block {

    PNOperationType operationType = PNRemoveAllPushNotificationsOperation;
    PNRequestParameters *parameters = [PNRequestParameters new];
    BOOL removeAllChannels = !shouldEnabled && !channels.count;

    [parameters addQueryParameters:queryParameters];
    
    if (token.length) {
        NSString *tokenHEX = [PNData HEXFromDevicePushToken:token].lowercaseString;

        [parameters addPathComponent:tokenHEX forPlaceholder:@"{token}"];
    }

    if (!removeAllChannels) {
        operationType = (shouldEnabled ? PNAddPushNotificationsOnChannelsOperation
                                       : PNRemovePushNotificationsFromChannelsOperation);
        
        if (channels.count) {
            [parameters addQueryParameter:[PNChannel namesForRequest:channels]
                             forFieldName:(shouldEnabled ? @"add" : @"remove")];
            
            if (operationType == PNAddPushNotificationsOnChannelsOperation) {
                NSData *oldToken = [self storedDevicePushToken];
                
                if (oldToken && ![token isEqual:oldToken]) {
                    NSString *tokenHEX = [PNData HEXFromDevicePushToken:oldToken].lowercaseString;

                    [parameters addQueryParameter:tokenHEX forFieldName:@"old_token"];
                }
            }
        } else if (operationType == PNAddPushNotificationsOnChannelsOperation) {
            [parameters removePathComponentForPlaceholder:@"{token}"];
        }

        PNLogAPICall(self.logger, @"<PubNub::API> %@ push notifications for device '%@': %@.",
            (shouldEnabled ? @"Enable" : @"Disable"),
            [PNData HEXFromDevicePushToken:token].lowercaseString,
            [PNChannel namesForRequest:channels]);
    } else {
        PNLogAPICall(self.logger, @"<PubNub::API> Disable push notifications for device '%@'.",
            [[PNData HEXFromDevicePushToken:token] lowercaseString]);
    }

    __weak __typeof(self) weakSelf = self;
    [self processOperation:operationType
            withParameters:parameters
           completionBlock:^(PNStatus *status) {

        if (status.isError) {
            status.retryBlock = ^{
                [weakSelf enablePushNotification:shouldEnabled
                                      onChannels:channels
                             withDevicePushToken:token
                                 queryParameters:queryParameters
                                   andCompletion:block];
            };
        } else if (operationType == PNAddPushNotificationsOnChannelsOperation) {
            [PNKeychain storeValue:token
                            forKey:kPNAPNSDevicePushTokenStoreKey
               withCompletionBlock:NULL];
        }
        
        [weakSelf callBlock:block status:YES withResult:nil andStatus:status];
    }];
}


#pragma mark - Push notifications state audit

- (void)pushNotificationEnabledChannelsForDeviceWithPushToken:(NSData *)pushToken
                                 andCompletion:(PNPushNotificationsStateAuditCompletionBlock)block {

    [self pushNotificationEnabledChannelsForDeviceWithPushToken:pushToken
                                                queryParameters:nil
                                                  andCompletion:block];
}

- (void)pushNotificationEnabledChannelsForDeviceWithPushToken:(NSData *)pushToken
                               queryParameters:(NSDictionary *)queryParameters
                                 andCompletion:(PNPushNotificationsStateAuditCompletionBlock)block {

    PNRequestParameters *parameters = [PNRequestParameters new];

    [parameters addQueryParameters:queryParameters];
    
    if (pushToken.length) {
        [parameters addPathComponent:[PNData HEXFromDevicePushToken:pushToken].lowercaseString
                      forPlaceholder:@"{token}"];
    }

    PNLogAPICall(self.logger, @"<PubNub::API> Push notification enabled channels for device '%@'.",
        [PNData HEXFromDevicePushToken:pushToken].lowercaseString);

    __weak __typeof(self) weakSelf = self;
    [self processOperation:PNPushNotificationEnabledChannelsOperation
            withParameters:parameters
           completionBlock:^(PNResult *result, PNStatus *status) {
               
        if (status.isError) {
            status.retryBlock = ^{
                [weakSelf pushNotificationEnabledChannelsForDeviceWithPushToken:pushToken
                                                                queryParameters:queryParameters
                                                                  andCompletion:block];
            };
        }

        [weakSelf callBlock:block status:NO withResult:result andStatus:status];
    }];
}


#pragma mark - Misc

- (NSData *)storedDevicePushToken {
    
    __block NSData *token = nil;

    [PNKeychain valueForKey:kPNAPNSDevicePushTokenStoreKey withCompletionBlock:^(id value) {
        if ([value isKindOfClass:NSString.class]) {
            token = [(NSString *)value dataUsingEncoding:NSUTF8StringEncoding];
        } else if ([value isKindOfClass:NSData.class]) {
            token = value;
        }
    }];
    
    return token;
}

#pragma mark -


@end
