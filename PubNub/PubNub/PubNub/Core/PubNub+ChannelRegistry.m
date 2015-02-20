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
 @brief Retrieve list of channel groups which has been registered for all application users
        (identifier by subscription key).
 
 @param nspace        Namespace name from which channel groups should be retrieved.
 @param callbackToken Reference on callback token under which stored block passed by user on API
                      usage. This block will be reused because of method rescheduling.
 @param handlerBlock  The block which will be called by \b PubNub client as soon as channel groups
                      request operation will be completed. The block takes three arguments:
                      \c namespace - namespace from which channel groups requested; \c groups - list
                      of \b PNChannelGroup describing channel group inside of namespace;
                      \c error - describes what exactly went wrong (check error code and compare it
                      with \b PNErrorCodes ).
 
 @since 3.7.0
 */
- (void)requestChannelGroupsForNamespace:(NSString *)nspace
                rescheduledCallbackToken:(NSString *)callbackToken
             withCompletionHandlingBlock:(PNClientChannelGroupsRequestHandlingBlock)handlerBlock;

/**
 @brief Postpone channel groups list request so it will be executed in future.
 
 @note  Postpone can be because of few cases: \b PubNub client is in connecting or initial
        connection state; another request which has been issued earlier didn't completed yet.
 
 @param nspace        Namespace name from which channel groups should be retrieved.
 @param callbackToken Reference on callback token under which stored block passed by user on API
                      usage. This block will be reused because of method rescheduling.
 @param handlerBlock  The block which will be called by \b PubNub client as soon as channel groups
                      request operation will be completed. The block takes three arguments:
                      \c namespace - namespace from which channel groups requested; \c groups - list
                      of \b PNChannelGroup describing channel group inside of namespace;
                      \c error - describes what exactly went wrong (check error code and compare it
                      with \b PNErrorCodes ).

 @since 3.7.0
 */
- (void)postponeRequestChannelGroupsForNamespace:(NSString *)nspace
                        rescheduledCallbackToken:(NSString *)callbackToken
                     withCompletionHandlingBlock:(id)handlerBlock;


#pragma mark - Namespace / group panimulation

/**
 @brief Retrieve list of all namespaces which has been created under application subscribe key.
 
 @param callbackToken Reference on callback token under which stored block passed by user on API
                      usage. This block will be reused because of method rescheduling.
 @param handlerBlock  The block which will be called by \b PubNub client as soon as namespace list
                      pulled for channel group (all available namespaces under which channel group
                      can be registered). The block takes two arguments: \c namespaces - list of
                      namespaces which has been created to store registered channel groups;
                      \c error - describes what exactly went wrong (check error code and compare it
                      with \b PNErrorCodes ).
 
 @since 3.7.0
 */
- (void)requestChannelGroupNamespacesWithRescheduledCallbackToken:(NSString *)callbackToken
                                       andCompletionHandlingBlock:(PNClientChannelGroupNamespacesRequestHandlingBlock)handlerBlock;

/**
 @brief Postpone channel group namespaces list request so it will be executed in future.
 
 @note  Postpone can be because of few cases: \b PubNub client is in connecting or initial
        connection state; another request which has been issued earlier didn't completed yet.
 
 @param callbackToken Reference on callback token under which stored block passed by user on API
                      usage. This block will be reused because of method rescheduling.
 @param handlerBlock  The block which will be called by \b PubNub client as soon as namespace list
                      pulled for channel group (all available namespaces under which channel group
                      can be registered). The block takes two arguments: \c namespaces - list of
                      namespaces which has been created to store registered channel groups;
                      \c error - describes what exactly went wrong (check error code and compare it
                      with \b PNErrorCodes ).
 
 @since 3.7.0
 */
- (void)postponeChannelGroupNamespacesRequestWithRescheduledCallbackToken:(NSString *)callbackToken
                                               andCompletionHandlingBlock:(id)handlerBlock;

/**
 @brief Remove one of channel group namespaces from channel registry. All channel groups and
        channels which has been registered and added to target namespace will be deleted as well.
 
 @param nspace        Reference on namespace name which should be removed along with all channel
                      group and channels registered in it.
 @param callbackToken Reference on callback token under which stored block passed by user on API
                      usage. This block will be reused because of method rescheduling.
 @param handlerBlock  The block which will be called by \b PubNub client as soon as namespace
                      removal process will be completed. The block takes two arguments:
                      \c namespace - namespace name which should be removed; \c error - describes
                      what exactly went wrong (check error code and compare it with \b PNErrorCodes ).
 
 @since 3.7.0
 */
- (void)removeChannelGroupNamespace:(NSString *)nspace
           rescheduledCallbackToken:(NSString *)callbackToken
        withCompletionHandlingBlock:(PNClientChannelGroupNamespaceRemoveHandlingBlock)handlerBlock;

/**
 @brief Postpone channel group namespace removal request so it will be executed in future.
 
 @note  Postpone can be because of few cases: \b PubNub client is in connecting or initial
        connection state; another request which has been issued earlier didn't completed yet.
 
 @param nspace        Reference on namespace name which should be removed along with all channel
                      group and channels registered in it.
 @param callbackToken Reference on callback token under which stored block passed by user on API
                      usage. This block will be reused because of method rescheduling.
 @param handlerBlock  The block which will be called by \b PubNub client as soon as namespace
                      removal process will be completed. The block takes two arguments:
                      \c namespace - namespace name which should be removed; \c error - describes
                      what exactly went wrong (check error code and compare it with \b PNErrorCodes ).
 
 @since 3.7.0
 */
- (void)postponeRemoveChannelGroupNamespace:(NSString *)nspace
                   rescheduledCallbackToken:(NSString *)callbackToken
                withCompletionHandlingBlock:(id)handlerBlock;

/**
 @brief Remove one of channel groups from channel registry. All channels which has been registered
        in it also will be removed.
 
 @param group         \b PNChannelGroup instance which describes channel group which should be
                      deleted by \b PubNub client.
 @param callbackToken Reference on callback token under which stored block passed by user on API
                      usage. This block will be reused because of method rescheduling.
 @param handlerBlock  The block which will be called by \b PubNub client as soon as channel group
                      removal process will be completed. The block takes two arguments:
                      \c PNChannelGroup - \b PNChannelGroup which should be removed; \c error -
                      describes what exactly went wrong (check error code and compare it with
                      \b PNErrorCodes ).
 
 @since 3.7.0
 */
- (void) removeChannelGroup:(PNChannelGroup *)group
   rescheduledCallbackToken:(NSString *)callbackToken
withCompletionHandlingBlock:(PNClientChannelGroupRemoveHandlingBlock)handlerBlock;

/**
 @brief Postpone channel group removal request so it will be executed in future.
 
 @note  Postpone can be because of few cases: \b PubNub client is in connecting or initial
        connection state; another request which has been issued earlier didn't completed yet.
 
 @param group         \b PNChannelGroup instance which describes channel group which should be
                      deleted by \b PubNub client.
 @param callbackToken Reference on callback token under which stored block passed by user on API
                      usage. This block will be reused because of method rescheduling.
 @param handlerBlock  The block which will be called by \b PubNub client as soon as channel group
                      removal process will be completed. The block takes two arguments:
                      \c PNChannelGroup - \b PNChannelGroup which should be removed; \c error -
                      describes what exactly went wrong (check error code and compare it with
                      \b PNErrorCodes ).
 
 @since 3.7.0
 */
- (void)postponeRemoveChannelGroup:(PNChannelGroup *)group
          rescheduledCallbackToken:(NSString *)callbackToken
       withCompletionHandlingBlock:(id)handlerBlock;


#pragma mark - Channel group channels request

/**
 @brief Retrieve list of channels for specific channel group which has been added for all
        application users (identifier by subscription key).
 
 @param group         Reference on channel group object which hold information about group name and
                      namespace.
 @param callbackToken Reference on callback token under which stored block passed by user on API
                      usage. This block will be reused because of method rescheduling.
 @param handlerBlock  The block which will be called by \b PubNub client as soon as channels for
                      group request operation will be completed. The block takes two arguments:
                      \c group - \b PNChannelGroup instance which describe group for which channels
                      should be retrieved (it also has property with channels list); \c error -
                      describes what exactly went wrong (check error code and compare it with
                      \b PNErrorCodes ).
 
 @since 3.7.0
 */
- (void)requestChannelsForGroup:(PNChannelGroup *)group
       rescheduledCallbackToken:(NSString *)callbackToken
    withCompletionHandlingBlock:(PNClientChannelsForGroupRequestHandlingBlock)handlerBlock;

/**
 @brief Postpone channels list for group request so it will be executed in future.
 
 @param group         Reference on channel group object which hold information about group name and
                      namespace.
 @param callbackToken Reference on callback token under which stored block passed by user on API
                      usage. This block will be reused because of method rescheduling.
 @param handlerBlock  The block which will be called by \b PubNub client as soon as channels for
                      group request operation will be completed. The block takes two arguments:
                      \c group - \b PNChannelGroup instance which describe group for which channels
                      should be retrieved (it also has property with channels list); \c error -
                      describes what exactly went wrong (check error code and compare it with
                      \b PNErrorCodes ).
 
 @since 3.7.0
 */
- (void)postponeRequestChannelsForGroup:(PNChannelGroup *)group
               rescheduledCallbackToken:(NSString *)callbackToken
            withCompletionHandlingBlock:(id)handlerBlock;


#pragma mark - Channel group channels list manipulation

/**
 @brief Add channels list to the group.
 
 @param channels      Reference on list of \b PNChannel instances which should be added to the
                      group.
 @param group         Reference on channel group object which hold information about group name and
                      namespace.
 @param callbackToken Reference on callback token under which stored block passed by user on API
                      usage. This block will be reused because of method rescheduling.
 @param handlerBlock  The block which will be called by \b PubNub client as soon as channels
                      addition to group operation will be completed. The block takes two arguments:
                      \c group - \b PNChannelGroup instance which describe group into which channels
                      should be added; \c channels - list of \b PNChannel instance which should be
                      added to the group; \c error - describes what exactly went wrong (check error
                      code and compare it with \b PNErrorCodes ).
 
 @since 3.7.0
 */
- (void)        addChannels:(NSArray *)channels toGroup:(PNChannelGroup *)group
   rescheduledCallbackToken:(NSString *)callbackToken
withCompletionHandlingBlock:(PNClientChannelsAdditionToGroupHandlingBlock)handlerBlock;

/**
 @brief Postpone channels list addition to group so it will be executed in future.
 
 @param channels      Reference on list of \b PNChannel instances which should be added to the
                      group.
 @param group         Reference on channel group object which hold information about group name and
                      namespace.
 @param callbackToken Reference on callback token under which stored block passed by user on API
                      usage. This block will be reused because of method rescheduling.
 @param handlerBlock  The block which will be called by \b PubNub client as soon as channels
                      addition to group operation will be completed. The block takes two arguments:
                      \c group - \b PNChannelGroup instance which describe group into which channels
                      should be added; \c channels - list of \b PNChannel instance which should be
                      added to the group; \c error - describes what exactly went wrong (check error
                      code and compare it with \b PNErrorCodes ).
 
 @since 3.7.0
 */
- (void)postponeAddChannels:(NSArray *)channels toGroup:(PNChannelGroup *)group
   rescheduledCallbackToken:(NSString *)callbackToken withCompletionHandlingBlock:(id)handlerBlock;

/**
 @brief Remove channels list from the group.
 
 @param channels      Reference on list of \b PNChannel instances which should be removed from the
                      group.
 @param group         Reference on channel group object which hold information about group name and
                      namespace.
 @param callbackToken Reference on callback token under which stored block passed by user on API
                      usage. This block will be reused because of method rescheduling.
 @param handlerBlock  The block which will be called by \b PubNub client as soon as channels removal
                      from group operation will be completed. The block takes two arguments:
                      \c group - \b PNChannelGroup instance which describe group from which channels
                      should be removed; \c channels - list of \b PNChannel instance which should be
                      removed from the group; \c error - describes what exactly went wrong (check
                      error code and compare it with \b PNErrorCodes ).
 
 @since 3.7.0
 */
- (void)     removeChannels:(NSArray *)channels fromGroup:(PNChannelGroup *)group
   rescheduledCallbackToken:(NSString *)callbackToken
withCompletionHandlingBlock:(PNClientChannelsRemovalFromGroupHandlingBlock)handlerBlock;

/**
 @brief Postpone channels list removal from group so it will be executed in future.
 
 @param channels      Reference on list of \b PNChannel instances which should be removed from the
                      group.
 @param group         Reference on channel group object which hold information about group name and
                      namespace.
 @param callbackToken Reference on callback token under which stored block passed by user on API
                      usage. This block will be reused because of method rescheduling.
 @param handlerBlock  The block which will be called by \b PubNub client as soon as channels removal
                      from group operation will be completed. The block takes two arguments:
                      \c group - \b PNChannelGroup instance which describe group from which channels
                      should be removed; \c channels - list of \b PNChannel instance which should be
                      removed from the group; \c error - describes what exactly went wrong (check
                      error code and compare it with \b PNErrorCodes ).
 
 @since 3.7.0
 */
- (void)postponeRemoveChannels:(NSArray *)channels fromGroup:(PNChannelGroup *)group
      rescheduledCallbackToken:(NSString *)callbackToken
   withCompletionHandlingBlock:(id)handlerBlock;


#pragma mark - Misc methods

/**
 @brief This method will notify delegate about that channel groups retrieve request failed.

 @param error         \b PNError instance which hold information about what exactly went wrong
                      during channel groups audit process.
 @param callbackToken Reference on callback token under which stored block passed by user on API
                      usage. This block will be reused because of method rescheduling.

 @since 3.7.0
 */
- (void)notifyDelegateAboutChannelGroupsRequestFailedWithError:(PNError *)error
                                              andCallbackToken:(NSString *)callbackToken;

/**
 @brief This method will notify delegate about that channel group namespaces retrieve request
        failed.

 @param error         \b PNError instance which hold information about what exactly went wrong
                      during namespaces audit process.
 @param callbackToken Reference on callback token under which stored block passed by user on API
                      usage. This block will be reused because of method rescheduling.

 @since 3.7.0
 */
- (void)notifyDelegateAboutChannelGroupNamespacesRequestFailedWithError:(PNError *)error
                                                       andCallbackToken:(NSString *)callbackToken;

/**
 @brief This method will notify delegate about that channel group namespace removal request failed.

 @param error         \b PNError instance which hold information about what exactly went wrong
                      during namespace removal process.
 @param callbackToken Reference on callback token under which stored block passed by user on API
                      usage. This block will be reused because of method rescheduling.

 @since 3.7.0
 */
- (void)notifyDelegateAboutChannelGroupNamespaceRemovalFailedWithError:(PNError *)error
                                                      andCallbackToken:(NSString *)callbackToken;

/**
 @brief This method will notify delegate about that channel group removal request failed.

 @param error         \b PNError instance which hold information about what exactly went wrong
                      during channel group removal process.
 @param callbackToken Reference on callback token under which stored block passed by user on API
                      usage. This block will be reused because of method rescheduling.

 @since 3.7.0
 */
- (void)notifyDelegateAboutChannelGroupRemovalFailedWithError:(PNError *)error
                                             andCallbackToken:(NSString *)callbackToken;

/**
 @brief This method will notify delegate about that channels list for group retrieve request failed.

 @param error         \b PNError instance which hold information about what exactly went wrong
                      during channel group channels audit process.
 @param callbackToken Reference on callback token under which stored block passed by user on API
                      usage. This block will be reused because of method rescheduling.

 @since 3.7.0
 */
- (void)notifyDelegateAboutChannelsForGroupRequestFailedWithError:(PNError *)error
                                                 andCallbackToken:(NSString *)callbackToken;

/**
 @brief This method will notify delegate about that channels list change for group failed.

 @param error         \b PNError instance which hold information about what exactly went wrong
                      during channel group channels list modification process.
 @param callbackToken Reference on callback token under which stored block passed by user on API
                      usage. This block will be reused because of method rescheduling.

 @since 3.7.0
 */
- (void)notifyDelegateAboutChannelsListChangeFailedWithError:(PNError *)error
                                            andCallbackToken:(NSString *)callbackToken;

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

    [self requestChannelGroupsForNamespace:nspace rescheduledCallbackToken:nil
               withCompletionHandlingBlock:handlerBlock];
}

- (void)requestChannelGroupsForNamespace:(NSString *)nspace
                rescheduledCallbackToken:(NSString *)callbackToken
             withCompletionHandlingBlock:(PNClientChannelGroupsRequestHandlingBlock)handlerBlock {
    
    [self pn_dispatchBlock:^{
        
        [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray *{
            
            return @[PNLoggerSymbols.api.channelGroupsRequestAttempt,
                     (nspace ? nspace : [NSNull null]), [self humanReadableStateFrom:self.state]];
        }];
        
        [self   performAsyncLockingBlock:^{

            // Check whether client is able to send request or not
            NSInteger statusCode = [self requestExecutionPossibilityStatusCode];
            if (statusCode == 0) {

                [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray * {

                    return @[PNLoggerSymbols.api.requestChannelGroups,
                            [self humanReadableStateFrom:self.state]];
                }];

                PNChannelGroupsRequest *request = [PNChannelGroupsRequest channelGroupsRequestForNamespace:nspace];
                if (handlerBlock && !callbackToken) {

                    [self.observationCenter addClientAsChannelGroupsRequestObserverWithToken:request.shortIdentifier
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

                    return @[PNLoggerSymbols.api.channelGroupsRequestImpossible,
                            [self humanReadableStateFrom:self.state]];
                }];

                PNError *requestError = [PNError errorWithCode:statusCode];
                requestError.associatedObject = nspace;

                [self notifyDelegateAboutChannelGroupsRequestFailedWithError:requestError
                                                            andCallbackToken:callbackToken];

                if (handlerBlock && !callbackToken) {

                    dispatch_async(dispatch_get_main_queue(), ^{

                        handlerBlock(nspace, nil, requestError);
                    });
                }
            }
        }        postponedExecutionBlock:^{

            [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray * {

                return @[PNLoggerSymbols.api.postponeChannelGroupsRequest,
                        [self humanReadableStateFrom:self.state]];
            }];

            [self postponeRequestChannelGroupsForNamespace:nspace
                                  rescheduledCallbackToken:callbackToken
                               withCompletionHandlingBlock:handlerBlock];
        } burstExecutionLockingOperation:NO];
    }];
}

- (void)postponeRequestChannelGroupsForNamespace:(NSString *)nspace
                        rescheduledCallbackToken:(NSString *)callbackToken
                     withCompletionHandlingBlock:(id)handlerBlock {
    
    SEL targetSelector = @selector(requestChannelGroupsForNamespace:rescheduledCallbackToken:withCompletionHandlingBlock:);
    id handlerBlockCopy = (handlerBlock ? [handlerBlock copy] : nil);
    [self postponeSelector:targetSelector forObject:self
            withParameters:@[[PNHelper nilifyIfNotSet:nspace],
                             [PNHelper nilifyIfNotSet:callbackToken],
                             [PNHelper nilifyIfNotSet:handlerBlockCopy]]
                outOfOrder:(callbackToken != nil) burstExecutionLock:NO];
}


#pragma mark - Namespace / group panimulation

- (void)requestChannelGroupNamespaces {
    
    [self requestChannelGroupNamespacesWithCompletionHandlingBlock:nil];
}

- (void)requestChannelGroupNamespacesWithCompletionHandlingBlock:(PNClientChannelGroupNamespacesRequestHandlingBlock)handlerBlock {

    [self requestChannelGroupNamespacesWithRescheduledCallbackToken:nil
                                         andCompletionHandlingBlock:handlerBlock];
}

- (void)requestChannelGroupNamespacesWithRescheduledCallbackToken:(NSString *)callbackToken
                                       andCompletionHandlingBlock:(PNClientChannelGroupNamespacesRequestHandlingBlock)handlerBlock {
    
    [self pn_dispatchBlock:^{
        
        [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray *{
            
            return @[PNLoggerSymbols.api.channelGroupNamespacesRetrieveAttempt,
                     [self humanReadableStateFrom:self.state]];
        }];
        
        [self   performAsyncLockingBlock:^{

            // Check whether client is able to send request or not
            NSInteger statusCode = [self requestExecutionPossibilityStatusCode];
            if (statusCode == 0) {

                [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray * {

                    return @[PNLoggerSymbols.api.retrievingChannelGroupNamespaces,
                            [self humanReadableStateFrom:self.state]];
                }];

                PNChannelGroupNamespacesRequest *request = [PNChannelGroupNamespacesRequest new];
                if (handlerBlock && !callbackToken) {

                    [self.observationCenter addClientAsChannelGroupNamespacesRequestObserverWithToken:request.shortIdentifier
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

                    return @[PNLoggerSymbols.api.channelGroupNamespacesRetrieveImpossible,
                            [self humanReadableStateFrom:self.state]];
                }];

                PNError *requestError = [PNError errorWithCode:statusCode];
                [self notifyDelegateAboutChannelGroupNamespacesRequestFailedWithError:requestError
                                                                     andCallbackToken:callbackToken];

                if (handlerBlock && !callbackToken) {

                    dispatch_async(dispatch_get_main_queue(), ^{

                        handlerBlock(nil, requestError);
                    });
                }
            }
        }        postponedExecutionBlock:^{

            [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray * {

                return @[PNLoggerSymbols.api.postponeChannelGroupNamespacesRetrieval,
                        [self humanReadableStateFrom:self.state]];
            }];

            [self postponeChannelGroupNamespacesRequestWithRescheduledCallbackToken:callbackToken
                                                         andCompletionHandlingBlock:handlerBlock];
        } burstExecutionLockingOperation:NO];
    }];
}

- (void)postponeChannelGroupNamespacesRequestWithRescheduledCallbackToken:(NSString *)callbackToken
                                               andCompletionHandlingBlock:(id)handlerBlock {
    
    SEL targetSelector = @selector(requestChannelGroupNamespacesWithRescheduledCallbackToken:andCompletionHandlingBlock:);
    id handlerBlockCopy = (handlerBlock ? [handlerBlock copy] : nil);
    [self postponeSelector:targetSelector forObject:self
            withParameters:@[[PNHelper nilifyIfNotSet:callbackToken],
                             [PNHelper nilifyIfNotSet:handlerBlockCopy]]
                outOfOrder:(callbackToken != nil) burstExecutionLock:NO];
}

- (void)removeChannelGroupNamespace:(NSString *)nspace {
    
    [self removeChannelGroupNamespace:nspace withCompletionHandlingBlock:nil];
}

- (void)removeChannelGroupNamespace:(NSString *)nspace
        withCompletionHandlingBlock:(PNClientChannelGroupNamespaceRemoveHandlingBlock)handlerBlock {

    [self removeChannelGroupNamespace:nspace rescheduledCallbackToken:nil
          withCompletionHandlingBlock:handlerBlock];
}

- (void)removeChannelGroupNamespace:(NSString *)nspace
           rescheduledCallbackToken:(NSString *)callbackToken
        withCompletionHandlingBlock:(PNClientChannelGroupNamespaceRemoveHandlingBlock)handlerBlock {
    
    [self pn_dispatchBlock:^{
        
        [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray *{
            
            return @[PNLoggerSymbols.api.channelGroupNamespaceRemovalAttempt,
                     (nspace ? nspace : [NSNull null]), [self humanReadableStateFrom:self.state]];
        }];
        
        [self   performAsyncLockingBlock:^{

            // Check whether client is able to send request or not
            NSInteger statusCode = [self requestExecutionPossibilityStatusCode];
            if (statusCode == 0) {

                [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray * {

                    return @[PNLoggerSymbols.api.removingChannelGroupNamespace,
                            [self humanReadableStateFrom:self.state]];
                }];

                PNChannelGroupNamespaceRemoveRequest *request = [PNChannelGroupNamespaceRemoveRequest requestToRemoveNamespace:nspace];
                if (handlerBlock && !callbackToken) {

                    [self.observationCenter addClientAsChannelGroupNamespaceRemovalObserverWithToken:request.shortIdentifier
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

                    return @[PNLoggerSymbols.api.channelGroupNamespaceRemovalImpossible,
                            [self humanReadableStateFrom:self.state]];
                }];

                PNError *requestError = [PNError errorWithCode:statusCode];
                requestError.associatedObject = nspace;
                [self notifyDelegateAboutChannelGroupNamespaceRemovalFailedWithError:requestError
                                                                    andCallbackToken:callbackToken];

                if (handlerBlock && !callbackToken) {

                    dispatch_async(dispatch_get_main_queue(), ^{

                        handlerBlock(nspace, requestError);
                    });
                }
            }
        }        postponedExecutionBlock:^{

            [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray * {

                return @[PNLoggerSymbols.api.postponeChannelGroupNamespaceRemoval,
                        [self humanReadableStateFrom:self.state]];
            }];

            [self postponeRemoveChannelGroupNamespace:nspace
                             rescheduledCallbackToken:callbackToken
                          withCompletionHandlingBlock:handlerBlock];
        } burstExecutionLockingOperation:NO];
    }];
}

- (void)postponeRemoveChannelGroupNamespace:(NSString *)nspace
                   rescheduledCallbackToken:(NSString *)callbackToken
                withCompletionHandlingBlock:(id)handlerBlock {
    
    SEL targetSelector = @selector(removeChannelGroupNamespace:rescheduledCallbackToken:withCompletionHandlingBlock:);
    id handlerBlockCopy = (handlerBlock ? [handlerBlock copy] : nil);
    [self postponeSelector:targetSelector forObject:self
            withParameters:@[[PNHelper nilifyIfNotSet:nspace],
                             [PNHelper nilifyIfNotSet:callbackToken],
                             [PNHelper nilifyIfNotSet:handlerBlockCopy]]
                outOfOrder:(callbackToken != nil) burstExecutionLock:NO];
}

- (void)removeChannelGroup:(PNChannelGroup *)group {
    
    [self removeChannelGroup:group withCompletionHandlingBlock:nil];
}

- (void)   removeChannelGroup:(PNChannelGroup *)group
  withCompletionHandlingBlock:(PNClientChannelGroupRemoveHandlingBlock)handlerBlock {

    [self removeChannelGroup:group rescheduledCallbackToken:nil
 withCompletionHandlingBlock:handlerBlock];
}

- (void) removeChannelGroup:(PNChannelGroup *)group rescheduledCallbackToken:(NSString *)callbackToken
withCompletionHandlingBlock:(PNClientChannelGroupRemoveHandlingBlock)handlerBlock {
    
    [self pn_dispatchBlock:^{
        
        [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray *{
            
            return @[PNLoggerSymbols.api.channelGroupRemovalAttempt,
                     (group ? group : [NSNull null]), [self humanReadableStateFrom:self.state]];
        }];
        
        [self   performAsyncLockingBlock:^{

            // Check whether client is able to send request or not
            NSInteger statusCode = [self requestExecutionPossibilityStatusCode];
            if (statusCode == 0) {

                [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray * {

                    return @[PNLoggerSymbols.api.removingChannelGroup,
                            [self humanReadableStateFrom:self.state]];
                }];

                PNChannelGroupRemoveRequest *request = [PNChannelGroupRemoveRequest requestToRemoveGroup:group];
                if (handlerBlock && !callbackToken) {

                    [self.observationCenter addClientAsChannelGroupRemovalObserverWithToken:request.shortIdentifier
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

                    return @[PNLoggerSymbols.api.channelGroupRemovalImpossible,
                            [self humanReadableStateFrom:self.state]];
                }];

                PNError *requestError = [PNError errorWithCode:statusCode];
                requestError.associatedObject = group;
                [self notifyDelegateAboutChannelGroupRemovalFailedWithError:requestError
                                                           andCallbackToken:callbackToken];

                if (handlerBlock && !callbackToken) {

                    dispatch_async(dispatch_get_main_queue(), ^{

                        handlerBlock(group, requestError);
                    });
                }
            }
        }        postponedExecutionBlock:^{

            [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray * {

                return @[PNLoggerSymbols.api.postponeChannelGroupRemoval,
                        [self humanReadableStateFrom:self.state]];
            }];

            [self postponeRemoveChannelGroup:group rescheduledCallbackToken:callbackToken
                 withCompletionHandlingBlock:handlerBlock];
        } burstExecutionLockingOperation:NO];
    }];
}

- (void)postponeRemoveChannelGroup:(PNChannelGroup *)group
          rescheduledCallbackToken:(NSString *)callbackToken
       withCompletionHandlingBlock:(id)handlerBlock {
    
    SEL targetSelector = @selector(removeChannelGroup:rescheduledCallbackToken:withCompletionHandlingBlock:);
    id handlerBlockCopy = (handlerBlock ? [handlerBlock copy] : nil);
    [self postponeSelector:targetSelector forObject:self
            withParameters:@[[PNHelper nilifyIfNotSet:group],
                             [PNHelper nilifyIfNotSet:callbackToken],
                             [PNHelper nilifyIfNotSet:handlerBlockCopy]]
                outOfOrder:(callbackToken != nil) burstExecutionLock:NO];
}


#pragma mark - Channel group channels request

- (void)requestChannelsForGroup:(PNChannelGroup *)group {
    
    [self requestChannelsForGroup:group withCompletionHandlingBlock:nil];
}

- (void)requestChannelsForGroup:(PNChannelGroup *)group
    withCompletionHandlingBlock:(PNClientChannelsForGroupRequestHandlingBlock)handlerBlock {

    [self requestChannelsForGroup:group rescheduledCallbackToken:nil
      withCompletionHandlingBlock:handlerBlock];
}

- (void)requestChannelsForGroup:(PNChannelGroup *)group rescheduledCallbackToken:(NSString *)callbackToken
    withCompletionHandlingBlock:(PNClientChannelsForGroupRequestHandlingBlock)handlerBlock {
    
    [self pn_dispatchBlock:^{
        
        [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray *{
            
            return @[PNLoggerSymbols.api.channelsForGroupRequestAttempt,
                     (group ? group : [NSNull null]), [self humanReadableStateFrom:self.state]];
        }];
        
        [self   performAsyncLockingBlock:^{

            // Check whether client is able to send request or not
            NSInteger statusCode = [self requestExecutionPossibilityStatusCode];
            if (statusCode == 0) {

                [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray * {

                    return @[PNLoggerSymbols.api.requestChannelsForGroup,
                            [self humanReadableStateFrom:self.state]];
                }];

                PNChannelsForGroupRequest *request = [PNChannelsForGroupRequest channelsRequestForGroup:group];
                if (handlerBlock && !callbackToken) {

                    [self.observationCenter addClientAsChannelsForGroupRequestObserverWithToken:request.shortIdentifier
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

                    return @[PNLoggerSymbols.api.channelsForGroupRequestImpossible,
                            [self humanReadableStateFrom:self.state]];
                }];

                PNError *requestError = [PNError errorWithCode:statusCode];
                requestError.associatedObject = group;

                [self notifyDelegateAboutChannelsForGroupRequestFailedWithError:requestError
                                                               andCallbackToken:callbackToken];

                if (handlerBlock && !callbackToken) {

                    dispatch_async(dispatch_get_main_queue(), ^{

                        handlerBlock(group, requestError);
                    });
                }
            }
        }        postponedExecutionBlock:^{

            [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray * {

                return @[PNLoggerSymbols.api.postponeChannelsForGroupRequest,
                        [self humanReadableStateFrom:self.state]];
            }];

            [self postponeRequestChannelsForGroup:group
                         rescheduledCallbackToken:callbackToken
                      withCompletionHandlingBlock:handlerBlock];
        } burstExecutionLockingOperation:NO];
    }];
}

- (void)postponeRequestChannelsForGroup:(PNChannelGroup *)group
               rescheduledCallbackToken:(NSString *)callbackToken
            withCompletionHandlingBlock:(id)handlerBlock {
    
    SEL targetSelector = @selector(requestChannelsForGroup:rescheduledCallbackToken:withCompletionHandlingBlock:);
    id handlerBlockCopy = (handlerBlock ? [handlerBlock copy] : nil);
    [self postponeSelector:targetSelector forObject:self
            withParameters:@[[PNHelper nilifyIfNotSet:group],
                             [PNHelper nilifyIfNotSet:callbackToken],
                             [PNHelper nilifyIfNotSet:handlerBlockCopy]]
                outOfOrder:(callbackToken != nil) burstExecutionLock:NO];
}


#pragma mark - Channel group channels list manipulation

- (void)addChannels:(NSArray *)channels toGroup:(PNChannelGroup *)group {
    
    [self addChannels:channels toGroup:group withCompletionHandlingBlock:nil];
}

- (void)          addChannels:(NSArray *)channels toGroup:(PNChannelGroup *)group
  withCompletionHandlingBlock:(PNClientChannelsAdditionToGroupHandlingBlock)handlerBlock {

    [self addChannels:channels toGroup:group rescheduledCallbackToken:nil
            withCompletionHandlingBlock:handlerBlock];
}

- (void)        addChannels:(NSArray *)channels toGroup:(PNChannelGroup *)group
   rescheduledCallbackToken:(NSString *)callbackToken
withCompletionHandlingBlock:(PNClientChannelsAdditionToGroupHandlingBlock)handlerBlock {
    
    [self pn_dispatchBlock:^{
        
        [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray *{
            
            return @[PNLoggerSymbols.api.channelsAdditionToGroupAttempt,
                     (channels ? channels : [NSNull null]), (group ? group : [NSNull null]),
                     [self humanReadableStateFrom:self.state]];
        }];
        
        [self   performAsyncLockingBlock:^{

            // Check whether client is able to send request or not
            NSInteger statusCode = [self requestExecutionPossibilityStatusCode];
            if (statusCode == 0) {

                [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray * {

                    return @[PNLoggerSymbols.api.addingChannelsToGroup,
                            [self humanReadableStateFrom:self.state]];
                }];

                PNChannelsListUpdateForChannelGroupRequest *request = [PNChannelsListUpdateForChannelGroupRequest channelsListAddition:channels
                                                                                                                       forChannelGroup:group];
                if (handlerBlock && !callbackToken) {

                    [self.observationCenter addClientAsChannelsAdditionToGroupObserverWithToken:request.shortIdentifier
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

                    return @[PNLoggerSymbols.api.channelsAdditionToGroupImpossible,
                            [self humanReadableStateFrom:self.state]];
                }];

                PNError *requestError = [PNError errorWithCode:statusCode];
                requestError.associatedObject = [PNChannelGroupChange changeForGroup:group
                                                                            channels:channels
                                                                      addingChannels:YES];

                [self notifyDelegateAboutChannelsListChangeFailedWithError:requestError
                                                          andCallbackToken:callbackToken];

                if (handlerBlock && !callbackToken) {

                    dispatch_async(dispatch_get_main_queue(), ^{

                        handlerBlock(group, channels, requestError);
                    });
                }
            }
        }        postponedExecutionBlock:^{

            [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray * {

                return @[PNLoggerSymbols.api.postponeChannelsAdditionToGroup,
                        [self humanReadableStateFrom:self.state]];
            }];

            [self postponeAddChannels:channels toGroup:group
             rescheduledCallbackToken:callbackToken
          withCompletionHandlingBlock:handlerBlock];
        } burstExecutionLockingOperation:NO];
    }];
}

- (void)postponeAddChannels:(NSArray *)channels toGroup:(PNChannelGroup *)group
   rescheduledCallbackToken:(NSString *)callbackToken withCompletionHandlingBlock:(id)handlerBlock {
    
    SEL targetSelector = @selector(addChannels:toGroup:rescheduledCallbackToken:withCompletionHandlingBlock:);
    id handlerBlockCopy = (handlerBlock ? [handlerBlock copy] : nil);
    [self postponeSelector:targetSelector forObject:self
            withParameters:@[[PNHelper nilifyIfNotSet:channels], [PNHelper nilifyIfNotSet:group],
                             [PNHelper nilifyIfNotSet:callbackToken],
                             [PNHelper nilifyIfNotSet:handlerBlockCopy]]
                outOfOrder:(callbackToken != nil) burstExecutionLock:NO];
}

- (void)removeChannels:(NSArray *)channels fromGroup:(PNChannelGroup *)group {
    
    [self removeChannels:channels fromGroup:group withCompletionHandlingBlock:nil];
}

- (void)       removeChannels:(NSArray *)channels fromGroup:(PNChannelGroup *)group
  withCompletionHandlingBlock:(PNClientChannelsRemovalFromGroupHandlingBlock)handlerBlock {

    [self removeChannels:channels fromGroup:group rescheduledCallbackToken:nil
            withCompletionHandlingBlock:handlerBlock];
}

- (void)     removeChannels:(NSArray *)channels fromGroup:(PNChannelGroup *)group
   rescheduledCallbackToken:(NSString *)callbackToken
withCompletionHandlingBlock:(PNClientChannelsRemovalFromGroupHandlingBlock)handlerBlock {
    
    [self pn_dispatchBlock:^{
        
        [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray *{
            
            return @[PNLoggerSymbols.api.channelsRemovalFromGroupAttempt,
                     (channels ? channels : [NSNull null]), (group ? group : [NSNull null]),
                     [self humanReadableStateFrom:self.state]];
        }];
        
        [self   performAsyncLockingBlock:^{

            // Check whether client is able to send request or not
            NSInteger statusCode = [self requestExecutionPossibilityStatusCode];
            if (statusCode == 0) {

                [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray * {

                    return @[PNLoggerSymbols.api.removingChannelsFromGroup,
                            [self humanReadableStateFrom:self.state]];
                }];

                PNChannelsListUpdateForChannelGroupRequest *request = [PNChannelsListUpdateForChannelGroupRequest channelsListRemoval:channels
                                                                                                                      forChannelGroup:group];
                if (handlerBlock && !callbackToken) {

                    [self.observationCenter addClientAsChannelsRemovalFromGroupObserverWithToken:request.shortIdentifier
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

                    return @[PNLoggerSymbols.api.channelsRemovalGroupImpossible,
                            [self humanReadableStateFrom:self.state]];
                }];

                PNError *requestError = [PNError errorWithCode:statusCode];
                requestError.associatedObject = [PNChannelGroupChange changeForGroup:group
                                                                            channels:channels
                                                                      addingChannels:NO];

                [self notifyDelegateAboutChannelsListChangeFailedWithError:requestError
                                                          andCallbackToken:callbackToken];

                if (handlerBlock && !callbackToken) {

                    dispatch_async(dispatch_get_main_queue(), ^{

                        handlerBlock(group, channels, requestError);
                    });
                }
            }
        }        postponedExecutionBlock:^{

            [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray * {

                return @[PNLoggerSymbols.api.postponeChannelsRemovalFromGroup,
                        [self humanReadableStateFrom:self.state]];
            }];

            [self postponeRemoveChannels:channels fromGroup:group
                rescheduledCallbackToken:callbackToken
             withCompletionHandlingBlock:handlerBlock];
        } burstExecutionLockingOperation:NO];
    }];
}

- (void)postponeRemoveChannels:(NSArray *)channels fromGroup:(PNChannelGroup *)group
      rescheduledCallbackToken:(NSString *)callbackToken
   withCompletionHandlingBlock:(id)handlerBlock {
    
    SEL targetSelector = @selector(removeChannels:fromGroup:rescheduledCallbackToken:withCompletionHandlingBlock:);
    id handlerBlockCopy = (handlerBlock ? [handlerBlock copy] : nil);
    [self postponeSelector:targetSelector forObject:self
            withParameters:@[[PNHelper nilifyIfNotSet:channels], [PNHelper nilifyIfNotSet:group],
                             [PNHelper nilifyIfNotSet:callbackToken],
                             [PNHelper nilifyIfNotSet:handlerBlockCopy]]
                outOfOrder:(callbackToken != nil) burstExecutionLock:NO];
}


#pragma mark - Misc methods

- (void)notifyDelegateAboutChannelGroupsRequestFailedWithError:(PNError *)error
                                              andCallbackToken:(NSString *)callbackToken {
    
    [self handleLockingOperationBlockCompletion:^{

        [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray * {

            return @[PNLoggerSymbols.api.channelGroupsRequestFailed,
                    [self humanReadableStateFrom:self.state]];
        }];

        // Check whether delegate us able to handle participants list download error or not
        if ([self.clientDelegate respondsToSelector:@selector(pubnubClient:channelGroupsRequestDidFailWithError:)]) {

            dispatch_async(dispatch_get_main_queue(), ^{

                [self.clientDelegate pubnubClient:self channelGroupsRequestDidFailWithError:error];
            });
        }

        [self sendNotification:kPNClientChannelGroupsRequestDidFailWithErrorNotification
                    withObject:error andCallbackToken:callbackToken];
    }                           shouldStartNext:YES burstExecutionLockingOperation:NO];
}

- (void)notifyDelegateAboutChannelGroupNamespacesRequestFailedWithError:(PNError *)error
                                                       andCallbackToken:(NSString *)callbackToken {
    
    [self handleLockingOperationBlockCompletion:^{

        [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray * {

            return @[PNLoggerSymbols.api.channelGroupNamespacesRetrievalFailed,
                    [self humanReadableStateFrom:self.state]];
        }];

        // Check whether delegate us able to handle participants list download error or not
        if ([self.clientDelegate respondsToSelector:@selector(pubnubClient:channelGroupNamespacesRequestDidFailWithError:)]) {

            dispatch_async(dispatch_get_main_queue(), ^{

                [self.clientDelegate pubnubClient:self channelGroupNamespacesRequestDidFailWithError:error];
            });
        }

        [self sendNotification:kPNClientChannelGroupNamespacesRequestDidFailWithErrorNotification
                    withObject:error andCallbackToken:callbackToken];
    }                           shouldStartNext:YES burstExecutionLockingOperation:NO];
}

- (void)notifyDelegateAboutChannelGroupNamespaceRemovalFailedWithError:(PNError *)error
                                                      andCallbackToken:(NSString *)callbackToken {
    
    [self handleLockingOperationBlockCompletion:^{

        [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray * {

            return @[PNLoggerSymbols.api.channelGroupNamespaceRemovalFailed,
                    [self humanReadableStateFrom:self.state]];
        }];

        // Check whether delegate us able to handle participants list download error or not
        if ([self.clientDelegate respondsToSelector:@selector(pubnubClient:namespaceRemovalDidFailWithError:)]) {

            dispatch_async(dispatch_get_main_queue(), ^{

                [self.clientDelegate pubnubClient:self namespaceRemovalDidFailWithError:error];
            });
        }

        [self sendNotification:kPNClientChannelGroupNamespaceRemovalDidFailWithErrorNotification
                    withObject:error andCallbackToken:callbackToken];
    }                           shouldStartNext:YES burstExecutionLockingOperation:NO];
}

- (void)notifyDelegateAboutChannelGroupRemovalFailedWithError:(PNError *)error
                                             andCallbackToken:(NSString *)callbackToken {
    
    [self handleLockingOperationBlockCompletion:^{

        [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray * {

            return @[PNLoggerSymbols.api.channelGroupRemovalFailed,
                    [self humanReadableStateFrom:self.state]];
        }];

        // Check whether delegate us able to handle participants list download error or not
        if ([self.clientDelegate respondsToSelector:@selector(pubnubClient:channelGroupRemovalDidFailWithError:)]) {

            dispatch_async(dispatch_get_main_queue(), ^{

                [self.clientDelegate pubnubClient:self channelGroupRemovalDidFailWithError:error];
            });
        }

        [self sendNotification:kPNClientChannelGroupRemovalDidFailWithErrorNotification
                    withObject:error andCallbackToken:callbackToken];
    }                           shouldStartNext:YES burstExecutionLockingOperation:NO];
}

- (void)notifyDelegateAboutChannelsForGroupRequestFailedWithError:(PNError *)error
                                                 andCallbackToken:(NSString *)callbackToken {
    
    [self handleLockingOperationBlockCompletion:^{

        [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray * {

            return @[PNLoggerSymbols.api.channelsForGroupRequestFailed,
                    [self humanReadableStateFrom:self.state]];
        }];

        // Check whether delegate us able to handle participants list download error or not
        if ([self.clientDelegate respondsToSelector:@selector(pubnubClient:channelsForGroupRequestDidFailWithError:)]) {

            dispatch_async(dispatch_get_main_queue(), ^{

                [self.clientDelegate pubnubClient:self channelsForGroupRequestDidFailWithError:error];
            });
        }

        [self sendNotification:kPNClientChannelsForGroupRequestDidFailWithErrorNotification
                    withObject:error andCallbackToken:callbackToken];
    }                           shouldStartNext:YES burstExecutionLockingOperation:NO];
}

- (void)notifyDelegateAboutChannelsListChangeFailedWithError:(PNError *)error
                                            andCallbackToken:(NSString *)callbackToken {
    
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

        [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray * {

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

        [self sendNotification:notification withObject:error andCallbackToken:callbackToken];
    }                           shouldStartNext:YES burstExecutionLockingOperation:NO];
}


#pragma mark - Service channel delegate methods

- (void)serviceChannel:(PNServiceChannel *)channel didReceiveChannelGroups:(NSArray *)channelGroups
          forNamespace:(NSString *)nspace onRequest:(PNBaseRequest *)request {

    void(^handlingBlock)(BOOL) = ^(BOOL shouldNotify){

        [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray *{

            return @[PNLoggerSymbols.api.channelGroupsRequestCompleted,
                     [self humanReadableStateFrom:self.state]];
        }];

        if (shouldNotify) {

            // Check whether delegate can response on participants list download event or not
            if ([self.clientDelegate respondsToSelector:@selector(pubnubClient:didReceiveChannelGroups:forNamespace:)]) {

                dispatch_async(dispatch_get_main_queue(), ^{

                    [self.clientDelegate pubnubClient:self didReceiveChannelGroups:channelGroups
                                         forNamespace:nspace];
                });
            }

            id notificationObject = channelGroups;
            if (nspace) {

                notificationObject = @{nspace:channelGroups};
            }

            [self sendNotification:kPNClientChannelGroupsRequestCompleteNotification
                        withObject:notificationObject andCallbackToken:request.shortIdentifier];
        }
    };

    [self checkShouldChannelNotifyAboutEvent:channel withBlock:^(BOOL shouldNotify) {

        [self handleLockingOperationBlockCompletion:^{

            handlingBlock(shouldNotify);
        }                           shouldStartNext:YES burstExecutionLockingOperation:NO];
    }];
}

- (void)serviceChannel:(PNServiceChannel *)channel channelGroupsRequestForNamespace:(NSString *)nspace
      didFailWithError:(PNError *)error forRequest:(PNBaseRequest *)request {

    NSString *callbackToken = request.shortIdentifier;
    if (error.code != kPNRequestCantBeProcessedWithOutRescheduleError) {
        
        [error replaceAssociatedObject:nspace];
        [self notifyDelegateAboutChannelGroupsRequestFailedWithError:error
                                                    andCallbackToken:callbackToken];
    }
    else {
        
        [self rescheduleMethodCall:^{
            
            [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray *{
                
                return @[PNLoggerSymbols.api.rescheduleChannelGroupsRequest,
                         [self humanReadableStateFrom:self.state]];
            }];

            [self requestChannelGroupsForNamespace:nspace rescheduledCallbackToken:callbackToken
                       withCompletionHandlingBlock:nil];
        }];
    }
}

- (void)            serviceChannel:(PNServiceChannel *)channel
  didReceiveChannelGroupNamespaces:(NSArray *)namespaces
                         onRequest:(PNBaseRequest *)request {

    void(^handlingBlock)(BOOL) = ^(BOOL shouldNotify){

        [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray *{

            return @[PNLoggerSymbols.api.channelGroupNamespacesRetrievalCompleted,
                     [self humanReadableStateFrom:self.state]];
        }];

        if (shouldNotify) {

            if ([self.clientDelegate respondsToSelector:@selector(pubnubClient:didReceiveChannelGroupNamespaces:)]) {

                dispatch_async(dispatch_get_main_queue(), ^{

                    [self.clientDelegate pubnubClient:self didReceiveChannelGroupNamespaces:namespaces];
                });
            }

            [self sendNotification:kPNClientChannelGroupNamespacesRequestCompleteNotification
                        withObject:namespaces andCallbackToken:request.shortIdentifier];
        }
    };

    [self checkShouldChannelNotifyAboutEvent:channel withBlock:^(BOOL shouldNotify) {

        [self handleLockingOperationBlockCompletion:^{

            handlingBlock(shouldNotify);
        }                           shouldStartNext:YES burstExecutionLockingOperation:NO];
    }];
}

- (void)                         serviceChannel:(PNServiceChannel *)channel
  channelGroupNamespacesRequestDidFailWithError:(PNError *)error
                                     forRequest:(PNBaseRequest *)request {

    NSString *callbackToken = request.shortIdentifier;
    if (error.code != kPNRequestCantBeProcessedWithOutRescheduleError) {
        
        [self notifyDelegateAboutChannelGroupNamespacesRequestFailedWithError:error
                                                             andCallbackToken:callbackToken];
    }
    else {
        
        [self rescheduleMethodCall:^{
            
            [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray *{
                
                return @[PNLoggerSymbols.api.rescheduleChannelGroupNamespacesRetrieval,
                         [self humanReadableStateFrom:self.state]];
            }];

            [self requestChannelGroupNamespacesWithRescheduledCallbackToken:callbackToken
                                                 andCompletionHandlingBlock:nil];
        }];
    }
}

- (void)serviceChannel:(PNServiceChannel *)channel didRemoveNamespace:(NSString *)nspace
             onRequest:(PNBaseRequest *)request {

    void(^handlingBlock)(BOOL) = ^(BOOL shouldNotify){

        [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray *{

            return @[PNLoggerSymbols.api.channelGroupNamespaceRemovalCompleted,
                     [self humanReadableStateFrom:self.state]];
        }];

        if (shouldNotify) {

            if ([self.clientDelegate respondsToSelector:@selector(pubnubClient:didRemoveNamespace:)]) {

                dispatch_async(dispatch_get_main_queue(), ^{

                    [self.clientDelegate pubnubClient:self didRemoveNamespace:nspace];
                });
            }

            [self sendNotification:kPNClientChannelGroupNamespaceRemovalCompleteNotification
                        withObject:nspace andCallbackToken:request.shortIdentifier];
        }
    };

    [self checkShouldChannelNotifyAboutEvent:channel withBlock:^(BOOL shouldNotify) {

        [self handleLockingOperationBlockCompletion:^{

            handlingBlock(shouldNotify);
        }                           shouldStartNext:YES burstExecutionLockingOperation:NO];
    }];
}

- (void)serviceChannel:(PNServiceChannel *)channel namespace:(NSString *)nspace
        removalDidFailWithError:(PNError *)error forRequest:(PNBaseRequest *)request {

    NSString *callbackToken = request.shortIdentifier;
    if (error.code != kPNRequestCantBeProcessedWithOutRescheduleError) {
        
        [error replaceAssociatedObject:nspace];
        [self notifyDelegateAboutChannelGroupNamespaceRemovalFailedWithError:error
                                                            andCallbackToken:callbackToken];
    }
    else {
        
        [self rescheduleMethodCall:^{
            
            [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray *{
                
                return @[PNLoggerSymbols.api.rescheduleChannelGroupNamespaceRemoval,
                         [self humanReadableStateFrom:self.state]];
            }];

            [self removeChannelGroupNamespace:nspace rescheduledCallbackToken:callbackToken
                  withCompletionHandlingBlock:nil];
        }];
    }
}

- (void)serviceChannel:(PNServiceChannel *)channel didRemoveChannelGroup:(PNChannelGroup *)group
             onRequest:(PNBaseRequest *)request {

    void(^handlingBlock)(BOOL) = ^(BOOL shouldNotify){

        [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray *{

            return @[PNLoggerSymbols.api.channelGroupRemovalCompleted,
                     [self humanReadableStateFrom:self.state]];
        }];

        if (shouldNotify) {

            if ([self.clientDelegate respondsToSelector:@selector(pubnubClient:didRemoveChannelGroup:)]) {

                dispatch_async(dispatch_get_main_queue(), ^{

                    [self.clientDelegate pubnubClient:self didRemoveChannelGroup:group];
                });
            }

            [self sendNotification:kPNClientChannelGroupRemovalCompleteNotification
                        withObject:group andCallbackToken:request.shortIdentifier];
        }
    };

    [self checkShouldChannelNotifyAboutEvent:channel withBlock:^(BOOL shouldNotify) {

        [self handleLockingOperationBlockCompletion:^{

            handlingBlock(shouldNotify);
        }                           shouldStartNext:YES burstExecutionLockingOperation:NO];
    }];
}

- (void)serviceChannel:(PNServiceChannel *)channel channelGroup:(PNChannelGroup *)group
        removalDidFailWithError:(PNError *)error forRequest:(PNBaseRequest *)request {

    NSString *callbackToken = request.shortIdentifier;
    if (error.code != kPNRequestCantBeProcessedWithOutRescheduleError) {
        
        [self notifyDelegateAboutChannelGroupRemovalFailedWithError:error
                                                   andCallbackToken:callbackToken];
    }
    else {
        
        [self rescheduleMethodCall:^{
            
            [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray *{
                
                return @[PNLoggerSymbols.api.rescheduleChannelGroupRemoval,
                         [self humanReadableStateFrom:self.state]];
            }];

            [self removeChannelGroup:group rescheduledCallbackToken:callbackToken
         withCompletionHandlingBlock:nil];
        }];
    }
}

- (void)serviceChannel:(PNServiceChannel *)channel didReceiveChannels:(NSArray *)channels
              forGroup:(PNChannelGroup *)group onRequest:(PNBaseRequest *)request {

    void(^handlingBlock)(BOOL) = ^(BOOL shouldNotify){

        [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray *{

            return @[PNLoggerSymbols.api.channelsForGroupRequestCompleted,
                     [self humanReadableStateFrom:self.state]];
        }];

        if (shouldNotify) {

            group.channels = channels;

            // Check whether delegate can response on participants list download event or not
            if ([self.clientDelegate respondsToSelector:@selector(pubnubClient:didReceiveChannelsForGroup:)]) {

                dispatch_async(dispatch_get_main_queue(), ^{

                    [self.clientDelegate pubnubClient:self didReceiveChannelsForGroup:group];
                });
            }

            [self sendNotification:kPNClientChannelsForGroupRequestCompleteNotification
                        withObject:group andCallbackToken:request.shortIdentifier];
        }
    };

    [self checkShouldChannelNotifyAboutEvent:channel withBlock:^(BOOL shouldNotify) {

        [self handleLockingOperationBlockCompletion:^{

            handlingBlock(shouldNotify);
        }                           shouldStartNext:YES burstExecutionLockingOperation:NO];
    }];
}

- (void)serviceChannel:(PNServiceChannel *)channel channelsForGroupRequest:(PNChannelGroup *)group
      didFailWithError:(PNError *)error forRequest:(PNBaseRequest *)request {

    NSString *callbackToken = request.shortIdentifier;
    if (error.code != kPNRequestCantBeProcessedWithOutRescheduleError) {
        
        [self notifyDelegateAboutChannelsForGroupRequestFailedWithError:error
                                                       andCallbackToken:callbackToken];
    }
    else {
        
        [self rescheduleMethodCall:^{
            
            [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray *{
                
                return @[PNLoggerSymbols.api.rescheduleChannelsForGroupRequest,
                         [self humanReadableStateFrom:self.state]];
            }];

            [self requestChannelsForGroup:group rescheduledCallbackToken:callbackToken
              withCompletionHandlingBlock:nil];
        }];
    }
}

- (void)serviceChannel:(PNServiceChannel *)channel didChangeGroupChannels:(PNChannelGroupChange *)change
             onRequest:(PNBaseRequest *)request {

    void(^handlingBlock)(BOOL) = ^(BOOL shouldNotify){

        NSString *symbol = ([change addingChannels] ?
                              PNLoggerSymbols.api.channelsAdditionToGroupCompleted :
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

                        [self.clientDelegate pubnubClient:self didAddChannels:change.channels
                                                  toGroup:change.group];
                    }
                    else {

                        [self.clientDelegate pubnubClient:self didRemoveChannels:change.channels
                                                fromGroup:change.group];
                    }

                });
            }

            [self sendNotification:notification withObject:change
                  andCallbackToken:request.shortIdentifier];
        }
    };

    [self checkShouldChannelNotifyAboutEvent:channel withBlock:^(BOOL shouldNotify) {

        [self handleLockingOperationBlockCompletion:^{

            handlingBlock(shouldNotify);
        }                           shouldStartNext:YES burstExecutionLockingOperation:NO];
    }];
}

- (void)serviceChannel:(PNServiceChannel *)channel groupChannelsChange:(PNChannelGroupChange *)change
      didFailWithError:(PNError *)error forRequest:(PNBaseRequest *)request {

    NSString *callbackToken = request.shortIdentifier;
    if (error.code != kPNRequestCantBeProcessedWithOutRescheduleError) {
        
        [error replaceAssociatedObject:change];
        [self notifyDelegateAboutChannelsListChangeFailedWithError:error
                                                  andCallbackToken:callbackToken];
    }
    else {
        
        [self rescheduleMethodCall:^{
            
            NSString *symbol = ([change addingChannels] ?
                                  PNLoggerSymbols.api.rescheduleChannelsAdditionToGroup :
                                  PNLoggerSymbols.api.rescheduleChannelsRemovalFromGroup);
            [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray *{
                
                return @[symbol, [self humanReadableStateFrom:self.state]];
            }];
            
            if ([change addingChannels]) {

                [self addChannels:change.channels toGroup:change.group
         rescheduledCallbackToken:callbackToken withCompletionHandlingBlock:nil];
            }
            else {

                [self removeChannels:change.channels fromGroup:change.group
            rescheduledCallbackToken:callbackToken withCompletionHandlingBlock:nil];
            }
        }];
    }
}

#pragma mark -


@end
