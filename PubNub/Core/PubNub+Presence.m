#import "PubNub+PresencePrivate.h"
#import "PNPresenceChannelGroupHereNowResult+Private.h"
#import "PNPresenceChannelHereNowResult+Private.h"
#import "PNPresenceGlobalHereNowResult+Private.h"
#import "PNPresenceHereNowFetchData+Private.h"
#import "PNBaseOperationData+Private.h"
#import "PNOperationResult+Private.h"
#import "PubNub+SubscribePrivate.h"
#import "PubNub+CorePrivate.h"
#import "PNStatus+Private.h"
#import "PNHelpers.h"

// Deprecated
#import "PNAPICallBuilder+Private.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Private interface declaration

@interface PubNub (PresenceProtected)


#pragma mark - Channel/Channel group here now

/// Request information about subscribers on specific remote data object live feeds.
///
/// - Parameters:
///   - level: One of **PNHereNowVerbosityLevel** fields to instruct what exactly data it expected in response.
///   - objects: Remote data objects for which here now information should be received.
///   - operation: One of **PNOperationType** fields to identify which kind on of presence operation should be
///   performed.
///   - queryParameters: List arbitrary query parameters which should be sent along with original API call.
///   - block: Here now fetch completion block.
- (void)hereNowWithVerbosity:(PNHereNowVerbosityLevel)level
                  forObjects:(nullable NSArray<NSString *> *)objects
           withOperationType:(PNOperationType)operation
             queryParameters:(nullable NSDictionary *)queryParameters
             completionBlock:(PNHereNowCompletionBlock)block;


#pragma mark - Client where now

/// Request information about remote data object live feeds on which client with specified UUID subscribed at this
/// moment.
///
/// - Parameters:
///   - uuid: Reference on UUID for which request should be performed.
///   - queryParameters: List arbitrary query parameters which should be sent along with original API call.
///   - block: Where now fetch completion block.
- (void)whereNowUUID:(NSString *)uuid
    withQueryParameters:(nullable NSDictionary *)queryParameters
             completion:(PNWhereNowCompletionBlock)block;


#pragma mark - Heartbeat

/// Send request to change client's presence at specified `channels` and / or `groups`.
///
/// Depending from ``connected`` flag value, heartbeat can be used for passed objects (channels / groups) to trigger
/// `join` event or use presence `leave` API to trigger `leave` event.
///
/// - Parameters:
///   - connected: Whether `join` or `leave` events should be generated for client.
///   - channels: List of ``channels`` for which client should change it's presence state according to ``connected``
///   flag value.
///   - channelGroups: List of channel `groups` for which client should change it's presence state according to ``connected`` flag value.
///   - states: Client's state which should be set for passed objects (same as state passed during subscription or using state change API).
///   - block: Client's presence modification completion block.
- (void)setConnected:(BOOL)connected
         forChannels:(nonnull NSArray<NSString *> *)channels
       channelGroups:(nonnull NSArray<NSString *> *)channelGroups
           withState:(nonnull NSDictionary<NSString*, NSDictionary *> *)states
     completionBlock:(nonnull PNStatusBlock)block;

/// List of channels which should be used with heartbeat request.
///
/// Use subscriber's and heartbeat managers information about active channels to create full list which should be passed
/// to heartbeat request.
///
/// - Returns: Full list of active channels.
- (NSArray<NSString *> *)channelsForHeartbeat;

/// List of channel groups which should be used with heartbeat request.
///
/// Use subscriber's and heartbeat managers information about active channel groups to create full list which should be
/// passed to heartbeat request.
///
/// - Returns: Full list of active channel groups.
- (NSArray<NSString *> *)channelGroupsForHeartbeat;

#pragma mark -


@end

NS_ASSUME_NONNULL_END


#pragma mark - Interface implementation

@implementation PubNub (Presence)


#pragma mark - Presence API builder interdace (deprecated)

- (PNPresenceAPICallBuilder * (^)(void))presence {
    PNPresenceAPICallBuilder *builder = nil;
    builder = [PNPresenceAPICallBuilder builderWithExecutionBlock:^(NSArray<NSString *> *flags,
                                                                    NSDictionary *parameters) {
        NSDictionary *queryParam = parameters[@"queryParam"];
        id block = parameters[@"block"];
        
        if ([flags containsObject:NSStringFromSelector(@selector(connected))]) {
            NSNumber *connected = parameters[NSStringFromSelector(@selector(connected))];
            NSArray *channels = parameters[NSStringFromSelector(@selector(channels))];
            NSArray *channelGroups = parameters[NSStringFromSelector(@selector(channelGroups))];
            NSDictionary *state = parameters[NSStringFromSelector(@selector(state))];

            [self setConnected:connected.boolValue
                   forChannels:channels
                 channelGroups:channelGroups
                     withState:state
               completionBlock:block];
        } else if ([flags containsObject:NSStringFromSelector(@selector(hereNow))]) {
            NSString *object = (parameters[NSStringFromSelector(@selector(channel))] ?:
                                parameters[NSStringFromSelector(@selector(channelGroup))]);
            NSArray<NSString *> *objects = (parameters[NSStringFromSelector(@selector(channels))] ?:
                                            parameters[NSStringFromSelector(@selector(channelGroups))]);
            PNOperationType type = PNHereNowGlobalOperation;
            PNHereNowVerbosityLevel level = PNHereNowState;
            
            if (object || objects) {
                type = PNHereNowForChannelOperation;

                if (parameters[NSStringFromSelector(@selector(channelGroup))] ||
                    parameters[NSStringFromSelector(@selector(channelGroups))]) {
                    type = PNHereNowForChannelGroupOperation;
                }
                
                if (!objects) objects = @[object];
            }
            
            if (parameters[NSStringFromSelector(@selector(verbosity))]) {
                NSNumber *verbosity = parameters[NSStringFromSelector(@selector(verbosity))];
                level = (PNHereNowVerbosityLevel)verbosity.integerValue;
            }
            
            [self hereNowWithVerbosity:level
                            forObjects:objects
                     withOperationType:type
                       queryParameters:queryParam
                       completionBlock:block];
        } else {
            NSString *uuid = parameters[NSStringFromSelector(@selector(uuid))];
            [self whereNowUUID:uuid withQueryParameters:queryParam completion:block];
        }
    }];

    return ^PNPresenceAPICallBuilder * {
        return builder;
    };
}


#pragma mark - Channel and Channel Groups presence

- (void)hereNowWithRequest:(PNHereNowRequest *)userRequest completion:(PNHereNowCompletionBlock)handleBlock {
    PNOperationDataParser *responseParser = [self parserWithResult:[PNPresenceHereNowResult class]
                                                            status:[PNErrorStatus class]];
    PNHereNowCompletionBlock block = [handleBlock copy];
    PNParsedRequestCompletionBlock handler; 

#ifndef PUBNUB_DISABLE_LOGGER
    PNHereNowVerbosityLevel level = userRequest.verbosityLevel;
    PNOperationType operation = userRequest.operation;

    if (operation == PNHereNowGlobalOperation) {
        PNLogAPICall(self.logger, @"<PubNub::API> Global 'here now' information with %@ data.",
                     PNHereNowDataStrings[level]);
    } else {
        NSString *channelsOrGroups = [userRequest.channels ?: userRequest.channelGroups componentsJoinedByString:@","];
        
        PNLogAPICall(self.logger, @"<PubNub::API> Channel%@ 'here now' information for %@ with "
                     "%@ data.", (operation == PNHereNowForChannelGroupOperation ? @" group" : @""),
                     (channelsOrGroups ?: @"<error>"), PNHereNowDataStrings[level]);
    }
#endif // PUBNUB_DISABLE_LOGGER

    PNWeakify(self);
    handler = ^(PNTransportRequest *request, id<PNTransportResponse> response, __unused NSURL *location,
                PNOperationDataParseResult<PNPresenceHereNowResult *, PNErrorStatus *> *result) {
        PNStrongify(self);

        if (result.result) {
            if (!userRequest.channelGroups.count && userRequest.channels.count == 1) {
                [result.result.data setPresenceChannel:userRequest.channels.firstObject];
            }
        }

        if (result.status.isError) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
            result.status.retryBlock = ^{
                [self hereNowWithRequest:userRequest completion:block];
            };
#pragma clang diagnostic pop
        }

        [self callBlock:block status:NO withResult:result.result andStatus:result.status];
    };

    [self performRequest:userRequest withParser:responseParser completion:handler];
}


#pragma mark - Global here now

- (void)hereNowWithCompletion:(PNGlobalHereNowCompletionBlock)block {
    [self hereNowWithVerbosity:PNHereNowState completion:block];
}

- (void)hereNowWithVerbosity:(PNHereNowVerbosityLevel)level
                  completion:(PNGlobalHereNowCompletionBlock)handlerBlock {
    PNGlobalHereNowCompletionBlock block = [handlerBlock copy];

    [self hereNowWithVerbosity:level
                    forObjects:nil
             withOperationType:PNHereNowGlobalOperation
               queryParameters:nil
               completionBlock:^(PNPresenceHereNowResult *result, PNErrorStatus *status) {
        PNPresenceGlobalHereNowResult *globalResult;
        if (result) globalResult = [PNPresenceGlobalHereNowResult legacyPresenceFromPresence:result];

        [self callBlock:block status:NO withResult:globalResult andStatus:status];
    }];
}


#pragma mark - Channel here now

- (void)hereNowForChannel:(NSString *)channel withCompletion:(PNChannelHereNowCompletionBlock)block {
    [self hereNowForChannel:channel withVerbosity:PNHereNowState completion:block];
}

- (void)hereNowForChannel:(NSString *)channel
            withVerbosity:(PNHereNowVerbosityLevel)level
               completion:(PNChannelHereNowCompletionBlock)block {
    
    [self hereNowWithVerbosity:level
                    forObjects:(channel ? @[channel] : nil)
             withOperationType:PNHereNowForChannelOperation
               queryParameters:nil
               completionBlock:^(PNPresenceHereNowResult *result, PNErrorStatus *status) {
        PNPresenceChannelHereNowResult *channelResult;
        if (result) channelResult = [PNPresenceChannelHereNowResult legacyPresenceFromPresence:result];

        [self callBlock:block status:NO withResult:channelResult andStatus:status];
    }];
}


#pragma mark - Channel group here now

- (void)hereNowForChannelGroup:(NSString *)group
                withCompletion:(PNChannelGroupHereNowCompletionBlock)block {

    [self hereNowForChannelGroup:group withVerbosity:PNHereNowState completion:block];
}

- (void)hereNowForChannelGroup:(NSString *)group
                 withVerbosity:(PNHereNowVerbosityLevel)level
                    completion:(PNChannelGroupHereNowCompletionBlock)block {
    
    [self hereNowWithVerbosity:level
                    forObjects:(group ? @[group] : nil)
             withOperationType:PNHereNowForChannelGroupOperation
               queryParameters:nil
               completionBlock:^(PNPresenceHereNowResult *result, PNErrorStatus *status) {
        PNPresenceChannelGroupHereNowResult *channelGroupResult;
        if (result) channelGroupResult = [PNPresenceChannelGroupHereNowResult legacyPresenceFromPresence:result];

        [self callBlock:block status:NO withResult:channelGroupResult andStatus:status];
    }];
}

- (void)hereNowWithVerbosity:(PNHereNowVerbosityLevel)level
                  forObjects:(NSArray<NSString *> *)objects
           withOperationType:(PNOperationType)operation
             queryParameters:(NSDictionary *)queryParameters
             completionBlock:(PNHereNowCompletionBlock)block {
    PNHereNowRequest *request = nil;
    request.verbosityLevel = level;
                 
    if (operation == PNHereNowGlobalOperation) request = [PNHereNowRequest requestGlobal];
    else if (operation == PNHereNowForChannelOperation) request = [PNHereNowRequest requestForChannels:objects];
    else if (operation == PNHereNowForChannelGroupOperation) {
        request = [PNHereNowRequest requestForChannelGroups:objects];
    }
                 
    request.arbitraryQueryParameters = queryParameters;
    request.verbosityLevel = level;
    
    [self hereNowWithRequest:request completion:block];
}


#pragma mark - Client where now

- (void)whereNowWithRequest:(PNWhereNowRequest *)userRequest completion:(PNWhereNowCompletionBlock)handleBlock {
    PNOperationDataParser *responseParser = [self parserWithResult:[PNPresenceWhereNowResult class]
                                                            status:[PNErrorStatus class]];
    PNWhereNowCompletionBlock block = [handleBlock copy];
    PNParsedRequestCompletionBlock handler;
    
#ifndef PUBNUB_DISABLE_LOGGER
    PNLogAPICall(self.logger, @"<PubNub::API> 'Where now' presence information for %@.",
                 (userRequest.userId?: @"<error>"));
#endif // PUBNUB_DISABLE_LOGGER

    PNWeakify(self);
    handler = ^(PNTransportRequest *request, id<PNTransportResponse> response, __unused NSURL *location,
                PNOperationDataParseResult<PNPresenceWhereNowResult *, PNErrorStatus *> *result) {
        PNStrongify(self);

        if (result.status.isError) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
            result.status.retryBlock = ^{
                [self whereNowWithRequest:userRequest completion:block];
            };
#pragma clang diagnostic pop
        }

        [self callBlock:block status:NO withResult:result.result andStatus:result.status];
    };

    [self performRequest:userRequest withParser:responseParser completion:handler];
}

- (void)whereNowUUID:(NSString *)uuid withCompletion:(PNWhereNowCompletionBlock)block {
    [self whereNowUUID:uuid withQueryParameters:nil completion:block];
}

- (void)whereNowUUID:(NSString *)uuid
    withQueryParameters:(NSDictionary *)queryParameters
             completion:(PNWhereNowCompletionBlock)block {
    PNWhereNowRequest *request = [PNWhereNowRequest requestForUserId:uuid];
    request.arbitraryQueryParameters = queryParameters;

    [self whereNowWithRequest:request completion:block];
}


#pragma mark - Heartbeat

- (void)setConnected:(BOOL)connected
         forChannels:(NSArray<NSString *> *)channels
       channelGroups:(NSArray<NSString *> *)channelGroups
           withState:(NSDictionary<NSString*, NSDictionary *> *)states
     completionBlock:(PNStatusBlock)block {

    PNErrorStatus *(^errorStatus)(PNStatusCategory) = ^(PNStatusCategory category) {
        PNOperationType operation = connected ? PNHeartbeatOperation : PNUnsubscribeOperation;
        PNErrorStatus *badRequestStatus = [PNErrorStatus objectWithOperation:operation
                                                                    category:category
                                                                    response:nil];
        PNWeakify(self);
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        badRequestStatus.retryBlock = ^{
            PNStrongify(self);
            [self setConnected:connected 
                   forChannels:channels
                 channelGroups:channelGroups
                     withState:states
               completionBlock:block];
        };
#pragma clang diagnostic pop
        [self updateResult:badRequestStatus withRequest:nil response:nil];

        return badRequestStatus;
    };

    if (!self.configuration.shouldManagePresenceListManually) {
        PNErrorStatus *badRequestStatus = errorStatus(PNCancelledCategory);

        [self callBlock:block status:YES withResult:nil andStatus:badRequestStatus];
        return;
    }

    NSArray *presenceChannels = [PNChannel objectsWithOutPresenceFrom:channels];
    NSArray *presenceChannelGroups = [PNChannel objectsWithOutPresenceFrom:channelGroups];
    NSMutableArray *allPresenceObjects = [NSMutableArray arrayWithArray:presenceChannels];
    [allPresenceObjects addObjectsFromArray:presenceChannelGroups];

    [self.heartbeatManager setConnected:connected forChannelGroups:presenceChannelGroups];
    [self.heartbeatManager setConnected:connected forChannels:presenceChannels];

    if (states != nil) {
        for (NSString *object in allPresenceObjects) {
            [self.clientStateManager setState:states[object] forObjects:@[object]];
        }
    }

    if (allPresenceObjects.count) {
        if (connected) {
            [self heartbeatWithCompletion:block];
            [self.heartbeatManager startHeartbeatIfRequired];
        } else {
            [self cancelSubscribeOperations];
            [self.subscriberManager unsubscribeFromChannels:presenceChannels
                                                     groups:presenceChannelGroups
                                        withQueryParameters:nil
                                      listenersNotification:NO
                                                 completion:^(PNSubscribeStatus *status) {
                if (block) block((id)status);
            }];
        }
    } else {
        PNErrorStatus *badRequestStatus = errorStatus(PNBadRequestCategory);
        [self callBlock:block status:YES withResult:nil andStatus:badRequestStatus];
    }
}

- (void)heartbeatWithRequest:(PNPresenceHeartbeatRequest *)userRequest completion:(PNStatusBlock)handleBlock {
    PNOperationDataParser *responseParser = [self parserWithStatus:[PNErrorStatus class]];
    PNStatusBlock block = [handleBlock copy];
    PNParsedRequestCompletionBlock handler;

#ifndef PUBNUB_DISABLE_LOGGER
    PNLogAPICall(self.logger, @"<PubNub::API> Heartbeat for %@%@%@.",
                 userRequest.channels.count
                 ? [NSString stringWithFormat:@"channel%@ '%@'", userRequest.channels.count > 1 ? @"s" : @"",
                    [userRequest.channels componentsJoinedByString:@", "]]
                 : @"",
                 userRequest.channels.count && userRequest.channelGroups.count ? @" and " : @"",
                 userRequest.channelGroups.count
                 ? [NSString stringWithFormat:@"group%@ '%@'", userRequest.channelGroups.count > 1 ? @"s" : @"",
                    [userRequest.channelGroups componentsJoinedByString:@", "]]
                 : @"");
#endif // PUBNUB_DISABLE_LOGGER

    PNWeakify(self);
    handler = ^(PNTransportRequest *request, id<PNTransportResponse> response, __unused NSURL *location,
                PNOperationDataParseResult<PNErrorStatus *, PNErrorStatus *> *result) {
        PNStrongify(self);

        if (result.status.isError) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
            result.status.retryBlock = ^{
                [self heartbeatWithRequest:userRequest completion:block];
            };
#pragma clang diagnostic pop
        }

        [self callBlock:block status:YES withResult:nil andStatus:result.status];
    };

    [self performRequest:userRequest withParser:responseParser completion:handler];
}

- (void)heartbeatWithCompletion:(PNStatusBlock)handlerBlock {
    NSArray *groups = [self channelGroupsForHeartbeat];
    NSArray *channels = [self channelsForHeartbeat];

    if (channels.count == 0 && groups.count == 0) {
        PNErrorStatus *status = [PNErrorStatus objectWithOperation:PNHeartbeatOperation
                                                          category:PNAcknowledgmentCategory
                                                          response:nil];
        [self callBlock:handlerBlock status:YES withResult:nil andStatus:status];

        return;
    }

    NSInteger heartbeat = self.configuration.presenceHeartbeatValue;
    PNPresenceHeartbeatRequest *request = [PNPresenceHeartbeatRequest requestWithHeartbeat:heartbeat
                                                                                  channels:channels
                                                                             channelGroups:groups];
    NSDictionary *state = [self.clientStateManager state];

    if (state.count) {
        if (self.configuration.shouldManagePresenceListManually) {
            NSMutableArray *allObjects = [NSMutableArray arrayWithArray:channels];
            [allObjects addObjectsFromArray:groups];

            // Keep state only for channels / groups specified during manual presence manipulation method.
            state = [state dictionaryWithValuesForKeys:allObjects];
        }
    }

    if (state.count > 0) request.state = state;

    [self heartbeatWithRequest:request completion:handlerBlock];
}

- (NSArray<NSString *> *)channelsForHeartbeat {
    NSArray *subscribedChannels = nil;
    
    if (self.configuration.shouldManagePresenceListManually) subscribedChannels = [self.heartbeatManager channels];
    else subscribedChannels = [self.subscriberManager channels];

    return [PNChannel objectsWithOutPresenceFrom:subscribedChannels];
}

- (NSArray<NSString *> *)channelGroupsForHeartbeat {
    NSArray *subscribedChannelGroups = nil;
    
    if (self.configuration.shouldManagePresenceListManually) {
        subscribedChannelGroups = [self.heartbeatManager channelGroups];
    } else subscribedChannelGroups = [self.subscriberManager channelGroups];
    
    return [PNChannel objectsWithOutPresenceFrom:subscribedChannelGroups];
}

#pragma mark -


@end
