/**
 @author Sergey Mamontov
 @since 4.0
 @copyright © 2009-2015 PubNub, Inc.
 */
#import "PubNub+Presence.h"
#import "PubNub+StatePrivate.h"
#import "PubNub+CorePrivate.h"
#import "PNRequest+Private.h"
#import "PubNub+Subscribe.h"
#import <objc/runtime.h>
#import "PNHelpers.h"


#pragma mark Static

/**
 @brief  Pointer keys which is used to store associated object data.
 
 @since 4.0
 */
static const void *kPubNubHeartbeatTimerQueue = &kPubNubHeartbeatTimerQueue;
static const void *kPubNubHeartbeatTimerStateKey = &kPubNubHeartbeatTimerStateKey;


#pragma mark - Protected interface declaration

@interface PubNub (PresenceProtected)


#pragma mark - Properties

/**
 @brief  Queue which is used to synchronize access to heartbeat timer to make sure what data
         won't be accessed from few threads/queues at the same time.
 
 @return Reference on queue which should be used to synchronize access to heartbeat timer.
 
 @since 4.0
 */
- (dispatch_queue_t)heartbeatTimerAccessQueue;

- (BOOL)isHeartbeatTimerActive;
- (void)setHeartbeatTimerActive:(BOOL)active;

- (void)handleHeartbeatTimer;


#pragma mark - Channel group here now

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


#pragma mark - Processing

/**
 @brief  Try to pre-process provided data and translate it's content to expected from 'Presence 
         Audition' API group.
 
 @param response Reference on Foundation object which should be pre-processed.
 
 @return Pre-processed dictionary or \c nil in case if passed \c response doesn't meet format 
         requirements to be handled by 'Presence Audition' API group.
 
 @since 4.0
 */
- (NSDictionary *)processedPresenceAuditionResponse:(id)response;

/**
 @brief  Try to pre-process provided data and translate it's content to expected from 'Presence 
         Where Now' API.
 
 @param response Reference on Foundation object which should be pre-processed.
 
 @return Pre-processed dictionary or \c nil in case if passed \c response doesn't meet format 
         requirements to be handled by 'Presence Where Now' API.
 
 @since 4.0
 */
- (NSArray *)processedPresenceWhereNowResponse:(id)response;

#pragma mark -


@end


#pragma mark - Interface implementation

@implementation PubNub (Presence)


#pragma mark - Properties

- (dispatch_queue_t)heartbeatTimerAccessQueue {
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        dispatch_queue_t queue = dispatch_queue_create("com.pubnub.presence.heartbeat",
                                                       DISPATCH_QUEUE_CONCURRENT);
        objc_setAssociatedObject(self, kPubNubHeartbeatTimerQueue, queue,
                                 OBJC_ASSOCIATION_RETAIN);
    });
    
    return objc_getAssociatedObject(self, kPubNubHeartbeatTimerQueue);
}

- (BOOL)isHeartbeatTimerActive {
    
    __block BOOL isHeartbeatTimerActive = NO;
    dispatch_sync([self heartbeatTimerAccessQueue], ^{
        
        isHeartbeatTimerActive = [objc_getAssociatedObject(self, kPubNubHeartbeatTimerStateKey) boolValue];
    });
    
    return isHeartbeatTimerActive;
}
- (void)setHeartbeatTimerActive:(BOOL)active {
    
    dispatch_barrier_async([self heartbeatTimerAccessQueue], ^{
        
        objc_setAssociatedObject(self, kPubNubHeartbeatTimerStateKey, @(active),
                                 OBJC_ASSOCIATION_RETAIN);
    });
}


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
    
    __weak __typeof(self) weakSelf = self;
    
    // Dispatching async on private queue which is able to serialize access with client
    // configuration data.
    dispatch_async(self.serviceQueue, ^{
        
        __strong __typeof(self) strongSelf = weakSelf;
        NSString *subscribeKey = [PNString percentEscapedString:strongSelf.subscribeKey];
        NSMutableDictionary *parameters = [@{@"disable_uuids":@"1",@"state":@"0"} mutableCopy];
        if (type == PNHereNowUUID || type == PNHereNowState){
            
            parameters[@"disable_uuids"] = @"0";
            if (type == PNHereNowState) {
                
                parameters[@"state"] = @"1";
            }
        }
        if (!forChannel && object) {
            
            parameters[@"channel-group"] = [PNString percentEscapedString:object];
        }
        NSString *format = [@"/v2/presence/sub-key/%@"
                            stringByAppendingString:((forChannel && object) ? @"/channel/%@":@"")];
        NSString *path = [NSString stringWithFormat:format, subscribeKey,
                          [PNString percentEscapedString:object]];
        PNRequest *request = [PNRequest requestWithPath:path parameters:parameters
                                           forOperation:PNHereNowOperation withCompletion:block];
        request.parseBlock = ^id(id rawData) {
            
            __strong __typeof(self) strongSelfForParsing = weakSelf;
            return [strongSelfForParsing processedPresenceAuditionResponse:rawData];
        };
        [strongSelf processRequest:request];
    });
}


#pragma mark - Client where now

- (void)whereNowUUID:(NSString *)uuid withCompletion:(PNCompletionBlock)block {
    
    __weak __typeof(self) weakSelf = self;
    
    // Dispatching async on private queue which is able to serialize access with client
    // configuration data.
    dispatch_async(self.serviceQueue, ^{
        
        __strong __typeof(self) strongSelf = weakSelf;
        NSString *subscribeKey = [PNString percentEscapedString:strongSelf.subscribeKey];
        NSString *path = [NSString stringWithFormat:@"/v2/presence/sub-key/%@/uuid/%@",
                          subscribeKey, [PNString percentEscapedString:uuid]];
        PNRequest *request = [PNRequest requestWithPath:path parameters:nil
                                           forOperation:PNWhereNowOperation withCompletion:block];
        request.parseBlock = ^id(id rawData) {
            
            __strong __typeof(self) strongSelfForParsing = weakSelf;
            return [strongSelfForParsing processedPresenceWhereNowResponse:rawData];
        };
        [strongSelf processRequest:request];
    });
}


#pragma mark - Heartbeat

- (void)startHeartbeatIfRequired {
    
    __typeof(self) weakSelf = self;
    if (![self isHeartbeatTimerActive]) {
        
        dispatch_async(self.configurationAccessQueue, ^{
            
            __strong __typeof(self) strongSelf = weakSelf;
            if (strongSelf.presenceHeartbeatValue > 0) {
                
                [strongSelf setHeartbeatTimerActive:YES];
                int64_t offset = (int64_t)((NSUInteger)strongSelf.presenceHeartbeatInterval * NSEC_PER_SEC);
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, offset), dispatch_get_main_queue(), ^{
                    
                    __strong __typeof(self) strongSelfForTimer = weakSelf;
                    [strongSelfForTimer handleHeartbeatTimer];
                });
            }
        });
    }
}

- (void)handleHeartbeatTimer {
    
    __typeof(self) weakSelf = self;
    [self setHeartbeatTimerActive:NO];
    dispatch_async(self.configurationAccessQueue, ^{
        
        __strong __typeof(self) strongSelf = weakSelf;
        if (strongSelf.presenceHeartbeatValue > 0) {
            
            NSString *subscribeKey = [PNString percentEscapedString:strongSelf.subscribeKey];
            
            // Prepare channels for heartbeat request.
            NSString *channelsList = [PNChannel namesForRequest:[strongSelf channels]
                                                  defaultString:@","];
            NSString *groupsList = [PNChannel namesForRequest:[strongSelf channelGroups]];
            NSDictionary *state = [strongSelf state];
            
            // Prepare uery parameters basing on available information.
            NSMutableDictionary *parameters = [NSMutableDictionary new];
            parameters[@"heartbeat"] = @(strongSelf.presenceHeartbeatValue);
            if ([groupsList length]) {
                
                parameters[@"channel-group"] = groupsList;
            }
            if ([state count]) {
                
                NSString *stateString = [PNJSON JSONStringFrom:state withError:nil];
                if (stateString) {
                    
                    parameters[@"state"] = stateString;
                }
            }
            NSMutableString *path = [NSMutableString stringWithFormat:@"/v2/presence/sub-key/%@"
                                                                       "/channel/%@/heartbeat",
                                     subscribeKey, channelsList];
            PNRequest *request = [PNRequest requestWithPath:path parameters:parameters
                                               forOperation:PNTimeOperation
                                             withCompletion:^(PNResult *result, PNStatus *status) {
                                                 
                __strong __typeof(self) strongSelfForHandler = weakSelf;
                [strongSelfForHandler startHeartbeatIfRequired];
            }];
            [strongSelf processRequest:request];
        }
    });
}


#pragma mark - Processing

- (NSDictionary *)processedPresenceAuditionResponse:(id)response {
    
    // To handle case when response is unexpected for this type of operation processed value sent
    // through 'nil' initialized local variable.
    NSDictionary *processedResponse = nil;
    
    // Dictionary is valid response type for here now response.
    if ([response isKindOfClass:[NSDictionary class]]) {
        
        NSArray *(^uuidParseBlock)(NSArray *) = ^NSArray *(NSArray *uuids) {
            
            NSMutableArray *parsedUUIDData = [NSMutableArray new];
            for (id uuidData in uuids) {
                
                id parsedData = uuidData;
                if ([uuidData respondsToSelector:@selector(count)]) {
                    
                    NSMutableDictionary *data = [@{@"uuid":uuidData[@"uuid"]} mutableCopy];
                    if (uuidData[@"state"]) {
                        
                        data[@"state"] = uuidData[@"state"];
                    }
                    parsedData = data;
                }
                [parsedUUIDData addObject:parsedData];
            }
            
            return [parsedUUIDData copy];
        };
        // Check whether global here now has been performed or not
        if (response[@"payload"][@"channels"]) {
            
            // Composing initial response content.
            NSMutableDictionary *data = [@{@"total_channels":response[@"payload"][@"total_channels"],
                                           @"total_occupancy":response[@"payload"][@"total_occupancy"]
                                           } mutableCopy];
            for (NSDictionary *channelName in response[@"payload"][@"channels"]) {
                
                NSDictionary *channelData = response[@"payload"][@"channels"][channelName];
                NSMutableDictionary *parsedChannelData = [@{@"occupancy":channelData[@"occupancy"]
                                                            } mutableCopy];
                if (channelData[@"uuids"]) {
                    
                    parsedChannelData[@"uuids"] = uuidParseBlock(channelData[@"uuids"]);
                }
                
                data[channelName] = parsedChannelData;
            }
            processedResponse = data;
        }
        else if (response[@"uuids"]){
            
            processedResponse = @{@"occupancy":response[@"occupancy"],
                                  @"uuids":uuidParseBlock(response[@"uuids"])};
        }
        else if (response[@"occupancy"]){
            
            processedResponse = @{@"occupancy":response[@"occupancy"]};
        }
    }
    
    return [processedResponse copy];
}

- (NSArray *)processedPresenceWhereNowResponse:(id)response {
    
    // To handle case when response is unexpected for this type of operation processed value sent
    // through 'nil' initialized local variable.
    NSArray *processedResponse = nil;
    
    // Dictionary is valid response type for where now response.
    if ([response isKindOfClass:[NSDictionary class]] && response[@"payload"][@"channels"]) {
        
        processedResponse = response[@"payload"][@"channels"];
    }
    
    return [processedResponse copy];
}

#pragma mark -


@end
