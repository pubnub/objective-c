/**
 @author Sergey Mamontov
 @since 4.0
 @copyright © 2009-2015 PubNub, Inc.
 */
#import "PubNub+StatePrivate.h"
#import "PubNub+CorePrivate.h"
#import "PNRequest+Private.h"
#import <objc/runtime.h>
#import "PNErrorCodes.h"
#import "PNHelpers.h"
#import "PNResult.h"
#import "PNStatus.h"


#pragma mark Static

/**
 @brief  Pointer keys which is used to store associated object data.
 
 @since 4.0
 */
static const void *kPubNubStateCache = &kPubNubStateCache;
static const void *kPubNubStateCacheSynchronizationQueue = &kPubNubStateCacheSynchronizationQueue;


#pragma mark - Protected interface declaration

@interface PubNub (StateProtected)


#pragma mark - Properties

/**
 @brief  Queue which is used to synchronize access to client state cache to make sure what data 
         won't be accessed from few threads/queues at the same time.
 
 @return Reference on queue which should be used to synchronize access to state cache.
 
 @since 4.0
 */
- (dispatch_queue_t)stateAccessQueue;

/**
 @brief  Retrieve reference on mutable state cache which can be used for merging and clean up.
 
 @return Mutable state cache dictionary.
 
 @since 4.0
 */
- (NSMutableDictionary *)mutableState;


#pragma mark - Client state information manipulation

/**
 @brief  Modify state information for \c uuid on specified remote data object.
 
 @param state     Reference on dictionary which should be bound to \c uuid on remote data object.
 @param uuid      Reference on unique user identifier for which state should be bound.
 @param onChannel Whether state has been provided for channel or channel group.
 @param object    Name of remote data object which will store provided state information for 
                  \c uuid.
 @param block     State modification for user on remote data object processing completion block 
                  which pass two arguments: \c result - in case of successful request processing 
                  \c data field will contain results of client state update operation;
                  \c status - in case if error occurred during request processing.
 
 @since 4.0
 */
- (void)setState:(NSDictionary *)state forUUID:(NSString *)uuid onChannel:(BOOL)onChannel
        withName:(NSString *)object withCompletion:(PNCompletionBlock)block;

/**
 @brief  Handle client state modification completion.

 @param state  Reference on dictionary which has been bound to \c uuid on remote data object.
 @param uuid   Reference on unique user identifier for which state should be updated.
 @param object Name of remote data object for which state information for \c uuid had been bound.
 @param result Reference on operation processing results (success).
 @param status Reference on operation processing status (usually reported during issues).

 @since 4.0
 */
- (void)handleSetState:(NSDictionary *)state forUUID:(NSString *)uuid forObject:(NSString *)object
            withResult:(PNResult *)result andStatus:(PNStatus *)status;

/**
 @brief  Retrieve state information for \c uuid on specified remote data object.

 @param uuid      Reference on unique user identifier for which state should be retrieved.
 @param onChannel Whether state has been provided for channel or channel group.
 @param object    Name of remote data object from which state information for \c uuid will be pulled
                  out.
 @param block     State audition for user on remote data object processing completion block which 
                  pass two arguments: \c result - in case of successful request processing \c data
                  field will contain results of client state retrieve operation; \c status - in case
                  if error occurred during request processing.
 
 @since 4.0
 */
- (void)stateForUUID:(NSString *)uuid onChannel:(BOOL)onChannel withName:(NSString *)object
      withCompletion:(PNCompletionBlock)block;

/**
 @brief  Handle client state audition completion.

 @param uuid   Reference on unique user identifier for which state should be retrieved.
 @param object Name of remote data object from which state information for \c uuid will be pulled
               out.
 @param result Reference on operation processing results (success).
 @param status Reference on operation processing status (usually reported during issues).

 @since 4.0
 */
- (void)handleStateForUUID:(NSString *)uuid forObject:(NSString *)object
                withResult:(PNResult *)result andStatus:(PNStatus *)status;


#pragma mark - Processing

/**
 @brief  Try to pre-process provided data and translate it's content to expected from 'State update'
         API.
 
 @param response Reference on Foundation object which should be pre-processed.
 
 @return Pre-processed dictionary or \c nil in case if passed \c response doesn't meet format 
         requirements to be handled by 'State update' API.
 
 @since 4.0
 */
- (NSDictionary *)processedStateResponse:(id)response;

#pragma mark - 


@end


#pragma mark Interface implementation

@implementation PubNub (State)


#pragma mark - Client state cache

- (dispatch_queue_t)stateAccessQueue {
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        dispatch_queue_t queue = dispatch_queue_create("com.pubnub.state.cache",
                                                       DISPATCH_QUEUE_CONCURRENT);
        objc_setAssociatedObject(self, kPubNubStateCacheSynchronizationQueue, queue,
                                 OBJC_ASSOCIATION_RETAIN);
    });
    
    return objc_getAssociatedObject(self, kPubNubStateCacheSynchronizationQueue);
}

- (NSMutableDictionary *)mutableState {
    
    __block NSMutableDictionary *mutableState = nil;
    dispatch_sync([self stateAccessQueue], ^{
        
        mutableState = objc_getAssociatedObject(self, kPubNubStateCache);
        if (!mutableState) {
            
            mutableState = [NSMutableDictionary new];
            objc_setAssociatedObject(self, kPubNubStateCache, mutableState,
                                     OBJC_ASSOCIATION_RETAIN);
        }
    });
    
    return mutableState;
}

- (NSDictionary *)state {
    
    NSDictionary *state = [[self mutableState] copy];
    
    return ([state count] ? state : nil);
}

- (NSDictionary *)stateMergedWith:(NSDictionary *)state forObjects:(NSArray *)objects {
    
    NSMutableDictionary *mutableState = [([self state]?: @{}) mutableCopy];
    [state enumerateKeysAndObjectsUsingBlock:^(NSString *objectName,
                                               NSDictionary *stateForObject,
                                               BOOL *stateEnumeratorStop) {
        
        // Check whether cache already store information for specified object or not.
        if (mutableState[objectName] != nil) {
            
            // Clean up cached version (if required)
            NSMutableDictionary *cachedObjectState = mutableState[objectName];
            [cachedObjectState addEntriesFromDictionary:stateForObject];
            [[cachedObjectState copy] enumerateKeysAndObjectsUsingBlock:^(NSString *fieldName,
                                                                          id fieldValue,
                                                                          BOOL *fieldsEnumeratorStop) {
                
                // In case if provided data is 'nil' it should be removed from previous state
                // dictionary.
                if ([fieldValue isKindOfClass:[NSNull class]]) {
                    
                    [cachedObjectState removeObjectForKey:fieldName];
                }
            }];
        }
        // Checking whether state contains some data or not.
        // In case if state object is empty it mean what client state information will be
        // removed with next subscribe/heartbeat request.
        else if ([stateForObject count] && [objects containsObject:objectName]) {
            
            mutableState[objectName] = stateForObject;
        }
    }];
    
    [[mutableState allKeys] enumerateObjectsUsingBlock:^(NSString *objectName,
                                                         NSUInteger objectNameIdx,
                                                         BOOL *objectNamesEnumeratorStop) {
        if (![objects containsObject:objectName]) {
            
            [mutableState removeObjectForKey:objectName];
        }
    }];
    
    return [mutableState copy];
}

- (void)mergeWithState:(NSDictionary *)state {

    if ([state count]) {

        NSMutableDictionary *mutableState = [self mutableState];
        dispatch_barrier_async([self stateAccessQueue], ^{

            [state enumerateKeysAndObjectsUsingBlock:^(NSString *objectName,
                    NSDictionary *stateForObject,
                    BOOL *stateEnumeratorStop) {

                // Check whether cache already store information for specified object or not.
                if (mutableState[objectName] != nil) {

                    // Clean up cached version (if required)
                    NSMutableDictionary *cachedObjectState = [mutableState[objectName] mutableCopy];
                    [cachedObjectState addEntriesFromDictionary:stateForObject];
                    mutableState[objectName] = [cachedObjectState copy];
                }
                else {

                    mutableState[objectName] = stateForObject;
                }
            }];

        });
    }
}

- (void)setState:(NSDictionary *)state forObject:(NSString *)object {

    NSMutableDictionary *mutableState = [self mutableState];
    dispatch_barrier_async([self stateAccessQueue], ^{

        if ([state count]) {

            mutableState[object] = state;
        }
        else {

            [mutableState removeObjectForKey:object];
        }
    });
}


#pragma mark - Client state information manipulation

- (void)setState:(NSDictionary *)state forUUID:(NSString *)uuid onChannel:(NSString *)channel
  withCompletion:(PNCompletionBlock)block {
    
    [self setState:state forUUID:uuid onChannel:YES withName:channel withCompletion:block];
}

- (void)setState:(NSDictionary *)state forUUID:(NSString *)uuid onChannelGroup:(NSString *)group
  withCompletion:(PNCompletionBlock)block {
    
    [self setState:state forUUID:uuid onChannel:NO withName:group withCompletion:block];
}

- (void)setState:(NSDictionary *)state forUUID:(NSString *)uuid onChannel:(BOOL)onChannel
        withName:(NSString *)object withCompletion:(PNCompletionBlock)block {

    // Dispatching async on private queue which is able to serialize access with client
    // configuration data.
    __weak __typeof(self) weakSelf = self;
    dispatch_async(self.serviceQueue, ^{
        
        __strong __typeof(self) strongSelf = weakSelf;
        NSString *subscribeKey = [PNString percentEscapedString:strongSelf.subscribeKey];
        NSString *channel = (onChannel ? [PNString percentEscapedString:object] : @".");
        NSString *stateString = [PNJSON JSONStringFrom:state withError:NULL];
        NSMutableDictionary *parameters = [@{@"state": (stateString?:@"{}")} mutableCopy];
        if (!onChannel && [object length]) {
            
            parameters[@"channel-group"] = [PNString percentEscapedString:object];
        }
        NSString *path = [NSString stringWithFormat:@"/v2/presence/sub-key/%@/channel/%@/uuid/%@/data",
                          subscribeKey, channel, [PNString percentEscapedString:uuid]];
        PNRequest *request = [PNRequest requestWithPath:path parameters:parameters
                                           forOperation:PNSetStateOperation
                                         withCompletion:^(PNResult *result, PNStatus *status) {

            __strong __typeof(self) strongSelfForResults = weakSelf;
            [strongSelfForResults handleSetState:state forUUID:uuid forObject:object
                                      withResult:result andStatus:status];
            [strongSelfForResults callBlock:[block copy] withResult:result andStatus:status];
        }];
        request.parseBlock = ^id(id rawData) {
            
            __strong __typeof(self) strongSelfForParsing = weakSelf;
            return [strongSelfForParsing processedStateResponse:rawData];
        };
        
        DDLogAPICall(@"<PubNub> Set %@'s state on '%@' channel%@: %@.", (uuid?: @"<error>"),
                     (object?: @"<error>"), (!onChannel ? @" group" : @""), parameters[@"state"]);

        // Ensure what all required fields passed before starting processing.
        if ([uuid length] && [object length]) {

            [strongSelf processRequest:request];
        }
        // Notify about incomplete parameters set.
        else {

            NSString *description = @"UUID not specified.";
            if (![object length]) {

                description = (onChannel ? @"Channel not specified":@"Channel group not specified");
            }
            NSError *error = [NSError errorWithDomain:kPNAPIErrorDomain
                                                 code:kPNAPIUnacceptableParameters
                                             userInfo:@{NSLocalizedDescriptionKey:description}];
            [strongSelf handleRequestFailure:request withError:error];
        }
    });
}

- (void)handleSetState:(NSDictionary *)state forUUID:(NSString *)uuid forObject:(NSString *)object
            withResult:(PNResult *)result andStatus:(PNStatus *)status {

    // Check whether state modification to the client has been successful or not.
    if (result && [uuid isEqualToString:self.uuid]) {

        // Overwrite cached state information.
        [self setState:state forObject:object];
    }
}


#pragma mark - Client state information audit

- (void)stateForUUID:(NSString *)uuid onChannel:(NSString *)channel
      withCompletion:(PNCompletionBlock)block {
    
    [self stateForUUID:uuid onChannel:YES withName:channel withCompletion:block];
}

- (void)stateForUUID:(NSString *)uuid onChannelGroup:(NSString *)group
      withCompletion:(PNCompletionBlock)block {
    
    [self stateForUUID:uuid onChannel:NO withName:group withCompletion:block];
}

- (void)stateForUUID:(NSString *)uuid onChannel:(BOOL)onChannel withName:(NSString *)object
      withCompletion:(PNCompletionBlock)block {

    // Dispatching async on private queue which is able to serialize access with client
    // configuration data.
    __weak __typeof(self) weakSelf = self;
    dispatch_async(self.serviceQueue, ^{
        
        __strong __typeof(self) strongSelf = weakSelf;
        NSString *subscribeKey = [PNString percentEscapedString:strongSelf.subscribeKey];
        NSString *channel = (onChannel ? [PNString percentEscapedString:object] : @".");
        NSDictionary *parameters = nil;
        if (!onChannel && [object length]) {

            parameters = @{@"channel-group": [PNString percentEscapedString:object]};
        }
        NSString *path = [NSString stringWithFormat:@"/v2/presence/sub-key/%@/channel/%@/uuid/%@",
                          subscribeKey, channel, [PNString percentEscapedString:uuid]];
        PNRequest *request = [PNRequest requestWithPath:path parameters:parameters
                                           forOperation:PNStateOperation
                                         withCompletion:^(PNResult *result, PNStatus *status) {

            __strong __typeof(self) strongSelfForResults = weakSelf;
            [strongSelfForResults handleStateForUUID:uuid forObject:object withResult:result
                                           andStatus:status];
            [strongSelfForResults callBlock:[block copy] withResult:result andStatus:status];
        }];
        request.parseBlock = ^id(id rawData) {
            
            __strong __typeof(self) strongSelfForParsing = weakSelf;
            return [strongSelfForParsing processedStateResponse:rawData];
        };

        // Ensure what all required fields passed before starting processing.
        if ([uuid length] && [object length]) {

            [strongSelf processRequest:request];
        }
        // Notify about incomplete parameters set.
        else {

            NSString *description = @"UUID not specified.";
            if (![object length]) {

                description = (onChannel ? @"Channel not specified":@"Channel group not specified");
            }
            NSError *error = [NSError errorWithDomain:kPNAPIErrorDomain
                                                 code:kPNAPIUnacceptableParameters
                                             userInfo:@{NSLocalizedDescriptionKey:description}];
            [strongSelf handleRequestFailure:request withError:error];
        }
    });
}

- (void)handleStateForUUID:(NSString *)uuid forObject:(NSString *)object
                withResult:(PNResult *)result andStatus:(PNStatus *)status {

    // Check whether state modification to the client has been successful or not.
    if (result && [uuid isEqualToString:self.uuid]) {

        // Overwrite cached state information.
        [self setState:result.data forObject:object];
    }
}


#pragma mark - Processing

- (NSDictionary *)processedStateResponse:(id)response {
    
    // To handle case when response is unexpected for this type of operation processed value sent
    // through 'nil' initialized local variable.
    NSDictionary *processedResponse = nil;
    
    // Dictionary is valid response type for state update.
    if ([response isKindOfClass:[NSDictionary class]]) {
        
        processedResponse = @{@"state": response[@"payload"],
                              @"status": @([response[@"message"] isEqualToString:@"OK"])};
    }
    
    return [processedResponse copy];
}

#pragma mark -


@end
