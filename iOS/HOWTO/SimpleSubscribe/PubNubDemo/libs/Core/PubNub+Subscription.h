#import "PubNub.h"
#import "PNChannelProtocol.h"

/**
 Base class extension which provide methods for subscription manipulation.
 
 @author Sergey Mamontov
 @version 3.7.0
 @copyright © 2009-13 PubNub Inc.
 */
@interface PubNub (Subscription)


#pragma mark - Class (singleton) methods

/**
 Retrieve list of channels on which \b PubNub client subscribed at this moment.
 
 @code
 @endcode
 \b Example:
 
 @code
 [PubNub setConfiguration:[PNConfiguration defaultConfiguration] andDelegate:self];
 [PubNub connect];
 [PubNub subscribeOnChannels:[PNChannel channelsWithNames:@[@"iosdev", @"macosdev"]]
 withCompletionHandlingBlock:^(PNSubscriptionProcessState state, NSArray *channels, PNError *subscriptionError) {
 
     if (subscriptionError == nil) {
     
         NSLog(@"Channels: %@", [PubNub subscribedChannels]); // iosdev, macosdev
     }
     else {
     
         // Update user interface to let user know that something went wrong and do something to recover from this state.
         //
         // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
         // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
         // 'error.associatedObject' contains array of PNChannel instances on which PubNub client was unable to
         // subscribe.
     }
 }];
 @endcode
 
 @note It will return list of the channels even if \b PubNub client in \a 'disconnected' because of error. It is because after connection restore completions
 it will restore subscription (if allowed by user via \a resubscribeOnConnectionRestore field in \b PNConfiguration instance or
 \a -shouldResubscribeOnConnectionRestore delegate method).
 
 @return array of \b PNChannel instances on which \b PubNub client subscribed at this moment.
 
 @since 3.4.0
 
 @see PNChannel class
 
 @see +isSubscribedOnChannel:
 */
+ (NSArray *)subscribedChannels
  DEPRECATED_MSG_ATTRIBUTE(" Use '+subscribedObjectsList' or '-subscribedObjectsList' instead. Class method will be "
                           "removed in future.");

/**
 @brief Retrieve list of data feed objects on which \b PubNub client subscribed at this moment.

 @code
 @endcode
 \b Example:

 @code
 [PubNub setConfiguration:[PNConfiguration defaultConfiguration] andDelegate:self];
 [PubNub connect];
 [PubNub subscribeOn:[PNChannel channelsWithNames:@[@"iosdev", @"macosdev"]]
 withCompletionHandlingBlock:^(PNSubscriptionProcessState state, NSArray *channels, PNError *subscriptionError) {

     if (subscriptionError == nil) {

         NSLog(@"Channels: %@", [PubNub subscribedObjectsList]); // iosdev, macosdev
     }
     else {

         // Update user interface to let user know that something went wrong and do something to recover from this state.
         //
         // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
         // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
         // 'error.associatedObject' contains array of PNChannel instances on which PubNub client was unable to
         // subscribe.
     }
 }];
 @endcode

 @note It will return list of the data feed objects even if \b PubNub client in \a 'disconnected' because of error. It
 is because after connection restore completions it will restore subscription (if allowed by user via
 \a resubscribeOnConnectionRestore field in \b PNConfiguration instance or \a -shouldResubscribeOnConnectionRestore
 delegate method).

 @return array objects (which conforms to \b PNChannelProtocol data feed object protocol) on which \b PubNub client
 subscribed at this moment.

 @since 3.7.0
 */
+ (NSArray *)subscribedObjectsList;

/**
 Check whether client subscribed on specified channel or not.
 
 @code
 @endcode
 \b Example:
 
 @code
 [PubNub setConfiguration:[PNConfiguration defaultConfiguration] andDelegate:self];
 [PubNub connect];
 [PubNub subscribeOnChannels:[PNChannel channelsWithNames:@[@"iosdev", @"macosdev"]]
 withCompletionHandlingBlock:^(PNSubscriptionProcessState state, NSArray *channels, PNError *subscriptionError) {
 
     if (subscriptionError == nil) {
     
         NSLog(@"Is subscribed on 'iosdev' channel? %@", [PubNub isSubscribedOnChannel:[PNChannel channelWithName:@"iosdev"]] ? @"YES" : @"NO"); // YES
         NSLog(@"Is subscribed on 'androiddev' channel? %@", [PubNub isSubscribedOnChannel:[PNChannel channelWithName:@"androiddev"]] ? @"YES" : @"NO"); // NO
     }
     else {
     
         // Update user interface to let user know that something went wrong and do something to recover from this state.
         //
         // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
         // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
         // 'error.associatedObject' contains array of PNChannel instances on which PubNub client was unable to
         // subscribe.
     }
 }];
 @endcode
 
 @param channel
 \b PNChannel instance against which check should be performed.
 
 @return \c YES if \b PubNub client subscribed on provided channel.
 
 @since 3.4.0
 
 @see PNChannel class
 
 @see +subscribedChannels
 */
+ (BOOL)isSubscribedOnChannel:(PNChannel *)channel
  DEPRECATED_MSG_ATTRIBUTE(" Use '+isSubscribedOn:' or '-isSubscribedOn:' instead. Class method will be removed in "
                           "future.");

/**
 @brief Check whether client subscribed on specified data feed object or not.

 @code
 @endcode
 \b Example:

 @code
 [PubNub setConfiguration:[PNConfiguration defaultConfiguration] andDelegate:self];
 [PubNub connect];
 [PubNub subscribeOn:[PNChannel channelsWithNames:@[@"iosdev", @"macosdev"]]
 withCompletionHandlingBlock:^(PNSubscriptionProcessState state, NSArray *channels, PNError *subscriptionError) {

     if (subscriptionError == nil) {

         NSLog(@"Is subscribed on 'iosdev' channel? %@", [PubNub isSubscribedOn:[PNChannel channelWithName:@"iosdev"]] ? @"YES" : @"NO"); // YES
         NSLog(@"Is subscribed on 'androiddev' channel? %@", [PubNub isSubscribedOn:[PNChannel channelWithName:@"androiddev"]] ? @"YES" : @"NO"); // NO
     }
     else {

         // Update user interface to let user know that something went wrong and do something to recover from this state.
         //
         // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
         // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
         // 'error.associatedObject' contains array of PNChannel instances on which PubNub client was unable to
         // subscribe.
     }
 }];
 @endcode

 @param object Object (which conforms to \b PNChannelProtocol data feed object protocol) like \b PNChannel and
               \b PNChannelGroup against which check should be performed

 @return \c YES if \b PubNub client subscribed on provided data feed object.

 @since 3.7.0
 */
+ (BOOL)isSubscribedOn:(id <PNChannelProtocol>)object;

/**
 Subscribe client to one more channel. By default this method will trigger presence event by sending \a 'leave' presence event to channels on
 which \b PubNub client already subscribed and then re-subscribe generating \a 'join' presence event.
 
 @code
 @endcode
 \b Example:
 
 @code
 [PubNub setConfiguration:[PNConfiguration defaultConfiguration] andDelegate:self];
 [PubNub connect];
 [PubNub subscribeOnChannel:[PNChannel channelsWithName:@"iosdev"]];
 @endcode
 
 And handle it with delegates:
 @code
 - (void)pubnubClient:(PubNub *)client didSubscribeOnChannels:(NSArray *)channels {
 
     // PubNub client subscribed on specified set of channels.
 }
 
 - (void)pubnubClient:(PubNub *)client subscriptionDidFailWithError:(NSError *)error {
 
     // PubNub client did fail to subscribe on requested set of channels.
     //
     // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
     // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
     // 'error.associatedObject' contains array of PNChannel instances on which PubNub client was unable to
     // subscribe.
 }
 @endcode
 
 There is also way to observe subscription process state from any place in your application using  \b PNObservationCenter:
 @code
 [[PNObservationCenter defaultCenter] addClientChannelSubscriptionStateObserver:self
 withCallbackBlock:^(PNSubscriptionProcessState state, NSArray *channels, PNError *error) {
 
     switch (state) {
         case PNSubscriptionProcessNotSubscribedState:
         
             // There should be a reason because of which subscription failed and it can be found in 'error' instance.
             //
             // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
             // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
             // 'error.associatedObject' contains array of PNChannel instances on which PubNub client was unable to
             // subscribe.
             break;
         case PNSubscriptionProcessSubscribedState:
         
             // PubNub client completed subscription on specified set of channels.
             break;
         case PNSubscriptionProcessWillRestoreState:
         
             // PubNub client is about to restore subscription on specified set of channels.
             break;
         case PNSubscriptionProcessRestoredState:
         
             // PubNub client completed subscription restore process
             break;
     }
 }];
 @endcode
 
 Also observation can be done using \b NSNotificationCenter to observe this notifications: kPNClientSubscriptionDidCompleteNotification,
 kPNClientSubscriptionWillRestoreNotification, kPNClientSubscriptionDidRestoreNotification, kPNClientSubscriptionDidFailNotification.
 
 @param channel
 \b PNChannel instance on which client should subscribe.
 
 @since 3.4.0
 
 @see PNChannel class
 
 @see PNError class
 
 @see PNObservationCenter class
 
 @see +subscribeOnChannel:withCompletionHandlingBlock:
 */
+ (void)subscribeOnChannel:(PNChannel *)channel
  DEPRECATED_MSG_ATTRIBUTE(" Use '+subscribeOn:' or '-subscribeOn:' instead. Class methods will be deprecated in "
                           "future.");

/**
 Subscribe client to one more channel. By default this method will trigger presence event by sending \a 'leave' presence event to channels on which
 client already subscribed and then re-subscribe generating \a 'join' presence event.
 
 @code
 @endcode
 This method extends \a +subscribeOnChannel: and allow to specify subscription process state change handler block.
 
 @code
 @endcode
 \b Example:
 
 @code
 [PubNub setConfiguration:[PNConfiguration defaultConfiguration] andDelegate:self];
 [PubNub connect];
 [PubNub subscribeOnChannel:[PNChannel channelsWithName:@"iosdev"]
 withCompletionHandlingBlock:^(PNSubscriptionProcessState state, NSArray *channels, PNError *subscriptionError) {
 
     switch (state) {
         case PNSubscriptionProcessNotSubscribedState:
         
             // There should be a reason because of which subscription failed and it can be found in 'error' instance.
             //
             // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
             // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
             // 'error.associatedObject' contains array of PNChannel instances on which PubNub client was unable to
             // subscribe.
             break;
         case PNSubscriptionProcessSubscribedState:
         
             // PubNub client completed subscription on specified set of channels.
             break;
     }
 }];
 @endcode
 
 And handle it with delegates:
 @code
 - (void)pubnubClient:(PubNub *)client didSubscribeOnChannels:(NSArray *)channels {
 
     // PubNub client subscribed on specified set of channels.
 }
 
 - (void)pubnubClient:(PubNub *)client subscriptionDidFailWithError:(NSError *)error {
 
     // PubNub client did fail to subscribe on requested set of channels.
     //
     // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
     // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
     // 'error.associatedObject' contains array of PNChannel instances on which PubNub client was unable to
     // subscribe.
 }
 @endcode
 
 There is also way to observe subscription process state from any place in your application using  \b PNObservationCenter:
 @code
 [[PNObservationCenter defaultCenter] addClientChannelSubscriptionStateObserver:self
 withCallbackBlock:^(PNSubscriptionProcessState state, NSArray *channels, PNError *error) {
 
     switch (state) {
         case PNSubscriptionProcessNotSubscribedState:
         
             // There should be a reason because of which subscription failed and it can be found in 'error' instance.
             //
             // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
             // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
             // 'error.associatedObject' contains array of PNChannel instances on which PubNub client was unable to
             // subscribe.
             break;
         case PNSubscriptionProcessSubscribedState:
         
             // PubNub client completed subscription on specified set of channels.
             break;
         case PNSubscriptionProcessWillRestoreState:
         
             // PubNub client is about to restore subscription on specified set of channels.
             break;
         case PNSubscriptionProcessRestoredState:
         
             // PubNub client completed subscription restore process.
             break;
     }
 }];
 @endcode
 
 Also observation can be done using \b NSNotificationCenter to observe this notifications: kPNClientSubscriptionDidCompleteNotification,
 kPNClientSubscriptionWillRestoreNotification, kPNClientSubscriptionDidRestoreNotification, kPNClientSubscriptionDidFailNotification.
 
 @param channel
 \b PNChannel instance on which client should subscribe.
 
 @param handlerBlock
 The block which will be called by \b PubNub client as soon as subscription process state will change. The block takes three arguments:
 \c state - is \b PNSubscriptionProcessState enumerator field which describes current subscription state; \c channels - array of \b PNChannel instances for which
 subscription process changed state; \c error - error because of which subscription failed. Always check \a error.code to find out what caused error
 (check \b PNErrorCodes header file and use \a -localizedDescription / \a -localizedFailureReason and \a -localizedRecoverySuggestion to get human
 readable description for error).
 
 @since 3.4.0
 
 @see PNChannel class
 
 @see PNError class
 
 @see PNObservationCenter class
 
 @sse +subscribeOnChannel:
 */
+ (void)   subscribeOnChannel:(PNChannel *)channel
  withCompletionHandlingBlock:(PNClientChannelSubscriptionHandlerBlock)handlerBlock
  DEPRECATED_MSG_ATTRIBUTE(" Use '+subscribeOn:withCompletionHandlingBlock:' or "
                           "'-subscribeOn:withCompletionHandlingBlock:' instead. Class methods will be deprecated in "
                           "future.");

/**
 Subscribe client to one more channel. By default this method will trigger presence event by sending \a 'leave' presence event to channels on
 which \b PubNub client already subscribed and then re-subscribe generating \a 'join' presence event.
 
 @code
 @endcode
 This method extends \a +subscribeOnChannel: and allow to specify client specific state.
 
 @code
 @endcode
 \b Example:
 
 @code
 [PubNub setConfiguration:[PNConfiguration defaultConfiguration] andDelegate:self];
 [PubNub connect];
 [PubNub subscribeOnChannel:[PNChannel channelsWithName:@"iosdev"]
 withClientState:@{@"firstName":@"John", @"lastName":@"Appleseed", @"age":@(240)}];
 @endcode
 
 And handle it with delegates:
 @code
 - (void)pubnubClient:(PubNub *)client didSubscribeOnChannels:(NSArray *)channels {
 
     // PubNub client subscribed on specified set of channels.
 }
 
 - (void)pubnubClient:(PubNub *)client subscriptionDidFailWithError:(NSError *)error {
 
     // PubNub client did fail to subscribe on requested set of channels.
     //
     // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
     // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
     // 'error.associatedObject' contains array of PNChannel instances on which PubNub client was unable to
     // subscribe.
 }
 @endcode
 
 There is also way to observe subscription process state from any place in your application using  \b PNObservationCenter:
 @code
 [[PNObservationCenter defaultCenter] addClientChannelSubscriptionStateObserver:self
 withCallbackBlock:^(PNSubscriptionProcessState state, NSArray *channels, PNError *error) {
 
     switch (state) {
         case PNSubscriptionProcessNotSubscribedState:
         
             // There should be a reason because of which subscription failed and it can be found in 'error' instance.
             //
             // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
             // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
             // 'error.associatedObject' contains array of PNChannel instances on which PubNub client was unable to
             // subscribe.
             break;
         case PNSubscriptionProcessSubscribedState:
         
             // PubNub client completed subscription on specified set of channels.
             break;
         case PNSubscriptionProcessWillRestoreState:
         
             // PubNub client is about to restore subscription on specified set of channels.
             break;
         case PNSubscriptionProcessRestoredState:
         
             // PubNub client completed subscription restore process
             break;
     }
 }];
 @endcode
 
 Also observation can be done using \b NSNotificationCenter to observe this notifications: kPNClientSubscriptionDidCompleteNotification,
 kPNClientSubscriptionWillRestoreNotification, kPNClientSubscriptionDidRestoreNotification, kPNClientSubscriptionDidFailNotification.
 
 @param channel
 \b PNChannel instance on which client should subscribe.
 
 @param clientState
 \b NSDictionary instance with list of parameters which should be bound to the client.
 
 @note You can delete previously configured key from state by passing [NSNull null] as value for target key and \b
 PubNub service will remove specified key from client's state at specified channel.
 
 @warning Client state shouldn't contain any nesting and values should be one of: int, float or string.
 
 @warning If you already subscribed on channel (for which already specified state) and will subscribe to another
 one, it will override old state (if keys are the same or will add new keys into old one).
 
 @since 3.6.0
 
 @see PNChannel class
 
 @see PNError class
 
 @see PNObservationCenter class
 
 @see +subscribeOnChannel:withCompletionHandlingBlock:
 */
+ (void)subscribeOnChannel:(PNChannel *)channel withClientState:(NSDictionary *)clientState
  DEPRECATED_MSG_ATTRIBUTE(" Use '+subscribeOn:withClientState:' or '-subscribeOn:withClientState:' instead. Class "
                           "methods will be deprecated in future.");

/**
 Subscribe client to one more channel. By default this method will trigger presence event by sending \a 'leave' presence event to channels on which
 client already subscribed and then re-subscribe generating \a 'join' presence event.
 
 @code
 @endcode
 This method extends \a +subscribeOnChannel:withClientState: and allow to specify subscription process state change handler
 block.
 
 @code
 @endcode
 \b Example:
 
 @code
 [PubNub setConfiguration:[PNConfiguration defaultConfiguration] andDelegate:self];
 [PubNub connect];
 [PubNub subscribeOnChannel:[PNChannel channelsWithName:@"iosdev"]
 withClientState:@{@"firstName":@"John", @"lastName":@"Appleseed", @"age":@(240)}
 andCompletionHandlingBlock:^(PNSubscriptionProcessState state, NSArray *channels, PNError *subscriptionError) {
 
     switch (state) {
         case PNSubscriptionProcessNotSubscribedState:
         
             // There should be a reason because of which subscription failed and it can be found in 'error' instance.
             //
             // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
             // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
             // 'error.associatedObject' contains array of PNChannel instances on which PubNub client was unable to
             // subscribe.
             break;
         case PNSubscriptionProcessSubscribedState:
         
             // PubNub client completed subscription on specified set of channels.
             break;
     }
 }];
 @endcode
 
 And handle it with delegates:
 @code
 - (void)pubnubClient:(PubNub *)client didSubscribeOnChannels:(NSArray *)channels {
 
     // PubNub client subscribed on specified set of channels.
 }
 
 - (void)pubnubClient:(PubNub *)client subscriptionDidFailWithError:(NSError *)error {
 
     // PubNub client did fail to subscribe on requested set of channels.
     //
     // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
     // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
     // 'error.associatedObject' contains array of PNChannel instances on which PubNub client was unable to
     // subscribe.
 }
 @endcode
 
 There is also way to observe subscription process state from any place in your application using  \b PNObservationCenter:
 @code
 [[PNObservationCenter defaultCenter] addClientChannelSubscriptionStateObserver:self
 withCallbackBlock:^(PNSubscriptionProcessState state, NSArray *channels, PNError *error) {
 
     switch (state) {
         case PNSubscriptionProcessNotSubscribedState:
         
             // There should be a reason because of which subscription failed and it can be found in 'error' instance.
             //
             // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
             // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
             // 'error.associatedObject' contains array of PNChannel instances on which PubNub client was unable to
             // subscribe.
             break;
         case PNSubscriptionProcessSubscribedState:
         
             // PubNub client completed subscription on specified set of channels.
             break;
         case PNSubscriptionProcessWillRestoreState:
         
             // PubNub client is about to restore subscription on specified set of channels.
             break;
         case PNSubscriptionProcessRestoredState:
         
             // PubNub client completed subscription restore process.
             break;
     }
 }];
 @endcode
 
 Also observation can be done using \b NSNotificationCenter to observe this notifications: kPNClientSubscriptionDidCompleteNotification,
 kPNClientSubscriptionWillRestoreNotification, kPNClientSubscriptionDidRestoreNotification, kPNClientSubscriptionDidFailNotification.
 
 @param channel
 \b PNChannel instance on which client should subscribe.
 
 @param clientState
 \b NSDictionary instance with list of parameters which should be bound to the client.
 
 @param handlerBlock
 The block which will be called by \b PubNub client as soon as subscription process state will change. The block takes three arguments:
 \c state - is \b PNSubscriptionProcessState enumerator field which describes current subscription state; \c channels - array of \b PNChannel instances for which
 subscription process changed state; \c error - error because of which subscription failed. Always check \a error.code to find out what caused error
 (check \b PNErrorCodes header file and use \a -localizedDescription / \a -localizedFailureReason and \a -localizedRecoverySuggestion to get human
 readable description for error).
 
 @note You can delete previously configured key from state by passing [NSNull null] as value for target key and \b
 PubNub service will remove specified key from client's state at specified channel.
 
 @warning Client state shouldn't contain any nesting and values should be one of: int, float or string.
 
 @warning If you already subscribed on channel (for which already specified state) and will subscribe to another
 one, it will override old state (if keys are the same or will add new keys into old one).
 
 @since 3.6.0
 
 @see PNChannel class
 
 @see PNError class
 
 @see PNObservationCenter class
 
 @sse +subscribeOnChannel:
 */
+ (void)  subscribeOnChannel:(PNChannel *)channel withClientState:(NSDictionary *)clientState
  andCompletionHandlingBlock:(PNClientChannelSubscriptionHandlerBlock)handlerBlock
  DEPRECATED_MSG_ATTRIBUTE(" Use '+subscribeOn:withClientState:andCompletionHandlingBlock:' or "
                           "'-subscribeOn:withClientState:andCompletionHandlingBlock:' instead. Class methods will be "
                           "deprecated in future.");

/**
 Subscribe client to the set of new channels. By default this method will trigger presence event by sending \a 'leave' presence to channels on which
 client already connected and then re-subscribe generating \a 'join' presence event.
 
 @code
 @endcode
 \b Example:
 
 @code
 [PubNub setConfiguration:[PNConfiguration defaultConfiguration] andDelegate:self];
 [PubNub connect];
 [PubNub subscribeOnChannels:[PNChannel channelsWithNames:@[@"iosdev", @"macosdev"]]];
 @endcode
 
 And handle it with delegates:
 @code
 - (void)pubnubClient:(PubNub *)client didSubscribeOnChannels:(NSArray *)channels {
 
     // PubNub client subscribed on specified set of channels.
 }
 
 - (void)pubnubClient:(PubNub *)client subscriptionDidFailWithError:(NSError *)error {
 
     // PubNub client did fail to subscribe on requested set of channels.
     //
     // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
     // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
     // 'error.associatedObject' contains array of PNChannel instances on which PubNub client was unable to
     // subscribe.
 }
 @endcode
 
 There is also way to observe subscription process state from any place in your application using  \b PNObservationCenter:
 @code
 [[PNObservationCenter defaultCenter] addClientChannelSubscriptionStateObserver:self
 withCallbackBlock:^(PNSubscriptionProcessState state, NSArray *channels, PNError *error) {
 
     switch (state) {
         case PNSubscriptionProcessNotSubscribedState:
         
             // There should be a reason because of which subscription failed and it can be found in 'error' instance.
             //
             // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
             // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
             // 'error.associatedObject' contains array of PNChannel instances on which PubNub client was unable to
             // subscribe.
             break;
         case PNSubscriptionProcessSubscribedState:
         
             // PubNub client completed subscription on specified set of channels.
             break;
         case PNSubscriptionProcessWillRestoreState:
         
             // PubNub client is about to restore subscription on specified set of channels.
             break;
         case PNSubscriptionProcessRestoredState:
         
             // PubNub client completed subscription restore process.
             break;
     }
 }];
 @endcode
 
 Also observation can be done using \b NSNotificationCenter to observe this notifications: kPNClientSubscriptionDidCompleteNotification,
 kPNClientSubscriptionWillRestoreNotification, kPNClientSubscriptionDidRestoreNotification, kPNClientSubscriptionDidFailNotification.
 
 @param channels
 Array of \b PNChannel instances on which client should subscribe.
 
 @since 3.4.0
 
 @see PNChannel class
 
 @see PNError class
 
 @see PNObservationCenter class
 
 @see +subscribeOnChannels:withCompletionHandlingBlock:
 */
+ (void)subscribeOnChannels:(NSArray *)channels
  DEPRECATED_MSG_ATTRIBUTE(" Use '+subscribeOn:' or '-subscribeOn:' instead. Class methods will be deprecated in "
                           "future.");

/**
 Subscribe client to the set of new channels. By default this method will trigger presence event by sending \a 'leave' presence event to channels
 on which client already connected and then re-subscribe generating \a 'join' presence event.
 
 @code
 @endcode
 This method extends \a +subscribeOnChannels: and allow to specify subscription process state change handler block.
 
 @code
 @endcode
 \b Example:
 
 @code
 [PubNub setConfiguration:[PNConfiguration defaultConfiguration] andDelegate:self];
 [PubNub connect];
 [PubNub subscribeOnChannels:[PNChannel channelsWithNames:@[@"iosdev", @"macosdev"]]
 withCompletionHandlingBlock:^(PNSubscriptionProcessState state, NSArray *channels, PNError *subscriptionError) {
 
     switch (state) {
         case PNSubscriptionProcessNotSubscribedState:
         
             // There should be a reason because of which subscription failed and it can be found in 'error' instance
             // Update user interface to let user know that something went wrong and do something to recover from this state.
             //
             // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
             // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
             // 'error.associatedObject' contains array of PNChannel instances on which PubNub client was unable to
             // subscribe.
             break;
         case PNSubscriptionProcessSubscribedState:
         
             // PubNub client completed subscription on specified set of channels.
             break;
         default:
             break;
     }
 }];
 @endcode
 
 And handle it with delegates:
 @code
 - (void)pubnubClient:(PubNub *)client didSubscribeOnChannels:(NSArray *)channels {
 
     // PubNub client subscribed on specified set of channels.
 }
 
 - (void)pubnubClient:(PubNub *)client subscriptionDidFailWithError:(NSError *)error {
 
     // PubNub client did fail to subscribe on requested set of channels.
     //
     // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
     // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
     // 'error.associatedObject' contains array of PNChannel instances on which PubNub client was unable to
     // subscribe.
 }
 @endcode
 
 There is also way to observe subscription process state from any place in your application using  \b PNObservationCenter:
 @code
 [[PNObservationCenter defaultCenter] addClientChannelSubscriptionStateObserver:self
 withCallbackBlock:^(PNSubscriptionProcessState state, NSArray *channels, PNError *error) {
 
     switch (state) {
         case PNSubscriptionProcessNotSubscribedState:
         
             // There should be a reason because of which subscription failed and it can be found in 'error' instance.
             //
             // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
             // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
             // 'error.associatedObject' contains array of PNChannel instances on which PubNub client was unable to
             // subscribe.
             break;
         case PNSubscriptionProcessSubscribedState:
         
             // PubNub client completed subscription on specified set of channels.
             break;
         case PNSubscriptionProcessWillRestoreState:
 
             // PubNub client is about to restore subscription on specified set of channels.
             break;
         case PNSubscriptionProcessRestoredState:
 
             // PubNub client completed subscription restore process.
             break;
     }
 }];
 @endcode
 
 Also observation can be done using \b NSNotificationCenter to observe this notifications: kPNClientSubscriptionDidCompleteNotification,
 kPNClientSubscriptionWillRestoreNotification, kPNClientSubscriptionDidRestoreNotification, kPNClientSubscriptionDidFailNotification.
 
 @param channels
 Array of \b PNChannel instances on which client should subscribe.
 
 @param handlerBlock
 The block which will be called by PubNub client as soon as subscription process state will change. The block takes three arguments:
 \c state - is \b PNSubscriptionProcessState enumerator field which describes current subscription state; \c channels - array of channels for which
 subscription process changed state; \c error - error because of which subscription failed. Always check \a error.code to find out what caused
 error (check PNErrorCodes header file and use \a -localizedDescription / \a -localizedFailureReason and \a -localizedRecoverySuggestion to get
 human readable description for error).
 
 @since 3.4.0
 
 @see PNChannel class
 
 @see PNError class
 
 @see PNObservationCenter class
 
 @see +subscribeOnChannels:
 */
+ (void)  subscribeOnChannels:(NSArray *)channels
  withCompletionHandlingBlock:(PNClientChannelSubscriptionHandlerBlock)handlerBlock
  DEPRECATED_MSG_ATTRIBUTE(" Use '+subscribeOn:withCompletionHandlingBlock:' or "
                           "'-subscribeOn:withCompletionHandlingBlock:' instead. Class methods will be deprecated in "
                           "future.");

/**
 Subscribe client to the set of new channels and channel groups. This method will trigger presence event by
 sending \a 'leave' presence event to channels on which client already connected and then re-subscribe generating
 \a 'join' presence event.
 
 @code
 @endcode
 \b Example:
 
 @code
 [PubNub setConfiguration:[PNConfiguration defaultConfiguration] andDelegate:self];
 [PubNub connect];
 [PubNub subscribeOn:@[[PNChannel channelWithName:@"iosdev"],
                       [PNChannelGroup channelGroupWithName:@"ios" inNamespace:@"users"]]];
 @endcode
 
 And handle it with delegates:
 @code
 - (void)pubnubClient:(PubNub *)client didSubscribeOn:(NSArray *)channelObjects {
 
     // PubNub client subscribed on specified set of channels.
 }
 
 - (void)pubnubClient:(PubNub *)client subscriptionDidFailWithError:(NSError *)error {
 
     // PubNub client did fail to subscribe on requested set of channels.
     //
     // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use 
     // -localizedDescription / -localizedFailureReason and -localizedRecoverySuggestion to get human readable 
     // description for error). 'error.associatedObject' contains array of objects (which conforms to 
     // PNChannelProtocol data feed object protocol) on which PubNub client was unable to subscribe.
 }
 @endcode
 
 There is also way to observe subscription process state from any place in your application using  
 \b PNObservationCenter:
 @code
 [[PNObservationCenter defaultCenter] addClientChannelSubscriptionStateObserver:self
 withCallbackBlock:^(PNSubscriptionProcessState state, NSArray *channels, PNError *error) {
 
     switch (state) {
         case PNSubscriptionProcessNotSubscribedState:
         
             // There should be a reason because of which subscription failed and it can be found in 'error' instance.
             //
             // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use 
             // -localizedDescription / -localizedFailureReason and -localizedRecoverySuggestion to get human readable 
             // description for error). 'error.associatedObject' contains array of objects (which conforms to 
             // PNChannelProtocol data feed object protocol) on which PubNub client was unable to subscribe.
             break;
         case PNSubscriptionProcessSubscribedState:
         
             // PubNub client completed subscription on specified set of channels.
             break;
         case PNSubscriptionProcessWillRestoreState:
         
             // PubNub client is about to restore subscription on specified set of channels.
             break;
         case PNSubscriptionProcessRestoredState:
         
             // PubNub client completed subscription restore process.
             break;
     }
 }];
 @endcode
 
 Also observation can be done using \b NSNotificationCenter to observe this notifications: 
 kPNClientSubscriptionDidCompleteNotification, kPNClientSubscriptionWillRestoreNotification, 
 kPNClientSubscriptionDidRestoreNotification, kPNClientSubscriptionDidFailNotification.
 
 @param channelObjects List of objects (which conforms to \b PNChannelProtocol data feed object protocol) on which 
                       client should subscribe.
 
 @since 3.7.0
 */
+ (void)subscribeOn:(NSArray *)channelObjects;

/**
 Subscribe client to the set of new channels and channel groups. This method will trigger presence event by 
 sending \a 'leave' presence event to channels on which client already connected and then re-subscribe generating 
 \a 'join' presence event.
 
 @code
 @endcode
 This method extends \a +subscribeOn: and allow to specify subscription process state change handler block.
 
 @code
 @endcode
 \b Example:
 
 @code
 [PubNub setConfiguration:[PNConfiguration defaultConfiguration] andDelegate:self];
 [PubNub connect];
 [PubNub subscribeOn:@[[PNChannel channelWithName:@"iosdev"],
                       [PNChannelGroup channelGroupWithName:@"ios" inNamespace:@"users"]]
withCompletionHandlingBlock:^(PNSubscriptionProcessState state, NSArray *channels, PNError *subscriptionError) {
 
     switch (state) {
         case PNSubscriptionProcessNotSubscribedState:
         
             // There should be a reason because of which subscription failed and it can be found in 'error' instance
             // Update user interface to let user know that something went wrong and do something to recover from this 
             // state.
             //
             // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use 
             // -localizedDescription / -localizedFailureReason and -localizedRecoverySuggestion to get human readable 
             // description for error). 'error.associatedObject' contains array of PNChannel instances on which PubNub 
             //client was unable to subscribe.
             break;
         case PNSubscriptionProcessSubscribedState:
         
             // PubNub client completed subscription on specified set of channels.
             break;
         default:
             break;
     }
 }];
 @endcode
 
 And handle it with delegates:
 @code
 - (void)pubnubClient:(PubNub *)client didSubscribeOn:(NSArray *)channelObjects {
 
     // PubNub client subscribed on specified set of channels.
 }
 
 - (void)pubnubClient:(PubNub *)client subscriptionDidFailWithError:(NSError *)error {
 
     // PubNub client did fail to subscribe on requested set of channels.
     //
     // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use
     // -localizedDescription / -localizedFailureReason and -localizedRecoverySuggestion to get human readable 
     // description for error). 'error.associatedObject' contains array of objects (which conforms to 
     // PNChannelProtocol data feed object protocol) on which PubNub client was unable to subscribe.
 }
 @endcode
 
 There is also way to observe subscription process state from any place in your application using 
 \b PNObservationCenter:
 @code
 [[PNObservationCenter defaultCenter] addClientChannelSubscriptionStateObserver:self
 withCallbackBlock:^(PNSubscriptionProcessState state, NSArray *channels, PNError *error) {
 
     switch (state) {
         case PNSubscriptionProcessNotSubscribedState:
         
             // There should be a reason because of which subscription failed and it can be found in 'error' instance.
             //
             // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use 
             // -localizedDescription / -localizedFailureReason and -localizedRecoverySuggestion to get human readable 
             // description for error). 'error.associatedObject' contains array of objects (which conforms to 
             // PNChannelProtocol data feed object protocol) on which PubNub client was unable to subscribe.
             break;
         case PNSubscriptionProcessSubscribedState:
         
             // PubNub client completed subscription on specified set of channels.
             break;
         case PNSubscriptionProcessWillRestoreState:
 
             // PubNub client is about to restore subscription on specified set of channels.
             break;
         case PNSubscriptionProcessRestoredState:
 
             // PubNub client completed subscription restore process.
             break;
     }
 }];
 @endcode
 
 Also observation can be done using \b NSNotificationCenter to observe this notifications: 
 kPNClientSubscriptionDidCompleteNotification, kPNClientSubscriptionWillRestoreNotification, 
 kPNClientSubscriptionDidRestoreNotification, kPNClientSubscriptionDidFailNotification.
 
 @param channelObjects List of objects (which conforms to \b PNChannelProtocol data feed object protocol) on which 
                       client should subscribe.
 @param handlerBlock   The block which will be called by PubNub client as soon as subscription process state will 
                       change. The block takes three arguments: \c state - is \b PNSubscriptionProcessState enum field 
                       which describes current subscription state; \c channels - array of channels for which 
                       subscription process changed state; \c error - error because of which subscription failed. Always
                       check \a error.code to find out what caused error (check PNErrorCodes header file and use 
                       \a -localizedDescription / \a -localizedFailureReason and \a -localizedRecoverySuggestion to get 
                       human readable description for error).
 
 @since 3.7.0
 */
+ (void)          subscribeOn:(NSArray *)channelObjects
  withCompletionHandlingBlock:(PNClientChannelSubscriptionHandlerBlock)handlerBlock;

/**
 Subscribe client to the set of new channels. By default this method will trigger presence event by sending \a 'leave' presence to channels on which
 client already connected and then re-subscribe generating \a 'join' presence event.
 
 @code
 @endcode
 This method extends \a +subscribeOnChannels: and allow to specify client specific state.
 
 @code
 @endcode
 \b Example:
 
 @code
 [PubNub setConfiguration:[PNConfiguration defaultConfiguration] andDelegate:self];
 [PubNub connect];
 [PubNub subscribeOnChannels:[PNChannel channelsWithNames:@[@"iosdev", @"macosdev"]]
 withClientState:@{@"iosdev": @{@"firstName":@"John", @"lastName":@"Appleseed", @"age":@(240)}, @"macosdev": @{@"type": @"developer", @"fullAccess": @(NO)}}];
 @endcode
 
 And handle it with delegates:
 @code
 - (void)pubnubClient:(PubNub *)client didSubscribeOnChannels:(NSArray *)channels {
 
     // PubNub client subscribed on specified set of channels.
 }
 
 - (void)pubnubClient:(PubNub *)client subscriptionDidFailWithError:(NSError *)error {
 
     // PubNub client did fail to subscribe on requested set of channels.
     //
     // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
     // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
     // 'error.associatedObject' contains array of PNChannel instances on which PubNub client was unable to
     // subscribe.
 }
 @endcode
 
 There is also way to observe subscription process state from any place in your application using  \b PNObservationCenter:
 @code
 [[PNObservationCenter defaultCenter] addClientChannelSubscriptionStateObserver:self
 withCallbackBlock:^(PNSubscriptionProcessState state, NSArray *channels, PNError *error) {
 
     switch (state) {
         case PNSubscriptionProcessNotSubscribedState:
         
             // There should be a reason because of which subscription failed and it can be found in 'error' instance.
             //
             // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
             // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
             // 'error.associatedObject' contains array of PNChannel instances on which PubNub client was unable to
             // subscribe.
             break;
         case PNSubscriptionProcessSubscribedState:
         
             // PubNub client completed subscription on specified set of channels.
             break;
         case PNSubscriptionProcessWillRestoreState:
         
             // PubNub client is about to restore subscription on specified set of channels.
             break;
         case PNSubscriptionProcessRestoredState:
         
             // PubNub client completed subscription restore process.
             break;
     }
 }];
 @endcode
 
 Also observation can be done using \b NSNotificationCenter to observe this notifications: kPNClientSubscriptionDidCompleteNotification,
 kPNClientSubscriptionWillRestoreNotification, kPNClientSubscriptionDidRestoreNotification, kPNClientSubscriptionDidFailNotification.
 
 @param channels
 Array of \b PNChannel instances on which client should subscribe.
 
 @param clientState
 \b NSDictionary instance with list of parameters which should be bound to the client.
 
 @note You can delete previously configured key from state by passing [NSNull null] as value for target key and \b
 PubNub service will remove specified key from client's state at specified channel.
 
 @warning Client state should be represented with dictionary with channel names as keys and channel state as values. Channel state shouldn't contain any nesting and values should be one of: int, float or string. As keys should be used \b only channel names on which you are subscribing or already subscribed.
 
 @warning If you already subscribed on channel (for which already specified state) and will subscribe to another
 one, it will override old state (if keys are the same or will add new keys into old one).
 
 @since 3.6.0
 
 @see PNChannel class
 
 @see PNError class
 
 @see PNObservationCenter class
 
 @see +subscribeOnChannels:withCompletionHandlingBlock:
 */
+ (void)subscribeOnChannels:(NSArray *)channels withClientState:(NSDictionary *)clientState
   DEPRECATED_MSG_ATTRIBUTE(" Use '+subscribeOn:withClientState:' or '-subscribeOn:withClientState:' instead. Class "
                            "methods will be deprecated in future.");

/**
 Subscribe client to the set of new channels. By default this method will trigger presence event by sending \a 'leave' presence event to channels
 on which client already connected and then re-subscribe generating \a 'join' presence event.
 
 @code
 @endcode
 This method extends \a +subscribeOnChannels:withClientState: and allow to specify subscription process state change handler block.
 
 @code
 @endcode
 \b Example:
 
 @code
 [PubNub setConfiguration:[PNConfiguration defaultConfiguration] andDelegate:self];
 [PubNub connect];
 [PubNub subscribeOnChannels:[PNChannel channelsWithNames:@[@"iosdev", @"macosdev"]]
 withClientState:@{@"iosdev": @{@"firstName":@"John", @"lastName":@"Appleseed", @"age":@(240)}, @"macosdev": @{@"type": @"developer", @"fullAccess": @(NO)}}
 andCompletionHandlingBlock:^(PNSubscriptionProcessState state, NSArray *channels, PNError *subscriptionError) {
 
     switch (state) {
         case PNSubscriptionProcessNotSubscribedState:
         
             // There should be a reason because of which subscription failed and it can be found in 'error' instance
             // Update user interface to let user know that something went wrong and do something to recover from this state.
             //
             // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
             // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
             // 'error.associatedObject' contains array of PNChannel instances on which PubNub client was unable to
             // subscribe.
             break;
         case PNSubscriptionProcessSubscribedState:
 
             // PubNub client completed subscription on specified set of channels.
             break;
         default:
             break;
     }
 }];
 @endcode
 
 And handle it with delegates:
 @code
 - (void)pubnubClient:(PubNub *)client didSubscribeOnChannels:(NSArray *)channels {
 
     // PubNub client subscribed on specified set of channels.
 }
 
 - (void)pubnubClient:(PubNub *)client subscriptionDidFailWithError:(NSError *)error {
 
     // PubNub client did fail to subscribe on requested set of channels.
     //
     // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
     // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
     // 'error.associatedObject' contains array of PNChannel instances on which PubNub client was unable to
     // subscribe.
 }
 @endcode
 
 There is also way to observe subscription process state from any place in your application using  \b PNObservationCenter:
 @code
 [[PNObservationCenter defaultCenter] addClientChannelSubscriptionStateObserver:self
 withCallbackBlock:^(PNSubscriptionProcessState state, NSArray *channels, PNError *error) {
 
     switch (state) {
         case PNSubscriptionProcessNotSubscribedState:
         
             // There should be a reason because of which subscription failed and it can be found in 'error' instance.
             //
             // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
             // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
             // 'error.associatedObject' contains array of PNChannel instances on which PubNub client was unable to
             // subscribe.
             break;
         case PNSubscriptionProcessSubscribedState:
         
             // PubNub client completed subscription on specified set of channels.
             break;
         case PNSubscriptionProcessWillRestoreState:
         
             // PubNub client is about to restore subscription on specified set of channels.
             break;
         case PNSubscriptionProcessRestoredState:
         
             // PubNub client completed subscription restore process.
             break;
     }
 }];
 @endcode
 
 Also observation can be done using \b NSNotificationCenter to observe this notifications: kPNClientSubscriptionDidCompleteNotification,
 kPNClientSubscriptionWillRestoreNotification, kPNClientSubscriptionDidRestoreNotification, kPNClientSubscriptionDidFailNotification.
 
 @param channels
 Array of \b PNChannel instances on which client should subscribe.
 
 @param clientState
 \b NSDictionary instance with list of parameters which should be bound to the client.
 
 @param handlerBlock
 The block which will be called by PubNub client as soon as subscription process state will change. The block takes three arguments:
 \c state - is \b PNSubscriptionProcessState enumerator field which describes current subscription state; \c channels - array of channels for which
 subscription process changed state; \c error - error because of which subscription failed. Always check \a error.code to find out what caused
 error (check PNErrorCodes header file and use \a -localizedDescription / \a -localizedFailureReason and \a -localizedRecoverySuggestion to get
 human readable description for error).
 
 @note You can delete previously configured key from state by passing [NSNull null] as value for target key and \b
 PubNub service will remove specified key from client's state at specified channel.
 
 @warning Client state should be represented with dictionary with channel names as keys and channel state as values. Channel state shouldn't contain any nesting and values should be one of: int, float or string. As keys should be used \b only channel names on which you are subscribing or already subscribed.
 
 @warning If you already subscribed on channel (for which already specified state) and will subscribe to another
 one, it will override old state (if keys are the same or will add new keys into old one).
 
 @since 3.4.0
 
 @see PNChannel class
 
 @see PNError class
 
 @see PNObservationCenter class
 
 @see +subscribeOnChannels:
 */
+ (void) subscribeOnChannels:(NSArray *)channels withClientState:(NSDictionary *)clientState
  andCompletionHandlingBlock:(PNClientChannelSubscriptionHandlerBlock)handlerBlock
  DEPRECATED_MSG_ATTRIBUTE(" Use '+subscribeOn:withClientState:andCompletionHandlingBlock:' or "
                           "'-subscribeOn:withClientState:andCompletionHandlingBlock:' instead. Class methods will be "
                           "deprecated in future.");

/**
 Subscribe client to the set of new channels and channel groups. This method will trigger presence event by
 sending \a 'leave' presence event to channels on which client already connected and then re-subscribe generating
 \a 'join' presence event.
 
 @code
 @endcode
 This method extends \a +subscribeOn: and allow to specify client specific state.
 
 @code
 @endcode
 \b Example:
 
 @code
 [PubNub setConfiguration:[PNConfiguration defaultConfiguration] andDelegate:self];
 [PubNub connect];
 [PubNub subscribeOn:@[[PNChannel channelWithName:@"iosdev"],
                       [PNChannelGroup channelGroupWithName:@"ios" inNamespace:@"users"]]
     withClientState:@{@"iosdev": @{@"firstName":@"John", @"lastName":@"Appleseed", @"age":@(240)},
                       @"users:ios": @{@"type": @"developer", @"fullAccess": @(NO)}}];
 @endcode
 
 And handle it with delegates:
 @code
 - (void)pubnubClient:(PubNub *)client didSubscribeOn:(NSArray *)channelObjects {
 
     // PubNub client subscribed on specified set of channels.
 }
 
 - (void)pubnubClient:(PubNub *)client subscriptionDidFailWithError:(NSError *)error {
 
     // PubNub client did fail to subscribe on requested set of channels.
     //
     // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use 
     // -localizedDescription / -localizedFailureReason and -localizedRecoverySuggestion to get human readable 
     // description for error). 'error.associatedObject' contains array of objects (which conforms to 
     // PNChannelProtocol data feed object protocol) on which PubNub client was unable to subscribe.
 }
 @endcode
 
 There is also way to observe subscription process state from any place in your application using  
 \b PNObservationCenter:
 @code
 [[PNObservationCenter defaultCenter] addClientChannelSubscriptionStateObserver:self
 withCallbackBlock:^(PNSubscriptionProcessState state, NSArray *channels, PNError *error) {
 
     switch (state) {
         case PNSubscriptionProcessNotSubscribedState:
         
             // There should be a reason because of which subscription failed and it can be found in 'error' instance.
             //
             // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use 
             // -localizedDescription / -localizedFailureReason and -localizedRecoverySuggestion to get human readable 
             // description for error). 'error.associatedObject' contains array of objects (which conforms to 
             // PNChannelProtocol data feed object protocol) on which PubNub client was unable to subscribe.
             break;
         case PNSubscriptionProcessSubscribedState:
         
             // PubNub client completed subscription on specified set of channels.
             break;
         case PNSubscriptionProcessWillRestoreState:
         
             // PubNub client is about to restore subscription on specified set of channels.
             break;
         case PNSubscriptionProcessRestoredState:
         
             // PubNub client completed subscription restore process.
             break;
     }
 }];
 @endcode
 
 Also observation can be done using \b NSNotificationCenter to observe this notifications: 
 kPNClientSubscriptionDidCompleteNotification, kPNClientSubscriptionWillRestoreNotification, 
 kPNClientSubscriptionDidRestoreNotification, kPNClientSubscriptionDidFailNotification.
 
 @param channelObjects List of objects (which conforms to \b PNChannelProtocol data feed object protocol) on which 
                       client should subscribe.
 @param clientState    \b NSDictionary instance with list of parameters which should be bound to the client.
 
 @since 3.7.0
 */
+ (void)subscribeOn:(NSArray *)channelObjects withClientState:(NSDictionary *)clientState;

/**
 Subscribe client to the set of new channels and channel groups. This method will trigger presence event by 
 sending \a 'leave' presence event to channels on which client already connected and then re-subscribe generating 
 \a 'join' presence event.
 
 @code
 @endcode
 This method extends \a +subscribeOn:withClientState: and allow to specify subscription process state change handler 
 block.
 
 @code
 @endcode
 \b Example:
 
 @code
 [PubNub setConfiguration:[PNConfiguration defaultConfiguration] andDelegate:self];
 [PubNub connect];
 [PubNub subscribeOn:@[[PNChannel channelWithName:@"iosdev"],
                       [PNChannelGroup channelGroupWithName:@"ios" inNamespace:@"users"]]
     withClientState:@{@"iosdev": @{@"firstName":@"John", @"lastName":@"Appleseed", @"age":@(240)},
                       @"users:ios": @{@"type": @"developer", @"fullAccess": @(NO)}}
andCompletionHandlingBlock:^(PNSubscriptionProcessState state, NSArray *channels, PNError *subscriptionError) {
 
     switch (state) {
         case PNSubscriptionProcessNotSubscribedState:
         
             // There should be a reason because of which subscription failed and it can be found in 'error' instance
             // Update user interface to let user know that something went wrong and do something to recover from this 
             // state.
             //
             // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use 
             // -localizedDescription / -localizedFailureReason and -localizedRecoverySuggestion to get human readable 
             // description for error). 'error.associatedObject' contains array of PNChannel instances on which PubNub 
             //client was unable to subscribe.
             break;
         case PNSubscriptionProcessSubscribedState:
         
             // PubNub client completed subscription on specified set of channels.
             break;
         default:
             break;
     }
 }];
 @endcode
 
 And handle it with delegates:
 @code
 - (void)pubnubClient:(PubNub *)client didSubscribeOn:(NSArray *)channelObjects {
 
     // PubNub client subscribed on specified set of channels.
 }
 
 - (void)pubnubClient:(PubNub *)client subscriptionDidFailWithError:(NSError *)error {
 
     // PubNub client did fail to subscribe on requested set of channels.
     //
     // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use
     // -localizedDescription / -localizedFailureReason and -localizedRecoverySuggestion to get human readable 
     // description for error). 'error.associatedObject' contains array of objects (which conforms to 
     // PNChannelProtocol data feed object protocol) on which PubNub client was unable to subscribe.
 }
 @endcode
 
 There is also way to observe subscription process state from any place in your application using 
 \b PNObservationCenter:
 @code
 [[PNObservationCenter defaultCenter] addClientChannelSubscriptionStateObserver:self
 withCallbackBlock:^(PNSubscriptionProcessState state, NSArray *channels, PNError *error) {
 
     switch (state) {
         case PNSubscriptionProcessNotSubscribedState:
         
             // There should be a reason because of which subscription failed and it can be found in 'error' instance.
             //
             // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use 
             // -localizedDescription / -localizedFailureReason and -localizedRecoverySuggestion to get human readable 
             // description for error). 'error.associatedObject' contains array of objects (which conforms to 
             // PNChannelProtocol data feed object protocol) on which PubNub client was unable to subscribe.
             break;
         case PNSubscriptionProcessSubscribedState:
         
             // PubNub client completed subscription on specified set of channels.
             break;
         case PNSubscriptionProcessWillRestoreState:
 
             // PubNub client is about to restore subscription on specified set of channels.
             break;
         case PNSubscriptionProcessRestoredState:
 
             // PubNub client completed subscription restore process.
             break;
     }
 }];
 @endcode
 
 Also observation can be done using \b NSNotificationCenter to observe this notifications: 
 kPNClientSubscriptionDidCompleteNotification, kPNClientSubscriptionWillRestoreNotification, 
 kPNClientSubscriptionDidRestoreNotification, kPNClientSubscriptionDidFailNotification.
 
 @param channelObjects List of objects (which conforms to \b PNChannelProtocol data feed object protocol) on which 
                       client should subscribe.
 @param clientState    \b NSDictionary instance with list of parameters which should be bound to the client.
 @param handlerBlock   The block which will be called by PubNub client as soon as subscription process state will
                       change. The block takes three arguments: \c state - is \b PNSubscriptionProcessState enum field 
                       which describes current subscription state; \c channels - array of channels for which 
                       subscription process changed state; \c error - error because of which subscription failed. Always
                       check \a error.code to find out what caused error (check PNErrorCodes header file and use 
                       \a -localizedDescription / \a -localizedFailureReason and \a -localizedRecoverySuggestion to get 
                       human readable description for error).
 
 @since 3.7.0
 */
+ (void)         subscribeOn:(NSArray *)channelObjects withClientState:(NSDictionary *)clientState
  andCompletionHandlingBlock:(PNClientChannelSubscriptionHandlerBlock)handlerBlock;

/**
 Unsubscribe client from one channel. By default this method will trigger presence event by sending \a 'leave' presence event to channels on
 which client already subscribed and then re-subscribe generating \a 'join' presence event on the rest of channels.
 
 @code
 @endcode
 \b Example:
 
 @code
 [PubNub setConfiguration:[PNConfiguration defaultConfiguration] andDelegate:self];
 [PubNub connect];
 [PubNub subscribeFromChannel:[PNChannel channelsWithName:@"iosdev"]];
 [PubNub sendMessage:@"PubNub welcomes iOS developers" toChannel:[PNChannel channelWithName:@"iosdev"]];
 [PubNub unsubscribeFromChannel:[PNChannel channelsWithName:@"iosdev"]];
 @endcode
 
 And handle it with delegates:
 @code
 - (void)pubnubClient:(PubNub *)client didUnsubscribeOnChannels:(NSArray *)channels {
 
     // PubNub client successfully unsubscribed from specified set of channels.
 }
 
 - (void)pubnubClient:(PubNub *)client unsubscriptionDidFailWithError:(PNError *)error {
 
     // PubNub client did fail to unsubscribe from provided set of channels (they are in 'error.associatedObject') of 'error'.
 }
 @endcode
 
 There is also way to observe unsubscription process state from any place in your application using  \b PNObservationCenter:
 @code
 [[PNObservationCenter defaultCenter] addClientChannelUnsubscriptionObserver:self
 withCallbackBlock:^(NSArray *channels, PNError *error) {
 
     if (error == nil) {
     
         // PubNub client successfully unsubscribed from specified channels.
     }
     else {
     
         // PubNub did fail to unsubscribed from specified channels and reason can be found in error instance.
         //
         // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
         // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
         // 'error.associatedObject' contains array of PNChannel instances from which PubNub client was unable to
         // unsubscribe.
     }
 }];
 @endcode
 
 Also observation can be done using \b NSNotificationCenter to observe this notifications: kPNClientUnsubscriptionDidCompleteNotification,
 kPNClientUnsubscriptionDidFailNotification.
 
 @param channel
 \b PNChannel instance from which client should unsubscribe.
 
 @since 3.4.0
 
 @see PNChannel class
 
 @see PNError class
 
 @see PNObservationCenter class
 
 @see +unsubscribeFromChannel:withCompletionHandlingBlock:
 */
+ (void)unsubscribeFromChannel:(PNChannel *)channel
  DEPRECATED_MSG_ATTRIBUTE(" Use '+unsubscribeFrom:' or '-unsubscribeFrom:' instead. "
                           "Class method will be removed in future.");

/**
 Unsubscribe client from one channel. By default this method will trigger presence event by sending \a 'leave' presence event to channels on
 which client already subscribed and then re-subscribe generating \a 'join' presence event on the rest of channels.
 
 @code
 @endcode
 This method extends \a +unsubscribeFromChannel: and allow to specify unsubscription process state change handler block.
 
 @code
 @endcode
 \b Example:
 
 @code
 [PubNub setConfiguration:[PNConfiguration defaultConfiguration] andDelegate:self];
 [PubNub connect];
 [PubNub subscribeFromChannel:[PNChannel channelsWithName:@"iosdev"]];
 [PubNub sendMessage:@"PubNub welcomes iOS developers" toChannel:[PNChannel channelWithName:@"iosdev"]];
 [PubNub unsubscribeFromChannel:[PNChannel channelWithName:@"iosdev"]
 withCompletionHandlingBlock:^(NSArray *channels, PNError *error) {
 
     if (error == nil) {
     
         // PubNub client successfully unsubscribed from specified channels.
     }
     else {
     
         // PubNub did fail to unsubscribed from specified channels and reason can be found in error instance.
         //
         // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
         // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
         // 'error.associatedObject' contains array of PNChannel instances from which PubNub client was unable to
         // unsubscribe.
     }
 }];
 @endcode
 
 And handle it with delegates:
 @code
 - (void)pubnubClient:(PubNub *)client didUnsubscribeOnChannels:(NSArray *)channels {
 
     // PubNub client successfully unsubscribed from specified set of channels.
 }
 
 - (void)pubnubClient:(PubNub *)client unsubscriptionDidFailWithError:(PNError *)error {
 
     // PubNub client did fail to unsubscribe from provided set of channels.
     //
     // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
     // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
     // 'error.associatedObject' contains array of PNChannel instances from which PubNub client was unable to
     // unsubscribe.
 }
 @endcode
 
 There is also way to observe unsubscription process state from any place in your application using  \b PNObservationCenter:
 @code
 [[PNObservationCenter defaultCenter] addClientChannelUnsubscriptionObserver:self
 withCallbackBlock:^(NSArray *channels, PNError *error) {
 
     if (error == nil) {
     
         // PubNub client successfully unsubscribed from specified channels.
     }
     else {
     
         // PubNub did fail to unsubscribed from specified channels and reason can be found in error instance.
         //
         // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
         // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
         // 'error.associatedObject' contains array of PNChannel instances from which PubNub client was unable to
         // unsubscribe.
     }
 }];
 @endcode
 
 Also observation can be done using \b NSNotificationCenter to observe this notifications: kPNClientUnsubscriptionDidCompleteNotification,
 kPNClientUnsubscriptionDidFailNotification.
 
 @param channel
 \b PNChannel instance from which client should unsubscribe.
 
 @param handlerBlock
 The block whichh will be called by PubNub client as soon as subscription process state will change. The block takes two arguments:
 \c channels - array of \b PNChannel instances from which client unsubscribe; \c error - error because of which unsubscription failed.
 Always check \a error.code to find out what caused error (check PNErrorCodes header file and use \a -localizedDescription /
 \a -localizedFailureReason and \a -localizedRecoverySuggestion to get human readable description for error).
 
 @since 3.4.0
 
 @see PNChannel class
 
 @see PNError class
 
 @see PNObservationCenter class
 
 @see +unsubscribeFromChannel:
 */
+ (void)unsubscribeFromChannel:(PNChannel *)channel
   withCompletionHandlingBlock:(PNClientChannelUnsubscriptionHandlerBlock)handlerBlock
  DEPRECATED_MSG_ATTRIBUTE(" Use '+unsubscribeFrom:withCompletionHandlingBlock:' or "
                           "'-unsubscribeFrom:withCompletionHandlingBlock:' instead. Class methods "
                           "will be deprecated in future.");

/**
 Unsubscribe client from set of channels. By default this method will trigger presence event by sending \a 'leave' presence event to channels on
 which client already subscribed and then re-subscribe generating \a 'join' presence event on the rest of channels.
 
 @code
 @endcode
 \b Example:
 
 @code
 [PubNub setConfiguration:[PNConfiguration defaultConfiguration] andDelegate:self];
 [PubNub connect];
 [PubNub subscribeFromChannel:[PNChannel channelsWithName:@"iosdev"]];
 [PubNub sendMessage:@"PubNub welcomes iOS developers" toChannel:[PNChannel channelWithName:@"iosdev"]];
 [PubNub unsubscribeFromChannels:[PNChannel channelsWithNames:@[@"iosdev", @"macosdev"]]];
 @endcode
 
 And handle it with delegates:
 @code
 - (void)pubnubClient:(PubNub *)client didUnsubscribeOnChannels:(NSArray *)channels {
 
     // PubNub client successfully unsubscribed from specified set of channels.
 }
 
 - (void)pubnubClient:(PubNub *)client unsubscriptionDidFailWithError:(PNError *)error {
 
     // PubNub client did fail to unsubscribe from provided set of channels.
     //
     // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
     // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
     // 'error.associatedObject' contains array of PNChannel instances from which PubNub client was unable to
     // unsubscribe.
 }
 @endcode
 
 There is also way to observe unsubscription process state from any place in your application using  \b PNObservationCenter:
 @code
 [[PNObservationCenter defaultCenter] addClientChannelUnsubscriptionObserver:self
 withCallbackBlock:^(NSArray *channels, PNError *error) {
 
     if (error == nil) {
     
         // PubNub client successfully unsubscribed from specified channels.
     }
     else {
     
         // PubNub did fail to unsubscribed from specified channels and reason can be found in error instance.
         //
         // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
         // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
         // 'error.associatedObject' contains array of PNChannel instances from which PubNub client was unable to
         // unsubscribe.
     }
 }];
 @endcode
 
 Also observation can be done using \b NSNotificationCenter to observe this notifications: kPNClientUnsubscriptionDidCompleteNotification,
 kPNClientUnsubscriptionDidFailNotification.
 
 @param channels
 Array of \b PNChannel instances from which client should unsubscribe.
 
 @since 3.4.0
 
 @see PNChannel class
 
 @see PNError class
 
 @see PNObservationCenter class
 
 @see +unsubscribeFromChannels:withCompletionHandlingBlock:
 */
+ (void)unsubscribeFromChannels:(NSArray *)channels
  DEPRECATED_MSG_ATTRIBUTE(" Use '+unsubscribeFrom:' or '-unsubscribeFrom:' instead. "
                           "Class method will be removed in future.");

/**
 Unsubscribe client from set of channels. By default this method will trigger presence event by sending \a 'leave' presence event to channels on
 which client already subscribed and then re-subscribe generating \a 'join' presence event on the rest of channels.
 
 @code
 @endcode
 This method extends \a +unsubscribeFromChannels: and allow to specify unsubscription process state change handler block.
 
 @code
 @endcode
 \b Example:
 
 @code
 [PubNub setConfiguration:[PNConfiguration defaultConfiguration] andDelegate:self];
 [PubNub connect];
 [PubNub subscribeFromChannel:[PNChannel channelsWithName:@"iosdev"]];
 [PubNub sendMessage:@"PubNub welcomes iOS developers" toChannel:[PNChannel channelWithName:@"iosdev"]];
 [PubNub unsubscribeFromChannels:[PNChannel channelsWithNames:@[@"iosdev", @"macosdev"]]
 withCompletionHandlingBlock:^(NSArray *channels, PNError *error) {
 
     if (error == nil) {
     
         // PubNub client successfully unsubscribed from specified channels
     }
     else {
     
         // PubNub did fail to unsubscribed from specified channels and reason can be found in error instance
     }
 }];
 @endcode
 
 And handle it with delegates:
 @code
 - (void)pubnubClient:(PubNub *)client didUnsubscribeOnChannels:(NSArray *)channels {
 
     // PubNub client successfully unsubscribed from specified set of channels.
 }
 
 - (void)pubnubClient:(PubNub *)client unsubscriptionDidFailWithError:(PNError *)error {
 
     // PubNub client did fail to unsubscribe from provided set of channels (they are in 'error.associatedObject') of 'error'.
 }
 @endcode
 
 There is also way to observe unsubscription process state from any place in your application using  \b PNObservationCenter:
 @code
 [[PNObservationCenter defaultCenter] addClientChannelUnsubscriptionObserver:self
 withCallbackBlock:^(NSArray *channels, PNError *error) {
 
     if (error == nil) {
     
         // PubNub client successfully unsubscribed from specified channels
     }
     else {
     
         // PubNub did fail to unsubscribed from specified channels and reason can be found in error instance
     }
 }];
 @endcode
 
 Also observation can be done using \b NSNotificationCenter to observe this notifications: kPNClientUnsubscriptionDidCompleteNotification,
 kPNClientUnsubscriptionDidFailNotification.
 
 @param channels
 Array of \b PNChannel instances from which client should unsubscribe.
 
 @param handlerBlock
 The block which will be called by PubNub client as soon as unsubscription process state will change. The block takes two arguments:
 \c channels - array of \b PNChannel instances from which client unsubscribe; \c error - error because of which unsubscription failed.
 Always check \a error.code to find out what caused error (check PNErrorCodes header file and use \a -localizedDescription /
 \a -localizedFailureReason and \a -localizedRecoverySuggestion to get human readable description for error).
 
 @since 3.4.0
 
 @see PNChannel class
 
 @see PNError class
 
 @see PNObservationCenter class
 
 @see +unsubscribeFromChannels:
 */
+ (void)unsubscribeFromChannels:(NSArray *)channels
    withCompletionHandlingBlock:(PNClientChannelUnsubscriptionHandlerBlock)handlerBlock
  DEPRECATED_MSG_ATTRIBUTE(" Use '+unsubscribeFrom:withCompletionHandlingBlock:' or "
                           "'-unsubscribeFrom:withCompletionHandlingBlock:' instead. Class methods "
                           "will be deprecated in future.");

/**
 Unsubscribe client from set of channels. By default this method will trigger presence event by sending \a 'leave' 
 presence event to channels on which client already subscribed and then re-subscribe generating \a 'join' presence 
 event on the rest of channels.
 
 @code
 @endcode
 \b Example:
 
 @code
 [PubNub setConfiguration:[PNConfiguration defaultConfiguration] andDelegate:self];
 [PubNub connect];
 [PubNub subscribeFromChannelsAndGroups:@[[PNChannel channelsWithName:@"iosdev"]]];
 [PubNub sendMessage:@"PubNub welcomes iOS developers" toChannel:[PNChannel channelWithName:@"iosdev"]];
 [PubNub unsubscribeFrom:[PNChannel channelsWithNames:@[@"iosdev", @"macosdev"]]];
 @endcode
 
 And handle it with delegates:
 @code
 - (void)pubnubClient:(PubNub *)client didUnsubscribeFrom:(NSArray *)channelObjects {
 
     // PubNub client successfully unsubscribed from specified set of channels.
 }
 
 - (void)pubnubClient:(PubNub *)client unsubscriptionDidFailWithError:(PNError *)error {
 
     // PubNub client did fail to unsubscribe from provided set of channels.
     //
     // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use 
     // -localizedDescription / -localizedFailureReason and -localizedRecoverySuggestion to get human readable 
     // description for error). 'error.associatedObject' contains array of objects (which conforms to PNChannelProtocol 
     // data feed object protocol) from which PubNub client was unable to unsubscribe.
 }
 @endcode
 
 There is also way to observe unsubscription process state from any place in your application using  \b PNObservationCenter:
 @code
 [[PNObservationCenter defaultCenter] addClientChannelUnsubscriptionObserver:self
 withCallbackBlock:^(NSArray *channels, PNError *error) {
 
     if (error == nil) {
     
         // PubNub client successfully unsubscribed from specified channels.
     }
     else {
     
         // PubNub did fail to unsubscribed from specified channels and reason can be found in error instance.
         //
         // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use 
         // -localizedDescription / -localizedFailureReason and -localizedRecoverySuggestion to get human readable 
         // description for error). 'error.associatedObject' contains array of objects (which conforms to 
         // PNChannelProtocol data feed object protocol) from which PubNub client was unable to unsubscribe.
     }
 }];
 @endcode
 
 Also observation can be done using \b NSNotificationCenter to observe this notifications: 
 kPNClientUnsubscriptionDidCompleteNotification, kPNClientUnsubscriptionDidFailNotification.
 
 @param channelObjects List of objects (which conforms to \b PNChannelProtocol data feed object protocol) from which
                       client should unsubscribe.
 
 @since 3.7.0
 */
+ (void)unsubscribeFrom:(NSArray *)channelObjects;

/**
 Unsubscribe client from set of channels. By default this method will trigger presence event by sending \a 'leave' 
 presence event to channels on which client already subscribed and then re-subscribe generating \a 'join' presence
 event on the rest of channels.
 
 @code
 @endcode
 This method extends \a +unsubscribeFrom: and allow to specify unsubscription process state change handler block.
 
 @code
 @endcode
 \b Example:
 
 @code
 [PubNub setConfiguration:[PNConfiguration defaultConfiguration] andDelegate:self];
 [PubNub connect];
 [PubNub subscribeFromChannelsAndGroups:@[[PNChannel channelsWithName:@"iosdev"]]];
 [PubNub sendMessage:@"PubNub welcomes iOS developers" toChannel:[PNChannel channelWithName:@"iosdev"]];
 [PubNub unsubscribeFrom:[PNChannel channelsWithNames:@[@"iosdev", @"macosdev"]]
 withCompletionHandlingBlock:^(NSArray *channels, PNError *error) {
 
     if (error == nil) {
     
         // PubNub client successfully unsubscribed from specified channels.
     }
     else {
     
         // PubNub did fail to unsubscribed from specified channels and reason can be found in error instance.
         //
         // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use 
         // -localizedDescription / -localizedFailureReason and -localizedRecoverySuggestion to get human readable 
         // description for error). 'error.associatedObject' contains array of PNChannel instances from which PubNub 
         // client was unable to unsubscribe.
     }
 }];
 @endcode
 
 And handle it with delegates:
 @code
 - (void)pubnubClient:(PubNub *)client didUnsubscribeFrom:(NSArray *)channelObjects {
 
     // PubNub client successfully unsubscribed from specified set of channels.
 }
 
 - (void)pubnubClient:(PubNub *)client unsubscriptionDidFailWithError:(PNError *)error {
 
     // PubNub client did fail to unsubscribe from provided set of channels.
     //
     // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use 
     // -localizedDescription / -localizedFailureReason and -localizedRecoverySuggestion to get human readable 
     // description for error). 'error.associatedObject' contains array of objects (which conforms to PNChannelProtocol 
     // data feed object protocol) from which PubNub client was unable to unsubscribe.
 }
 @endcode
 
 There is also way to observe unsubscription process state from any place in your application using 
 \b PNObservationCenter:
 @code
 [[PNObservationCenter defaultCenter] addClientChannelUnsubscriptionObserver:self
 withCallbackBlock:^(NSArray *channels, PNError *error) {

     if (error == nil) {
     
         // PubNub client successfully unsubscribed from specified channels.
     }
     else {
     
         // PubNub did fail to unsubscribed from specified channels and reason can be found in error instance.
         //
         // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use 
         // -localizedDescription / -localizedFailureReason and -localizedRecoverySuggestion to get human readable 
         // description for error). 'error.associatedObject' contains array of objects (which conforms to
         // PNChannelProtocol data feed object protocol) from which PubNub client was unable to unsubscribe.
     }
 }];
 @endcode
 
 Also observation can be done using \b NSNotificationCenter to observe this notifications: 
 kPNClientUnsubscriptionDidCompleteNotification, kPNClientUnsubscriptionDidFailNotification.
 
 @param channelObjects List of objects (which conforms to \b PNChannelProtocol data feed object protocol) from which
                       client should unsubscribe.
 @param handlerBlock   The block which will be called by PubNub client as soon as unsubscription process state will
                       change. The block takes two arguments: \c channels - array of \b PNChannel instances from which
                       client unsubscribe; \c error - error because of which unsubscription failed. Always check
                       \a error.code to find out what caused error (check PNErrorCodes header file and use
                       \a -localizedDescription / \a -localizedFailureReason and \a -localizedRecoverySuggestion to get
                       human readable description for error).
 
 @since 3.7.0
 */
+ (void)    unsubscribeFrom:(NSArray *)channelObjects
withCompletionHandlingBlock:(PNClientChannelUnsubscriptionHandlerBlock)handlerBlock;


#pragma mark - Instance methods

/**
 Retrieve list of channels on which \b PubNub client subscribed at this moment.
 
 @code
 @endcode
 \b Example:
 
 @code
 PubNub *pubNub = [PubNub clientWithConfiguration:[PNConfiguration defaultConfiguration] andDelegate:self];
 [pubNub connect];
 [pubNub subscribeOnChannels:[PNChannel channelsWithNames:@[@"iosdev", @"macosdev"]]
 withCompletionHandlingBlock:^(PNSubscriptionProcessState state, NSArray *channels, PNError *subscriptionError) {
 
     if (subscriptionError == nil) {
     
         NSLog(@"Channels: %@", [pubNub subscribedChannels]); // iosdev, macosdev
     }
     else {
     
         // Update user interface to let user know that something went wrong and do something to recover from this state.
         //
         // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
         // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
         // 'error.associatedObject' contains array of PNChannel instances on which PubNub client was unable to
         // subscribe.
     }
 }];
 @endcode
 
 @note It will return list of the channels even if \b PubNub client in \a 'disconnected' because of error. It is because after connection restore completions
 it will restore subscription (if allowed by user via \a resubscribeOnConnectionRestore field in \b PNConfiguration instance or
 \a -shouldResubscribeOnConnectionRestore delegate method).
 
 @return array of \b PNChannel instances on which \b PubNub client subscribed at this moment.
 
 @since 3.4.0
 
 @see PNChannel class
 
 @see -isSubscribedOnChannel:
 */
- (NSArray *)subscribedChannels  DEPRECATED_MSG_ATTRIBUTE(" Use '-subscribedObjectsList' instead.");

/**
 @brief Retrieve list of data feed objects on which \b PubNub client subscribed at this moment.

 @code
 @endcode
 \b Example:

 @code
 PubNub *pubNub = [PubNub clientWithConfiguration:[PNConfiguration defaultConfiguration] andDelegate:self];
 [pubNub connect];
 [pubNub subscribeOn:[PNChannel channelsWithNames:@[@"iosdev", @"macosdev"]]
 withCompletionHandlingBlock:^(PNSubscriptionProcessState state, NSArray *channels, PNError *subscriptionError) {

     if (subscriptionError == nil) {

         NSLog(@"Channels: %@", [pubNub subscribedObjectsList]); // iosdev, macosdev
     }
     else {

         // Update user interface to let user know that something went wrong and do something to recover from this state.
         //
         // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
         // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
         // 'error.associatedObject' contains array of PNChannel instances on which PubNub client was unable to
         // subscribe.
     }
 }];
 @endcode

 @note It will return list of the data feed objects even if \b PubNub client in \a 'disconnected' because of error. It
 is because after connection restore completions it will restore subscription (if allowed by user via
 \a resubscribeOnConnectionRestore field in \b PNConfiguration instance or \a -shouldResubscribeOnConnectionRestore
 delegate method).

 @return array objects (which conforms to \b PNChannelProtocol data feed object protocol) on which \b PubNub client
 subscribed at this moment.

 @since 3.7.0
 */
- (NSArray *)subscribedObjectsList;

/**
 Check whether client subscribed on specified channel or not.
 
 @code
 @endcode
 \b Example:
 
 @code
 PubNub *pubNub = [PubNub clientWithConfiguration:[PNConfiguration defaultConfiguration] andDelegate:self];
 [pubNub connect];
 [pubNub subscribeOnChannels:[PNChannel channelsWithNames:@[@"iosdev", @"macosdev"]]
 withCompletionHandlingBlock:^(PNSubscriptionProcessState state, NSArray *channels, PNError *subscriptionError) {
 
     if (subscriptionError == nil) {
     
         NSLog(@"Is subscribed on 'iosdev' channel? %@", [pubNub isSubscribedOnChannel:[PNChannel channelWithName:@"iosdev"]] ? @"YES" : @"NO"); // YES
         NSLog(@"Is subscribed on 'androiddev' channel? %@", [pubNub isSubscribedOnChannel:[PNChannel channelWithName:@"androiddev"]] ? @"YES" : @"NO"); // NO
     }
     else {
     
         // Update user interface to let user know that something went wrong and do something to recover from this state.
         //
         // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
         // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
         // 'error.associatedObject' contains array of PNChannel instances on which PubNub client was unable to
         // subscribe.
     }
 }];
 @endcode
 
 @param channel
 \b PNChannel instance against which check should be performed.
 
 @return \c YES if \b PubNub client subscribed on provided channel.
 
 @since 3.4.0
 
 @see PNChannel class
 
 @see -subscribedChannels
 */
- (BOOL)isSubscribedOnChannel:(PNChannel *)channel
  DEPRECATED_MSG_ATTRIBUTE(" Use '-isSubscribedOn:' instead.");

/**
 @brief Check whether client subscribed on specified data feed object or not.

 @code
 @endcode
 \b Example:

 @code
 PubNub *pubNub = [PubNub clientWithConfiguration:[PNConfiguration defaultConfiguration] andDelegate:self];
 [pubNub connect];
 [pubNub subscribeOn:[PNChannel channelsWithNames:@[@"iosdev", @"macosdev"]]
 withCompletionHandlingBlock:^(PNSubscriptionProcessState state, NSArray *channels, PNError *subscriptionError) {

     if (subscriptionError == nil) {

         NSLog(@"Is subscribed on 'iosdev' channel? %@", [pubNub isSubscribedOn:[PNChannel channelWithName:@"iosdev"]] ? @"YES" : @"NO"); // YES
         NSLog(@"Is subscribed on 'androiddev' channel? %@", [pubNub isSubscribedOn:[PNChannel channelWithName:@"androiddev"]] ? @"YES" : @"NO"); // NO
     }
     else {

         // Update user interface to let user know that something went wrong and do something to recover from this state.
         //
         // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
         // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
         // 'error.associatedObject' contains array of PNChannel instances on which PubNub client was unable to
         // subscribe.
     }
 }];
 @endcode

 @param object Object (which conforms to \b PNChannelProtocol data feed object protocol) like \b PNChannel and
               \b PNChannelGroup against which check should be performed

 @return \c YES if \b PubNub client subscribed on provided data feed object.

 @since 3.7.0
 */
- (BOOL)isSubscribedOn:(id <PNChannelProtocol>)object;

/**
 Subscribe client to one more channel. By default this method will trigger presence event by sending \a 'leave' presence event to channels on
 which \b PubNub client already subscribed and then re-subscribe generating \a 'join' presence event.
 
 @code
 @endcode
 \b Example:
 
 @code
 PubNub *pubNub = [PubNub clientWithConfiguration:[PNConfiguration defaultConfiguration] andDelegate:self];
 [pubNub connect];
 [pubNub subscribeOnChannel:[PNChannel channelsWithName:@"iosdev"]];
 @endcode
 
 And handle it with delegates:
 @code
 - (void)pubnubClient:(PubNub *)client didSubscribeOnChannels:(NSArray *)channels {
 
     // PubNub client subscribed on specified set of channels.
 }
 
 - (void)pubnubClient:(PubNub *)client subscriptionDidFailWithError:(NSError *)error {
 
     // PubNub client did fail to subscribe on requested set of channels.
     //
     // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
     // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
     // 'error.associatedObject' contains array of PNChannel instances on which PubNub client was unable to
     // subscribe.
 }
 @endcode
 
 There is also way to observe subscription process state from any place in your application using  \b PNObservationCenter:
 @code
 [pubNub.observationCenter addClientChannelSubscriptionStateObserver:self
 withCallbackBlock:^(PNSubscriptionProcessState state, NSArray *channels, PNError *error) {
 
     switch (state) {
         case PNSubscriptionProcessNotSubscribedState:
         
             // There should be a reason because of which subscription failed and it can be found in 'error' instance.
             //
             // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
             // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
             // 'error.associatedObject' contains array of PNChannel instances on which PubNub client was unable to
             // subscribe.
             break;
         case PNSubscriptionProcessSubscribedState:
         
             // PubNub client completed subscription on specified set of channels.
             break;
         case PNSubscriptionProcessWillRestoreState:
         
             // PubNub client is about to restore subscription on specified set of channels.
             break;
         case PNSubscriptionProcessRestoredState:
         
             // PubNub client completed subscription restore process
             break;
     }
 }];
 @endcode
 
 Also observation can be done using \b NSNotificationCenter to observe this notifications: kPNClientSubscriptionDidCompleteNotification,
 kPNClientSubscriptionWillRestoreNotification, kPNClientSubscriptionDidRestoreNotification, kPNClientSubscriptionDidFailNotification.
 
 @param channel
 \b PNChannel instance on which client should subscribe.
 
 @since 3.4.0
 
 @see PNChannel class
 
 @see PNError class
 
 @see PNObservationCenter class
 
 @see -subscribeOnChannel:withCompletionHandlingBlock:
 */
- (void)subscribeOnChannel:(PNChannel *)channel DEPRECATED_MSG_ATTRIBUTE(" Use '-subscribeOn:' instead.");

/**
 Subscribe client to one more channel. By default this method will trigger presence event by sending \a 'leave' presence event to channels on which
 client already subscribed and then re-subscribe generating \a 'join' presence event.
 
 @code
 @endcode
 This method extends \a -subscribeOnChannel: and allow to specify subscription process state change handler block.
 
 @code
 @endcode
 \b Example:
 
 @code
 PubNub *pubNub = [PubNub clientWithConfiguration:[PNConfiguration defaultConfiguration] andDelegate:self];
 [pubNub connect];
 [pubNub subscribeOnChannel:[PNChannel channelsWithName:@"iosdev"]
 withCompletionHandlingBlock:^(PNSubscriptionProcessState state, NSArray *channels, PNError *subscriptionError) {
 
     switch (state) {
         case PNSubscriptionProcessNotSubscribedState:
         
             // There should be a reason because of which subscription failed and it can be found in 'error' instance.
             //
             // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
             // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
             // 'error.associatedObject' contains array of PNChannel instances on which PubNub client was unable to
             // subscribe.
             break;
         case PNSubscriptionProcessSubscribedState:
         
             // PubNub client completed subscription on specified set of channels.
             break;
     }
 }];
 @endcode
 
 And handle it with delegates:
 @code
 - (void)pubnubClient:(PubNub *)client didSubscribeOnChannels:(NSArray *)channels {
 
     // PubNub client subscribed on specified set of channels.
 }
 
 - (void)pubnubClient:(PubNub *)client subscriptionDidFailWithError:(NSError *)error {
 
     // PubNub client did fail to subscribe on requested set of channels.
     //
     // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
     // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
     // 'error.associatedObject' contains array of PNChannel instances on which PubNub client was unable to
     // subscribe.
 }
 @endcode
 
 There is also way to observe subscription process state from any place in your application using  \b PNObservationCenter:
 @code
 [pubNub.observationCenter addClientChannelSubscriptionStateObserver:self
 withCallbackBlock:^(PNSubscriptionProcessState state, NSArray *channels, PNError *error) {
 
     switch (state) {
         case PNSubscriptionProcessNotSubscribedState:
         
             // There should be a reason because of which subscription failed and it can be found in 'error' instance.
             //
             // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
             // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
             // 'error.associatedObject' contains array of PNChannel instances on which PubNub client was unable to
             // subscribe.
             break;
         case PNSubscriptionProcessSubscribedState:
         
             // PubNub client completed subscription on specified set of channels.
             break;
         case PNSubscriptionProcessWillRestoreState:
         
             // PubNub client is about to restore subscription on specified set of channels.
             break;
         case PNSubscriptionProcessRestoredState:
         
             // PubNub client completed subscription restore process.
             break;
     }
 }];
 @endcode
 
 Also observation can be done using \b NSNotificationCenter to observe this notifications: kPNClientSubscriptionDidCompleteNotification,
 kPNClientSubscriptionWillRestoreNotification, kPNClientSubscriptionDidRestoreNotification, kPNClientSubscriptionDidFailNotification.
 
 @param channel
 \b PNChannel instance on which client should subscribe.
 
 @param handlerBlock
 The block which will be called by \b PubNub client as soon as subscription process state will change. The block takes three arguments:
 \c state - is \b PNSubscriptionProcessState enumerator field which describes current subscription state; \c channels - array of \b PNChannel instances for which
 subscription process changed state; \c error - error because of which subscription failed. Always check \a error.code to find out what caused error
 (check \b PNErrorCodes header file and use \a -localizedDescription / \a -localizedFailureReason and \a -localizedRecoverySuggestion to get human
 readable description for error).
 
 @since 3.4.0
 
 @see PNChannel class
 
 @see PNError class
 
 @see PNObservationCenter class
 
 @sse +subscribeOnChannel:
 */
- (void)   subscribeOnChannel:(PNChannel *)channel
  withCompletionHandlingBlock:(PNClientChannelSubscriptionHandlerBlock)handlerBlock
  DEPRECATED_MSG_ATTRIBUTE(" Use '-subscribeOn:withCompletionHandlingBlock:' instead.");

/**
 Subscribe client to one more channel. By default this method will trigger presence event by sending \a 'leave' presence event to channels on
 which \b PubNub client already subscribed and then re-subscribe generating \a 'join' presence event.
 
 @code
 @endcode
 This method extends \a -subscribeOnChannel: and allow to specify client specific state.
 
 @code
 @endcode
 \b Example:
 
 @code
 PubNub *pubNub = [PubNub clientWithConfiguration:[PNConfiguration defaultConfiguration] andDelegate:self];
 [pubNub connect];
 [pubNub subscribeOnChannel:[PNChannel channelsWithName:@"iosdev"]
 withClientState:@{@"firstName":@"John", @"lastName":@"Appleseed", @"age":@(240)}];
 @endcode
 
 And handle it with delegates:
 @code
 - (void)pubnubClient:(PubNub *)client didSubscribeOnChannels:(NSArray *)channels {
 
     // PubNub client subscribed on specified set of channels.
 }
 
 - (void)pubnubClient:(PubNub *)client subscriptionDidFailWithError:(NSError *)error {
 
     // PubNub client did fail to subscribe on requested set of channels.
     //
     // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
     // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
     // 'error.associatedObject' contains array of PNChannel instances on which PubNub client was unable to
     // subscribe.
 }
 @endcode
 
 There is also way to observe subscription process state from any place in your application using  \b PNObservationCenter:
 @code
 [pubNub.observationCenter addClientChannelSubscriptionStateObserver:self
 withCallbackBlock:^(PNSubscriptionProcessState state, NSArray *channels, PNError *error) {
 
     switch (state) {
         case PNSubscriptionProcessNotSubscribedState:
         
             // There should be a reason because of which subscription failed and it can be found in 'error' instance.
             //
             // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
             // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
             // 'error.associatedObject' contains array of PNChannel instances on which PubNub client was unable to
             // subscribe.
             break;
         case PNSubscriptionProcessSubscribedState:
         
             // PubNub client completed subscription on specified set of channels.
             break;
         case PNSubscriptionProcessWillRestoreState:
         
             // PubNub client is about to restore subscription on specified set of channels.
             break;
         case PNSubscriptionProcessRestoredState:
         
             // PubNub client completed subscription restore process
             break;
     }
 }];
 @endcode
 
 Also observation can be done using \b NSNotificationCenter to observe this notifications: kPNClientSubscriptionDidCompleteNotification,
 kPNClientSubscriptionWillRestoreNotification, kPNClientSubscriptionDidRestoreNotification, kPNClientSubscriptionDidFailNotification.
 
 @param channel
 \b PNChannel instance on which client should subscribe.
 
 @param clientState
 \b NSDictionary instance with list of parameters which should be bound to the client.
 
 @note You can delete previously configured key from state by passing [NSNull null] as value for target key and \b
 PubNub service will remove specified key from client's state at specified channel.
 
 @warning Client state shouldn't contain any nesting and values should be one of: int, float or string.
 
 @warning If you already subscribed on channel (for which already specified state) and will subscribe to another
 one, it will override old state (if keys are the same or will add new keys into old one).
 
 @since 3.6.0
 
 @see PNChannel class
 
 @see PNError class
 
 @see PNObservationCenter class
 
 @see -subscribeOnChannel:withCompletionHandlingBlock:
 */
- (void)subscribeOnChannel:(PNChannel *)channel withClientState:(NSDictionary *)clientState
  DEPRECATED_MSG_ATTRIBUTE(" Use '-subscribeOn:withClientState:' instead.");

/**
 Subscribe client to one more channel. By default this method will trigger presence event by sending \a 'leave' presence event to channels on which
 client already subscribed and then re-subscribe generating \a 'join' presence event.
 
 @code
 @endcode
 This method extends \a -subscribeOnChannel:withClientState: and allow to specify subscription process state change handler
 block.
 
 @code
 @endcode
 \b Example:
 
 @code
 PubNub *pubNub = [PubNub clientWithConfiguration:[PNConfiguration defaultConfiguration] andDelegate:self];
 [pubNub connect];
 [pubNub subscribeOnChannel:[PNChannel channelsWithName:@"iosdev"]
 withClientState:@{@"firstName":@"John", @"lastName":@"Appleseed", @"age":@(240)}
 andCompletionHandlingBlock:^(PNSubscriptionProcessState state, NSArray *channels, PNError *subscriptionError) {
 
     switch (state) {
         case PNSubscriptionProcessNotSubscribedState:
         
             // There should be a reason because of which subscription failed and it can be found in 'error' instance.
             //
             // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
             // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
             // 'error.associatedObject' contains array of PNChannel instances on which PubNub client was unable to
             // subscribe.
             break;
         case PNSubscriptionProcessSubscribedState:
         
             // PubNub client completed subscription on specified set of channels.
             break;
     }
 }];
 @endcode
 
 And handle it with delegates:
 @code
 - (void)pubnubClient:(PubNub *)client didSubscribeOnChannels:(NSArray *)channels {
 
     // PubNub client subscribed on specified set of channels.
 }
 
 - (void)pubnubClient:(PubNub *)client subscriptionDidFailWithError:(NSError *)error {
 
     // PubNub client did fail to subscribe on requested set of channels.
     //
     // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
     // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
     // 'error.associatedObject' contains array of PNChannel instances on which PubNub client was unable to
     // subscribe.
 }
 @endcode
 
 There is also way to observe subscription process state from any place in your application using  \b PNObservationCenter:
 @code
 [pubNub.observationCenter addClientChannelSubscriptionStateObserver:self
 withCallbackBlock:^(PNSubscriptionProcessState state, NSArray *channels, PNError *error) {
 
     switch (state) {
         case PNSubscriptionProcessNotSubscribedState:
         
             // There should be a reason because of which subscription failed and it can be found in 'error' instance.
             //
             // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
             // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
             // 'error.associatedObject' contains array of PNChannel instances on which PubNub client was unable to
             // subscribe.
             break;
         case PNSubscriptionProcessSubscribedState:
         
             // PubNub client completed subscription on specified set of channels.
             break;
         case PNSubscriptionProcessWillRestoreState:
         
             // PubNub client is about to restore subscription on specified set of channels.
             break;
         case PNSubscriptionProcessRestoredState:
         
             // PubNub client completed subscription restore process.
             break;
     }
 }];
 @endcode
 
 Also observation can be done using \b NSNotificationCenter to observe this notifications: kPNClientSubscriptionDidCompleteNotification,
 kPNClientSubscriptionWillRestoreNotification, kPNClientSubscriptionDidRestoreNotification, kPNClientSubscriptionDidFailNotification.
 
 @param channel
 \b PNChannel instance on which client should subscribe.
 
 @param clientState
 \b NSDictionary instance with list of parameters which should be bound to the client.
 
 @param handlerBlock
 The block which will be called by \b PubNub client as soon as subscription process state will change. The block takes three arguments:
 \c state - is \b PNSubscriptionProcessState enumerator field which describes current subscription state; \c channels - array of \b PNChannel instances for which
 subscription process changed state; \c error - error because of which subscription failed. Always check \a error.code to find out what caused error
 (check \b PNErrorCodes header file and use \a -localizedDescription / \a -localizedFailureReason and \a -localizedRecoverySuggestion to get human
 readable description for error).
 
 @note You can delete previously configured key from state by passing [NSNull null] as value for target key and \b
 PubNub service will remove specified key from client's state at specified channel.
 
 @warning Client state shouldn't contain any nesting and values should be one of: int, float or string.
 
 @warning If you already subscribed on channel (for which already specified state) and will subscribe to another
 one, it will override old state (if keys are the same or will add new keys into old one).
 
 @since 3.6.0
 
 @see PNChannel class
 
 @see PNError class
 
 @see PNObservationCenter class
 
 @sse -subscribeOnChannel:
 */
- (void)  subscribeOnChannel:(PNChannel *)channel withClientState:(NSDictionary *)clientState
  andCompletionHandlingBlock:(PNClientChannelSubscriptionHandlerBlock)handlerBlock
  DEPRECATED_MSG_ATTRIBUTE(" Use '-subscribeOn:withClientState:andCompletionHandlingBlock:' instead.");

/**
 Subscribe client to the set of new channels. By default this method will trigger presence event by sending \a 'leave' presence to channels on which
 client already connected and then re-subscribe generating \a 'join' presence event.
 
 @code
 @endcode
 \b Example:
 
 @code
 PubNub *pubNub = [PubNub clientWithConfiguration:[PNConfiguration defaultConfiguration] andDelegate:self];
 [pubNub connect];
 [pubNub subscribeOnChannels:[PNChannel channelsWithNames:@[@"iosdev", @"macosdev"]]];
 @endcode
 
 And handle it with delegates:
 @code
 - (void)pubnubClient:(PubNub *)client didSubscribeOnChannels:(NSArray *)channels {
 
     // PubNub client subscribed on specified set of channels.
 }
 
 - (void)pubnubClient:(PubNub *)client subscriptionDidFailWithError:(NSError *)error {
 
     // PubNub client did fail to subscribe on requested set of channels.
     //
     // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
     // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
     // 'error.associatedObject' contains array of PNChannel instances on which PubNub client was unable to
     // subscribe.
 }
 @endcode
 
 There is also way to observe subscription process state from any place in your application using  \b PNObservationCenter:
 @code
 [pubNub.observationCenter addClientChannelSubscriptionStateObserver:self
 withCallbackBlock:^(PNSubscriptionProcessState state, NSArray *channels, PNError *error) {
 
     switch (state) {
         case PNSubscriptionProcessNotSubscribedState:
         
             // There should be a reason because of which subscription failed and it can be found in 'error' instance.
             //
             // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
             // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
             // 'error.associatedObject' contains array of PNChannel instances on which PubNub client was unable to
             // subscribe.
             break;
         case PNSubscriptionProcessSubscribedState:
         
             // PubNub client completed subscription on specified set of channels.
             break;
         case PNSubscriptionProcessWillRestoreState:
         
             // PubNub client is about to restore subscription on specified set of channels.
             break;
         case PNSubscriptionProcessRestoredState:
         
             // PubNub client completed subscription restore process.
             break;
     }
 }];
 @endcode
 
 Also observation can be done using \b NSNotificationCenter to observe this notifications: kPNClientSubscriptionDidCompleteNotification,
 kPNClientSubscriptionWillRestoreNotification, kPNClientSubscriptionDidRestoreNotification, kPNClientSubscriptionDidFailNotification.
 
 @param channels
 Array of \b PNChannel instances on which client should subscribe.
 
 @since 3.4.0
 
 @see PNChannel class
 
 @see PNError class
 
 @see PNObservationCenter class
 
 @see -subscribeOnChannels:withCompletionHandlingBlock:
 */
- (void)subscribeOnChannels:(NSArray *)channels DEPRECATED_MSG_ATTRIBUTE(" Use '-subscribeOn:' instead.");

/**
 Subscribe client to the set of new channels. By default this method will trigger presence event by sending \a 'leave' presence event to channels
 on which client already connected and then re-subscribe generating \a 'join' presence event.
 
 @code
 @endcode
 This method extends \a -subscribeOnChannels: and allow to specify subscription process state change handler block.
 
 @code
 @endcode
 \b Example:
 
 @code
 PubNub *pubNub = [PubNub clientWithConfiguration:[PNConfiguration defaultConfiguration] andDelegate:self];
 [pubNub connect];
 [pubNub subscribeOnChannels:[PNChannel channelsWithNames:@[@"iosdev", @"macosdev"]]
 withCompletionHandlingBlock:^(PNSubscriptionProcessState state, NSArray *channels, PNError *subscriptionError) {
 
     switch (state) {
         case PNSubscriptionProcessNotSubscribedState:
         
             // There should be a reason because of which subscription failed and it can be found in 'error' instance
             // Update user interface to let user know that something went wrong and do something to recover from this state.
             //
             // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
             // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
             // 'error.associatedObject' contains array of PNChannel instances on which PubNub client was unable to
             // subscribe.
             break;
         case PNSubscriptionProcessSubscribedState:
         
             // PubNub client completed subscription on specified set of channels.
             break;
         default:
             break;
     }
 }];
 @endcode
 
 And handle it with delegates:
 @code
 - (void)pubnubClient:(PubNub *)client didSubscribeOnChannels:(NSArray *)channels {
 
     // PubNub client subscribed on specified set of channels.
 }
 
 - (void)pubnubClient:(PubNub *)client subscriptionDidFailWithError:(NSError *)error {
 
     // PubNub client did fail to subscribe on requested set of channels.
     //
     // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
     // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
     // 'error.associatedObject' contains array of PNChannel instances on which PubNub client was unable to
     // subscribe.
 }
 @endcode
 
 There is also way to observe subscription process state from any place in your application using  \b PNObservationCenter:
 @code
 [pubNub.observationCenter addClientChannelSubscriptionStateObserver:self
 withCallbackBlock:^(PNSubscriptionProcessState state, NSArray *channels, PNError *error) {
 
     switch (state) {
         case PNSubscriptionProcessNotSubscribedState:
         
             // There should be a reason because of which subscription failed and it can be found in 'error' instance.
             //
             // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
             // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
             // 'error.associatedObject' contains array of PNChannel instances on which PubNub client was unable to
             // subscribe.
             break;
         case PNSubscriptionProcessSubscribedState:
         
             // PubNub client completed subscription on specified set of channels.
             break;
         case PNSubscriptionProcessWillRestoreState:
 
             // PubNub client is about to restore subscription on specified set of channels.
             break;
         case PNSubscriptionProcessRestoredState:
 
             // PubNub client completed subscription restore process.
             break;
     }
 }];
 @endcode
 
 Also observation can be done using \b NSNotificationCenter to observe this notifications: kPNClientSubscriptionDidCompleteNotification,
 kPNClientSubscriptionWillRestoreNotification, kPNClientSubscriptionDidRestoreNotification, kPNClientSubscriptionDidFailNotification.
 
 @param channels
 Array of \b PNChannel instances on which client should subscribe.
 
 @param handlerBlock
 The block which will be called by PubNub client as soon as subscription process state will change. The block takes three arguments:
 \c state - is \b PNSubscriptionProcessState enumerator field which describes current subscription state; \c channels - array of channels for which
 subscription process changed state; \c error - error because of which subscription failed. Always check \a error.code to find out what caused
 error (check PNErrorCodes header file and use \a -localizedDescription / \a -localizedFailureReason and \a -localizedRecoverySuggestion to get
 human readable description for error).
 
 @since 3.4.0
 
 @see PNChannel class
 
 @see PNError class
 
 @see PNObservationCenter class
 
 @see -subscribeOnChannels:
 */
- (void)  subscribeOnChannels:(NSArray *)channels
  withCompletionHandlingBlock:(PNClientChannelSubscriptionHandlerBlock)handlerBlock
  DEPRECATED_MSG_ATTRIBUTE(" Use '-subscribeOn:withCompletionHandlingBlock:' instead.");

/**
 Subscribe client to the set of new channels and channel groups. This method will trigger presence event by
 sending \a 'leave' presence event to channels on which client already connected and then re-subscribe generating
 \a 'join' presence event.
 
 @code
 @endcode
 \b Example:
 
 @code
 PubNub *pubNub = [PubNub clientWithConfiguration:[PNConfiguration defaultConfiguration] andDelegate:self];
 [pubNub connect];
 [pubNub subscribeOn:@[[PNChannel channelWithName:@"iosdev"],
                       [PNChannelGroup channelGroupWithName:@"ios" inNamespace:@"users"]]];
 @endcode
 
 And handle it with delegates:
 @code
 - (void)pubnubClient:(PubNub *)client didSubscribeOn:(NSArray *)channelObjects {
 
     // PubNub client subscribed on specified set of channels.
 }
 
 - (void)pubnubClient:(PubNub *)client subscriptionDidFailWithError:(NSError *)error {
 
     // PubNub client did fail to subscribe on requested set of channels.
     //
     // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use 
     // -localizedDescription / -localizedFailureReason and -localizedRecoverySuggestion to get human readable 
     // description for error). 'error.associatedObject' contains array of objects (which conforms to 
     // PNChannelProtocol data feed object protocol) on which PubNub client was unable to subscribe.
 }
 @endcode
 
 There is also way to observe subscription process state from any place in your application using  
 \b PNObservationCenter:
 @code
 [pubNub.observationCenter addClientChannelSubscriptionStateObserver:self
 withCallbackBlock:^(PNSubscriptionProcessState state, NSArray *channels, PNError *error) {
 
     switch (state) {
         case PNSubscriptionProcessNotSubscribedState:
         
             // There should be a reason because of which subscription failed and it can be found in 'error' instance.
             //
             // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use 
             // -localizedDescription / -localizedFailureReason and -localizedRecoverySuggestion to get human readable 
             // description for error). 'error.associatedObject' contains array of objects (which conforms to 
             // PNChannelProtocol data feed object protocol) on which PubNub client was unable to subscribe.
             break;
         case PNSubscriptionProcessSubscribedState:
         
             // PubNub client completed subscription on specified set of channels.
             break;
         case PNSubscriptionProcessWillRestoreState:
         
             // PubNub client is about to restore subscription on specified set of channels.
             break;
         case PNSubscriptionProcessRestoredState:
         
             // PubNub client completed subscription restore process.
             break;
     }
 }];
 @endcode
 
 Also observation can be done using \b NSNotificationCenter to observe this notifications: 
 kPNClientSubscriptionDidCompleteNotification, kPNClientSubscriptionWillRestoreNotification, 
 kPNClientSubscriptionDidRestoreNotification, kPNClientSubscriptionDidFailNotification.
 
 @param channelObjects List of objects (which conforms to \b PNChannelProtocol data feed object protocol) on which 
                       client should subscribe.
 
 @since 3.7.0
 */
- (void)subscribeOn:(NSArray *)channelObjects;

/**
 Subscribe client to the set of new channels and channel groups. This method will trigger presence event by 
 sending \a 'leave' presence event to channels on which client already connected and then re-subscribe generating 
 \a 'join' presence event.
 
 @code
 @endcode
 This method extends \a -subscribeOn: and allow to specify subscription process state change handler block.
 
 @code
 @endcode
 \b Example:
 
 @code
 PubNub *pubNub = [PubNub clientWithConfiguration:[PNConfiguration defaultConfiguration] andDelegate:self];
 [pubNub connect];
 [pubNub subscribeOn:@[[PNChannel channelWithName:@"iosdev"],
                       [PNChannelGroup channelGroupWithName:@"ios" inNamespace:@"users"]]
 withCompletionHandlingBlock:^(PNSubscriptionProcessState state, NSArray *channels, PNError *subscriptionError) {
 
     switch (state) {
         case PNSubscriptionProcessNotSubscribedState:
         
             // There should be a reason because of which subscription failed and it can be found in 'error' instance
             // Update user interface to let user know that something went wrong and do something to recover from this 
             // state.
             //
             // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use 
             // -localizedDescription / -localizedFailureReason and -localizedRecoverySuggestion to get human readable 
             // description for error). 'error.associatedObject' contains array of PNChannel instances on which PubNub 
             //client was unable to subscribe.
             break;
         case PNSubscriptionProcessSubscribedState:
         
             // PubNub client completed subscription on specified set of channels.
             break;
         default:
             break;
     }
 }];
 @endcode
 
 And handle it with delegates:
 @code
 - (void)pubnubClient:(PubNub *)client didSubscribeOn:(NSArray *)channelObjects {
 
     // PubNub client subscribed on specified set of channels.
 }
 
 - (void)pubnubClient:(PubNub *)client subscriptionDidFailWithError:(NSError *)error {
 
     // PubNub client did fail to subscribe on requested set of channels.
     //
     // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use
     // -localizedDescription / -localizedFailureReason and -localizedRecoverySuggestion to get human readable 
     // description for error). 'error.associatedObject' contains array of objects (which conforms to 
     // PNChannelProtocol data feed object protocol) on which PubNub client was unable to subscribe.
 }
 @endcode
 
 There is also way to observe subscription process state from any place in your application using 
 \b PNObservationCenter:
 @code
 [pubNub.observationCenter addClientChannelSubscriptionStateObserver:self 
 withCallbackBlock:^(PNSubscriptionProcessState state, NSArray *channels, PNError *error) {
 
     switch (state) {
         case PNSubscriptionProcessNotSubscribedState:
         
             // There should be a reason because of which subscription failed and it can be found in 'error' instance.
             //
             // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use 
             // -localizedDescription / -localizedFailureReason and -localizedRecoverySuggestion to get human readable 
             // description for error). 'error.associatedObject' contains array of objects (which conforms to 
             // PNChannelProtocol data feed object protocol) on which PubNub client was unable to subscribe.
             break;
         case PNSubscriptionProcessSubscribedState:
         
             // PubNub client completed subscription on specified set of channels.
             break;
         case PNSubscriptionProcessWillRestoreState:
 
             // PubNub client is about to restore subscription on specified set of channels.
             break;
         case PNSubscriptionProcessRestoredState:
 
             // PubNub client completed subscription restore process.
             break;
     }
 }];
 @endcode
 
 Also observation can be done using \b NSNotificationCenter to observe this notifications: 
 kPNClientSubscriptionDidCompleteNotification, kPNClientSubscriptionWillRestoreNotification, 
 kPNClientSubscriptionDidRestoreNotification, kPNClientSubscriptionDidFailNotification.
 
 @param channelObjects List of objects (which conforms to \b PNChannelProtocol data feed object protocol) on which 
                       client should subscribe.
 @param handlerBlock   The block which will be called by PubNub client as soon as subscription process state will
                       change. The block takes three arguments: \c state - is \b PNSubscriptionProcessState enum field 
                       which describes current subscription state; \c channels - array of channels for which 
                       subscription process changed state; \c error - error because of which subscription failed. Always
                       check \a error.code to find out what caused error (check PNErrorCodes header file and use 
                       \a -localizedDescription / \a -localizedFailureReason and \a -localizedRecoverySuggestion to get
                       human readable description for error).
 
 @since 3.7.0
 */
- (void)          subscribeOn:(NSArray *)channelsAndGroups
  withCompletionHandlingBlock:(PNClientChannelSubscriptionHandlerBlock)handlerBlock;

/**
 Subscribe client to the set of new channels. By default this method will trigger presence event by sending \a 'leave' presence to channels on which
 client already connected and then re-subscribe generating \a 'join' presence event.
 
 @code
 @endcode
 This method extends \a -subscribeOnChannels: and allow to specify client specific state.
 
 @code
 @endcode
 \b Example:
 
 @code
 PubNub *pubNub = [PubNub clientWithConfiguration:[PNConfiguration defaultConfiguration] andDelegate:self];
 [pubNub connect];
 [pubNub subscribeOnChannels:[PNChannel channelsWithNames:@[@"iosdev", @"macosdev"]]
 withClientState:@{@"iosdev": @{@"firstName":@"John", @"lastName":@"Appleseed", @"age":@(240)}, @"macosdev": @{@"type": @"developer", @"fullAccess": @(NO)}}];
 @endcode
 
 And handle it with delegates:
 @code
 - (void)pubnubClient:(PubNub *)client didSubscribeOnChannels:(NSArray *)channels {
 
     // PubNub client subscribed on specified set of channels.
 }
 
 - (void)pubnubClient:(PubNub *)client subscriptionDidFailWithError:(NSError *)error {
 
     // PubNub client did fail to subscribe on requested set of channels.
     //
     // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
     // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
     // 'error.associatedObject' contains array of PNChannel instances on which PubNub client was unable to
     // subscribe.
 }
 @endcode
 
 There is also way to observe subscription process state from any place in your application using  \b PNObservationCenter:
 @code
 [pubNub.observationCenter addClientChannelSubscriptionStateObserver:self
 withCallbackBlock:^(PNSubscriptionProcessState state, NSArray *channels, PNError *error) {
 
     switch (state) {
         case PNSubscriptionProcessNotSubscribedState:
         
             // There should be a reason because of which subscription failed and it can be found in 'error' instance.
             //
             // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
             // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
             // 'error.associatedObject' contains array of PNChannel instances on which PubNub client was unable to
             // subscribe.
             break;
         case PNSubscriptionProcessSubscribedState:
         
             // PubNub client completed subscription on specified set of channels.
             break;
         case PNSubscriptionProcessWillRestoreState:
         
             // PubNub client is about to restore subscription on specified set of channels.
             break;
         case PNSubscriptionProcessRestoredState:
         
             // PubNub client completed subscription restore process.
             break;
     }
 }];
 @endcode
 
 Also observation can be done using \b NSNotificationCenter to observe this notifications: kPNClientSubscriptionDidCompleteNotification,
 kPNClientSubscriptionWillRestoreNotification, kPNClientSubscriptionDidRestoreNotification, kPNClientSubscriptionDidFailNotification.
 
 @param channels
 Array of \b PNChannel instances on which client should subscribe.
 
 @param clientState
 \b NSDictionary instance with list of parameters which should be bound to the client.
 
 @note You can delete previously configured key from state by passing [NSNull null] as value for target key and \b
 PubNub service will remove specified key from client's state at specified channel.
 
 @warning Client state should be represented with dictionary with channel names as keys and channel state as values. Channel state shouldn't contain any nesting and values should be one of: int, float or string. As keys should be used \b only channel names on which you are subscribing or already subscribed.
 
 @warning If you already subscribed on channel (for which already specified state) and will subscribe to another
 one, it will override old state (if keys are the same or will add new keys into old one).
 
 @since 3.6.0
 
 @see PNChannel class
 
 @see PNError class
 
 @see PNObservationCenter class
 
 @see -subscribeOnChannels:withCompletionHandlingBlock:
 */
- (void)subscribeOnChannels:(NSArray *)channels withClientState:(NSDictionary *)clientState
  DEPRECATED_MSG_ATTRIBUTE(" Use '-subscribeOn:withClientState:' instead.");

/**
 Subscribe client to the set of new channels. By default this method will trigger presence event by sending \a 'leave' presence event to channels
 on which client already connected and then re-subscribe generating \a 'join' presence event.
 
 @code
 @endcode
 This method extends \a -subscribeOnChannels:withClientState: and allow to specify subscription process state change handler block.
 
 @code
 @endcode
 \b Example:
 
 @code
 PubNub *pubNub = [PubNub clientWithConfiguration:[PNConfiguration defaultConfiguration] andDelegate:self];
 [pubNub connect];
 [pubNub subscribeOnChannels:[PNChannel channelsWithNames:@[@"iosdev", @"macosdev"]]
 withClientState:@{@"iosdev": @{@"firstName":@"John", @"lastName":@"Appleseed", @"age":@(240)}, @"macosdev": @{@"type": @"developer", @"fullAccess": @(NO)}}
 andCompletionHandlingBlock:^(PNSubscriptionProcessState state, NSArray *channels, PNError *subscriptionError) {
 
     switch (state) {
         case PNSubscriptionProcessNotSubscribedState:
         
             // There should be a reason because of which subscription failed and it can be found in 'error' instance
             // Update user interface to let user know that something went wrong and do something to recover from this state.
             //
             // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
             // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
             // 'error.associatedObject' contains array of PNChannel instances on which PubNub client was unable to
             // subscribe.
             break;
         case PNSubscriptionProcessSubscribedState:
 
             // PubNub client completed subscription on specified set of channels.
             break;
         default:
             break;
     }
 }];
 @endcode
 
 And handle it with delegates:
 @code
 - (void)pubnubClient:(PubNub *)client didSubscribeOnChannels:(NSArray *)channels {
 
     // PubNub client subscribed on specified set of channels.
 }
 
 - (void)pubnubClient:(PubNub *)client subscriptionDidFailWithError:(NSError *)error {
 
     // PubNub client did fail to subscribe on requested set of channels.
     //
     // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
     // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
     // 'error.associatedObject' contains array of PNChannel instances on which PubNub client was unable to
     // subscribe.
 }
 @endcode
 
 There is also way to observe subscription process state from any place in your application using  \b PNObservationCenter:
 @code
 [pubNub.observationCenter addClientChannelSubscriptionStateObserver:self
 withCallbackBlock:^(PNSubscriptionProcessState state, NSArray *channels, PNError *error) {
 
     switch (state) {
         case PNSubscriptionProcessNotSubscribedState:
         
             // There should be a reason because of which subscription failed and it can be found in 'error' instance.
             //
             // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
             // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
             // 'error.associatedObject' contains array of PNChannel instances on which PubNub client was unable to
             // subscribe.
             break;
         case PNSubscriptionProcessSubscribedState:
         
             // PubNub client completed subscription on specified set of channels.
             break;
         case PNSubscriptionProcessWillRestoreState:
         
             // PubNub client is about to restore subscription on specified set of channels.
             break;
         case PNSubscriptionProcessRestoredState:
         
             // PubNub client completed subscription restore process.
             break;
     }
 }];
 @endcode
 
 Also observation can be done using \b NSNotificationCenter to observe this notifications: kPNClientSubscriptionDidCompleteNotification,
 kPNClientSubscriptionWillRestoreNotification, kPNClientSubscriptionDidRestoreNotification, kPNClientSubscriptionDidFailNotification.
 
 @param channels
 Array of \b PNChannel instances on which client should subscribe.
 
 @param clientState
 \b NSDictionary instance with list of parameters which should be bound to the client.
 
 @param handlerBlock
 The block which will be called by PubNub client as soon as subscription process state will change. The block takes three arguments:
 \c state - is \b PNSubscriptionProcessState enumerator field which describes current subscription state; \c channels - array of channels for which
 subscription process changed state; \c error - error because of which subscription failed. Always check \a error.code to find out what caused
 error (check PNErrorCodes header file and use \a -localizedDescription / \a -localizedFailureReason and \a -localizedRecoverySuggestion to get
 human readable description for error).
 
 @note You can delete previously configured key from state by passing [NSNull null] as value for target key and \b
 PubNub service will remove specified key from client's state at specified channel.
 
 @warning Client state should be represented with dictionary with channel names as keys and channel state as values. Channel state shouldn't contain any nesting and values should be one of: int, float or string. As keys should be used \b only channel names on which you are subscribing or already subscribed.
 
 @warning If you already subscribed on channel (for which already specified state) and will subscribe to another
 one, it will override old state (if keys are the same or will add new keys into old one).
 
 @since 3.4.0
 
 @see PNChannel class
 
 @see PNError class
 
 @see PNObservationCenter class
 
 @see -subscribeOnChannels:
 */
- (void) subscribeOnChannels:(NSArray *)channels withClientState:(NSDictionary *)clientState
  andCompletionHandlingBlock:(PNClientChannelSubscriptionHandlerBlock)handlerBlock
  DEPRECATED_MSG_ATTRIBUTE(" Use '-subscribeOn:withClientState:andCompletionHandlingBlock:' instead.");

/**
 Subscribe client to the set of new channels and channel groups. This method will trigger presence event by
 sending \a 'leave' presence event to channels on which client already connected and then re-subscribe generating
 \a 'join' presence event.
 
 @code
 @endcode
 This method extends \a -subscribeOn: and allow to specify client specific state.
 
 @code
 @endcode
 \b Example:
 
 @code
 PubNub *pubNub = [PubNub clientWithConfiguration:[PNConfiguration defaultConfiguration] andDelegate:self];
 [pubNub connect];
 [pubNub subscribeOn:@[[PNChannel channelWithName:@"iosdev"],
                       [PNChannelGroup channelGroupWithName:@"ios" inNamespace:@"users"]]
     withClientState:@{@"iosdev": @{@"firstName":@"John", @"lastName":@"Appleseed", @"age":@(240)},
                       @"users:ios": @{@"type": @"developer", @"fullAccess": @(NO)}}];
 @endcode
 
 And handle it with delegates:
 @code
 - (void)pubnubClient:(PubNub *)client didSubscribeOn:(NSArray *)channelObjects {
 
     // PubNub client subscribed on specified set of channels.
 }
 
 - (void)pubnubClient:(PubNub *)client subscriptionDidFailWithError:(NSError *)error {
 
     // PubNub client did fail to subscribe on requested set of channels.
     //
     // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use 
     // -localizedDescription / -localizedFailureReason and -localizedRecoverySuggestion to get human readable 
     // description for error). 'error.associatedObject' contains array of objects (which conforms to 
     // PNChannelProtocol data feed object protocol) on which PubNub client was unable to subscribe.
 }
 @endcode
 
 There is also way to observe subscription process state from any place in your application using  
 \b PNObservationCenter:
 @code
 [pubNub.observationCenter addClientChannelSubscriptionStateObserver:self
 withCallbackBlock:^(PNSubscriptionProcessState state, NSArray *channels, PNError *error) {
 
     switch (state) {
         case PNSubscriptionProcessNotSubscribedState:
         
             // There should be a reason because of which subscription failed and it can be found in 'error' instance.
             //
             // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use 
             // -localizedDescription / -localizedFailureReason and -localizedRecoverySuggestion to get human readable 
             // description for error). 'error.associatedObject' contains array of PNChannel instances on which PubNub 
             // client was unable to subscribe.
             break;
         case PNSubscriptionProcessSubscribedState:
         
             // PubNub client completed subscription on specified set of channels.
             break;
         case PNSubscriptionProcessWillRestoreState:
         
             // PubNub client is about to restore subscription on specified set of channels.
             break;
         case PNSubscriptionProcessRestoredState:
         
             // PubNub client completed subscription restore process.
             break;
     }
 }];
 @endcode
 
 Also observation can be done using \b NSNotificationCenter to observe this notifications: 
 kPNClientSubscriptionDidCompleteNotification, kPNClientSubscriptionWillRestoreNotification, 
 kPNClientSubscriptionDidRestoreNotification, kPNClientSubscriptionDidFailNotification.
 
 @param channelObjects List of objects (which conforms to \b PNChannelProtocol data feed object protocol) on which 
                       client should subscribe.
 @param clientState    \b NSDictionary instance with list of parameters which should be bound to the client.
 
 @since 3.7.0
 */
- (void)subscribeOn:(NSArray *)channelObjects withClientState:(NSDictionary *)clientState;

/**
 Subscribe client to the set of new channels and channel groups. This method will trigger presence event by 
 sending \a 'leave' presence event to channels on which client already connected and then re-subscribe generating 
 \a 'join' presence event.
 
 @code
 @endcode
 This method extends \a -subscribeOn:withClientState: and allow to specify subscription process state change handler 
 block.
 
 @code
 @endcode
 \b Example:
 
 @code
 PubNub *pubNub = [PubNub clientWithConfiguration:[PNConfiguration defaultConfiguration] andDelegate:self];
 [pubNub connect];
 [pubNub subscribeOn:@[[PNChannel channelWithName:@"iosdev"],
                       [PNChannelGroup channelGroupWithName:@"ios" inNamespace:@"users"]]
     withClientState:@{@"iosdev": @{@"firstName":@"John", @"lastName":@"Appleseed", @"age":@(240)},
                       @"users:ios": @{@"type": @"developer", @"fullAccess": @(NO)}}
andCompletionHandlingBlock:^(PNSubscriptionProcessState state, NSArray *channels, PNError *subscriptionError) {
 
     switch (state) {
         case PNSubscriptionProcessNotSubscribedState:
         
             // There should be a reason because of which subscription failed and it can be found in 'error' instance
             // Update user interface to let user know that something went wrong and do something to recover from this 
             // state.
             //
             // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use 
             // -localizedDescription / -localizedFailureReason and -localizedRecoverySuggestion to get human readable 
             // description for error). 'error.associatedObject' contains array of PNChannel instances on which PubNub 
             //client was unable to subscribe.
             break;
         case PNSubscriptionProcessSubscribedState:
         
             // PubNub client completed subscription on specified set of channels.
             break;
         default:
             break;
     }
 }];
 @endcode
 
 And handle it with delegates:
 @code
 - (void)pubnubClient:(PubNub *)client didSubscribeOn:(NSArray *)channelObjects {
 
     // PubNub client subscribed on specified set of channels.
 }
 
 - (void)pubnubClient:(PubNub *)client subscriptionDidFailWithError:(NSError *)error {
 
     // PubNub client did fail to subscribe on requested set of channels.
     //
     // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use
     // -localizedDescription / -localizedFailureReason and -localizedRecoverySuggestion to get human readable 
     // description for error). 'error.associatedObject' contains array of objects (which conforms to 
     // PNChannelProtocol data feed object protocol) on which PubNub client was unable to subscribe.
 }
 @endcode
 
 There is also way to observe subscription process state from any place in your application using 
 \b PNObservationCenter:
 @code
 [pubNub.observationCenter addClientChannelSubscriptionStateObserver:self
 withCallbackBlock:^(PNSubscriptionProcessState state, NSArray *channels, PNError *error) {
 
     switch (state) {
         case PNSubscriptionProcessNotSubscribedState:
         
             // There should be a reason because of which subscription failed and it can be found in 'error' instance.
             //
             // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use 
             // -localizedDescription / -localizedFailureReason and -localizedRecoverySuggestion to get human readable 
             // description for error). 'error.associatedObject' contains array of objects (which conforms to 
             // PNChannelProtocol data feed object protocol) on which PubNub client was unable to subscribe.
             break;
         case PNSubscriptionProcessSubscribedState:
         
             // PubNub client completed subscription on specified set of channels.
             break;
         case PNSubscriptionProcessWillRestoreState:
 
             // PubNub client is about to restore subscription on specified set of channels.
             break;
         case PNSubscriptionProcessRestoredState:
 
             // PubNub client completed subscription restore process.
             break;
     }
 }];
 @endcode
 
 Also observation can be done using \b NSNotificationCenter to observe this notifications: 
 kPNClientSubscriptionDidCompleteNotification, kPNClientSubscriptionWillRestoreNotification, 
 kPNClientSubscriptionDidRestoreNotification, kPNClientSubscriptionDidFailNotification.
 
 @param channelObjects List of objects (which conforms to \b PNChannelProtocol data feed object protocol) on which 
                       client should subscribe.
 @param clientState    \b NSDictionary instance with list of parameters which should be bound to the client.
 @param handlerBlock   The block which will be called by PubNub client as soon as subscription process state will 
                       change. The block takes three arguments: \c state - is \b PNSubscriptionProcessState enum field 
                       which describes current subscription state; \c channels - array of channels for which 
                       subscription process changed state; \c error - error because of which subscription failed. Always
                       check \a error.code to find out what caused error (check PNErrorCodes header file and use 
                       \a -localizedDescription / \a -localizedFailureReason and \a -localizedRecoverySuggestion to get
                       human readable description for error).
 
 @since 3.7.0
 */
- (void)         subscribeOn:(NSArray *)channelObjects withClientState:(NSDictionary *)clientState
  andCompletionHandlingBlock:(PNClientChannelSubscriptionHandlerBlock)handlerBlock;

/**
 Unsubscribe client from one channel. By default this method will trigger presence event by sending \a 'leave' presence event to channels on
 which client already subscribed and then re-subscribe generating \a 'join' presence event on the rest of channels.
 
 @code
 @endcode
 \b Example:
 
 @code
 PubNub *pubNub = [PubNub clientWithConfiguration:[PNConfiguration defaultConfiguration] andDelegate:self];
 [pubNub connect];
 [pubNub subscribeFromChannel:[PNChannel channelsWithName:@"iosdev"]];
 [pubNub sendMessage:@"PubNub welcomes iOS developers" toChannel:[PNChannel channelWithName:@"iosdev"]];
 [pubNub unsubscribeFromChannel:[PNChannel channelsWithName:@"iosdev"]];
 @endcode
 
 And handle it with delegates:
 @code
 - (void)pubnubClient:(PubNub *)client didUnsubscribeOnChannels:(NSArray *)channels {
 
     // PubNub client successfully unsubscribed from specified set of channels.
 }
 
 - (void)pubnubClient:(PubNub *)client unsubscriptionDidFailWithError:(PNError *)error {
 
     // PubNub client did fail to unsubscribe from provided set of channels (they are in 'error.associatedObject') of 'error'.
 }
 @endcode
 
 There is also way to observe unsubscription process state from any place in your application using  \b PNObservationCenter:
 @code
 [pubNub.observationCenter addClientChannelUnsubscriptionObserver:self
 withCallbackBlock:^(NSArray *channels, PNError *error) {
 
     if (error == nil) {
     
         // PubNub client successfully unsubscribed from specified channels.
     }
     else {
     
         // PubNub did fail to unsubscribed from specified channels and reason can be found in error instance.
         //
         // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
         // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
         // 'error.associatedObject' contains array of PNChannel instances from which PubNub client was unable to
         // unsubscribe.
     }
 }];
 @endcode
 
 Also observation can be done using \b NSNotificationCenter to observe this notifications: kPNClientUnsubscriptionDidCompleteNotification,
 kPNClientUnsubscriptionDidFailNotification.
 
 @param channel
 \b PNChannel instance from which client should unsubscribe.
 
 @since 3.4.0
 
 @see PNChannel class
 
 @see PNError class
 
 @see PNObservationCenter class
 
 @see -unsubscribeFromChannel:withCompletionHandlingBlock:
 */
- (void)unsubscribeFromChannel:(PNChannel *)channel
  DEPRECATED_MSG_ATTRIBUTE(" Use '-unsubscribeFrom:' instead.");

/**
 Unsubscribe client from one channel. By default this method will trigger presence event by sending \a 'leave' presence event to channels on
 which client already subscribed and then re-subscribe generating \a 'join' presence event on the rest of channels.
 
 @code
 @endcode
 This method extends \a -unsubscribeFromChannel: and allow to specify unsubscription process state change handler block.
 
 @code
 @endcode
 \b Example:
 
 @code
 PubNub *pubNub = [PubNub clientWithConfiguration:[PNConfiguration defaultConfiguration] andDelegate:self];
 [pubNub connect];
 [pubNub subscribeFromChannel:[PNChannel channelsWithName:@"iosdev"]];
 [pubNub sendMessage:@"PubNub welcomes iOS developers" toChannel:[PNChannel channelWithName:@"iosdev"]];
 [pubNub unsubscribeFromChannel:[PNChannel channelWithName:@"iosdev"]
 withCompletionHandlingBlock:^(NSArray *channels, PNError *error) {
 
     if (error == nil) {
     
         // PubNub client successfully unsubscribed from specified channels.
     }
     else {
     
         // PubNub did fail to unsubscribed from specified channels and reason can be found in error instance.
         //
         // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
         // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
         // 'error.associatedObject' contains array of PNChannel instances from which PubNub client was unable to
         // unsubscribe.
     }
 }];
 @endcode
 
 And handle it with delegates:
 @code
 - (void)pubnubClient:(PubNub *)client didUnsubscribeOnChannels:(NSArray *)channels {
 
     // PubNub client successfully unsubscribed from specified set of channels.
 }
 
 - (void)pubnubClient:(PubNub *)client unsubscriptionDidFailWithError:(PNError *)error {
 
     // PubNub client did fail to unsubscribe from provided set of channels.
     //
     // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
     // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
     // 'error.associatedObject' contains array of PNChannel instances from which PubNub client was unable to
     // unsubscribe.
 }
 @endcode
 
 There is also way to observe unsubscription process state from any place in your application using  \b PNObservationCenter:
 @code
 [pubNub.observationCenter addClientChannelUnsubscriptionObserver:self
 withCallbackBlock:^(NSArray *channels, PNError *error) {
 
     if (error == nil) {
     
         // PubNub client successfully unsubscribed from specified channels.
     }
     else {
     
         // PubNub did fail to unsubscribed from specified channels and reason can be found in error instance.
         //
         // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
         // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
         // 'error.associatedObject' contains array of PNChannel instances from which PubNub client was unable to
         // unsubscribe.
     }
 }];
 @endcode
 
 Also observation can be done using \b NSNotificationCenter to observe this notifications: kPNClientUnsubscriptionDidCompleteNotification,
 kPNClientUnsubscriptionDidFailNotification.
 
 @param channel
 \b PNChannel instance from which client should unsubscribe.
 
 @param handlerBlock
 The block whichh will be called by PubNub client as soon as subscription process state will change. The block takes two arguments:
 \c channels - array of \b PNChannel instances from which client unsubscribe; \c error - error because of which unsubscription failed.
 Always check \a error.code to find out what caused error (check PNErrorCodes header file and use \a -localizedDescription /
 \a -localizedFailureReason and \a -localizedRecoverySuggestion to get human readable description for error).
 
 @since 3.4.0
 
 @see PNChannel class
 
 @see PNError class
 
 @see PNObservationCenter class
 
 @see -unsubscribeFromChannel:
 */
- (void)unsubscribeFromChannel:(PNChannel *)channel
   withCompletionHandlingBlock:(PNClientChannelUnsubscriptionHandlerBlock)handlerBlock
  DEPRECATED_MSG_ATTRIBUTE(" Use '-unsubscribeFrom:withCompletionHandlingBlock:' instead.");

/**
 Unsubscribe client from set of channels. By default this method will trigger presence event by sending \a 'leave' presence event to channels on
 which client already subscribed and then re-subscribe generating \a 'join' presence event on the rest of channels.
 
 @code
 @endcode
 \b Example:
 
 @code
 PubNub *pubNub = [PubNub clientWithConfiguration:[PNConfiguration defaultConfiguration] andDelegate:self];
 [pubNub connect];
 [pubNub subscribeFromChannel:[PNChannel channelsWithName:@"iosdev"]];
 [pubNub sendMessage:@"PubNub welcomes iOS developers" toChannel:[PNChannel channelWithName:@"iosdev"]];
 [pubNub unsubscribeFromChannels:[PNChannel channelsWithNames:@[@"iosdev", @"macosdev"]]];
 @endcode
 
 And handle it with delegates:
 @code
 - (void)pubnubClient:(PubNub *)client didUnsubscribeOnChannels:(NSArray *)channels {
 
     // PubNub client successfully unsubscribed from specified set of channels.
 }
 
 - (void)pubnubClient:(PubNub *)client unsubscriptionDidFailWithError:(PNError *)error {
 
     // PubNub client did fail to unsubscribe from provided set of channels.
     //
     // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
     // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
     // 'error.associatedObject' contains array of PNChannel instances from which PubNub client was unable to
     // unsubscribe.
 }
 @endcode
 
 There is also way to observe unsubscription process state from any place in your application using  \b PNObservationCenter:
 @code
 [pubNub.observationCenter addClientChannelUnsubscriptionObserver:self
 withCallbackBlock:^(NSArray *channels, PNError *error) {
 
     if (error == nil) {
     
         // PubNub client successfully unsubscribed from specified channels.
     }
     else {
     
         // PubNub did fail to unsubscribed from specified channels and reason can be found in error instance.
         //
         // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
         // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
         // 'error.associatedObject' contains array of PNChannel instances from which PubNub client was unable to
         // unsubscribe.
     }
 }];
 @endcode
 
 Also observation can be done using \b NSNotificationCenter to observe this notifications: kPNClientUnsubscriptionDidCompleteNotification,
 kPNClientUnsubscriptionDidFailNotification.
 
 @param channels
 Array of \b PNChannel instances from which client should unsubscribe.
 
 @since 3.4.0
 
 @see PNChannel class
 
 @see PNError class
 
 @see PNObservationCenter class
 
 @see -unsubscribeFromChannels:withCompletionHandlingBlock:
 */
- (void)unsubscribeFromChannels:(NSArray *)channels
  DEPRECATED_MSG_ATTRIBUTE(" Use '-unsubscribeFrom:' instead.");

/**
 Unsubscribe client from set of channels. By default this method will trigger presence event by sending \a 'leave' presence event to channels on
 which client already subscribed and then re-subscribe generating \a 'join' presence event on the rest of channels.
 
 @code
 @endcode
 This method extends \a -unsubscribeFromChannels: and allow to specify unsubscription process state change handler block.
 
 @code
 @endcode
 \b Example:
 
 @code
 PubNub *pubNub = [PubNub clientWithConfiguration:[PNConfiguration defaultConfiguration] andDelegate:self];
 [pubNub connect];
 [pubNub subscribeFromChannel:[PNChannel channelsWithName:@"iosdev"]];
 [pubNub sendMessage:@"PubNub welcomes iOS developers" toChannel:[PNChannel channelWithName:@"iosdev"]];
 [pubNub unsubscribeFromChannels:[PNChannel channelsWithNames:@[@"iosdev", @"macosdev"]]
 withCompletionHandlingBlock:^(NSArray *channels, PNError *error) {
 
     if (error == nil) {
     
         // PubNub client successfully unsubscribed from specified channels
     }
     else {
     
         // PubNub did fail to unsubscribed from specified channels and reason can be found in error instance
     }
 }];
 @endcode
 
 And handle it with delegates:
 @code
 - (void)pubnubClient:(PubNub *)client didUnsubscribeOnChannels:(NSArray *)channels {
 
     // PubNub client successfully unsubscribed from specified set of channels.
 }
 
 - (void)pubnubClient:(PubNub *)client unsubscriptionDidFailWithError:(PNError *)error {
 
     // PubNub client did fail to unsubscribe from provided set of channels (they are in 'error.associatedObject') of 'error'.
 }
 @endcode
 
 There is also way to observe unsubscription process state from any place in your application using  \b PNObservationCenter:
 @code
 [pubNub.observationCenter addClientChannelUnsubscriptionObserver:self
 withCallbackBlock:^(NSArray *channels, PNError *error) {
 
     if (error == nil) {
     
         // PubNub client successfully unsubscribed from specified channels
     }
     else {
     
         // PubNub did fail to unsubscribed from specified channels and reason can be found in error instance
     }
 }];
 @endcode
 
 Also observation can be done using \b NSNotificationCenter to observe this notifications: kPNClientUnsubscriptionDidCompleteNotification,
 kPNClientUnsubscriptionDidFailNotification.
 
 @param channels
 Array of \b PNChannel instances from which client should unsubscribe.
 
 @param handlerBlock
 The block which will be called by PubNub client as soon as unsubscription process state will change. The block takes two arguments:
 \c channels - array of \b PNChannel instances from which client unsubscribe; \c error - error because of which unsubscription failed.
 Always check \a error.code to find out what caused error (check PNErrorCodes header file and use \a -localizedDescription /
 \a -localizedFailureReason and \a -localizedRecoverySuggestion to get human readable description for error).
 
 @since 3.4.0
 
 @see PNChannel class
 
 @see PNError class
 
 @see PNObservationCenter class
 
 @see -unsubscribeFromChannels:
 */
- (void)unsubscribeFromChannels:(NSArray *)channels
    withCompletionHandlingBlock:(PNClientChannelUnsubscriptionHandlerBlock)handlerBlock
  DEPRECATED_MSG_ATTRIBUTE(" Use '-unsubscribeFrom:withCompletionHandlingBlock:' instead.");

/**
 Unsubscribe client from set of channels. By default this method will trigger presence event by sending \a 'leave' 
 presence event to channels on which client already subscribed and then re-subscribe generating \a 'join' presence 
 event on the rest of channels.
 
 @code
 @endcode
 \b Example:
 
 @code
 PubNub *pubNub = [PubNub clientWithConfiguration:[PNConfiguration defaultConfiguration] andDelegate:self];
 [pubNub connect];
 [pubNub subscribeFromChannelsAndGroups:@[[PNChannel channelsWithName:@"iosdev"]]];
 [pubNub sendMessage:@"PubNub welcomes iOS developers" toChannel:[PNChannel channelWithName:@"iosdev"]];
 [pubNub unsubscribeFrom:[PNChannel channelsWithNames:@[@"iosdev", @"macosdev"]]];
 @endcode
 
 And handle it with delegates:
 @code
 - (void)pubnubClient:(PubNub *)client didUnsubscribeFrom:(NSArray *)channelObjects {
 
     // PubNub client successfully unsubscribed from specified set of channels.
 }
 
 - (void)pubnubClient:(PubNub *)client unsubscriptionDidFailWithError:(PNError *)error {
 
     // PubNub client did fail to unsubscribe from provided set of channels.
     //
     // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use 
     // -localizedDescription / -localizedFailureReason and -localizedRecoverySuggestion to get human readable 
     // description for error). 'error.associatedObject' contains array of objects (which conforms to PNChannelProtocol
     // data feed object protocol) from which PubNub client was unable to unsubscribe.
 }
 @endcode
 
 There is also way to observe unsubscription process state from any place in your application using  \b PNObservationCenter:
 @code
 [pubNub.observationCenter addClientChannelUnsubscriptionObserver:self
 withCallbackBlock:^(NSArray *channels, PNError *error) {
 
     if (error == nil) {
     
         // PubNub client successfully unsubscribed from specified channels.
     }
     else {
     
         // PubNub did fail to unsubscribed from specified channels and reason can be found in error instance.
         //
         // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use 
         // -localizedDescription / -localizedFailureReason and -localizedRecoverySuggestion to get human readable 
         // description for error). 'error.associatedObject' contains array of objects (which conforms to 
         // PNChannelProtocol data feed object protocol) from which PubNub client was unable to unsubscribe.
     }
 }];
 @endcode
 
 Also observation can be done using \b NSNotificationCenter to observe this notifications: 
 kPNClientUnsubscriptionDidCompleteNotification, kPNClientUnsubscriptionDidFailNotification.
 
 @param channelObjects List of objects (which conforms to \b PNChannelProtocol data feed object protocol) from which
                       client should unsubscribe.
 
 @since 3.7.0
 */
- (void)unsubscribeFrom:(NSArray *)channelObjects;

/**
 Unsubscribe client from set of channels. By default this method will trigger presence event by sending \a 'leave' 
 presence event to channels on which client already subscribed and then re-subscribe generating \a 'join' presence
 event on the rest of channels.
 
 @code
 @endcode
 This method extends \a -unsubscribeFrom: and allow to specify unsubscription process state change handler block.
 
 @code
 @endcode
 \b Example:
 
 @code
 PubNub *pubNub = [PubNub clientWithConfiguration:[PNConfiguration defaultConfiguration] andDelegate:self];
 [pubNub connect];
 [pubNub subscribeFromChannelsAndGroups:@[[PNChannel channelsWithName:@"iosdev"]]];
 [pubNub sendMessage:@"PubNub welcomes iOS developers" toChannel:[PNChannel channelWithName:@"iosdev"]];
 [pubNub unsubscribeFrom:[PNChannel channelsWithNames:@[@"iosdev", @"macosdev"]]
 withCompletionHandlingBlock:^(NSArray *channels, PNError *error) {
 
     if (error == nil) {
     
         // PubNub client successfully unsubscribed from specified channels.
     }
     else {
     
         // PubNub did fail to unsubscribed from specified channels and reason can be found in error instance.
         //
         // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use 
         // -localizedDescription / -localizedFailureReason and -localizedRecoverySuggestion to get human readable 
         // description for error). 'error.associatedObject' contains array of PNChannel instances from which PubNub 
         // client was unable to unsubscribe.
     }
 }];
 @endcode
 
 And handle it with delegates:
 @code
 - (void)pubnubClient:(PubNub *)client didUnsubscribeFrom:(NSArray *)channelObjects {
 
     // PubNub client successfully unsubscribed from specified set of channels.
 }
 
 - (void)pubnubClient:(PubNub *)client unsubscriptionDidFailWithError:(PNError *)error {
 
     // PubNub client did fail to unsubscribe from provided set of channels.
     //
     // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use 
     // -localizedDescription / -localizedFailureReason and -localizedRecoverySuggestion to get human readable 
     // description for error). 'error.associatedObject' contains array of objects (which conforms to PNChannelProtocol 
     // data feed object protocol) from which PubNub client was unable to unsubscribe.
 }
 @endcode
 
 There is also way to observe unsubscription process state from any place in your application using 
 \b PNObservationCenter:
 @code
 [pubNub.observationCenter addClientChannelUnsubscriptionObserver:self
 withCallbackBlock:^(NSArray *channels, PNError *error) {

     if (error == nil) {
     
         // PubNub client successfully unsubscribed from specified channels.
     }
     else {
     
         // PubNub did fail to unsubscribed from specified channels and reason can be found in error instance.
         //
         // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use 
         // -localizedDescription / -localizedFailureReason and -localizedRecoverySuggestion to get human readable 
         // description for error). 'error.associatedObject' contains array of objects (which conforms to 
         // PNChannelProtocol data feed object protocol) from which PubNub client was unable to unsubscribe.
     }
 }];
 @endcode
 
 Also observation can be done using \b NSNotificationCenter to observe this notifications: 
 kPNClientUnsubscriptionDidCompleteNotification, kPNClientUnsubscriptionDidFailNotification.
 
 @param channelObjects List of objects (which conforms to \b PNChannelProtocol data feed object protocol) from which
                       client should unsubscribe.
 @param handlerBlock   The block which will be called by PubNub client as soon as unsubscription process state will
                       change. The block takes two arguments: \c channels - array of \b PNChannel instances from which
                       client unsubscribe; \c error - error because of which unsubscription failed. Always check
                       \a error.code to find out what caused error (check PNErrorCodes header file and use
                       \a -localizedDescription / \a -localizedFailureReason and \a -localizedRecoverySuggestion to get
                       human readable description for error).
 
 @since 3.7.0
 */
- (void)    unsubscribeFrom:(NSArray *)channelObjects
withCompletionHandlingBlock:(PNClientChannelUnsubscriptionHandlerBlock)handlerBlock;

#pragma mark -


@end
