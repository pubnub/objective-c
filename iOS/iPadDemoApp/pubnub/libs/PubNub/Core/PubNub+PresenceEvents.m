/**
 
 @author Sergey Mamontov
 @version 3.6.8
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
 Postpone presence observation enabling user request so it will be executed in future.
 
 @note Postpone can be because of few cases: \b PubNub client is in connecting or initial connection state; another request
 which has been issued earlier didn't completed yet.
 
 @param channels
 List of \b PNChannel instances on which client should enable presence events observation.
 
 @param handlerBlock
 Handler block which is called by \b PubNub client when presence enabling process state changes. Block pass two arguments:
 \c channels - List of \b PNChannel instances for which presence enabling process changed state;
 \c error - \b PNError instance which hold information about why presence enabling process failed. Always
 check \a error.code to find out what caused error (check PNErrorCodes header file and use \a -localizedDescription /
 \a -localizedFailureReason and \a -localizedRecoverySuggestion to get human readable description for error).
 */
- (void)postponeEnablePresenceObservationForChannels:(NSArray *)channels withCompletionHandlingBlock:(id)handlerBlock;

/**
 Postpone presence observation disabling user request so it will be executed in future.
 
 @note Postpone can be because of few cases: \b PubNub client is in connecting or initial connection state; another request
 which has been issued earlier didn't completed yet.
 
 @param channels
 List of \b PNChannel instances on which client should disable presence events observation.
 
 @param handlerBlock
 Handler block which is called by \b PubNub client when presence disabling process state changes. Block pass two arguments:
 \c channels - List of \b PNChannel instances for which presence disabling process changed state;
 \c error - \b PNError instance which hold information about why presence disabling process failed. Always
 check \a error.code to find out what caused error (check PNErrorCodes header file and use \a -localizedDescription /
 \a -localizedFailureReason and \a -localizedRecoverySuggestion to get human readable description for error).
 */
- (void)postponeDisablePresenceObservationForChannels:(NSArray *)channels withCompletionHandlingBlock:(id)handlerBlock;


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

+ (void)enablePresenceObservationForChannel:(PNChannel *)channel {
    
    [self enablePresenceObservationForChannel:channel withCompletionHandlingBlock:nil];
}

+ (void)enablePresenceObservationForChannel:(PNChannel *)channel
                withCompletionHandlingBlock:(PNClientPresenceEnableHandlingBlock)handlerBlock {
    
    [self enablePresenceObservationForChannels:@[channel] withCompletionHandlingBlock:handlerBlock];
}

+ (void)enablePresenceObservationForChannels:(NSArray *)channels {
    
    [self enablePresenceObservationForChannels:channels withCompletionHandlingBlock:nil];
}

+ (void)enablePresenceObservationForChannels:(NSArray *)channels
                 withCompletionHandlingBlock:(PNClientPresenceEnableHandlingBlock)handlerBlock {
    
    [[self sharedInstance] enablePresenceObservationForChannels:channels withCompletionHandlingBlock:handlerBlock];
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
    
    [[self sharedInstance] disablePresenceObservationForChannels:channels withCompletionHandlingBlock:handlerBlock];
}


#pragma mark - Instance methods

- (BOOL)isPresenceObservationEnabledForChannel:(PNChannel *)channel {
    
    BOOL observingPresence = NO;
    
    // Ensure that PubNub client currently connected to
    // remote PubNub services
    if ([self isConnected]) {
        
        observingPresence = [self.messagingChannel isPresenceObservationEnabledForChannel:channel];
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

    [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray *{

        return @[PNLoggerSymbols.api.presenceObservationEnableAttempt, (channels ? channels : [NSNull null]),
                 [self humanReadableStateFrom:self.state]];
    }];

    [self performAsyncLockingBlock:^{
        
        [self pn_dispatchAsynchronouslyBlock:^{
            
            [self.observationCenter removeClientAsPresenceEnabling];
            [self.observationCenter removeClientAsPresenceDisabling];
            
            // Check whether client is able to send request or not
            NSInteger statusCode = [self requestExecutionPossibilityStatusCode];
            if (statusCode == 0) {
                
                [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray *{
                    
                    return @[PNLoggerSymbols.api.enablingPresenceObservation, [self humanReadableStateFrom:self.state]];
                }];
                
                if (handlerBlock != nil) {
                    
                    [self.observationCenter addClientAsPresenceEnablingObserverWithBlock:handlerBlock];
                }
                
                // Enumerate over the list of channels and mark that it should observe for presence
                [channels enumerateObjectsUsingBlock:^(PNChannel *channel, NSUInteger channelIdx, BOOL *channelEnumeratorStop) {
                    
                    channel.observePresence = YES;
                    channel.linkedWithPresenceObservationChannel = NO;
                }];
                
                [self.messagingChannel enablePresenceObservationForChannels:channels];
            }
            else {
                
                [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray *{
                    
                    return @[PNLoggerSymbols.api.presenceObservationEnableImpossible, [self humanReadableStateFrom:self.state]];
                }];
                
                PNError *presenceEnableError = [PNError errorWithCode:statusCode];
                presenceEnableError.associatedObject = channels;
                
                
                [self notifyDelegateAboutPresenceEnablingFailWithError:presenceEnableError completeLockingOperation:YES];
                
                if (handlerBlock != nil) {
                    
                    handlerBlock(channels, presenceEnableError);
                }
            }
        }];

    }
           postponedExecutionBlock:^{

               [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray *{

                   return @[PNLoggerSymbols.api.postponePresenceObservationEnable, [self humanReadableStateFrom:self.state]];
               }];

               [self postponeEnablePresenceObservationForChannels:channels withCompletionHandlingBlock:handlerBlock];
           }];
}

- (void)postponeEnablePresenceObservationForChannels:(NSArray *)channels withCompletionHandlingBlock:(id)handlerBlock {
    
    id handlerBlockCopy = (handlerBlock ? [handlerBlock copy] : nil);
    [self postponeSelector:@selector(enablePresenceObservationForChannels:withCompletionHandlingBlock:) forObject:self
            withParameters:@[[PNHelper nilifyIfNotSet:channels], [PNHelper nilifyIfNotSet:handlerBlockCopy]] outOfOrder:NO];
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
    
    [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray *{
        
        return @[PNLoggerSymbols.api.presenceObservationDisableAttempt, (channels ? channels : [NSNull null]),
                 [self humanReadableStateFrom:self.state]];
    }];
    
    [self performAsyncLockingBlock:^{
        
        [self pn_dispatchAsynchronouslyBlock:^{
        
            [self.observationCenter removeClientAsPresenceEnabling];
            [self.observationCenter removeClientAsPresenceDisabling];
            
            // Check whether client is able to send request or not
            NSInteger statusCode = [self requestExecutionPossibilityStatusCode];
            if (statusCode == 0) {
                
                [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray *{
                    
                    return @[PNLoggerSymbols.api.disablingPresenceObservation, [self humanReadableStateFrom:self.state]];
                }];
                
                if (handlerBlock != nil) {
                    
                    [self.observationCenter addClientAsPresenceDisablingObserverWithBlock:handlerBlock];
                }
                
                [self.messagingChannel disablePresenceObservationForChannels:channels];
            }
            else {
                
                [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray *{
                    
                    return @[PNLoggerSymbols.api.presenceObservationDisableImpossible,
                             [self humanReadableStateFrom:self.state]];
                }];
                
                PNError *presencedisableError = [PNError errorWithCode:statusCode];
                presencedisableError.associatedObject = channels;
                
                
                [self notifyDelegateAboutPresenceDisablingFailWithError:presencedisableError
                                               completeLockingOperation:YES];
                
                if (handlerBlock != nil) {
                    
                    handlerBlock(channels, presencedisableError);
                }
            }
        }];
    }
           postponedExecutionBlock:^{
               
               [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray *{
                   
                   return @[PNLoggerSymbols.api.postponePresenceObservationDisable,
                            [self humanReadableStateFrom:self.state]];
               }];

               [self postponeDisablePresenceObservationForChannels:channels withCompletionHandlingBlock:handlerBlock];
           }];
}

- (void)postponeDisablePresenceObservationForChannels:(NSArray *)channels
                          withCompletionHandlingBlock:(PNClientPresenceDisableHandlingBlock)handlerBlock {
    
    id handlerBlockCopy = (handlerBlock ? [handlerBlock copy] : nil);
    [self postponeSelector:@selector(disablePresenceObservationForChannels:withCompletionHandlingBlock:) forObject:self
            withParameters:@[[PNHelper nilifyIfNotSet:channels], [PNHelper nilifyIfNotSet:handlerBlockCopy]] outOfOrder:NO];
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
    
    [self pn_dispatchAsynchronouslyBlock:^{
        
        if ([self isConnected]) {
            
            self.asyncLockingOperationInProgress = YES;
        }
    }];
}

- (void)messagingChannel:(PNMessagingChannel *)messagingChannel didEnablePresenceObservationOn:(NSArray *)channelObjects
               sequenced:(BOOL)isSequenced {
    
    void(^handlerBlock)(void) = ^{
        
        [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray *{
            
            return @[PNLoggerSymbols.api.enabledPresenceObservation, (channelObjects ? channelObjects : [NSNull null]),
                     [self humanReadableStateFrom:self.state]];
        }];
        
        if ([self shouldChannelNotifyAboutEvent:messagingChannel]) {
            
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
    
    if (!isSequenced) {
        
        [self handleLockingOperationBlockCompletion:handlerBlock shouldStartNext:YES];
    }
    else {
        
        handlerBlock();
    }
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
    
    [self pn_dispatchAsynchronouslyBlock:^{
    
        if ([self isConnected]) {
            
            self.asyncLockingOperationInProgress = YES;
        }
    }];
}

- (void)messagingChannel:(PNMessagingChannel *)messagingChannel didDisablePresenceObservationOn:(NSArray *)channelObjects
               sequenced:(BOOL)isSequenced {
    
    void(^handlerBlock)(void) = ^{
        
        [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray *{
            
            return @[PNLoggerSymbols.api.disabledPresenceObservation, (channelObjects ? channelObjects : [NSNull null]),
                     [self humanReadableStateFrom:self.state]];
        }];
        
        if ([self shouldChannelNotifyAboutEvent:messagingChannel]) {
            
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
    
    if (!isSequenced) {
        
        [self handleLockingOperationBlockCompletion:handlerBlock shouldStartNext:YES];
    }
    else {
        
        handlerBlock();
    }
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
    
    if ([self shouldChannelNotifyAboutEvent:messagingChannel]) {
        
        // Check whether delegate can handle presence event arrival or not
        if ([self.clientDelegate respondsToSelector:@selector(pubnubClient:didReceivePresenceEvent:)]) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
            
                [self.clientDelegate performSelector:@selector(pubnubClient:didReceivePresenceEvent:) withObject:self
                                          withObject:event];
            });
        }
        
        [self sendNotification:kPNClientDidReceivePresenceEventNotification withObject:event];
    }
}

#pragma mark -


@end
