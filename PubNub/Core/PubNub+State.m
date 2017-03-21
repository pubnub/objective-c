/**
 @author Sergey Mamontov
 @since 4.0
 @copyright © 2009-2017 PubNub, Inc.
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
 @brief  Modify state information for \c uuid on specified remote data object.
 
 @param state     Reference on dictionary which should be bound to \c uuid on remote data object.
 @param uuid      Reference on unique user identifier for which state should be bound.
 @param onChannel Whether state has been provided for channel or channel group.
 @param object    Name of remote data object which will store provided state information for \c uuid.
 @param block     State modification for user on channel processing completion block which pass only
                  one argument - request processing status to report about how data pushing was 
                  successful or not.
 
 @since 4.0
 */
- (void)setState:(nullable NSDictionary<NSString *, id> *)state forUUID:(NSString *)uuid 
       onChannel:(BOOL)onChannel withName:(NSString *)object 
  withCompletion:(nullable PNSetStateCompletionBlock)block;

/**
 @brief  Retrieve state information for \c uuid on specified remote data object.

 @param uuid      Reference on unique user identifier for which state should be retrieved.
 @param onChannel Whether state has been provided for channel or channel group.
 @param object    Name of remote data object from which state information for \c uuid will be pulled out.
 @param block     State audition for user on remote data object processing completion block which pass two 
                  arguments: \c result - in case of successful request processing \c data field will contain 
                  results of client state retrieve operation; \c status - in case if error occurred during 
                  request processing.
 
 @since 4.0
 */
- (void)stateForUUID:(NSString *)uuid onChannel:(BOOL)onChannel withName:(NSString *)object
      withCompletion:(id)block;


#pragma mark - Handlers

/**
 @brief  Process client state modification request completion and notify observers about results.

 @param status Reference on state modification status instance.
 @param uuid   Reference on unique user identifier for which state should be updated.
 @param object Name of remote data object for which state information for \c uuid had been bound.
 @param block  State modification for user on channel processing completion block which pass only one 
               argument - request processing status to report about how data pushing was successful or not.

 @since 4.0
 */
- (void)handleSetStateStatus:(PNClientStateUpdateStatus *)status forUUID:(NSString *)uuid
                    atObject:(NSString *)object withCompletion:(nullable PNSetStateCompletionBlock)block;

/**
 @brief  Process client state audition request completion and notify observers about results.

 @param result    Reference on service response results instance.
 @param status    Reference on state request status instance.
 @param uuid      Reference on unique user identifier for which state should be retrieved.
 @param isChannel Whether received state information for channel or not.
 @param object    Name of remote data object from which state information for \c uuid will be pulled out.
 @param block     State audition for user on channel processing completion block which pass two arguments:
                  \c result - in case of successful request processing \c data field will contain results of
                  client state retrieve operation; \c status - in case if error occurred during request
                  processing.

 @since 4.0
 */
- (void)handleStateResult:(nullable PNChannelClientStateResult *)result withStatus:(nullable PNStatus *)status
                  forUUID:(NSString *)uuid atChannel:(BOOL)isChannel object:(NSString *)object
           withCompletion:(id)block;

#pragma mark - 


@end

NS_ASSUME_NONNULL_END


#pragma mark Interface implementation

@implementation PubNub (State)


#pragma mark - API Builder support

- (PNStateAPICallBuilder *(^)(void))state {
    
    PNStateAPICallBuilder *builder = nil;
    builder = [PNStateAPICallBuilder builderWithExecutionBlock:^(NSArray<NSString *> *flags, 
                                                                 NSDictionary *parameters) {
                            
        NSString *uuid = parameters[NSStringFromSelector(@selector(uuid))];
        NSString *object = (parameters[NSStringFromSelector(@selector(channel))]?: 
                            parameters[NSStringFromSelector(@selector(channelGroup))]);
        BOOL forChannel = (parameters[NSStringFromSelector(@selector(channel))] != nil);
        NSDictionary *state = parameters[NSStringFromSelector(@selector(state))];
        id block = parameters[@"block"];
        if ([flags containsObject:NSStringFromSelector(@selector(audit))]) {
            
            [self stateForUUID:uuid onChannel:forChannel withName:object withCompletion:block];
        }
        else { [self setState:state forUUID:uuid onChannel:forChannel withName:object withCompletion:block]; }
    }];
    
    return ^PNStateAPICallBuilder *{ return builder; };
}


#pragma mark - Client state information manipulation

- (void)setState:(NSDictionary<NSString *, id> *)state forUUID:(NSString *)uuid onChannel:(NSString *)channel 
  withCompletion:(PNSetStateCompletionBlock)block {
    
    [self setState:state forUUID:uuid onChannel:YES withName:channel withCompletion:block];
}

- (void)setState:(NSDictionary<NSString *, id> *)state forUUID:(NSString *)uuid 
  onChannelGroup:(NSString *)group withCompletion:(PNSetStateCompletionBlock)block {
    
    [self setState:state forUUID:uuid onChannel:NO withName:group withCompletion:block];
}

- (void)setState:(NSDictionary<NSString *, id> *)state forUUID:(NSString *)uuid onChannel:(BOOL)onChannel 
        withName:(NSString *)object withCompletion:(PNSetStateCompletionBlock)block {
    
    __weak __typeof(self) weakSelf = self;
    dispatch_queue_t queue = (self.configuration.applicationExtensionSharedGroupIdentifier != nil ? dispatch_get_main_queue() :
                              dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0));
    dispatch_async(queue, ^{
        
        __strong __typeof__(weakSelf) strongSelf = weakSelf;
        PNRequestParameters *parameters = [PNRequestParameters new];
        [parameters addPathComponent:(onChannel ? [PNString percentEscapedString:object] : @",")
                      forPlaceholder:@"{channel}"];
        NSString *stateString = ([PNJSON JSONStringFrom:state withError:NULL]?: @"{}");
        [parameters addQueryParameter:[PNString percentEscapedString:stateString]
                         forFieldName:@"state"];
        if (uuid.length) {
            
            [parameters addPathComponent:[PNString percentEscapedString:uuid] forPlaceholder:@"{uuid}"];
        }
        if (!onChannel && object.length) {
            
            [parameters addQueryParameter:[PNString percentEscapedString:object]
                             forFieldName:@"channel-group"];
        }
        
        DDLogAPICall(strongSelf.logger, @"<PubNub::API> Set %@'s state on '%@' channel%@: %@.", 
                     (uuid?: @"<error>"), (object?: @"<error>"), (!onChannel ? @" group" : @""), 
                     parameters.query[@"state"]);
        
        [strongSelf processOperation:PNSetStateOperation withParameters:parameters
                     completionBlock:^(PNStatus *status) {
                   
           // Silence static analyzer warnings.
           // Code is aware about this case and at the end will simply call on 'nil' object method.
           // In most cases if referenced object become 'nil' it mean what there is no more need in
           // it and probably whole client instance has been deallocated.
           #pragma clang diagnostic push
           #pragma clang diagnostic ignored "-Wreceiver-is-weak"
           if (status.isError) {
                
               status.retryBlock = ^{
                   
                   [weakSelf setState:state forUUID:uuid onChannel:onChannel withName:object
                       withCompletion:block];
               };
           }
           [weakSelf handleSetStateStatus:(PNClientStateUpdateStatus *)status
                                  forUUID:uuid atObject:object withCompletion:block];
           #pragma clang diagnostic pop
       }];
    });
}


#pragma mark - Client state information audit

- (void)stateForUUID:(NSString *)uuid onChannel:(NSString *)channel
      withCompletion:(PNChannelStateCompletionBlock)block {
    
    [self stateForUUID:uuid onChannel:YES withName:channel withCompletion:block];
}

- (void)stateForUUID:(NSString *)uuid onChannelGroup:(NSString *)group
      withCompletion:(PNChannelGroupStateCompletionBlock)block {
    
    [self stateForUUID:uuid onChannel:NO withName:group withCompletion:block];
}

- (void)stateForUUID:(NSString *)uuid onChannel:(BOOL)onChannel withName:(NSString *)object
      withCompletion:(id)block {
    
    PNRequestParameters *parameters = [PNRequestParameters new];
    [parameters addPathComponent:(onChannel ? [PNString percentEscapedString:object] : @",")
                  forPlaceholder:@"{channel}"];
    if (uuid.length) {
        
        [parameters addPathComponent:[PNString percentEscapedString:uuid] forPlaceholder:@"{uuid}"];
    }
    if (!onChannel && object.length) {
        
        [parameters addQueryParameter:[PNString percentEscapedString:object] forFieldName:@"channel-group"];
    }
    
    DDLogAPICall(self.logger, @"<PubNub::API> State request on '%@' channel%@: %@.", (uuid?: @"<error>"), 
                 (object?: @"<error>"), (!onChannel ? @" group" : @""));
    
    __weak __typeof(self) weakSelf = self;
    [self processOperation:(onChannel ? PNStateForChannelOperation : PNStateForChannelGroupOperation)
            withParameters:parameters 
           completionBlock:^(PNResult *result, PNStatus *status) {
               
        // Silence static analyzer warnings.
        // Code is aware about this case and at the end will simply call on 'nil' object method.
        // In most cases if referenced object become 'nil' it mean what there is no more need in
        // it and probably whole client instance has been deallocated.
        #pragma clang diagnostic push
        #pragma clang diagnostic ignored "-Wreceiver-is-weak"
        if (status.isError) {
            
            status.retryBlock = ^{
                
                [weakSelf stateForUUID:uuid onChannel:onChannel withName:object withCompletion:block];
            };
        }
        [weakSelf handleStateResult:(PNChannelClientStateResult *)result withStatus:status
                            forUUID:uuid atChannel:onChannel object:object withCompletion:block];
        #pragma clang diagnostic pop
    }];
}


#pragma mark - Handlers

- (void)handleSetStateStatus:(PNClientStateUpdateStatus *)status forUUID:(NSString *)uuid
                    atObject:(NSString *)object withCompletion:(PNSetStateCompletionBlock)block {
    
    // Check whether state modification to the client has been successful or not.
    if (status && !status.isError && [uuid isEqualToString:self.configuration.uuid]) {

        // Overwrite cached state information.
        [self.clientStateManager setState:(status.data.state?: @{}) forObject:object];
    }
    [self callBlock:block status:YES withResult:nil andStatus:(PNStatus *)status];
}

- (void)handleStateResult:(PNChannelClientStateResult *)result withStatus:(PNStatus *)status
                  forUUID:(NSString *)uuid atChannel:(BOOL)isChannel object:(NSString *)object
           withCompletion:(id)block {
    
    // Check whether state successfully fetched or not.
    if (result && [uuid isEqualToString:self.configuration.uuid] && isChannel) {

        // Overwrite cached state information.
        [self.clientStateManager setState:(result.data.state?: @{}) forObject:object];
    }
    [self callBlock:block status:NO withResult:(PNResult *)result andStatus:status];
}

#pragma mark -


@end
