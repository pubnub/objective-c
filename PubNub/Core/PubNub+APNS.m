#import "PubNub+APNS.h"
#import "PNBasePushNotificationsRequest+Private.h"
#import "PNOperationResult+Private.h"
#import "PubNub+CorePrivate.h"
#import "PNStatus+Private.h"

// Deprecated
#import "PNAPICallBuilder+Private.h"


#pragma mark Interface implementation

@implementation PubNub (APNS)


#pragma mark - Push notification API builder interdace (deprecated)

- (PNAPNSAPICallBuilder * (^)(void))push {
    PNAPNSAPICallBuilder *builder = nil;
    builder = [PNAPNSAPICallBuilder builderWithExecutionBlock:^(NSArray<NSString *> *flags, NSDictionary *parameters) {
        NSArray<NSString *> *channels = parameters[NSStringFromSelector(@selector(channels))];
        NSNumber *environmentValue = parameters[NSStringFromSelector(@selector(environment))];
        NSNumber *pushTypeValue = parameters[NSStringFromSelector(@selector(pushType))];
        PNAPNSEnvironment environment = environmentValue.unsignedIntegerValue;
        NSString *topic = parameters[NSStringFromSelector(@selector(topic))];
        id token = parameters[NSStringFromSelector(@selector(token))];
        PNPushType pushType = pushTypeValue.unsignedIntegerValue;
        NSDictionary *queryParam = parameters[@"queryParam"];
        PNBasePushNotificationsRequest *request = nil;
        id block = parameters[@"block"];
        
        if ([flags containsObject:NSStringFromSelector(@selector(audit))]) {
            request = [PNPushNotificationFetchRequest requestWithDevicePushToken:token pushType:pushType];
        } else if ([flags containsObject:NSStringFromSelector(@selector(enable))]) {
            request = [PNPushNotificationManageRequest requestToAddChannels:channels
                                                           toDeviceWithToken:token
                                                                    pushType:pushType];
        } else if ([flags containsObject:NSStringFromSelector(@selector(disable))]) {
            request = [PNPushNotificationManageRequest requestToRemoveChannels:channels 
                                                            fromDeviceWithToken:token
                                                                       pushType:pushType];
        } else if ([flags containsObject:NSStringFromSelector(@selector(disableAll))]) {
            request = [PNPushNotificationManageRequest requestToRemoveDeviceWithToken:token pushType:pushType];
        }
        
        if (request) {
            request.arbitraryQueryParameters = queryParam;
            request.environment = environment;
            request.topic = topic;
            
            if ([flags containsObject:NSStringFromSelector(@selector(audit))]) {
                [self fetchPushNotificationWithRequest:(PNPushNotificationFetchRequest *)request
                                                           completion:block];
            } else {
                [self managePushNotificationWithRequest:(PNPushNotificationManageRequest *)request completion:block];
            }
        }
    }];
    
    return ^PNAPNSAPICallBuilder * {
        return builder;
    };
}


#pragma mark - Push notifications state manipulation

- (void)managePushNotificationWithRequest:(PNPushNotificationManageRequest *)userRequest
                               completion:(PNPushNotificationsStateModificationCompletionBlock)handlerBlock {
    PNOperationDataParser *responseParser = [self parserWithStatus:[PNAcknowledgmentStatus class]];
    PNPushNotificationsStateModificationCompletionBlock block = [handlerBlock copy];
    PNParsedRequestCompletionBlock handler; 

    PNOperationType operation = userRequest.operation;
    if (operation == PNRemoveAllPushNotificationsOperation || operation == PNRemoveAllPushNotificationsV2Operation) {
        PNLogAPICall(self.logger, @"<PubNub::API> Disable push notifications for device '%@'%@.",
                     userRequest.pushToken,
                     userRequest.pushType == PNAPNS2Push 
                        ? [NSString stringWithFormat:@" ('%@' topic in %@ environment)",
                           userRequest.topic, userRequest.environment == PNAPNSDevelopment ? @"development" : @"production"]
                        : @"");
    } else {
        PNLogAPICall(self.logger, @"<PubNub::API> %@ push notifications for device '%@'%@: %@.",
                     (operation == PNAddPushNotificationsOnChannelsOperation ||
                      operation == PNAddPushNotificationsOnChannelsV2Operation) ? @"Enable" : @"Disable",
                     userRequest.pushToken,
                     userRequest.pushType == PNAPNS2Push 
                        ? [NSString stringWithFormat:@" ('%@' topic in %@ environment)",
                           userRequest.topic, userRequest.environment == PNAPNSDevelopment ? @"development" : @"production"]
                        : @"",
                     [userRequest.channels componentsJoinedByString:@", "]);
    }

    PNWeakify(self);
    handler = ^(PNTransportRequest *request, id<PNTransportResponse> response, __unused NSURL *location,
                PNOperationDataParseResult<PNAcknowledgmentStatus *, PNAcknowledgmentStatus *> *result) {
        PNStrongify(self);

        if (result.status.isError) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
            result.status.retryBlock = ^{
                [self managePushNotificationWithRequest:userRequest completion:block];
            };
#pragma clang diagnostic pop
        }

        [self callBlock:block status:YES withResult:nil andStatus:result.status];
    };

    [self performRequest:userRequest withParser:responseParser completion:handler];
}

- (void)addPushNotificationsOnChannels:(NSArray<NSString *> *)channels
                   withDevicePushToken:(NSData *)pushToken
                         andCompletion:(PNPushNotificationsStateModificationCompletionBlock)block {
    [self addPushNotificationsOnChannels:channels withDevicePushToken:pushToken pushType:PNAPNSPush andCompletion:block];
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
    PNPushNotificationManageRequest *request = nil;
    request = [PNPushNotificationManageRequest requestToAddChannels:channels
                                                   toDeviceWithToken:pushToken
                                                            pushType:pushType];
    
    if (pushType == PNAPNS2Push) {
        request.environment = environment;
        request.topic = topic ?: NSBundle.mainBundle.bundleIdentifier;
    }
    
    [self managePushNotificationWithRequest:request completion:block];
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

    PNPushNotificationManageRequest *request = nil;
    request = [PNPushNotificationManageRequest requestToRemoveChannels:channels 
                                                    fromDeviceWithToken:pushToken
                                                               pushType:pushType];
    
    if (pushType == PNAPNS2Push) {
        request.environment = environment;
        request.topic = topic ?: NSBundle.mainBundle.bundleIdentifier;
    }
    
    [self managePushNotificationWithRequest:request completion:block];
}

- (void)removeAllPushNotificationsFromDeviceWithPushToken:(NSData *)pushToken
                                            andCompletion:(PNPushNotificationsStateModificationCompletionBlock)block {
    [self removeAllPushNotificationsFromDeviceWithPushToken:pushToken pushType:PNAPNSPush andCompletion:block];
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

    PNPushNotificationManageRequest *request = nil;
    request = [PNPushNotificationManageRequest requestToRemoveDeviceWithToken:pushToken pushType:pushType];
    
    if (pushType == PNAPNS2Push) {
        request.environment = environment;
        request.topic = topic ?: NSBundle.mainBundle.bundleIdentifier;
    }
    
    [self managePushNotificationWithRequest:request completion:block];
}


#pragma mark - Push notifications state audit

- (void)fetchPushNotificationWithRequest:(PNPushNotificationFetchRequest *)userRequest
                              completion:(PNPushNotificationsStateAuditCompletionBlock)handlerBlock {
    PNOperationDataParser *responseParser = [self parserWithResult:[PNAPNSEnabledChannelsResult class]
                                                            status:[PNErrorStatus class]];
    PNPushNotificationsStateAuditCompletionBlock block = [handlerBlock copy];
    PNParsedRequestCompletionBlock handler;

    PNLogAPICall(self.logger, @"<PubNub::API> Push notification enabled channels for device '%@'%@.",
                 userRequest.pushToken,
                 userRequest.pushType == PNAPNS2Push 
                    ? [NSString stringWithFormat:@" ('%@' topic in %@ environment)",
                       userRequest.topic, userRequest.environment == PNAPNSDevelopment ? @"development" : @"production"]
                    : @"");

    PNWeakify(self);
    handler = ^(PNTransportRequest *request, id<PNTransportResponse> response, __unused NSURL *location,
                PNOperationDataParseResult<PNAPNSEnabledChannelsResult *, PNErrorStatus *> *result) {
        PNStrongify(self);

        if (result.status.isError) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
            result.status.retryBlock = ^{
                [self fetchPushNotificationWithRequest:userRequest completion:block];
            };
#pragma clang diagnostic pop
        }

        [self callBlock:block status:NO withResult:result.result andStatus:result.status];
    };

    [self performRequest:userRequest withParser:responseParser completion:handler];
}

- (void)pushNotificationEnabledChannelsForDeviceWithPushToken:(NSData *)pushToken
                                                andCompletion:(PNPushNotificationsStateAuditCompletionBlock)block {
    [self pushNotificationEnabledChannelsForDeviceWithPushToken:pushToken pushType:PNAPNSPush andCompletion:block];
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
    PNPushNotificationFetchRequest *request = nil;
    request = [PNPushNotificationFetchRequest requestWithDevicePushToken:pushToken pushType:pushType];
    
    if (pushType == PNAPNS2Push) {
        request.environment = environment;
        request.topic = topic;
    }
    
    [self fetchPushNotificationWithRequest:request completion:block];
}

#pragma mark -


@end
