/**
 @author Sergey Mamontov
 @since 4.0
 @copyright © 2009-2017 PubNub, Inc.
 */
#import "PubNub+APNS.h"
#import "PNAPICallBuilder+Private.h"
#import "PNRequestParameters.h"
#import "PubNub+CorePrivate.h"
#import "PNStatus+Private.h"
#import "PNLogMacro.h"
#import "PNKeychain.h"
#import "PNHelpers.h"


#pragma mark Static

/**
 @brief  Stores reference on key under which previous device push token is stored
         in persistent storage.
 
 @since 4.x.1
 */
static NSString * const kPNAPNSDevicePushTokenStoreKey = @"PNAPNSDevicePushToken";

NS_ASSUME_NONNULL_BEGIN

#pragma mark - Protected interface declaration

@interface PubNub (APNSProtected)


#pragma mark - Push notifications state manipulation 

/**
 @brief  Final designated method which allow to modify push notifications state on set of channels
         for device specified by \c pushToken.
 
 @param shouldEnabled Whether push notification should be enabled or disabled on \c channels.
 @param channels      List of channels for which notification state should be changed.
 @param pushToken     Reference on device push token for which on specified \c channels push notifications 
                      will be enabled or disabled.
 @param block         Push notifications state modification on channels processing completion block which pass
                      only one argument - request processing status to report about how data pushing was 
                      successful or not.
 
 @since 4.0
 */
- (void)enablePushNotification:(BOOL)shouldEnabled onChannels:(nullable NSArray<NSString *> *)channels
           withDevicePushToken:(NSData *)pushToken
                 andCompletion:(nullable PNPushNotificationsStateModificationCompletionBlock)block;


#pragma mark - Misc

/**
 @brief      Receive device push token stored in persistent storage.
 @discussion Try to receive device push token which has been during previous channels registration
             from Keychain storage.
 
 @since 4.x.1
 */
- (NSData *)storedDevicePushToken;

#pragma mark - 


@end

NS_ASSUME_NONNULL_END


#pragma mark - Interface implementation

@implementation PubNub (APNS)


#pragma mark - API Builder support

- (PNAPNSAPICallBuilder *(^)(void))push {
    
    PNAPNSAPICallBuilder *builder = nil; 
    builder = [PNAPNSAPICallBuilder builderWithExecutionBlock:^(NSArray<NSString *> *flags, 
                                                                NSDictionary *parameters) {
        
        NSData *pushToken = parameters[NSStringFromSelector(@selector(token))];
        id block = parameters[@"block"];
        if ([flags containsObject:NSStringFromSelector(@selector(audit))]) {
            
            [self pushNotificationEnabledChannelsForDeviceWithPushToken:pushToken andCompletion:block];
        }
        else {
            
            NSArray<NSString *> *channels = parameters[NSStringFromSelector(@selector(channels))];
            BOOL enabling = [flags containsObject:NSStringFromSelector(@selector(enable))];
            [self enablePushNotification:enabling onChannels:(channels.count ? channels : nil)
                     withDevicePushToken:pushToken andCompletion:block];
        }
    }];
    
    return ^PNAPNSAPICallBuilder *{ return builder; };
}


#pragma mark - Push notifications state manipulation

- (void)addPushNotificationsOnChannels:(NSArray<NSString *> *)channels withDevicePushToken:(NSData *)pushToken
                         andCompletion:(PNPushNotificationsStateModificationCompletionBlock)block {
    
    [self enablePushNotification:YES onChannels:channels withDevicePushToken:pushToken andCompletion:block];
}

- (void)removePushNotificationsFromChannels:(NSArray<NSString *> *)channels
                        withDevicePushToken:(NSData *)pushToken
                              andCompletion:(PNPushNotificationsStateModificationCompletionBlock)block {
    
    [self enablePushNotification:NO onChannels:channels withDevicePushToken:pushToken andCompletion:block];
}

- (void)removeAllPushNotificationsFromDeviceWithPushToken:(NSData *)pushToken
                          andCompletion:(PNPushNotificationsStateModificationCompletionBlock)block {
    
    [self enablePushNotification:NO onChannels:nil withDevicePushToken:pushToken andCompletion:block];
}

- (void)enablePushNotification:(BOOL)shouldEnabled onChannels:(NSArray<NSString *> *)channels
           withDevicePushToken:(NSData *)pushToken
                 andCompletion:(PNPushNotificationsStateModificationCompletionBlock)block {

    BOOL removeAllChannels = (!shouldEnabled && !channels.count);
    PNOperationType operationType = PNRemoveAllPushNotificationsOperation;
    PNRequestParameters *parameters = [PNRequestParameters new];
    if (pushToken.length) {

        [parameters addPathComponent:[PNData HEXFromDevicePushToken:pushToken].lowercaseString
                      forPlaceholder:@"{token}"];
    }

    if (!removeAllChannels){

        operationType = (shouldEnabled ? PNAddPushNotificationsOnChannelsOperation :
                         PNRemovePushNotificationsFromChannelsOperation);
        if ([channels count]) {

            [parameters addQueryParameter:[PNChannel namesForRequest:channels]
                             forFieldName:(shouldEnabled ? @"add":@"remove")];
            if (operationType == PNAddPushNotificationsOnChannelsOperation) {
                
                NSData *previousPushToken = [self storedDevicePushToken];
                if (previousPushToken && ![pushToken isEqual:previousPushToken]) {
                    
                    [parameters addQueryParameter:[[PNData HEXFromDevicePushToken:previousPushToken] lowercaseString]
                                     forFieldName:@"old_token"];
                }
            }
        }
        else if (operationType == PNAddPushNotificationsOnChannelsOperation) {
            
            [parameters removePathComponentForPlaceholder:@"{token}"];
        }

        DDLogAPICall(self.logger, @"<PubNub::API> %@ push notifications for device '%@': %@.",
                     (shouldEnabled ? @"Enable" : @"Disable"), 
                     [PNData HEXFromDevicePushToken:pushToken].lowercaseString, 
                     [PNChannel namesForRequest:channels]);
    }
    else {

        DDLogAPICall(self.logger, @"<PubNub::API> Disable push notifications for device '%@'.",
                     [[PNData HEXFromDevicePushToken:pushToken] lowercaseString]);
    }

    __weak __typeof(self) weakSelf = self;
    [self processOperation:operationType withParameters:parameters completionBlock:^(PNStatus *status){

        // Silence static analyzer warnings.
        // Code is aware about this case and at the end will simply call on 'nil' object method.
        // In most cases if referenced object become 'nil' it mean what there is no more need in
        // it and probably whole client instance has been deallocated.
        #pragma clang diagnostic push
        #pragma clang diagnostic ignored "-Wreceiver-is-weak"
        if (status.isError) {
            
            status.retryBlock = ^{
                
                [weakSelf enablePushNotification:shouldEnabled onChannels:channels
                             withDevicePushToken:pushToken andCompletion:block];
            };
        }
        else if (operationType == PNAddPushNotificationsOnChannelsOperation) {
            
            [PNKeychain storeValue:pushToken forKey:kPNAPNSDevicePushTokenStoreKey
               withCompletionBlock:NULL];
        }
        [weakSelf callBlock:block status:YES withResult:nil andStatus:status];
        #pragma clang diagnostic pop
    }];
}


#pragma mark - Push notifications state audit

- (void)pushNotificationEnabledChannelsForDeviceWithPushToken:(NSData *)pushToken
                                 andCompletion:(PNPushNotificationsStateAuditCompletionBlock)block {

    PNRequestParameters *parameters = [PNRequestParameters new];
    if (pushToken.length) {

        [parameters addPathComponent:[PNData HEXFromDevicePushToken:pushToken].lowercaseString
                      forPlaceholder:@"{token}"];
    }

    DDLogAPICall(self.logger, @"<PubNub::API> Push notification enabled channels for device '%@'.",
                 [PNData HEXFromDevicePushToken:pushToken].lowercaseString);

    __weak __typeof(self) weakSelf = self;
    [self processOperation:PNPushNotificationEnabledChannelsOperation withParameters:parameters
           completionBlock:^(PNResult *result, PNStatus *status){

               // Silence static analyzer warnings.
               // Code is aware about this case and at the end will simply call on 'nil' object
               // method. In most cases if referenced object become 'nil' it mean what there is no
               // more need in it and probably whole client instance has been deallocated.
               #pragma clang diagnostic push
               #pragma clang diagnostic ignored "-Wreceiver-is-weak"
               if (status.isError) {
                    
                   status.retryBlock = ^{
                        
                       [weakSelf pushNotificationEnabledChannelsForDeviceWithPushToken:pushToken
                                                                         andCompletion:block];
                   };
               }
               [weakSelf callBlock:block status:NO withResult:result andStatus:status];
               #pragma clang diagnostic pop
           }];
}


#pragma mark - Misc

- (NSData *)storedDevicePushToken {
    
    __block NSData *token = nil;
    [PNKeychain valueForKey:kPNAPNSDevicePushTokenStoreKey withCompletionBlock:^(id value) {
        
        if ([value isKindOfClass:NSString.class]) {
            
            token = [(NSString *)value dataUsingEncoding:NSUTF8StringEncoding];
        }
        else if ([value isKindOfClass:NSData.class]){ token = value; }
    }];
    
    return token;
}

#pragma mark -


@end
