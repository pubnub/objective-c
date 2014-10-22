#import "PubNub.h"

/**
 Base class extension which provide methods for channels registry manipulation. This feature allow to combine set of channels
 under unique name which will be used during subscription process.
 
 @author Sergey Mamontov
 @version 3.7.0
 @copyright © 2009-13 PubNub Inc.
 */
@interface PubNub (ChannelRegistry)


#pragma mark - Instance methods

#pragma mark - Channel groups request

/**
 Retrieve list of channel groups which has been registered for all application users (identifier by subscription key).
 
 @code
 @endcode
 \b Example:
 
 @code
 PubNub *pubNub = [PubNub clientWithConfiguration:[PNConfiguration defaultConfiguration] andDelegate:self];
 [pubNub connect];
 [pubNub requestDefaultChannelGroups];
 @endcode
 
 And handle it with delegates:
 @code
- (void)pubnubClient:(PubNub *)client didReceiveChannelGroups:(NSArray *)groups forNamespace:(NSString *)nspace {
 
     // PubNub client received list of channel groups inside specified namespace or application wide.
 }
 
 - (void)pubnubClient:(PubNub *)client channelGroupsRequestDidFailWithError:(PNError *)error {
 
     // PubNub client did fail to retrieve list of channel groups inside specified namespace or application wide.
     //
     // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
     // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
     // 'error.associatedObject' contains name of namespace for which channel groups has been requested (will be nil in case
     // if request has been application wide).
 }
 @endcode
 
 There is also way to observe channel groups request process state from any place in your application using  \b PNObservationCenter:
 @code
 [pubNub.observationCenter addChannelGroupsRequestObserver:self
                                         withCallbackBlock:^(NSString *nspace, NSArray *groups, PNError *error) {
 
     if (!error) {
     
         // PubNub client received list of channel groups inside specified namespace or application wide.
     }
     else {
         
         // PubNub client did fail to retrieve list of channel groups inside specified namespace or application wide.
         //
         // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
         // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
         // 'error.associatedObject' contains name of namespace for which channel groups has been requested (will be nil in case
         // if request has been application wide).
     }
 }];
 @endcode
 
 Also observation can be done using \b NSNotificationCenter to observe this notifications: kPNClientChannelGroupsRequestCompleteNotification,
 kPNClientChannelGroupsRequestDidFailWithErrorNotification.
 
 @since 3.7.0
 */
- (void)requestDefaultChannelGroups;

/**
 Retrieve list of channel groups which has been registered for all application users (identifier by subscription key).
 
 @code
 @endcode
 This method extends \a -requestDefaultChannelGroups and allow to specify groups request process state change handler block.
 
 @code
 @endcode
 \b Example:
 
 @code
 PubNub *pubNub = [PubNub clientWithConfiguration:[PNConfiguration defaultConfiguration] andDelegate:self];
 [pubNub connect];
 [pubNub requestDefaultChannelGroupsWithCompletionHandlingBlock:^(NSString *nspace, NSArray *groups, PNError *error) {
 
     if (!error) {
     
         // PubNub client received list of channel groups inside specified namespace or application wide.
     }
     else {
         
         // PubNub client did fail to retrieve list of channel groups inside specified namespace or application wide.
         //
         // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
         // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
         // 'error.associatedObject' contains name of namespace for which channel groups has been requested (will be nil in case
         // if request has been application wide).
     }
 }];
 @endcode
 
 And handle it with delegates:
 @code
- (void)pubnubClient:(PubNub *)client didReceiveChannelGroups:(NSArray *)groups forNamespace:(NSString *)nspace {
 
     // PubNub client received list of channel groups inside specified namespace or application wide.
 }
 
 - (void)pubnubClient:(PubNub *)client channelGroupsRequestDidFailWithError:(PNError *)error {
 
     // PubNub client did fail to retrieve list of channel groups inside specified namespace or application wide.
     //
     // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
     // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
     // 'error.associatedObject' contains name of namespace for which channel groups has been requested (will be nil in case
     // if request has been application wide).
 }
 @endcode
 
 There is also way to observe channel groups request process state from any place in your application using  \b PNObservationCenter:
 @code
 [pubNub.observationCenter addChannelGroupsRequestObserver:self
                                         withCallbackBlock:^(NSString *nspace, NSArray *groups, PNError *error) {
 
     if (!error) {
     
         // PubNub client received list of channel groups inside specified namespace or application wide.
     }
     else {
         
         // PubNub client did fail to retrieve list of channel groups inside specified namespace or application wide.
         //
         // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
         // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
         // 'error.associatedObject' contains name of namespace for which channel groups has been requested (will be nil in case
         // if request has been application wide).
     }
 }];
 @endcode
 
 Also observation can be done using \b NSNotificationCenter to observe this notifications: kPNClientChannelGroupsRequestCompleteNotification,
 kPNClientChannelGroupsRequestDidFailWithErrorNotification.
 
 @param handlerBlock
 The block which will be called by \b PubNub client as soon as channel groups request operation will be completed.
 The block takes three arguments:
 \c namespace - namespace from which channel groups requested; \c groups - list of \b PNChannelGroup describing channel group
 inside of namespace; \c error - describes what exactly went wrong (check error code and compare it with \b PNErrorCodes ).
 
 @since 3.7.0
 */
- (void)requestDefaultChannelGroupsWithCompletionHandlingBlock:(PNClientChannelGroupsRequestHandlingBlock)handlerBlock;

/**
 Retrieve list of channel groups which has been registered for all application users (identifier by subscription key).
 
 @code
 @endcode
 This method extends \a -requestDefaultChannelGroups and allow to specify concrete namespace from which channel groups should be retrieved.
 
 @code
 @endcode
 \b Example:
 
 @code
 PubNub *pubNub = [PubNub clientWithConfiguration:[PNConfiguration defaultConfiguration] andDelegate:self];
 [pubNub connect];
 [pubNub requestChannelGroupsForNamespace:@"user-desk"];
 @endcode
 
 And handle it with delegates:
 @code
- (void)pubnubClient:(PubNub *)client didReceiveChannelGroups:(NSArray *)groups forNamespace:(NSString *)nspace {
 
     // PubNub client received list of channel groups inside specified namespace or application wide.
 }
 
 - (void)pubnubClient:(PubNub *)client channelGroupsRequestDidFailWithError:(PNError *)error {
 
     // PubNub client did fail to retrieve list of channel groups inside specified namespace or application wide.
     //
     // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
     // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
     // 'error.associatedObject' contains name of namespace for which channel groups has been requested (will be nil in case
     // if request has been application wide).
 }
 @endcode
 
 There is also way to observe channel groups request process state from any place in your application using  \b PNObservationCenter:
 @code
 [pubNub.observationCenter addChannelGroupsRequestObserver:self
                                         withCallbackBlock:^(NSString *nspace, NSArray *groups, PNError *error) {
 
     if (!error) {
     
         // PubNub client received list of channel groups inside specified namespace or application wide.
     }
     else {
         
         // PubNub client did fail to retrieve list of channel groups inside specified namespace or application wide.
         //
         // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
         // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
         // 'error.associatedObject' contains name of namespace for which channel groups has been requested (will be nil in case
         // if request has been application wide).
     }
 }];
 @endcode
 
 Also observation can be done using \b NSNotificationCenter to observe this notifications: kPNClientChannelGroupsRequestCompleteNotification,
 kPNClientChannelGroupsRequestDidFailWithErrorNotification.
 
 @param nspace
 Namespace name from which channel groups should be retrieved.
 
 @since 3.7.0
 */
- (void)requestChannelGroupsForNamespace:(NSString *)nspace;

/**
 Retrieve list of channel groups which has been registered for all application users (identifier by subscription key).
 
 @code
 @endcode
 This method extends \a -requestChannelGroupsForNamespace: and allow to specify groups request process state change handler block.
 
 @code
 @endcode
 \b Example:
 
 @code
 PubNub *pubNub = [PubNub clientWithConfiguration:[PNConfiguration defaultConfiguration] andDelegate:self];
 [pubNub connect];
 [pubNub requestChannelGroupsForNamespace:@"user-desk" 
              withCompletionHandlingBlock:^(NSString *nspace, NSArray *groups, PNError *error) {
 
     if (!error) {
     
         // PubNub client received list of channel groups inside specified namespace or application wide.
     }
     else {
         
         // PubNub client did fail to retrieve list of channel groups inside specified namespace or application wide.
         //
         // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
         // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
         // 'error.associatedObject' contains name of namespace for which channel groups has been requested (will be nil in case
         // if request has been application wide).
     }
 }];
 @endcode
 
 And handle it with delegates:
 @code
- (void)pubnubClient:(PubNub *)client didReceiveChannelGroups:(NSArray *)groups forNamespace:(NSString *)nspace {
 
     // PubNub client received list of channel groups inside specified namespace or application wide.
 }
 
 - (void)pubnubClient:(PubNub *)client channelGroupsRequestDidFailWithError:(PNError *)error {
 
     // PubNub client did fail to retrieve list of channel groups inside specified namespace or application wide.
     //
     // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
     // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
     // 'error.associatedObject' contains name of namespace for which channel groups has been requested (will be nil in case
     // if request has been application wide).
 }
 @endcode
 
 There is also way to observe channel groups request process state from any place in your application using  \b PNObservationCenter:
 @code
 [pubNub.observationCenter addChannelGroupsRequestObserver:self
                                         withCallbackBlock:^(NSString *nspace, NSArray *groups, PNError *error) {
 
     if (!error) {
     
         // PubNub client received list of channel groups inside specified namespace or application wide.
     }
     else {
         
         // PubNub client did fail to retrieve list of channel groups inside specified namespace or application wide.
         //
         // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
         // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
         // 'error.associatedObject' contains name of namespace for which channel groups has been requested (will be nil in case
         // if request has been application wide).
     }
 }];
 @endcode
 
 Also observation can be done using \b NSNotificationCenter to observe this notifications: kPNClientChannelGroupsRequestCompleteNotification,
 kPNClientChannelGroupsRequestDidFailWithErrorNotification.
 
 @param nspace
 Namespace name from which channel groups should be retrieved.
 
 @param handlerBlock
 The block which will be called by \b PubNub client as soon as channel groups request operation will be completed.
 The block takes three arguments:
 \c namespace - namespace from which channel groups requested; \c groups - list of \b PNChannelGroup describing channel group
 inside of namespace; \c error - describes what exactly went wrong (check error code and compare it with \b PNErrorCodes ).
 
 @since 3.7.0
 */
- (void)requestChannelGroupsForNamespace:(NSString *)nspace
             withCompletionHandlingBlock:(PNClientChannelGroupsRequestHandlingBlock)handlerBlock;


#pragma mark - Namespace / group panimulation

/**
 Retrieve list of all namespaces which has been created under application subscribe key.
 
 @code
 @endcode
 \b Example:
 
 @code
 PubNub *pubNub = [PubNub clientWithConfiguration:[PNConfiguration defaultConfiguration] andDelegate:self];
 [pubNub connect];
 [pubNub requestChannelGroupNamespaces];
 @endcode
 
 And handle it with delegates:
 @code
 - (void)pubnubClient:(PubNub *)client didReceiveChannelGroupNamespaces:(NSArray *)namespaces {
 
     // PubNub client received list of namespaces which is registered under current subscribe key.
 }
 
 - (void)pubnubClient:(PubNub *)client channelGroupNamespacesRequestDidFailWithError:(PNError *)error {
 
     // PubNub client did fail to retrieve list of namespaces.
     //
     // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
     // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
 }
 @endcode
 
 There is also way to observe channel group namespaces request process state from any place in your application using  \b PNObservationCenter:
 @code
 [pubNub.observationCenter addChannelGroupNamespacesRequestObserver:self withCallbackBlock:^(NSArray *namespaces, PNError *error) {
 
     if (!error) {
     
         // PubNub client received list of namespaces which is registered under current subscribe key.
     }
     else {
     
         // PubNub client did fail to retrieve list of namespaces.
         //
         // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
         // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
     }
 }];
 @endcode
 
 Also observation can be done using \b NSNotificationCenter to observe this notifications: kPNClientChannelGroupNamespacesRequestCompleteNotification,
 kPNClientChannelGroupNamespacesRequestDidFailWithErrorNotification.
 
 @since 3.7.0
 */
- (void)requestChannelGroupNamespaces;

/**
 Retrieve list of all namespaces which has been created under application subscribe key.
 
 @code
 @endcode
 This method extends \a -requestChannelGroupNamespaces and allow to specify channel group namespaces retrieval process handler block.
 
 @code
 @endcode
 \b Example:
 
 @code
 PubNub *pubNub = [PubNub clientWithConfiguration:[PNConfiguration defaultConfiguration] andDelegate:self];
 [pubNub connect];
 [pubNub requestChannelGroupNamespaces];
 @endcode
 
 And handle it with delegates:
 @code
 - (void)pubnubClient:(PubNub *)client didReceiveChannelGroupNamespaces:(NSArray *)namespaces {
 
     // PubNub client received list of namespaces which is registered under current subscribe key.
 }
 
 - (void)pubnubClient:(PubNub *)client channelGroupNamespacesRequestDidFailWithError:(PNError *)error {
 
     // PubNub client did fail to retrieve list of namespaces.
     //
     // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
     // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
 }
 @endcode
 
 There is also way to observe channel group namespaces request process state from any place in your application using  \b PNObservationCenter:
 @code
 [pubNub.observationCenter addChannelGroupNamespacesRequestObserver:self withCallbackBlock:^(NSArray *namespaces, PNError *error) {
 
     if (!error) {
     
         // PubNub client received list of namespaces which is registered under current subscribe key.
     }
     else {
     
         // PubNub client did fail to retrieve list of namespaces.
         //
         // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
         // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
     }
 }];
 @endcode
 
 Also observation can be done using \b NSNotificationCenter to observe this notifications: kPNClientChannelGroupNamespacesRequestCompleteNotification,
 kPNClientChannelGroupNamespacesRequestDidFailWithErrorNotification.
 
 @param handlerBlock
 The block which will be called by \b PubNub client as soon as namespace list pulled for channel group (all available namespaces 
 under which channel group can be registered). The block takes two arguments:
 \c namespaces - list of namespaces which has been created to store registered channel groups; \c error - describes what
 exactly went wrong (check error code and compare it with \b PNErrorCodes ).
 
 @since 3.7.0
 */
- (void)requestChannelGroupNamespacesWithCompletionHandlingBlock:(PNClientChannelGroupNamespacesRequestHandlingBlock)handlerBlock;

/**
 Remove one of channel group namespaces from channel registry. All channel groups and channels which has been registered and 
 added to target namespace will be deleted as well.
 
 @code
 @endcode
 \b Example:
 
 @code
 PubNub *pubNub = [PubNub clientWithConfiguration:[PNConfiguration defaultConfiguration] andDelegate:self];
 [pubNub connect];
 [pubNub removeChannelGroupNamespace:@"adroid"];
 
 And handle it with delegates:
 @code
 - (void)pubnubClient:(PubNub *)client didRemoveNamespace:(NSString *)nspace {
 
     // PubNub client successfully removed channel group namespace.
 }
 
 - (void)pubnubClient:(PubNub *)client namespaceRemovalDidFailWithError:(PNError *)error {
 
     // PubNub client did fail to remove channel group namespace.
     //
     // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
     // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
     // 'error.associatedObject' stores reference on namespace name which client tried to remove.
 }
 @endcode
 
 There is also way to observe channel group namespace removal process state from any place in your application using  \b PNObservationCenter:
 @code
 [pubNub.observationCenter addChannelGroupNamespaceRemovalObserver:self withCallbackBlock:^(NSString *namespace, PNError *error) {
 
     if (!error) {
     
         // PubNub client successfully removed channel group namespace.
     }
     else {
     
         // PubNub client did fail to remove channel group namespace.
         //
         // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
         // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
         // 'error.associatedObject' stores reference on namespace name which client tried to remove.
     }
 }];
 @endcode
 
 Also observation can be done using \b NSNotificationCenter to observe this notifications: kPNClientChannelGroupNamespaceRemovalCompleteNotification,
 kPNClientChannelGroupNamespaceRemovalDidFailWithErrorNotification.
 
 @param nspace
 Reference on namespace name which should be removed along with all channel group and channels registered in it.
 
 @since 3.7.0
 */
- (void)removeChannelGroupNamespace:(NSString *)nspace;

/**
 Remove one of channel group namespaces from channel registry. All channel groups and channels which has been registered and 
 added to target namespace will be deleted as well.
 
 @code
 @endcode
 This method extends \a -removeChannelGroupNamespace: and allow to specify channel group namespaces removal process handler block.
 
 @code
 @endcode
 \b Example:
 
 @code
 PubNub *pubNub = [PubNub clientWithConfiguration:[PNConfiguration defaultConfiguration] andDelegate:self];
 [pubNub connect];
 [pubNub removeChannelGroupNamespace:@"adroid" withCompletionHandlingBlock:^(NSString *namespace, PNError *error) {
 
     if (!error) {
     
         // PubNub client successfully removed channel group namespace.
     }
     else {
     
         // PubNub client did fail to remove channel group namespace.
         //
         // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
         // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
         // 'error.associatedObject' stores reference on namespace name which client tried to remove.
     }
 }];
 
 And handle it with delegates:
 @code
 - (void)pubnubClient:(PubNub *)client didRemoveNamespace:(NSString *)nspace {
 
     // PubNub client successfully removed channel group namespace.
 }
 
 - (void)pubnubClient:(PubNub *)client namespaceRemovalDidFailWithError:(PNError *)error {
 
     // PubNub client did fail to remove channel group namespace.
     //
     // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
     // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
     // 'error.associatedObject' stores reference on namespace name which client tried to remove.
 }
 @endcode
 
 There is also way to observe channel group namespace removal process state from any place in your application using  \b PNObservationCenter:
 @code
 [pubNub.observationCenter addChannelGroupNamespaceRemovalObserver:self withCallbackBlock:^(NSString *namespace, PNError *error) {
 
     if (!error) {
     
         // PubNub client successfully removed channel group namespace.
     }
     else {
     
         // PubNub client did fail to remove channel group namespace.
         //
         // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
         // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
         // 'error.associatedObject' stores reference on namespace name which client tried to remove.
     }
 }];
 @endcode
 
 Also observation can be done using \b NSNotificationCenter to observe this notifications: kPNClientChannelGroupNamespaceRemovalCompleteNotification,
 kPNClientChannelGroupNamespaceRemovalDidFailWithErrorNotification.
 
 @param nspace
 Reference on namespace name which should be removed along with all channel group and channels registered in it.
 
 @param handlerBlock
 The block which will be called by \b PubNub client as soon as namespace removal process will be completed. The block takes two arguments:
 \c namespace - namespace name which should be removed; \c error - describes what exactly went wrong (check error code 
 and compare it with \b PNErrorCodes ).
 
 @since 3.7.0
 */
- (void)removeChannelGroupNamespace:(NSString *)nspace withCompletionHandlingBlock:(PNClientChannelGroupNamespaceRemoveHandlingBlock)handlerBlock;

/**
 Remove one of channel groups from channel registry. All channels which has been registered in it also will be removed.
 
 @code
 @endcode
 \b Example:
 
 @code
 PubNub *pubNub = [PubNub clientWithConfiguration:[PNConfiguration defaultConfiguration] andDelegate:self];
 [pubNub connect];
 [pubNub removeChannelGroup:[PNChannelGroup channelGroupWithName:@"android" inNamespace:@"users"]];
 
 And handle it with delegates:
 @code
 - (void)pubnubClient:(PubNub *)client didRemoveNamespace:(NSString *)nspace {
 
     // PubNub client successfully removed channel group.
 }
 
 - (void)pubnubClient:(PubNub *)client namespaceRemovalDidFailWithError:(PNError *)error {
 
     // PubNub client did fail to remove channel group.
     //
     // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
     // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
     // 'error.associatedObject' stores reference on PNChannelGroup which describe group which clinent tried to remove.
 }
 @endcode
 
 There is also way to observe channel group namespace removal process state from any place in your application using  \b PNObservationCenter:
 @code
 [pubNub.observationCenter addChannelGroupNamespaceRemovalObserver:self withCallbackBlock:^(NSString *namespace, PNError *error) {
 
     if (!error) {
     
         // PubNub client successfully removed channel group.
     }
     else {
     
         // PubNub client did fail to remove channel group.
         //
         // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
         // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
         // 'error.associatedObject' stores reference on PNChannelGroup which describe group which clinent tried to remove.
     }
 }];
 @endcode
 
 Also observation can be done using \b NSNotificationCenter to observe this notifications: kPNClientChannelGroupRemovalCompleteNotification,
 kPNClientChannelGroupRemovalDidFailWithErrorNotification.
 
 @param group
 \b PNChannelGroup instance which describs channel group which should be deleted by \b PubNub client.
 
 @since 3.7.0
 */
- (void)removeChannelGroup:(PNChannelGroup *)group;

/**
 Remove one of channel groups from channel registry. All channels which has been registered in it also will be removed.
 
 @code
 @endcode
 This method extends \a -removeChannelGroup: and allow to specify channel group removal process handler block.
 
 @code
 @endcode
 \b Example:
 
 @code
 PubNub *pubNub = [PubNub clientWithConfiguration:[PNConfiguration defaultConfiguration] andDelegate:self];
 [pubNub connect];
 [pubNub removeChannelGroup:[PNChannelGroup channelGroupWithName:@"android" inNamespace:@"users"]
 withCompletionHandlingBlock:^(PNChannelGroup *group, PNError *error) {
 
     if (!error) {
     
         // PubNub client successfully removed channel group.
     }
     else {
     
         // PubNub client did fail to remove channel group.
         //
         // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
         // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
         // 'error.associatedObject' stores reference on PNChannelGroup which describe group which clinent tried to remove.
     }
 }];
 
 And handle it with delegates:
 @code
 - (void)pubnubClient:(PubNub *)client didRemoveNamespace:(NSString *)nspace {
 
     // PubNub client successfully removed channel group.
 }
 
 - (void)pubnubClient:(PubNub *)client namespaceRemovalDidFailWithError:(PNError *)error {
 
     // PubNub client did fail to remove channel group.
     //
     // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
     // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
     // 'error.associatedObject' stores reference on PNChannelGroup which describe group which clinent tried to remove.
 }
 @endcode
 
 There is also way to observe channel group namespace removal process state from any place in your application using  \b PNObservationCenter:
 @code
 [pubNub.observationCenter addChannelGroupNamespaceRemovalObserver:self withCallbackBlock:^(NSString *namespace, PNError *error) {
 
     if (!error) {
     
         // PubNub client successfully removed channel group.
     }
     else {
     
         // PubNub client did fail to remove channel group.
         //
         // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
         // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
         // 'error.associatedObject' stores reference on PNChannelGroup which describe group which clinent tried to remove.
     }
 }];
 @endcode
 
 Also observation can be done using \b NSNotificationCenter to observe this notifications: kPNClientChannelGroupRemovalCompleteNotification,
 kPNClientChannelGroupRemovalDidFailWithErrorNotification.
 
 @param group
 \b PNChannelGroup instance which describs channel group which should be deleted by \b PubNub client.
 
 @param handlerBlock
 The block which will be called by \b PubNub client as soon as channel group removal process will be completed. The block takes two arguments:
 \c PNChannelGroup - \b PNChannelGroup which should be removed; \c error - describes what exactly went wrong (check error code
 and compare it with \b PNErrorCodes ).
 
 @since 3.7.0
 */
- (void)removeChannelGroup:(PNChannelGroup *)group withCompletionHandlingBlock:(PNClientChannelGroupRemoveHandlingBlock)handlerBlock;


#pragma mark - Channel group channels request

/**
 Retrieve list of channels for specific channel group which has been added for all application users (identifier by subscription key).
 
 @code
 @endcode
 \b Example:
 
 @code
 PubNub *pubNub = [PubNub clientWithConfiguration:[PNConfiguration defaultConfiguration] andDelegate:self];
 [pubNub connect];
 [pubNub requestChannelsForGroup:[PNChannelGroup channelGroupWithName:@"users"]];
 [pubNub requestChannelsForGroup:[PNChannelGroup channelGroupWithName:@"users" inNamespace:@"admin"]];
 @endcode
 
 And handle it with delegates:
 @code
- (void)pubnubClient:(PubNub *)client didReceiveChannelsForGroup:(PNChannelGroup *)group {
 
     // PubNub client received list of channels for specified channel group.
 }
 
 - (void)pubnubClient:(PubNub *)client channelsForGroupRequestDidFailWithError:(PNError *)error {
 
     // PubNub client did fail to retrieve list of channels for channel group.
     //
     // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
     // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
     // 'error.associatedObject' contains PNChannelGroup instance for which channels has been requested.
 }
 @endcode
 
 There is also way to observe channels for group request process state from any place in your application using  \b PNObservationCenter:
 @code
 [pubNub.observationCenter addChannelsForGroupRequestObserver:self withCallbackBlock:^(PNChannelGroup *group, PNError *error) {
 
     if (!error) {
     
         // PubNub client received list of channels for specified channel group.
     }
     else {
     
         // PubNub client did fail to retrieve list of channels for channel group.
         //
         // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
         // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
         // 'error.associatedObject' contains PNChannelGroup instance for which channels has been requested.
     }
 }];
 @endcode
 
 Also observation can be done using \b NSNotificationCenter to observe this notifications: kPNClientChannelsForGroupRequestCompleteNotification,
 kPNClientChannelsForGroupRequestDidFailWithErrorNotification.
 
 @param group
 Reference on channel group object which hold information about group name and namespace.
 
 @since 3.7.0
 */
- (void)requestChannelsForGroup:(PNChannelGroup *)group;

/**
 Retrieve list of channels for specific channel group which has been added for all application users (identifier by subscription key).
 
 @code
 @endcode
 This method extends \a -requestChannelsForGroup: and allow to specify channels for group processing handler block.
 
 @code
 @endcode
 \b Example:
 
 @code
 PubNub *pubNub = [PubNub clientWithConfiguration:[PNConfiguration defaultConfiguration] andDelegate:self];
 [pubNub connect];
 [pubNub requestChannelsForGroup:[PNChannelGroup channelGroupWithName:@"users" inNamespace:@"admin"] 
     withCompletionHandlingBlock:^(PNChannelGroup *group, PNError *error) {
 
     if (!error) {
     
         // PubNub client received list of channels for specified channel group.
     }
     else {
     
         // PubNub client did fail to retrieve list of channels for channel group.
         //
         // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
         // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
         // 'error.associatedObject' contains PNChannelGroup instance for which channels has been requested.
     }
 }];
 @endcode
 
 And handle it with delegates:
 @code
- (void)pubnubClient:(PubNub *)client didReceiveChannelsForGroup:(PNChannelGroup *)group {
 
     // PubNub client received list of channels for specified channel group.
 }
 
 - (void)pubnubClient:(PubNub *)client channelsForGroupRequestDidFailWithError:(PNError *)error {
 
     // PubNub client did fail to retrieve list of channels for channel group.
     //
     // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
     // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
     // 'error.associatedObject' contains PNChannelGroup instance for which channels has been requested.
 }
 @endcode
 
 There is also way to observe channels for group request process state from any place in your application using  \b PNObservationCenter:
 @code
 [pubNub.observationCenter addChannelsForGroupRequestObserver:self withCallbackBlock:^(PNChannelGroup *group, PNError *error) {
 
     if (!error) {
     
         // PubNub client received list of channels for specified channel group.
     }
     else {
     
         // PubNub client did fail to retrieve list of channels for channel group.
         //
         // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
         // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
         // 'error.associatedObject' contains PNChannelGroup instance for which channels has been requested.
     }
 }];
 @endcode
 
 Also observation can be done using \b NSNotificationCenter to observe this notifications: kPNClientChannelsForGroupRequestCompleteNotification,
 kPNClientChannelsForGroupRequestDidFailWithErrorNotification.
 
 @param group
 Reference on channel group object which hold information about group name and namespace.
 
 @param handlerBlock
 The block which will be called by \b PubNub client as soon as channels for group request operation will be completed.
 The block takes two arguments:
 \c group - \b PNChannelGroup instance which describe group for which channels should be retrieved (it also has property 
 with channels list); \c error - describes what exactly went wrong (check error code and compare it with \b PNErrorCodes ).
 
 @since 3.7.0
 */
- (void)requestChannelsForGroup:(PNChannelGroup *)group
    withCompletionHandlingBlock:(PNClientChannelsForGroupRequestHandlingBlock)handlerBlock;


#pragma mark - Channel group channels list manipulation

/**
 Add channels list to the group.
 
 @code
 @endcode
 \b Example:
 
 @code
 PubNub *pubNub = [PubNub clientWithConfiguration:[PNConfiguration defaultConfiguration] andDelegate:self];
 [pubNub connect];
 [[PubNub sharedInstance] addChannels:[PNChannel channelsWithNames:@[@"Bob", @"Jay"]] 
                              toGroup:[PNChannelGroup channelGroupWithName:@"users"]];
 @endcode
 
 And handle it with delegates:
 @code
- (void)pubnubClient:(PubNub *)client didAddChannels:(NSArray *)channels toGroup:(PNChannelGroup *)group {
 
     // PubNub client added channels to the group.
 }
 
 - (void)pubnubClient:(PubNub *)client channelsAdditionToGroupDidFailWithError:(PNError *)error {
 
     // PubNub client did fail to add channels to the group.
     //
     // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
     // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
     // 'error.associatedObject' contains PNChannelGroupChange instance which describe change details.
 }
 @endcode
 
 There is also way to observe channels for group channels list modification process state from any place in your application using  \b PNObservationCenter:
 @code
 [pubNub.observationCenter addChannelsAdditionToGroupObserver:self withCallbackBlock:^(PNChannelGroup *group, NSArray *channels, PNError *error) {
 
     if (!error) {
     
         // PubNub client added channels to the group.
     }
     else {
     
         // PubNub client did fail to add channels to the group.
         //
         // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
         // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
         // 'error.associatedObject' contains PNChannelGroupChange instance which describe change details.
     }
 }];
 @endcode
 
 Also observation can be done using \b NSNotificationCenter to observe this notifications: kPNClientGroupChannelsAdditionCompleteNotification,
 kPNClientGroupChannelsAdditionDidFailWithErrorNotification.
 
 @param channels
 Reference on list of \b PNChannel instances which should be added to the group.
 
 @param group
 Reference on channel group object which hold information about group name and namespace.
 
 @since 3.7.0
 */
- (void)addChannels:(NSArray *)channels toGroup:(PNChannelGroup *)group;

/**
 Add channels list to the group.
 
 @code
 @endcode
 This method extends \a -addChannels:toGroup: and allow to specify channels addition process handler block.
 
 @code
 @endcode
 \b Example:
 
 @code
 PubNub *pubNub = [PubNub clientWithConfiguration:[PNConfiguration defaultConfiguration] andDelegate:self];
 [pubNub connect];
 [[PubNub sharedInstance] addChannels:[PNChannel channelsWithNames:@[@"Bob", @"Jay"]] 
                              toGroup:[PNChannelGroup channelGroupWithName:@"users"] 
          withCompletionHandlingBlock:^(PNChannelGroup *group, NSArray *channels, PNError *error) {
 
             if (!error) {
             
                 // PubNub client added channels to the group.
             }
             else {
             
                 // PubNub client did fail to add channels to the group.
                 //
                 // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
                 // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
                 // 'error.associatedObject' contains PNChannelGroupChange instance which describe change details.
             }
 }];
 @endcode
 
 And handle it with delegates:
 @code
- (void)pubnubClient:(PubNub *)client didAddChannels:(NSArray *)channels toGroup:(PNChannelGroup *)group {
 
     // PubNub client added channels to the group.
 }
 
 - (void)pubnubClient:(PubNub *)client channelsAdditionToGroupDidFailWithError:(PNError *)error {
 
     // PubNub client did fail to add channels to the group.
     //
     // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
     // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
     // 'error.associatedObject' contains PNChannelGroupChange instance which describe change details.
 }
 @endcode
 
 There is also way to observe channels for group channels list modification process state from any place in your application using  \b PNObservationCenter:
 @code
 [pubNub.observationCenter addChannelsAdditionToGroupObserver:self withCallbackBlock:^(PNChannelGroup *group, NSArray *channels, PNError *error) {
 
     if (!error) {
     
         // PubNub client added channels to the group.
     }
     else {
     
         // PubNub client did fail to add channels to the group.
         //
         // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
         // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
         // 'error.associatedObject' contains PNChannelGroupChange instance which describe change details.
     }
 }];
 @endcode
 
 Also observation can be done using \b NSNotificationCenter to observe this notifications: kPNClientGroupChannelsAdditionCompleteNotification,
 kPNClientGroupChannelsAdditionDidFailWithErrorNotification.
 
 @param channels
 Reference on list of \b PNChannel instances which should be added to the group.
 
 @param group
 Reference on channel group object which hold information about group name and namespace.
 
 @param handlerBlock
 The block which will be called by \b PubNub client as soon as channels addition to group operation will be completed.
 The block takes two arguments:
 \c group - \b PNChannelGroup instance which describe group into which channels should be added; \c channels - list 
 of \b PNChannel instance which should be added to the group; \c error - describes what exactly went wrong (check 
 error code and compare it with \b PNErrorCodes ).
 
 @since 3.7.0
 */
- (void)          addChannels:(NSArray *)channels toGroup:(PNChannelGroup *)group
  withCompletionHandlingBlock:(PNClientChannelsAdditionToGroupHandlingBlock)handlerBlock;

/**
 Add channels list to the group.
 
 @code
 @endcode
 \b Example:
 
 @code
 PubNub *pubNub = [PubNub clientWithConfiguration:[PNConfiguration defaultConfiguration] andDelegate:self];
 [pubNub connect];
 [[PubNub sharedInstance] removeChannels:[PNChannel channelsWithNames:@[@"Bob"]]
                               fromGroup:[PNChannelGroup channelGroupWithName:@"users"]
             withCompletionHandlingBlock:^(PNChannelGroup *group, NSArray *channels, PNError *error) {
 
                 if (!error) {
                 
                     // PubNub client removed channels from the group.
                 }
                 else {
                 
                     // PubNub client did fail to remove channels from the group.
                     //
                     // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
                     // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
                     // 'error.associatedObject' contains PNChannelGroupChange instance which describe change details.
                 }
 }];
 @endcode
 
 And handle it with delegates:
 @code
- (void)pubnubClient:(PubNub *)client didRemoveChannels:(NSArray *)channels fromGroup:(PNChannelGroup *)group {
 
     // PubNub client removed channels from the group.
 }
 
 - (void)pubnubClient:(PubNub *)client channelsRemovalFromGroupDidFailWithError:(PNError *)error {
 
     // PubNub client did fail to remove channels from the group.
     //
     // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
     // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
     // 'error.associatedObject' contains PNChannelGroupChange instance which describe change details.
 }
 @endcode
 
 There is also way to observe channels for group channels list modification process state from any place in your application using  \b PNObservationCenter:
 @code
 [pubNub.observationCenter addChannelsRemovalFromGroupObserver:self withCallbackBlock:^(PNChannelGroup *group, NSArray *channels, PNError *error) {
 
     if (!error) {
     
         // PubNub client removed channels from the group.
     }
     else {
     
         // PubNub client did fail to remove channels from the group.
         //
         // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
         // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
         // 'error.associatedObject' contains PNChannelGroupChange instance which describe change details.
     }
 }];
 @endcode
 
 Also observation can be done using \b NSNotificationCenter to observe this notifications: kPNClientGroupChannelsRemovalCompleteNotification,
 kPNClientGroupChannelsRemovalDidFailWithErrorNotification.
 
 @param channels
 Reference on list of \b PNChannel instances which should be added to the group.
 
 @param group
 Reference on channel group object which hold information about group name and namespace.
 
 @since 3.7.0
 */
- (void)removeChannels:(NSArray *)channels fromGroup:(PNChannelGroup *)group;

/**
 Add channels list to the group.
 
 @code
 @endcode
 This method extends \a -removeChannels:fromGroup: and allow to specify channels removal process handler block.
 
 @code
 @endcode
 \b Example:
 
 @code
 PubNub *pubNub = [PubNub clientWithConfiguration:[PNConfiguration defaultConfiguration] andDelegate:self];
 [pubNub connect];
 [[PubNub sharedInstance] removeChannels:[PNChannel channelsWithNames:@[@"Bob"]]
                               fromGroup:[PNChannelGroup channelGroupWithName:@"users"]
             withCompletionHandlingBlock:^(PNChannelGroup *group, NSArray *channels, PNError *error) {
 
                 if (!error) {
                 
                     // PubNub client removed channels from the group.
                 }
                 else {
                 
                     // PubNub client did fail to remove channels from the group.
                     //
                     // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
                     // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
                     // 'error.associatedObject' contains PNChannelGroupChange instance which describe change details.
                 }
 }];
 @endcode
 
 And handle it with delegates:
 @code
- (void)pubnubClient:(PubNub *)client didRemoveChannels:(NSArray *)channels fromGroup:(PNChannelGroup *)group {
 
     // PubNub client removed channels from the group.
 }
 
 - (void)pubnubClient:(PubNub *)client channelsRemovalFromGroupDidFailWithError:(PNError *)error {
 
     // PubNub client did fail to remove channels from the group.
     //
     // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
     // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
     // 'error.associatedObject' contains PNChannelGroupChange instance which describe change details.
 }
 @endcode
 
 There is also way to observe channels for group channels list modification process state from any place in your application using  \b PNObservationCenter:
 @code
 [pubNub.observationCenter addChannelsRemovalFromGroupObserver:self withCallbackBlock:^(PNChannelGroup *group, NSArray *channels, PNError *error) {
 
     if (!error) {
     
         // PubNub client removed channels from the group.
     }
     else {
     
         // PubNub client did fail to remove channels from the group.
         //
         // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
         // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
         // 'error.associatedObject' contains PNChannelGroupChange instance which describe change details.
     }
 }];
 @endcode
 
 Also observation can be done using \b NSNotificationCenter to observe this notifications: kPNClientGroupChannelsRemovalCompleteNotification,
 kPNClientGroupChannelsRemovalDidFailWithErrorNotification.
 
 @param channels
 Reference on list of \b PNChannel instances which should be added to the group.
 
 @param group
 Reference on channel group object which hold information about group name and namespace.
 
 @param handlerBlock
 The block which will be called by \b PubNub client as soon as channels removal from group operation will be completed.
 The block takes two arguments:
 \c group - \b PNChannelGroup instance which describe group from which channels should be removed; \c channels - list
 of \b PNChannel instance which should be removed from the group; \c error - describes what exactly went wrong (check
 error code and compare it with \b PNErrorCodes ).
 
 @since 3.7.0
 */
- (void)       removeChannels:(NSArray *)channels fromGroup:(PNChannelGroup *)group
  withCompletionHandlingBlock:(PNClientChannelsRemovalFromGroupHandlingBlock)handlerBlock;

#pragma mark -


@end
