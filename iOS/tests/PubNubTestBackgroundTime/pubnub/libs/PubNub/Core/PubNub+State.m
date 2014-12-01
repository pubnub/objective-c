/**
 
 @author Sergey Mamontov
 @version 3.7.0
 @copyright © 2009-14 PubNub Inc.
 
 */

#import "PubNub+State.h"
#import "PNClientStateUpdateRequest.h"
#import "NSObject+PNAdditions.h"
#import "PNClientStateRequest.h"
#import "PNChannel+Protected.h"
#import "PubNub+Subscription.h"
#import "PNServiceChannel.h"
#import "PubNub+Protected.h"
#import "PNNotifications.h"
#import "PNHelper.h"
#import "PNCache.h"

#import "NSDictionary+PNAdditions.h"

#import "PNLogger+Protected.h"
#import "PNLoggerSymbols.h"


#pragma mark - Category private interface declaration

@interface PubNub (StatePrivate)


#pragma mark - Instance methods

/**
 @brief Final designated method which allow to fetch client's state information.

 @discussion Retrieve client's information stored within channel or channel group.

 @param clientIdentifier        Client identifier for which \b PubNub client should retrieve state.
 @param object                  Object (which conforms to \b PNChannelProtocol data feed object protocol) for which
                                client's state should be pulled out.
 @param isMethodCallRescheduled In case if value set to \c YES it will mean that method call has been rescheduled and
                                probably there is no handler block which client should use for observation notification.
 @param handlerBlock            The block which will be called by \b PubNub client as soon as client state retrieval
                                process operation will be completed. The block takes three arguments:
                                \c clientIdentifier - identifier for which \b PubNub client search for channels;
                                \c state - is \b PNDictionary instance which store state previously bounded to the 
                                client at specified channel; \c error - describes what exactly went wrong (check error 
                                code and compare it with \b PNErrorCodes ).

@since 3.7.0
*/
- (void)   requestClientState:(NSString *)clientIdentifier forObject:(id <PNChannelProtocol>)object
       reschedulingMethodCall:(BOOL)isMethodCallRescheduled
  withCompletionHandlingBlock:(PNClientStateRetrieveHandlingBlock)handlerBlock;

/**
 @brief  Postpone client's state fetch user request so it will be executed in future.
 
 @discussion Postpone can be because of few cases: \b PubNub client is in connecting or initial connection state; 
 another request which has been issued earlier didn't completed yet.
 
 @param clientIdentifier        Client identifier for which \b PubNub client should retrieve state.
 @param object                  Object (which conforms to \b PNChannelProtocol data feed object protocol) for which 
                                client's state should be pulled out.
 @param isMethodCallRescheduled In case if value set to \c YES it will mean that method call has been rescheduled and
                                probably there is no handler block which client should use for observation notification.
 @param handlerBlock            The block which will be called by \b PubNub client as soon as client state retrieval
                                process operation will be completed. The block takes three arguments:
                                \c clientIdentifier - identifier for which \b PubNub client search for channels;
                                \c state - is \b PNDictionary instance which store state previously bounded to the 
                                client at specified channel; \c error - describes what exactly went wrong (check error 
                                code and compare it with \b PNErrorCodes ).
 
 @since 3.7.0
 */
- (void)postponeRequestClientState:(NSString *)clientIdentifier forObject:(id <PNChannelProtocol>)object
            reschedulingMethodCall:(BOOL)isMethodCallRescheduled witCompletionHandlingBlock:(id)handlerBlock;

/**
 Final designated method which allow to update client state information depending on provided set of parameters.

 @param clientIdentifier
 Client identifier for which \b PubNub client should bound state.

 @param clientState
 \b NSDictionary instance with list of parameters which should be bound to the client.

 @param channel
 \b PNChannel instance for which client's state should be bound.

 @param isMethodCallRescheduled
 In case if value set to \c YES it will mean that method call has been rescheduled and probably there is no handler
 block which client should use for observation notification.

 @param handlerBlock
 The block which will be called by \b PubNub client as soon as client state update process operation will be
 completed. The block takes three arguments:
 \c clientIdentifier - identifier for which \b PubNub client search for channels;
 \c channels - is list of \b PNChannel instances in which \c clientIdentifier has been found as subscriber; \c error -
 describes what exactly went wrong (check error code and compare it with \b PNErrorCodes ).
 */
/**
 @brief Final designated method which allow to update client's state information.
 
 @discussion Update client's information stored inside of channel or channel group.
 
 @param clientIdentifier        Client identifier for which \b PubNub client should bound state.
 @param clientState             \b NSDictionary instance with list of parameters which should be bound to the client.
 @param object                  Object (which conforms to \b PNChannelProtocol data feed object protocol) for which client's
                                state should be bound.
 @param isMethodCallRescheduled In case if value set to \c YES it will mean that method call has been rescheduled and 
                                probably there is no handler block which client should use for observation notification.
 @param handlerBlock            The block which will be called by \b PubNub client as soon as client state update 
                                process operation will be completed. The block takes three arguments:
                                \c clientIdentifier - identifier for which \b PubNub client search for channels;
                                \c channels - is list of \b PNChannel instances in which \c clientIdentifier has been
                                found as subscriber; \c error - describes what exactly went wrong (check error code and 
                                compare it with \b PNErrorCodes ).
 
 @since 3.7.0
 */
- (void)    updateClientState:(NSString *)clientIdentifier state:(NSDictionary *)clientState
                    forObject:(id <PNChannelProtocol>)object reschedulingMethodCall:(BOOL)isMethodCallRescheduled
  withCompletionHandlingBlock:(PNClientStateUpdateHandlingBlock)handlerBlock;

/**
 @brief  Postpone client's state update user request so it will be executed in future.
 
 @discussion Postpone can be because of few cases: \b PubNub client is in connecting or initial connection state; 
 another request which has been issued earlier didn't completed yet.
 
 @param clientIdentifier        Client's identifier for which state information should be updated.
 @param clientState             \a NSDictionary instance which hold information which should be changed
 @param object                  Object (which conforms to \b PNChannelProtocol data feed object protocol) for which client's
                                state should be bound.
 @param isMethodCallRescheduled In case if value set to \c YES it will mean that method call has been rescheduled and 
                                probably there is no handler block which client should use for observation notification.
 @param handlerBlock            Handler block which is called by \b PubNub client when client's state update process 
                                state changes. Block pass two arguments: \c client - \b PNClient instance which may or 
                                may not contain information about client's state bound to concrete channel;
                                \c error - \b PNError instance which hold information about why client's state update 
                                process failed. Always check \a error.code to find out what caused error (check 
                                PNErrorCodes header file and use \a -localizedDescription / \a -localizedFailureReason 
                                and \a -localizedRecoverySuggestion to get human readable description for error).
 
 @since 3.7.0
 */
- (void)postponeUpdateClientState:(NSString *)clientIdentifier state:(NSDictionary *)clientState
                        forObject:(id <PNChannelProtocol>)object reschedulingMethodCall:(BOOL)isMethodCallRescheduled
      withCompletionHandlingBlock:(id)handlerBlock;


#pragma mark - Misc methods

/**
 This method should notify delegate that \b PubNub client failed to retrieve state for client.
 
 @note Always check \a error.code to find out what caused error (check PNErrorCodes header file and use \a -localizedDescription /
 \a -localizedFailureReason and \a -localizedRecoverySuggestion to get human readable description for error).
 
 @param error
 Instance of \b PNError which describes what exactly happened and why this error occurred. \a 'error.associatedObject'
 contains reference on \b PNAccessRightOptions instance which will allow to review and identify what options \b PubNub client tried to apply.
 */
- (void)notifyDelegateAboutStateRetrievalDidFailWithError:(PNError *)error;

/**
 This method should notify delegate that \b PubNub client failed to update state for client.
 
 @note Always check \a error.code to find out what caused error (check PNErrorCodes header file and use \a -localizedDescription /
 \a -localizedFailureReason and \a -localizedRecoverySuggestion to get human readable description for error).
 
 @param error
 Instance of \b PNError which describes what exactly happened and why this error occurred. \a 'error.associatedObject'
 contains reference on \b PNAccessRightOptions instance which will allow to review and identify what options \b PubNub client tried to apply.
 */
- (void)notifyDelegateAboutStateUpdateDidFailWithError:(PNError *)error;


#pragma mark -

@end


#pragma mark - Category methods implementation

@implementation PubNub (State)


#pragma mark - Class (singleton) methods

+ (void)requestClientState:(NSString *)clientIdentifier forChannel:(PNChannel *)channel {
    
    [self requestClientState:clientIdentifier forChannel:channel withCompletionHandlingBlock:nil];
}

+ (void)   requestClientState:(NSString *)clientIdentifier forChannel:(PNChannel *)channel
  withCompletionHandlingBlock:(PNClientStateRetrieveHandlingBlock)handlerBlock {
    
    [self requestClientState:clientIdentifier forObject:channel withCompletionHandlingBlock:handlerBlock];
}

+ (void)requestClientState:(NSString *)clientIdentifier forObject:(id <PNChannelProtocol>)object {
    
    [self requestClientState:clientIdentifier forObject:object withCompletionHandlingBlock:nil];
}

+ (void)   requestClientState:(NSString *)clientIdentifier forObject:(id <PNChannelProtocol>)object
  withCompletionHandlingBlock:(PNClientStateRetrieveHandlingBlock)handlerBlock {
    
    [[self sharedInstance] requestClientState:clientIdentifier forObject:object
                  withCompletionHandlingBlock:handlerBlock];
}

+ (void)updateClientState:(NSString *)clientIdentifier state:(NSDictionary *)clientState
               forChannel:(PNChannel *)channel {
    
    [self updateClientState:clientIdentifier state:clientState forChannel:channel withCompletionHandlingBlock:nil];
}

+ (void)    updateClientState:(NSString *)clientIdentifier state:(NSDictionary *)clientState
                   forChannel:(PNChannel *)channel
  withCompletionHandlingBlock:(PNClientStateUpdateHandlingBlock)handlerBlock {
    
    [self updateClientState:clientIdentifier state:clientState forObject:channel
withCompletionHandlingBlock:handlerBlock];
}

+ (void)updateClientState:(NSString *)clientIdentifier state:(NSDictionary *)clientState
                forObject:(id <PNChannelProtocol>)object {
    
    [self updateClientState:clientIdentifier state:clientState forObject:object withCompletionHandlingBlock:nil];
}

+ (void)    updateClientState:(NSString *)clientIdentifier state:(NSDictionary *)clientState
                    forObject:(id <PNChannelProtocol>)object
  withCompletionHandlingBlock:(PNClientStateUpdateHandlingBlock)handlerBlock{
    
    [[self sharedInstance] updateClientState:clientIdentifier state:clientState forObject:object
                 withCompletionHandlingBlock:handlerBlock];
}


#pragma mark - Instance methods

- (void)requestClientState:(NSString *)clientIdentifier forChannel:(PNChannel *)channel {
    
    [self requestClientState:clientIdentifier forObject:channel withCompletionHandlingBlock:nil];
}

- (void)   requestClientState:(NSString *)clientIdentifier forChannel:(PNChannel *)channel
  withCompletionHandlingBlock:(PNClientStateRetrieveHandlingBlock)handlerBlock {
    
    [self requestClientState:clientIdentifier forObject:channel withCompletionHandlingBlock:handlerBlock];
}

- (void)requestClientState:(NSString *)clientIdentifier forObject:(id <PNChannelProtocol>)object {
    
    [self requestClientState:clientIdentifier forObject:object withCompletionHandlingBlock:nil];
}

- (void)   requestClientState:(NSString *)clientIdentifier forObject:(id <PNChannelProtocol>)object
  withCompletionHandlingBlock:(PNClientStateRetrieveHandlingBlock)handlerBlock {
    
    [self requestClientState:clientIdentifier forObject:object reschedulingMethodCall:NO
 withCompletionHandlingBlock:handlerBlock];
}

- (void)   requestClientState:(NSString *)clientIdentifier forObject:(id <PNChannelProtocol>)object
       reschedulingMethodCall:(BOOL)isMethodCallRescheduled
  withCompletionHandlingBlock:(PNClientStateRetrieveHandlingBlock)handlerBlock {

    [self pn_dispatchBlock:^{
        
        [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray *{
            
            return @[PNLoggerSymbols.api.clientStateAuditAttempt, (clientIdentifier ? clientIdentifier : [NSNull null]),
                     (object ? (id)object : [NSNull null]), [self humanReadableStateFrom:self.state]];
        }];
        
        [self performAsyncLockingBlock:^{
            
            if (!isMethodCallRescheduled) {
                
                [self.observationCenter removeClientAsStateRequestObserver];
            }
            
            // Check whether client is able to send request or not
            NSInteger statusCode = [self requestExecutionPossibilityStatusCode];
            if (statusCode == 0) {
                
                [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray * {
                    
                    return @[PNLoggerSymbols.api.auditClientState, [self humanReadableStateFrom:self.state]];
                }];
                
                if (handlerBlock && !isMethodCallRescheduled) {
                    
                    [self.observationCenter addClientAsStateRequestObserverWithBlock:handlerBlock];
                }
                
                PNClientStateRequest *request = [PNClientStateRequest clientStateRequestForIdentifier:clientIdentifier
                                                                                           andChannel:object];
                [self sendRequest:request shouldObserveProcessing:YES];
            }
            // Looks like client can't send request because of some reasons
            else {
                
                [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray * {
                    
                    return @[PNLoggerSymbols.api.clientStateAuditionImpossible,
                             (clientIdentifier ? clientIdentifier : [NSNull null]),
                             (object ? (id) object : [NSNull null]), [self humanReadableStateFrom:self.state]];
                }];
                
                PNError *requestError = [PNError errorWithCode:statusCode];
                requestError.associatedObject = [PNClient clientForIdentifier:clientIdentifier channel:object
                                                                      andData:nil];;
                
                [self notifyDelegateAboutStateRetrievalDidFailWithError:requestError];
                
                
                if (handlerBlock && !isMethodCallRescheduled) {
                    
                    handlerBlock(requestError.associatedObject, requestError);
                }
            }
        }
               postponedExecutionBlock:^{
                   
                   [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray *{
                       
                       return @[PNLoggerSymbols.api.postponeClientStateAudit, [self humanReadableStateFrom:self.state]];
                   }];
                   
                   [self postponeRequestClientState:clientIdentifier forObject:object
                             reschedulingMethodCall:isMethodCallRescheduled witCompletionHandlingBlock:handlerBlock];
               }];
    }];
}

- (void)postponeRequestClientState:(NSString *)clientIdentifier forObject:(id <PNChannelProtocol>)object
            reschedulingMethodCall:(BOOL)isMethodCallRescheduled witCompletionHandlingBlock:(id)handlerBlock {
    
    id handlerBlockCopy = (handlerBlock ? [handlerBlock copy] : nil);
    [self postponeSelector:@selector(requestClientState:forObject:reschedulingMethodCall:withCompletionHandlingBlock:) forObject:self
            withParameters:@[[PNHelper nilifyIfNotSet:clientIdentifier], [PNHelper nilifyIfNotSet:object],
                             @(isMethodCallRescheduled), [PNHelper nilifyIfNotSet:handlerBlockCopy]]
                outOfOrder:isMethodCallRescheduled];
}

- (void)updateClientState:(NSString *)clientIdentifier state:(NSDictionary *)clientState forChannel:(PNChannel *)channel {
    
    [self updateClientState:clientIdentifier state:clientState forChannel:channel withCompletionHandlingBlock:nil];
}

- (void)    updateClientState:(NSString *)clientIdentifier state:(NSDictionary *)clientState
                   forChannel:(PNChannel *)channel
  withCompletionHandlingBlock:(PNClientStateUpdateHandlingBlock)handlerBlock {
    
    [self updateClientState:clientIdentifier state:clientState forObject:channel
withCompletionHandlingBlock:handlerBlock];
}

- (void)updateClientState:(NSString *)clientIdentifier state:(NSDictionary *)clientState
                 forObject:(id <PNChannelProtocol>)object {
    
    [self updateClientState:clientIdentifier state:clientState forObject:object withCompletionHandlingBlock:nil];
}

- (void)    updateClientState:(NSString *)clientIdentifier state:(NSDictionary *)clientState
                    forObject:(id <PNChannelProtocol>)object
  withCompletionHandlingBlock:(PNClientStateUpdateHandlingBlock)handlerBlock {
    
    [self updateClientState:clientIdentifier state:clientState forObject:object reschedulingMethodCall:NO
withCompletionHandlingBlock:handlerBlock];
}

- (void)    updateClientState:(NSString *)clientIdentifier state:(NSDictionary *)clientState
                    forObject:(id <PNChannelProtocol>)object reschedulingMethodCall:(BOOL)isMethodCallRescheduled
  withCompletionHandlingBlock:(PNClientStateUpdateHandlingBlock)handlerBlock {

    [self pn_dispatchBlock:^{
        
        [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray *{
            
            return @[PNLoggerSymbols.api.clientStateChangeAttempt, (clientIdentifier ? clientIdentifier : [NSNull null]),
                     (object ? (id)object : [NSNull null]), [self humanReadableStateFrom:self.state]];
        }];
        
        [self performAsyncLockingBlock:^{
            
            if (!isMethodCallRescheduled) {
                
                [self.observationCenter removeClientAsStateUpdateObserver];
            }
            
            __block NSDictionary *mergedClientState = @{object.name : clientState};
            
            dispatch_block_t completionBlock = ^{
                
                // Check whether client is able to send request or not
                NSInteger statusCode = [self requestExecutionPossibilityStatusCode];
                if (statusCode == 0 && mergedClientState && (![mergedClientState pn_isValidState] ||
                                                             ![[self subscribedObjectsList] containsObject:object])) {
                    
                    statusCode = kPNInvalidStatePayloadError;
                    if (![[self subscribedObjectsList] containsObject:object]) {
                        
                        statusCode = kPNCantUpdateStateForNotSubscribedChannelsError;
                    }
                }
                if (statusCode == 0) {
                    
                    [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray * {
                        
                        return @[PNLoggerSymbols.api.changeClientState, (mergedClientState ? mergedClientState : [NSNull null]),
                                 [self humanReadableStateFrom:self.state]];
                    }];
                    
                    if (handlerBlock && !isMethodCallRescheduled) {
                        
                        [self.observationCenter addClientAsStateUpdateObserverWithBlock:handlerBlock];
                    }
                    
                    mergedClientState = [mergedClientState valueForKeyPath:object.name];
                    PNClientStateUpdateRequest *request = [PNClientStateUpdateRequest clientStateUpdateRequestWithIdentifier:clientIdentifier
                                                                                                                     channel:object
                                                                                                              andClientState:mergedClientState];
                    [self sendRequest:request shouldObserveProcessing:YES];
                }
                // Looks like client can't send request because of some reasons
                else {
                    
                    [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray * {
                        
                        return @[PNLoggerSymbols.api.clientStateChangeImpossible, (clientState ? clientState : [NSNull null]),
                                 [self humanReadableStateFrom:self.state]];
                    }];
                    
                    PNError *requestError = [PNError errorWithCode:statusCode];
                    requestError.associatedObject = [PNClient clientForIdentifier:clientIdentifier channel:object
                                                                          andData:clientState];
                    
                    [self notifyDelegateAboutStateUpdateDidFailWithError:requestError];
                    
                    
                    if (handlerBlock && !isMethodCallRescheduled) {
                        
                        handlerBlock(requestError.associatedObject, requestError);
                    }
                }
            };
            // Only in case if client update it's own state, we can append cached data to it.
            if ([clientIdentifier isEqualToString:self.clientIdentifier]) {
                
                [self.cache stateMergedWithState:mergedClientState withBlock:^(NSDictionary *mergedState) {
                    
                    [self pn_dispatchBlock:^{
                        
                        mergedClientState = mergedState;
                        completionBlock();
                    }];
                }];
            }
            else {
                
                completionBlock();
            }
        }
               postponedExecutionBlock:^{
                   
                   [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray *{
                       
                       return @[PNLoggerSymbols.api.postponeClientStateChange, [self humanReadableStateFrom:self.state]];
                   }];
                   
                   [self postponeUpdateClientState:clientIdentifier state:clientState forObject:object
                            reschedulingMethodCall:isMethodCallRescheduled withCompletionHandlingBlock:handlerBlock];
               }];
    }];
}

- (void)postponeUpdateClientState:(NSString *)clientIdentifier state:(NSDictionary *)clientState
                        forObject:(id <PNChannelProtocol>)object
           reschedulingMethodCall:(BOOL)isMethodCallRescheduled withCompletionHandlingBlock:(id)handlerBlock {
    
    id handlerBlockCopy = (handlerBlock ? [handlerBlock copy] : nil);
    [self postponeSelector:@selector(updateClientState:state:forObject:reschedulingMethodCall:withCompletionHandlingBlock:) forObject:self
            withParameters:@[[PNHelper nilifyIfNotSet:clientIdentifier], [PNHelper nilifyIfNotSet:clientState],
                             [PNHelper nilifyIfNotSet:object], @(isMethodCallRescheduled), [PNHelper nilifyIfNotSet:handlerBlockCopy]]
                outOfOrder:isMethodCallRescheduled];
}


#pragma mark - Misc methods

- (void)notifyDelegateAboutStateRetrievalDidFailWithError:(PNError *)error {
    
    [self handleLockingOperationBlockCompletion:^{
        
        [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray *{
            
            return @[PNLoggerSymbols.api.clientStateAuditFailed, [self humanReadableStateFrom:self.state]];
        }];
        
        // Check whether delegate us able to handle state retrieval error or not
        if ([self.clientDelegate respondsToSelector:@selector(pubnubClient:clientStateRetrieveDidFailWithError:)]) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
            
                [self.clientDelegate pubnubClient:self clientStateRetrieveDidFailWithError:error];
            });
        }
        
        [self sendNotification:kPNClientStateRetrieveDidFailWithErrorNotification withObject:error];
    }
                                shouldStartNext:YES];
}

- (void)notifyDelegateAboutStateUpdateDidFailWithError:(PNError *)error {
    
    [self handleLockingOperationBlockCompletion:^{
        
        [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray *{
            
            return @[PNLoggerSymbols.api.clientStateChangeFailed, [self humanReadableStateFrom:self.state]];
        }];
        
        // Check whether delegate able to state update error even or not.
        if ([self.clientDelegate respondsToSelector:@selector(pubnubClient:clientStateUpdateDidFailWithError:)]) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
            
                [self.clientDelegate performSelector:@selector(pubnubClient:clientStateUpdateDidFailWithError:)
                                          withObject:self withObject:error];
            });
        }
        
        [self sendNotification:kPNClientStateUpdateDidFailWithErrorNotification withObject:error];
    }
                                shouldStartNext:YES];
}


#pragma mark - Service channel delegate methods

- (void)serviceChannel:(PNServiceChannel *)serviceChannel didReceiveClientState:(PNClient *)client {

    void(^handlingBlock)(BOOL) = ^(BOOL shouldNotify){

        [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray *{

            return @[PNLoggerSymbols.api.didReceiveClientState, [self humanReadableStateFrom:self.state]];
        }];

        // In case if there is no error and client identifier is the same as this one,
        // client will store retrieved state in cache.
        if ([client.identifier isEqualToString:self.clientIdentifier]) {

            [client.channels enumerateObjectsUsingBlock:^(PNChannel *channel, NSUInteger channelIdx,
                                                          BOOL *channelEnumeratorStop) {

                [self.cache purgeStateForChannel:channel];
                [self.cache storeClientState:[client stateForChannel:channel] forChannel:channel];
            }];
        }

        if (shouldNotify) {

            // Check whether delegate is able to handle state retrieval event or not
            SEL selector = @selector(pubnubClient:didReceiveClientState:);
            if ([self.clientDelegate respondsToSelector:selector]) {

                #pragma clang diagnostic push
                #pragma clang diagnostic ignored "-Warc-performSelector-leaks"
                dispatch_async(dispatch_get_main_queue(), ^{

                    [self.clientDelegate performSelector:selector withObject:self withObject:client];
                });
                #pragma clang diagnostic pop
            }

            [self sendNotification:kPNClientDidReceiveClientStateNotification withObject:client];
        }
    };

    [self checkShouldChannelNotifyAboutEvent:serviceChannel withBlock:^(BOOL shouldNotify) {

        [self handleLockingOperationBlockCompletion:^{

            handlingBlock(shouldNotify);
        }
                                    shouldStartNext:YES];
    }];
}

- (void)serviceChannel:(PNServiceChannel *)channel clientStateReceiveDidFailWithError:(PNError *)error {
    
    if (error.code != kPNRequestCantBeProcessedWithOutRescheduleError) {
        
        [self notifyDelegateAboutStateRetrievalDidFailWithError:error];
    }
    else {
        
        [self rescheduleMethodCall:^{
            
            PNClient *clientInformation = (PNClient *)error.associatedObject;
            
            [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray *{
                
                return @[PNLoggerSymbols.api.rescheduleClientStateAudit, [self humanReadableStateFrom:self.state]];
            }];
            
            [self requestClientState:clientInformation.identifier forObject:clientInformation.channel
              reschedulingMethodCall:YES withCompletionHandlingBlock:nil];
        }];
    }
}

- (void)serviceChannel:(PNServiceChannel *)channel didUpdateClientState:(PNClient *)client {

    void(^handlingBlock)(BOOL) = ^(BOOL shouldNotify){

        [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray *{

            return @[PNLoggerSymbols.api.didChangeClientState, [self humanReadableStateFrom:self.state]];
        }];

        // Ensure that we received data for this client or not
        if ([client.identifier isEqualToString:self.clientIdentifier]) {

            [self.cache storeClientState:[client stateForChannel:client.channel] forChannel:client.channel];
        }

        if (shouldNotify) {

            // Check whether delegate is able to handle state update event or not
            SEL selector = @selector(pubnubClient:didUpdateClientState:);
            if ([self.clientDelegate respondsToSelector:selector]) {

                #pragma clang diagnostic push
                #pragma clang diagnostic ignored "-Warc-performSelector-leaks"
                dispatch_async(dispatch_get_main_queue(), ^{

                    [self.clientDelegate performSelector:selector withObject:self withObject:client];
                });
                #pragma clang diagnostic pop
            }

            [self sendNotification:kPNClientDidUpdateClientStateNotification withObject:client];
        }
    };

    [self checkShouldChannelNotifyAboutEvent:channel withBlock:^(BOOL shouldNotify) {

        [self handleLockingOperationBlockCompletion:^{

            handlingBlock(shouldNotify);
        }
                                    shouldStartNext:YES];
    }];
}

- (void)serviceChannel:(PNServiceChannel *)channel clientStateUpdateDidFailWithError:(PNError *)error {
    
    if (error.code != kPNRequestCantBeProcessedWithOutRescheduleError) {
        
        [self notifyDelegateAboutStateUpdateDidFailWithError:error];
    }
    else {
        
        [self rescheduleMethodCall:^{
            
            PNClient *clientInformation = (PNClient *)error.associatedObject;
            
            [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray *{
                
                return @[PNLoggerSymbols.api.rescheduleClientStateChange, [self humanReadableStateFrom:self.state]];
            }];
            
            [self updateClientState:clientInformation.identifier
                              state:[clientInformation stateForChannel:clientInformation.channel]
                          forObject:clientInformation.channel
             reschedulingMethodCall:YES withCompletionHandlingBlock:nil];
        }];
    }
}

#pragma mark -


@end
