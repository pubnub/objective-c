/**
 @author Sergey Mamontov
 @since 4.0
 @copyright © 2009-2016 PubNub, Inc.
 */
#import "PubNub+PresencePrivate.h"
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
 @brief  Request information about subscribers on specific remote data object live feeds.
 @note   This API will retrieve only list of UUIDs for specified remote data object and number of
         subscribers on it.
 
 @param level     Reference on one of \b PNHereNowVerbosityLevel fields to instruct what exactly data it
                  expected in response.
 @param object    Reference on remote data object for which here now information should be received.
 @param operation Reference on one of \b PNOperationType fields to identify which kind on of presence 
                  operation should be performed.
 @param block     Here now processing completion block which pass two arguments: \c result - in case of
                  successful request processing \c data field will contain results of here now operation; 
                  \c status - in case if error occurred during request processing.
 
 @since 4.0
 */
- (void)hereNowWithVerbosity:(PNHereNowVerbosityLevel)level forObject:(nullable NSString *)object 
           withOperationType:(PNOperationType)operation completionBlock:(id)block;

#pragma mark -


@end

NS_ASSUME_NONNULL_END


#pragma mark - Interface implementation

@implementation PubNub (Presence)


#pragma mark - Global here now

- (void)hereNowWithCompletion:(PNGlobalHereNowCompletionBlock)block {

    [self hereNowWithVerbosity:PNHereNowState completion:block];
}

- (void)hereNowWithVerbosity:(PNHereNowVerbosityLevel)level
                  completion:(PNGlobalHereNowCompletionBlock)block {

    [self hereNowWithVerbosity:level forObject:nil withOperationType:PNHereNowGlobalOperation 
               completionBlock:block];
}


#pragma mark - Channel here now

- (void)hereNowForChannel:(NSString *)channel withCompletion:(PNHereNowCompletionBlock)block {

    [self hereNowForChannel:channel withVerbosity:PNHereNowState completion:block];
}

- (void)hereNowForChannel:(NSString *)channel withVerbosity:(PNHereNowVerbosityLevel)level
               completion:(PNHereNowCompletionBlock)block {
    
    [self hereNowWithVerbosity:level forObject:channel withOperationType:PNHereNowForChannelOperation
               completionBlock:block];
}


#pragma mark - Channel group here now

- (void)hereNowForChannelGroup:(NSString *)group
                withCompletion:(PNChannelGroupHereNowCompletionBlock)block {

    [self hereNowForChannelGroup:group withVerbosity:PNHereNowState completion:block];
}

- (void)hereNowForChannelGroup:(NSString *)group withVerbosity:(PNHereNowVerbosityLevel)level
                    completion:(PNChannelGroupHereNowCompletionBlock)block {
    
    [self hereNowWithVerbosity:level forObject:group withOperationType:PNHereNowForChannelGroupOperation
               completionBlock:block];
}

- (void)hereNowWithVerbosity:(PNHereNowVerbosityLevel)level forObject:(nullable NSString *)object 
           withOperationType:(PNOperationType)operation completionBlock:(id)block {

    PNRequestParameters *parameters = [PNRequestParameters new];
    [parameters addQueryParameter:@"1" forFieldName:@"disable_uuids"];
    [parameters addQueryParameter:@"0" forFieldName:@"state"];
    if (level == PNHereNowUUID || level == PNHereNowState){
        
        [parameters addQueryParameter:@"0" forFieldName:@"disable_uuids"];
        if (level == PNHereNowState) { [parameters addQueryParameter:@"1" forFieldName:@"state"]; }
    }
    
    if (operation == PNHereNowGlobalOperation) {
        
        DDLogAPICall([[self class] ddLogLevel], @"<PubNub::API> Global 'here now' information with "
                     "%@ data.", PNHereNowDataStrings[level]);
    }
    else {
        
        if ([object length]) {
            
            [parameters addPathComponent:(operation == PNHereNowForChannelOperation ? 
                                          [PNString percentEscapedString:object] : @",")
                          forPlaceholder:@"{channel}"];
            if (operation == PNHereNowForChannelGroupOperation) {
                
                [parameters addQueryParameter:[PNString percentEscapedString:object] 
                                 forFieldName:@"channel-group"];
            }
        }
        DDLogAPICall([[self class] ddLogLevel], @"<PubNub::API> Channel%@ 'here now' information "
                     "for %@ with %@ data.", (operation == PNHereNowForChannelGroupOperation ? @" group" : @""), 
                     (object?: @"<error>"), PNHereNowDataStrings[level]);
    }
    
    __weak __typeof(self) weakSelf = self;
    [self processOperation:operation withParameters:parameters completionBlock:^(PNResult * _Nullable result,
                                                                                 PNStatus * _Nullable status) {
               
        // Silence static analyzer warnings.
        // Code is aware about this case and at the end will simply call on 'nil' object
        // method. In most cases if referenced object become 'nil' it mean what there is no
        // more need in it and probably whole client instance has been deallocated.
        #pragma clang diagnostic push
        #pragma clang diagnostic ignored "-Wreceiver-is-weak"
        if (status.isError) {

            status.retryBlock = ^{

                [weakSelf hereNowWithVerbosity:level forObject:object withOperationType:operation 
                              completionBlock:block];
            };
        }
        [weakSelf callBlock:block status:NO withResult:result andStatus:status];
        #pragma clang diagnostic pop
    }];
}


#pragma mark - Client where now

- (void)whereNowUUID:(NSString *)uuid withCompletion:(PNWhereNowCompletionBlock)block {

    PNRequestParameters *parameters = [PNRequestParameters new];
    if (uuid.length) {
        
        [parameters addPathComponent:[PNString percentEscapedString:uuid] forPlaceholder:@"{uuid}"];
    }
    DDLogAPICall([[self class] ddLogLevel], @"<PubNub::API> 'Where now' presence information for "
                 "%@.", (uuid?: @"<error>"));

    __weak __typeof(self) weakSelf = self;
    [self processOperation:PNWhereNowOperation withParameters:parameters
           completionBlock:^(PNResult * _Nullable result, PNStatus * _Nullable status) {
               
        // Silence static analyzer warnings.
        // Code is aware about this case and at the end will simply call on 'nil' object
        // method. In most cases if referenced object become 'nil' it mean what there is no
        // more need in it and probably whole client instance has been deallocated.
        #pragma clang diagnostic push
        #pragma clang diagnostic ignored "-Wreceiver-is-weak"
        if (status.isError) {

            status.retryBlock = ^{ [weakSelf whereNowUUID:uuid withCompletion:block]; };
        }
        [weakSelf callBlock:block status:NO withResult:result andStatus:status];
        #pragma clang diagnostic pop
    }];
}


#pragma mark - Heartbeat

- (void)heartbeatWithCompletion:(PNStatusBlock)block {
    
    __weak __typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSArray *channels = [self.subscriberManager channels];
        NSArray *groups = [PNChannel objectsWithOutPresenceFrom:[self.subscriberManager channelGroups]];
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
                
                NSString *stateString = [PNJSON JSONStringFrom:state withError:nil];
                if (stateString.length) {
                    
                    [parameters addQueryParameter:[PNString percentEscapedString:stateString]
                                     forFieldName:@"state"];
                }
            }
            DDLogAPICall([[self class] ddLogLevel], @"<PubNub::API> Heartbeat for channels %@ and "
                         "groups %@.", [channels componentsJoinedByString:@", "],
                         [groups componentsJoinedByString:@", "]);
            
            [self processOperation:PNHeartbeatOperation withParameters:parameters
                   completionBlock:^(PNStatus *status) {
                       
               // Silence static analyzer warnings.
               // Code is aware about this case and at the end will simply call on 'nil' object
               // method. In most cases if referenced object become 'nil' it mean what there is no
               // more need in it and probably whole client instance has been deallocated.
               #pragma clang diagnostic push
               #pragma clang diagnostic ignored "-Wreceiver-is-weak"
               [weakSelf callBlock:block status:YES withResult:nil andStatus:status];
               #pragma clang diagnostic pop
           }];
        }
    });
}

#pragma mark -


@end
