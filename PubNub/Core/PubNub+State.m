#import "PubNub+State.h"
#import "PNChannelGroupClientStateResult+Private.h"
#import "PNPresenceUserStateFetchData+Private.h"
#import "PNChannelClientStateResult+Private.h"
#import "PNClientStateGetResult+Private.h"
#import "PNOperationResult+Private.h"
#import "PubNub+CorePrivate.h"
#import "PNStatus+Private.h"

// Deprecated
#import "PNAPICallBuilder+Private.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Private interface declaration

/// **PubNub** `Presence State` API private extension.
@interface PubNub (StateProtected)


#pragma mark - Client state information manipulation

/// Modify state information for `uuid` on specified remote data object.
///
/// - Parameters:
///   - state: `NSDictionary` with data which should be bound to `uuid` on channel group.
///   - uuid: Unique user identifier for which state should be bound.
///   - channels: List of the channels which will store provided state information for `uuid`.
///   - groups: List of channel group names which will store provided state information for `uuid`.
///   - queryParameters: List arbitrary query parameters which should be sent along with original API call.
///   - block: State modification for user on channel completion block.
- (void)setState:(nullable NSDictionary<NSString *, id> *)state
                forUUID:(NSString *)uuid
             onChannels:(nullable NSArray<NSString *> *)channels
                 groups:(nullable NSArray<NSString *> *)groups
    withQueryParameters:(nullable NSDictionary *)queryParameters
             completion:(nullable PNSetStateCompletionBlock)block;

/// Retrieve state information for `uuid` on specified remote data object.
///
/// - Parameters:
///   - uuid: Unique user identifier for which state should be retrieved.
///   - channels: List of the channels from which state information for `uuid` will be pulled out.
///   - groups: List of channel group names from which state information for `uuid` will be pulled out.
///   - apiCallBuilder: Whether API has been called from API call builder or not.
///   - queryParameters: List arbitrary query parameters which should be sent along with original API call.
///   - block: State audition for user on remote data object completion block.
- (void)stateForUUID:(NSString *)uuid
            onChannels:(nullable NSArray<NSString *> *)channels
                 groups:(nullable NSArray<NSString *> *)groups
            fromBuilder:(BOOL)apiCallBuilder
    withQueryParameters:(nullable NSDictionary *)queryParameters
             completion:(id)block;


#pragma mark - Handlers

/// Process client state modification request completion and notify observers about results.
///
/// - Parameters:
///   - status: State modification status instance.
///   - uuid: Unique user identifier for which state should be updated.
///   - channels: List of the channels which will store provided state information for `uuid`.
///   - groups: List of channel group names which will store provided state information for `uuid`.
///   - block: State modification for user on channel completion block.
- (void)handleSetStateStatus:(PNClientStateUpdateStatus *)status
                     forUUID:(NSString *)uuid
                  atChannels:(nullable NSArray<NSString *> *)channels
                      groups:(nullable NSArray<NSString *> *)groups
              withCompletion:(nullable PNSetStateCompletionBlock)block;

///  Process client state audition request completion and notify observers about results.
///
///  - Parameters:
///    - result: Service response results instance.
///    - status: State request status instance.
///    - uuid: Unique user identifier for which state should be retrieved.
///    - channels: List of the channels which will store provided state information for `uuid`.
///    - groups: List of channel group names which will store provided state information for `uuid`.
///    - block: State audition for user on channel completion block.
- (void)handleStateResult:(nullable PNPresenceStateFetchResult *)result
               withStatus:(nullable PNStatus *)status
                  forUUID:(NSString *)uuid
               atChannels:(nullable NSArray<NSString *> *)channels
                   groups:(nullable NSArray<NSString *> *)groups
           withCompletion:(id)block;

#pragma mark - 


@end

NS_ASSUME_NONNULL_END


#pragma mark - Interface implementation

@implementation PubNub (State)


#pragma mark - Presence API builder interface (deprecated)

- (PNStateAPICallBuilder * (^)(void))state {
    PNStateAPICallBuilder *builder = nil;
    builder = [PNStateAPICallBuilder builderWithExecutionBlock:^(NSArray<NSString *> *flags, NSDictionary *parameters) {
        NSArray<NSString *> *groups = parameters[NSStringFromSelector(@selector(channelGroups))];
        NSArray<NSString *> *channels = parameters[NSStringFromSelector(@selector(channels))];
        NSDictionary *state = parameters[NSStringFromSelector(@selector(state))];
        NSString *uuid = parameters[NSStringFromSelector(@selector(uuid))];
        NSDictionary *queryParam = parameters[@"queryParam"];
        id block = parameters[@"block"];
        
        if ([flags containsObject:NSStringFromSelector(@selector(audit))]) {
            [self stateForUUID:uuid
                    onChannels:channels
                        groups:groups
                   fromBuilder:YES
           withQueryParameters:queryParam
                    completion:block];
        } else {
            [self setState:state
                   forUUID:uuid
                onChannels:channels
                    groups:groups
       withQueryParameters:queryParam
                completion:block];
        }
    }];
    
    return ^PNStateAPICallBuilder * {
        return builder;
    };
}


#pragma mark - Client state information manipulation

- (void)setPresenceStateWithRequest:(PNPresenceStateSetRequest *)userRequest
                         completion:(PNSetStateCompletionBlock)handlerBlock {
    PNOperationDataParser *responseParser = [self parserWithStatus:[PNClientStateUpdateStatus class]];
    PNSetStateCompletionBlock block = [handlerBlock copy];
    PNParsedRequestCompletionBlock handler; 

    PNLogAPICall(self.logger, @"<PubNub::API> Set %@'s state on%@%@: %@.",
                 userRequest.userId,
                 (userRequest.channels.count
                  ? [NSString stringWithFormat:@" channels (%@)", [userRequest.channels componentsJoinedByString:@","]]
                  : @""),
                 (userRequest.channelGroups.count
                  ? [NSString stringWithFormat:@" %@channel groups (%@)", userRequest.channels.count ? @"and " : @"", [userRequest.channelGroups componentsJoinedByString:@","]]
                  : @""),
                 userRequest.state);

    PNWeakify(self);
    handler = ^(PNTransportRequest *request, id<PNTransportResponse> response, __unused NSURL *location,
                PNOperationDataParseResult<PNClientStateUpdateStatus *, PNClientStateUpdateStatus *> *result) {
        PNStrongify(self);

        if (result.status.isError) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
            result.status.retryBlock = ^{
                [self setPresenceStateWithRequest:userRequest completion:block];
            };
#pragma clang diagnostic pop
        }

        [self handleSetStateStatus:result.status
                           forUUID:userRequest.userId
                        atChannels:userRequest.channels
                            groups:userRequest.channelGroups
                    withCompletion:block];
    };

    [self performRequest:userRequest withParser:responseParser completion:handler];
}

- (void)setState:(NSDictionary<NSString *, id> *)state
           forUUID:(NSString *)uuid
         onChannel:(NSString *)channel
    withCompletion:(PNSetStateCompletionBlock)block {
    NSArray *channels = channel ? @[channel] : nil;

    [self setState:state
                forUUID:uuid
             onChannels:channels
                 groups:nil
    withQueryParameters:nil
             completion:block];
}

- (void)setState:(NSDictionary<NSString *, id> *)state
           forUUID:(NSString *)uuid
    onChannelGroup:(NSString *)group
    withCompletion:(PNSetStateCompletionBlock)block {
    NSArray *groups = group ? @[group] : nil;

    [self setState:state
                forUUID:uuid
             onChannels:nil
                 groups:groups
    withQueryParameters:nil
             completion:block];
}

- (void)setState:(nullable NSDictionary<NSString *, id> *)state
                forUUID:(NSString *)uuid
             onChannels:(NSArray<NSString *> *)channels
                 groups:(NSArray<NSString *> *)groups
    withQueryParameters:(NSDictionary *)queryParameters
             completion:(PNSetStateCompletionBlock)block {
    PNPresenceStateSetRequest *request = [PNPresenceStateSetRequest requestWithUserId:uuid];
    request.arbitraryQueryParameters = queryParameters;
    request.channelGroups = groups;
    request.channels = channels;
    request.state = state;

    [self setPresenceStateWithRequest:request completion:block];
}


#pragma mark - Client state information audit

- (void)fetchPresenceStateWithRequest:(PNPresenceStateFetchRequest *)userRequest
                           completion:(PNPresenceStateFetchCompletionBlock)handlerBlock {
    PNOperationDataParser *responseParser = [self parserWithResult:[PNPresenceStateFetchResult class]
                                                            status:[PNErrorStatus class]];
    PNPresenceStateFetchCompletionBlock block = [handlerBlock copy];
    PNParsedRequestCompletionBlock handler;

    PNLogAPICall(self.logger, @"<PubNub::API> State request on %@%@ for %@.",
                 (userRequest.channels.count
                  ? [NSString stringWithFormat:@" channels (%@)", [userRequest.channels componentsJoinedByString:@","]]
                  : @""),
                 (userRequest.channelGroups.count
                  ? [NSString stringWithFormat:@" %@channel groups (%@)", userRequest.channels.count ? @"and " : @"",
                             [userRequest.channelGroups componentsJoinedByString:@","]] 
                  : @""),
                 userRequest.userId);

    PNWeakify(self);
    handler = ^(PNTransportRequest *request, id<PNTransportResponse> response, __unused NSURL *location,
                PNOperationDataParseResult<PNPresenceStateFetchResult *, PNErrorStatus *> *result) {
        PNStrongify(self);

        if (result.status.isError) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
            result.status.retryBlock = ^{
                [self fetchPresenceStateWithRequest:userRequest completion:block];
            };
#pragma clang diagnostic pop
        }

        [self handleStateResult:result.result
                     withStatus:result.status
                        forUUID:userRequest.userId
                     atChannels:userRequest.channels
                         groups:userRequest.channelGroups
                 withCompletion:block];
    };

    [self performRequest:userRequest withParser:responseParser completion:handler];
}

- (void)stateForUUID:(NSString *)uuid
           onChannel:(NSString *)channel
      withCompletion:(PNChannelStateCompletionBlock)block {
    NSArray *channels = channel ? @[channel] : nil;
    
    [self stateForUUID:uuid
             onChannels:channels
                 groups:nil
            fromBuilder:NO
    withQueryParameters:nil
             completion:block];
}

- (void)stateForUUID:(NSString *)uuid
      onChannelGroup:(NSString *)group
      withCompletion:(PNChannelGroupStateCompletionBlock)block {
    NSArray *groups = group ? @[group] : nil;
    
    [self stateForUUID:uuid
             onChannels:nil
                 groups:groups
            fromBuilder:NO
    withQueryParameters:nil
             completion:block];
}

- (void)stateForUUID:(NSString *)uuid
             onChannels:(NSArray<NSString *> *)channels
                 groups:(NSArray<NSString *> *)groups
            fromBuilder:(BOOL)apiCallBuilder
    withQueryParameters:(NSDictionary *)queryParameters
             completion:(id)handlerBlock {

    PNPresenceStateFetchRequest *request = [PNPresenceStateFetchRequest requestWithUserId:uuid];
    request.arbitraryQueryParameters = queryParameters;
    request.channelGroups = groups;
    id block = [handlerBlock copy];
    request.channels = channels;

    [self fetchPresenceStateWithRequest:request completion:^(PNPresenceStateFetchResult *result, PNErrorStatus *status) {
        id mappedResult = result;
        if (apiCallBuilder) {
           if (mappedResult) mappedResult = [PNClientStateGetResult legacyPresenceStateFromPresenceState:result];
        }  else {
            if (channels.count == 1 && groups.count == 0) {
                if (mappedResult) mappedResult = [PNChannelClientStateResult legacyPresenceFromPresence:result];
                else status.operation = PNStateForChannelOperation;
            } else if (channels.count > 1 || groups.count >= 1) {
                if (mappedResult) mappedResult = [PNChannelGroupClientStateResult legacyPresenceFromPresence:result];
                else status.operation = PNStateForChannelGroupOperation;
            }
        }

        [self callBlock:block status:NO withResult:mappedResult andStatus:status];
    }];
}


#pragma mark - Handlers

- (void)handleSetStateStatus:(PNClientStateUpdateStatus *)status
                     forUUID:(NSString *)uuid
                  atChannels:(NSArray<NSString *> *)channels
                      groups:(NSArray<NSString *> *)groups
              withCompletion:(PNSetStateCompletionBlock)block {

    if (status && !status.isError && [uuid isEqualToString:self.configuration.userID]) {
        NSDictionary *state = status.data.state ?: @{};

        [self.clientStateManager setState:state forObjects:channels];
        [self.clientStateManager setState:state forObjects:groups];
    }

    [self callBlock:block status:YES withResult:nil andStatus:status];
}

- (void)handleStateResult:(PNPresenceStateFetchResult *)result
               withStatus:(PNStatus *)status
                  forUUID:(NSString *)uuid
               atChannels:(NSArray<NSString *> *)channels
                   groups:(NSArray<NSString *> *)groups
           withCompletion:(id)block {

    if (result && [uuid isEqualToString:self.configuration.userID]) {
        NSDictionary *state = @{};

        if (result.data.channel) state = @{ result.data.channel: result.data.state };
        else state = result.data.channels;

        NSMutableDictionary *existingState = [(self.clientStateManager.state ?: @{}) mutableCopy];
        [existingState addEntriesFromDictionary:state];

        NSArray<NSString *> *channelsWithState = self.clientStateManager.state.allKeys;
        state = [existingState dictionaryWithValuesForKeys:channelsWithState];

        if (state.count) [self.clientStateManager setState:state forObjects:channelsWithState];
    }

    [self callBlock:block status:NO withResult:result andStatus:status];
}

#pragma mark -


@end
