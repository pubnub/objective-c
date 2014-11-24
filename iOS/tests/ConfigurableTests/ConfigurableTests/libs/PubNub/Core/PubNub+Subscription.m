/**
 
 @author Sergey Mamontov
 @version 3.7.0
 @copyright © 2009-14 PubNub Inc.
 
 */

#import "PubNub+Subscription.h"
#import "NSObject+PNAdditions.h"
#import "PNMessagingChannel.h"
#import "PubNub+Protected.h"
#import "PNNotifications.h"
#import "PNCryptoHelper.h"
#import "PubNub+Cipher.h"
#import "PNHelper.h"
#import "PNError.h"
#import "PNCache.h"

#import "NSDictionary+PNAdditions.h"

#import "PNLogger+Protected.h"
#import "PNLoggerSymbols.h"


#pragma mark - Category private interface declaration

@interface PubNub (SubscriptionPrivate)


#pragma mark - Instance methods

/**
 Postpone subscription user request so it will be executed in future.
 
 @note Postpone can be because of few cases: \b PubNub client is in connecting or initial connection state; another 
 request which has been issued earlier didn't completed yet.
 
 @param channelObjects List of objects (which conforms to \b PNChannelProtocol data feed object protocol) on which 
                       client should subscribe.
 @param shouldCatchUp  If set to \c YES client will use last time token to catchup on previous messages on channels at 
                       which client subscribed at this moment.
 @param clientState    Reference on \a NSDictionary which hold information which should be bound to the client during
                       his subscription session to target channels.
 @param handlerBlock   Handler block which is called by \b PubNub client when subscription process state changes.
                       Block pass three arguments: \c state - one of \b PNSubscriptionProcessState fields;
                       \c channels - list of \b PNChannel instances for which subscription process changes state;
                       \c subscriptionError - \b PNError instance which hold information about why subscription process
                       failed. Always check \a error.code to find out what caused error (check PNErrorCodes header file
                       and use \a -localizedDescription / \a -localizedFailureReason and \a -localizedRecoverySuggestion
                       to get human readable description for error).
 */
- (void)postponeSubscribeOn:(NSArray *)channelObjects withCatchUp:(BOOL)shouldCatchUp
                clientState:(NSDictionary *)clientState
 andCompletionHandlingBlock:(PNClientChannelSubscriptionHandlerBlock)handlerBlock;

/**
 @brief Postpone unsubscription user request so it will be executed in future.
 
 @discussion Postpone can be because of few cases: \b PubNub client is in connecting or initial connection state;
 another request which has been issued earlier didn't completed yet.
 
 @param channelObjects List of objects (which conforms to \b PNChannelProtocol data feed object protocol) from which
                       client should unsubscribe.
 @param handlerBlock   Handler block which is called by \b PubNub client when unsubscription process state changes.
                       Block pass two arguments: \c channels - list of \b PNChannel instances for which unsubscription
                       process changes state; \c subscriptionError - \b PNError instance which hold information about 
                       why unsubscription process failed. Always check \a error.code to find out what caused error 
                       (check PNErrorCodes header file and use \a -localizedDescription / \a -localizedFailureReason and
                       \a -localizedRecoverySuggestion to get human readable description for error).
 */
- (void)postponeUnsubscribeFrom:(NSArray *)channelObjects
    withCompletionHandlingBlock:(PNClientChannelUnsubscriptionHandlerBlock)handlerBlock;


#pragma mark - Misc methods

/**
 This method will notify delegate that client is about to restore subscription to specified set of channels
 and send notification about it.
 
 @param channels
 List of \b PNChannel instances for which subscription will be restored.
 */
- (void)notifyDelegateAboutResubscribeWillStartOnChannels:(NSArray *)channels;

/**
 * This method will notify delegate about that unsubscription failed with error.
 
 @param error
 \b PNError instance which hold information about what exactly went wrong during unsubscription process.
 
 @param shouldCompleteLockingOperation
 Whether procedural lock should be released after delegate notification or not.
 */
- (void)notifyDelegateAboutUnsubscriptionFailWithError:(PNError *)error
                              completeLockingOperation:(BOOL)shouldCompleteLockingOperation;

#pragma mark -


@end


#pragma mark - Category methods implementation

@implementation PubNub (Subscription)


#pragma mark - Class (singleton) methods

+ (NSArray *)subscribedChannels {

    return [self subscribedObjectsList];
}

+ (NSArray *)subscribedObjectsList {

    return [[self sharedInstance] subscribedObjectsList];
}

+ (BOOL)isSubscribedOnChannel:(PNChannel *)channel {

    return [self isSubscribedOn:channel];
}

+ (BOOL)isSubscribedOn:(id <PNChannelProtocol>)object {

    return [[self sharedInstance] isSubscribedOn:object];
}

+ (void)subscribeOnChannel:(PNChannel *)channel {
    
    [self subscribeOnChannel:channel withCompletionHandlingBlock:nil];
}

+ (void)   subscribeOnChannel:(PNChannel *)channel
  withCompletionHandlingBlock:(PNClientChannelSubscriptionHandlerBlock)handlerBlock {
    
    [self subscribeOnChannel:channel withClientState:nil andCompletionHandlingBlock:handlerBlock];
}

+ (void)subscribeOnChannel:(PNChannel *)channel withClientState:(NSDictionary *)clientState {
    
    [self subscribeOnChannel:channel withClientState:clientState andCompletionHandlingBlock:nil];
}

+ (void)  subscribeOnChannel:(PNChannel *)channel withClientState:(NSDictionary *)clientState
  andCompletionHandlingBlock:(PNClientChannelSubscriptionHandlerBlock)handlerBlock {
    
    // Checking whether client state for channel has been provided in correct format or not.
    if (channel && clientState && ![[clientState valueForKey:channel.name] isKindOfClass:[NSDictionary class]]) {
        
        clientState = @{channel.name: clientState};
    }
    
    [self subscribeOnChannels:(channel ? @[channel] : @[]) withClientState:clientState
   andCompletionHandlingBlock:handlerBlock];
}

+ (void)subscribeOnChannels:(NSArray *)channels {
    
    [self subscribeOnChannels:channels withCompletionHandlingBlock:nil];
}

+ (void)  subscribeOnChannels:(NSArray *)channels
  withCompletionHandlingBlock:(PNClientChannelSubscriptionHandlerBlock)handlerBlock {
    
    [self subscribeOnChannels:channels withClientState:nil andCompletionHandlingBlock:handlerBlock];
}

+ (void)subscribeOnChannels:(NSArray *)channels withClientState:(NSDictionary *)clientState {
    
    [self subscribeOnChannels:channels withClientState:clientState andCompletionHandlingBlock:nil];
}

+ (void) subscribeOnChannels:(NSArray *)channels withClientState:(NSDictionary *)clientState
  andCompletionHandlingBlock:(PNClientChannelSubscriptionHandlerBlock)handlerBlock {
    
    [self subscribeOn:channels withClientState:clientState andCompletionHandlingBlock:handlerBlock];
}

+ (void)subscribeOn:(NSArray *)channelObjects {
    
    [self subscribeOn:channelObjects withCompletionHandlingBlock:nil];
}

+ (void)          subscribeOn:(NSArray *)channelObjects
  withCompletionHandlingBlock:(PNClientChannelSubscriptionHandlerBlock)handlerBlock {
    
    [self subscribeOn:channelObjects withClientState:nil andCompletionHandlingBlock:handlerBlock];
}

+ (void)subscribeOn:(NSArray *)channelObjects withClientState:(NSDictionary *)clientState {
    
    [self subscribeOn:channelObjects withClientState:clientState andCompletionHandlingBlock:nil];
}

+ (void)         subscribeOn:(NSArray *)channelObjects withClientState:(NSDictionary *)clientState
  andCompletionHandlingBlock:(PNClientChannelSubscriptionHandlerBlock)handlerBlock {
    
    [self subscribeOn:channelObjects withCatchUp:NO clientState:clientState
andCompletionHandlingBlock:handlerBlock];
}

+ (void)         subscribeOn:(NSArray *)channelObjects withCatchUp:(BOOL)shouldCatchUp
                 clientState:(NSDictionary *)clientState
  andCompletionHandlingBlock:(PNClientChannelSubscriptionHandlerBlock)handlerBlock {
    
    [[self sharedInstance] subscribeOn:channelObjects withCatchUp:shouldCatchUp clientState:clientState
            andCompletionHandlingBlock:handlerBlock];
}

+ (void)unsubscribeFromChannel:(PNChannel *)channel {
    
    [self unsubscribeFromChannel:channel withCompletionHandlingBlock:nil];
}

+ (void)unsubscribeFromChannel:(PNChannel *)channel
   withCompletionHandlingBlock:(PNClientChannelUnsubscriptionHandlerBlock)handlerBlock {
    
    [self unsubscribeFromChannels:(channel ? @[channel] : nil) withCompletionHandlingBlock:handlerBlock];
}

+ (void)unsubscribeFromChannels:(NSArray *)channels {
    
    [self unsubscribeFromChannels:channels withCompletionHandlingBlock:nil];
}

+ (void)unsubscribeFromChannels:(NSArray *)channels
    withCompletionHandlingBlock:(PNClientChannelUnsubscriptionHandlerBlock)handlerBlock {

    [self unsubscribeFrom:channels withCompletionHandlingBlock:handlerBlock];
}

+ (void)unsubscribeFrom:(NSArray *)channelObjects {

    [self unsubscribeFrom:channelObjects withCompletionHandlingBlock:nil];
}

+ (void)    unsubscribeFrom:(NSArray *)channelObjects
withCompletionHandlingBlock:(PNClientChannelUnsubscriptionHandlerBlock)handlerBlock {

    [[self sharedInstance] unsubscribeFrom:channelObjects withCompletionHandlingBlock:handlerBlock];
}


#pragma mark - Instance methods

- (NSArray *)subscribedChannels {
    
    return [self subscribedObjectsList];
}

- (NSArray *)subscribedObjectsList {

    return [self.messagingChannel subscribedChannels];
}

- (BOOL)isSubscribedOnChannel:(PNChannel *)channel {

    return [self isSubscribedOn:channel];
}

- (BOOL)isSubscribedOn:(id <PNChannelProtocol>)object {

    return [self.messagingChannel isSubscribedForChannel:object];
}

- (void)subscribeOnChannel:(PNChannel *)channel {
    
    [self subscribeOnChannel:channel withCompletionHandlingBlock:nil];
}

- (void)   subscribeOnChannel:(PNChannel *)channel
  withCompletionHandlingBlock:(PNClientChannelSubscriptionHandlerBlock)handlerBlock {
    
    [self subscribeOnChannel:channel withClientState:nil andCompletionHandlingBlock:handlerBlock];
}

- (void)subscribeOnChannel:(PNChannel *)channel withClientState:(NSDictionary *)clientState {
    
    [self subscribeOnChannel:channel withClientState:clientState andCompletionHandlingBlock:nil];
}

- (void) subscribeOnChannel:(PNChannel *)channel withClientState:(NSDictionary *)clientState
 andCompletionHandlingBlock:(PNClientChannelSubscriptionHandlerBlock)handlerBlock {
    
    // Checking whether client state for channel has been provided in correct format or not.
    if (channel && clientState && ![[clientState valueForKey:channel.name] isKindOfClass:[NSDictionary class]]) {
        
        clientState = @{channel.name: clientState};
    }
    
    [self subscribeOnChannels:(channel ? @[channel] : nil) withClientState:clientState
   andCompletionHandlingBlock:handlerBlock];
}

- (void)subscribeOnChannels:(NSArray *)channels {
    
    [self subscribeOnChannels:channels withCompletionHandlingBlock:nil];
}

- (void)  subscribeOnChannels:(NSArray *)channels
  withCompletionHandlingBlock:(PNClientChannelSubscriptionHandlerBlock)handlerBlock {
    
    [self subscribeOnChannels:channels withClientState:nil andCompletionHandlingBlock:handlerBlock];
}

- (void)subscribeOnChannels:(NSArray *)channels withClientState:(NSDictionary *)clientState {
    
    [self subscribeOnChannels:channels withClientState:clientState andCompletionHandlingBlock:nil];
}

- (void)subscribeOnChannels:(NSArray *)channels withClientState:(NSDictionary *)clientState
 andCompletionHandlingBlock:(PNClientChannelSubscriptionHandlerBlock)handlerBlock {
    
    [self subscribeOn:channels withClientState:clientState andCompletionHandlingBlock:handlerBlock];
}

- (void)subscribeOn:(NSArray *)channelObjects {
    
    [self subscribeOn:channelObjects withCompletionHandlingBlock:nil];
}

- (void)          subscribeOn:(NSArray *)channelObjects
  withCompletionHandlingBlock:(PNClientChannelSubscriptionHandlerBlock)handlerBlock {
    
    [self subscribeOn:channelObjects withClientState:nil andCompletionHandlingBlock:handlerBlock];
}

- (void)subscribeOn:(NSArray *)channelObjects withClientState:(NSDictionary *)clientState {
    
    [self subscribeOn:channelObjects withClientState:clientState andCompletionHandlingBlock:nil];
}

- (void)         subscribeOn:(NSArray *)channelObjects withClientState:(NSDictionary *)clientState
  andCompletionHandlingBlock:(PNClientChannelSubscriptionHandlerBlock)handlerBlock {
    
    [self subscribeOn:channelObjects withCatchUp:NO clientState:clientState
andCompletionHandlingBlock:handlerBlock];
}

- (void)         subscribeOn:(NSArray *)channelObjects withCatchUp:(BOOL)shouldCatchUp
                 clientState:(NSDictionary *)clientState
  andCompletionHandlingBlock:(PNClientChannelSubscriptionHandlerBlock)handlerBlock {
    
    [self pn_dispatchBlock:^{
        
        [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray *{
            
            return @[PNLoggerSymbols.api.subscribeAttempt, (channelObjects ? channelObjects : [NSNull null]),
                     @(shouldCatchUp), [self humanReadableStateFrom:self.state]];
        }];
        
        [self performAsyncLockingBlock:^{
            
            [self.observationCenter removeClientAsSubscriptionObserver];
            [self.observationCenter removeClientAsUnsubscribeObserver];
            
            // Check whether client is able to send request or not
            NSInteger statusCode = [self requestExecutionPossibilityStatusCode];
            if (statusCode == 0 && clientState && ![clientState pn_isValidState]) {
                
                statusCode = kPNInvalidStatePayloadError;
            }
            if (statusCode == 0) {
                
                [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray * {
                    
                    return @[PNLoggerSymbols.api.subscribing, [self humanReadableStateFrom:self.state]];
                }];
                
                if (handlerBlock != nil) {
                    
                    [self.observationCenter addClientAsSubscriptionObserverWithBlock:handlerBlock];
                }
                
                
                [self.messagingChannel subscribeOnChannels:channelObjects withCatchUp:shouldCatchUp
                                            andClientState:clientState];
            }
            // Looks like client can't send request because of some reasons
            else {
                
                [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray * {
                    
                    return @[PNLoggerSymbols.api.subscriptionImpossible, [self humanReadableStateFrom:self.state]];
                }];
                
                PNError *subscriptionError = [PNError errorWithCode:statusCode];
                subscriptionError.associatedObject = channelObjects;
                
                [self notifyDelegateAboutSubscriptionFailWithError:subscriptionError
                                          completeLockingOperation:YES];
                
                
                if (handlerBlock) {
                    
                    handlerBlock(PNSubscriptionProcessNotSubscribedState, channelObjects, subscriptionError);
                }
            }
        }
               postponedExecutionBlock:^{
                   
                   [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray *{
                       
                       return @[PNLoggerSymbols.api.postponeSubscription,
                                [self humanReadableStateFrom:self.state]];
                   }];
                   
                   [self postponeSubscribeOn:channelObjects withCatchUp:shouldCatchUp clientState:clientState
                  andCompletionHandlingBlock:handlerBlock];
               }];
    }];
}

- (void) postponeSubscribeOn:(NSArray *)channelObjects withCatchUp:(BOOL)shouldCatchUp
                 clientState:(NSDictionary *)clientState
  andCompletionHandlingBlock:(PNClientChannelSubscriptionHandlerBlock)handlerBlock {
    
    PNClientChannelSubscriptionHandlerBlock handlerBlockCopy = (handlerBlock ? [handlerBlock copy] : nil);
    [self postponeSelector:@selector(subscribeOn:withCatchUp:clientState:andCompletionHandlingBlock:)
                 forObject:self
            withParameters:@[[PNHelper nilifyIfNotSet:channelObjects], @(shouldCatchUp),
                             [PNHelper nilifyIfNotSet:clientState], [PNHelper nilifyIfNotSet:handlerBlockCopy]]
                outOfOrder:NO];
}

- (void)unsubscribeFromChannel:(PNChannel *)channel {
    
    [self unsubscribeFromChannel:channel withCompletionHandlingBlock:nil];
}

- (void)unsubscribeFromChannel:(PNChannel *)channel
   withCompletionHandlingBlock:(PNClientChannelUnsubscriptionHandlerBlock)handlerBlock {
    
    [self unsubscribeFromChannels:(channel ? @[channel] : nil) withCompletionHandlingBlock:handlerBlock];
}

- (void)unsubscribeFromChannels:(NSArray *)channels {
    
    [self unsubscribeFromChannels:channels withCompletionHandlingBlock:nil];
}

- (void)unsubscribeFromChannels:(NSArray *)channels
    withCompletionHandlingBlock:(PNClientChannelUnsubscriptionHandlerBlock)handlerBlock {

    [self unsubscribeFrom:channels withCompletionHandlingBlock:handlerBlock];
}

- (void)unsubscribeFrom:(NSArray *)channelObjects {

    [self unsubscribeFrom:channelObjects withCompletionHandlingBlock:nil];
}

- (void)    unsubscribeFrom:(NSArray *)channelObjects
withCompletionHandlingBlock:(PNClientChannelUnsubscriptionHandlerBlock)handlerBlock {
    
    [self pn_dispatchBlock:^{
        
        [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray *{
            
            return @[PNLoggerSymbols.api.unsubscribeAttempt, (channelObjects ? channelObjects : [NSNull null]),
                     [self humanReadableStateFrom:self.state]];
        }];
        
        [self performAsyncLockingBlock:^{
            
            [self.observationCenter removeClientAsSubscriptionObserver];
            [self.observationCenter removeClientAsUnsubscribeObserver];
            
            // Check whether client is able to send request or not
            NSInteger statusCode = [self requestExecutionPossibilityStatusCode];
            if (statusCode == 0) {
                
                [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray * {
                    
                    return @[PNLoggerSymbols.api.unsubscribing, [self humanReadableStateFrom:self.state]];
                }];
                
                if (handlerBlock) {
                    
                    [self.observationCenter addClientAsUnsubscribeObserverWithBlock:handlerBlock];
                }
                
                [self.messagingChannel unsubscribeFromChannels:channelObjects];
            }
            // Looks like client can't send request because of some reasons
            else {
                
                [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray * {
                    
                    return @[PNLoggerSymbols.api.unsubscriptionImpossible, [self humanReadableStateFrom:self.state]];
                }];
                
                PNError *unsubscriptionError = [PNError errorWithCode:statusCode];
                unsubscriptionError.associatedObject = channelObjects;
                
                [self notifyDelegateAboutUnsubscriptionFailWithError:unsubscriptionError completeLockingOperation:YES];
                
                
                if (handlerBlock) {
                    
                    handlerBlock(channelObjects, unsubscriptionError);
                }
            }
        }
               postponedExecutionBlock:^{
                   
                   [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray *{
                       
                       return @[PNLoggerSymbols.api.postponeUnsubscription, [self humanReadableStateFrom:self.state]];
                   }];
                   
                   [self postponeUnsubscribeFrom:channelObjects withCompletionHandlingBlock:handlerBlock];
               }];
    }];
}

- (void)postponeUnsubscribeFrom:(NSArray *)channelObjects
    withCompletionHandlingBlock:(PNClientChannelUnsubscriptionHandlerBlock)handlerBlock {
    
    PNClientChannelUnsubscriptionHandlerBlock handlerBlockCopy = (handlerBlock ? [handlerBlock copy] : nil);
    [self postponeSelector:@selector(unsubscribeFrom:withCompletionHandlingBlock:) forObject:self
            withParameters:@[[PNHelper nilifyIfNotSet:channelObjects], [PNHelper nilifyIfNotSet:handlerBlockCopy]]
                outOfOrder:NO];
}

#pragma mark - Misc methods

- (void)notifyDelegateAboutSubscriptionFailWithError:(PNError *)error
                            completeLockingOperation:(BOOL)shouldCompleteLockingOperation {
    
    void(^handlerBlock)(void) = ^{

        if (!self.isUpdatingClientIdentifier) {

            [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray * {

                return @[PNLoggerSymbols.api.subscriptionFailed, (error.associatedObject ? error.associatedObject : [NSNull null]),
                        (error ? error : [NSNull null]), [self humanReadableStateFrom:self.state]];
            }];

            // Check whether delegate is able to handle subscription error or not
            if ([self.clientDelegate respondsToSelector:@selector(pubnubClient:subscriptionDidFailWithError:)]) {

                dispatch_async(dispatch_get_main_queue(), ^{

                    [self.clientDelegate performSelector:@selector(pubnubClient:subscriptionDidFailWithError:) withObject:self
                                              withObject:(id) error];
                });
            }

            [self sendNotification:kPNClientSubscriptionDidFailNotification withObject:error];
        }
        else {

            [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray * {

                return @[PNLoggerSymbols.api.subscriptionOnClientIdentifierChangeFailed,
                        (error.associatedObject ? error.associatedObject : [NSNull null]), (error ? error : [NSNull null]),
                        [self humanReadableStateFrom:self.state]];
            }];

            [self sendNotification:kPNClientSubscriptionDidFailOnClientIdentifierUpdateNotification withObject:error];
        }
    };
    
    if (shouldCompleteLockingOperation) {
        
        [self handleLockingOperationBlockCompletion:handlerBlock shouldStartNext:YES];
    }
    else {
        
        handlerBlock();
    }
}

- (void)notifyDelegateAboutResubscribeWillStartOnChannels:(NSArray *)channels {
    
    if ([channels count] > 0) {

        [self checkShouldChannelNotifyAboutEvent:self.messagingChannel withBlock:^(BOOL shouldNotify) {

            if (shouldNotify) {

                #pragma clang diagnostic push
                #pragma clang diagnostic ignored "-Wdeprecated-declarations"
                // Notify delegate that client is about to restore subscription on previously subscribed channels
                if ([self.clientDelegate respondsToSelector:@selector(pubnubClient:willRestoreSubscriptionOnChannels:)]) {

                    dispatch_async(dispatch_get_main_queue(), ^{

                        [self.clientDelegate performSelector:@selector(pubnubClient:willRestoreSubscriptionOnChannels:)
                                                  withObject:self withObject:channels];
                    });
                }
                #pragma clang diagnostic pop

                // Notify delegate that client is about to restore subscription on previously subscribed channels
                if ([self.clientDelegate respondsToSelector:@selector(pubnubClient:willRestoreSubscriptionOn:)]) {

                    dispatch_async(dispatch_get_main_queue(), ^{

                        [self.clientDelegate performSelector:@selector(pubnubClient:willRestoreSubscriptionOn:)
                                                  withObject:self withObject:channels];
                    });
                }

                [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray *{

                    return @[PNLoggerSymbols.api.resumingSubscription, (channels ? channels : [NSNull null]),
                            [self humanReadableStateFrom:self.state]];
                }];


                [self sendNotification:kPNClientSubscriptionWillRestoreNotification withObject:channels];
            }
        }];
    }
}

- (void)notifyDelegateAboutUnsubscriptionFailWithError:(PNError *)error
                              completeLockingOperation:(BOOL)shouldCompleteLockingOperation {
    
    void(^handlerBlock)(void) = ^{

        if (!self.isUpdatingClientIdentifier) {

            [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray * {

                return @[PNLoggerSymbols.api.unsubscriptionFailed, (error.associatedObject ? error.associatedObject : [NSNull null]),
                        (error ? error : [NSNull null]), [self humanReadableStateFrom:self.state]];
            }];

            // Check whether delegate is able to handle unsubscription error or not
            if ([self.clientDelegate respondsToSelector:@selector(pubnubClient:unsubscriptionDidFailWithError:)]) {

                dispatch_async(dispatch_get_main_queue(), ^{

                    [self.clientDelegate performSelector:@selector(pubnubClient:unsubscriptionDidFailWithError:) withObject:self
                                              withObject:(id) error];
                });
            }


            [self sendNotification:kPNClientUnsubscriptionDidFailNotification withObject:error];
        }
        else {

            [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray * {

                return @[PNLoggerSymbols.api.unsubscriptionOnClientIdentifierChangeFailed,
                        (error.associatedObject ? error.associatedObject : [NSNull null]), (error ? error : [NSNull null]),
                        [self humanReadableStateFrom:self.state]];
            }];

            [self sendNotification:kPNClientUnsubscriptionDidFailOnClientIdentifierUpdateNotification withObject:error];
        }
    };
    
    if (shouldCompleteLockingOperation) {
        
        [self handleLockingOperationBlockCompletion:handlerBlock shouldStartNext:YES];
    }
    else {
        
        handlerBlock();
    }
}


#pragma mark - Message channel delegate methods

- (void)messagingChannel:(PNMessagingChannel *)messagingChannel willSubscribeOnChannels:(NSArray *)channels
               sequenced:(BOOL)isSequenced {
    
    [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray *{
        
        return @[PNLoggerSymbols.api.willSubscribe, (channels? channels : [NSNull null]), [self humanReadableStateFrom:self.state]];
    }];
    
    [self pn_dispatchBlock:^{
    
        if ([self isConnected]) {
            
            self.asyncLockingOperationInProgress = YES;
        }
    }];
}

- (void)messagingChannel:(PNMessagingChannel *)channel didSubscribeOn:(NSArray *)channelObjects
               sequenced:(BOOL)isSequenced withClientState:(NSDictionary *)clientState {

    void(^handlingBlock)(BOOL) = ^(BOOL shouldNotify){

        self.restoringConnection = NO;

        // Storing new data for channels.
        [self.cache storeClientState:clientState forChannels:channelObjects];

        [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray * {

            return @[PNLoggerSymbols.api.didSubscribe, (channelObjects ? channelObjects : [NSNull null]),
                    [self humanReadableStateFrom:self.state]];
        }];

        if (shouldNotify) {

            if (!self.isUpdatingClientIdentifier) {

                #pragma clang diagnostic push
                #pragma clang diagnostic ignored "-Wdeprecated-declarations"
                // Check whether delegate can handle subscription on channel or not
                if ([self.clientDelegate respondsToSelector:@selector(pubnubClient:didSubscribeOnChannels:)]) {

                    dispatch_async(dispatch_get_main_queue(), ^{

                        [self.clientDelegate performSelector:@selector(pubnubClient:didSubscribeOnChannels:)
                                                  withObject:self withObject:channelObjects];
                    });
                }
                #pragma clang diagnostic pop

                // Check whether delegate can handle subscription on channel or not
                if ([self.clientDelegate respondsToSelector:@selector(pubnubClient:didSubscribeOn:)]) {

                    dispatch_async(dispatch_get_main_queue(), ^{

                        [self.clientDelegate performSelector:@selector(pubnubClient:didSubscribeOn:)
                                                  withObject:self withObject:channelObjects];
                    });
                }

                [self sendNotification:kPNClientSubscriptionDidCompleteNotification withObject:channelObjects];
            }
            else {

                [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray * {

                    return @[PNLoggerSymbols.api.didSubscribeDuringClientIdentifierChange,
                            (channelObjects ? channelObjects : [NSNull null]),
                            [self humanReadableStateFrom:self.state]];
                }];

                [self sendNotification:kPNClientSubscriptionDidCompleteOnClientIdentifierUpdateNotification
                            withObject:channelObjects];
            }
        }
    };
    
    [self checkShouldChannelNotifyAboutEvent:channel withBlock:^(BOOL shouldNotify) {
        
        [self pn_dispatchBlock:^{
            
            if (!isSequenced) {
                
                [self handleLockingOperationBlockCompletion:^{
                    
                    handlingBlock(shouldNotify);
                }
                                            shouldStartNext:YES];
            }
            else {
                
                handlingBlock(shouldNotify);
            }
            
            [self launchHeartbeatTimer];
        }];
    }];
}

- (void)messagingChannel:(PNMessagingChannel *)messagingChannel willRestoreSubscriptionOn:(NSArray *)channelObjects
               sequenced:(BOOL)isSequenced {
    
    [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray *{
        
        return @[PNLoggerSymbols.api.willRestoreSubscription, (channelObjects ? channelObjects : [NSNull null]),
                 [self humanReadableStateFrom:self.state]];
    }];

    void(^checkCompletionBlock)(BOOL) = ^(BOOL connected){

        [self pn_dispatchBlock:^{

            if (connected) {

                self.asyncLockingOperationInProgress = YES;
            }

            [self notifyDelegateAboutResubscribeWillStartOnChannels:channelObjects];
        }];
    };
    if (messagingChannel) {

        [messagingChannel checkConnected:checkCompletionBlock];
    }
    else {

        checkCompletionBlock(NO);
    }
}

- (void)messagingChannel:(PNMessagingChannel *)messagingChannel didRestoreSubscriptionOn:(NSArray *)channelObjects
               sequenced:(BOOL)isSequenced {

    [self pn_dispatchBlock:^{
        
        self.restoringConnection = NO;

        void(^handlingBlock)(BOOL) = ^(BOOL shouldNotify){

            [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray *{

                return @[PNLoggerSymbols.api.restoredSubscription, (channelObjects ? channelObjects : [NSNull null]),
                        [self humanReadableStateFrom:self.state]];
            }];

            if (shouldNotify) {

                #pragma clang diagnostic push
                #pragma clang diagnostic ignored "-Wdeprecated-declarations"
                // Check whether delegate can handle subscription restore on channels or not
                if ([self.clientDelegate respondsToSelector:@selector(pubnubClient:didRestoreSubscriptionOnChannels:)]) {

                    dispatch_async(dispatch_get_main_queue(), ^{

                        [self.clientDelegate performSelector:@selector(pubnubClient:didRestoreSubscriptionOnChannels:)
                                                  withObject:self withObject:channelObjects];
                    });
                }
                #pragma clang diagnostic pop

                // Check whether delegate can handle subscription restore on channels or not
                if ([self.clientDelegate respondsToSelector:@selector(pubnubClient:didRestoreSubscriptionOn:)]) {

                    dispatch_async(dispatch_get_main_queue(), ^{

                        [self.clientDelegate performSelector:@selector(pubnubClient:didRestoreSubscriptionOn:)
                                                  withObject:self withObject:channelObjects];
                    });
                }

                [self sendNotification:kPNClientSubscriptionDidRestoreNotification withObject:channelObjects];
            }
        };


        [self checkShouldChannelNotifyAboutEvent:messagingChannel withBlock:^(BOOL shouldNotify) {

            if (!isSequenced) {

                [self handleLockingOperationBlockCompletion:^{

                    handlingBlock(shouldNotify);
                }
                                            shouldStartNext:YES];
            }
            else {

                handlingBlock(shouldNotify);
            }

            [self launchHeartbeatTimer];
        }];
    }];
}

- (void)messagingChannel:(PNMessagingChannel *)channel didFailSubscribeOn:(NSArray *)channelObjects
               withError:(PNError *)error sequenced:(BOOL)isSequenced {
    
    error.associatedObject = channelObjects;
    [self notifyDelegateAboutSubscriptionFailWithError:error completeLockingOperation:!isSequenced];
    
    [self launchHeartbeatTimer];
}

- (void)messagingChannel:(PNMessagingChannel *)messagingChannel willUnsubscribeFrom:(NSArray *)channelObjects
               sequenced:(BOOL)isSequenced {
    
    [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray *{
        
        return @[PNLoggerSymbols.api.willUnsubscribe, (channelObjects ? channelObjects : [NSNull null]),
                 [self humanReadableStateFrom:self.state]];
    }];
    
    [self pn_dispatchBlock:^{
    
        if ([self isConnected]) {
            
            self.asyncLockingOperationInProgress = YES;
        }
    }];
}

- (void)messagingChannel:(PNMessagingChannel *)channel didUnsubscribeFrom:(NSArray *)channelObjects
               sequenced:(BOOL)isSequenced {

    void(^handlingBlock)(BOOL) = ^(BOOL shouldNotify){

        // Removing cached data for channels set.
        [self.cache purgeStateForChannels:channelObjects];

        [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray * {

            return @[PNLoggerSymbols.api.didUnsubscribe, (channelObjects ? channelObjects : [NSNull null]),
                    [self humanReadableStateFrom:self.state]];
        }];

        if (shouldNotify) {

            if (!self.isUpdatingClientIdentifier) {

                #pragma clang diagnostic push
                #pragma clang diagnostic ignored "-Wdeprecated-declarations"
                // Check whether delegate can handle unsubscription event or not
                if ([self.clientDelegate respondsToSelector:@selector(pubnubClient:didUnsubscribeOnChannels:)]) {

                    dispatch_async(dispatch_get_main_queue(), ^{

                        [self.clientDelegate performSelector:@selector(pubnubClient:didUnsubscribeOnChannels:)
                                                  withObject:self withObject:channelObjects];
                    });
                }
                #pragma clang diagnostic pop

                // Check whether delegate can handle unsubscription event or not
                if ([self.clientDelegate respondsToSelector:@selector(pubnubClient:didUnsubscribeFrom:)]) {

                    dispatch_async(dispatch_get_main_queue(), ^{

                        [self.clientDelegate performSelector:@selector(pubnubClient:didUnsubscribeFrom:)
                                                  withObject:self withObject:channelObjects];
                    });
                }

                [self sendNotification:kPNClientUnsubscriptionDidCompleteNotification withObject:channelObjects];
            }
            else {

                [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray * {

                    return @[PNLoggerSymbols.api.didUnsubscribeDuringClientIdentifierChange,
                            (channelObjects ? channelObjects : [NSNull null]), [self humanReadableStateFrom:self.state]];
                }];

                [self sendNotification:kPNClientUnsubscriptionDidCompleteOnClientIdentifierUpdateNotification withObject:self];
            }
        }
    };

    [self checkShouldChannelNotifyAboutEvent:channel withBlock:^(BOOL shouldNotify) {

        [self pn_dispatchBlock:^{

            if (!isSequenced) {

                [self handleLockingOperationBlockCompletion:^{

                    handlingBlock(shouldNotify);
                }
                                            shouldStartNext:YES];
            }
            else {

                handlingBlock(shouldNotify);
            }

            [self launchHeartbeatTimer];
        }];
    }];
}

- (void)messagingChannel:(PNMessagingChannel *)channel didFailUnsubscribeFrom:(NSArray *)channelObjects
               withError:(PNError *)error sequenced:(BOOL)isSequenced {
    
    error.associatedObject = channelObjects;
    [self notifyDelegateAboutUnsubscriptionFailWithError:error completeLockingOperation:!isSequenced];
    
    [self launchHeartbeatTimer];
}

- (void)messagingChannel:(PNMessagingChannel *)messagingChannel didReceiveMessage:(PNMessage *)message {
    
    [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray *{
        
        return @[PNLoggerSymbols.api.didReceiveMessage, (message.message ? message.message : [NSNull null]),
                 (message.channel ? message.channel : [NSNull null]),
                 [self humanReadableStateFrom:self.state]];
    }];
    [self launchHeartbeatTimer];

    [self checkShouldChannelNotifyAboutEvent:messagingChannel withBlock:^(BOOL shouldNotify) {

        [self pn_dispatchBlock:^{

            // In case if cryptor configured and ready to go, message will be decrypted.
            if (self.cryptoHelper.ready) {

                message.message = [self AESDecrypt:message.message];
            }

            if (shouldNotify) {

                // Check whether delegate can handle new message arrival or not
                if ([self.clientDelegate respondsToSelector:@selector(pubnubClient:didReceiveMessage:)]) {

                    dispatch_async(dispatch_get_main_queue(), ^{

                        [self.clientDelegate performSelector:@selector(pubnubClient:didReceiveMessage:) withObject:self
                                                  withObject:message];
                    });
                }

                [self sendNotification:kPNClientDidReceiveMessageNotification withObject:message];
            }
        }];
    }];
}

#pragma mark -


@end
