/**
 
 @author Sergey Mamontov
 @version 3.7.0
 @copyright © 2009-14 PubNub Inc.
 
 */

#import "PubNub+PresenceEvents.h"
#import "NSObject+PNAdditions.h"
#import "PNMessagingChannel.h"
#import "PubNub+Protected.h"
#import "PNNotifications.h"
#import "PNPresenceEvent.h"
#import "PNHelper.h"
#import "PNCache.h"

#import "PNLogger+Protected.h"
#import "PNLoggerSymbols.h"


#pragma mark - Category private interface declaration

@interface PubNub (PresenceEventsPrivate)


#pragma mark - Instance methods

/**
 @brief Postpone presence observation enabling user request so it will be executed in future.
 
 @discussion Postpone can be because of few cases: \b PubNub client is in connecting or initial connection state;
 another request which has been issued earlier didn't completed yet.
 
 @param channelObjects List of objects (which conforms to \b PNChannelProtocol data feed object protocol) like
                       \b PNChannel or \b PNChannelGroup for which \b PubNub client should enable presence events
                       observation.
 @param handlerBlock   The block which will be called by \b PubNub client as soon as presence enabling state will
                       change. The block takes two arguments: \c channels - array of \b PNChannel instances for which
                       presence enabling state changed; \c error - describes what exactly went wrong (check error code
                       and compare it with \b PNErrorCodes ).

 @since 3.7.0
 */
- (void)postponeEnablePresenceObservationFor:(NSArray *)channelObjects withCompletionHandlingBlock:(id)handlerBlock;

/**
 @brief Postpone presence observation disabling user request so it will be executed in future.
 
 @discussion Postpone can be because of few cases: \b PubNub client is in connecting or initial connection state;
 another request which has been issued earlier didn't completed yet.

 @param channelObjects List of objects (which conforms to \b PNChannelProtocol data feed object protocol) like
                       \b PNChannel or \b PNChannelGroup for which \b PubNub client should disable presence events
                       observation.
 @param handlerBlock   Handler block which is called by \b PubNub client when presence disabling process state changes.
                       Block pass two arguments: \c channels - List of \b PNChannel instances for which presence
                       disabling process changed state; \c error - \b PNError instance which hold information about why
                       presence disabling process failed. Always check \a error.code to find out what caused error
                       (check PNErrorCodes header file and use \a -localizedDescription / \a -localizedFailureReason and
                       \a -localizedRecoverySuggestion to get human readable description for error).
 */
- (void)postponeDisablePresenceObservationFor:(NSArray *)channelObjects withCompletionHandlingBlock:(id)handlerBlock;


#pragma mark - Misc methods

/**
 This method will notify delegate about that presence enabling failed with error.
 
 @note Always check \a error.code to find out what caused error (check PNErrorCodes header file and use \a -localizedDescription /
 \a -localizedFailureReason and \a -localizedRecoverySuggestion to get human readable description for error).
 
 @param error
 Instance of \b PNError which describes what exactly happened and why this error occurred. \a 'error.associatedObject'
 contains reference on \b PNAccessRightOptions instance which will allow to review and identify what options \b PubNub client tried to apply.
 
 @param shouldCompleteLockingOperation
 Whether procedural lock should be released after delegate notification or not.
 */
- (void)notifyDelegateAboutPresenceEnablingFailWithError:(PNError *)error
                                completeLockingOperation:(BOOL)shouldCompleteLockingOperation;

/**
 This method will notify delegate about that presence disabling failed with error.
 
 @note Always check \a error.code to find out what caused error (check PNErrorCodes header file and use \a -localizedDescription /
 \a -localizedFailureReason and \a -localizedRecoverySuggestion to get human readable description for error).
 
 @param error
 Instance of \b PNError which describes what exactly happened and why this error occurred. \a 'error.associatedObject'
 contains reference on \b PNAccessRightOptions instance which will allow to review and identify what options \b PubNub client tried to apply.
 
 @param shouldCompleteLockingOperation
 Whether procedural lock should be released after delegate notification or not.
 */
- (void)notifyDelegateAboutPresenceDisablingFailWithError:(PNError *)error
                                 completeLockingOperation:(BOOL)shouldCompleteLockingOperation;

#pragma mark -


@end


#pragma mark - Category methods implementation

@implementation PubNub (PresenceEvents)


#pragma mark - Class (singleton) methods

+ (BOOL)isPresenceObservationEnabledForChannel:(PNChannel *)channel {
    
    return [[self sharedInstance] isPresenceObservationEnabledForChannel:channel];
}

+ (BOOL)isPresenceObservationEnabledFor:(id <PNChannelProtocol>)object {

    return [[self sharedInstance] isPresenceObservationEnabledFor:object];
}

+ (void)enablePresenceObservationForChannel:(PNChannel *)channel {
    
    [self enablePresenceObservationForChannel:channel withCompletionHandlingBlock:nil];
}

+ (void)enablePresenceObservationForChannel:(PNChannel *)channel
                withCompletionHandlingBlock:(PNClientPresenceEnableHandlingBlock)handlerBlock {
    
    [self enablePresenceObservationForChannels:(channel ? @[channel] : nil) withCompletionHandlingBlock:handlerBlock];
}

+ (void)enablePresenceObservationForChannels:(NSArray *)channels {
    
    [self enablePresenceObservationForChannels:channels withCompletionHandlingBlock:nil];
}

+ (void)enablePresenceObservationForChannels:(NSArray *)channels
                 withCompletionHandlingBlock:(PNClientPresenceEnableHandlingBlock)handlerBlock {

    [self enablePresenceObservationFor:channels withCompletionHandlingBlock:handlerBlock];
}

+ (void)enablePresenceObservationFor:(NSArray *)channelObjects {

    [self enablePresenceObservationFor:channelObjects withCompletionHandlingBlock:nil];
}

+ (void)enablePresenceObservationFor:(NSArray *)channelObjects
         withCompletionHandlingBlock:(PNClientPresenceEnableHandlingBlock)handlerBlock {

    [[self sharedInstance] enablePresenceObservationFor:channelObjects withCompletionHandlingBlock:handlerBlock];
}

+ (void)disablePresenceObservationForChannel:(PNChannel *)channel {
    
    [self disablePresenceObservationForChannel:channel withCompletionHandlingBlock:nil];
}

+ (void)disablePresenceObservationForChannel:(PNChannel *)channel
                 withCompletionHandlingBlock:(PNClientPresenceDisableHandlingBlock)handlerBlock {
    
    [self disablePresenceObservationForChannels:@[channel] withCompletionHandlingBlock:handlerBlock];
}

+ (void)disablePresenceObservationForChannels:(NSArray *)channels {
    
    [self disablePresenceObservationForChannels:channels withCompletionHandlingBlock:nil];
}

+ (void)disablePresenceObservationForChannels:(NSArray *)channels
                  withCompletionHandlingBlock:(PNClientPresenceDisableHandlingBlock)handlerBlock {

    [self disablePresenceObservationFor:channels withCompletionHandlingBlock:handlerBlock];
}

+ (void)disablePresenceObservationFor:(NSArray *)channelObjects {

    [self disablePresenceObservationFor:channelObjects withCompletionHandlingBlock:nil];
}

+ (void)disablePresenceObservationFor:(NSArray *)channelObjects
          withCompletionHandlingBlock:(PNClientPresenceDisableHandlingBlock)handlerBlock {

    [[self sharedInstance] disablePresenceObservationFor:channelObjects withCompletionHandlingBlock:handlerBlock];
}


#pragma mark - Instance methods

- (BOOL)isPresenceObservationEnabledForChannel:(PNChannel *)channel {

    return [self isPresenceObservationEnabledFor:channel];
}

- (BOOL)isPresenceObservationEnabledFor:(id <PNChannelProtocol>)object {

    BOOL observingPresence = NO;

    // Ensure that PubNub client currently connected to
    // remote PubNub services
    if ([self isConnected]) {

        observingPresence = [self.messagingChannel isPresenceObservationEnabledForChannel:object];
    }


    return observingPresence;
}

- (void)enablePresenceObservationForChannel:(PNChannel *)channel {
    
    [self enablePresenceObservationForChannel:channel withCompletionHandlingBlock:nil];
}

- (void)enablePresenceObservationForChannel:(PNChannel *)channel
                withCompletionHandlingBlock:(PNClientPresenceEnableHandlingBlock)handlerBlock {
    
    [self enablePresenceObservationForChannels:(channel ? @[channel] : nil) withCompletionHandlingBlock:handlerBlock];
}

- (void)enablePresenceObservationForChannels:(NSArray *)channels {
    
    [self enablePresenceObservationForChannels:channels withCompletionHandlingBlock:nil];
}

- (void)enablePresenceObservationForChannels:(NSArray *)channels
                 withCompletionHandlingBlock:(PNClientPresenceEnableHandlingBlock)handlerBlock {

    [self enablePresenceObservationFor:channels withCompletionHandlingBlock:handlerBlock];
}

- (void)enablePresenceObservationFor:(NSArray *)channelObjects {

    [self enablePresenceObservationFor:channelObjects withCompletionHandlingBlock:nil];
}

- (void)enablePresenceObservationFor:(NSArray *)channelObjects
         withCompletionHandlingBlock:(PNClientPresenceEnableHandlingBlock)handlerBlock {

    [self pn_dispatchBlock:^{
        
        [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray *{
            
            return @[PNLoggerSymbols.api.presenceObservationEnableAttempt, (channelObjects ? channelObjects : [NSNull null]),
                     [self humanReadableStateFrom:self.state]];
        }];
        
        [self performAsyncLockingBlock:^{
            
            [self.observationCenter removeClientAsPresenceEnabling];
            [self.observationCenter removeClientAsPresenceDisabling];
            
            // Check whether client is able to send request or not
            NSInteger statusCode = [self requestExecutionPossibilityStatusCode];
            if (statusCode == 0) {
                
                [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray * {
                    
                    return @[PNLoggerSymbols.api.enablingPresenceObservation, [self humanReadableStateFrom:self.state]];
                }];
                
                if (handlerBlock != nil) {
                    
                    [self.observationCenter addClientAsPresenceEnablingObserverWithBlock:handlerBlock];
                }
                
                // Enumerate over the list of channels and mark that it should observe for presence
                [channelObjects enumerateObjectsUsingBlock:^(PNChannel *channel, NSUInteger channelIdx, BOOL *channelEnumeratorStop) {
                    
                    channel.observePresence = YES;
                    channel.linkedWithPresenceObservationChannel = NO;
                }];
                
                [self.messagingChannel enablePresenceObservationForChannels:channelObjects];
            }
            else {
                
                [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray * {
                    
                    return @[PNLoggerSymbols.api.presenceObservationEnableImpossible, [self humanReadableStateFrom:self.state]];
                }];
                
                PNError *presenceEnableError = [PNError errorWithCode:statusCode];
                presenceEnableError.associatedObject = channelObjects;
                
                
                [self notifyDelegateAboutPresenceEnablingFailWithError:presenceEnableError completeLockingOperation:YES];
                
                if (handlerBlock != nil) {
                    
                    handlerBlock(channelObjects, presenceEnableError);
                }
            }
            
        }
               postponedExecutionBlock:^{
                   
                   [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray *{
                       
                       return @[PNLoggerSymbols.api.postponePresenceObservationEnable, [self humanReadableStateFrom:self.state]];
                   }];
                   
                   [self postponeEnablePresenceObservationFor:channelObjects withCompletionHandlingBlock:handlerBlock];
               }];
    }];
}

- (void)postponeEnablePresenceObservationFor:(NSArray *)channelObjects withCompletionHandlingBlock:(id)handlerBlock {

    id handlerBlockCopy = (handlerBlock ? [handlerBlock copy] : nil);
    [self postponeSelector:@selector(enablePresenceObservationFor:withCompletionHandlingBlock:) forObject:self
            withParameters:@[[PNHelper nilifyIfNotSet:channelObjects], [PNHelper nilifyIfNotSet:handlerBlockCopy]] outOfOrder:NO];
}

- (void)disablePresenceObservationForChannel:(PNChannel *)channel {
    
    [self disablePresenceObservationForChannel:channel withCompletionHandlingBlock:nil];
}

- (void)disablePresenceObservationForChannel:(PNChannel *)channel
                 withCompletionHandlingBlock:(PNClientPresenceDisableHandlingBlock)handlerBlock {
    
    [self disablePresenceObservationForChannels:(channel ? @[channel] : nil) withCompletionHandlingBlock:handlerBlock];
}

- (void)disablePresenceObservationForChannels:(NSArray *)channels {
    
    [self disablePresenceObservationForChannels:channels withCompletionHandlingBlock:nil];
}

- (void)disablePresenceObservationForChannels:(NSArray *)channels
                  withCompletionHandlingBlock:(PNClientPresenceDisableHandlingBlock)handlerBlock {

    [self disablePresenceObservationFor:channels withCompletionHandlingBlock:handlerBlock];
}

- (void)disablePresenceObservationFor:(NSArray *)channelObjects {

    [self disablePresenceObservationFor:channelObjects withCompletionHandlingBlock:nil];
}

- (void)disablePresenceObservationFor:(NSArray *)channelObjects
          withCompletionHandlingBlock:(PNClientPresenceDisableHandlingBlock)handlerBlock {

    [self pn_dispatchBlock:^{
        
        [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray *{
            
            return @[PNLoggerSymbols.api.presenceObservationDisableAttempt, (channelObjects ? channelObjects : [NSNull null]),
                     [self humanReadableStateFrom:self.state]];
        }];
        
        [self performAsyncLockingBlock:^{
            
            [self.observationCenter removeClientAsPresenceEnabling];
            [self.observationCenter removeClientAsPresenceDisabling];
            
            // Check whether client is able to send request or not
            NSInteger statusCode = [self requestExecutionPossibilityStatusCode];
            if (statusCode == 0) {
                
                [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray * {
                    
                    return @[PNLoggerSymbols.api.disablingPresenceObservation, [self humanReadableStateFrom:self.state]];
                }];
                
                if (handlerBlock != nil) {
                    
                    [self.observationCenter addClientAsPresenceDisablingObserverWithBlock:handlerBlock];
                }
                
                [self.messagingChannel disablePresenceObservationForChannels:channelObjects];
            }
            else {
                
                [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray * {
                    
                    return @[PNLoggerSymbols.api.presenceObservationDisableImpossible,
                             [self humanReadableStateFrom:self.state]];
                }];
                
                PNError *presencedisableError = [PNError errorWithCode:statusCode];
                presencedisableError.associatedObject = channelObjects;
                
                
                [self notifyDelegateAboutPresenceDisablingFailWithError:presencedisableError
                                               completeLockingOperation:YES];
                
                if (handlerBlock != nil) {
                    
                    handlerBlock(channelObjects, presencedisableError);
                }
            }
        }
               postponedExecutionBlock:^{
                   
                   [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray *{
                       
                       return @[PNLoggerSymbols.api.postponePresenceObservationDisable,
                                [self humanReadableStateFrom:self.state]];
                   }];
                   
                   [self postponeDisablePresenceObservationFor:channelObjects withCompletionHandlingBlock:handlerBlock];
               }];
    }];
}

- (void)postponeDisablePresenceObservationFor:(NSArray *)channelObjects
                  withCompletionHandlingBlock:(id)handlerBlock {
    
    id handlerBlockCopy = (handlerBlock ? [handlerBlock copy] : nil);
    [self postponeSelector:@selector(disablePresenceObservationFor:withCompletionHandlingBlock:) forObject:self
            withParameters:@[[PNHelper nilifyIfNotSet:channelObjects], [PNHelper nilifyIfNotSet:handlerBlockCopy]] outOfOrder:NO];
}


#pragma mark - Misc methods

- (void)notifyDelegateAboutPresenceEnablingFailWithError:(PNError *)error
                                completeLockingOperation:(BOOL)shouldCompleteLockingOperation {
    
    void(^handlerBlock)(void) = ^{
        
        [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray *{
            
            return @[PNLoggerSymbols.api.presenceObservationEnablingFailed,
                     (error.associatedObject ? error.associatedObject : [NSNull null]),
                     (error ? error : [NSNull null]), [self humanReadableStateFrom:self.state]];
        }];
        
        // Check whether delegate is able to handle unsubscription error or not
        if ([self.clientDelegate respondsToSelector:@selector(pubnubClient:presenceObservationEnablingDidFailWithError:)]) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
            
                [self.clientDelegate performSelector:@selector(pubnubClient:presenceObservationEnablingDidFailWithError:)
                                          withObject:self withObject:(id)error];
            });
        }
        
        [self sendNotification:kPNClientPresenceEnablingDidFailNotification withObject:error];
    };
    
    if (shouldCompleteLockingOperation) {
        
        [self handleLockingOperationBlockCompletion:handlerBlock shouldStartNext:YES];
    }
    else {
        
        handlerBlock();
    }
}

- (void)notifyDelegateAboutPresenceDisablingFailWithError:(PNError *)error
                                 completeLockingOperation:(BOOL)shouldCompleteLockingOperation {
    
    void(^handlerBlock)(void) = ^{
        
        [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray *{
            
            return @[PNLoggerSymbols.api.presenceObservationDisablingFailed,
                     (error.associatedObject ? error.associatedObject : [NSNull null]),
                     (error ? error : [NSNull null]), [self humanReadableStateFrom:self.state]];
        }];
        
        // Check whether delegate is able to handle unsubscription error or not
        if ([self.clientDelegate respondsToSelector:@selector(pubnubClient:presenceObservationDisablingDidFailWithError:)]) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
            
                [self.clientDelegate performSelector:@selector(pubnubClient:presenceObservationDisablingDidFailWithError:)
                                          withObject:self withObject:(id)error];
            });
        }
        
        [self sendNotification:kPNClientPresenceDisablingDidFailNotification withObject:error];
    };
    
    if (shouldCompleteLockingOperation) {
        
        [self handleLockingOperationBlockCompletion:handlerBlock shouldStartNext:YES];
    }
    else {
        
        handlerBlock();
    }
}


#pragma mark - Message channel delegate methods

- (void)messagingChannel:(PNMessagingChannel *)messagingChannel willEnablePresenceObservationOn:(NSArray *)channelObjects
               sequenced:(BOOL)isSequenced {
    
    [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray *{
        
        return @[PNLoggerSymbols.api.willEnablePresenceObservation, (channelObjects ? channelObjects : [NSNull null]),
                 [self humanReadableStateFrom:self.state]];
    }];

    [self pn_dispatchBlock:^{

        if ([self isConnected]) {

            self.asyncLockingOperationInProgress = YES;
        }
    }];
}

- (void)messagingChannel:(PNMessagingChannel *)messagingChannel didEnablePresenceObservationOn:(NSArray *)channelObjects
               sequenced:(BOOL)isSequenced {
    
    void(^handlerBlock)(BOOL) = ^(BOOL shouldNotify){
        
        [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray *{
            
            return @[PNLoggerSymbols.api.enabledPresenceObservation, (channelObjects ? channelObjects : [NSNull null]),
                     [self humanReadableStateFrom:self.state]];
        }];

        if (shouldNotify) {

            // Check whether delegate can handle new message arrival or not
            if ([self.clientDelegate respondsToSelector:@selector(pubnubClient:didEnablePresenceObservationOn:)]) {

                dispatch_async(dispatch_get_main_queue(), ^{

                    [self.clientDelegate performSelector:@selector(pubnubClient:didEnablePresenceObservationOn:)
                                              withObject:self withObject:channelObjects];
                });
            }

            [self sendNotification:kPNClientPresenceEnablingDidCompleteNotification withObject:channelObjects];
        }
    };
    
    [self checkShouldChannelNotifyAboutEvent:messagingChannel withBlock:^(BOOL shouldNotify) {
        
        if (!isSequenced) {
            
            [self handleLockingOperationBlockCompletion:^{
                
                handlerBlock(shouldNotify);
            }
                                        shouldStartNext:YES];
        }
        else {
            
            handlerBlock(shouldNotify);
        }
    }];
}

- (void)messagingChannel:(PNMessagingChannel *)messagingChannel didFailPresenceEnablingOn:(NSArray *)channelObjects
               withError:(PNError *)error sequenced:(BOOL)isSequenced {
    
    error.associatedObject = channelObjects;
    [self notifyDelegateAboutPresenceEnablingFailWithError:error completeLockingOperation:!isSequenced];
}

- (void)messagingChannel:(PNMessagingChannel *)messagingChannel willDisablePresenceObservationOn:(NSArray *)channelObjects
               sequenced:(BOOL)isSequenced {
    
    [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray *{
        
        return @[PNLoggerSymbols.api.willDisablePresenceObservation, (channelObjects ? channelObjects : [NSNull null]),
                 [self humanReadableStateFrom:self.state]];
    }];

    [self pn_dispatchBlock:^{

        if ([self isConnected]) {

            self.asyncLockingOperationInProgress = YES;
        }
    }];
}

- (void)messagingChannel:(PNMessagingChannel *)messagingChannel didDisablePresenceObservationOn:(NSArray *)channelObjects
               sequenced:(BOOL)isSequenced {
    
    void(^handlerBlock)(BOOL) = ^(BOOL shouldNotify){
        
        [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray *{
            
            return @[PNLoggerSymbols.api.disabledPresenceObservation, (channelObjects ? channelObjects : [NSNull null]),
                     [self humanReadableStateFrom:self.state]];
        }];

        if (shouldNotify) {

            // Check whether delegate can handle new message arrival or not
            if ([self.clientDelegate respondsToSelector:@selector(pubnubClient:didDisablePresenceObservationOn:)]) {

                dispatch_async(dispatch_get_main_queue(), ^{

                    [self.clientDelegate performSelector:@selector(pubnubClient:didDisablePresenceObservationOn:)
                                              withObject:self withObject:channelObjects];
                });
            }

            [self sendNotification:kPNClientPresenceDisablingDidCompleteNotification withObject:channelObjects];
        }
    };
    
    [self checkShouldChannelNotifyAboutEvent:messagingChannel withBlock:^(BOOL shouldNotify) {
        
        if (!isSequenced) {
            
            [self handleLockingOperationBlockCompletion:^{
                
                handlerBlock(shouldNotify);
            }
                                        shouldStartNext:YES];
        }
        else {
            
            handlerBlock(shouldNotify);
        }
    }];
}

- (void)messagingChannel:(PNMessagingChannel *)messagingChannel didFailPresenceDisablingOn:(NSArray *)channelObjects
               withError:(PNError *)error sequenced:(BOOL)isSequenced {
    
    error.associatedObject = channelObjects;
    [self notifyDelegateAboutPresenceDisablingFailWithError:error completeLockingOperation:!isSequenced];
}

- (void)messagingChannel:(PNMessagingChannel *)messagingChannel didReceiveEvent:(PNPresenceEvent *)event {
    
    // Try to update cached channel data
    PNChannel *channel = event.channel;
    if (channel) {
        
        [channel updateWithEvent:event];
    }
    
    [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray *{
        
        return @[PNLoggerSymbols.api.didReceiveEvent, (event ? event : [NSNull null]), (event.channel ? event.channel : [NSNull null]),
                 [self humanReadableStateFrom:self.state]];
    }];
    
    [self launchHeartbeatTimer];

    [self checkShouldChannelNotifyAboutEvent:messagingChannel withBlock:^(BOOL shouldNotify) {

        if (shouldNotify) {

            // Check whether delegate can handle presence event arrival or not
            if ([self.clientDelegate respondsToSelector:@selector(pubnubClient:didReceivePresenceEvent:)]) {

                dispatch_async(dispatch_get_main_queue(), ^{

                    [self.clientDelegate performSelector:@selector(pubnubClient:didReceivePresenceEvent:) withObject:self
                                              withObject:event];
                });
            }

            [self sendNotification:kPNClientDidReceivePresenceEventNotification withObject:event];
        }
    }];
}

#pragma mark -


@end
