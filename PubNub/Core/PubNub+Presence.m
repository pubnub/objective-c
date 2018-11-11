/**
 * @author Serhii Mamontov
 * @since 4.0
 * @copyright © 2010-2018 PubNub, Inc.
 */
#import "PubNub+PresencePrivate.h"
#import "PNAPICallBuilder+Private.h"
#import "PubNub+SubscribePrivate.h"
#import "PNPrivateStructures.h"
#import "PNRequestParameters.h"
#import "PubNub+CorePrivate.h"
#import "PNStatus+Private.h"
#import "PNConfiguration.h"
#import "PNLogMacro.h"
#import "PNHelpers.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Protected interface declaration

@interface PubNub (PresenceProtected)


#pragma mark - Channel/Channel group here now

/**
 * @brief Request information about subscribers on specific remote data object live feeds.
 *
 * @param level One of \b PNHereNowVerbosityLevel fields to instruct what exactly data it expected
 *     in response.
 * @param object Remote data object for which here now information should be received.
 * @param operation One of \b PNOperationType fields to identify which kind on of presence operation
 *     should be performed.
 * @param queryParameters List arbitrary query parameters which should be sent along with original
 *     API call.
 * @param block Here now fetch completion block.
 *
 * @since 4.8.2
 */
- (void)hereNowWithVerbosity:(PNHereNowVerbosityLevel)level
                   forObject:(nullable NSString *)object
           withOperationType:(PNOperationType)operation
             queryParameters:(nullable NSDictionary *)queryParameters
             completionBlock:(id)block;


#pragma mark - Client where now

/**
 * @brief Request information about remote data object live feeds on which client with specified
 * UUID subscribed at this moment.
 *
 * @param uuid Reference on UUID for which request should be performed.
 * @param queryParameters List arbitrary query parameters which should be sent along with original
 *     API call.
 * @param block Where now fetch completion block.
 *
 * @since 4.8.2
 */
- (void)whereNowUUID:(NSString *)uuid
    withQueryParameters:(nullable NSDictionary *)queryParameters
             completion:(PNWhereNowCompletionBlock)block;


#pragma mark - Heartbeat

/**
 * @brief Send request to change client's presence at specified \c channels and / or \c groups.
 *
 * @discussion Depending from \c connected flag value, heartbeat can be used for passed objects
 * (channels/groups) to trigger \a join event or use presence \a leave API to trigger \a leave
 * event.
 *
 * @param connected Whether \c join or \c leave events should be generated for client.
 * @param channels List of \c channels for which client should change it's presence state according
 *     to \c connected flag value.
 * @param channelGroups List of channel \c groups for which client should change it's presence state
 *     according to \c connected flag value.
 * @param states Client's state which should be set for passed objects (same as state passed during
 *     subscription or using state change API).
 * @param block Client's presence modification completion block.
 *
 * @since 4.8.2
 */
- (void)setConnected:(BOOL)connected
         forChannels:(nonnull NSArray<NSString *> *)channels
       channelGroups:(nonnull NSArray<NSString *> *)channelGroups
           withState:(nonnull NSDictionary<NSString*, NSDictionary *> *)states
     completionBlock:(nonnull PNStatusBlock)block;

/**
 * @brief List of channels which should be used with heartbeat request.
 *
 * @discussion Use subscriber's and heartbeat managers information about active channels to create
 * full list which should be passed to heartbeat request.
 *
 * @return Full list of active channels.
 *
 * @since 4.7.5
 */
- (NSArray<NSString *> *)channelsForHeartbeat;

/**
 * @brief List of channel groups which should be used with heartbeat request.
 *
 * @discussion Use subscriber's and heartbeat managers information about active channel groups to
 * create full list which should be passed to heartbeat request.
 *
 * @return Full list of active channel groups.
 *
 * @since 4.7.5
 */
- (NSArray<NSString *> *)channelGroupsForHeartbeat;

#pragma mark -


@end

NS_ASSUME_NONNULL_END


#pragma mark - Interface implementation

@implementation PubNub (Presence)


#pragma mark - API Builder support

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
            PNOperationType type = PNHereNowGlobalOperation;
            PNHereNowVerbosityLevel level = PNHereNowState;
            
            if (object) {
                type = PNHereNowForChannelOperation;

                if (parameters[NSStringFromSelector(@selector(channelGroup))]) {
                    type = PNHereNowForChannelGroupOperation;
                }
            }
            
            if (parameters[NSStringFromSelector(@selector(verbosity))]) {
                NSNumber *verbosity = parameters[NSStringFromSelector(@selector(verbosity))];
                level = (PNHereNowVerbosityLevel)verbosity.integerValue;
            }
            
            [self hereNowWithVerbosity:level
                             forObject:object
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


#pragma mark - Global here now

- (void)hereNowWithCompletion:(PNGlobalHereNowCompletionBlock)block {

    [self hereNowWithVerbosity:PNHereNowState completion:block];
}

- (void)hereNowWithVerbosity:(PNHereNowVerbosityLevel)level
                  completion:(PNGlobalHereNowCompletionBlock)block {

    [self hereNowWithVerbosity:level
                     forObject:nil
             withOperationType:PNHereNowGlobalOperation
               queryParameters:nil
               completionBlock:block];
}


#pragma mark - Channel here now

- (void)hereNowForChannel:(NSString *)channel withCompletion:(PNHereNowCompletionBlock)block {

    [self hereNowForChannel:channel withVerbosity:PNHereNowState completion:block];
}

- (void)hereNowForChannel:(NSString *)channel
            withVerbosity:(PNHereNowVerbosityLevel)level
               completion:(PNHereNowCompletionBlock)block {
    
    [self hereNowWithVerbosity:level
                     forObject:channel
             withOperationType:PNHereNowForChannelOperation
               queryParameters:nil
               completionBlock:block];
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
                     forObject:group
             withOperationType:PNHereNowForChannelGroupOperation
               queryParameters:nil
               completionBlock:block];
}

- (void)hereNowWithVerbosity:(PNHereNowVerbosityLevel)level
                   forObject:(NSString *)object
           withOperationType:(PNOperationType)operation
             queryParameters:(NSDictionary *)queryParameters
             completionBlock:(id)block {

    PNRequestParameters *parameters = [PNRequestParameters new];

    [parameters addQueryParameter:@"1" forFieldName:@"disable_uuids"];
    [parameters addQueryParameter:@"0" forFieldName:@"state"];
    [parameters addQueryParameters:queryParameters];
    
    if (level == PNHereNowUUID || level == PNHereNowState){
        [parameters addQueryParameter:@"0" forFieldName:@"disable_uuids"];
        
        if (level == PNHereNowState) {
            [parameters addQueryParameter:@"1" forFieldName:@"state"];
        }
    }
    
    if (operation == PNHereNowGlobalOperation) {
        PNLogAPICall(self.logger, @"<PubNub::API> Global 'here now' information with %@ data.",
            PNHereNowDataStrings[level]);
    } else {
        if ([object length]) {
            [parameters addPathComponent:(operation == PNHereNowForChannelOperation ? 
                                          [PNString percentEscapedString:object] : @",")
                          forPlaceholder:@"{channel}"];
            
            if (operation == PNHereNowForChannelGroupOperation) {
                [parameters addQueryParameter:[PNString percentEscapedString:object] 
                                 forFieldName:@"channel-group"];
            }
        }
        
        PNLogAPICall(self.logger, @"<PubNub::API> Channel%@ 'here now' information for %@ with "
            "%@ data.", (operation == PNHereNowForChannelGroupOperation ? @" group" : @""),
            (object?: @"<error>"), PNHereNowDataStrings[level]);
    }
    
    __weak __typeof(self) weakSelf = self;
    [self processOperation:operation
            withParameters:parameters
           completionBlock:^(PNResult *result, PNStatus *status) {
               
        if (status.isError) {
            status.retryBlock = ^{
                [weakSelf hereNowWithVerbosity:level
                                     forObject:object
                             withOperationType:operation
                               queryParameters:queryParameters
                               completionBlock:block];
            };
        }
               
        [weakSelf callBlock:block status:NO withResult:result andStatus:status];
    }];
}


#pragma mark - Client where now

- (void)whereNowUUID:(NSString *)uuid withCompletion:(PNWhereNowCompletionBlock)block {

    [self whereNowUUID:uuid withQueryParameters:nil completion:block];
}

- (void)whereNowUUID:(NSString *)uuid
    withQueryParameters:(NSDictionary *)queryParameters
             completion:(PNWhereNowCompletionBlock)block {

    PNRequestParameters *parameters = [PNRequestParameters new];

    [parameters addQueryParameters:queryParameters];

    if (uuid.length) {
        [parameters addPathComponent:[PNString percentEscapedString:uuid] forPlaceholder:@"{uuid}"];
    }

    PNLogAPICall(self.logger, @"<PubNub::API> 'Where now' presence information for %@.",
        (uuid?: @"<error>"));

    __weak __typeof(self) weakSelf = self;
    [self processOperation:PNWhereNowOperation
            withParameters:parameters
           completionBlock:^(PNResult *result, PNStatus *status) {

        if (status.isError) {
            status.retryBlock = ^{
                [weakSelf whereNowUUID:uuid withQueryParameters:queryParameters completion:block];
            };
        }

        [weakSelf callBlock:block status:NO withResult:result andStatus:status];
    }];
}


#pragma mark - Heartbeat

- (void)setConnected:(BOOL)connected
         forChannels:(NSArray<NSString *> *)channels
       channelGroups:(NSArray<NSString *> *)channelGroups
           withState:(NSDictionary<NSString*, NSDictionary *> *)states
     completionBlock:(PNStatusBlock)block {
    
    if (!self.configuration.shouldManagePresenceListManually) {
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

                if (block) {
                    block((id)status);
                }
            }];
        }
    }
}

- (void)heartbeatWithCompletion:(PNStatusBlock)block {
    
    __weak __typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSArray *channels = [self channelsForHeartbeat];
        NSArray *groups = [self channelGroupsForHeartbeat];

        if (self.configuration.presenceHeartbeatValue > 0 && (channels.count || groups.count)) {
            PNRequestParameters *parameters = [PNRequestParameters new];

            [parameters addPathComponent:[PNChannel namesForRequest:channels defaultString:@","]
                          forPlaceholder:@"{channels}"];

            if (groups.count) {
                [parameters addQueryParameter:[PNChannel namesForRequest:groups]
                                 forFieldName:@"channel-group"];
            }

            [parameters addQueryParameter:@(self.configuration.presenceHeartbeatValue).stringValue
                             forFieldName:@"heartbeat"];

            NSDictionary *state = [self.clientStateManager state];

            if (state.count) {
                if (self.configuration.shouldManagePresenceListManually) {
                    NSMutableArray *allObjects = [NSMutableArray arrayWithArray:channels];
                    [allObjects addObjectsFromArray:groups];
                    NSMutableDictionary *filteredState = [(state ?: @{}) mutableCopy];
                    NSMutableArray *stateKeys = [NSMutableArray arrayWithArray:state.allKeys];
                    
                    [stateKeys removeObjectsInArray:allObjects];
                    [filteredState removeObjectsForKeys:stateKeys];
                    
                    state = filteredState;
                }
                
                NSString *stateString = [PNJSON JSONStringFrom:state withError:nil];

                if (stateString.length) {
                    [parameters addQueryParameter:[PNString percentEscapedString:stateString]
                                     forFieldName:@"state"];
                }
            }
            
            PNLogAPICall(weakSelf.logger, @"<PubNub::API> Heartbeat for %@%@%@.",
                (channels.count ? [NSString stringWithFormat:@"channel%@ '%@'",
                                   (channels.count > 1 ? @"s" : @""),
                                   [channels componentsJoinedByString:@", "]] : @""),
                (channels.count && groups.count ? @" and " : @""),
                (groups.count ? [NSString stringWithFormat:@"group%@ '%@'",
                                 (groups.count > 1 ? @"s" : @""),
                                 [groups componentsJoinedByString:@", "]] : @""));
            
            [self processOperation:PNHeartbeatOperation
                    withParameters:parameters
                   completionBlock:^(PNStatus *status) {

               [weakSelf callBlock:block status:YES withResult:nil andStatus:status];
           }];
        }
    });
}

- (NSArray<NSString *> *)channelsForHeartbeat {

    NSArray *subscribedChannels = nil;
    
    if (self.configuration.shouldManagePresenceListManually) {
        subscribedChannels = [self.heartbeatManager channels];
    } else {
        subscribedChannels = [self.subscriberManager channels];
    }

    return [PNChannel objectsWithOutPresenceFrom:subscribedChannels];
}

- (NSArray<NSString *> *)channelGroupsForHeartbeat {
    
    NSArray *subscribedChannelGroups = nil;
    
    if (self.configuration.shouldManagePresenceListManually) {
        subscribedChannelGroups = [self.heartbeatManager channelGroups];
    } else {
        subscribedChannelGroups = [self.subscriberManager channelGroups];
    }
    
    return [PNChannel objectsWithOutPresenceFrom:subscribedChannelGroups];
}

#pragma mark -


@end
