/**
 * @author Serhii Mamontov
 * @since 4.0
 * @copyright © 2009-2017 PubNub, Inc.
 */
#import "PubNub+State.h"
#import "PNClientStateUpdateStatus.h"
#import "PNAPICallBuilder+Private.h"
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
 * @param onChannel Whether state has been provided for channel or channel group.
 * @param object Name of remote data object which will store provided state information for \c uuid.
 * @param queryParameters List arbitrary query parameters which should be sent along with original
 *     API call.
 * @param block State modification for user on channel completion block.
 *
 * @since 4.8.2
 */
- (void)setState:(nullable NSDictionary<NSString *, id> *)state
         forUUID:(NSString *)uuid
       onChannel:(BOOL)onChannel
        withName:(NSString *)object
 queryParameters:(nullable NSDictionary *)queryParameters
      completion:(nullable PNSetStateCompletionBlock)block;

/**
 * @brief Retrieve state information for \c uuid on specified remote data object.
 *
 * @param uuid Unique user identifier for which state should be retrieved.
 * @param onChannel Whether state has been provided for channel or channel group.
 * @param object Name of remote data object from which state information for \c uuid will be pulled
 *     out.
 * @param queryParameters List arbitrary query parameters which should be sent along with original
 *     API call.
 * @param block State audition for user on remote data object completion block.
 *
 * @since 4.8.2
 */
- (void)stateForUUID:(NSString *)uuid
           onChannel:(BOOL)onChannel
            withName:(NSString *)object
     queryParameters:(nullable NSDictionary *)queryParameters
          completion:(id)block;


#pragma mark - Handlers

/**
 * @brief Process client state modification request completion and notify observers about results.
 *
 * @param status State modification status instance.
 * @param uuid Unique user identifier for which state should be updated.
 * @param object Name of remote data object for which state information for \c uuid had been bound.
 * @param block State modification for user on channel completion block.
 *
 * @since 4.0
 */
- (void)handleSetStateStatus:(PNClientStateUpdateStatus *)status
                     forUUID:(NSString *)uuid
                    atObject:(NSString *)object
              withCompletion:(nullable PNSetStateCompletionBlock)block;

/**
 * @brief  Process client state audition request completion and notify observers about results.
 *
 * @param result Service response results instance.
 * @param status State request status instance.
 * @param uuid Unique user identifier for which state should be retrieved.
 * @param isChannel Whether received state information for channel or not.
 * @param object Name of remote data object from which state information for \c uuid will be pulled
 *     out.
 * @param block State audition for user on channel completion block.

 @since 4.0
 */
- (void)handleStateResult:(nullable PNChannelClientStateResult *)result
               withStatus:(nullable PNStatus *)status
                  forUUID:(NSString *)uuid
                atChannel:(BOOL)isChannel
                   object:(NSString *)object
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
        NSString *object = (parameters[NSStringFromSelector(@selector(channel))] ?:
                            parameters[NSStringFromSelector(@selector(channelGroup))]);
        BOOL forChannel = (parameters[NSStringFromSelector(@selector(channel))] != nil);
        NSDictionary *state = parameters[NSStringFromSelector(@selector(state))];
        NSDictionary *queryParam = parameters[@"queryParam"];
        id block = parameters[@"block"];
        
        if ([flags containsObject:NSStringFromSelector(@selector(audit))]) {
            [self stateForUUID:uuid
                     onChannel:forChannel
                      withName:object
               queryParameters:queryParam
                    completion:block];
        } else {
            [self setState:state
                   forUUID:uuid
                 onChannel:forChannel
                  withName:object
           queryParameters:queryParam
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
          onChannel:YES
           withName:channel
    queryParameters:nil
         completion:block];
}

- (void)setState:(NSDictionary<NSString *, id> *)state
           forUUID:(NSString *)uuid
    onChannelGroup:(NSString *)group
    withCompletion:(PNSetStateCompletionBlock)block {
    
    [self setState:state
            forUUID:uuid
          onChannel:NO
           withName:group
    queryParameters:nil
         completion:block];
}

- (void)setState:(NSDictionary<NSString *, id> *)state
            forUUID:(NSString *)uuid
          onChannel:(BOOL)onChannel
           withName:(NSString *)object
    queryParameters:(NSDictionary *)queryParameters
         completion:(PNSetStateCompletionBlock)block {

    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
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
        
        [parameters addPathComponent:(onChannel ? [PNString percentEscapedString:object] : @",")
                      forPlaceholder:@"{channel}"];
        [parameters addQueryParameter:[PNString percentEscapedString:stateString]
                         forFieldName:@"state"];
        [parameters addQueryParameters:queryParameters];
        
        if (uuid.length) {
            [parameters addPathComponent:[PNString percentEscapedString:uuid]
                          forPlaceholder:@"{uuid}"];
        }
        
        if (!onChannel && object.length) {
            [parameters addQueryParameter:[PNString percentEscapedString:object]
                             forFieldName:@"channel-group"];
        }
        
        PNLogAPICall(strongSelf.logger, @"<PubNub::API> Set %@'s state on '%@' channel%@: %@.",
            (uuid?: @"<error>"), (object?: @"<error>"), (!onChannel ? @" group" : @""),
            parameters.query[@"state"]);
        
        [strongSelf processOperation:PNSetStateOperation
                      withParameters:parameters
                     completionBlock:^(PNStatus *status) {
                         
           if (status.isError) {
               status.retryBlock = ^{
                   [weakSelf setState:state
                              forUUID:uuid
                            onChannel:onChannel
                             withName:object
                      queryParameters:queryParameters
                           completion:block];
               };
           }
                         
           [weakSelf handleSetStateStatus:(PNClientStateUpdateStatus *)status
                                  forUUID:uuid
                                 atObject:object
                           withCompletion:block];
       }];
    });
}


#pragma mark - Client state information audit

- (void)stateForUUID:(NSString *)uuid
           onChannel:(NSString *)channel
      withCompletion:(PNChannelStateCompletionBlock)block {
    
    [self stateForUUID:uuid onChannel:YES withName:channel queryParameters:nil completion:block];
}

- (void)stateForUUID:(NSString *)uuid
      onChannelGroup:(NSString *)group
      withCompletion:(PNChannelGroupStateCompletionBlock)block {
    
    [self stateForUUID:uuid onChannel:NO withName:group queryParameters:nil completion:block];
}
- (void)stateForUUID:(NSString *)uuid
           onChannel:(BOOL)onChannel
            withName:(NSString *)object
     queryParameters:(NSDictionary *)queryParameters
          completion:(id)block {
    
    PNRequestParameters *parameters = [PNRequestParameters new];

    [parameters addPathComponent:(onChannel ? [PNString percentEscapedString:object] : @",")
                  forPlaceholder:@"{channel}"];
    [parameters addQueryParameters:queryParameters];
    
    if (uuid.length) {
        [parameters addPathComponent:[PNString percentEscapedString:uuid] forPlaceholder:@"{uuid}"];
    }
    
    if (!onChannel && object.length) {
        [parameters addQueryParameter:[PNString percentEscapedString:object]
                         forFieldName:@"channel-group"];
    }
    
    PNLogAPICall(self.logger, @"<PubNub::API> State request on '%@' channel%@: %@.",
        (uuid?: @"<error>"), (object?: @"<error>"), (!onChannel ? @" group" : @""));
    
    __weak __typeof(self) weakSelf = self;
    [self processOperation:(onChannel ? PNStateForChannelOperation
                                      : PNStateForChannelGroupOperation)
            withParameters:parameters 
           completionBlock:^(PNResult *result, PNStatus *status) {
               
        if (status.isError) {
            status.retryBlock = ^{
                [weakSelf stateForUUID:uuid
                             onChannel:onChannel
                              withName:object
                       queryParameters:queryParameters
                            completion:block];
            };
        }
               
        [weakSelf handleStateResult:(PNChannelClientStateResult *)result
                         withStatus:status
                            forUUID:uuid
                          atChannel:onChannel
                             object:object
                     withCompletion:block];
    }];
}


#pragma mark - Handlers

- (void)handleSetStateStatus:(PNClientStateUpdateStatus *)status
                     forUUID:(NSString *)uuid
                    atObject:(NSString *)object
              withCompletion:(PNSetStateCompletionBlock)block {

    if (status && !status.isError && [uuid isEqualToString:self.configuration.uuid]) {
        [self.clientStateManager setState:(status.data.state ?: @{}) forObject:object];
    }

    [self callBlock:block status:YES withResult:nil andStatus:status];
}

- (void)handleStateResult:(PNChannelClientStateResult *)result
               withStatus:(PNStatus *)status
                  forUUID:(NSString *)uuid
                atChannel:(BOOL)isChannel
                   object:(NSString *)object
           withCompletion:(id)block {

    if (result && [uuid isEqualToString:self.configuration.uuid] && isChannel) {
        [self.clientStateManager setState:(result.data.state ?: @{}) forObject:object];
    }

    [self callBlock:block status:NO withResult:result andStatus:status];
}

#pragma mark -


@end
