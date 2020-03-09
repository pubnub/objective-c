
/**
 * @author Serhii Mamontov
 * @version 4.12.0
 * @since 4.0.0
 * @copyright © 2010-2019 PubNub, Inc.
 */
#import "PubNub+APNS.h"
#import "PNAPICallBuilder+Private.h"
#import "PNAcknowledgmentStatus.h"
#import "PNRequestParameters.h"
#import "PubNub+CorePrivate.h"
#import "PNStatus+Private.h"
#import "PNErrorStatus.h"
#import "PNKeychain.h"
#import "PNHelpers.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Private interface declaration

@interface PubNub (APNSProtected)


#pragma mark - Push notifications state manipulation

/**
 * @brief Enable push notifications (sent using legacy APNs or APNs over HTTP/2) on provided set of
 * \c channels.
 *
 * @code
 * PNAddPushNotificationsRequest *request = nil;
 * request = [PNAddPushNotificationsRequest requestWithDevicePushToken:self.devicePushToken
 *                                                            pushType:PNAPNSPush];
 * request.channels = @[@"wwdc",@"google.io"];
 *
 * [self.client addPushNotificationsWithRequest:request
 *                                   completion:^(PNAcknowledgmentStatus *status) {
 *
 *     if (!status.isError) {
 *        // Push notifications successful enabled on passed channels.
 *     } else {
 *        // Handle modification error. Check 'category' property to find out possible issue because
 *        // of which request did fail.
 *        //
 *        // Request can be resent using: [status retry];
 *     }
 * }];
 * @endcode
 *
 * @param request \c Add \c notifications \c for \c channels request with information required to
 *     enable notifications on \c channels.
 * @param block \c Add \c notifications \c for \c channels request completion block.
 *
 * @since 4.12.0
 */
- (void)addPushNotificationsWithRequest:(PNAddPushNotificationsRequest *)request
                     completion:(nullable PNPushNotificationsStateModificationCompletionBlock)block;

/**
 * @brief Disable push notifications (sent using legacy APNs or APNs over HTTP/2) on provided set of
 * \c channels.
 *
 * @code
 * PNRemovePushNotificationsRequest *request = nil;
 * request = [PNRemovePushNotificationsRequest requestWithDevicePushToken:self.devicePushToken
 *                                                               pushType:PNAPNSPush];
 * request.channels = @[@"wwdc",@"google.io"];
 *
 * [self.client removePushNotificationsWithRequest:request
 *                                      completion:^(PNAcknowledgmentStatus *status) {
 *
 *     if (!status.isError) {
 *        // Push notification successfully disabled on passed channels.
 *     } else {
 *        // Handle modification error. Check 'category' property to find out possible issue because
 *        // of which request did fail.
 *        //
 *        // Request can be resent using: [status retry];
 *     }
 * }];
 * @endcode
 *
 * @param request \c Remove \c notifications \c from \c channels request with information required
 *     to disable notifications for \c channels.
 * @param block \c Remove \c notifications \c from \c channels request completion block.
 *
 * @since 4.12.0
 */
- (void)removePushNotificationsWithRequest:(PNRemovePushNotificationsRequest *)request
                     completion:(nullable PNPushNotificationsStateModificationCompletionBlock)block;

/**
 * @brief Disable push notifications (sent using legacy APNs or APNs over HTTP/2) from all channels
 * which is registered with specified \c pushToken.
 *
 * @code
 * PNRemoveAllPushNotificationsRequest *request = nil;
 * request = [PNRemoveAllPushNotificationsRequest requestWithDevicePushToken:self.devicePushToken
 *                                                                  pushType:PNAPNS2Push];
 * request.topic = @"com.my-application.bundle";
 * request.environment = PNAPNSProduction;
 *
 * [self.client removeAllPushNotificationsWithRequest:request
 *                                         completion:^(PNAcknowledgmentStatus *status) {
 *
 *     if (!status.isError) {
 *        // Handle successful push notification disabling for all channels associated with
 *        // specified device push token.
 *     } else {
 *        // Handle modification error. Check 'category' property to find out possible issue because
 *        // of which request did fail.
 *        //
 *        // Request can be resent using: [status retry];
 *     }
 * }];
 * @endcode
 *
 * @param request \c Remove \c all \c notifications request with information required to disable
 *     notifications for \c device.
 * @param block \c Remove \c all \c notifications request completion block.
 *
 * @since 4.12.0
 */
- (void)removeAllPushNotificationsWithRequest:(PNRemoveAllPushNotificationsRequest *)request
                     completion:(nullable PNPushNotificationsStateModificationCompletionBlock)block;


#pragma mark - Push notifications state audit

/**
 * @brief Request for all channels on which push notification (sent using legacy APNs or APNs over
 * HTTP/2) has been enabled using specified \c pushToken.
 *
 * @code
 * PNAuditPushNotificationsRequest *request = nil;
 * request = [PNAuditPushNotificationsRequest requestWithDevicePushToken:self.devicePushToken
 *                                                              pushType:PNAPNS2Push];
 * request.topic = @"com.my-application.bundle";
 * request.environment = PNAPNSProduction;
 *
 * [self.client pushNotificationEnabledChannelsWithRequest:request
 *                     andCompletion:^(PNAPNSEnabledChannelsResult *result, PNErrorStatus *status) {
 *
 *     if (!status.isError) {
 *        // Handle downloaded list of channels using: result.data.channels
 *     } else {
 *        // Handle audition error. Check 'category' property to find out possible issue because of
 *        // which request did fail.
 *        //
 *        // Request can be resent using: [status retry];
 *     }
 * }];
 * @endcode
 *
 * @param request \c Audit \c notifications \c enabled \c channels request with information required
 *     to retrieve channels with enabled notifications.
 * @param block \c Audit \c notifications \c enabled \c channels request completion block.
 *
 * @since 4.12.0
 */
- (void)pushNotificationEnabledChannelsWithRequest:(PNAuditPushNotificationsRequest *)request
                                     completion:(PNPushNotificationsStateAuditCompletionBlock)block;


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

        NSArray<NSString *> *channels = parameters[NSStringFromSelector(@selector(channels))];
        NSNumber *environmentValue = parameters[NSStringFromSelector(@selector(environment))];
        NSNumber *pushTypeValue = parameters[NSStringFromSelector(@selector(pushType))];
        PNAPNSEnvironment environment = environmentValue.unsignedIntegerValue;
        NSString *topic = parameters[NSStringFromSelector(@selector(topic))];
        id token = parameters[NSStringFromSelector(@selector(token))];
        PNPushType pushType = pushTypeValue.unsignedIntegerValue;
        NSDictionary *queryParam = parameters[@"queryParam"];
        id block = parameters[@"block"];
        
        if ([flags containsObject:NSStringFromSelector(@selector(audit))]) {
            PNAuditPushNotificationsRequest *request = nil;
            request = [PNAuditPushNotificationsRequest requestWithDevicePushToken:token
                                                                         pushType:pushType];
            request.arbitraryQueryParameters = queryParam;
            request.environment = environment;
            request.topic = topic;
            
            [self pushNotificationEnabledChannelsWithRequest:request completion:block];
        } else if ([flags containsObject:NSStringFromSelector(@selector(enable))]) {
            PNAddPushNotificationsRequest *request = nil;
            request = [PNAddPushNotificationsRequest requestWithDevicePushToken:token
                                                                       pushType:pushType];
            request.arbitraryQueryParameters = queryParam;
            request.environment = environment;
            request.channels = channels;
            request.topic = topic;
            
            [self addPushNotificationsWithRequest:request completion:block];
        } else if ([flags containsObject:NSStringFromSelector(@selector(disable))]) {
            PNRemovePushNotificationsRequest *request = nil;
            request = [PNRemovePushNotificationsRequest requestWithDevicePushToken:token
                                                                          pushType:pushType];
            request.arbitraryQueryParameters = queryParam;
            request.environment = environment;
            request.channels = channels;
            request.topic = topic;
            
            [self removePushNotificationsWithRequest:request completion:block];
        } else if ([flags containsObject:NSStringFromSelector(@selector(disableAll))]) {
            PNRemoveAllPushNotificationsRequest *request = nil;
            request = [PNRemoveAllPushNotificationsRequest requestWithDevicePushToken:token
                                                                             pushType:pushType];
            request.arbitraryQueryParameters = queryParam;
            request.environment = environment;
            request.topic = topic;
            
            [self removeAllPushNotificationsWithRequest:request completion:block];
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
    
    [self addPushNotificationsOnChannels:channels
                     withDevicePushToken:pushToken
                                pushType:PNAPNSPush
                           andCompletion:block];
}

- (void)addPushNotificationsOnChannels:(NSArray<NSString *> *)channels
                   withDevicePushToken:(id)pushToken
                              pushType:(PNPushType)pushType
                         andCompletion:(PNPushNotificationsStateModificationCompletionBlock)block {
    
    [self addPushNotificationsOnChannels:channels
                     withDevicePushToken:pushToken
                                pushType:pushType
                             environment:PNAPNSDevelopment
                                   topic:NSBundle.mainBundle.bundleIdentifier
                           andCompletion:block];
}
 
- (void)addPushNotificationsOnChannels:(NSArray<NSString *> *)channels
                   withDevicePushToken:(id)pushToken
                              pushType:(PNPushType)pushType
                           environment:(PNAPNSEnvironment)environment
                                 topic:(NSString *)topic
                         andCompletion:(PNPushNotificationsStateModificationCompletionBlock)block {

    PNAddPushNotificationsRequest *request = nil;
    request = [PNAddPushNotificationsRequest requestWithDevicePushToken:pushToken
                                                               pushType:pushType];
    request.channels = channels;
    
    if (pushType == PNAPNS2Push) {
        request.environment = environment;
        request.topic = topic;
    }
    
    [self addPushNotificationsWithRequest:request completion:block];
}

- (void)addPushNotificationsWithRequest:(PNAddPushNotificationsRequest *)request
                     completion:(PNPushNotificationsStateModificationCompletionBlock)block {

    PNLogAPICall(self.logger, @"<PubNub::API> Enable push notifications for device '%@'%@: %@.",
                 request.pushToken,
                 request.pushType == PNAPNS2Push ? [NSString stringWithFormat:@" ('%@' topic in %@ environment)",
                                                    request.topic,
                                                    request.environment == PNAPNSDevelopment ? @"development" : @"production"]
                                                 : @"",
                 [PNChannel namesForRequest:request.channels]);
    
    __weak __typeof(self) weakSelf = self;
    
    [self performRequest:request withCompletion:^(PNAcknowledgmentStatus *status) {
        if (status.isError) {
            status.retryBlock = ^{
                [weakSelf addPushNotificationsWithRequest:request completion:block];
            };
        }

        block(status);
    }];
}

- (void)removePushNotificationsFromChannels:(NSArray<NSString *> *)channels
                    withDevicePushToken:(NSData *)pushToken
                          andCompletion:(PNPushNotificationsStateModificationCompletionBlock)block {
    
    [self removePushNotificationsFromChannels:channels
                          withDevicePushToken:pushToken
                                     pushType:PNAPNSPush
                                andCompletion:block];
}

- (void)removePushNotificationsFromChannels:(NSArray<NSString *> *)channels
                    withDevicePushToken:(id)pushToken
                               pushType:(PNPushType)pushType
                          andCompletion:(PNPushNotificationsStateModificationCompletionBlock)block {
    
    [self removePushNotificationsFromChannels:channels
                          withDevicePushToken:pushToken
                                     pushType:pushType
                                  environment:PNAPNSDevelopment
                                        topic:NSBundle.mainBundle.bundleIdentifier
                                andCompletion:block];
}

- (void)removePushNotificationsFromChannels:(NSArray<NSString *> *)channels
                    withDevicePushToken:(id)pushToken
                               pushType:(PNPushType)pushType
                            environment:(PNAPNSEnvironment)environment
                                  topic:(NSString *)topic
                          andCompletion:(PNPushNotificationsStateModificationCompletionBlock)block {

    PNRemovePushNotificationsRequest *request = nil;
    request = [PNRemovePushNotificationsRequest requestWithDevicePushToken:pushToken
                                                                  pushType:pushType];
    request.channels = channels;
    
    if (pushType == PNAPNS2Push) {
        request.environment = environment;
        request.topic = topic;
    }
    
    [self removePushNotificationsWithRequest:request completion:block];
}

- (void)removePushNotificationsWithRequest:(PNRemovePushNotificationsRequest *)request
                             completion:(PNPushNotificationsStateModificationCompletionBlock)block {
    
    PNLogAPICall(self.logger, @"<PubNub::API> Disable push notifications for device '%@'%@: %@.",
                 request.pushToken,
                 request.pushType == PNAPNS2Push ? [NSString stringWithFormat:@" ('%@' topic in %@ environment)",
                                                    request.topic,
                                                    request.environment == PNAPNSDevelopment ? @"development" : @"production"]
                                                 : @"",
                 [PNChannel namesForRequest:request.channels]);
    
    __weak __typeof(self) weakSelf = self;
    
    [self performRequest:request withCompletion:^(PNAcknowledgmentStatus *status) {
        if (status.isError) {
            status.retryBlock = ^{
                [weakSelf removePushNotificationsWithRequest:request completion:block];
            };
        }

        block(status);
    }];
}

- (void)removeAllPushNotificationsFromDeviceWithPushToken:(NSData *)pushToken
                          andCompletion:(PNPushNotificationsStateModificationCompletionBlock)block {

    [self removeAllPushNotificationsFromDeviceWithPushToken:pushToken
                                                   pushType:PNAPNSPush
                                              andCompletion:block];
}

- (void)removeAllPushNotificationsFromDeviceWithPushToken:(id)pushToken
                               pushType:(PNPushType)pushType
                          andCompletion:(PNPushNotificationsStateModificationCompletionBlock)block {
    
    [self removeAllPushNotificationsFromDeviceWithPushToken:pushToken
                                                   pushType:pushType
                                                environment:PNAPNSDevelopment
                                                      topic:NSBundle.mainBundle.bundleIdentifier
                                              andCompletion:block];
}

- (void)removeAllPushNotificationsFromDeviceWithPushToken:(id)pushToken
                               pushType:(PNPushType)pushType
                            environment:(PNAPNSEnvironment)environment
                                  topic:(NSString *)topic
                          andCompletion:(PNPushNotificationsStateModificationCompletionBlock)block {

    PNRemoveAllPushNotificationsRequest *request = nil;
    request = [PNRemoveAllPushNotificationsRequest requestWithDevicePushToken:pushToken
                                                                     pushType:pushType];
    
    if (pushType == PNAPNS2Push) {
        request.environment = environment;
        request.topic = topic;
    }
    
    [self removeAllPushNotificationsWithRequest:request completion:block];
}

- (void)removeAllPushNotificationsWithRequest:(PNRemoveAllPushNotificationsRequest *)request
                             completion:(PNPushNotificationsStateModificationCompletionBlock)block {
    
    PNLogAPICall(self.logger, @"<PubNub::API> Disable push notifications for device '%@'%@.",
                 request.pushToken,
                 request.pushType == PNAPNS2Push ? [NSString stringWithFormat:@" ('%@' topic in %@ environment)",
                                                    request.topic,
                                                    request.environment == PNAPNSDevelopment ? @"development" : @"production"]
                                                 : @"");
    
    __weak __typeof(self) weakSelf = self;
    
    [self performRequest:request withCompletion:^(PNAcknowledgmentStatus *status) {
        if (status.isError) {
            status.retryBlock = ^{
                [weakSelf removeAllPushNotificationsWithRequest:request completion:block];
            };
        }

        block(status);
    }];
}


#pragma mark - Push notifications state audit

- (void)pushNotificationEnabledChannelsForDeviceWithPushToken:(NSData *)pushToken
                                 andCompletion:(PNPushNotificationsStateAuditCompletionBlock)block {

    [self pushNotificationEnabledChannelsForDeviceWithPushToken:pushToken
                                                       pushType:PNAPNSPush
                                                  andCompletion:block];
}

- (void)pushNotificationEnabledChannelsForDeviceWithPushToken:(id)pushToken
                                      pushType:(PNPushType)pushType
                                 andCompletion:(PNPushNotificationsStateAuditCompletionBlock)block {
    
    [self pushNotificationEnabledChannelsForDeviceWithPushToken:pushToken
                                                       pushType:pushType
                                                    environment:PNAPNSDevelopment
                                                          topic:NSBundle.mainBundle.bundleIdentifier
                                                  andCompletion:block];
}

- (void)pushNotificationEnabledChannelsForDeviceWithPushToken:(id)pushToken
                                      pushType:(PNPushType)pushType
                                   environment:(PNAPNSEnvironment)environment
                                         topic:(NSString *)topic
                                 andCompletion:(PNPushNotificationsStateAuditCompletionBlock)block {

    PNAuditPushNotificationsRequest *request = nil;
    request = [PNAuditPushNotificationsRequest requestWithDevicePushToken:pushToken
                                                                 pushType:pushType];
    
    if (pushType == PNAPNS2Push) {
        request.environment = environment;
        request.topic = topic;
    }
    
    [self pushNotificationEnabledChannelsWithRequest:request completion:block];
}

- (void)pushNotificationEnabledChannelsWithRequest:(PNAuditPushNotificationsRequest *)request
                                    completion:(PNPushNotificationsStateAuditCompletionBlock)block {

    PNLogAPICall(self.logger, @"<PubNub::API> Push notification enabled channels for device '%@'%@.",
                 request.pushToken,
                 request.pushType == PNAPNS2Push ? [NSString stringWithFormat:@" ('%@' topic in %@ environment)",
                                                    request.topic,
                                                    request.environment == PNAPNSDevelopment ? @"development" : @"production"]
                                                 : @"");
    
    __weak __typeof(self) weakSelf = self;
    
    [self performRequest:request
          withCompletion:^(PNAPNSEnabledChannelsResult *result, PNErrorStatus *status) {
              
        if (status.isError) {
            status.retryBlock = ^{
                [weakSelf pushNotificationEnabledChannelsWithRequest:request completion:block];
            };
        }

        block(result, status);
    }];
}

#pragma mark -


@end
