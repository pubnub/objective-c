/**
 * @author Serhii Mamontov
 * @since 4.0
 * @copyright © 2010-2018 PubNub, Inc.
 */
#import "PubNub+State.h"
#import "PNChannelGroupClientStateResult.h"
#import "PNClientStateUpdateStatus.h"
#import "PNAPICallBuilder+Private.h"
#import "PNClientStateGetResult.h"
#import "PNRequestParameters.h"
#import "PubNub+CorePrivate.h"
#import "PNStatus+Private.h"
#import "PNConfiguration.h"
#import "PNLogMacro.h"
#import "PNHelpers.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Protected interface declaration

@interface PubNub (StateProtected)


#pragma mark - Client state information manipulation

/**
 * @brief Modify state information for \c uuid on specified remote data object.
 *
 * @param state \a NSDictionary with data which should be bound to \c uuid on channel group.
 * @param uuid Unique user identifier for which state should be bound.
 * @param channels List of the channels which will store provided state information for \c uuid.
 * @param groups List of channel group names which will store provided state information for
 *     \c uuid.
 * @param queryParameters List arbitrary query parameters which should be sent along with original
 *     API call.
 * @param block State modification for user on channel completion block.
 *
 * @since 4.8.2
 */
- (void)setState:(nullable NSDictionary<NSString *, id> *)state
                forUUID:(NSString *)uuid
             onChannels:(nullable NSArray<NSString *> *)channels
                 groups:(nullable NSArray<NSString *> *)groups
    withQueryParameters:(nullable NSDictionary *)queryParameters
             completion:(nullable PNSetStateCompletionBlock)block;

/**
 * @brief Retrieve state information for \c uuid on specified remote data object.
 *
 * @param uuid Unique user identifier for which state should be retrieved.
 * @param channels List of the channels from which state information for \c uuid will be pulled out.
 * @param groups List of channel group names from which state information for \c uuid will be
 *     pulled out.
 * @param apiCallBuilder Whether API has been called from API call builder or not.
 * @param queryParameters List arbitrary query parameters which should be sent along with original
 *     API call.
 * @param block State audition for user on remote data object completion block.
 *
 * @since 4.8.2
 */
- (void)stateForUUID:(NSString *)uuid
            onChannels:(nullable NSArray<NSString *> *)channels
                 groups:(nullable NSArray<NSString *> *)groups
            fromBuilder:(BOOL)apiCallBuilder
    withQueryParameters:(nullable NSDictionary *)queryParameters
             completion:(id)block;


#pragma mark - Handlers

/**
 * @brief Process client state modification request completion and notify observers about results.
 *
 * @param status State modification status instance.
 * @param uuid Unique user identifier for which state should be updated.
 * @param channels List of the channels which will store provided state information for \c uuid.
 * @param groups List of channel group names which will store provided state information for
 *     \c uuid.
 * @param block State modification for user on channel completion block.
 *
 * @since 4.0
 */
- (void)handleSetStateStatus:(PNClientStateUpdateStatus *)status
                     forUUID:(NSString *)uuid
                  atChannels:(nullable NSArray<NSString *> *)channels
                      groups:(nullable NSArray<NSString *> *)groups
              withCompletion:(nullable PNSetStateCompletionBlock)block;

/**
 * @brief  Process client state audition request completion and notify observers about results.
 *
 * @param result Service response results instance.
 * @param status State request status instance.
 * @param uuid Unique user identifier for which state should be retrieved.
 * @param channels List of the channels which will store provided state information for \c uuid.
 * @param groups List of channel group names which will store provided state information for
 *     \c uuid.
 * @param apiCallBuilder Whether processing data which has been received by API call from API call
 *     builder or not.
 * @param block State audition for user on channel completion block.

 @since 4.0
 */
- (void)handleStateResult:(nullable id)result
               withStatus:(nullable PNStatus *)status
                  forUUID:(NSString *)uuid
               atChannels:(nullable NSArray<NSString *> *)channels
                   groups:(nullable NSArray<NSString *> *)groups
              fromBuilder:(BOOL)apiCallBuilder
           withCompletion:(id)block;

#pragma mark - 


@end

NS_ASSUME_NONNULL_END


#pragma mark Interface implementation

@implementation PubNub (State)


#pragma mark - API Builder support

- (PNStateAPICallBuilder * (^)(void))state {
    
    PNStateAPICallBuilder *builder = nil;
    builder = [PNStateAPICallBuilder builderWithExecutionBlock:^(NSArray<NSString *> *flags, 
                                                                 NSDictionary *parameters) {
                            
        NSString *uuid = parameters[NSStringFromSelector(@selector(uuid))];
        NSArray<NSString *> *channels = parameters[NSStringFromSelector(@selector(channels))];
        NSArray<NSString *> *groups = parameters[NSStringFromSelector(@selector(channelGroups))];
        NSDictionary *state = parameters[NSStringFromSelector(@selector(state))];
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

- (void)setState:(NSDictionary<NSString *, id> *)state
           forUUID:(NSString *)uuid
         onChannel:(NSString *)channel
    withCompletion:(PNSetStateCompletionBlock)block {

    [self setState:state
                forUUID:uuid
             onChannels:@[channel]
                 groups:nil
    withQueryParameters:nil
             completion:block];
}

- (void)setState:(NSDictionary<NSString *, id> *)state
           forUUID:(NSString *)uuid
    onChannelGroup:(NSString *)group
    withCompletion:(PNSetStateCompletionBlock)block {

    [self setState:state
                forUUID:uuid
             onChannels:nil
                 groups:@[group]
    withQueryParameters:nil
             completion:block];
}

- (void)setState:(nullable NSDictionary<NSString *, id> *)state
                forUUID:(NSString *)uuid
             onChannels:(NSArray<NSString *> *)channels
                 groups:(NSArray<NSString *> *)groups
    withQueryParameters:(NSDictionary *)queryParameters
             completion:(PNSetStateCompletionBlock)block {

    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    uuid = uuid ?: self.configuration.uuid;
    __weak __typeof(self) weakSelf = self;
    
    if (@available(macOS 10.10, iOS 8.0, *)) {
        if (self.configuration.applicationExtensionSharedGroupIdentifier) {
            queue = dispatch_get_main_queue();
        }
    }

    dispatch_async(queue, ^{
        __strong __typeof__(weakSelf) strongSelf = weakSelf;
        NSString *stateString = [PNJSON JSONStringFrom:state withError:NULL] ?: @"{}";
        PNRequestParameters *parameters = [PNRequestParameters new];

        [parameters addPathComponent:(channels.count ? [PNChannel namesForRequest:channels] : @",")
                      forPlaceholder:@"{channel}"];
        [parameters addQueryParameter:[PNString percentEscapedString:stateString]
                         forFieldName:@"state"];
        [parameters addQueryParameters:queryParameters];
        
        if (uuid.length) {
            [parameters addPathComponent:[PNString percentEscapedString:uuid]
                          forPlaceholder:@"{uuid}"];
        }
        
        if (groups.count) {
            [parameters addQueryParameter:[PNChannel namesForRequest:groups]
                             forFieldName:@"channel-group"];
        }

        PNLogAPICall(strongSelf.logger, @"<PubNub::API> Set %@'s state on%@%@: %@.", uuid,
                (channels.count ? [NSString stringWithFormat:@" channels (%@)",
                                   [channels componentsJoinedByString:@","]] : @""),
                (groups.count ? [NSString stringWithFormat:@" %@channel groups (%@)",
                                channels.count ? @"and " : @"",
                                [groups componentsJoinedByString:@","]] : @""),
                parameters.query[@"state"]);
        
        [strongSelf processOperation:PNSetStateOperation
                      withParameters:parameters
                     completionBlock:^(PNStatus *status) {
                         
           if (status.isError) {
               status.retryBlock = ^{
                   [weakSelf setState:state
                              forUUID:uuid
                           onChannels:channels
                               groups:groups
                  withQueryParameters:queryParameters
                           completion:block];
               };
           }

           [weakSelf handleSetStateStatus:(PNClientStateUpdateStatus *)status
                                  forUUID:uuid
                               atChannels:channels
                                   groups:groups
                           withCompletion:block];
       }];
    });
}


#pragma mark - Client state information audit

- (void)stateForUUID:(NSString *)uuid
           onChannel:(NSString *)channel
      withCompletion:(PNChannelStateCompletionBlock)block {
    
    [self stateForUUID:uuid
             onChannels:@[channel]
                 groups:nil
            fromBuilder:NO
    withQueryParameters:nil
             completion:block];
}

- (void)stateForUUID:(NSString *)uuid
      onChannelGroup:(NSString *)group
      withCompletion:(PNChannelGroupStateCompletionBlock)block {
    
    [self stateForUUID:uuid
             onChannels:nil
                 groups:@[group]
            fromBuilder:NO
    withQueryParameters:nil
             completion:block];
}

- (void)stateForUUID:(NSString *)uuid
             onChannels:(NSArray<NSString *> *)channels
                 groups:(NSArray<NSString *> *)groups
            fromBuilder:(BOOL)apiCallBuilder
    withQueryParameters:(NSDictionary *)queryParameters
             completion:(id)block {
    
    PNRequestParameters *parameters = [PNRequestParameters new];
    uuid = uuid ?: self.configuration.uuid;
    PNOperationType operation = PNGetStateOperation;

    [parameters addPathComponent:(channels.count ? [PNChannel namesForRequest:channels] : @",")
                  forPlaceholder:@"{channel}"];
    [parameters addQueryParameters:queryParameters];
    
    if (uuid.length) {
        [parameters addPathComponent:[PNString percentEscapedString:uuid] forPlaceholder:@"{uuid}"];
    }
    
    if (groups.count) {
        [parameters addQueryParameter:[PNChannel namesForRequest:groups]
                         forFieldName:@"channel-group"];
    }

    if (!apiCallBuilder) {
        operation = groups.count ? PNStateForChannelGroupOperation : PNStateForChannelOperation;
    }
    
    PNLogAPICall(self.logger, @"<PubNub::API> State request on %@%@ for %@.",
            (channels.count ? [NSString stringWithFormat:@" channels (%@)",
                               [channels componentsJoinedByString:@","]] : @""),
            (groups.count ? [NSString stringWithFormat:@" %@channel groups (%@)",
                             channels.count ? @"and " : @"",
                             [groups componentsJoinedByString:@","]] : @""),
            uuid);
    
    __weak __typeof(self) weakSelf = self;
    [self processOperation:operation
            withParameters:parameters 
           completionBlock:^(PNResult *result, PNStatus *status) {
               
        if (status.isError) {
            status.retryBlock = ^{
                [weakSelf stateForUUID:uuid
                            onChannels:channels
                                groups:groups
                           fromBuilder:apiCallBuilder
                   withQueryParameters:queryParameters
                            completion:block];
            };
        }

        [weakSelf handleStateResult:(PNChannelClientStateResult *)result
                         withStatus:status
                            forUUID:uuid
                         atChannels:channels
                             groups:groups
                        fromBuilder:apiCallBuilder
                     withCompletion:block];
    }];
}


#pragma mark - Handlers

- (void)handleSetStateStatus:(PNClientStateUpdateStatus *)status
                     forUUID:(NSString *)uuid
                  atChannels:(NSArray<NSString *> *)channels
                      groups:(NSArray<NSString *> *)groups
              withCompletion:(PNSetStateCompletionBlock)block {

    if (status && !status.isError && [uuid isEqualToString:self.configuration.uuid]) {
        NSDictionary *state = status.data.state ?: @{};

        [self.clientStateManager setState:state forObjects:channels];
        [self.clientStateManager setState:state forObjects:groups];
    }

    [self callBlock:block status:YES withResult:nil andStatus:status];
}

- (void)handleStateResult:(id)result
               withStatus:(PNStatus *)status
                  forUUID:(NSString *)uuid
               atChannels:(NSArray<NSString *> *)channels
                   groups:(NSArray<NSString *> *)groups
              fromBuilder:(BOOL)apiCallBuilder
           withCompletion:(id)block {

    if (result && [uuid isEqualToString:self.configuration.uuid]) {
        NSDictionary *state = @{};

        if (!apiCallBuilder) {
            if (channels.count) {
                state = @{ channels[0]: ((PNChannelClientStateResult *)result).data.state ?: @{} };
            } else if (groups.count) {
                state = ((PNChannelGroupClientStateResult *)result).data.channels;
            }
        } else {
            state = ((PNClientStateGetResult *)result).data.channels;
        }

        NSMutableDictionary *existingState = [(self.clientStateManager.state ?: @{}) mutableCopy];
        [existingState addEntriesFromDictionary:state];

        NSArray<NSString *> *channelsWithState = self.clientStateManager.state.allKeys;
        state = [existingState dictionaryWithValuesForKeys:channelsWithState];

        if (state.count) {
            [self.clientStateManager setState:state forObjects:channelsWithState];
        }
    }

    [self callBlock:block status:NO withResult:result andStatus:status];
}

#pragma mark -


@end
