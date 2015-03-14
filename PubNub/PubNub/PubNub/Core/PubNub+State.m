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
 @brief      Final designated method which allow to fetch client's state information.

 @discussion Retrieve client's information stored within channel or channel group.

 @param clientIdentifier Client identifier for which \b PubNub client should retrieve state.
 @param object           Object (which conforms to \b PNChannelProtocol data feed object protocol)
                         for which client's state should be pulled out.
 @param callbackToken    Reference on callback token under which stored block passed by user on API
                         usage. This block will be reused because of method rescheduling.
 @param handlerBlock     The block which will be called by \b PubNub client as soon as client state
                         retrieval process operation will be completed. The block takes three
                         arguments: \c clientIdentifier - identifier for which \b PubNub client
                         search for channels; \c state - is \b PNDictionary instance which store
                         state previously bounded to the client at specified channel; \c error -
                         describes what exactly went wrong (check error code and compare it with
                         \b PNErrorCodes ).

@since 3.7.0
*/
- (void)   requestClientState:(NSString *)clientIdentifier forObject:(id <PNChannelProtocol>)object
     rescheduledCallbackToken:(NSString *)callbackToken
  withCompletionHandlingBlock:(PNClientStateRetrieveHandlingBlock)handlerBlock;

/**
 @brief      Postpone client's state fetch user request so it will be executed in future.
 
 @discussion Postpone can be because of few cases: \b PubNub client is in connecting or initial
             connection state; another request which has been issued earlier didn't completed yet.
 
 @param clientIdentifier Client identifier for which \b PubNub client should retrieve state.
 @param object           Object (which conforms to \b PNChannelProtocol data feed object protocol)
                         for which client's state should be pulled out.
 @param callbackToken    Reference on callback token under which stored block passed by user on API
                         usage. This block will be reused because of method rescheduling.
 @param handlerBlock     The block which will be called by \b PubNub client as soon as client state
                         retrieval process operation will be completed. The block takes three
                         arguments: \c clientIdentifier - identifier for which \b PubNub client
                         search for channels; \c state - is \b PNDictionary instance which store
                         state previously bounded to the client at specified channel; \c error -
                         describes what exactly went wrong (check error code and compare it with
                         \b PNErrorCodes ).
 
 @since 3.7.0
 */
- (void)postponeRequestClientState:(NSString *)clientIdentifier
                         forObject:(id <PNChannelProtocol>)object
          rescheduledCallbackToken:(NSString *)callbackToken
        witCompletionHandlingBlock:(id)handlerBlock;

/**
 @brief      Final designated method which allow to update client's state information.
 @discussion Update client's information stored inside of channel or channel group.
 
 @param clientIdentifier Client identifier for which \b PubNub client should bound state.
 @param clientState      \b NSDictionary instance with list of parameters which should be bound to
                         the client.
 @param object           Object (which conforms to \b PNChannelProtocol data feed object protocol)
                         for which client's state should be bound.
 @param callbackToken    Reference on callback token under which stored block passed by user on API
                         usage. This block will be reused because of method rescheduling.
 @param handlerBlock     The block which will be called by \b PubNub client as soon as client state
                         update process operation will be completed. The block takes three
                         arguments: \c clientIdentifier - identifier for which \b PubNub client
                         search for channels; \c channels - is list of \b PNChannel instances in
                         which \c clientIdentifier has been found as subscriber; \c error -
                         describes what exactly went wrong (check error code and compare it with
                         \b PNErrorCodes ).
 
 @since 3.7.0
 */
- (void)    updateClientState:(NSString *)clientIdentifier state:(NSDictionary *)clientState
                    forObject:(id <PNChannelProtocol>)object
     rescheduledCallbackToken:(NSString *)callbackToken
  withCompletionHandlingBlock:(PNClientStateUpdateHandlingBlock)handlerBlock;

/**
 @brief      Postpone client's state update user request so it will be executed in future.
 @discussion Postpone can be because of few cases: \b PubNub client is in connecting or initial
             connection state; another request which has been issued earlier didn't completed yet.
 
 @param clientIdentifier Client identifier for which \b PubNub client should bound state.
 @param clientState      \b NSDictionary instance with list of parameters which should be bound to
                         the client.
 @param object           Object (which conforms to \b PNChannelProtocol data feed object protocol)
                         for which client's state should be bound.
 @param callbackToken    Reference on callback token under which stored block passed by user on API
                         usage. This block will be reused because of method rescheduling.
 @param handlerBlock     The block which will be called by \b PubNub client as soon as client state
                         update process operation will be completed. The block takes three
                         arguments: \c clientIdentifier - identifier for which \b PubNub client
                         search for channels; \c channels - is list of \b PNChannel instances in
                         which \c clientIdentifier has been found as subscriber; \c error -
                         describes what exactly went wrong (check error code and compare it with
                         \b PNErrorCodes ).
 
 @since 3.7.0
 */
- (void)postponeUpdateClientState:(NSString *)clientIdentifier state:(NSDictionary *)clientState
                        forObject:(id <PNChannelProtocol>)object
         rescheduledCallbackToken:(NSString *)callbackToken
      withCompletionHandlingBlock:(id)handlerBlock;


#pragma mark - Misc methods

/**
 @brief This method should notify delegate that \b PubNub client failed to retrieve state for
        client.
 
 @param error         Instance of \b PNError which describes what exactly happened and why this
                      error occurred.
 @param callbackToken Reference on callback token under which stored block passed by user on API
                      usage. This block will be reused because of method rescheduling.

 @note Always check \a error.code to find out what caused error (check PNErrorCodes header file and
       use \a -localizedDescription / \a -localizedFailureReason and \a -localizedRecoverySuggestion
       to get human readable description for error).
 */
- (void)notifyDelegateAboutStateRetrievalDidFailWithError:(PNError *)error
                                         andCallbackToken:(NSString *)callbackToken;

/**
 This method should notify delegate that \b PubNub client failed to update state for client.
 
 @param error         Instance of \b PNError which describes what exactly happened and why this
                      error occurred.
 @param callbackToken Reference on callback token under which stored block passed by user on API
                      usage. This block will be reused because of method rescheduling.

 @note Always check \a error.code to find out what caused error (check PNErrorCodes header file and
       use \a -localizedDescription / \a -localizedFailureReason and \a -localizedRecoverySuggestion
       to get human readable description for error).
 */
- (void)notifyDelegateAboutStateUpdateDidFailWithError:(PNError *)error
                                      andCallbackToken:(NSString *)callbackToken;

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
    
    [self requestClientState:clientIdentifier forObject:channel
 withCompletionHandlingBlock:handlerBlock];
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
    
    [self updateClientState:clientIdentifier state:clientState forChannel:channel
withCompletionHandlingBlock:nil];
}

+ (void)    updateClientState:(NSString *)clientIdentifier state:(NSDictionary *)clientState
                   forChannel:(PNChannel *)channel
  withCompletionHandlingBlock:(PNClientStateUpdateHandlingBlock)handlerBlock {
    
    [self updateClientState:clientIdentifier state:clientState forObject:channel
withCompletionHandlingBlock:handlerBlock];
}

+ (void)updateClientState:(NSString *)clientIdentifier state:(NSDictionary *)clientState
                forObject:(id <PNChannelProtocol>)object {
    
    [self updateClientState:clientIdentifier state:clientState forObject:object
withCompletionHandlingBlock:nil];
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
    
    [self requestClientState:clientIdentifier forObject:channel
 withCompletionHandlingBlock:handlerBlock];
}

- (void)requestClientState:(NSString *)clientIdentifier forObject:(id <PNChannelProtocol>)object {
    
    [self requestClientState:clientIdentifier forObject:object withCompletionHandlingBlock:nil];
}

- (void)   requestClientState:(NSString *)clientIdentifier forObject:(id <PNChannelProtocol>)object
  withCompletionHandlingBlock:(PNClientStateRetrieveHandlingBlock)handlerBlock {

    [self requestClientState:clientIdentifier forObject:object rescheduledCallbackToken:nil
 withCompletionHandlingBlock:handlerBlock];
}

- (void)   requestClientState:(NSString *)clientIdentifier forObject:(id <PNChannelProtocol>)object
     rescheduledCallbackToken:(NSString *)callbackToken
  withCompletionHandlingBlock:(PNClientStateRetrieveHandlingBlock)handlerBlock {

    [self pn_dispatchBlock:^{
        
        [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray *{
            
            return @[PNLoggerSymbols.api.clientStateAuditAttempt,
                     (clientIdentifier ? clientIdentifier : [NSNull null]),
                     (object ? (id)object : [NSNull null]),
                     [self humanReadableStateFrom:self.state]];
        }];
        
        [self   performAsyncLockingBlock:^{

            // Check whether client is able to send request or not
            NSInteger statusCode = [self requestExecutionPossibilityStatusCode];
            if (statusCode == 0) {

                [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray * {

                    return @[PNLoggerSymbols.api.auditClientState, [self humanReadableStateFrom:self.state]];
                }];

                PNClientStateRequest *request = [PNClientStateRequest clientStateRequestForIdentifier:clientIdentifier
                                                                                           andChannel:object];
                if (handlerBlock && !callbackToken) {

                    [self.observationCenter addClientAsStateRequestObserverWithToken:request.shortIdentifier
                                                                            andBlock:handlerBlock];
                }
                else if (callbackToken) {

                    [self.observationCenter changeClientCallbackToken:callbackToken
                                                                   to:request.shortIdentifier];
                }

                [self sendRequest:request shouldObserveProcessing:YES];
            }
                // Looks like client can't send request because of some reasons
            else {

                [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray * {

                    return @[PNLoggerSymbols.api.clientStateAuditionImpossible,
                            (clientIdentifier ? clientIdentifier : [NSNull null]),
                            (object ? (id) object : [NSNull null]),
                            [self humanReadableStateFrom:self.state]];
                }];

                PNError *requestError = [PNError errorWithCode:statusCode];
                requestError.associatedObject = [PNClient clientForIdentifier:clientIdentifier
                                                                      channel:object
                                                                      andData:nil];;

                [self notifyDelegateAboutStateRetrievalDidFailWithError:requestError
                                                       andCallbackToken:callbackToken];

                if (handlerBlock && !callbackToken) {

                    dispatch_async(dispatch_get_main_queue(), ^{

                        handlerBlock(requestError.associatedObject, requestError);
                    });
                }
            }
        }        postponedExecutionBlock:^{

            [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray * {

                return @[PNLoggerSymbols.api.postponeClientStateAudit,
                        [self humanReadableStateFrom:self.state]];
            }];

            [self postponeRequestClientState:clientIdentifier forObject:object
                    rescheduledCallbackToken:callbackToken
                  witCompletionHandlingBlock:handlerBlock];
        } burstExecutionLockingOperation:NO];
    }];
}

- (void)postponeRequestClientState:(NSString *)clientIdentifier forObject:(id <PNChannelProtocol>)object
          rescheduledCallbackToken:(NSString *)callbackToken
        witCompletionHandlingBlock:(id)handlerBlock {
    
    id handlerBlockCopy = (handlerBlock ? [handlerBlock copy] : nil);
    [self postponeSelector:@selector(requestClientState:forObject:rescheduledCallbackToken:withCompletionHandlingBlock:)
                 forObject:self
            withParameters:@[[PNHelper nilifyIfNotSet:clientIdentifier],
                             [PNHelper nilifyIfNotSet:object],
                             [PNHelper nilifyIfNotSet:callbackToken],
                             [PNHelper nilifyIfNotSet:handlerBlockCopy]]
                outOfOrder:(callbackToken != nil) burstExecutionLock:NO];
}

- (void)updateClientState:(NSString *)clientIdentifier state:(NSDictionary *)clientState
               forChannel:(PNChannel *)channel {
    
    [self updateClientState:clientIdentifier state:clientState forChannel:channel
withCompletionHandlingBlock:nil];
}

- (void)    updateClientState:(NSString *)clientIdentifier state:(NSDictionary *)clientState
                   forChannel:(PNChannel *)channel
  withCompletionHandlingBlock:(PNClientStateUpdateHandlingBlock)handlerBlock {
    
    [self updateClientState:clientIdentifier state:clientState forObject:channel
withCompletionHandlingBlock:handlerBlock];
}

- (void)updateClientState:(NSString *)clientIdentifier state:(NSDictionary *)clientState
                 forObject:(id <PNChannelProtocol>)object {
    
    [self updateClientState:clientIdentifier state:clientState forObject:object
withCompletionHandlingBlock:nil];
}

- (void)    updateClientState:(NSString *)clientIdentifier state:(NSDictionary *)clientState
                    forObject:(id <PNChannelProtocol>)object
  withCompletionHandlingBlock:(PNClientStateUpdateHandlingBlock)handlerBlock {

    [self updateClientState:clientIdentifier state:clientState forObject:object
   rescheduledCallbackToken:nil withCompletionHandlingBlock:handlerBlock];
}

- (void)    updateClientState:(NSString *)clientIdentifier state:(NSDictionary *)clientState
                     forObject:(id <PNChannelProtocol>)object rescheduledCallbackToken:(NSString *)callbackToken
  withCompletionHandlingBlock:(PNClientStateUpdateHandlingBlock)handlerBlock {

    [self pn_dispatchBlock:^{
        
        [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray *{
            
            return @[PNLoggerSymbols.api.clientStateChangeAttempt,
                     (clientIdentifier ? clientIdentifier : [NSNull null]),
                     (object ? (id)object : [NSNull null]), [self humanReadableStateFrom:self.state]];
        }];
        
        [self   performAsyncLockingBlock:^{

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

                        return @[PNLoggerSymbols.api.changeClientState,
                                (mergedClientState ? mergedClientState : [NSNull null]),
                                [self humanReadableStateFrom:self.state]];
                    }];

                    mergedClientState = [mergedClientState valueForKeyPath:object.name];
                    PNClientStateUpdateRequest *request = [PNClientStateUpdateRequest clientStateUpdateRequestWithIdentifier:clientIdentifier
                                                                                                                     channel:object andClientState:mergedClientState];
                    if (handlerBlock && !callbackToken) {

                        [self.observationCenter addClientAsStateUpdateObserverWithToken:request.shortIdentifier
                                                                               andBlock:handlerBlock];
                    }
                    else if (callbackToken) {

                        [self.observationCenter changeClientCallbackToken:callbackToken
                                                                       to:request.shortIdentifier];
                    }

                    [self sendRequest:request shouldObserveProcessing:YES];
                }
                    // Looks like client can't send request because of some reasons
                else {

                    [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray * {

                        return @[PNLoggerSymbols.api.clientStateChangeImpossible,
                                (clientState ? clientState : [NSNull null]),
                                [self humanReadableStateFrom:self.state]];
                    }];

                    PNError *requestError = [PNError errorWithCode:statusCode];
                    requestError.associatedObject = [PNClient clientForIdentifier:clientIdentifier
                                                                          channel:object
                                                                          andData:clientState];

                    [self notifyDelegateAboutStateUpdateDidFailWithError:requestError
                                                        andCallbackToken:callbackToken];

                    if (handlerBlock && !callbackToken) {

                        dispatch_async(dispatch_get_main_queue(), ^{

                            handlerBlock(requestError.associatedObject, requestError);
                        });
                    }
                }
            };
            // Only in case if client update it's own state, we can append cached data to it.
            if ([clientIdentifier isEqualToString:self.clientIdentifier]) {

                [self.cache stateMergedWithState:mergedClientState
                                       withBlock:^(NSDictionary *mergedState) {

                                           [self pn_dispatchBlock:^{

                                               mergedClientState = mergedState;
                                               completionBlock();
                                           }];
                                       }];
            }
            else {

                completionBlock();
            }
        }        postponedExecutionBlock:^{

            [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray * {

                return @[PNLoggerSymbols.api.postponeClientStateChange,
                        [self humanReadableStateFrom:self.state]];
            }];

            [self postponeUpdateClientState:clientIdentifier state:clientState
                                  forObject:object rescheduledCallbackToken:callbackToken
                withCompletionHandlingBlock:handlerBlock];
        } burstExecutionLockingOperation:NO];
    }];
}

- (void)postponeUpdateClientState:(NSString *)clientIdentifier state:(NSDictionary *)clientState
                        forObject:(id <PNChannelProtocol>)object
         rescheduledCallbackToken:(NSString *)callbackToken
      withCompletionHandlingBlock:(id)handlerBlock {
    
    id handlerBlockCopy = (handlerBlock ? [handlerBlock copy] : nil);
    [self postponeSelector:@selector(updateClientState:state:forObject:rescheduledCallbackToken:withCompletionHandlingBlock:)
                 forObject:self
            withParameters:@[[PNHelper nilifyIfNotSet:clientIdentifier],
                             [PNHelper nilifyIfNotSet:clientState],
                             [PNHelper nilifyIfNotSet:object],
                             [PNHelper nilifyIfNotSet:callbackToken],
                             [PNHelper nilifyIfNotSet:handlerBlockCopy]]
                outOfOrder:(callbackToken != nil) burstExecutionLock:NO];
}


#pragma mark - Misc methods

- (void)notifyDelegateAboutStateRetrievalDidFailWithError:(PNError *)error
                                         andCallbackToken:(NSString *)callbackToken {
    
    [self handleLockingOperationBlockCompletion:^{

        [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray * {

            return @[PNLoggerSymbols.api.clientStateAuditFailed,
                    [self humanReadableStateFrom:self.state]];
        }];

        // Check whether delegate us able to handle state retrieval error or not
        if ([self.clientDelegate respondsToSelector:@selector(pubnubClient:clientStateRetrieveDidFailWithError:)]) {

            dispatch_async(dispatch_get_main_queue(), ^{

                [self.clientDelegate pubnubClient:self clientStateRetrieveDidFailWithError:error];
            });
        }

        [self sendNotification:kPNClientStateRetrieveDidFailWithErrorNotification withObject:error
              andCallbackToken:callbackToken];
    }                           shouldStartNext:YES burstExecutionLockingOperation:NO];
}

- (void)notifyDelegateAboutStateUpdateDidFailWithError:(PNError *)error
                                      andCallbackToken:(NSString *)callbackToken {
    
    [self handleLockingOperationBlockCompletion:^{

        [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray * {

            return @[PNLoggerSymbols.api.clientStateChangeFailed,
                    [self humanReadableStateFrom:self.state]];
        }];

        // Check whether delegate able to state update error even or not.
        if ([self.clientDelegate respondsToSelector:@selector(pubnubClient:clientStateUpdateDidFailWithError:)]) {

            dispatch_async(dispatch_get_main_queue(), ^{

                [self.clientDelegate performSelector:@selector(pubnubClient:clientStateUpdateDidFailWithError:)
                                          withObject:self withObject:error];
            });
        }

        [self sendNotification:kPNClientStateUpdateDidFailWithErrorNotification withObject:error
              andCallbackToken:callbackToken];
    }                           shouldStartNext:YES burstExecutionLockingOperation:NO];
}


#pragma mark - Service channel delegate methods

- (void)serviceChannel:(PNServiceChannel *)serviceChannel didReceiveClientState:(PNClient *)client
             onRequest:(PNBaseRequest *)request {

    void(^handlingBlock)(BOOL) = ^(BOOL shouldNotify){

        [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray *{

            return @[PNLoggerSymbols.api.didReceiveClientState,
                     [self humanReadableStateFrom:self.state]];
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

            [self sendNotification:kPNClientDidReceiveClientStateNotification withObject:client
                  andCallbackToken:request.shortIdentifier];
        }
    };

    [self checkShouldChannelNotifyAboutEvent:serviceChannel withBlock:^(BOOL shouldNotify) {

        [self handleLockingOperationBlockCompletion:^{

            handlingBlock(shouldNotify);
        }                           shouldStartNext:YES burstExecutionLockingOperation:NO];
    }];
}

- (void)              serviceChannel:(PNServiceChannel *)channel
  clientStateReceiveDidFailWithError:(PNError *)error forRequest:(PNBaseRequest *)request {

    NSString *callbackToken = request.shortIdentifier;
    if (error.code != kPNRequestCantBeProcessedWithOutRescheduleError) {
        
        [self notifyDelegateAboutStateRetrievalDidFailWithError:error
                                               andCallbackToken:callbackToken];
    }
    else {
        
        [self rescheduleMethodCall:^{
            
            PNClient *clientInformation = (PNClient *)error.associatedObject;
            
            [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray *{
                
                return @[PNLoggerSymbols.api.rescheduleClientStateAudit,
                         [self humanReadableStateFrom:self.state]];
            }];

            [self requestClientState:clientInformation.identifier forObject:clientInformation.channel
            rescheduledCallbackToken:callbackToken withCompletionHandlingBlock:nil];
        }];
    }
}

- (void)serviceChannel:(PNServiceChannel *)channel didUpdateClientState:(PNClient *)client
             onRequest:(PNBaseRequest *)request {

    void(^handlingBlock)(BOOL) = ^(BOOL shouldNotify){

        [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray *{

            return @[PNLoggerSymbols.api.didChangeClientState,
                     [self humanReadableStateFrom:self.state]];
        }];

        // Ensure that we received data for this client or not
        if ([client.identifier isEqualToString:self.clientIdentifier]) {

            [self.cache storeClientState:[client stateForChannel:client.channel]
                              forChannel:client.channel];
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

            [self sendNotification:kPNClientDidUpdateClientStateNotification withObject:client
                  andCallbackToken:request.shortIdentifier];
        }
    };

    [self checkShouldChannelNotifyAboutEvent:channel withBlock:^(BOOL shouldNotify) {

        [self handleLockingOperationBlockCompletion:^{

            handlingBlock(shouldNotify);
        }                           shouldStartNext:YES burstExecutionLockingOperation:NO];
    }];
}

- (void)             serviceChannel:(PNServiceChannel *)channel
  clientStateUpdateDidFailWithError:(PNError *)error forRequest:(PNBaseRequest *)request {

    NSString *callbackToken = request.shortIdentifier;
    if (error.code != kPNRequestCantBeProcessedWithOutRescheduleError) {
        
        [self notifyDelegateAboutStateUpdateDidFailWithError:error andCallbackToken:callbackToken];
    }
    else {
        
        [self rescheduleMethodCall:^{
            
            PNClient *clientInformation = (PNClient *)error.associatedObject;
            
            [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray *{
                
                return @[PNLoggerSymbols.api.rescheduleClientStateChange,
                         [self humanReadableStateFrom:self.state]];
            }];

            [self updateClientState:clientInformation.identifier
                              state:[clientInformation stateForChannel:clientInformation.channel]
                          forObject:clientInformation.channel rescheduledCallbackToken:callbackToken
        withCompletionHandlingBlock:nil];
        }];
    }
}

#pragma mark -


@end
