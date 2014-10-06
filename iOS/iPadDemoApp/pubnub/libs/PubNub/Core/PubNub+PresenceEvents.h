#import "PubNub.h"

/**
 Base class extension which provide methods for presence events observation.
 
 @author Sergey Mamontov
 @version 3.6.8
 @copyright © 2009-13 PubNub Inc.
 */
@interface PubNub (PresenceEvents)


#pragma mark - Class (singleton) methods

/**
 Checking whether client added presence observation on particular channel or not.
 
 @code
 @endcode
 \b Example:
 
 @code
 [PubNub setConfiguration:[PNConfiguration defaultConfiguration] andDelegate:self];
 [PubNub connect];
 [PubNub enablePresenceObservationForChannel:[PNChannel channelWithName:@"macosdev"] 
  withCompletionHandlingBlock:^(NSArray *channels, PNError *error) {
  
      if (error == nil) {
      
          BOOL isObservingPresenceOnIOS = [PubNub isPresenceObservationEnabledForChannel:[PNChannel channelWithName:@"iosdev"]];
          NSLog(@"Observing presence events on 'iosdev' channel? %@", isObservingPresenceOnIOS ? @"YES" : @"NO");
      }
      else {
          
          // PubNub client was unable to enable presence on specified channels and reason can be found in error instance.
      }
 }];
 @endcode
 
 @return \c YES in case if channel already added to presence observation list and \c NO if not.
 
 @see +enablePresenceObservationForChannel:
 @see +disablePresenceObservationForChannel:
 */
+ (BOOL)isPresenceObservationEnabledForChannel:(PNChannel *)channel;

/**
 Enable presence observation on specific channel. This method will subscribe \b PubNub client on special type of channel and receive presence events
 from it. Each channel has it's own presence observation pair. If \b PubNub client doesn't observe for presence events, you will be unable to know
 when someone is joining or leaving specific channel.
 
 @code
 @endcode
 \b Example:
 
 @code
 [PubNub setConfiguration:[PNConfiguration defaultConfiguration] andDelegate:self];
 [PubNub connect];
 [PubNub enablePresenceObservationForChannel:[PNChannel channelWithName:@"iosdev"]];
 
 // There is another way to enable presence observation on channel. You can use \a +channelWithName:shouldObservePresence: \b PNChannel class method
 // to prepare channel instance in a way, which will enable presence automatically. This method should be used when you subscribe on channel(s).
 // [PubNub subscribeOnChannel:[PNChannel channelWithName:@"iosdev" shouldObservePresence:YES]];
 @endcode
 
 And handle it with delegates:
 @code
 - (void)pubnubClient:(PubNub *)client didEnablePresenceObservationOn:(NSArray *)channelObjects {
 
     // PubNub client successfully enabled presence on specified set of channels.
 }
 
 - (void)pubnubClient:(PubNub *)client presenceObservationEnablingDidFailWithError:(PNError *)error {
 
     // PubNub client did fail to enable presence on specified set of channels.
 }
 @endcode
 
 There is also way to observe connection state from any place in your application using  \b PNObservationCenter:
 @code
 [[PNObservationCenter defaultCenter] addClientPresenceEnablingObserver:self withCallbackBlock:^(NSArray *channels, PNError *error) {
 
     if (error == nil) {
 
         // PubNub client successfully enabled presence on specified set of channels.
     }
     else {
 
         // PubNub client did fail to enable presence on specified set of channels.
     }
 }];
 @endcode
 
 @param channel
 \b PNChannel instance for which client should enable presence observation.
 
 @see +enablePresenceObservationForChannel:withCompletionHandlingBlock:
 */
+ (void)enablePresenceObservationForChannel:(PNChannel *)channel;

/**
 Enable presence observation on specific channel.
 
 @code
 @endcode
 This method extendeds \a +enablePresenceObservationForChannel: and allow to specify presence enabling process state change handler block.
 
 @code
 @endcode
 \b Example:
 
 @code
 [PubNub setConfiguration:[PNConfiguration defaultConfiguration] andDelegate:self];
 [PubNub connect];
 [PubNub enablePresenceObservationForChannel:[PNChannel channelWithName:@"iosdev"] withCompletionHandlingBlock:^(NSArray *channels, PNError *error) {
 
     if (error == nil) {
 
         // PubNub client successfully enabled presence on specified set of channels.
     }
     else {
 
         // PubNub client did fail to enable presence on specified set of channels.
     }
 }];
 
 // There is another way to enable presence observation on channel. You can use \a +channelWithName:shouldObservePresence: \b PNChannel class method
 // to prepare channel instance in a way, which will enable presence automatically. This method should be used when you subscribe on channel(s).
 // [PubNub subscribeOnChannel:[PNChannel channelWithName:@"iosdev" shouldObservePresence:YES]];
 @endcode
 
 And handle it with delegates:
 @code
 - (void)pubnubClient:(PubNub *)client didEnablePresenceObservationOn:(NSArray *)channelObjects {
 
     // PubNub client successfully enabled presence on specified set of channels.
 }
 
 - (void)pubnubClient:(PubNub *)client presenceObservationEnablingDidFailWithError:(PNError *)error {
 
     // PubNub client did fail to enable presence on specified set of channels.
 }
 @endcode
 
 There is also way to observe connection state from any place in your application using  \b PNObservationCenter:
 @code
 [[PNObservationCenter defaultCenter] addClientPresenceEnablingObserver:self withCallbackBlock:^(NSArray *channels, PNError *error) {
 
     if (error == nil) {
 
         // PubNub client successfully enabled presence on specified set of channels.
     }
     else {
 
         // PubNub client did fail to enable presence on specified set of channels.
     }
 }];
 @endcode
 
 @param channel
 \b PNChannel instance for which client should enable presence observation.
 
 @param handlerBlock
 The block which will be called by \b PubNub client as soon as presence enabling state will change. The block takes two arguments:
 \c channels - array of \b PNChannel instances for which presence enabling state changed; \c error - describes what exactly went wrong 
 (check error code and compare it with \b PNErrorCodes ).
 
 @see +enablePresenceObservationForChannel:
 */
+ (void)enablePresenceObservationForChannel:(PNChannel *)channel withCompletionHandlingBlock:(PNClientPresenceEnableHandlingBlock)handlerBlock;

/**
 Enable presence observation on set of channels. This method will subscribe \b PubNub client on special type of channels and receive presence events
 from them. Each channel has it's own presence observation pair. If \b PubNub client doesn't observe for presence events, you will be unable to know
 when someone is joining or leaving specific channel.
 
 @code
 @endcode
 \b Example:
 
 @code
 [PubNub setConfiguration:[PNConfiguration defaultConfiguration] andDelegate:self];
 [PubNub connect];
 [PubNub enablePresenceObservationForChannels:[PNChannel channelsWithNames:@[@"iosdev", @"macosdev"]]];
 
 // There is another way to enable presence observation on channel. You can use \a +channelWithName:shouldObservePresence: \b PNChannel class method
 // to prepare channel instance in a way, which will enable presence automatically. This method should be used when you subscribe on channel(s).
 // [PubNub subscribeOnChannel:[PNChannel channelWithName:@"iosdev" shouldObservePresence:YES]];
 @endcode
 
 And handle it with delegates:
 @code
 - (void)pubnubClient:(PubNub *)client didEnablePresenceObservationOn:(NSArray *)channelObjects {
 
     // PubNub client successfully enabled presence on specified set of channels.
 }
 
 - (void)pubnubClient:(PubNub *)client presenceObservationEnablingDidFailWithError:(PNError *)error {
 
     // PubNub client did fail to enable presence on specified set of channels.
 }
 @endcode
 
 There is also way to observe connection state from any place in your application using  \b PNObservationCenter:
 @code
 [[PNObservationCenter defaultCenter] addClientPresenceEnablingObserver:self withCallbackBlock:^(NSArray *channels, PNError *error) {
 
     if (error == nil) {
 
         // PubNub client successfully enabled presence on specified set of channels.
     }
     else {
 
         // PubNub client did fail to enable presence on specified set of channels.
     }
 }];
 @endcode
 
 @param channels
 Array of \b PNChannel instances for which client should enable presence observation.
 
 @see +enablePresenceObservationForChannels:withCompletionHandlingBlock:
 */
+ (void)enablePresenceObservationForChannels:(NSArray *)channels;

/**
 Enable presence observation on set of channels.
 
 @code
 @endcode
 This method extendeds \a +enablePresenceObservationForChannels: and allow to specify presence enabling process state change handler block.
 
 @code
 @endcode
 \b Example:
 
 @code
 [PubNub setConfiguration:[PNConfiguration defaultConfiguration] andDelegate:self];
 [PubNub connect];
 [PubNub enablePresenceObservationForChannels:[PNChannel channelsWithNames:@[@"iosdev", @"macosdev"]]
  withCompletionHandlingBlock:^(NSArray *channels, PNError *error) {
 
     if (error == nil) {
 
         // PubNub client successfully enabled presence on specified set of channels.
     }
     else {
 
         // PubNub client did fail to enable presence on specified set of channels.
     }
 }];
 
 // There is another way to enable presence observation on channel. You can use \a +channelWithName:shouldObservePresence: \b PNChannel class method
 // to prepare channel instance in a way, which will enable presence automatically. This method should be used when you subscribe on channel(s).
 // [PubNub subscribeOnChannel:[PNChannel channelWithName:@"iosdev" shouldObservePresence:YES]];
 @endcode
 
 And handle it with delegates:
 @code
 - (void)pubnubClient:(PubNub *)client didEnablePresenceObservationOn:(NSArray *)channelObjects {
 
     // PubNub client successfully enabled presence on specified set of channels.
 }
 
 - (void)pubnubClient:(PubNub *)client presenceObservationEnablingDidFailWithError:(PNError *)error {
 
     // PubNub client did fail to enable presence on specified set of channels.
 }
 @endcode
 
 There is also way to observe connection state from any place in your application using  \b PNObservationCenter:
 @code
 [[PNObservationCenter defaultCenter] addClientPresenceEnablingObserver:self withCallbackBlock:^(NSArray *channels, PNError *error) {
 
     if (error == nil) {
 
         // PubNub client successfully enabled presence on specified set of channels.
     }
     else {
 
         // PubNub client did fail to enable presence on specified set of channels.
     }
 }];
 @endcode
 
 @param channels
 Array of \b PNChannel instances for which client should enable presence observation.
 
 @param handlerBlock
 The block which will be called by \b PubNub client as soon as presence enabling state will change. The block takes two arguments:
 \c channels - array of \b PNChannel instances for which presence enabling state changed; \c error - describes what exactly went wrong 
 (check error code and compare it with \b PNErrorCodes ).
 
 @see +enablePresenceObservationForChannels:
 */
+ (void)enablePresenceObservationForChannels:(NSArray *)channels withCompletionHandlingBlock:(PNClientPresenceEnableHandlingBlock)handlerBlock;

/**
 Disable presence observation on specific channel. This method will subscribe \b PubNub client on special type of channel and receive presence events
 from them. Each channel has it's own presence observation pair. If \b PubNub client doesn't observe for presence events, you will be unable to know
 when someone is joining or leaving specific channel.
 
 @code
 @endcode
 \b Example:
 
 @code
 [PubNub setConfiguration:[PNConfiguration defaultConfiguration] andDelegate:self];
 [PubNub connect];
 [PubNub disablePresenceObservationForChannel:[PNChannel channelWithName:@"iosdev"]];
 @endcode
 
 And handle it with delegates:
 @code
 - (void)pubnubClient:(PubNub *)client didDisablePresenceObservationOn:(NSArray *)channelObjects {
 
     // PubNub client successfully disabled presence on specified set of channels.
 }
 
 - (void)pubnubClient:(PubNub *)client presenceObservationDisablingDidFailWithError:(PNError *)error {
 
     // PubNub client did fail to disable presence on specified set of channels.
 }
 @endcode
 
 There is also way to observe presence disabling state from any place in your application using  \b PNObservationCenter:
 @code
 [[PNObservationCenter defaultCenter] addClientPresenceDisablingObserver:self withCallbackBlock:^(NSArray *channels, PNError *error) {
 
     if (error == nil) {
 
         // PubNub client successfully disabled presence on specified set of channels.
     }
     else {
 
         // PubNub client did fail to disable presence on specified set of channels.
     }
 }];
 @endcode
 
 @param channel
 \b PNChannel instance for which client should disable presence observation.
 
 @see +disablePresenceObservationForChannel:withCompletionHandlingBlock:
 */
+ (void)disablePresenceObservationForChannel:(PNChannel *)channel;

/**
 Disable presence observation on set of channels.
 
 @code
 @endcode
 This method extendeds \a +disablePresenceObservationForChannel: and allow to specify presence disabling process state change handler block.
 
 @code
 @endcode
 \b Example:
 
 @code
 [PubNub setConfiguration:[PNConfiguration defaultConfiguration] andDelegate:self];
 [PubNub connect];
 [PubNub disablePresenceObservationForChannel:[PNChannel channelWithName:@"iosdev"]
  withCompletionHandlingBlock:^(NSArray *channels, PNError *error) {
 
     if (error == nil) {
 
         // PubNub client successfully disabled presence on specified set of channels.
     }
     else {
 
         // PubNub client did fail to disable presence on specified set of channels.
     }
 }];
 @endcode
 
 And handle it with delegates:
 @code
 - (void)pubnubClient:(PubNub *)client didDisablePresenceObservationOn:(NSArray *)channelObjects {
 
     // PubNub client successfully disabled presence on specified set of channels.
 }
 
 - (void)pubnubClient:(PubNub *)client presenceObservationDisablingDidFailWithError:(PNError *)error {
 
     // PubNub client did fail to disable presence on specified set of channels.
 }
 @endcode
 
 There is also way to observe connection state from any place in your application using  \b PNObservationCenter:
 @code
 [[PNObservationCenter defaultCenter] addClientPresenceDisablingObserver:self withCallbackBlock:^(NSArray *channels, PNError *error) {
 
     if (error == nil) {
 
         // PubNub client successfully disabled presence on specified set of channels.
     }
     else {
 
         // PubNub client did fail to disable presence on specified set of channels.
     }
 }];
 @endcode
 
 @param channel
 \b PNChannel instance for which client should disable presence observation.
 
 @param handlerBlock
 The block which will be called by \b PubNub client as soon as presence disabling state will change. The block takes two arguments:
 \c channels - array of \b PNChannel instances for which presence disabling state changed; \c error - describes what exactly went wrong
 (check error code and compare it with \b PNErrorCodes ).
 
 @see +disablePresenceObservationForChannel:
 */
+ (void)disablePresenceObservationForChannel:(PNChannel *)channel withCompletionHandlingBlock:(PNClientPresenceDisableHandlingBlock)handlerBlock;

/**
 Disable presence observation on set of channels. This method will subscribe \b PubNub client on special type of channels and receive presence events
 from them. Each channel has it's own presence observation pair. If \b PubNub client doesn't observe for presence events, you will be unable to know
 when someone is joining or leaving specific channel.
 
 @code
 @endcode
 \b Example:
 
 @code
 [PubNub setConfiguration:[PNConfiguration defaultConfiguration] andDelegate:self];
 [PubNub connect];
 [PubNub disablePresenceObservationForChannels:[PNChannel channelsWithNames:@[@"iosdev", @"macosdev"]]];
 @endcode
 
 And handle it with delegates:
 @code
 - (void)pubnubClient:(PubNub *)client didDisablePresenceObservationOn:(NSArray *)channelObjects {
 
     // PubNub client successfully disabled presence on specified set of channels.
 }
 
 - (void)pubnubClient:(PubNub *)client presenceObservationDisablingDidFailWithError:(PNError *)error {
 
     // PubNub client did fail to disable presence on specified set of channels.
 }
 @endcode
 
 There is also way to observe presence disabling state from any place in your application using  \b PNObservationCenter:
 @code
 [[PNObservationCenter defaultCenter] addClientPresenceDisablingObserver:self withCallbackBlock:^(NSArray *channels, PNError *error) {
 
     if (error == nil) {
 
         // PubNub client successfully disabled presence on specified set of channels.
     }
     else {
 
         // PubNub client did fail to disable presence on specified set of channels.
     }
 }];
 @endcode
 
 @param channels
 Array of \b PNChannel instances for which client should disable presence observation.
 
 @see +disablePresenceObservationForChannels:withCompletionHandlingBlock:
 */
+ (void)disablePresenceObservationForChannels:(NSArray *)channels;

/**
 Enable presence observation on set of channels.
 
 @code
 @endcode
 This method extendeds \a +disablePresenceObservationForChannels: and allow to specify presence disabling process state change handler block.
 
 @code
 @endcode
 \b Example:
 
 @code
 [PubNub setConfiguration:[PNConfiguration defaultConfiguration] andDelegate:self];
 [PubNub connect];
 [PubNub disablePresenceObservationForChannels:[PNChannel channelsWithNames:@[@"iosdev", @"macosdev"]]
  withCompletionHandlingBlock:^(NSArray *channels, PNError *error) {
 
     if (error == nil) {
 
         // PubNub client successfully disabled presence on specified set of channels.
     }
     else {
 
         // PubNub client did fail to disable presence on specified set of channels.
     }
 }];
 @endcode
 
 And handle it with delegates:
 @code
 - (void)pubnubClient:(PubNub *)client didDisablePresenceObservationOn:(NSArray *)channelObjects {
 
     // PubNub client successfully disabled presence on specified set of channels.
 }
 
 - (void)pubnubClient:(PubNub *)client presenceObservationDisablingDidFailWithError:(PNError *)error {
 
     // PubNub client did fail to disable presence on specified set of channels.
 }
 @endcode
 
 There is also way to observe connection state from any place in your application using  \b PNObservationCenter:
 @code
 [[PNObservationCenter defaultCenter] addClientPresenceDisablingObserver:self withCallbackBlock:^(NSArray *channels, PNError *error) {
 
     if (error == nil) {
 
         // PubNub client successfully disabled presence on specified set of channels.
     }
     else {
 
         // PubNub client did fail to disable presence on specified set of channels.
     }
 }];
 @endcode
 
 @param channels
 Array of \b PNChannel instances for which client should disable presence observation.
 
 @param handlerBlock
 The block which will be called by \b PubNub client as soon as presence disabling state will change. The block takes two arguments:
 \c channels - array of \b PNChannel instances for which presence disabling state changed; \c error - describes what exactly went wrong
 (check error code and compare it with \b PNErrorCodes ).
 
 @see +disablePresenceObservationForChannels:
 */
+ (void)disablePresenceObservationForChannels:(NSArray *)channels withCompletionHandlingBlock:(PNClientPresenceDisableHandlingBlock)handlerBlock;


#pragma mark - Instance methods

/**
 Checking whether client added presence observation on particular channel or not.
 
 @code
 @endcode
 \b Example:
 
 @code
 PubNub *pubNub = [PubNub clientWithConfiguration:[PNConfiguration defaultConfiguration] andDelegate:self];
 [pubNub connect];
 [pubNub enablePresenceObservationForChannel:[PNChannel channelWithName:@"macosdev"]
  withCompletionHandlingBlock:^(NSArray *channels, PNError *error) {
  
      if (error == nil) {
      
          BOOL isObservingPresenceOnIOS = [PubNub isPresenceObservationEnabledForChannel:[PNChannel channelWithName:@"iosdev"]];
          NSLog(@"Observing presence events on 'iosdev' channel? %@", isObservingPresenceOnIOS ? @"YES" : @"NO");
      }
      else {
          
          // PubNub client was unable to enable presence on specified channels and reason can be found in error instance.
      }
 }];
 @endcode
 
 @return \c YES in case if channel already added to presence observation list and \c NO if not.
 
 @see -enablePresenceObservationForChannel:
 @see -disablePresenceObservationForChannel:
 */
- (BOOL)isPresenceObservationEnabledForChannel:(PNChannel *)channel;

/**
 Enable presence observation on specific channel. This method will subscribe \b PubNub client on special type of channel and receive presence events
 from it. Each channel has it's own presence observation pair. If \b PubNub client doesn't observe for presence events, you will be unable to know
 when someone is joining or leaving specific channel.
 
 @code
 @endcode
 \b Example:
 
 @code
 PubNub *pubNub = [PubNub clientWithConfiguration:[PNConfiguration defaultConfiguration] andDelegate:self];
 [pubNub connect];
 [pubNub enablePresenceObservationForChannel:[PNChannel channelWithName:@"iosdev"]];
 
 // There is another way to enable presence observation on channel. You can use \a +channelWithName:shouldObservePresence: \b PNChannel class method
 // to prepare channel instance in a way, which will enable presence automatically. This method should be used when you subscribe on channel(s).
 // [PubNub subscribeOnChannel:[PNChannel channelWithName:@"iosdev" shouldObservePresence:YES]];
 @endcode
 
 And handle it with delegates:
 @code
 - (void)pubnubClient:(PubNub *)client didEnablePresenceObservationOn:(NSArray *)channelObjects {
 
     // PubNub client successfully enabled presence on specified set of channels.
 }
 
 - (void)pubnubClient:(PubNub *)client presenceObservationEnablingDidFailWithError:(PNError *)error {
 
     // PubNub client did fail to enable presence on specified set of channels.
 }
 @endcode
 
 There is also way to observe connection state from any place in your application using  \b PNObservationCenter:
 @code
 [pubNub.observationCenter addClientPresenceEnablingObserver:self withCallbackBlock:^(NSArray *channels, PNError *error) {
 
     if (error == nil) {
 
         // PubNub client successfully enabled presence on specified set of channels.
     }
     else {
 
         // PubNub client did fail to enable presence on specified set of channels.
     }
 }];
 @endcode
 
 @param channel
 \b PNChannel instance for which client should enable presence observation.
 
 @see -enablePresenceObservationForChannel:withCompletionHandlingBlock:
 */
- (void)enablePresenceObservationForChannel:(PNChannel *)channel;

/**
 Enable presence observation on specific channel.
 
 @code
 @endcode
 This method extendeds \a -enablePresenceObservationForChannel: and allow to specify presence enabling process state change handler block.
 
 @code
 @endcode
 \b Example:
 
 @code
 PubNub *pubNub = [PubNub clientWithConfiguration:[PNConfiguration defaultConfiguration] andDelegate:self];
 [pubNub connect];
 [pubNub enablePresenceObservationForChannel:[PNChannel channelWithName:@"iosdev"] withCompletionHandlingBlock:^(NSArray *channels, PNError *error) {
 
     if (error == nil) {
 
         // PubNub client successfully enabled presence on specified set of channels.
     }
     else {
 
         // PubNub client did fail to enable presence on specified set of channels.
     }
 }];
 
 // There is another way to enable presence observation on channel. You can use \a +channelWithName:shouldObservePresence: \b PNChannel class method
 // to prepare channel instance in a way, which will enable presence automatically. This method should be used when you subscribe on channel(s).
 // [PubNub subscribeOnChannel:[PNChannel channelWithName:@"iosdev" shouldObservePresence:YES]];
 @endcode
 
 And handle it with delegates:
 @code
 - (void)pubnubClient:(PubNub *)client didEnablePresenceObservationOn:(NSArray *)channelObjects {
 
     // PubNub client successfully enabled presence on specified set of channels.
 }
 
 - (void)pubnubClient:(PubNub *)client presenceObservationEnablingDidFailWithError:(PNError *)error {
 
     // PubNub client did fail to enable presence on specified set of channels.
 }
 @endcode
 
 There is also way to observe connection state from any place in your application using  \b PNObservationCenter:
 @code
 [pubNub.observationCenter addClientPresenceEnablingObserver:self withCallbackBlock:^(NSArray *channels, PNError *error) {
 
     if (error == nil) {
 
         // PubNub client successfully enabled presence on specified set of channels.
     }
     else {
 
         // PubNub client did fail to enable presence on specified set of channels.
     }
 }];
 @endcode
 
 @param channel
 \b PNChannel instance for which client should enable presence observation.
 
 @param handlerBlock
 The block which will be called by \b PubNub client as soon as presence enabling state will change. The block takes two arguments:
 \c channels - array of \b PNChannel instances for which presence enabling state changed; \c error - describes what exactly went wrong 
 (check error code and compare it with \b PNErrorCodes ).
 
 @see -enablePresenceObservationForChannel:
 */
- (void)enablePresenceObservationForChannel:(PNChannel *)channel withCompletionHandlingBlock:(PNClientPresenceEnableHandlingBlock)handlerBlock;

/**
 Enable presence observation on set of channels. This method will subscribe \b PubNub client on special type of channels and receive presence events
 from them. Each channel has it's own presence observation pair. If \b PubNub client doesn't observe for presence events, you will be unable to know
 when someone is joining or leaving specific channel.
 
 @code
 @endcode
 \b Example:
 
 @code
 PubNub *pubNub = [PubNub clientWithConfiguration:[PNConfiguration defaultConfiguration] andDelegate:self];
 [pubNub connect];
 [pubNub enablePresenceObservationForChannels:[PNChannel channelsWithNames:@[@"iosdev", @"macosdev"]]];
 
 // There is another way to enable presence observation on channel. You can use \a +channelWithName:shouldObservePresence: \b PNChannel class method
 // to prepare channel instance in a way, which will enable presence automatically. This method should be used when you subscribe on channel(s).
 // [PubNub subscribeOnChannel:[PNChannel channelWithName:@"iosdev" shouldObservePresence:YES]];
 @endcode
 
 And handle it with delegates:
 @code
 - (void)pubnubClient:(PubNub *)client didEnablePresenceObservationOn:(NSArray *)channelObjects {
 
     // PubNub client successfully enabled presence on specified set of channels.
 }
 
 - (void)pubnubClient:(PubNub *)client presenceObservationEnablingDidFailWithError:(PNError *)error {
 
     // PubNub client did fail to enable presence on specified set of channels.
 }
 @endcode
 
 There is also way to observe connection state from any place in your application using  \b PNObservationCenter:
 @code
 [pubNub.observationCenter addClientPresenceEnablingObserver:self withCallbackBlock:^(NSArray *channels, PNError *error) {
 
     if (error == nil) {
 
         // PubNub client successfully enabled presence on specified set of channels.
     }
     else {
 
         // PubNub client did fail to enable presence on specified set of channels.
     }
 }];
 @endcode
 
 @param channels
 Array of \b PNChannel instances for which client should enable presence observation.
 
 @see -enablePresenceObservationForChannels:withCompletionHandlingBlock:
 */
- (void)enablePresenceObservationForChannels:(NSArray *)channels;

/**
 Enable presence observation on set of channels.
 
 @code
 @endcode
 This method extendeds \a -enablePresenceObservationForChannels: and allow to specify presence enabling process state change handler block.
 
 @code
 @endcode
 \b Example:
 
 @code
 PubNub *pubNub = [PubNub clientWithConfiguration:[PNConfiguration defaultConfiguration] andDelegate:self];
 [pubNub connect];
 [pubNub enablePresenceObservationForChannels:[PNChannel channelsWithNames:@[@"iosdev", @"macosdev"]]
  withCompletionHandlingBlock:^(NSArray *channels, PNError *error) {
 
     if (error == nil) {
 
         // PubNub client successfully enabled presence on specified set of channels.
     }
     else {
 
         // PubNub client did fail to enable presence on specified set of channels.
     }
 }];
 
 // There is another way to enable presence observation on channel. You can use \a +channelWithName:shouldObservePresence: \b PNChannel class method
 // to prepare channel instance in a way, which will enable presence automatically. This method should be used when you subscribe on channel(s).
 // [PubNub subscribeOnChannel:[PNChannel channelWithName:@"iosdev" shouldObservePresence:YES]];
 @endcode
 
 And handle it with delegates:
 @code
 - (void)pubnubClient:(PubNub *)client didEnablePresenceObservationOn:(NSArray *)channelObjects {
 
     // PubNub client successfully enabled presence on specified set of channels.
 }
 
 - (void)pubnubClient:(PubNub *)client presenceObservationEnablingDidFailWithError:(PNError *)error {
 
     // PubNub client did fail to enable presence on specified set of channels.
 }
 @endcode
 
 There is also way to observe connection state from any place in your application using  \b PNObservationCenter:
 @code
 [pubNub.observationCenter addClientPresenceEnablingObserver:self withCallbackBlock:^(NSArray *channels, PNError *error) {
 
     if (error == nil) {
 
         // PubNub client successfully enabled presence on specified set of channels.
     }
     else {
 
         // PubNub client did fail to enable presence on specified set of channels.
     }
 }];
 @endcode
 
 @param channels
 Array of \b PNChannel instances for which client should enable presence observation.
 
 @param handlerBlock
 The block which will be called by \b PubNub client as soon as presence enabling state will change. The block takes two arguments:
 \c channels - array of \b PNChannel instances for which presence enabling state changed; \c error - describes what exactly went wrong 
 (check error code and compare it with \b PNErrorCodes ).
 
 @see -enablePresenceObservationForChannels:
 */
- (void)enablePresenceObservationForChannels:(NSArray *)channels withCompletionHandlingBlock:(PNClientPresenceEnableHandlingBlock)handlerBlock;

/**
 Disable presence observation on specific channel. This method will subscribe \b PubNub client on special type of channel and receive presence events
 from them. Each channel has it's own presence observation pair. If \b PubNub client doesn't observe for presence events, you will be unable to know
 when someone is joining or leaving specific channel.
 
 @code
 @endcode
 \b Example:
 
 @code
 PubNub *pubNub = [PubNub clientWithConfiguration:[PNConfiguration defaultConfiguration] andDelegate:self];
 [pubNub connect];
 [pubNub disablePresenceObservationForChannel:[PNChannel channelWithName:@"iosdev"]];
 @endcode
 
 And handle it with delegates:
 @code
 - (void)pubnubClient:(PubNub *)client didDisablePresenceObservationOn:(NSArray *)channelObjects {
 
     // PubNub client successfully disabled presence on specified set of channels.
 }
 
 - (void)pubnubClient:(PubNub *)client presenceObservationDisablingDidFailWithError:(PNError *)error {
 
     // PubNub client did fail to disable presence on specified set of channels.
 }
 @endcode
 
 There is also way to observe presence disabling state from any place in your application using  \b PNObservationCenter:
 @code
 [pubNub.observationCenter addClientPresenceDisablingObserver:self withCallbackBlock:^(NSArray *channels, PNError *error) {
 
     if (error == nil) {
 
         // PubNub client successfully disabled presence on specified set of channels.
     }
     else {
 
         // PubNub client did fail to disable presence on specified set of channels.
     }
 }];
 @endcode
 
 @param channel
 \b PNChannel instance for which client should disable presence observation.
 
 @see -disablePresenceObservationForChannel:withCompletionHandlingBlock:
 */
- (void)disablePresenceObservationForChannel:(PNChannel *)channel;

/**
 Disable presence observation on set of channels.
 
 @code
 @endcode
 This method extendeds \a -disablePresenceObservationForChannel: and allow to specify presence disabling process state change handler block.
 
 @code
 @endcode
 \b Example:
 
 @code
 PubNub *pubNub = [PubNub clientWithConfiguration:[PNConfiguration defaultConfiguration] andDelegate:self];
 [pubNub connect];
 [pubNub disablePresenceObservationForChannel:[PNChannel channelWithName:@"iosdev"]
  withCompletionHandlingBlock:^(NSArray *channels, PNError *error) {
 
     if (error == nil) {
 
         // PubNub client successfully disabled presence on specified set of channels.
     }
     else {
 
         // PubNub client did fail to disable presence on specified set of channels.
     }
 }];
 @endcode
 
 And handle it with delegates:
 @code
 - (void)pubnubClient:(PubNub *)client didDisablePresenceObservationOn:(NSArray *)channelObjects {
 
     // PubNub client successfully disabled presence on specified set of channels.
 }
 
 - (void)pubnubClient:(PubNub *)client presenceObservationDisablingDidFailWithError:(PNError *)error {
 
     // PubNub client did fail to disable presence on specified set of channels.
 }
 @endcode
 
 There is also way to observe connection state from any place in your application using  \b PNObservationCenter:
 @code
 [pubNub.observationCenter addClientPresenceDisablingObserver:self withCallbackBlock:^(NSArray *channels, PNError *error) {
 
     if (error == nil) {
 
         // PubNub client successfully disabled presence on specified set of channels.
     }
     else {
 
         // PubNub client did fail to disable presence on specified set of channels.
     }
 }];
 @endcode
 
 @param channel
 \b PNChannel instance for which client should disable presence observation.
 
 @param handlerBlock
 The block which will be called by \b PubNub client as soon as presence disabling state will change. The block takes two arguments:
 \c channels - array of \b PNChannel instances for which presence disabling state changed; \c error - describes what exactly went wrong
 (check error code and compare it with \b PNErrorCodes ).
 
 @see -disablePresenceObservationForChannel:
 */
- (void)disablePresenceObservationForChannel:(PNChannel *)channel withCompletionHandlingBlock:(PNClientPresenceDisableHandlingBlock)handlerBlock;

/**
 Disable presence observation on set of channels. This method will subscribe \b PubNub client on special type of channels and receive presence events
 from them. Each channel has it's own presence observation pair. If \b PubNub client doesn't observe for presence events, you will be unable to know
 when someone is joining or leaving specific channel.
 
 @code
 @endcode
 \b Example:
 
 @code
 PubNub *pubNub = [PubNub clientWithConfiguration:[PNConfiguration defaultConfiguration] andDelegate:self];
 [pubNub connect];
 [pubNub disablePresenceObservationForChannels:[PNChannel channelsWithNames:@[@"iosdev", @"macosdev"]]];
 @endcode
 
 And handle it with delegates:
 @code
 - (void)pubnubClient:(PubNub *)client didDisablePresenceObservationOn:(NSArray *)channelObjects {
 
     // PubNub client successfully disabled presence on specified set of channels.
 }
 
 - (void)pubnubClient:(PubNub *)client presenceObservationDisablingDidFailWithError:(PNError *)error {
 
     // PubNub client did fail to disable presence on specified set of channels.
 }
 @endcode
 
 There is also way to observe presence disabling state from any place in your application using  \b PNObservationCenter:
 @code
 [pubNub.observationCenter addClientPresenceDisablingObserver:self withCallbackBlock:^(NSArray *channels, PNError *error) {
 
     if (error == nil) {
 
         // PubNub client successfully disabled presence on specified set of channels.
     }
     else {
 
         // PubNub client did fail to disable presence on specified set of channels.
     }
 }];
 @endcode
 
 @param channels
 Array of \b PNChannel instances for which client should disable presence observation.
 
 @see -disablePresenceObservationForChannels:withCompletionHandlingBlock:
 */
- (void)disablePresenceObservationForChannels:(NSArray *)channels;

/**
 Enable presence observation on set of channels.
 
 @code
 @endcode
 This method extendeds \a -disablePresenceObservationForChannels: and allow to specify presence disabling process state change handler block.
 
 @code
 @endcode
 \b Example:
 
 @code
 PubNub *pubNub = [PubNub clientWithConfiguration:[PNConfiguration defaultConfiguration] andDelegate:self];
 [pubNub connect];
 [pubNub disablePresenceObservationForChannels:[PNChannel channelsWithNames:@[@"iosdev", @"macosdev"]]
  withCompletionHandlingBlock:^(NSArray *channels, PNError *error) {
 
     if (error == nil) {
 
         // PubNub client successfully disabled presence on specified set of channels.
     }
     else {
 
         // PubNub client did fail to disable presence on specified set of channels.
     }
 }];
 @endcode
 
 And handle it with delegates:
 @code
 - (void)pubnubClient:(PubNub *)client didDisablePresenceObservationOn:(NSArray *)channelObjects {
 
     // PubNub client successfully disabled presence on specified set of channels.
 }
 
 - (void)pubnubClient:(PubNub *)client presenceObservationDisablingDidFailWithError:(PNError *)error {
 
     // PubNub client did fail to disable presence on specified set of channels.
 }
 @endcode
 
 There is also way to observe connection state from any place in your application using  \b PNObservationCenter:
 @code
 [pubNub.observationCenter addClientPresenceDisablingObserver:self withCallbackBlock:^(NSArray *channels, PNError *error) {
 
     if (error == nil) {
 
         // PubNub client successfully disabled presence on specified set of channels.
     }
     else {
 
         // PubNub client did fail to disable presence on specified set of channels.
     }
 }];
 @endcode
 
 @param channels
 Array of \b PNChannel instances for which client should disable presence observation.
 
 @param handlerBlock
 The block which will be called by \b PubNub client as soon as presence disabling state will change. The block takes two arguments:
 \c channels - array of \b PNChannel instances for which presence disabling state changed; \c error - describes what exactly went wrong
 (check error code and compare it with \b PNErrorCodes ).
 
 @see -disablePresenceObservationForChannels:
 */
- (void)disablePresenceObservationForChannels:(NSArray *)channels withCompletionHandlingBlock:(PNClientPresenceDisableHandlingBlock)handlerBlock;

#pragma mark - 


@end
