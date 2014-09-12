/**
 
 @author Sergey Mamontov
 @version 3.6.8
 @copyright © 2009-14 PubNub Inc.
 
 */

#import "PubNub+Presence.h"
#import "NSObject+PNAdditions.h"
#import "PNWhereNowRequest.h"
#import "PNHereNowRequest.h"
#import "PNServiceChannel.h"
#import "PubNub+Protected.h"
#import "PNNotifications.h"
#import "PNHelper.h"

#import "PNLogger+Protected.h"
#import "PNLoggerSymbols.h"


#pragma mark - Category private interface declaration

@interface PubNub (PresencePrivate)


#pragma mark - Instance methods

/**
 Final designated method which allow to channels participant information depending on provided set of parameters.

 @param channel
 \b PNChannel instance on for which \b PubNub client should retrieve information about participants.

 @param isClientIdentifiersRequired
 Whether or not \b PubNub client should fetch list of client identifiers or only number of them will be returned by
 server.

 @param shouldFetchClientState
 Whether or not \b PubNub client should fetch additional information which has been added to the client during
 subscription or specific API endpoints.

 @param shouldFetchClientState
 Whether or not \b PubNub client should fetch additional information which has been added to the client during
 subscription or specific API endpoints.

 @param handleBlock
 The block which will be called by \b PubNub client as soon as participants list request operation will be completed.
 The block takes three arguments:
 \c clients - array of \b PNClient instances which represent client which is subscribed on target channel (if
 \a 'isClientIdentifiersRequired' is set to \c NO than all objects will have \c kPNAnonymousParticipantIdentifier value);
 \c channel - is \b PNChannel instance for which \b PubNub client received participants list; \c error - describes what
 exactly went wrong (check error code and compare it with \b PNErrorCodes ).

 @note If \a 'isClientIdentifiersRequired' is set to \c NO then value of \a 'shouldFetchClientState' will be
 ignored and returned result array will contain list of \b PNClient instances with names set to \a 'unknown'.

 @since 3.6.0
 */
- (void)requestParticipantsListForChannel:(PNChannel *)channel clientIdentifiersRequired:(BOOL)isClientIdentifiersRequired
                              clientState:(BOOL)shouldFetchClientState reschedulingMethodCall:(BOOL)isMethodCallRescheduled
                      withCompletionBlock:(PNClientParticipantsHandlingBlock)handleBlock;

/**
 Postpone participants list user request so it will be executed in future.

 @note Postpone can be because of few cases: \b PubNub client is in connecting or initial connection state; another request
 which has been issued earlier didn't completed yet.

 @param channel
 \b PNChannel instance on for which \b PubNub client should retrieve information about participants.

 @param isClientIdentifiersRequired
 Whether or not \b PubNub client should fetch list of client identifiers or only number of them will be returned by
 server.

 @param shouldFetchClientState
 Whether or not \b PubNub client should fetch additional information which has been added to the client during
 subscription or specific API endpoints.

 @param isMethodCallRescheduled
 In case if value set to \c YES it will mean that method call has been rescheduled and probably there is no handler
 block which client should use for observation notification.

 @param handleBlock
 The block which will be called by \b PubNub client as soon as participants list request operation will be completed.
 The block takes three arguments:
 \c clients - array of \b PNClient instances which represent client which is subscribed on target channel (if
 \a 'isClientIdentifiersRequired' is set to \c NO than all objects will have \c kPNAnonymousParticipantIdentifier value);
 \c channel - is \b PNChannel instance for which \b PubNub client received participants list; \c error - describes what
 exactly went wrong (check error code and compare it with \b PNErrorCodes ).
 */
- (void)postponeRequestParticipantsListForChannel:(PNChannel *)channel clientIdentifiersLRequired:(BOOL)isClientIdentifiersRequired
                                      clientState:(BOOL)shouldFetchClientState reschedulingMethodCall:(BOOL)isMethodCallRescheduled
                              withCompletionBlock:(id)handleBlock;

/**
 Final designated method which allow to participant channels information depending on provided set of parameters.

 @param clientIdentifier
 Client identifier for which \b PubNub client should get list of channels in which it reside.

 @param isMethodCallRescheduled
 In case if value set to \c YES it will mean that method call has been rescheduled and probably there is no handler
 block which client should use for observation notification.

 @param handleBlock
 The block which will be called by \b PubNub client as soon as participant channels list request operation will be
 completed. The block takes three arguments:
 \c clientIdentifier - identifier for which \b PubNub client search for channels;
 \c channels - is list of \b PNChannel instances in which \c clientIdentifier has been found as subscriber; \c error -
 describes what exactly went wrong (check error code and compare it with \b PNErrorCodes ).

 @since 3.6.0
 */
- (void)requestParticipantChannelsList:(NSString *)clientIdentifier reschedulingMethodCall:(BOOL)isMethodCallRescheduled
                   withCompletionBlock:(PNClientParticipantChannelsHandlingBlock)handleBlock;

/**
 Postpone participant channels list user request so it will be executed in future.

 @note Postpone can be because of few cases: \b PubNub client is in connecting or initial connection state; another request
 which has been issued earlier didn't completed yet.

 @param clientIdentifier
 Client identifier for which \b PubNub client should get list of channels in which it reside.

 @param isMethodCallRescheduled
 In case if value set to \c YES it will mean that method call has been rescheduled and probably there is no handler
 block which client should use for observation notification.

 @param handleBlock
 The block which will be called by \b PubNub client as soon as participant channels list request operation will be
 completed. The block takes three arguments:
 \c clientIdentifier - identifier for which \b PubNub client search for channels;
 \c channels - is list of \b PNChannel instances in which \c clientIdentifier has been found as subscriber; \c error -
 describes what exactly went wrong (check error code and compare it with \b PNErrorCodes ).
 */
- (void)postponeRequestParticipantChannelsList:(NSString *)clientIdentifier reschedulingMethodCall:(BOOL)isMethodCallRescheduled
                           withCompletionBlock:(id)handleBlock;


#pragma mark - Misc methods

/**
 * This method will notify delegate about that participants list download error occurred
 */
- (void)notifyDelegateAboutParticipantsListDownloadFailedWithError:(PNError *)error;

/**
 * This method will notify delegate about that participant channels list download error occurred.
 */
- (void)notifyDelegateAboutParticipantChannelsListDownloadFailedWithError:(PNError *)error;

#pragma mark -


@end


#pragma mark - Category methods implementation

@implementation PubNub (Presence)


#pragma mark - Class (singleton) methods

+ (void)requestParticipantsList {
    
    [self requestParticipantsListWithCompletionBlock:nil];
}

+ (void)requestParticipantsListWithCompletionBlock:(PNClientParticipantsHandlingBlock)handleBlock {
    
    [self requestParticipantsListWithClientIdentifiers:YES andCompletionBlock:handleBlock];
}

+ (void)requestParticipantsListWithClientIdentifiers:(BOOL)isClientIdentifiersRequired {
    
    [self requestParticipantsListWithClientIdentifiers:isClientIdentifiersRequired andCompletionBlock:nil];
}

+ (void)requestParticipantsListWithClientIdentifiers:(BOOL)isClientIdentifiersRequired
                                  andCompletionBlock:(PNClientParticipantsHandlingBlock)handleBlock {
    
    [self requestParticipantsListWithClientIdentifiers:isClientIdentifiersRequired clientState:NO
                                    andCompletionBlock:handleBlock];
}

+ (void)requestParticipantsListWithClientIdentifiers:(BOOL)isClientIdentifiersRequired
                                         clientState:(BOOL)shouldFetchClientState {
    
    [self requestParticipantsListWithClientIdentifiers:isClientIdentifiersRequired clientState:shouldFetchClientState
                                    andCompletionBlock:nil];
}

+ (void)requestParticipantsListWithClientIdentifiers:(BOOL)isClientIdentifiersRequired
                                         clientState:(BOOL)shouldFetchClientState
                                  andCompletionBlock:(PNClientParticipantsHandlingBlock)handleBlock {
    
    [self requestParticipantsListForChannel:nil clientIdentifiersRequired:isClientIdentifiersRequired
                                clientState:shouldFetchClientState withCompletionBlock:handleBlock];
}

+ (void)requestParticipantsListForChannel:(PNChannel *)channel {
    
    [self requestParticipantsListForChannel:channel withCompletionBlock:nil];
}

+ (void)requestParticipantsListForChannel:(PNChannel *)channel withCompletionBlock:(PNClientParticipantsHandlingBlock)handleBlock {
    
    [self requestParticipantsListForChannel:channel clientIdentifiersRequired:YES withCompletionBlock:handleBlock];
}

+ (void)requestParticipantsListForChannel:(PNChannel *)channel
                clientIdentifiersRequired:(BOOL)isClientIdentifiersRequired {
    
    [self requestParticipantsListForChannel:channel clientIdentifiersRequired:isClientIdentifiersRequired
                        withCompletionBlock:nil];
}

+ (void)requestParticipantsListForChannel:(PNChannel *)channel
                clientIdentifiersRequired:(BOOL)isClientIdentifiersRequired
                      withCompletionBlock:(PNClientParticipantsHandlingBlock)handleBlock {
    
    [self requestParticipantsListForChannel:channel clientIdentifiersRequired:isClientIdentifiersRequired
                                clientState:NO withCompletionBlock:handleBlock];
}

+ (void)requestParticipantsListForChannel:(PNChannel *)channel clientIdentifiersRequired:(BOOL)isClientIdentifiersRequired
                              clientState:(BOOL)shouldFetchClientState {
    
    [self requestParticipantsListForChannel:channel clientIdentifiersRequired:isClientIdentifiersRequired
                                clientState:shouldFetchClientState withCompletionBlock:nil];
}

+ (void)requestParticipantsListForChannel:(PNChannel *)channel clientIdentifiersRequired:(BOOL)isClientIdentifiersRequired
                              clientState:(BOOL)shouldFetchClientState
                      withCompletionBlock:(PNClientParticipantsHandlingBlock)handleBlock {
    
    [[self sharedInstance] requestParticipantsListForChannel:channel clientIdentifiersRequired:isClientIdentifiersRequired
                                                 clientState:shouldFetchClientState withCompletionBlock:handleBlock];
}

+ (void)requestParticipantChannelsList:(NSString *)clientIdentifier {
    
    [self requestParticipantChannelsList:clientIdentifier withCompletionBlock:nil];
}

+ (void)requestParticipantChannelsList:(NSString *)clientIdentifier
                   withCompletionBlock:(PNClientParticipantChannelsHandlingBlock)handleBlock {
    
    [[self sharedInstance] requestParticipantChannelsList:clientIdentifier withCompletionBlock:handleBlock];
}


#pragma mark - Instance methods

- (void)requestParticipantsList {
    
    [self requestParticipantsListWithCompletionBlock:nil];
}

- (void)requestParticipantsListWithCompletionBlock:(PNClientParticipantsHandlingBlock)handleBlock {
    
    [self requestParticipantsListWithClientIdentifiers:YES andCompletionBlock:handleBlock];
}

- (void)requestParticipantsListWithClientIdentifiers:(BOOL)isClientIdentifiersRequired {
    
    [self requestParticipantsListWithClientIdentifiers:isClientIdentifiersRequired andCompletionBlock:nil];
}

- (void)requestParticipantsListWithClientIdentifiers:(BOOL)isClientIdentifiersRequired
                                  andCompletionBlock:(PNClientParticipantsHandlingBlock)handleBlock {
    
    [self requestParticipantsListWithClientIdentifiers:isClientIdentifiersRequired clientState:NO
                                    andCompletionBlock:handleBlock];
}

- (void)requestParticipantsListWithClientIdentifiers:(BOOL)isClientIdentifiersRequired
                                         clientState:(BOOL)shouldFetchClientState {
    
    [self requestParticipantsListWithClientIdentifiers:isClientIdentifiersRequired clientState:shouldFetchClientState
                                    andCompletionBlock:nil];
}

- (void)requestParticipantsListWithClientIdentifiers:(BOOL)isClientIdentifiersRequired
                                         clientState:(BOOL)shouldFetchClientState
                                  andCompletionBlock:(PNClientParticipantsHandlingBlock)handleBlock {
    
    [self requestParticipantsListForChannel:nil clientIdentifiersRequired:isClientIdentifiersRequired
                                clientState:shouldFetchClientState withCompletionBlock:handleBlock];
}

- (void)requestParticipantsListForChannel:(PNChannel *)channel {
    
    [self requestParticipantsListForChannel:channel withCompletionBlock:nil];
}

- (void)requestParticipantsListForChannel:(PNChannel *)channel withCompletionBlock:(PNClientParticipantsHandlingBlock)handleBlock {
    
    [self requestParticipantsListForChannel:channel clientIdentifiersRequired:YES withCompletionBlock:handleBlock];
}

- (void)requestParticipantsListForChannel:(PNChannel *)channel
                clientIdentifiersRequired:(BOOL)isClientIdentifiersRequired {
    
    [self requestParticipantsListForChannel:channel clientIdentifiersRequired:isClientIdentifiersRequired
                        withCompletionBlock:nil];
}

- (void)requestParticipantsListForChannel:(PNChannel *)channel
                clientIdentifiersRequired:(BOOL)isClientIdentifiersRequired
                      withCompletionBlock:(PNClientParticipantsHandlingBlock)handleBlock {
    
    [self requestParticipantsListForChannel:channel clientIdentifiersRequired:isClientIdentifiersRequired
                                clientState:NO withCompletionBlock:handleBlock];
}

- (void)requestParticipantsListForChannel:(PNChannel *)channel clientIdentifiersRequired:(BOOL)isClientIdentifiersRequired
                              clientState:(BOOL)shouldFetchClientState {
    
    [self requestParticipantsListForChannel:channel clientIdentifiersRequired:isClientIdentifiersRequired
                                clientState:shouldFetchClientState withCompletionBlock:nil];
}

- (void)requestParticipantsListForChannel:(PNChannel *)channel clientIdentifiersRequired:(BOOL)isClientIdentifiersRequired
                              clientState:(BOOL)shouldFetchClientState withCompletionBlock:(PNClientParticipantsHandlingBlock)handleBlock {

    [self requestParticipantsListForChannel:channel clientIdentifiersRequired:isClientIdentifiersRequired
                                clientState:shouldFetchClientState reschedulingMethodCall:NO withCompletionBlock:handleBlock];
}

- (void)requestParticipantsListForChannel:(PNChannel *)channel clientIdentifiersRequired:(BOOL)isClientIdentifiersRequired
                              clientState:(BOOL)shouldFetchClientState reschedulingMethodCall:(BOOL)isMethodCallRescheduled
                      withCompletionBlock:(PNClientParticipantsHandlingBlock)handleBlock {

    [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray *{

        return @[PNLoggerSymbols.api.participantsListRequestAttempt, (channel ? channel : [NSNull null]),
                 @(isClientIdentifiersRequired), [self humanReadableStateFrom:self.state]];
    }];

    [self performAsyncLockingBlock:^{
        
        [self pn_dispatchAsynchronouslyBlock:^{
            
            if (!isMethodCallRescheduled) {
                
                [self.observationCenter removeClientAsParticipantsListDownloadObserver];
            }
            
            // Check whether client is able to send request or not
            NSInteger statusCode = [self requestExecutionPossibilityStatusCode];
            if (statusCode == 0) {
                
                [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray *{
                    
                    return @[PNLoggerSymbols.api.requestingParticipantsList, [self humanReadableStateFrom:self.state]];
                }];
                
                if (handleBlock && !isMethodCallRescheduled) {
                    
                    [self.observationCenter addClientAsParticipantsListDownloadObserverWithBlock:handleBlock];
                }
                
                PNHereNowRequest *request = [PNHereNowRequest whoNowRequestForChannel:channel
                                                            clientIdentifiersRequired:isClientIdentifiersRequired
                                                                          clientState:shouldFetchClientState];
                [self sendRequest:request shouldObserveProcessing:YES];
            }
            // Looks like client can't send request because of some reasons
            else {
                
                [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray *{
                    
                    return @[PNLoggerSymbols.api.participantsListRequestImpossible,
                             [self humanReadableStateFrom:self.state]];
                }];
                
                PNError *sendingError = [PNError errorWithCode:statusCode];
                sendingError.associatedObject = channel;
                
                [self notifyDelegateAboutParticipantsListDownloadFailedWithError:sendingError];
                
                if (handleBlock && !isMethodCallRescheduled) {
                    
                    handleBlock(nil, channel, sendingError);
                }
            }
        }];
    }
           postponedExecutionBlock:^{

               [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray *{

                   return @[PNLoggerSymbols.api.postponeParticipantsListRequest,
                            [self humanReadableStateFrom:self.state]];
               }];

               [self postponeRequestParticipantsListForChannel:channel clientIdentifiersLRequired:isClientIdentifiersRequired
                                                   clientState:shouldFetchClientState reschedulingMethodCall:isMethodCallRescheduled
                                           withCompletionBlock:handleBlock];
           }];
}

- (void)postponeRequestParticipantsListForChannel:(PNChannel *)channel clientIdentifiersLRequired:(BOOL)isClientIdentifiersRequired
                                      clientState:(BOOL)shouldFetchClientState reschedulingMethodCall:(BOOL)isMethodCallRescheduled
                              withCompletionBlock:(id)handleBlock {
    
    SEL targetSelector = @selector(requestParticipantsListForChannel:clientIdentifiersRequired:clientState:reschedulingMethodCall:withCompletionBlock:);
    id handleBlockCopy = (handleBlock ? [handleBlock copy] : nil);
    [self postponeSelector:targetSelector forObject:self
            withParameters:@[[PNHelper nilifyIfNotSet:channel], @(isClientIdentifiersRequired), @(shouldFetchClientState),
                             @(isMethodCallRescheduled), [PNHelper nilifyIfNotSet:handleBlockCopy]]
                outOfOrder:isMethodCallRescheduled];
}

- (void)requestParticipantChannelsList:(NSString *)clientIdentifier {
    
    [self requestParticipantChannelsList:clientIdentifier withCompletionBlock:nil];
}

- (void)requestParticipantChannelsList:(NSString *)clientIdentifier
                   withCompletionBlock:(PNClientParticipantChannelsHandlingBlock)handleBlock {

    [self requestParticipantChannelsList:clientIdentifier reschedulingMethodCall:NO withCompletionBlock:handleBlock];
}

- (void)requestParticipantChannelsList:(NSString *)clientIdentifier reschedulingMethodCall:(BOOL)isMethodCallRescheduled
                   withCompletionBlock:(PNClientParticipantChannelsHandlingBlock)handleBlock {

    [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray *{

        return @[PNLoggerSymbols.api.participantChannelsListRequestAttempt, (clientIdentifier ? clientIdentifier : [NSNull null]),
                 [self humanReadableStateFrom:self.state]];
    }];

    [self performAsyncLockingBlock:^{
        
        [self pn_dispatchAsynchronouslyBlock:^{
            
            if (!isMethodCallRescheduled) {
                
                [self.observationCenter removeClientAsParticipantChannelsListDownloadObserver];
            }

            // Check whether client is able to send request or not
            NSInteger statusCode = [self requestExecutionPossibilityStatusCode];
            if (statusCode == 0) {

                [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray *{

                    return @[PNLoggerSymbols.api.requestingParticipantChannelsList, [self humanReadableStateFrom:self.state]];
                }];

                if (handleBlock && !isMethodCallRescheduled) {

                    [self.observationCenter addClientAsParticipantChannelsListDownloadObserverWithBlock:handleBlock];
                }

                PNWhereNowRequest *request = [PNWhereNowRequest whereNowRequestForIdentifier:clientIdentifier];
                [self sendRequest:request shouldObserveProcessing:YES];
            }
            else {

                [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray *{

                    return @[PNLoggerSymbols.api.participantChannelsListRequestImpossible,
                             [self humanReadableStateFrom:self.state]];
                }];

                PNError *sendingError = [PNError errorWithCode:statusCode];
                sendingError.associatedObject = clientIdentifier;

                [self notifyDelegateAboutParticipantChannelsListDownloadFailedWithError:sendingError];

                if (handleBlock && !isMethodCallRescheduled) {

                    handleBlock(clientIdentifier, nil, sendingError);
                }
            }
        }];
    }
           postponedExecutionBlock:^{

               [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray *{

                   return @[PNLoggerSymbols.api.postponeParticipantChannelsListRequest,
                            [self humanReadableStateFrom:self.state]];
               }];

               [self postponeRequestParticipantChannelsList:clientIdentifier reschedulingMethodCall:isMethodCallRescheduled
                                        withCompletionBlock:handleBlock];
           }];
}

- (void)postponeRequestParticipantChannelsList:(NSString *)clientIdentifier reschedulingMethodCall:(BOOL)isMethodCallRescheduled
                           withCompletionBlock:(id)handleBlock {
    
    SEL targetSelector = @selector(requestParticipantChannelsList:reschedulingMethodCall:withCompletionBlock:);
    id handleBlockCopy = (handleBlock ? [handleBlock copy] : nil);
    [self postponeSelector:targetSelector forObject:self
            withParameters:@[[PNHelper nilifyIfNotSet:clientIdentifier], @(isMethodCallRescheduled),
                            [PNHelper nilifyIfNotSet:handleBlockCopy]]
                outOfOrder:isMethodCallRescheduled];
}


#pragma mark - Misc methods

- (void)notifyDelegateAboutParticipantsListDownloadFailedWithError:(PNError *)error {
    
    [self handleLockingOperationBlockCompletion:^{
        
        [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray *{
            
            return @[PNLoggerSymbols.api.participantsListDownloadFailed, [self humanReadableStateFrom:self.state]];
        }];
        
        // Check whether delegate us able to handle participants list download error or not
        if ([self.clientDelegate respondsToSelector:@selector(pubnubClient:didFailParticipantsListDownloadForChannel:withError:)]) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
            
                [self.clientDelegate pubnubClient:self didFailParticipantsListDownloadForChannel:error.associatedObject
                                        withError:error];
            });
        }
        
        [self sendNotification:kPNClientParticipantsListDownloadFailedWithErrorNotification withObject:error];
    }
                                shouldStartNext:YES];
}

- (void)notifyDelegateAboutParticipantChannelsListDownloadFailedWithError:(PNError *)error {
    
    [self handleLockingOperationBlockCompletion:^{
        
        [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray *{
            
            return @[PNLoggerSymbols.api.participantChannelsListDownloadFailed, [self humanReadableStateFrom:self.state]];
        }];
        
        // Check whether delegate us able to handle participants list download error or not
        if ([self.clientDelegate respondsToSelector:@selector(pubnubClient:didFailParticipantChannelsListDownloadForIdentifier:withError:)]) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
            
                [self.clientDelegate pubnubClient:self didFailParticipantChannelsListDownloadForIdentifier:error.associatedObject
                                        withError:error];
            });
        }
        
        [self sendNotification:kPNClientParticipantChannelsListDownloadFailedWithErrorNotification withObject:error];
    }
                                shouldStartNext:YES];
}


#pragma mark - Service channel delegate methods

- (void)serviceChannel:(PNServiceChannel *)serviceChannel didReceiveParticipantsList:(PNHereNow *)participants {
    
    [self handleLockingOperationBlockCompletion:^{
        
        [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray *{
            
            return @[PNLoggerSymbols.api.didReceiveParticipantsList, [self humanReadableStateFrom:self.state]];
        }];
        
        if ([self shouldChannelNotifyAboutEvent:serviceChannel]) {
            
            // Check whether delegate can response on participants list download event or not
            if ([self.clientDelegate respondsToSelector:@selector(pubnubClient:didReceiveParticipantsList:forChannel:)]) {
                
                dispatch_async(dispatch_get_main_queue(), ^{
                
                    [self.clientDelegate pubnubClient:self didReceiveParticipantsList:participants.participants
                                           forChannel:participants.channel];
                });
            }
            
            [self sendNotification:kPNClientDidReceiveParticipantsListNotification withObject:participants];
        }
    }
                                shouldStartNext:YES];
}

- (void)serviceChannel:(PNServiceChannel *)serviceChannel didFailParticipantsListLoadForChannel:(PNChannel *)channel
             withError:(PNError *)error {
    
    if (error.code != kPNRequestCantBeProcessedWithOutRescheduleError) {
        
        error.associatedObject = channel;
        [self notifyDelegateAboutParticipantsListDownloadFailedWithError:error];
    }
    else {
        
        [self rescheduleMethodCall:^{
            
            [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray *{
                
                return @[PNLoggerSymbols.api.rescheduleParticipantsListRequest, [self humanReadableStateFrom:self.state]];
            }];
            
            NSDictionary *options = (NSDictionary *)error.associatedObject;
            [self requestParticipantsListForChannel:channel clientIdentifiersRequired:[[options valueForKey:@"clientIdentifiersRequired"] boolValue]
                                        clientState:[[options valueForKey:@"fetchClientState"] boolValue]
                             reschedulingMethodCall:YES withCompletionBlock:nil];
        }];
    }
    
}

- (void)serviceChannel:(PNServiceChannel *)serviceChannel didReceiveParticipantChannelsList:(PNWhereNow *)participantChannels {
    
    [self handleLockingOperationBlockCompletion:^{
        
        [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray *{
            
            return @[PNLoggerSymbols.api.didReceiveParticipantChannelsList, [self humanReadableStateFrom:self.state]];
        }];
        
        if ([self shouldChannelNotifyAboutEvent:serviceChannel]) {
            
            // Check whether delegate can response on participant channels list download event or not
            if ([self.clientDelegate respondsToSelector:@selector(pubnubClient:didReceiveParticipantChannelsList:forIdentifier:)]) {
                
                dispatch_async(dispatch_get_main_queue(), ^{
                
                    [self.clientDelegate pubnubClient:self didReceiveParticipantChannelsList:participantChannels.channels
                                        forIdentifier:participantChannels.identifier];
                });
            }
            
            [self sendNotification:kPNClientDidReceiveParticipantChannelsListNotification withObject:participantChannels];
        }
    }
                                shouldStartNext:YES];
}

- (void)serviceChannel:(PNServiceChannel *)serviceChannel didFailParticipantChannelsListLoadForIdentifier:(NSString *)clientIdentifier
             withError:(PNError *)error {
    
    if (error.code != kPNRequestCantBeProcessedWithOutRescheduleError) {
        
        error.associatedObject = clientIdentifier;
        [self notifyDelegateAboutParticipantChannelsListDownloadFailedWithError:error];
    }
    else {
        
        [self rescheduleMethodCall:^{
            
            [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray *{
                
                return @[PNLoggerSymbols.api.rescheduleParticipantChannelsListRequest, [self humanReadableStateFrom:self.state]];
            }];
            
            [self requestParticipantChannelsList:clientIdentifier reschedulingMethodCall:YES withCompletionBlock:nil];
        }];
    }
}

#pragma mark -


@end
