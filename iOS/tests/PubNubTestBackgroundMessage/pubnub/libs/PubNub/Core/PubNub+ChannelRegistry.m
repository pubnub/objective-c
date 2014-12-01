/**
 
 @author Sergey Mamontov
 @version 3.7.0
 @copyright © 2009-14 PubNub Inc.
 
 */

#import "PubNub+ChannelRegistry.h"
#import "PNChannelsListUpdateForChannelGroupRequest.h"
#import "PNChannelGroupNamespaceRemoveRequest.h"
#import "PNChannelGroupNamespacesRequest.h"
#import "PNChannelGroupChange+Protected.h"
#import "PNChannelGroupRemoveRequest.h"
#import "PNChannelsForGroupRequest.h"
#import "PNChannelGroup+Protected.h"
#import "PNChannelGroupsRequest.h"
#import "NSObject+PNAdditions.h"
#import "PNServiceChannel.h"
#import "PubNub+Protected.h"
#import "PNNotifications.h"
#import "PNHelper.h"

#import "PNLogger+Protected.h"
#import "PNLoggerSymbols.h"


#pragma mark - Category private interface declaration

@interface PubNub (PrivateChannelRegistry)


#pragma mark - Instance methods

#pragma mark - Channel groups request

/**
 Retrieve list of channel groups which has been registered for all application users (identifier by subscription key).
 
 @param nspace
 Namespace name from which channel groups should be retrieved.
 
 @param isMethodCallRescheduled
 In case if value set to \c YES it will mean that method call has been rescheduled and probably there is no handler
 block which client should use for observation notification.
 
 @param handlerBlock
 The block which will be called by \b PubNub client as soon as channel groups request operation will be completed.
 The block takes three arguments:
 \c namespace - namespace from which channel groups requested; \c groups - list of \b PNChannelGroup describing channel group
 inside of namespace; \c error - describes what exactly went wrong (check error code and compare it with \b PNErrorCodes ).
 
 @since 3.7.0
 */
- (void)requestChannelGroupsForNamespace:(NSString *)nspace reschedulingMethodCall:(BOOL)isMethodCallRescheduled
             withCompletionHandlingBlock:(PNClientChannelGroupsRequestHandlingBlock)handlerBlock;

/**
 Postpone channel groups list request so it will be executed in future.
 
 @note Postpone can be because of few cases: \b PubNub client is in connecting or initial connection state; another request
 which has been issued earlier didn't completed yet.
 
 @param nspace
 Namespace name from which channel groups should be retrieved.
 
 @param isMethodCallRescheduled
 In case if value set to \c YES it will mean that method call has been rescheduled and probably there is no handler
 block which client should use for observation notification.
 
 @param handlerBlock
 The block which will be called by \b PubNub client as soon as channel groups request operation will be completed.
 The block takes three arguments:
 \c namespace - namespace from which channel groups requested; \c groups - list of \b PNChannelGroup describing channel group
 inside of namespace; \c error - describes what exactly went wrong (check error code and compare it with \b PNErrorCodes ).
 */
- (void)postponeRequestChannelGroupsForNamespace:(NSString *)nspace reschedulingMethodCall:(BOOL)isMethodCallRescheduled
                     withCompletionHandlingBlock:(PNClientChannelGroupsRequestHandlingBlock)handlerBlock;


#pragma mark - Namespace / group panimulation

/**
 Retrieve list of all namespaces which has been created under application subscribe key.
 
 @param isMethodCallRescheduled
 In case if value set to \c YES it will mean that method call has been rescheduled and probably there is no handler
 block which client should use for observation notification.
 
 @param handlerBlock
 The block which will be called by \b PubNub client as soon as namespace list pulled for channel group (all available namespaces
 under which channel group can be registered). The block takes two arguments:
 \c namespaces - list of namespaces which has been created to store registered channel groups; \c error - describes what
 exactly went wrong (check error code and compare it with \b PNErrorCodes ).
 
 @since 3.7.0
 */
- (void)requestChannelGroupNamespacesWithReschedulingMethodCall:(BOOL)isMethodCallRescheduled
                                     andCompletionHandlingBlock:(PNClientChannelGroupNamespacesRequestHandlingBlock)handlerBlock;

/**
 Postpone channel group namespaces list request so it will be executed in future.
 
 @note Postpone can be because of few cases: \b PubNub client is in connecting or initial connection state; another request
 which has been issued earlier didn't completed yet.
 
 @param isMethodCallRescheduled
 In case if value set to \c YES it will mean that method call has been rescheduled and probably there is no handler
 block which client should use for observation notification.
 
 @param handlerBlock
 The block which will be called by \b PubNub client as soon as namespace list pulled for channel group (all available namespaces
 under which channel group can be registered). The block takes two arguments:
 \c namespaces - list of namespaces which has been created to store registered channel groups; \c error - describes what
 exactly went wrong (check error code and compare it with \b PNErrorCodes ).
 
 @since 3.7.0
 */
- (void)postponeChannelGroupNamespacesRequestWithReschedulingMethodCall:(BOOL)isMethodCallRescheduled
                                             andCompletionHandlingBlock:(PNClientChannelGroupNamespacesRequestHandlingBlock)handlerBlock;

/**
 Remove one of channel group namespaces from channel registry. All channel groups and channels which has been registered and
 added to target namespace will be deleted as well.
 
 @param nspace
 Reference on namespace name which should be removed along with all channel group and channels registered in it.
 
 @param isMethodCallRescheduled
 In case if value set to \c YES it will mean that method call has been rescheduled and probably there is no handler
 block which client should use for observation notification.
 
 @param handlerBlock
 The block which will be called by \b PubNub client as soon as namespace removal process will be completed. The block takes two arguments:
 \c namespace - namespace name which should be removed; \c error - describes what exactly went wrong (check error code
 and compare it with \b PNErrorCodes ).
 
 @since 3.7.0
 */
- (void)removeChannelGroupNamespace:(NSString *)nspace reschedulingMethodCall:(BOOL)isMethodCallRescheduled
        withCompletionHandlingBlock:(PNClientChannelGroupNamespaceRemoveHandlingBlock)handlerBlock;

/**
 Postpone channel group namespace removal request so it will be executed in future.
 
 @note Postpone can be because of few cases: \b PubNub client is in connecting or initial connection state; another request
 which has been issued earlier didn't completed yet.
 
 @param nspace
 Reference on namespace name which should be removed along with all channel group and channels registered in it.
 
 @param isMethodCallRescheduled
 In case if value set to \c YES it will mean that method call has been rescheduled and probably there is no handler
 block which client should use for observation notification.
 
 @param handlerBlock
 The block which will be called by \b PubNub client as soon as namespace removal process will be completed. The block takes two arguments:
 \c namespace - namespace name which should be removed; \c error - describes what exactly went wrong (check error code
 and compare it with \b PNErrorCodes ).
 
 @since 3.7.0
 */
- (void)postponeRemoveChannelGroupNamespace:(NSString *)nspace reschedulingMethodCall:(BOOL)isMethodCallRescheduled
                withCompletionHandlingBlock:(PNClientChannelGroupNamespaceRemoveHandlingBlock)handlerBlock;

/**
 Remove one of channel groups from channel registry. All channels which has been registered in it also will be removed.
 
 @param group
 \b PNChannelGroup instance which describs channel group which should be deleted by \b PubNub client.
 
 @param isMethodCallRescheduled
 In case if value set to \c YES it will mean that method call has been rescheduled and probably there is no handler
 block which client should use for observation notification.
 
 @param handlerBlock
 The block which will be called by \b PubNub client as soon as channel group removal process will be completed. The block takes two arguments:
 \c PNChannelGroup - \b PNChannelGroup which should be removed; \c error - describes what exactly went wrong (check error code
 and compare it with \b PNErrorCodes ).
 
 @since 3.7.0
 */
- (void)   removeChannelGroup:(PNChannelGroup *)group reschedulingMethodCall:(BOOL)isMethodCallRescheduled
  withCompletionHandlingBlock:(PNClientChannelGroupRemoveHandlingBlock)handlerBlock;

/**
 Postpone channel group removal request so it will be executed in future.
 
 @note Postpone can be because of few cases: \b PubNub client is in connecting or initial connection state; another request
 which has been issued earlier didn't completed yet.
 
 @param group
 \b PNChannelGroup instance which describs channel group which should be deleted by \b PubNub client.
 
 @param isMethodCallRescheduled
 In case if value set to \c YES it will mean that method call has been rescheduled and probably there is no handler
 block which client should use for observation notification.
 
 @param handlerBlock
 The block which will be called by \b PubNub client as soon as channel group removal process will be completed. The block takes two arguments:
 \c PNChannelGroup - \b PNChannelGroup which should be removed; \c error - describes what exactly went wrong (check error code
 and compare it with \b PNErrorCodes ).
 
 @since 3.7.0
 */
- (void)postponeRemoveChannelGroup:(PNChannelGroup *)group reschedulingMethodCall:(BOOL)isMethodCallRescheduled
       withCompletionHandlingBlock:(PNClientChannelGroupRemoveHandlingBlock)handlerBlock;


#pragma mark - Channel group channels request

/**
 Retrieve list of channels for specific channel group which has been added for all application users (identifier by subscription key).
 
 @param group
 Reference on channel group object which hold information about group name and namespace.
 
 @param isMethodCallRescheduled
 In case if value set to \c YES it will mean that method call has been rescheduled and probably there is no handler
 block which client should use for observation notification.
 
 @param handlerBlock
 The block which will be called by \b PubNub client as soon as channels for group request operation will be completed.
 The block takes two arguments:
 \c group - \b PNChannelGroup instance which describe group for which channels should be retrieved (it also has property
 with channels list); \c error - describes what exactly went wrong (check error code and compare it with \b PNErrorCodes ).
 
 @since 3.7.0
 */
- (void)requestChannelsForGroup:(PNChannelGroup *)group reschedulingMethodCall:(BOOL)isMethodCallRescheduled
    withCompletionHandlingBlock:(PNClientChannelsForGroupRequestHandlingBlock)handlerBlock;

/**
 Postpone channels list for group request so it will be executed in future.
 
 @param group
 Reference on channel group object which hold information about group name and namespace.
 
 @param isMethodCallRescheduled
 In case if value set to \c YES it will mean that method call has been rescheduled and probably there is no handler
 block which client should use for observation notification.
 
 @param handlerBlock
 The block which will be called by \b PubNub client as soon as channels for group request operation will be completed.
 The block takes two arguments:
 \c group - \b PNChannelGroup instance which describe group for which channels should be retrieved (it also has property
 with channels list); \c error - describes what exactly went wrong (check error code and compare it with \b PNErrorCodes ).
 
 @since 3.7.0
 */
- (void)postponeRequestChannelsForGroup:(PNChannelGroup *)group reschedulingMethodCall:(BOOL)isMethodCallRescheduled
            withCompletionHandlingBlock:(PNClientChannelsForGroupRequestHandlingBlock)handlerBlock;


#pragma mark - Channel group channels list manipulation

/**
 Add channels list to the group.
 
 @param channels
 Reference on list of \b PNChannel instances which should be added to the group.
 
 @param group
 Reference on channel group object which hold information about group name and namespace.
 
 @param isMethodCallRescheduled
 In case if value set to \c YES it will mean that method call has been rescheduled and probably there is no handler
 block which client should use for observation notification.
 
 @param handlerBlock
 The block which will be called by \b PubNub client as soon as channels addition to group operation will be completed.
 The block takes two arguments:
 \c group - \b PNChannelGroup instance which describe group into which channels should be added; \c channels - list
 of \b PNChannel instance which should be added to the group; \c error - describes what exactly went wrong (check
 error code and compare it with \b PNErrorCodes ).
 
 @since 3.7.0
 */
- (void)          addChannels:(NSArray *)channels toGroup:(PNChannelGroup *)group reschedulingMethodCall:(BOOL)isMethodCallRescheduled
  withCompletionHandlingBlock:(PNClientChannelsAdditionToGroupHandlingBlock)handlerBlock;

/**
 Postpone channels list addition to group so it will be executed in future.
 
 @param channels
 Reference on list of \b PNChannel instances which should be added to the group.
 
 @param group
 Reference on channel group object which hold information about group name and namespace.
 
 @param isMethodCallRescheduled
 In case if value set to \c YES it will mean that method call has been rescheduled and probably there is no handler
 block which client should use for observation notification.
 
 @param handlerBlock
 The block which will be called by \b PubNub client as soon as channels addition to group operation will be completed.
 The block takes two arguments:
 \c group - \b PNChannelGroup instance which describe group into which channels should be added; \c channels - list
 of \b PNChannel instance which should be added to the group; \c error - describes what exactly went wrong (check
 error code and compare it with \b PNErrorCodes ).
 
 @since 3.7.0
 */
- (void)  postponeAddChannels:(NSArray *)channels toGroup:(PNChannelGroup *)group reschedulingMethodCall:(BOOL)isMethodCallRescheduled
  withCompletionHandlingBlock:(PNClientChannelsAdditionToGroupHandlingBlock)handlerBlock;

/**
 Remove channels list from the group.
 
 @param channels
 Reference on list of \b PNChannel instances which should be removed from the group.
 
 @param group
 Reference on channel group object which hold information about group name and namespace.
 
 @param isMethodCallRescheduled
 In case if value set to \c YES it will mean that method call has been rescheduled and probably there is no handler
 block which client should use for observation notification.
 
 @param handlerBlock
 The block which will be called by \b PubNub client as soon as channels removal from group operation will be completed.
 The block takes two arguments:
 \c group - \b PNChannelGroup instance which describe group from which channels should be removed; \c channels - list
 of \b PNChannel instance which should be removed from the group; \c error - describes what exactly went wrong (check
 error code and compare it with \b PNErrorCodes ).
 
 @since 3.7.0
 */
- (void)       removeChannels:(NSArray *)channels fromGroup:(PNChannelGroup *)group reschedulingMethodCall:(BOOL)isMethodCallRescheduled
  withCompletionHandlingBlock:(PNClientChannelsRemovalFromGroupHandlingBlock)handlerBlock;

/**
 Postpone channels list removal from group so it will be executed in future.
 
 @param channels
 Reference on list of \b PNChannel instances which should be removed from the group.
 
 @param group
 Reference on channel group object which hold information about group name and namespace.
 
 @param isMethodCallRescheduled
 In case if value set to \c YES it will mean that method call has been rescheduled and probably there is no handler
 block which client should use for observation notification.
 
 @param handlerBlock
 The block which will be called by \b PubNub client as soon as channels removal from group operation will be completed.
 The block takes two arguments:
 \c group - \b PNChannelGroup instance which describe group from which channels should be removed; \c channels - list
 of \b PNChannel instance which should be removed from the group; \c error - describes what exactly went wrong (check
 error code and compare it with \b PNErrorCodes ).
 
 @since 3.7.0
 */
- (void)postponeRemoveChannels:(NSArray *)channels fromGroup:(PNChannelGroup *)group reschedulingMethodCall:(BOOL)isMethodCallRescheduled
   withCompletionHandlingBlock:(PNClientChannelsRemovalFromGroupHandlingBlock)handlerBlock;


#pragma mark - Misc methods

/**
 This method will notify delegate about that channel groups retrieve request failed
 */
- (void)notifyDelegateAboutChannelGroupsRequestFailedWithError:(PNError *)error;

/**
 This method will notify delegate about that channel group namespaces retrieve request failed
 */
- (void)notifyDelegateAboutChannelGroupNamespacesRequestFailedWithError:(PNError *)error;

/**
 This method will notify delegate about that channel group namespace removal request failed
 */
- (void)notifyDelegateAboutChannelGroupNamespaceRemovalFailedWithError:(PNError *)error;

/**
 This method will notify delegate about that channel group removal request failed
 */
- (void)notifyDelegateAboutChannelGroupRemovalFailedWithError:(PNError *)error;

/**
 This method will notify delegate about that channels list for group retrieve request failed
 */
- (void)notifyDelegateAboutChannelsForGroupRequestFailedWithError:(PNError *)error;

/**
 This method will notify delegate about that channels list change for group failed
 */
- (void)notifyDelegateAboutChannelsListChangeFailedWithError:(PNError *)error;

#pragma mark -


@end


#pragma mark - Category methods implementation

@implementation PubNub (ChannelRegistry)


#pragma mark - Instance methods

#pragma mark - Channel groups request

- (void)requestDefaultChannelGroups {

    [self requestDefaultChannelGroupsWithCompletionHandlingBlock:nil];
}

- (void)requestDefaultChannelGroupsWithCompletionHandlingBlock:(PNClientChannelGroupsRequestHandlingBlock)handlerBlock {
    
    [self requestChannelGroupsForNamespace:nil withCompletionHandlingBlock:handlerBlock];
}

- (void)requestChannelGroupsForNamespace:(NSString *)nspace {
    
    [self requestChannelGroupsForNamespace:nspace withCompletionHandlingBlock:nil];
}

- (void)requestChannelGroupsForNamespace:(NSString *)nspace
             withCompletionHandlingBlock:(PNClientChannelGroupsRequestHandlingBlock)handlerBlock {
    
    [self requestChannelGroupsForNamespace:nspace reschedulingMethodCall:NO withCompletionHandlingBlock:handlerBlock];
}

- (void)requestChannelGroupsForNamespace:(NSString *)nspace reschedulingMethodCall:(BOOL)isMethodCallRescheduled
             withCompletionHandlingBlock:(PNClientChannelGroupsRequestHandlingBlock)handlerBlock {
    
    [self pn_dispatchBlock:^{
        
        [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray *{
            
            return @[PNLoggerSymbols.api.channelGroupsRequestAttempt, (nspace ? nspace : [NSNull null]),
                     [self humanReadableStateFrom:self.state]];
        }];
        
        [self performAsyncLockingBlock:^{
            
            if (!isMethodCallRescheduled) {
                
                [self.observationCenter removeClientAsChannelGroupsRequestObserver];
            }
            
            // Check whether client is able to send request or not
            NSInteger statusCode = [self requestExecutionPossibilityStatusCode];
            if (statusCode == 0) {
                
                [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray * {
                    
                    return @[PNLoggerSymbols.api.requestChannelGroups, [self humanReadableStateFrom:self.state]];
                }];
                
                if (handlerBlock && !isMethodCallRescheduled) {
                    
                    [self.observationCenter addClientAsChannelGroupsRequestObserverWithCallbackBlock:handlerBlock];
                }
                
                PNChannelGroupsRequest *request = [PNChannelGroupsRequest channelGroupsRequestForNamespace:nspace];
                [self sendRequest:request shouldObserveProcessing:YES];
            }
            // Looks like client can't send request because of some reasons
            else {
                
                [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray * {
                    
                    return @[PNLoggerSymbols.api.channelGroupsRequestImpossible,
                             [self humanReadableStateFrom:self.state]];
                }];
                
                PNError *requestError = [PNError errorWithCode:statusCode];
                requestError.associatedObject = nspace;
                
                [self notifyDelegateAboutChannelGroupsRequestFailedWithError:requestError];
                
                if (handlerBlock && !isMethodCallRescheduled) {
                    
                    handlerBlock(nspace, nil, requestError);
                }
            }
        }
               postponedExecutionBlock:^{
                   
                   [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray *{
                       
                       return @[PNLoggerSymbols.api.postponeChannelGroupsRequest,
                                [self humanReadableStateFrom:self.state]];
                   }];
                   
                   [self postponeRequestChannelGroupsForNamespace:nspace reschedulingMethodCall:isMethodCallRescheduled
                                      withCompletionHandlingBlock:handlerBlock];
               }];
    }];
}

- (void)postponeRequestChannelGroupsForNamespace:(NSString *)nspace reschedulingMethodCall:(BOOL)isMethodCallRescheduled
                     withCompletionHandlingBlock:(PNClientChannelGroupsRequestHandlingBlock)handlerBlock {
    
    SEL targetSelector = @selector(requestChannelGroupsForNamespace:reschedulingMethodCall:withCompletionHandlingBlock:);
    id handlerBlockCopy = (handlerBlock ? [handlerBlock copy] : nil);
    [self postponeSelector:targetSelector forObject:self withParameters:@[[PNHelper nilifyIfNotSet:nspace], @(isMethodCallRescheduled),
                                                                          [PNHelper nilifyIfNotSet:handlerBlockCopy]]
                outOfOrder:isMethodCallRescheduled];
}


#pragma mark - Namespace / group panimulation

- (void)requestChannelGroupNamespaces {
    
    [self requestChannelGroupNamespacesWithCompletionHandlingBlock:nil];
}

- (void)requestChannelGroupNamespacesWithCompletionHandlingBlock:(PNClientChannelGroupNamespacesRequestHandlingBlock)handlerBlock {
    
    [self requestChannelGroupNamespacesWithReschedulingMethodCall:NO andCompletionHandlingBlock:handlerBlock];
}

- (void)requestChannelGroupNamespacesWithReschedulingMethodCall:(BOOL)isMethodCallRescheduled
                                     andCompletionHandlingBlock:(PNClientChannelGroupNamespacesRequestHandlingBlock)handlerBlock {
    
    [self pn_dispatchBlock:^{
        
        [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray *{
            
            return @[PNLoggerSymbols.api.channelGroupNamespacesRetrieveAttempt, [self humanReadableStateFrom:self.state]];
        }];
        
        [self performAsyncLockingBlock:^{
            
            if (!isMethodCallRescheduled) {
                
                [self.observationCenter removeClientAsChannelGroupNamespacesRequestObserver];
            }
            
            // Check whether client is able to send request or not
            NSInteger statusCode = [self requestExecutionPossibilityStatusCode];
            if (statusCode == 0) {
                
                [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray * {
                    
                    return @[PNLoggerSymbols.api.retrievingChannelGroupNamespaces, [self humanReadableStateFrom:self.state]];
                }];
                
                if (handlerBlock && !isMethodCallRescheduled) {
                    
                    [self.observationCenter addClientAsChannelGroupNamespacesRequestObserverWithCallbackBlock:handlerBlock];
                }
                
                [self sendRequest:[PNChannelGroupNamespacesRequest new] shouldObserveProcessing:YES];
            }
            // Looks like client can't send request because of some reasons
            else {
                
                [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray * {
                    
                    return @[PNLoggerSymbols.api.channelGroupNamespacesRetrieveImpossible,
                             [self humanReadableStateFrom:self.state]];
                }];
                
                PNError *requestError = [PNError errorWithCode:statusCode];
                [self notifyDelegateAboutChannelGroupNamespacesRequestFailedWithError:requestError];
                
                if (handlerBlock && !isMethodCallRescheduled) {
                    
                    handlerBlock(nil, requestError);
                }
            }
        }
               postponedExecutionBlock:^{
                   
                   [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray *{
                       
                       return @[PNLoggerSymbols.api.postponeChannelGroupNamespacesRetrieval,
                                [self humanReadableStateFrom:self.state]];
                   }];
                   
                   [self postponeChannelGroupNamespacesRequestWithReschedulingMethodCall:isMethodCallRescheduled
                                                              andCompletionHandlingBlock:handlerBlock];
               }];
    }];
}

- (void)postponeChannelGroupNamespacesRequestWithReschedulingMethodCall:(BOOL)isMethodCallRescheduled
                                             andCompletionHandlingBlock:(PNClientChannelGroupNamespacesRequestHandlingBlock)handlerBlock {
    
    SEL targetSelector = @selector(requestChannelGroupNamespacesWithReschedulingMethodCall:andCompletionHandlingBlock:);
    id handlerBlockCopy = (handlerBlock ? [handlerBlock copy] : nil);
    [self postponeSelector:targetSelector forObject:self withParameters:@[@(isMethodCallRescheduled),
                                                                          [PNHelper nilifyIfNotSet:handlerBlockCopy]]
                outOfOrder:isMethodCallRescheduled];
}

- (void)removeChannelGroupNamespace:(NSString *)nspace {
    
    [self removeChannelGroupNamespace:nspace withCompletionHandlingBlock:nil];
}

- (void)removeChannelGroupNamespace:(NSString *)nspace withCompletionHandlingBlock:(PNClientChannelGroupNamespaceRemoveHandlingBlock)handlerBlock {
    
    [self removeChannelGroupNamespace:nspace reschedulingMethodCall:NO withCompletionHandlingBlock:handlerBlock];
}

- (void)removeChannelGroupNamespace:(NSString *)nspace reschedulingMethodCall:(BOOL)isMethodCallRescheduled
        withCompletionHandlingBlock:(PNClientChannelGroupNamespaceRemoveHandlingBlock)handlerBlock {
    
    [self pn_dispatchBlock:^{
        
        [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray *{
            
            return @[PNLoggerSymbols.api.channelGroupNamespaceRemovalAttempt, (nspace ? nspace : [NSNull null]),
                     [self humanReadableStateFrom:self.state]];
        }];
        
        [self performAsyncLockingBlock:^{
            
            if (!isMethodCallRescheduled) {
                
                [self.observationCenter removeClientAsChannelGroupNamespaceRemovalObserver];
            }
            
            // Check whether client is able to send request or not
            NSInteger statusCode = [self requestExecutionPossibilityStatusCode];
            if (statusCode == 0) {
                
                [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray * {
                    
                    return @[PNLoggerSymbols.api.removingChannelGroupNamespace, [self humanReadableStateFrom:self.state]];
                }];
                
                if (handlerBlock && !isMethodCallRescheduled) {
                    
                    [self.observationCenter addClientAsChannelGroupNamespaceRemovalObserverWithCallbackBlock:handlerBlock];
                }
                
                [self sendRequest:[PNChannelGroupNamespaceRemoveRequest requestToRemoveNamespace:nspace] shouldObserveProcessing:YES];
            }
            // Looks like client can't send request because of some reasons
            else {
                
                [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray * {
                    
                    return @[PNLoggerSymbols.api.channelGroupNamespaceRemovalImpossible,
                             [self humanReadableStateFrom:self.state]];
                }];
                
                PNError *requestError = [PNError errorWithCode:statusCode];
                requestError.associatedObject = nspace;
                [self notifyDelegateAboutChannelGroupNamespaceRemovalFailedWithError:requestError];
                
                if (handlerBlock && !isMethodCallRescheduled) {
                    
                    handlerBlock(nspace, requestError);
                }
            }
        }
               postponedExecutionBlock:^{
                   
                   [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray *{
                       
                       return @[PNLoggerSymbols.api.postponeChannelGroupNamespaceRemoval,
                                [self humanReadableStateFrom:self.state]];
                   }];
                   
                   [self postponeRemoveChannelGroupNamespace:nspace reschedulingMethodCall:isMethodCallRescheduled
                                 withCompletionHandlingBlock:handlerBlock];
               }];
    }];
}

- (void)postponeRemoveChannelGroupNamespace:(NSString *)nspace reschedulingMethodCall:(BOOL)isMethodCallRescheduled
                withCompletionHandlingBlock:(PNClientChannelGroupNamespaceRemoveHandlingBlock)handlerBlock {
    
    SEL targetSelector = @selector(removeChannelGroupNamespace:reschedulingMethodCall:withCompletionHandlingBlock:);
    id handlerBlockCopy = (handlerBlock ? [handlerBlock copy] : nil);
    [self postponeSelector:targetSelector forObject:self withParameters:@[[PNHelper nilifyIfNotSet:nspace], @(isMethodCallRescheduled),
                                                                          [PNHelper nilifyIfNotSet:handlerBlockCopy]]
                outOfOrder:isMethodCallRescheduled];
}

- (void)removeChannelGroup:(PNChannelGroup *)group {
    
    [self removeChannelGroup:group withCompletionHandlingBlock:nil];
}

- (void)removeChannelGroup:(PNChannelGroup *)group withCompletionHandlingBlock:(PNClientChannelGroupRemoveHandlingBlock)handlerBlock {
    
    [self removeChannelGroup:group reschedulingMethodCall:NO withCompletionHandlingBlock:handlerBlock];
}

- (void)   removeChannelGroup:(PNChannelGroup *)group reschedulingMethodCall:(BOOL)isMethodCallRescheduled
  withCompletionHandlingBlock:(PNClientChannelGroupRemoveHandlingBlock)handlerBlock {
    
    [self pn_dispatchBlock:^{
        
        [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray *{
            
            return @[PNLoggerSymbols.api.channelGroupRemovalAttempt, (group ? group : [NSNull null]),
                     [self humanReadableStateFrom:self.state]];
        }];
        
        [self performAsyncLockingBlock:^{
            
            if (!isMethodCallRescheduled) {
                
                [self.observationCenter removeClientAsChannelGroupRemovalObserver];
            }
            
            // Check whether client is able to send request or not
            NSInteger statusCode = [self requestExecutionPossibilityStatusCode];
            if (statusCode == 0) {
                
                [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray * {
                    
                    return @[PNLoggerSymbols.api.removingChannelGroup, [self humanReadableStateFrom:self.state]];
                }];
                
                if (handlerBlock && !isMethodCallRescheduled) {
                    
                    [self.observationCenter addClientAsChannelGroupRemovalObserverWithCallbackBlock:handlerBlock];
                }
                
                [self sendRequest:[PNChannelGroupRemoveRequest requestToRemoveGroup:group] shouldObserveProcessing:YES];
            }
            // Looks like client can't send request because of some reasons
            else {
                
                [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray * {
                    
                    return @[PNLoggerSymbols.api.channelGroupRemovalImpossible,
                             [self humanReadableStateFrom:self.state]];
                }];
                
                PNError *requestError = [PNError errorWithCode:statusCode];
                requestError.associatedObject = group;
                [self notifyDelegateAboutChannelGroupRemovalFailedWithError:requestError];
                
                if (handlerBlock && !isMethodCallRescheduled) {
                    
                    handlerBlock(group, requestError);
                }
            }
        }
               postponedExecutionBlock:^{
                   
                   [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray *{
                       
                       return @[PNLoggerSymbols.api.postponeChannelGroupRemoval,
                                [self humanReadableStateFrom:self.state]];
                   }];
                   
                   [self postponeRemoveChannelGroup:group reschedulingMethodCall:isMethodCallRescheduled
                        withCompletionHandlingBlock:handlerBlock];
               }];
    }];
}

- (void)postponeRemoveChannelGroup:(PNChannelGroup *)group reschedulingMethodCall:(BOOL)isMethodCallRescheduled
       withCompletionHandlingBlock:(PNClientChannelGroupRemoveHandlingBlock)handlerBlock {
    
    SEL targetSelector = @selector(removeChannelGroup:reschedulingMethodCall:withCompletionHandlingBlock:);
    id handlerBlockCopy = (handlerBlock ? [handlerBlock copy] : nil);
    [self postponeSelector:targetSelector forObject:self withParameters:@[[PNHelper nilifyIfNotSet:group], @(isMethodCallRescheduled),
                                                                          [PNHelper nilifyIfNotSet:handlerBlockCopy]]
                outOfOrder:isMethodCallRescheduled];
}


#pragma mark - Channel group channels request

- (void)requestChannelsForGroup:(PNChannelGroup *)group {
    
    [self requestChannelsForGroup:group withCompletionHandlingBlock:nil];
}

- (void)requestChannelsForGroup:(PNChannelGroup *)group
    withCompletionHandlingBlock:(PNClientChannelsForGroupRequestHandlingBlock)handlerBlock {
    
    [self requestChannelsForGroup:group reschedulingMethodCall:NO withCompletionHandlingBlock:handlerBlock];
}

- (void)requestChannelsForGroup:(PNChannelGroup *)group reschedulingMethodCall:(BOOL)isMethodCallRescheduled
    withCompletionHandlingBlock:(PNClientChannelsForGroupRequestHandlingBlock)handlerBlock {
    
    [self pn_dispatchBlock:^{
        
        [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray *{
            
            return @[PNLoggerSymbols.api.channelsForGroupRequestAttempt, (group ? group : [NSNull null]),
                     [self humanReadableStateFrom:self.state]];
        }];
        
        [self performAsyncLockingBlock:^{
            
            if (!isMethodCallRescheduled) {
                
                [self.observationCenter removeClientAsChannelsForGroupRequestObserver];
            }
            
            // Check whether client is able to send request or not
            NSInteger statusCode = [self requestExecutionPossibilityStatusCode];
            if (statusCode == 0) {
                
                [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray * {
                    
                    return @[PNLoggerSymbols.api.requestChannelsForGroup, [self humanReadableStateFrom:self.state]];
                }];
                
                if (handlerBlock && !isMethodCallRescheduled) {
                    
                    [self.observationCenter addClientAsChannelsForGroupRequestObserverWithCallbackBlock:handlerBlock];
                }
                
                PNChannelsForGroupRequest *request = [PNChannelsForGroupRequest channelsRequestForGroup:group];
                [self sendRequest:request shouldObserveProcessing:YES];
            }
            // Looks like client can't send request because of some reasons
            else {
                
                [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray * {
                    
                    return @[PNLoggerSymbols.api.channelsForGroupRequestImpossible,
                             [self humanReadableStateFrom:self.state]];
                }];
                
                PNError *requestError = [PNError errorWithCode:statusCode];
                requestError.associatedObject = group;
                
                [self notifyDelegateAboutChannelsForGroupRequestFailedWithError:requestError];
                
                if (handlerBlock && !isMethodCallRescheduled) {
                    
                    handlerBlock(group, requestError);
                }
            }
        }
               postponedExecutionBlock:^{
                   
                   [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray *{
                       
                       return @[PNLoggerSymbols.api.postponeChannelsForGroupRequest,
                                [self humanReadableStateFrom:self.state]];
                   }];
                   
                   [self postponeRequestChannelsForGroup:group reschedulingMethodCall:isMethodCallRescheduled
                             withCompletionHandlingBlock:handlerBlock];
               }];
    }];
}

- (void)postponeRequestChannelsForGroup:(PNChannelGroup *)group reschedulingMethodCall:(BOOL)isMethodCallRescheduled
            withCompletionHandlingBlock:(PNClientChannelsForGroupRequestHandlingBlock)handlerBlock {
    
    SEL targetSelector = @selector(requestChannelsForGroup:reschedulingMethodCall:withCompletionHandlingBlock:);
    id handlerBlockCopy = (handlerBlock ? [handlerBlock copy] : nil);
    [self postponeSelector:targetSelector forObject:self withParameters:@[[PNHelper nilifyIfNotSet:group], @(isMethodCallRescheduled),
                                                                          [PNHelper nilifyIfNotSet:handlerBlockCopy]]
                outOfOrder:isMethodCallRescheduled];
}


#pragma mark - Channel group channels list manipulation

- (void)addChannels:(NSArray *)channels toGroup:(PNChannelGroup *)group {
    
    [self addChannels:channels toGroup:group withCompletionHandlingBlock:nil];
}

- (void)          addChannels:(NSArray *)channels toGroup:(PNChannelGroup *)group
  withCompletionHandlingBlock:(PNClientChannelsAdditionToGroupHandlingBlock)handlerBlock {
    
    [self addChannels:channels toGroup:group reschedulingMethodCall:NO withCompletionHandlingBlock:handlerBlock];
}

- (void)          addChannels:(NSArray *)channels toGroup:(PNChannelGroup *)group reschedulingMethodCall:(BOOL)isMethodCallRescheduled
  withCompletionHandlingBlock:(PNClientChannelsAdditionToGroupHandlingBlock)handlerBlock {
    
    [self pn_dispatchBlock:^{
        
        [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray *{
            
            return @[PNLoggerSymbols.api.channelsAdditionToGroupAttempt, (channels ? channels : [NSNull null]),
                     (group ? group : [NSNull null]), [self humanReadableStateFrom:self.state]];
        }];
        
        [self performAsyncLockingBlock:^{
            
            if (!isMethodCallRescheduled) {
                
                [self.observationCenter removeClientAsChannelsAdditionToGroupObserver];
            }
            
            // Check whether client is able to send request or not
            NSInteger statusCode = [self requestExecutionPossibilityStatusCode];
            if (statusCode == 0) {
                
                [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray * {
                    
                    return @[PNLoggerSymbols.api.addingChannelsToGroup, [self humanReadableStateFrom:self.state]];
                }];
                
                if (handlerBlock && !isMethodCallRescheduled) {
                    
                    [self.observationCenter addClientAsChannelsAdditionToGroupObserverWithCallbackBlock:handlerBlock];
                }
                
                PNChannelsListUpdateForChannelGroupRequest *request = [PNChannelsListUpdateForChannelGroupRequest channelsListAddition:channels
                                                                                                                       forChannelGroup:group];
                [self sendRequest:request shouldObserveProcessing:YES];
            }
            // Looks like client can't send request because of some reasons
            else {
                
                [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray * {
                    
                    return @[PNLoggerSymbols.api.channelsAdditionToGroupImpossible,
                             [self humanReadableStateFrom:self.state]];
                }];
                
                PNError *requestError = [PNError errorWithCode:statusCode];
                requestError.associatedObject = [PNChannelGroupChange changeForGroup:group channels:channels addingChannels:YES];
                
                [self notifyDelegateAboutChannelsListChangeFailedWithError:requestError];
                
                if (handlerBlock && !isMethodCallRescheduled) {
                    
                    handlerBlock(group, channels, requestError);
                }
            }
        }
               postponedExecutionBlock:^{
                   
                   [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray *{
                       
                       return @[PNLoggerSymbols.api.postponeChannelsAdditionToGroup,
                                [self humanReadableStateFrom:self.state]];
                   }];
                   
                   [self postponeAddChannels:channels toGroup:group reschedulingMethodCall:isMethodCallRescheduled
                 withCompletionHandlingBlock:handlerBlock];
               }];
    }];
}

- (void)  postponeAddChannels:(NSArray *)channels toGroup:(PNChannelGroup *)group reschedulingMethodCall:(BOOL)isMethodCallRescheduled
  withCompletionHandlingBlock:(PNClientChannelsAdditionToGroupHandlingBlock)handlerBlock {
    
    SEL targetSelector = @selector(addChannels:toGroup:reschedulingMethodCall:withCompletionHandlingBlock:);
    id handlerBlockCopy = (handlerBlock ? [handlerBlock copy] : nil);
    [self postponeSelector:targetSelector forObject:self withParameters:@[[PNHelper nilifyIfNotSet:channels],
                                                                          [PNHelper nilifyIfNotSet:group],
                                                                          @(isMethodCallRescheduled),
                                                                          [PNHelper nilifyIfNotSet:handlerBlockCopy]]
                outOfOrder:isMethodCallRescheduled];
}

- (void)removeChannels:(NSArray *)channels fromGroup:(PNChannelGroup *)group {
    
    [self removeChannels:channels fromGroup:group withCompletionHandlingBlock:nil];
}

- (void)       removeChannels:(NSArray *)channels fromGroup:(PNChannelGroup *)group
  withCompletionHandlingBlock:(PNClientChannelsRemovalFromGroupHandlingBlock)handlerBlock {
    
    [self removeChannels:channels fromGroup:group reschedulingMethodCall:NO withCompletionHandlingBlock:handlerBlock];
}

- (void)       removeChannels:(NSArray *)channels fromGroup:(PNChannelGroup *)group reschedulingMethodCall:(BOOL)isMethodCallRescheduled
  withCompletionHandlingBlock:(PNClientChannelsRemovalFromGroupHandlingBlock)handlerBlock {
    
    [self pn_dispatchBlock:^{
        
        [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray *{
            
            return @[PNLoggerSymbols.api.channelsRemovalFromGroupAttempt, (channels ? channels : [NSNull null]),
                     (group ? group : [NSNull null]), [self humanReadableStateFrom:self.state]];
        }];
        
        [self performAsyncLockingBlock:^{
            
            if (!isMethodCallRescheduled) {
                
                [self.observationCenter removeClientAsChannelsRemovalFromGroupObserver];
            }
            
            // Check whether client is able to send request or not
            NSInteger statusCode = [self requestExecutionPossibilityStatusCode];
            if (statusCode == 0) {
                
                [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray * {
                    
                    return @[PNLoggerSymbols.api.removingChannelsFromGroup, [self humanReadableStateFrom:self.state]];
                }];
                
                if (handlerBlock && !isMethodCallRescheduled) {
                    
                    [self.observationCenter addClientAsChannelsRemovalFromGroupObserverWithCallbackBlock:handlerBlock];
                }
                
                PNChannelsListUpdateForChannelGroupRequest *request = [PNChannelsListUpdateForChannelGroupRequest channelsListRemoval:channels
                                                                                                                      forChannelGroup:group];
                [self sendRequest:request shouldObserveProcessing:YES];
            }
            // Looks like client can't send request because of some reasons
            else {
                
                [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray * {
                    
                    return @[PNLoggerSymbols.api.channelsRemovalGroupImpossible,
                             [self humanReadableStateFrom:self.state]];
                }];
                
                PNError *requestError = [PNError errorWithCode:statusCode];
                requestError.associatedObject = [PNChannelGroupChange changeForGroup:group channels:channels addingChannels:NO];
                
                [self notifyDelegateAboutChannelsListChangeFailedWithError:requestError];
                
                if (handlerBlock && !isMethodCallRescheduled) {
                    
                    handlerBlock(group, channels, requestError);
                }
            }
        }
               postponedExecutionBlock:^{
                   
                   [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray *{
                       
                       return @[PNLoggerSymbols.api.postponeChannelsRemovalFromGroup,
                                [self humanReadableStateFrom:self.state]];
                   }];
                   
                   [self postponeRemoveChannels:channels fromGroup:group reschedulingMethodCall:isMethodCallRescheduled
                    withCompletionHandlingBlock:handlerBlock];
               }];
    }];
}

- (void)postponeRemoveChannels:(NSArray *)channels fromGroup:(PNChannelGroup *)group reschedulingMethodCall:(BOOL)isMethodCallRescheduled
   withCompletionHandlingBlock:(PNClientChannelsRemovalFromGroupHandlingBlock)handlerBlock {
    
    SEL targetSelector = @selector(removeChannels:fromGroup:reschedulingMethodCall:withCompletionHandlingBlock:);
    id handlerBlockCopy = (handlerBlock ? [handlerBlock copy] : nil);
    [self postponeSelector:targetSelector forObject:self withParameters:@[[PNHelper nilifyIfNotSet:channels],
                                                                          [PNHelper nilifyIfNotSet:group],
                                                                          @(isMethodCallRescheduled),
                                                                          [PNHelper nilifyIfNotSet:handlerBlockCopy]]
                outOfOrder:isMethodCallRescheduled];
}


#pragma mark - Misc methods

- (void)notifyDelegateAboutChannelGroupsRequestFailedWithError:(PNError *)error {
    
    [self handleLockingOperationBlockCompletion:^{
        
        [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray *{
            
            return @[PNLoggerSymbols.api.channelGroupsRequestFailed, [self humanReadableStateFrom:self.state]];
        }];
        
        // Check whether delegate us able to handle participants list download error or not
        if ([self.clientDelegate respondsToSelector:@selector(pubnubClient:channelGroupsRequestDidFailWithError:)]) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [self.clientDelegate pubnubClient:self channelGroupsRequestDidFailWithError:error];
            });
        }
        
        [self sendNotification:kPNClientChannelGroupsRequestDidFailWithErrorNotification withObject:error];
    }
                                shouldStartNext:YES];
}

- (void)notifyDelegateAboutChannelGroupNamespacesRequestFailedWithError:(PNError *)error {
    
    [self handleLockingOperationBlockCompletion:^{
        
        [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray *{
            
            return @[PNLoggerSymbols.api.channelGroupNamespacesRetrievalFailed, [self humanReadableStateFrom:self.state]];
        }];
        
        // Check whether delegate us able to handle participants list download error or not
        if ([self.clientDelegate respondsToSelector:@selector(pubnubClient:channelGroupNamespacesRequestDidFailWithError:)]) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [self.clientDelegate pubnubClient:self channelGroupNamespacesRequestDidFailWithError:error];
            });
        }
        
        [self sendNotification:kPNClientChannelGroupNamespacesRequestDidFailWithErrorNotification withObject:error];
    }
                                shouldStartNext:YES];
}

- (void)notifyDelegateAboutChannelGroupNamespaceRemovalFailedWithError:(PNError *)error {
    
    [self handleLockingOperationBlockCompletion:^{
        
        [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray *{
            
            return @[PNLoggerSymbols.api.channelGroupNamespaceRemovalFailed, [self humanReadableStateFrom:self.state]];
        }];
        
        // Check whether delegate us able to handle participants list download error or not
        if ([self.clientDelegate respondsToSelector:@selector(pubnubClient:namespaceRemovalDidFailWithError:)]) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [self.clientDelegate pubnubClient:self namespaceRemovalDidFailWithError:error];
            });
        }
        
        [self sendNotification:kPNClientChannelGroupNamespaceRemovalDidFailWithErrorNotification withObject:error];
    }
                                shouldStartNext:YES];
}

- (void)notifyDelegateAboutChannelGroupRemovalFailedWithError:(PNError *)error {
    
    [self handleLockingOperationBlockCompletion:^{
        
        [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray *{
            
            return @[PNLoggerSymbols.api.channelGroupRemovalFailed, [self humanReadableStateFrom:self.state]];
        }];
        
        // Check whether delegate us able to handle participants list download error or not
        if ([self.clientDelegate respondsToSelector:@selector(pubnubClient:channelGroupRemovalDidFailWithError:)]) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [self.clientDelegate pubnubClient:self channelGroupRemovalDidFailWithError:error];
            });
        }
        
        [self sendNotification:kPNClientChannelGroupRemovalDidFailWithErrorNotification withObject:error];
    }
                                shouldStartNext:YES];
}

- (void)notifyDelegateAboutChannelsForGroupRequestFailedWithError:(PNError *)error {
    
    [self handleLockingOperationBlockCompletion:^{
        
        [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray *{
            
            return @[PNLoggerSymbols.api.channelsForGroupRequestFailed, [self humanReadableStateFrom:self.state]];
        }];
        
        // Check whether delegate us able to handle participants list download error or not
        if ([self.clientDelegate respondsToSelector:@selector(pubnubClient:channelsForGroupRequestDidFailWithError:)]) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [self.clientDelegate pubnubClient:self channelsForGroupRequestDidFailWithError:error];
            });
        }
        
        [self sendNotification:kPNClientChannelsForGroupRequestDidFailWithErrorNotification withObject:error];
    }
                                shouldStartNext:YES];
}

- (void)notifyDelegateAboutChannelsListChangeFailedWithError:(PNError *)error {
    
    [self handleLockingOperationBlockCompletion:^{
        
        PNChannelGroupChange *change = error.associatedObject;
        NSString *symbol = PNLoggerSymbols.api.channelsAdditionToGroupFailed;
        NSString *notification = kPNClientGroupChannelsAdditionDidFailWithErrorNotification;
        SEL selector = @selector(pubnubClient:channelsAdditionToGroupDidFailWithError:);
        if (!change.addingChannels) {
            
            symbol = PNLoggerSymbols.api.channelsRemovalFromGroupFailed;
            notification = kPNClientGroupChannelsRemovalDidFailWithErrorNotification;
            selector = @selector(pubnubClient:channelsRemovalFromGroupDidFailWithError:);
        }
        
        [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray *{
            
            return @[symbol, [self humanReadableStateFrom:self.state]];
        }];
        
        // Check whether delegate us able to handle channels list change error or not
        if ([self.clientDelegate respondsToSelector:selector]) {
            
            #pragma clang diagnostic push
            #pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [self.clientDelegate performSelector:selector withObject:self withObject:error];
            });
            #pragma clang diagnostic pop
        }
        
        [self sendNotification:notification withObject:error];
    }
                                shouldStartNext:YES];
}


#pragma mark - Service channel delegate methods

- (void)serviceChannel:(PNServiceChannel *)channel didReceiveChannelGroups:(NSArray *)channelGroups
          forNamespace:(NSString *)nspace {

    void(^handlingBlock)(BOOL) = ^(BOOL shouldNotify){

        [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray *{

            return @[PNLoggerSymbols.api.channelGroupsRequestCompleted, [self humanReadableStateFrom:self.state]];
        }];

        if (shouldNotify) {

            // Check whether delegate can response on participants list download event or not
            if ([self.clientDelegate respondsToSelector:@selector(pubnubClient:didReceiveChannelGroups:forNamespace:)]) {

                dispatch_async(dispatch_get_main_queue(), ^{

                    [self.clientDelegate pubnubClient:self didReceiveChannelGroups:channelGroups forNamespace:nspace];
                });
            }

            id notificationObject = channelGroups;
            if (nspace) {

                notificationObject = @{nspace:channelGroups};
            }

            [self sendNotification:kPNClientChannelGroupsRequestCompleteNotification withObject:notificationObject];
        }
    };

    [self checkShouldChannelNotifyAboutEvent:channel withBlock:^(BOOL shouldNotify) {

        [self handleLockingOperationBlockCompletion:^{

            handlingBlock(shouldNotify);
        }
                                    shouldStartNext:YES];
    }];
}

- (void)serviceChannel:(PNServiceChannel *)channel channelGroupsRequestForNamespace:(NSString *)nspace
      didFailWithError:(PNError *)error {
    
    if (error.code != kPNRequestCantBeProcessedWithOutRescheduleError) {
        
        [error replaceAssociatedObject:nspace];
        [self notifyDelegateAboutChannelGroupsRequestFailedWithError:error];
    }
    else {
        
        [self rescheduleMethodCall:^{
            
            [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray *{
                
                return @[PNLoggerSymbols.api.rescheduleChannelGroupsRequest, [self humanReadableStateFrom:self.state]];
            }];
            
            [self requestChannelGroupsForNamespace:nspace reschedulingMethodCall:YES
                       withCompletionHandlingBlock:nil];
        }];
    }
}

- (void)serviceChannel:(PNServiceChannel *)channel didReceiveChannelGroupNamespaces:(NSArray *)namespaces {

    void(^handlingBlock)(BOOL) = ^(BOOL shouldNotify){

        [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray *{

            return @[PNLoggerSymbols.api.channelGroupNamespacesRetrievalCompleted, [self humanReadableStateFrom:self.state]];
        }];

        if (shouldNotify) {

            if ([self.clientDelegate respondsToSelector:@selector(pubnubClient:didReceiveChannelGroupNamespaces:)]) {

                dispatch_async(dispatch_get_main_queue(), ^{

                    [self.clientDelegate pubnubClient:self didReceiveChannelGroupNamespaces:namespaces];
                });
            }

            [self sendNotification:kPNClientChannelGroupNamespacesRequestCompleteNotification withObject:namespaces];
        }
    };

    [self checkShouldChannelNotifyAboutEvent:channel withBlock:^(BOOL shouldNotify) {

        [self handleLockingOperationBlockCompletion:^{

            handlingBlock(shouldNotify);
        }
                                    shouldStartNext:YES];
    }];
}

- (void)serviceChannel:(PNServiceChannel *)channel channelGroupNamespacesRequestDidFailWithError:(PNError *)error {
    
    if (error.code != kPNRequestCantBeProcessedWithOutRescheduleError) {
        
        [self notifyDelegateAboutChannelGroupNamespacesRequestFailedWithError:error];
    }
    else {
        
        [self rescheduleMethodCall:^{
            
            [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray *{
                
                return @[PNLoggerSymbols.api.rescheduleChannelGroupNamespacesRetrieval, [self humanReadableStateFrom:self.state]];
            }];
            
            [self requestChannelGroupNamespacesWithReschedulingMethodCall:YES
                                               andCompletionHandlingBlock:nil];
        }];
    }
}

- (void)serviceChannel:(PNServiceChannel *)channel didRemoveNamespace:(NSString *)nspace {

    void(^handlingBlock)(BOOL) = ^(BOOL shouldNotify){

        [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray *{

            return @[PNLoggerSymbols.api.channelGroupNamespaceRemovalCompleted, [self humanReadableStateFrom:self.state]];
        }];

        if (shouldNotify) {

            if ([self.clientDelegate respondsToSelector:@selector(pubnubClient:didRemoveNamespace:)]) {

                dispatch_async(dispatch_get_main_queue(), ^{

                    [self.clientDelegate pubnubClient:self didRemoveNamespace:nspace];
                });
            }

            [self sendNotification:kPNClientChannelGroupNamespaceRemovalCompleteNotification withObject:nspace];
        }
    };

    [self checkShouldChannelNotifyAboutEvent:channel withBlock:^(BOOL shouldNotify) {

        [self handleLockingOperationBlockCompletion:^{

            handlingBlock(shouldNotify);
        }
                                    shouldStartNext:YES];
    }];
}

- (void)serviceChannel:(PNServiceChannel *)channel namespace:(NSString *)nspace removalDidFailWithError:(PNError *)error {
    
    if (error.code != kPNRequestCantBeProcessedWithOutRescheduleError) {
        
        [error replaceAssociatedObject:nspace];
        [self notifyDelegateAboutChannelGroupNamespaceRemovalFailedWithError:error];
    }
    else {
        
        [self rescheduleMethodCall:^{
            
            [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray *{
                
                return @[PNLoggerSymbols.api.rescheduleChannelGroupNamespaceRemoval, [self humanReadableStateFrom:self.state]];
            }];
            
            [self removeChannelGroupNamespace:nspace reschedulingMethodCall:YES
                  withCompletionHandlingBlock:nil];
        }];
    }
}

- (void)serviceChannel:(PNServiceChannel *)channel didRemoveChannelGroup:(PNChannelGroup *)group {

    void(^handlingBlock)(BOOL) = ^(BOOL shouldNotify){

        [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray *{

            return @[PNLoggerSymbols.api.channelGroupRemovalCompleted, [self humanReadableStateFrom:self.state]];
        }];

        if (shouldNotify) {

            if ([self.clientDelegate respondsToSelector:@selector(pubnubClient:didRemoveChannelGroup:)]) {

                dispatch_async(dispatch_get_main_queue(), ^{

                    [self.clientDelegate pubnubClient:self didRemoveChannelGroup:group];
                });
            }

            [self sendNotification:kPNClientChannelGroupRemovalCompleteNotification withObject:group];
        }
    };

    [self checkShouldChannelNotifyAboutEvent:channel withBlock:^(BOOL shouldNotify) {

        [self handleLockingOperationBlockCompletion:^{

            handlingBlock(shouldNotify);
        }
                                    shouldStartNext:YES];
    }];
}

- (void)serviceChannel:(PNServiceChannel *)channel channelGroup:(PNChannelGroup *)group removalDidFailWithError:(PNError *)error {
    
    if (error.code != kPNRequestCantBeProcessedWithOutRescheduleError) {
        
        [self notifyDelegateAboutChannelGroupRemovalFailedWithError:error];
    }
    else {
        
        [self rescheduleMethodCall:^{
            
            [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray *{
                
                return @[PNLoggerSymbols.api.rescheduleChannelGroupRemoval, [self humanReadableStateFrom:self.state]];
            }];
            
            [self removeChannelGroup:group reschedulingMethodCall:YES
         withCompletionHandlingBlock:nil];
        }];
    }
}

- (void)serviceChannel:(PNServiceChannel *)channel didReceiveChannels:(NSArray *)channels forGroup:(PNChannelGroup *)group {

    void(^handlingBlock)(BOOL) = ^(BOOL shouldNotify){

        [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray *{

            return @[PNLoggerSymbols.api.channelsForGroupRequestCompleted, [self humanReadableStateFrom:self.state]];
        }];

        if (shouldNotify) {

            group.channels = channels;

            // Check whether delegate can response on participants list download event or not
            if ([self.clientDelegate respondsToSelector:@selector(pubnubClient:didReceiveChannelsForGroup:)]) {

                dispatch_async(dispatch_get_main_queue(), ^{

                    [self.clientDelegate pubnubClient:self didReceiveChannelsForGroup:group];
                });
            }

            [self sendNotification:kPNClientChannelsForGroupRequestCompleteNotification withObject:group];
        }
    };

    [self checkShouldChannelNotifyAboutEvent:channel withBlock:^(BOOL shouldNotify) {

        [self handleLockingOperationBlockCompletion:^{

            handlingBlock(shouldNotify);
        }
                                    shouldStartNext:YES];
    }];
}

- (void)serviceChannel:(PNServiceChannel *)channel channelsForGroupRequest:(PNChannelGroup *)group
      didFailWithError:(PNError *)error {
    
    if (error.code != kPNRequestCantBeProcessedWithOutRescheduleError) {
        
        [self notifyDelegateAboutChannelsForGroupRequestFailedWithError:error];
    }
    else {
        
        [self rescheduleMethodCall:^{
            
            [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray *{
                
                return @[PNLoggerSymbols.api.rescheduleChannelsForGroupRequest, [self humanReadableStateFrom:self.state]];
            }];
            
            [self requestChannelsForGroup:group reschedulingMethodCall:YES
              withCompletionHandlingBlock:nil];
        }];
    }
}

- (void)serviceChannel:(PNServiceChannel *)channel didChangeGroupChannels:(PNChannelGroupChange *)change {

    void(^handlingBlock)(BOOL) = ^(BOOL shouldNotify){

        NSString *symbol = ([change addingChannels] ? PNLoggerSymbols.api.channelsAdditionToGroupCompleted :
                            PNLoggerSymbols.api.channelsRemovalFromGroupCompleted);

        [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray *{

            return @[symbol, [self humanReadableStateFrom:self.state]];
        }];

        if (shouldNotify) {

            NSString *notification = kPNClientGroupChannelsAdditionCompleteNotification;
            SEL selector = @selector(pubnubClient:didAddChannels:toGroup:);
            if (!change.addingChannels) {

                symbol = PNLoggerSymbols.api.channelsRemovalFromGroupFailed;
                notification = kPNClientGroupChannelsRemovalCompleteNotification;
                selector = @selector(pubnubClient:didRemoveChannels:fromGroup:);
            }

            // Check whether delegate can response on group channels list manipulation or not
            if ([self.clientDelegate respondsToSelector:selector]) {

                dispatch_async(dispatch_get_main_queue(), ^{

                    if (change.addingChannels) {

                        [self.clientDelegate pubnubClient:self didAddChannels:change.channels toGroup:change.group];
                    }
                    else {

                        [self.clientDelegate pubnubClient:self didRemoveChannels:change.channels fromGroup:change.group];
                    }

                });
            }

            [self sendNotification:notification withObject:change];
        }
    };

    [self checkShouldChannelNotifyAboutEvent:channel withBlock:^(BOOL shouldNotify) {

        [self handleLockingOperationBlockCompletion:^{

            handlingBlock(shouldNotify);
        }
                                    shouldStartNext:YES];
    }];
}

- (void)serviceChannel:(PNServiceChannel *)channel groupChannelsChange:(PNChannelGroupChange *)change
      didFailWithError:(PNError *)error {
    
    if (error.code != kPNRequestCantBeProcessedWithOutRescheduleError) {
        
        [error replaceAssociatedObject:change];
        [self notifyDelegateAboutChannelsListChangeFailedWithError:error];
    }
    else {
        
        [self rescheduleMethodCall:^{
            
            NSString *symbol = ([change addingChannels] ? PNLoggerSymbols.api.rescheduleChannelsAdditionToGroup :
                                                          PNLoggerSymbols.api.rescheduleChannelsRemovalFromGroup);
            [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray *{
                
                return @[symbol, [self humanReadableStateFrom:self.state]];
            }];
            
            if ([change addingChannels]) {
                
                [self addChannels:change.channels toGroup:change.group reschedulingMethodCall:YES
      withCompletionHandlingBlock:nil];
            }
            else {
                
                [self removeChannels:change.channels fromGroup:change.group reschedulingMethodCall:YES
         withCompletionHandlingBlock:nil];
            }
        }];
    }
}

#pragma mark -


@end
