/**
 @author Sergey Mamontov
 @since 4.0
 @copyright © 2009-2015 PubNub, Inc.
 */
#import "PubNub+PresencePrivate.h"
#import "PNPrivateStructures.h"
#import "PNRequestParameters.h"
#import "PubNub+CorePrivate.h"
#import "PNConfiguration.h"
#import "PNClientState.h"
#import "PNSubscriber.h"
#import "PNHelpers.h"



#pragma mark - Protected interface declaration

@interface PubNub (PresenceProtected)


#pragma mark - Channel/Channel group here now

/**
 @brief  Request information about subscribers on specific remote data object live feeds.
 @note   This API will retrieve only list of UUIDs for specified remote data object and number of
         subscribers on it.
 
 @param type       Reference on one of \b PNHereNowDataType fields to instruct what exactly data it
                   expected in response.
 @param forChannel Whether 'here now' information should be pulled for channel or group.
 @param object     Reference on remote data object for which here now information should be 
                   received.
 @param block      Here now processing completion block which pass two arguments: \c result - in 
                   case of successful request processing \c data field will contain results of here 
                   now operation; \c status - in case if error occurred during request processing.
 
 @since 4.0
 */
- (void)hereNowData:(PNHereNowDataType)type forChannel:(BOOL)forChannel withName:(NSString *)object
     withCompletion:(PNCompletionBlock)block;

#pragma mark -


@end


#pragma mark - Interface implementation

@implementation PubNub (Presence)


#pragma mark - Global here now

- (void)hereNowWithCompletion:(PNCompletionBlock)block {
    
    [self hereNowData:PNHereNowUUID withCompletion:block];
}

- (void)hereNowData:(PNHereNowDataType)type withCompletion:(PNCompletionBlock)block {
    
    [self hereNowData:type forChannel:nil withCompletion:block];
}


#pragma mark - Channel here now

- (void)hereNowForChannel:(NSString *)channel withCompletion:(PNCompletionBlock)block {
    
    [self hereNowData:PNHereNowUUID forChannel:channel withCompletion:block];
}

- (void)hereNowData:(PNHereNowDataType)type forChannel:(NSString *)channel
     withCompletion:(PNCompletionBlock)block {
    
    [self hereNowData:type forChannel:YES withName:channel withCompletion:block];
}


#pragma mark - Channel group here now

- (void)hereNowForChannelGroup:(NSString *)group withCompletion:(PNCompletionBlock)block {
    
    [self hereNowData:PNHereNowUUID forChannel:NO withName:group withCompletion:block];
}

- (void)hereNowData:(PNHereNowDataType)type forChannelGroup:(NSString *)group
     withCompletion:(PNCompletionBlock)block {
    
    [self hereNowData:type forChannel:NO withName:group withCompletion:block];
}

- (void)hereNowData:(PNHereNowDataType)type forChannel:(BOOL)forChannel withName:(NSString *)object
     withCompletion:(PNCompletionBlock)block {

    PNRequestParameters *parameters = [PNRequestParameters new];
    [parameters addQueryParameter:@"1" forFieldName:@"disable_uuids"];
    [parameters addQueryParameter:@"0" forFieldName:@"state"];
    if (type == PNHereNowUUID || type == PNHereNowState){
        
        [parameters addQueryParameter:@"0" forFieldName:@"disable_uuids"];
        if (type == PNHereNowState) {
            
            [parameters addQueryParameter:@"1" forFieldName:@"state"];
        }
    }
    if ([object length]) {
        
        if (forChannel) {
            
            [parameters addPathComponent:[PNString percentEscapedString:object]
                          forPlaceholder:@"{channel}"];
        }
        else {
            
            [parameters addQueryParameter:[PNString percentEscapedString:object]
                             forFieldName:@"channel-group"];
        }
    }
    
    if (![object length]) {
        
        DDLogAPICall(@"<PubNub> Global 'here now' information with %@ data.",
                     PNHereNowDataStrings[type]);
    }
    else {
        
        DDLogAPICall(@"<PubNub> Channel%@ 'here now' information for %@ with %@ data.",
                     (!forChannel ? @" group" : @""), (object?: @"<error>"),
                     PNHereNowDataStrings[type]);
    }
    
    PNCompletionBlock blockCopy = [block copy];
    __weak __typeof(self) weakSelf = self;
    [self processOperation:(![object length] ? PNHereNowGlobalOperation : PNHereNowOperation)
            withParameters:parameters completionBlock:^(PNResult *result, PNStatus *status) {
               
               // Silence static analyzer warnings.
               // Code is aware about this case and at the end will simply call on 'nil' object method.
               // This instance is one of client properties and if client already deallocated there is
               // no need to this object which will be deallocated as well.
               #pragma clang diagnostic push
               #pragma clang diagnostic ignored "-Wreceiver-is-weak"
               #pragma clang diagnostic ignored "-Warc-repeated-use-of-weak"
               [weakSelf callBlock:blockCopy status:NO withResult:result andStatus:status];
               #pragma clang diagnostic pop
           }];
}


#pragma mark - Client where now

- (void)whereNowUUID:(NSString *)uuid withCompletion:(PNCompletionBlock)block {

    PNRequestParameters *parameters = [PNRequestParameters new];
    if ([uuid length]) {
        
        [parameters addPathComponent:[PNString percentEscapedString:uuid] forPlaceholder:@"{uuid}"];
    }
    DDLogAPICall(@"<PubNub> 'Where now' presence information for %@.", (uuid?: @"<error>"));

    PNCompletionBlock blockCopy = [block copy];
    __weak __typeof(self) weakSelf = self;
    [self processOperation:PNWhereNowOperation withParameters:parameters
           completionBlock:^(PNResult *result, PNStatus *status) {
               
               // Silence static analyzer warnings.
               // Code is aware about this case and at the end will simply call on 'nil' object method.
               // This instance is one of client properties and if client already deallocated there is
               // no need to this object which will be deallocated as well.
               #pragma clang diagnostic push
               #pragma clang diagnostic ignored "-Wreceiver-is-weak"
               #pragma clang diagnostic ignored "-Warc-repeated-use-of-weak"
               [weakSelf callBlock:blockCopy status:NO withResult:result andStatus:status];
               #pragma clang diagnostic pop
           }];
}


#pragma mark - Heartbeat

- (void)heartbeatWithCompletion:(PNStatusBlock)block {
    
    PNStatusBlock blockCopy = [block copy];
    __weak __typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSArray *channels = [self.subsceriberManager channels];
        NSArray *groups = [PNChannel objectsWithOutPresenceFrom:[self.subsceriberManager channelGroups]];
        if (self.configuration.presenceHeartbeatValue > 0 && ([channels count] || [groups count])) {
            
            PNRequestParameters *parameters = [PNRequestParameters new];
            [parameters addPathComponent:[PNChannel namesForRequest:channels defaultString:@","]
                          forPlaceholder:@"{channels}"];
            if ([groups count]) {
                
                [parameters addQueryParameter:[PNChannel namesForRequest:groups]
                                 forFieldName:@"channel-group"];
            }
            [parameters addQueryParameter:[@(self.configuration.presenceHeartbeatValue) stringValue]
                             forFieldName:@"heartbeat"];
            NSDictionary *state = [self.clientStateManager state];
            if ([state count]) {
                
                NSString *stateString = [PNJSON JSONStringFrom:state withError:nil];
                if ([stateString length]) {
                    
                    [parameters addQueryParameter:[PNString percentEscapedString:stateString]
                                     forFieldName:@"state"];
                }
            }
            DDLogAPICall(@"<PubNub> Heartbeat for channels %@ and groups %@.",
                         [channels componentsJoinedByString:@", "],
                         [groups componentsJoinedByString:@", "]);
            
            [self processOperation:PNHeartbeatOperation withParameters:parameters
                   completionBlock:^(PNStatus *status) {
                       
                       // Silence static analyzer warnings.
                       // Code is aware about this case and at the end will simply call on 'nil'
                       // object method. This instance is one of client properties and if client
                       // already deallocated there is no need to this object which will be
                       // deallocated as well.
                       #pragma clang diagnostic push
                       #pragma clang diagnostic ignored "-Wreceiver-is-weak"
                       #pragma clang diagnostic ignored "-Warc-repeated-use-of-weak"
                       [weakSelf callBlock:blockCopy status:YES withResult:nil andStatus:status];
                       #pragma clang diagnostic pop
                   }];
        }
    });
}

#pragma mark -


@end
