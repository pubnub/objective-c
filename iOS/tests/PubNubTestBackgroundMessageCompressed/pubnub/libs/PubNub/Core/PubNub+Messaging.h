#import "PubNub.h"

/**
 Base class extension which provide methods for messaging.
 
 @author Sergey Mamontov
 @version 3.7.0
 @copyright © 2009-13 PubNub Inc.
 */
@interface PubNub (Messaging)


#pragma mark - Class (singleton) methods

/**
 Send \c message to the \c channel. All messages placed into queue and will be sent in the same order as they were scheduled.
 
 @code
 @endcode
 \b Example:
 
 @code
 [PubNub setConfiguration:[PNConfiguration defaultConfiguration] andDelegate:self];
 [PubNub connect];
 [PubNub sendMessage:@{@"array": @[@"of", @"strings"], @"and": @16} toChannel:[PNChannel channelWithName:@"iosdev"]];
 @endcode
 
 And handle it with delegates:
 @code
 - (void)pubnubClient:(PubNub *)client willSendMessage:(PNMessage *)message {
 
     // PubNub client is sending message at this moment.
 }
 
 - (void)pubnubClient:(PubNub *)client didFailMessageSend:(PNMessage *)message withError:(PNError *)error {
 
     // PubNub client failed to send message and reason is in 'error'.
 }
 
 - (void)pubnubClient:(PubNub *)client didSendMessage:(PNMessage *)message {
 
     // PubNub client successfully sent message to specified channel.
 }
 @endcode
 
 There is also way to observe message processing from any place in your application using  \b PNObservationCenter:
 @code
 [[PNObservationCenter defaultCenter] addMessageProcessingObserver:self
  withBlock:^(PNMessageState state, id data) {
 
  switch (state) {
      case PNMessageSending:
 
          // PubNub client is sending message at this moment. 'data' stores reference on PNMessage instance which is processing at this moment.
          break;
      case PNMessageSendingError:
 
          // PubNub client failed to send message and reason is in 'data' object.
          break;
      case PNMessageSent:
 
          // PubNub client successfully sent message to specified channel. 'data' stores reference on PNMessage instance which has been sent.
          break;
      }
 }];
 @endcode
 
 @param message
 Object which should be sent to the channel. It can be any object which can be serialized into JSON: \c NSString, \c NSNumber, \c NSArray,
 \c NSDictionary.
 
 @param channel
 \b PNChannel instance into which message should be sent.
 
 @return \b PNMessage instance if message payload is correct or \c nil if not.
 */
+ (PNMessage *)sendMessage:(id)message toChannel:(PNChannel *)channel;

/**
 Same as +sendMessage:toChannel: but allow to specify completion block which will be called when message will be sent or in case of error.
 
 Only last call of this method will call completion block. If you need to track message sending from many places, use PNObservationCenter methods
 for this purpose.
 */
+ (PNMessage *)sendMessage:(id)message toChannel:(PNChannel *)channel withCompletionBlock:(PNClientMessageProcessingBlock)success;

/**
 Send \c message to the \c channel. All messages placed into queue and will be sent in the same order as they were scheduled.
 
 @code
 @endcode
 This method extendeds \a +sendMessage:toChannel: and allow to specify whether message should be stored in history or not.
 
 @code
 @endcode
 \b Example:
 
 @code
 [PubNub setConfiguration:[PNConfiguration defaultConfiguration] andDelegate:self];
 [PubNub connect];
 [PubNub sendMessage:@{@"array": @[@"of", @"strings"], @"and": @16} toChannel:[PNChannel channelWithName:@"iosdev"] 
      storeInHistory:NO];
 @endcode
 
 And handle it with delegates:
 @code
 - (void)pubnubClient:(PubNub *)client willSendMessage:(PNMessage *)message {
 
     // PubNub client is sending message at this moment.
 }
 
 - (void)pubnubClient:(PubNub *)client didFailMessageSend:(PNMessage *)message withError:(PNError *)error {
 
     // PubNub client failed to send message and reason is in 'error'.
 }
 
 - (void)pubnubClient:(PubNub *)client didSendMessage:(PNMessage *)message {
 
     // PubNub client successfully sent message to specified channel.
 }
 @endcode
 
 There is also way to observe message processing from any place in your application using  \b PNObservationCenter:
 @code
 [[PNObservationCenter defaultCenter] addMessageProcessingObserver:self
  withBlock:^(PNMessageState state, id data) {
 
  switch (state) {
      case PNMessageSending:
 
          // PubNub client is sending message at this moment. 'data' stores reference on PNMessage instance which is processing at this moment.
          break;
      case PNMessageSendingError:
 
          // PubNub client failed to send message and reason is in 'data' object.
          break;
      case PNMessageSent:
 
          // PubNub client successfully sent message to specified channel. 'data' stores reference on PNMessage instance which has been sent.
          break;
      }
 }];
 @endcode
 
 @param message
 Object which should be sent to the channel. It can be any object which can be serialized into JSON: \c NSString, \c NSNumber, \c NSArray,
 \c NSDictionary.
 
 @param channel
 \b PNChannel instance into which message should be sent.
 
 @param shouldStoreInHistory
 \c YES in case if message should be stored on \b PubNub service side and become available with History API.
 
 @return \b PNMessage instance if message payload is correct or \c nil if not.
 */
+ (PNMessage *)sendMessage:(id)message toChannel:(PNChannel *)channel storeInHistory:(BOOL)shouldStoreInHistory;

/**
 Same as +sendMessage:toChannel:withCompletionBlock: but allow to specify whether message should be stored in history or not.
 
 @param shouldStoreInHistory
 \c YES in case if message should be stored on \b PubNub service side and become available with History API.
 */
+ (PNMessage *)sendMessage:(id)message toChannel:(PNChannel *)channel storeInHistory:(BOOL)shouldStoreInHistory
       withCompletionBlock:(PNClientMessageProcessingBlock)success;

/**
 Send \c message to the \c channel. All messages placed into queue and will be sent in the same order as they were scheduled.
 
 @code
 @endcode
 This method extends \a +sendMessage:toChannel: and allow to specify separate payload which will be sent along with message using APNS.
 
 @code
 @endcode
 \b Example:
 
 @code
 [PubNub setConfiguration:[PNConfiguration defaultConfiguration] andDelegate:self];
 [PubNub connect];
 [PubNub sendMessage:@{@"array": @[@"of", @"strings"], @"and": @16} 
 applePushNotification:@{@"aps":@{@"alert":@"Someone sent array of strings"}} 
           toChannel:[PNChannel channelWithName:@"iosdev"]];
 @endcode
 
 And handle it with delegates:
 @code
 - (void)pubnubClient:(PubNub *)client willSendMessage:(PNMessage *)message {
 
     // PubNub client is sending message at this moment.
 }
 
 - (void)pubnubClient:(PubNub *)client didFailMessageSend:(PNMessage *)message withError:(PNError *)error {
 
     // PubNub client failed to send message and reason is in 'error'.
 }
 
 - (void)pubnubClient:(PubNub *)client didSendMessage:(PNMessage *)message {
 
     // PubNub client successfully sent message to specified channel.
 }
 @endcode
 
 There is also way to observe message processing from any place in your application using  \b PNObservationCenter:
 @code
 [[PNObservationCenter defaultCenter] addMessageProcessingObserver:self
  withBlock:^(PNMessageState state, id data) {
 
  switch (state) {
      case PNMessageSending:
 
          // PubNub client is sending message at this moment. 'data' stores reference on PNMessage instance which is processing at this moment.
          break;
      case PNMessageSendingError:
 
          // PubNub client failed to send message and reason is in 'data' object.
          break;
      case PNMessageSent:
 
          // PubNub client successfully sent message to specified channel. 'data' stores reference on PNMessage instance which has been sent.
          break;
      }
 }];
 @endcode
 
 @param message
 Object which should be sent to the channel. It can be any object which can be serialized into JSON: \c NSString, \c NSNumber, \c NSArray,
 \c NSDictionary.

 @param apnsPayload
 Valid APNS payload dictionary which should be delivered using push service to all subscribers. You can append some more data except message which should be shown to the user.

 @param channel
 \b PNChannel instance to which message should be sent.
 
 @return \b PNMessage instance if message payload is correct or \c nil if not.
 */
+ (PNMessage *)sendMessage:(id)message applePushNotification:(NSDictionary *)apnsPayload toChannel:(PNChannel *)channel;

/**
 Send \c message to the \c channel. All messages placed into queue and will be sent in the same order as they were scheduled.
 
 @code
 @endcode
 This method extends \a +sendMessage:applePushNotification:toChannel: and allow to specify message sending processing block.
 
 @code
 @endcode
 \b Example:
 
 @code
 [PubNub setConfiguration:[PNConfiguration defaultConfiguration] andDelegate:self];
 [PubNub connect];
 [PubNub sendMessage:@{@"array": @[@"of", @"strings"], @"and": @16} 
 applePushNotification:@{@"aps":@{@"alert":@"Someone sent array of strings"}} 
           toChannel:[PNChannel channelWithName:@"iosdev"]
 withCompletionBlock:^(PNMessageState state, id data) {
 
  switch (state) {
      case PNMessageSending:
 
          // PubNub client is sending message at this moment. 'data' stores reference on PNMessage instance which is processing at this moment.
          break;
      case PNMessageSendingError:
 
          // PubNub client failed to send message and reason is in 'data' object.
          break;
      case PNMessageSent:
 
          // PubNub client successfully sent message to specified channel. 'data' stores reference on PNMessage instance which has been sent.
          break;
      }
 }];
 @endcode
 
 And handle it with delegates:
 @code
 - (void)pubnubClient:(PubNub *)client willSendMessage:(PNMessage *)message {
 
     // PubNub client is sending message at this moment.
 }
 
 - (void)pubnubClient:(PubNub *)client didFailMessageSend:(PNMessage *)message withError:(PNError *)error {
 
     // PubNub client failed to send message and reason is in 'error'.
 }
 
 - (void)pubnubClient:(PubNub *)client didSendMessage:(PNMessage *)message {
 
     // PubNub client successfully sent message to specified channel.
 }
 @endcode
 
 There is also way to observe message processing from any place in your application using  \b PNObservationCenter:
 @code
 [[PNObservationCenter defaultCenter] addMessageProcessingObserver:self
  withBlock:^(PNMessageState state, id data) {
 
  switch (state) {
      case PNMessageSending:
 
          // PubNub client is sending message at this moment. 'data' stores reference on PNMessage instance which is processing at this moment.
          break;
      case PNMessageSendingError:
 
          // PubNub client failed to send message and reason is in 'data' object.
          break;
      case PNMessageSent:
 
          // PubNub client successfully sent message to specified channel. 'data' stores reference on PNMessage instance which has been sent.
          break;
      }
 }];
 @endcode
 
 @param message
 Object which should be sent to the channel. It can be any object which can be serialized into JSON: \c NSString, \c NSNumber, \c NSArray,
 \c NSDictionary.

 @param apnsPayload
 Valid APNS payload dictionary which should be delivered using push service to all subscribers. You can append some more data except message which should be shown to the user.

 @param channel
 \b PNChannel instance to which message should be sent.

 @param success
 The block which will be called by \b PubNub client any time when message processing state will be changed. The block takes two arguments:
 \c state - one of \b PNMessageState enumerator fields which tell at which stage message at this moment; \c data - depending on whether message is sending/sent or in state
 of message sending failure it can be one of: \b PNMessage or \b PNError instance.
 
 @return \b PNMessage instance if message payload is correct or \c nil if not.
 */
+ (PNMessage *)sendMessage:(id)message applePushNotification:(NSDictionary *)apnsPayload toChannel:(PNChannel *)channel
       withCompletionBlock:(PNClientMessageProcessingBlock)success;

/**
 Send \c message to the \c channel. All messages placed into queue and will be sent in the same order as they were scheduled.
 
 @code
 @endcode
 This method extends \a +sendMessage:applePushNotification:toChannel: and allow to specify whether message should be stored in history or not.
 
 @code
 @endcode
 \b Example:
 
 @code
 [PubNub setConfiguration:[PNConfiguration defaultConfiguration] andDelegate:self];
 [PubNub connect];
 [PubNub sendMessage:@{@"array": @[@"of", @"strings"], @"and": @16} 
applePushNotification:@{@"aps":@{@"alert":@"Someone sent array of strings"}}
           toChannel:[PNChannel channelWithName:@"iosdev"] storeInHistory:NO];
 @endcode
 
 And handle it with delegates:
 @code
 - (void)pubnubClient:(PubNub *)client willSendMessage:(PNMessage *)message {
 
     // PubNub client is sending message at this moment.
 }
 
 - (void)pubnubClient:(PubNub *)client didFailMessageSend:(PNMessage *)message withError:(PNError *)error {
 
     // PubNub client failed to send message and reason is in 'error'.
 }
 
 - (void)pubnubClient:(PubNub *)client didSendMessage:(PNMessage *)message {
 
     // PubNub client successfully sent message to specified channel.
 }
 @endcode
 
 There is also way to observe message processing from any place in your application using  \b PNObservationCenter:
 @code
 [[PNObservationCenter defaultCenter] addMessageProcessingObserver:self
  withBlock:^(PNMessageState state, id data) {
 
  switch (state) {
      case PNMessageSending:
 
          // PubNub client is sending message at this moment. 'data' stores reference on PNMessage instance which is processing at this moment.
          break;
      case PNMessageSendingError:
 
          // PubNub client failed to send message and reason is in 'data' object.
          break;
      case PNMessageSent:
 
          // PubNub client successfully sent message to specified channel. 'data' stores reference on PNMessage instance which has been sent.
          break;
      }
 }];
 @endcode
 
 @param message
 Object which should be sent to the channel. It can be any object which can be serialized into JSON: \c NSString, \c NSNumber, \c NSArray,
 \c NSDictionary.
 
 @param apnsPayload
 Valid APNS payload dictionary which should be delivered using push service to all subscribers. You can append some more data except message which should be shown to the user.
 
 @param channel
 \b PNChannel instance into which message should be sent.
 
 @param shouldStoreInHistory
 \c YES in case if message should be stored on \b PubNub service side and become available with History API.
 
 @return \b PNMessage instance if message payload is correct or \c nil if not.
 */
+ (PNMessage *)sendMessage:(id)message applePushNotification:(NSDictionary *)apnsPayload toChannel:(PNChannel *)channel
            storeInHistory:(BOOL)shouldStoreInHistory;

/**
 Send \c message to the \c channel. All messages placed into queue and will be sent in the same order as they were scheduled.
 
 @code
 @endcode
 This method extends \a +sendMessage:applePushNotification:toChannel:storeInHistory: and allow to specify message sending processing block.
 
 @code
 @endcode
 \b Example:
 
 @code
 [PubNub setConfiguration:[PNConfiguration defaultConfiguration] andDelegate:self];
 [PubNub connect];
 [PubNub sendMessage:@{@"array": @[@"of", @"strings"], @"and": @16} 
applePushNotification:@{@"aps":@{@"alert":@"Someone sent array of strings"}}
           toChannel:[PNChannel channelWithName:@"iosdev"] storeInHistory:NO
 withCompletionBlock:^(PNMessageState state, id data) {
 
  switch (state) {
      case PNMessageSending:
 
          // PubNub client is sending message at this moment. 'data' stores reference on PNMessage instance which is processing at this moment.
          break;
      case PNMessageSendingError:
 
          // PubNub client failed to send message and reason is in 'data' object.
          break;
      case PNMessageSent:
 
          // PubNub client successfully sent message to specified channel. 'data' stores reference on PNMessage instance which has been sent.
          break;
      }
 }];
 @endcode
 
 And handle it with delegates:
 @code
 - (void)pubnubClient:(PubNub *)client willSendMessage:(PNMessage *)message {
 
     // PubNub client is sending message at this moment.
 }
 
 - (void)pubnubClient:(PubNub *)client didFailMessageSend:(PNMessage *)message withError:(PNError *)error {
 
     // PubNub client failed to send message and reason is in 'error'.
 }
 
 - (void)pubnubClient:(PubNub *)client didSendMessage:(PNMessage *)message {
 
     // PubNub client successfully sent message to specified channel.
 }
 @endcode
 
 There is also way to observe message processing from any place in your application using  \b PNObservationCenter:
 @code
 [[PNObservationCenter defaultCenter] addMessageProcessingObserver:self
  withBlock:^(PNMessageState state, id data) {
 
  switch (state) {
      case PNMessageSending:
 
          // PubNub client is sending message at this moment. 'data' stores reference on PNMessage instance which is processing at this moment.
          break;
      case PNMessageSendingError:
 
          // PubNub client failed to send message and reason is in 'data' object.
          break;
      case PNMessageSent:
 
          // PubNub client successfully sent message to specified channel. 'data' stores reference on PNMessage instance which has been sent.
          break;
      }
 }];
 @endcode
 
 @param message
 Object which should be sent to the channel. It can be any object which can be serialized into JSON: \c NSString, \c NSNumber, \c NSArray,
 \c NSDictionary.
 
 @param apnsPayload
 Valid APNS payload dictionary which should be delivered using push service to all subscribers. You can append some more data except message which should be shown to the user.
 
 @param channel
 \b PNChannel instance into which message should be sent.
 
 @param shouldStoreInHistory
 \c YES in case if message should be stored on \b PubNub service side and become available with History API.
 
 @param success
 The block which will be called by \b PubNub client any time when message processing state will be changed. The block takes two arguments:
 \c state - one of \b PNMessageState enumerator fields which tell at which stage message at this moment; \c data - depending on whether message is sending/sent or in state
 of message sending failure it can be one of: \b PNMessage or \b PNError instance.
 
 @return \b PNMessage instance if message payload is correct or \c nil if not.
 */
+ (PNMessage *)sendMessage:(id)message applePushNotification:(NSDictionary *)apnsPayload toChannel:(PNChannel *)channel
            storeInHistory:(BOOL)shouldStoreInHistory withCompletionBlock:(PNClientMessageProcessingBlock)success;

/**
 Send \c message to the \c channel. All messages placed into queue and will be sent in the same order as they were scheduled.
 
 @code
 @endcode
 This method extends \a +sendMessage:toChannel: and allow to specify separate payload which will be sent along with message using GCM.
 
 @code
 @endcode
 \b Example:
 
 @code
 [PubNub setConfiguration:[PNConfiguration defaultConfiguration] andDelegate:self];
 [PubNub connect];
 [PubNub sendMessage:@{@"array": @[@"of", @"strings"], @"and": @16} 
 googleCloudNotification:@{@"data":@{@"summary":@"Someone sent array of strings"}} 
           toChannel:[PNChannel channelWithName:@"iosdev"]];
 @endcode
 
 And handle it with delegates:
 @code
 - (void)pubnubClient:(PubNub *)client willSendMessage:(PNMessage *)message {
 
     // PubNub client is sending message at this moment.
 }
 
 - (void)pubnubClient:(PubNub *)client didFailMessageSend:(PNMessage *)message withError:(PNError *)error {
 
     // PubNub client failed to send message and reason is in 'error'.
 }
 
 - (void)pubnubClient:(PubNub *)client didSendMessage:(PNMessage *)message {
 
     // PubNub client successfully sent message to specified channel.
 }
 @endcode
 
 There is also way to observe message processing from any place in your application using  \b PNObservationCenter:
 @code
 [[PNObservationCenter defaultCenter] addMessageProcessingObserver:self
  withBlock:^(PNMessageState state, id data) {
 
  switch (state) {
      case PNMessageSending:
 
          // PubNub client is sending message at this moment. 'data' stores reference on PNMessage instance which is processing at this moment.
          break;
      case PNMessageSendingError:
 
          // PubNub client failed to send message and reason is in 'data' object.
          break;
      case PNMessageSent:
 
          // PubNub client successfully sent message to specified channel. 'data' stores reference on PNMessage instance which has been sent.
          break;
      }
 }];
 @endcode
 
 @param message
 Object which should be sent to the channel. It can be any object which can be serialized into JSON: \c NSString, \c NSNumber, \c NSArray,
 \c NSDictionary.

 @param gcmPayload
 Valid GCM payload dictionary which should be delivered using cloud service to all subscribers. You can append some more data except message which should be shown to the user.

 @param channel
 \b PNChannel instance to which message should be sent.
 
 @return \b PNMessage instance if message payload is correct or \c nil if not.
 */
+ (PNMessage *)sendMessage:(id)message googleCloudNotification:(NSDictionary *)gcmPayload toChannel:(PNChannel *)channel;

/**
 Send \c message to the \c channel. All messages placed into queue and will be sent in the same order as they were scheduled.
 
 @code
 @endcode
 This method extends \a +sendMessage:googleCloudNotification:toChannel: and allow to specify message sending processing block.
 
 @code
 @endcode
 \b Example:
 
 @code
 [PubNub setConfiguration:[PNConfiguration defaultConfiguration] andDelegate:self];
 [PubNub connect];
 [PubNub sendMessage:@{@"array": @[@"of", @"strings"], @"and": @16} 
 googleCloudNotification:@{@"data":@{@"summary":@"Someone sent array of strings"}}
           toChannel:[PNChannel channelWithName:@"iosdev"]
 withCompletionBlock:^(PNMessageState state, id data) {
 
  switch (state) {
      case PNMessageSending:
 
          // PubNub client is sending message at this moment. 'data' stores reference on PNMessage instance which is processing at this moment.
          break;
      case PNMessageSendingError:
 
          // PubNub client failed to send message and reason is in 'data' object.
          break;
      case PNMessageSent:
 
          // PubNub client successfully sent message to specified channel. 'data' stores reference on PNMessage instance which has been sent.
          break;
      }
 }];
 @endcode
 
 And handle it with delegates:
 @code
 - (void)pubnubClient:(PubNub *)client willSendMessage:(PNMessage *)message {
 
     // PubNub client is sending message at this moment.
 }
 
 - (void)pubnubClient:(PubNub *)client didFailMessageSend:(PNMessage *)message withError:(PNError *)error {
 
     // PubNub client failed to send message and reason is in 'error'.
 }
 
 - (void)pubnubClient:(PubNub *)client didSendMessage:(PNMessage *)message {
 
     // PubNub client successfully sent message to specified channel.
 }
 @endcode
 
 There is also way to observe message processing from any place in your application using  \b PNObservationCenter:
 @code
 [[PNObservationCenter defaultCenter] addMessageProcessingObserver:self
  withBlock:^(PNMessageState state, id data) {
 
  switch (state) {
      case PNMessageSending:
 
          // PubNub client is sending message at this moment. 'data' stores reference on PNMessage instance which is processing at this moment.
          break;
      case PNMessageSendingError:
 
          // PubNub client failed to send message and reason is in 'data' object.
          break;
      case PNMessageSent:
 
          // PubNub client successfully sent message to specified channel. 'data' stores reference on PNMessage instance which has been sent.
          break;
      }
 }];
 @endcode
 
 @param message
 Object which should be sent to the channel. It can be any object which can be serialized into JSON: \c NSString, \c NSNumber, \c NSArray,
 \c NSDictionary.

 @param gcmPayload
 Valid GCM payload dictionary which should be delivered using cloud service to all subscribers. You can append some more data except message which should be shown to the user.

 @param channel
 \b PNChannel instance to which message should be sent.

 @param success
 The block which will be called by \b PubNub client any time when message processing state will be changed. The block takes two arguments:
 \c state - one of \b PNMessageState enumerator fields which tell at which stage message at this moment; \c data - depending on whether message is sending/sent or in state
 of message sending failure it can be one of: \b PNMessage or \b PNError instance.
 
 @return \b PNMessage instance if message payload is correct or \c nil if not.
 */
+ (PNMessage *)sendMessage:(id)message googleCloudNotification:(NSDictionary *)gcmPayload toChannel:(PNChannel *)channel
       withCompletionBlock:(PNClientMessageProcessingBlock)success;

/**
 Send \c message to the \c channel. All messages placed into queue and will be sent in the same order as they were scheduled.
 
 @code
 @endcode
 This method extends \a +sendMessage:googleCloudNotification:toChannel: and allow to specify whether message should be stored in history or not.
 
 @code
 @endcode
 \b Example:
 
 @code
 [PubNub setConfiguration:[PNConfiguration defaultConfiguration] andDelegate:self];
 [PubNub connect];
 [PubNub sendMessage:@{@"array": @[@"of", @"strings"], @"and": @16} 
googleCloudNotification:@{@"data":@{@"summary":@"Someone sent array of strings"}} 
           toChannel:[PNChannel channelWithName:@"iosdev"] storeInHistory:NO];
 @endcode
 
 And handle it with delegates:
 @code
 - (void)pubnubClient:(PubNub *)client willSendMessage:(PNMessage *)message {
 
     // PubNub client is sending message at this moment.
 }
 
 - (void)pubnubClient:(PubNub *)client didFailMessageSend:(PNMessage *)message withError:(PNError *)error {
 
     // PubNub client failed to send message and reason is in 'error'.
 }
 
 - (void)pubnubClient:(PubNub *)client didSendMessage:(PNMessage *)message {
 
     // PubNub client successfully sent message to specified channel.
 }
 @endcode
 
 There is also way to observe message processing from any place in your application using  \b PNObservationCenter:
 @code
 [[PNObservationCenter defaultCenter] addMessageProcessingObserver:self
  withBlock:^(PNMessageState state, id data) {
 
  switch (state) {
      case PNMessageSending:
 
          // PubNub client is sending message at this moment. 'data' stores reference on PNMessage instance which is processing at this moment.
          break;
      case PNMessageSendingError:
 
          // PubNub client failed to send message and reason is in 'data' object.
          break;
      case PNMessageSent:
 
          // PubNub client successfully sent message to specified channel. 'data' stores reference on PNMessage instance which has been sent.
          break;
      }
 }];
 @endcode
 
 @param message
 Object which should be sent to the channel. It can be any object which can be serialized into JSON: \c NSString, \c NSNumber, \c NSArray,
 \c NSDictionary.

 @param gcmPayload
 Valid GCM payload dictionary which should be delivered using cloud service to all subscribers. You can append some more data except message which should be shown to the user.
 
 @param channel
 \b PNChannel instance into which message should be sent.
 
 @param shouldStoreInHistory
 \c YES in case if message should be stored on \b PubNub service side and become available with History API.
 
 @return \b PNMessage instance if message payload is correct or \c nil if not.
 */
+ (PNMessage *)sendMessage:(id)message googleCloudNotification:(NSDictionary *)gcmPayload toChannel:(PNChannel *)channel
            storeInHistory:(BOOL)shouldStoreInHistory;

/**
 Send \c message to the \c channel. All messages placed into queue and will be sent in the same order as they were scheduled.
 
 @code
 @endcode
 This method extends \a +sendMessage:googleCloudNotification:toChannel:storeInHistory: and allow to specify message sending processing block.
 
 @code
 @endcode
 \b Example:
 
 @code
 [PubNub setConfiguration:[PNConfiguration defaultConfiguration] andDelegate:self];
 [PubNub connect];
 [PubNub sendMessage:@{@"array": @[@"of", @"strings"], @"and": @16} 
googleCloudNotification:@{@"data":@{@"summary":@"Someone sent array of strings"}} 
           toChannel:[PNChannel channelWithName:@"iosdev"] storeInHistory:NO
 withCompletionBlock:^(PNMessageState state, id data) {
 
  switch (state) {
      case PNMessageSending:
 
          // PubNub client is sending message at this moment. 'data' stores reference on PNMessage instance which is processing at this moment.
          break;
      case PNMessageSendingError:
 
          // PubNub client failed to send message and reason is in 'data' object.
          break;
      case PNMessageSent:
 
          // PubNub client successfully sent message to specified channel. 'data' stores reference on PNMessage instance which has been sent.
          break;
      }
 }];
 @endcode
 
 And handle it with delegates:
 @code
 - (void)pubnubClient:(PubNub *)client willSendMessage:(PNMessage *)message {
 
     // PubNub client is sending message at this moment.
 }
 
 - (void)pubnubClient:(PubNub *)client didFailMessageSend:(PNMessage *)message withError:(PNError *)error {
 
     // PubNub client failed to send message and reason is in 'error'.
 }
 
 - (void)pubnubClient:(PubNub *)client didSendMessage:(PNMessage *)message {
 
     // PubNub client successfully sent message to specified channel.
 }
 @endcode
 
 There is also way to observe message processing from any place in your application using  \b PNObservationCenter:
 @code
 [[PNObservationCenter defaultCenter] addMessageProcessingObserver:self
  withBlock:^(PNMessageState state, id data) {
 
  switch (state) {
      case PNMessageSending:
 
          // PubNub client is sending message at this moment. 'data' stores reference on PNMessage instance which is processing at this moment.
          break;
      case PNMessageSendingError:
 
          // PubNub client failed to send message and reason is in 'data' object.
          break;
      case PNMessageSent:
 
          // PubNub client successfully sent message to specified channel. 'data' stores reference on PNMessage instance which has been sent.
          break;
      }
 }];
 @endcode
 
 @param message
 Object which should be sent to the channel. It can be any object which can be serialized into JSON: \c NSString, \c NSNumber, \c NSArray,
 \c NSDictionary.

 @param gcmPayload
 Valid GCM payload dictionary which should be delivered using cloud service to all subscribers. You can append some more data except message which should be shown to the user.
 
 @param channel
 \b PNChannel instance into which message should be sent.
 
 @param shouldStoreInHistory
 \c YES in case if message should be stored on \b PubNub service side and become available with History API.
 
 @param success
 The block which will be called by \b PubNub client any time when message processing state will be changed. The block takes two arguments:
 \c state - one of \b PNMessageState enumerator fields which tell at which stage message at this moment; \c data - depending on whether message is sending/sent or in state
 of message sending failure it can be one of: \b PNMessage or \b PNError instance.
 
 @return \b PNMessage instance if message payload is correct or \c nil if not.
 */
+ (PNMessage *)sendMessage:(id)message googleCloudNotification:(NSDictionary *)gcmPayload toChannel:(PNChannel *)channel
            storeInHistory:(BOOL)shouldStoreInHistory withCompletionBlock:(PNClientMessageProcessingBlock)success;

/**
 Send \c message to the \c channel. All messages placed into queue and will be sent in the same order as they were scheduled.
 
 @code
 @endcode
 This method extends \a +sendMessage:toChannel: and allow to specify separate payload which will be sent along with message using APNS and GCM.
 
 @code
 @endcode
 \b Example:
 
 @code
 [PubNub setConfiguration:[PNConfiguration defaultConfiguration] andDelegate:self];
 [PubNub connect];
 [PubNub sendMessage:@{@"array": @[@"of", @"strings"], @"and": @16} 
 applePushNotification:@{@"aps":@{@"alert":@"Someone sent array of strings"}} 
googleCloudNotification:@{@"data":@{@"summary":@"Someone sent array of strings"}}
           toChannel:[PNChannel channelWithName:@"iosdev"]];
 @endcode
 
 And handle it with delegates:
 @code
 - (void)pubnubClient:(PubNub *)client willSendMessage:(PNMessage *)message {
 
     // PubNub client is sending message at this moment.
 }
 
 - (void)pubnubClient:(PubNub *)client didFailMessageSend:(PNMessage *)message withError:(PNError *)error {
 
     // PubNub client failed to send message and reason is in 'error'.
 }
 
 - (void)pubnubClient:(PubNub *)client didSendMessage:(PNMessage *)message {
 
     // PubNub client successfully sent message to specified channel.
 }
 @endcode
 
 There is also way to observe message processing from any place in your application using  \b PNObservationCenter:
 @code
 [[PNObservationCenter defaultCenter] addMessageProcessingObserver:self
  withBlock:^(PNMessageState state, id data) {
 
  switch (state) {
      case PNMessageSending:
 
          // PubNub client is sending message at this moment. 'data' stores reference on PNMessage instance which is processing at this moment.
          break;
      case PNMessageSendingError:
 
          // PubNub client failed to send message and reason is in 'data' object.
          break;
      case PNMessageSent:
 
          // PubNub client successfully sent message to specified channel. 'data' stores reference on PNMessage instance which has been sent.
          break;
      }
 }];
 @endcode
 
 @param message
 Object which should be sent to the channel. It can be any object which can be serialized into JSON: \c NSString, \c NSNumber, \c NSArray,
 \c NSDictionary.

 @param apnsPayload
 Valid APNS payload dictionary which should be delivered using push service to all subscribers. You can append some more data except message which should be shown to the user.

 @param gcmPayload
 Valid GCM payload dictionary which should be delivered using cloud service to all subscribers. You can append some more data except message which should be shown to the user.

 @param channel
 \b PNChannel instance to which message should be sent.
 
 @return \b PNMessage instance if message payload is correct or \c nil if not.
 */
+ (PNMessage *)sendMessage:(id)message applePushNotification:(NSDictionary *)apnsPayload googleCloudNotification:(NSDictionary *)gcmPayload
                 toChannel:(PNChannel *)channel;

/**
 Send \c message to the \c channel. All messages placed into queue and will be sent in the same order as they were scheduled.
 
 @code
 @endcode
 This method extends \a +sendMessage:applePushNotification:googleCloudNotification:toChannel: and allow to specify message sending processing block.
 
 @code
 @endcode
 \b Example:
 
 @code
 [PubNub setConfiguration:[PNConfiguration defaultConfiguration] andDelegate:self];
 [PubNub connect];
 [PubNub sendMessage:@{@"array": @[@"of", @"strings"], @"and": @16} 
 applePushNotification:@{@"aps":@{@"alert":@"Someone sent array of strings"}} 
 googleCloudNotification:@{@"data":@{@"summary":@"Someone sent array of strings"}}
           toChannel:[PNChannel channelWithName:@"iosdev"]
 withCompletionBlock:^(PNMessageState state, id data) {
 
  switch (state) {
      case PNMessageSending:
 
          // PubNub client is sending message at this moment. 'data' stores reference on PNMessage instance which is processing at this moment.
          break;
      case PNMessageSendingError:
 
          // PubNub client failed to send message and reason is in 'data' object.
          break;
      case PNMessageSent:
 
          // PubNub client successfully sent message to specified channel. 'data' stores reference on PNMessage instance which has been sent.
          break;
      }
 }];
 @endcode
 
 And handle it with delegates:
 @code
 - (void)pubnubClient:(PubNub *)client willSendMessage:(PNMessage *)message {
 
     // PubNub client is sending message at this moment.
 }
 
 - (void)pubnubClient:(PubNub *)client didFailMessageSend:(PNMessage *)message withError:(PNError *)error {
 
     // PubNub client failed to send message and reason is in 'error'.
 }
 
 - (void)pubnubClient:(PubNub *)client didSendMessage:(PNMessage *)message {
 
     // PubNub client successfully sent message to specified channel.
 }
 @endcode
 
 There is also way to observe message processing from any place in your application using  \b PNObservationCenter:
 @code
 [[PNObservationCenter defaultCenter] addMessageProcessingObserver:self
  withBlock:^(PNMessageState state, id data) {
 
  switch (state) {
      case PNMessageSending:
 
          // PubNub client is sending message at this moment. 'data' stores reference on PNMessage instance which is processing at this moment.
          break;
      case PNMessageSendingError:
 
          // PubNub client failed to send message and reason is in 'data' object.
          break;
      case PNMessageSent:
 
          // PubNub client successfully sent message to specified channel. 'data' stores reference on PNMessage instance which has been sent.
          break;
      }
 }];
 @endcode
 
 @param message
 Object which should be sent to the channel. It can be any object which can be serialized into JSON: \c NSString, \c NSNumber, \c NSArray,
 \c NSDictionary.

 @param apnsPayload
 Valid APNS payload dictionary which should be delivered using push service to all subscribers. You can append some more data except message which should be shown to the user.

 @param gcmPayload
 Valid GCM payload dictionary which should be delivered using cloud service to all subscribers. You can append some more data except message which should be shown to the user.

 @param channel
 \b PNChannel instance to which message should be sent.

 @param success
 The block which will be called by \b PubNub client any time when message processing state will be changed. The block takes two arguments:
 \c state - one of \b PNMessageState enumerator fields which tell at which stage message at this moment; \c data - depending on whether message is sending/sent or in state
 of message sending failure it can be one of: \b PNMessage or \b PNError instance.
 
 @return \b PNMessage instance if message payload is correct or \c nil if not.
 */
+ (PNMessage *)sendMessage:(id)message applePushNotification:(NSDictionary *)apnsPayload googleCloudNotification:(NSDictionary *)gcmPayload
                 toChannel:(PNChannel *)channel withCompletionBlock:(PNClientMessageProcessingBlock)success;

/**
 Send \c message to the \c channel. All messages placed into queue and will be sent in the same order as they were scheduled.
 
 @code
 @endcode
 This method extends \a +sendMessage:applePushNotification:googleCloudNotification:toChannel: and allow to specify whether message should be stored in history or not.
 
 @code
 @endcode
 \b Example:
 
 @code
 [PubNub setConfiguration:[PNConfiguration defaultConfiguration] andDelegate:self];
 [PubNub connect];
 [PubNub sendMessage:@{@"array": @[@"of", @"strings"], @"and": @16} 
applePushNotification:@{@"aps":@{@"alert":@"Someone sent array of strings"}} 
googleCloudNotification:@{@"data":@{@"summary":@"Someone sent array of strings"}}
           toChannel:[PNChannel channelWithName:@"iosdev"] storeInHistory:NO];
 @endcode
 
 And handle it with delegates:
 @code
 - (void)pubnubClient:(PubNub *)client willSendMessage:(PNMessage *)message {
 
     // PubNub client is sending message at this moment.
 }
 
 - (void)pubnubClient:(PubNub *)client didFailMessageSend:(PNMessage *)message withError:(PNError *)error {
 
     // PubNub client failed to send message and reason is in 'error'.
 }
 
 - (void)pubnubClient:(PubNub *)client didSendMessage:(PNMessage *)message {
 
     // PubNub client successfully sent message to specified channel.
 }
 @endcode
 
 There is also way to observe message processing from any place in your application using  \b PNObservationCenter:
 @code
 [[PNObservationCenter defaultCenter] addMessageProcessingObserver:self
  withBlock:^(PNMessageState state, id data) {
 
  switch (state) {
      case PNMessageSending:
 
          // PubNub client is sending message at this moment. 'data' stores reference on PNMessage instance which is processing at this moment.
          break;
      case PNMessageSendingError:
 
          // PubNub client failed to send message and reason is in 'data' object.
          break;
      case PNMessageSent:
 
          // PubNub client successfully sent message to specified channel. 'data' stores reference on PNMessage instance which has been sent.
          break;
      }
 }];
 @endcode
 
 @param message
 Object which should be sent to the channel. It can be any object which can be serialized into JSON: \c NSString, \c NSNumber, \c NSArray,
 \c NSDictionary.

 @param apnsPayload
 Valid APNS payload dictionary which should be delivered using push service to all subscribers. You can append some more data except message which should be shown to the user.

 @param gcmPayload
 Valid GCM payload dictionary which should be delivered using cloud service to all subscribers. You can append some more data except message which should be shown to the user.
 
 @param channel
 \b PNChannel instance into which message should be sent.
 
 @param shouldStoreInHistory
 \c YES in case if message should be stored on \b PubNub service side and become available with History API.
 
 @return \b PNMessage instance if message payload is correct or \c nil if not.
 */
+ (PNMessage *)sendMessage:(id)message applePushNotification:(NSDictionary *)apnsPayload googleCloudNotification:(NSDictionary *)gcmPayload
                 toChannel:(PNChannel *)channel storeInHistory:(BOOL)shouldStoreInHistory;

/**
 Send \c message to the \c channel. All messages placed into queue and will be sent in the same order as they were scheduled.
 
 @code
 @endcode
 This method extends \a +sendMessage:applePushNotification:googleCloudNotification:toChannel:storeInHistory: and allow to specify message sending processing block.
 
 @code
 @endcode
 \b Example:
 
 @code
 [PubNub setConfiguration:[PNConfiguration defaultConfiguration] andDelegate:self];
 [PubNub connect];
 [PubNub sendMessage:@{@"array": @[@"of", @"strings"], @"and": @16} 
applePushNotification:@{@"aps":@{@"alert":@"Someone sent array of strings"}} 
googleCloudNotification:@{@"data":@{@"summary":@"Someone sent array of strings"}}
           toChannel:[PNChannel channelWithName:@"iosdev"] storeInHistory:NO
 withCompletionBlock:^(PNMessageState state, id data) {
 
  switch (state) {
      case PNMessageSending:
 
          // PubNub client is sending message at this moment. 'data' stores reference on PNMessage instance which is processing at this moment.
          break;
      case PNMessageSendingError:
 
          // PubNub client failed to send message and reason is in 'data' object.
          break;
      case PNMessageSent:
 
          // PubNub client successfully sent message to specified channel. 'data' stores reference on PNMessage instance which has been sent.
          break;
      }
 }];
 @endcode
 
 And handle it with delegates:
 @code
 - (void)pubnubClient:(PubNub *)client willSendMessage:(PNMessage *)message {
 
     // PubNub client is sending message at this moment.
 }
 
 - (void)pubnubClient:(PubNub *)client didFailMessageSend:(PNMessage *)message withError:(PNError *)error {
 
     // PubNub client failed to send message and reason is in 'error'.
 }
 
 - (void)pubnubClient:(PubNub *)client didSendMessage:(PNMessage *)message {
 
     // PubNub client successfully sent message to specified channel.
 }
 @endcode
 
 There is also way to observe message processing from any place in your application using  \b PNObservationCenter:
 @code
 [[PNObservationCenter defaultCenter] addMessageProcessingObserver:self
  withBlock:^(PNMessageState state, id data) {
 
  switch (state) {
      case PNMessageSending:
 
          // PubNub client is sending message at this moment. 'data' stores reference on PNMessage instance which is processing at this moment.
          break;
      case PNMessageSendingError:
 
          // PubNub client failed to send message and reason is in 'data' object.
          break;
      case PNMessageSent:
 
          // PubNub client successfully sent message to specified channel. 'data' stores reference on PNMessage instance which has been sent.
          break;
      }
 }];
 @endcode
 
 @param message
 Object which should be sent to the channel. It can be any object which can be serialized into JSON: \c NSString, \c NSNumber, \c NSArray,
 \c NSDictionary.

 @param apnsPayload
 Valid APNS payload dictionary which should be delivered using push service to all subscribers. You can append some more data except message which should be shown to the user.

 @param gcmPayload
 Valid GCM payload dictionary which should be delivered using cloud service to all subscribers. You can append some more data except message which should be shown to the user.
 
 @param channel
 \b PNChannel instance into which message should be sent.
 
 @param shouldStoreInHistory
 \c YES in case if message should be stored on \b PubNub service side and become available with History API.
 
 @param success
 The block which will be called by \b PubNub client any time when message processing state will be changed. The block takes two arguments:
 \c state - one of \b PNMessageState enumerator fields which tell at which stage message at this moment; \c data - depending on whether message is sending/sent or in state
 of message sending failure it can be one of: \b PNMessage or \b PNError instance.
 
 @return \b PNMessage instance if message payload is correct or \c nil if not.
 */
+ (PNMessage *)sendMessage:(id)message applePushNotification:(NSDictionary *)apnsPayload googleCloudNotification:(NSDictionary *)gcmPayload
                 toChannel:(PNChannel *)channel storeInHistory:(BOOL)shouldStoreInHistory withCompletionBlock:(PNClientMessageProcessingBlock)success;

/**
 Send \c message to the \c channel. All messages placed into queue and will be sent in the same order as they were scheduled.
 
 @code
 @endcode
 This method extendeds \a +sendMessage:toChannel: and allow to specify whether message should be GZIPed before sending to the \b PubNub service or not.
 
 @code
 @endcode
 \b Example:
 
 @code
 [PubNub setConfiguration:[PNConfiguration defaultConfiguration] andDelegate:self];
 [PubNub connect];
 [PubNub sendMessage:@{@"array": @[@"of", @"strings"], @"and": @16} toChannel:[PNChannel channelWithName:@"iosdev"] compressed:YES];
 @endcode
 
 And handle it with delegates:
 @code
 - (void)pubnubClient:(PubNub *)client willSendMessage:(PNMessage *)message {
 
     // PubNub client is sending message at this moment.
 }
 
 - (void)pubnubClient:(PubNub *)client didFailMessageSend:(PNMessage *)message withError:(PNError *)error {
 
     // PubNub client failed to send message and reason is in 'error'.
 }
 
 - (void)pubnubClient:(PubNub *)client didSendMessage:(PNMessage *)message {
 
     // PubNub client successfully sent message to specified channel.
 }
 @endcode
 
 There is also way to observe message processing from any place in your application using  \b PNObservationCenter:
 @code
 [[PNObservationCenter defaultCenter] addMessageProcessingObserver:self
  withBlock:^(PNMessageState state, id data) {
 
  switch (state) {
      case PNMessageSending:
 
          // PubNub client is sending message at this moment. 'data' stores reference on PNMessage instance which is processing at this moment.
          break;
      case PNMessageSendingError:
 
          // PubNub client failed to send message and reason is in 'data' object.
          break;
      case PNMessageSent:
 
          // PubNub client successfully sent message to specified channel. 'data' stores reference on PNMessage instance which has been sent.
          break;
      }
 }];
 @endcode
 
 @param message
 Object which should be sent to the channel. It can be any object which can be serialized into JSON: \c NSString, \c NSNumber, \c NSArray,
 \c NSDictionary.
 
 @param channel
 \b PNChannel instance into which message should be sent.
 
 @param shouldCompressMessage
 \c YES will instruct \b PubNub client to compress message before sending it to the target \c channel.
 
 @return \b PNMessage instance if message payload is correct or \c nil if not.
 */
+ (PNMessage *)sendMessage:(id)message toChannel:(PNChannel *)channel compressed:(BOOL)shouldCompressMessage;

/**
 Send \c message to the \c channel. All messages placed into queue and will be sent in the same order as they were scheduled.
 
 @code
 @endcode
 This method extendeds \a +sendMessage:toChannel:withCompletionBlock: and allow to specify whether message should be GZIPed before sending to the 
 \b PubNub service or not.
 
 @code
 @endcode
 \b Example:
 
 @code
 [PubNub setConfiguration:[PNConfiguration defaultConfiguration] andDelegate:self];
 [PubNub connect];
 [PubNub sendMessage:@{@"array": @[@"of", @"strings"], @"and": @16} toChannel:[PNChannel channelWithName:@"iosdev"] compressed:YES 
 withCompletionBlock:^(PNMessageState state, id data) {
 
  switch (state) {
      case PNMessageSending:
 
          // PubNub client is sending message at this moment. 'data' stores reference on PNMessage instance which is processing at this moment.
          break;
      case PNMessageSendingError:
 
          // PubNub client failed to send message and reason is in 'data' object.
          break;
      case PNMessageSent:
 
          // PubNub client successfully sent message to specified channel. 'data' stores reference on PNMessage instance which has been sent.
          break;
      }
 }];
 @endcode
 
 And handle it with delegates:
 @code
 - (void)pubnubClient:(PubNub *)client willSendMessage:(PNMessage *)message {
 
    // PubNub client is sending message at this moment.
 }
 
 - (void)pubnubClient:(PubNub *)client didFailMessageSend:(PNMessage *)message withError:(PNError *)error {
 
    // PubNub client failed to send message and reason is in 'error'.
 }
 
 - (void)pubnubClient:(PubNub *)client didSendMessage:(PNMessage *)message {
 
    // PubNub client successfully sent message to specified channel.
 }
 @endcode
 
 There is also way to observe message processing from any place in your application using  \b PNObservationCenter:
 @code
 [[PNObservationCenter defaultCenter] addMessageProcessingObserver:self
                                                         withBlock:^(PNMessageState state, id data) {
 
    switch (state) {
        case PNMessageSending:
 
            // PubNub client is sending message at this moment. 'data' stores reference on PNMessage instance which is processing at this moment.
            break;
    case PNMessageSendingError:
 
            // PubNub client failed to send message and reason is in 'data' object.
            break;
    case PNMessageSent:
 
            // PubNub client successfully sent message to specified channel. 'data' stores reference on PNMessage instance which has been sent.
            break;
    }
 }];
 @endcode
 
 @param message
 Object which should be sent to the channel. It can be any object which can be serialized into JSON: \c NSString, \c NSNumber, \c NSArray,
 \c NSDictionary.
 
 @param channel
 \b PNChannel instance into which message should be sent.
 
 @param shouldCompressMessage
 \c YES will instruct \b PubNub client to compress message before sending it to the target \c channel.
 
 @param success
 The block which will be called by \b PubNub client any time when message processing state will be changed. The block takes two arguments:
 \c state - one of \b PNMessageState enumerator fields which tell at which stage message at this moment; \c data - depending on whether message is sending/sent or in state
 of message sending failure it can be one of: \b PNMessage or \b PNError instance.
 
 @return \b PNMessage instance if message payload is correct or \c nil if not.
 */
+ (PNMessage *)sendMessage:(id)message toChannel:(PNChannel *)channel compressed:(BOOL)shouldCompressMessage
       withCompletionBlock:(PNClientMessageProcessingBlock)success;

/**
 Send \c message to the \c channel. All messages placed into queue and will be sent in the same order as they were scheduled.
 @code
 @endcode
 This method extendeds \a +sendMessage:toChannel:compressed: and allow to specify whether message should be stored in history or not.
 
 @code
 @endcode
 \b Example:
 
 @code
 [PubNub setConfiguration:[PNConfiguration defaultConfiguration] andDelegate:self];
 [PubNub connect];
 [PubNub sendMessage:@{@"array": @[@"of", @"strings"], @"and": @16} toChannel:[PNChannel channelWithName:@"iosdev"] 
          compressed:YES storeInHistory:NO];
 @endcode
 
 And handle it with delegates:
 @code
 - (void)pubnubClient:(PubNub *)client willSendMessage:(PNMessage *)message {
 
     // PubNub client is sending message at this moment.
 }
 
 - (void)pubnubClient:(PubNub *)client didFailMessageSend:(PNMessage *)message withError:(PNError *)error {
 
     // PubNub client failed to send message and reason is in 'error'.
 }
 
 - (void)pubnubClient:(PubNub *)client didSendMessage:(PNMessage *)message {
 
     // PubNub client successfully sent message to specified channel.
 }
 @endcode
 
 There is also way to observe message processing from any place in your application using  \b PNObservationCenter:
 @code
 [[PNObservationCenter defaultCenter] addMessageProcessingObserver:self
  withBlock:^(PNMessageState state, id data) {
 
  switch (state) {
      case PNMessageSending:
 
          // PubNub client is sending message at this moment. 'data' stores reference on PNMessage instance which is processing at this moment.
          break;
      case PNMessageSendingError:
 
          // PubNub client failed to send message and reason is in 'data' object.
          break;
      case PNMessageSent:
 
          // PubNub client successfully sent message to specified channel. 'data' stores reference on PNMessage instance which has been sent.
          break;
      }
 }];
 @endcode
 
 @param message
 Object which should be sent to the channel. It can be any object which can be serialized into JSON: \c NSString, \c NSNumber, \c NSArray,
 \c NSDictionary.
 
 @param channel
 \b PNChannel instance into which message should be sent.
 
 @param shouldCompressMessage
 \c YES in case if message should be compressed before sending to the PubNub service.
 
 @param shouldStoreInHistory
 \c YES in case if message should be stored on \b PubNub service side and become available with History API.
 
 @return \b PNMessage instance if message payload is correct or \c nil if not.
 */
+ (PNMessage *)sendMessage:(id)message toChannel:(PNChannel *)channel compressed:(BOOL)shouldCompressMessage storeInHistory:(BOOL)shouldStoreInHistory;

/**
 Send \c message to the \c channel. All messages placed into queue and will be sent in the same order as they were scheduled.
 
 @code
 @endcode
 This method extendeds \a +sendMessage:toChannel:compressed:withCompletionBlock: and allow to specify whether message should be stored in history or not.
 
 @code
 @endcode
 \b Example:
 
 @code
 [PubNub setConfiguration:[PNConfiguration defaultConfiguration] andDelegate:self];
 [PubNub connect];
 [PubNub sendMessage:@{@"array": @[@"of", @"strings"], @"and": @16} toChannel:[PNChannel channelWithName:@"iosdev"] compressed:YES 
      storeInHistory:NO withCompletionBlock:^(PNMessageState state, id data) {
 
  switch (state) {
      case PNMessageSending:
 
          // PubNub client is sending message at this moment. 'data' stores reference on PNMessage instance which is processing at this moment.
          break;
      case PNMessageSendingError:
 
          // PubNub client failed to send message and reason is in 'data' object.
          break;
      case PNMessageSent:
 
          // PubNub client successfully sent message to specified channel. 'data' stores reference on PNMessage instance which has been sent.
          break;
      }
 }];
 @endcode
 
 And handle it with delegates:
 @code
 - (void)pubnubClient:(PubNub *)client willSendMessage:(PNMessage *)message {
 
    // PubNub client is sending message at this moment.
 }
 
 - (void)pubnubClient:(PubNub *)client didFailMessageSend:(PNMessage *)message withError:(PNError *)error {
 
    // PubNub client failed to send message and reason is in 'error'.
 }
 
 - (void)pubnubClient:(PubNub *)client didSendMessage:(PNMessage *)message {
 
    // PubNub client successfully sent message to specified channel.
 }
 @endcode
 
 There is also way to observe message processing from any place in your application using  \b PNObservationCenter:
 @code
 [[PNObservationCenter defaultCenter] addMessageProcessingObserver:self
                                                         withBlock:^(PNMessageState state, id data) {
 
    switch (state) {
        case PNMessageSending:
 
            // PubNub client is sending message at this moment. 'data' stores reference on PNMessage instance which is processing at this moment.
            break;
    case PNMessageSendingError:
 
            // PubNub client failed to send message and reason is in 'data' object.
            break;
    case PNMessageSent:
 
            // PubNub client successfully sent message to specified channel. 'data' stores reference on PNMessage instance which has been sent.
            break;
    }
 }];
 @endcode
 
 @param message
 Object which should be sent to the channel. It can be any object which can be serialized into JSON: \c NSString, \c NSNumber, \c NSArray,
 \c NSDictionary.
 
 @param channel
 \b PNChannel instance into which message should be sent.
 
 @param shouldCompressMessage
 \c YES in case if message should be compressed before sending to the PubNub service.
 
 @param shouldStoreInHistory
 \c YES in case if message should be stored on \b PubNub service side and become available with History API.
 
 @return \b PNMessage instance if message payload is correct or \c nil if not.
 */
+ (PNMessage *)sendMessage:(id)message toChannel:(PNChannel *)channel compressed:(BOOL)shouldCompressMessage storeInHistory:(BOOL)shouldStoreInHistory
       withCompletionBlock:(PNClientMessageProcessingBlock)success;

/**
 Send \c message to the \c channel. All messages placed into queue and will be sent in the same order as they were scheduled.
 
 @code
 @endcode
 This method extends \a +sendMessage:applePushNotification:toChannel: and allow to specify whether message should be GZIPed before sending to the \b PubNub service or not.
 
 @code
 @endcode
 \b Example:
 
 @code
 [PubNub setConfiguration:[PNConfiguration defaultConfiguration] andDelegate:self];
 [PubNub connect];
 [PubNub sendMessage:@{@"array": @[@"of", @"strings"], @"and": @16} 
 applePushNotification:@{@"aps":@{@"alert":@"Someone sent array of strings"}} 
           toChannel:[PNChannel channelWithName:@"iosdev"] compressed:NO];
 @endcode
 
 And handle it with delegates:
 @code
 - (void)pubnubClient:(PubNub *)client willSendMessage:(PNMessage *)message {
 
     // PubNub client is sending message at this moment.
 }
 
 - (void)pubnubClient:(PubNub *)client didFailMessageSend:(PNMessage *)message withError:(PNError *)error {
 
     // PubNub client failed to send message and reason is in 'error'.
 }
 
 - (void)pubnubClient:(PubNub *)client didSendMessage:(PNMessage *)message {
 
     // PubNub client successfully sent message to specified channel.
 }
 @endcode
 
 There is also way to observe message processing from any place in your application using  \b PNObservationCenter:
 @code
 [[PNObservationCenter defaultCenter] addMessageProcessingObserver:self
  withBlock:^(PNMessageState state, id data) {
 
  switch (state) {
      case PNMessageSending:
 
          // PubNub client is sending message at this moment. 'data' stores reference on PNMessage instance which is processing at this moment.
          break;
      case PNMessageSendingError:
 
          // PubNub client failed to send message and reason is in 'data' object.
          break;
      case PNMessageSent:
 
          // PubNub client successfully sent message to specified channel. 'data' stores reference on PNMessage instance which has been sent.
          break;
      }
 }];
 @endcode
 
 @param message
 Object which should be sent to the channel. It can be any object which can be serialized into JSON: \c NSString, \c NSNumber, \c NSArray,
 \c NSDictionary.

 @param apnsPayload
 Valid APNS payload dictionary which should be delivered using push service to all subscribers. You can append some more data except message which should be shown to the user.

 @param channel
 \b PNChannel instance to which message should be sent.
 
 @param shouldCompressMessage
 \c YES will instruct \b PubNub client to compress message before sending it to the target \c channel.
 
 @return \b PNMessage instance if message payload is correct or \c nil if not.
 */
+ (PNMessage *)sendMessage:(id)message applePushNotification:(NSDictionary *)apnsPayload toChannel:(PNChannel *)channel
                compressed:(BOOL)shouldCompressMessage;

/**
 Send \c message to the \c channel. All messages placed into queue and will be sent in the same order as they were scheduled.
 
 @code
 @endcode
 This method extends \a +sendMessage:applePushNotification:toChannel:compressed: and allow to specify message sending processing block.
 
 @code
 @endcode
 \b Example:
 
 @code
 [PubNub setConfiguration:[PNConfiguration defaultConfiguration] andDelegate:self];
 [PubNub connect];
 [PubNub sendMessage:@{@"array": @[@"of", @"strings"], @"and": @16} 
 applePushNotification:@{@"aps":@{@"alert":@"Someone sent array of strings"}} 
           toChannel:[PNChannel channelWithName:@"iosdev"] compressed:NO];
 @endcode
 
 And handle it with delegates:
 @code
 - (void)pubnubClient:(PubNub *)client willSendMessage:(PNMessage *)message {
 
     // PubNub client is sending message at this moment.
 }
 
 - (void)pubnubClient:(PubNub *)client didFailMessageSend:(PNMessage *)message withError:(PNError *)error {
 
     // PubNub client failed to send message and reason is in 'error'.
 }
 
 - (void)pubnubClient:(PubNub *)client didSendMessage:(PNMessage *)message {
 
     // PubNub client successfully sent message to specified channel.
 }
 @endcode
 
 There is also way to observe message processing from any place in your application using  \b PNObservationCenter:
 @code
 [[PNObservationCenter defaultCenter] addMessageProcessingObserver:self
  withBlock:^(PNMessageState state, id data) {
 
  switch (state) {
      case PNMessageSending:
 
          // PubNub client is sending message at this moment. 'data' stores reference on PNMessage instance which is processing at this moment.
          break;
      case PNMessageSendingError:
 
          // PubNub client failed to send message and reason is in 'data' object.
          break;
      case PNMessageSent:
 
          // PubNub client successfully sent message to specified channel. 'data' stores reference on PNMessage instance which has been sent.
          break;
      }
 }];
 @endcode
 
 @param message
 Object which should be sent to the channel. It can be any object which can be serialized into JSON: \c NSString, \c NSNumber, \c NSArray,
 \c NSDictionary.

 @param apnsPayload
 Valid APNS payload dictionary which should be delivered using push service to all subscribers. You can append some more data except message which should be shown to the user.

 @param channel
 \b PNChannel instance to which message should be sent.
 
 @param shouldCompressMessage
 \c YES will instruct \b PubNub client to compress message before sending it to the target \c channel.

 @param success
 The block which will be called by \b PubNub client any time when message processing state will be changed. The block takes two arguments:
 \c state - one of \b PNMessageState enumerator fields which tell at which stage message at this moment; \c data - depending on whether message is sending/sent or in state
 of message sending failure it can be one of: \b PNMessage or \b PNError instance.
 
 @return \b PNMessage instance if message payload is correct or \c nil if not.
 */
+ (PNMessage *)sendMessage:(id)message applePushNotification:(NSDictionary *)apnsPayload toChannel:(PNChannel *)channel
                compressed:(BOOL)shouldCompressMessage withCompletionBlock:(PNClientMessageProcessingBlock)success;

/**
 Send \c message to the \c channel. All messages placed into queue and will be sent in the same order as they were scheduled.
 
 @code
 @endcode
 This method extends \a +sendMessage:applePushNotification:toChannel:compressed: and allow to specify whether message should be stored in history or not.
 
 @code
 @endcode
 \b Example:
 
 @code
 [PubNub setConfiguration:[PNConfiguration defaultConfiguration] andDelegate:self];
 [PubNub connect];
 [PubNub sendMessage:@{@"array": @[@"of", @"strings"], @"and": @16} 
applePushNotification:@{@"aps":@{@"alert":@"Someone sent array of strings"}} 
           toChannel:[PNChannel channelWithName:@"iosdev"] compressed:NO storeInHistory:YES];
 @endcode
 
 And handle it with delegates:
 @code
 - (void)pubnubClient:(PubNub *)client willSendMessage:(PNMessage *)message {
 
     // PubNub client is sending message at this moment.
 }
 
 - (void)pubnubClient:(PubNub *)client didFailMessageSend:(PNMessage *)message withError:(PNError *)error {
 
     // PubNub client failed to send message and reason is in 'error'.
 }
 
 - (void)pubnubClient:(PubNub *)client didSendMessage:(PNMessage *)message {
 
     // PubNub client successfully sent message to specified channel.
 }
 @endcode
 
 There is also way to observe message processing from any place in your application using  \b PNObservationCenter:
 @code
 [[PNObservationCenter defaultCenter] addMessageProcessingObserver:self
  withBlock:^(PNMessageState state, id data) {
 
  switch (state) {
      case PNMessageSending:
 
          // PubNub client is sending message at this moment. 'data' stores reference on PNMessage instance which is processing at this moment.
          break;
      case PNMessageSendingError:
 
          // PubNub client failed to send message and reason is in 'data' object.
          break;
      case PNMessageSent:
 
          // PubNub client successfully sent message to specified channel. 'data' stores reference on PNMessage instance which has been sent.
          break;
      }
 }];
 @endcode
 
 @param message
 Object which should be sent to the channel. It can be any object which can be serialized into JSON: \c NSString, \c NSNumber, \c NSArray,
 \c NSDictionary.

 @param apnsPayload
 Valid APNS payload dictionary which should be delivered using push service to all subscribers. You can append some more data except message which should be shown to the user.
 
 @param channel
 \b PNChannel instance into which message should be sent.
 
 @param shouldCompressMessage
 \c YES will instruct \b PubNub client to compress message before sending it to the target \c channel.
 
 @param shouldStoreInHistory
 \c YES in case if message should be stored on \b PubNub service side and become available with History API.
 
 @return \b PNMessage instance if message payload is correct or \c nil if not.
 */
+ (PNMessage *)sendMessage:(id)message applePushNotification:(NSDictionary *)apnsPayload toChannel:(PNChannel *)channel
                compressed:(BOOL)shouldCompressMessage storeInHistory:(BOOL)shouldStoreInHistory;

/**
 Send \c message to the \c channel. All messages placed into queue and will be sent in the same order as they were scheduled.
 
 @code
 @endcode
 This method extends \a +sendMessage:applePushNotification:toChannel:compressed:storeInHistory: and allow to specify message sending processing block.
 
 @code
 @endcode
 \b Example:
 
 @code
 [PubNub setConfiguration:[PNConfiguration defaultConfiguration] andDelegate:self];
 [PubNub connect];
 [PubNub sendMessage:@{@"array": @[@"of", @"strings"], @"and": @16} 
applePushNotification:@{@"aps":@{@"alert":@"Someone sent array of strings"}} 
           toChannel:[PNChannel channelWithName:@"iosdev"] compressed:NO storeInHistory:NO
 withCompletionBlock:^(PNMessageState state, id data) {
 
  switch (state) {
      case PNMessageSending:
 
          // PubNub client is sending message at this moment. 'data' stores reference on PNMessage instance which is processing at this moment.
          break;
      case PNMessageSendingError:
 
          // PubNub client failed to send message and reason is in 'data' object.
          break;
      case PNMessageSent:
 
          // PubNub client successfully sent message to specified channel. 'data' stores reference on PNMessage instance which has been sent.
          break;
      }
 }];
 @endcode
 
 And handle it with delegates:
 @code
 - (void)pubnubClient:(PubNub *)client willSendMessage:(PNMessage *)message {
 
     // PubNub client is sending message at this moment.
 }
 
 - (void)pubnubClient:(PubNub *)client didFailMessageSend:(PNMessage *)message withError:(PNError *)error {
 
     // PubNub client failed to send message and reason is in 'error'.
 }
 
 - (void)pubnubClient:(PubNub *)client didSendMessage:(PNMessage *)message {
 
     // PubNub client successfully sent message to specified channel.
 }
 @endcode
 
 There is also way to observe message processing from any place in your application using  \b PNObservationCenter:
 @code
 [[PNObservationCenter defaultCenter] addMessageProcessingObserver:self
  withBlock:^(PNMessageState state, id data) {
 
  switch (state) {
      case PNMessageSending:
 
          // PubNub client is sending message at this moment. 'data' stores reference on PNMessage instance which is processing at this moment.
          break;
      case PNMessageSendingError:
 
          // PubNub client failed to send message and reason is in 'data' object.
          break;
      case PNMessageSent:
 
          // PubNub client successfully sent message to specified channel. 'data' stores reference on PNMessage instance which has been sent.
          break;
      }
 }];
 @endcode
 
 @param message
 Object which should be sent to the channel. It can be any object which can be serialized into JSON: \c NSString, \c NSNumber, \c NSArray,
 \c NSDictionary.

 @param apnsPayload
 Valid APNS payload dictionary which should be delivered using push service to all subscribers. You can append some more data except message which should be shown to the user.
 
 @param channel
 \b PNChannel instance into which message should be sent.
 
 @param shouldCompressMessage
 \c YES will instruct \b PubNub client to compress message before sending it to the target \c channel.
 
 @param shouldStoreInHistory
 \c YES in case if message should be stored on \b PubNub service side and become available with History API.
 
 @param success
 The block which will be called by \b PubNub client any time when message processing state will be changed. The block takes two arguments:
 \c state - one of \b PNMessageState enumerator fields which tell at which stage message at this moment; \c data - depending on whether message is sending/sent or in state
 of message sending failure it can be one of: \b PNMessage or \b PNError instance.
 
 @return \b PNMessage instance if message payload is correct or \c nil if not.
 */
+ (PNMessage *)sendMessage:(id)message applePushNotification:(NSDictionary *)apnsPayload toChannel:(PNChannel *)channel
                compressed:(BOOL)shouldCompressMessage storeInHistory:(BOOL)shouldStoreInHistory 
       withCompletionBlock:(PNClientMessageProcessingBlock)success;

/**
 Send \c message to the \c channel. All messages placed into queue and will be sent in the same order as they were scheduled.
 
 @code
 @endcode
 This method extends \a +sendMessage:googleCloudNotification:toChannel: and allow to specify whether message should be GZIPed before sending to the \b PubNub service or not.
 
 @code
 @endcode
 \b Example:
 
 @code
 [PubNub setConfiguration:[PNConfiguration defaultConfiguration] andDelegate:self];
 [PubNub connect];
 [PubNub sendMessage:@{@"array": @[@"of", @"strings"], @"and": @16} 
 googleCloudNotification:@{@"data":@{@"summary":@"Someone sent array of strings"}}
           toChannel:[PNChannel channelWithName:@"iosdev"] compressed:NO];
 @endcode
 
 And handle it with delegates:
 @code
 - (void)pubnubClient:(PubNub *)client willSendMessage:(PNMessage *)message {
 
     // PubNub client is sending message at this moment.
 }
 
 - (void)pubnubClient:(PubNub *)client didFailMessageSend:(PNMessage *)message withError:(PNError *)error {
 
     // PubNub client failed to send message and reason is in 'error'.
 }
 
 - (void)pubnubClient:(PubNub *)client didSendMessage:(PNMessage *)message {
 
     // PubNub client successfully sent message to specified channel.
 }
 @endcode
 
 There is also way to observe message processing from any place in your application using  \b PNObservationCenter:
 @code
 [[PNObservationCenter defaultCenter] addMessageProcessingObserver:self
  withBlock:^(PNMessageState state, id data) {
 
  switch (state) {
      case PNMessageSending:
 
          // PubNub client is sending message at this moment. 'data' stores reference on PNMessage instance which is processing at this moment.
          break;
      case PNMessageSendingError:
 
          // PubNub client failed to send message and reason is in 'data' object.
          break;
      case PNMessageSent:
 
          // PubNub client successfully sent message to specified channel. 'data' stores reference on PNMessage instance which has been sent.
          break;
      }
 }];
 @endcode
 
 @param message
 Object which should be sent to the channel. It can be any object which can be serialized into JSON: \c NSString, \c NSNumber, \c NSArray,
 \c NSDictionary.

 @param gcmPayload
 Valid GCM payload dictionary which should be delivered using cloud service to all subscribers. You can append some more data except message which should be shown to the user.

 @param channel
 \b PNChannel instance to which message should be sent.

 @param shouldCompressMessage
 If set to \c YES \b PubNub client will sent it in GZIPed form.
 
 @return \b PNMessage instance if message payload is correct or \c nil if not.
 */
+ (PNMessage *)sendMessage:(id)message googleCloudNotification:(NSDictionary *)gcmPayload toChannel:(PNChannel *)channel compressed:(BOOL)shouldCompressMessage;

/**
 Send \c message to the \c channel. All messages placed into queue and will be sent in the same order as they were scheduled.
 
 @code
 @endcode
 This method extends \a +sendMessage:googleCloudNotification:toChannel:compressed: and allow to specify message sending processing block.
 
 @code
 @endcode
 \b Example:
 
 @code
 [PubNub setConfiguration:[PNConfiguration defaultConfiguration] andDelegate:self];
 [PubNub connect];
 [PubNub sendMessage:@{@"array": @[@"of", @"strings"], @"and": @16} 
 googleCloudNotification:@{@"data":@{@"summary":@"Someone sent array of strings"}}
           toChannel:[PNChannel channelWithName:@"iosdev"] compressed:NO];
 @endcode
 
 And handle it with delegates:
 @code
 - (void)pubnubClient:(PubNub *)client willSendMessage:(PNMessage *)message {
 
     // PubNub client is sending message at this moment.
 }
 
 - (void)pubnubClient:(PubNub *)client didFailMessageSend:(PNMessage *)message withError:(PNError *)error {
 
     // PubNub client failed to send message and reason is in 'error'.
 }
 
 - (void)pubnubClient:(PubNub *)client didSendMessage:(PNMessage *)message {
 
     // PubNub client successfully sent message to specified channel.
 }
 @endcode
 
 There is also way to observe message processing from any place in your application using  \b PNObservationCenter:
 @code
 [[PNObservationCenter defaultCenter] addMessageProcessingObserver:self
  withBlock:^(PNMessageState state, id data) {
 
  switch (state) {
      case PNMessageSending:
 
          // PubNub client is sending message at this moment. 'data' stores reference on PNMessage instance which is processing at this moment.
          break;
      case PNMessageSendingError:
 
          // PubNub client failed to send message and reason is in 'data' object.
          break;
      case PNMessageSent:
 
          // PubNub client successfully sent message to specified channel. 'data' stores reference on PNMessage instance which has been sent.
          break;
      }
 }];
 @endcode
 
 @param message
 Object which should be sent to the channel. It can be any object which can be serialized into JSON: \c NSString, \c NSNumber, \c NSArray,
 \c NSDictionary.

 @param gcmPayload
 Valid GCM payload dictionary which should be delivered using cloud service to all subscribers. You can append some more data except message which should be shown to the user.

 @param channel
 \b PNChannel instance to which message should be sent.

 @param shouldCompressMessage
 If set to \c YES \b PubNub client will sent it in GZIPed form.

 @param success
 The block which will be called by \b PubNub client any time when message processing state will be changed. The block takes two arguments:
 \c state - one of \b PNMessageState enumerator fields which tell at which stage message at this moment; \c data - depending on whether message is sending/sent or in state
 of message sending failure it can be one of: \b PNMessage or \b PNError instance.
 
 @return \b PNMessage instance if message payload is correct or \c nil if not.
 */
+ (PNMessage *)sendMessage:(id)message googleCloudNotification:(NSDictionary *)gcmPayload toChannel:(PNChannel *)channel
                compressed:(BOOL)shouldCompressMessage withCompletionBlock:(PNClientMessageProcessingBlock)success;

/**
 Send \c message to the \c channel. All messages placed into queue and will be sent in the same order as they were scheduled.
 
 @code
 @endcode
 This method extends \a +sendMessage:googleCloudNotification:toChannel:compressed: and allow to specify whether message should be stored in history or not.
 
 @code
 @endcode
 \b Example:
 
 @code
 [PubNub setConfiguration:[PNConfiguration defaultConfiguration] andDelegate:self];
 [PubNub connect];
 [PubNub sendMessage:@{@"array": @[@"of", @"strings"], @"and": @16} 
googleCloudNotification:@{@"data":@{@"summary":@"Someone sent array of strings"}}
           toChannel:[PNChannel channelWithName:@"iosdev"] compressed:NO storeInHistory:YES];
 @endcode
 
 And handle it with delegates:
 @code
 - (void)pubnubClient:(PubNub *)client willSendMessage:(PNMessage *)message {
 
     // PubNub client is sending message at this moment.
 }
 
 - (void)pubnubClient:(PubNub *)client didFailMessageSend:(PNMessage *)message withError:(PNError *)error {
 
     // PubNub client failed to send message and reason is in 'error'.
 }
 
 - (void)pubnubClient:(PubNub *)client didSendMessage:(PNMessage *)message {
 
     // PubNub client successfully sent message to specified channel.
 }
 @endcode
 
 There is also way to observe message processing from any place in your application using  \b PNObservationCenter:
 @code
 [[PNObservationCenter defaultCenter] addMessageProcessingObserver:self
  withBlock:^(PNMessageState state, id data) {
 
  switch (state) {
      case PNMessageSending:
 
          // PubNub client is sending message at this moment. 'data' stores reference on PNMessage instance which is processing at this moment.
          break;
      case PNMessageSendingError:
 
          // PubNub client failed to send message and reason is in 'data' object.
          break;
      case PNMessageSent:
 
          // PubNub client successfully sent message to specified channel. 'data' stores reference on PNMessage instance which has been sent.
          break;
      }
 }];
 @endcode
 
 @param message
 Object which should be sent to the channel. It can be any object which can be serialized into JSON: \c NSString, \c NSNumber, \c NSArray,
 \c NSDictionary.

 @param gcmPayload
 Valid GCM payload dictionary which should be delivered using cloud service to all subscribers. You can append some more data except message which should be shown to the user.
 
 @param channel
 \b PNChannel instance into which message should be sent.
 
 @param shouldCompressMessage
 \c YES will instruct \b PubNub client to compress message before sending it to the target \c channel.
 
 @param shouldStoreInHistory
 \c YES in case if message should be stored on \b PubNub service side and become available with History API.
 
 @return \b PNMessage instance if message payload is correct or \c nil if not.
 */
+ (PNMessage *)sendMessage:(id)message googleCloudNotification:(NSDictionary *)gcmPayload toChannel:(PNChannel *)channel
                compressed:(BOOL)shouldCompressMessage storeInHistory:(BOOL)shouldStoreInHistory;

/**
 Send \c message to the \c channel. All messages placed into queue and will be sent in the same order as they were scheduled.
 
 @code
 @endcode
 This method extends \a +sendMessage:googleCloudNotification:toChannel:compressed:storeInHistory: and allow to specify message sending processing block.
 
 @code
 @endcode
 \b Example:
 
 @code
 [PubNub setConfiguration:[PNConfiguration defaultConfiguration] andDelegate:self];
 [PubNub connect];
 [PubNub sendMessage:@{@"array": @[@"of", @"strings"], @"and": @16} 
googleCloudNotification:@{@"data":@{@"summary":@"Someone sent array of strings"}}
           toChannel:[PNChannel channelWithName:@"iosdev"] compressed:NO storeInHistory:NO
 withCompletionBlock:^(PNMessageState state, id data) {
 
  switch (state) {
      case PNMessageSending:
 
          // PubNub client is sending message at this moment. 'data' stores reference on PNMessage instance which is processing at this moment.
          break;
      case PNMessageSendingError:
 
          // PubNub client failed to send message and reason is in 'data' object.
          break;
      case PNMessageSent:
 
          // PubNub client successfully sent message to specified channel. 'data' stores reference on PNMessage instance which has been sent.
          break;
      }
 }];
 @endcode
 
 And handle it with delegates:
 @code
 - (void)pubnubClient:(PubNub *)client willSendMessage:(PNMessage *)message {
 
     // PubNub client is sending message at this moment.
 }
 
 - (void)pubnubClient:(PubNub *)client didFailMessageSend:(PNMessage *)message withError:(PNError *)error {
 
     // PubNub client failed to send message and reason is in 'error'.
 }
 
 - (void)pubnubClient:(PubNub *)client didSendMessage:(PNMessage *)message {
 
     // PubNub client successfully sent message to specified channel.
 }
 @endcode
 
 There is also way to observe message processing from any place in your application using  \b PNObservationCenter:
 @code
 [[PNObservationCenter defaultCenter] addMessageProcessingObserver:self
  withBlock:^(PNMessageState state, id data) {
 
  switch (state) {
      case PNMessageSending:
 
          // PubNub client is sending message at this moment. 'data' stores reference on PNMessage instance which is processing at this moment.
          break;
      case PNMessageSendingError:
 
          // PubNub client failed to send message and reason is in 'data' object.
          break;
      case PNMessageSent:
 
          // PubNub client successfully sent message to specified channel. 'data' stores reference on PNMessage instance which has been sent.
          break;
      }
 }];
 @endcode
 
 @param message
 Object which should be sent to the channel. It can be any object which can be serialized into JSON: \c NSString, \c NSNumber, \c NSArray,
 \c NSDictionary.

 @param gcmPayload
 Valid GCM payload dictionary which should be delivered using cloud service to all subscribers. You can append some more data except message which should be shown to the user.
 
 @param channel
 \b PNChannel instance into which message should be sent.
 
 @param shouldCompressMessage
 \c YES will instruct \b PubNub client to compress message before sending it to the target \c channel.
 
 @param shouldStoreInHistory
 \c YES in case if message should be stored on \b PubNub service side and become available with History API.
 
 @param success
 The block which will be called by \b PubNub client any time when message processing state will be changed. The block takes two arguments:
 \c state - one of \b PNMessageState enumerator fields which tell at which stage message at this moment; \c data - depending on whether message is sending/sent or in state
 of message sending failure it can be one of: \b PNMessage or \b PNError instance.
 
 @return \b PNMessage instance if message payload is correct or \c nil if not.
 */
+ (PNMessage *)sendMessage:(id)message googleCloudNotification:(NSDictionary *)gcmPayload toChannel:(PNChannel *)channel
                compressed:(BOOL)shouldCompressMessage storeInHistory:(BOOL)shouldStoreInHistory 
       withCompletionBlock:(PNClientMessageProcessingBlock)success;

/**
 Send \c message to the \c channel. All messages placed into queue and will be sent in the same order as they were scheduled.
 
 @code
 @endcode
 This method extends \a +sendMessage:applePushNotification:googleCloudNotification:toChannel: and allow to specify whether message should be GZIPed before sending to the \b PubNub service or not.
 
 @code
 @endcode
 \b Example:
 
 @code
 [PubNub setConfiguration:[PNConfiguration defaultConfiguration] andDelegate:self];
 [PubNub connect];
 [PubNub sendMessage:@{@"array": @[@"of", @"strings"], @"and": @16} 
 applePushNotification:@{@"aps":@{@"alert":@"Someone sent array of strings"}} 
 googleCloudNotification:@{@"data":@{@"summary":@"Someone sent array of strings"}}
           toChannel:[PNChannel channelWithName:@"iosdev"] compressed:NO];
 @endcode
 
 And handle it with delegates:
 @code
 - (void)pubnubClient:(PubNub *)client willSendMessage:(PNMessage *)message {
 
     // PubNub client is sending message at this moment.
 }
 
 - (void)pubnubClient:(PubNub *)client didFailMessageSend:(PNMessage *)message withError:(PNError *)error {
 
     // PubNub client failed to send message and reason is in 'error'.
 }
 
 - (void)pubnubClient:(PubNub *)client didSendMessage:(PNMessage *)message {
 
     // PubNub client successfully sent message to specified channel.
 }
 @endcode
 
 There is also way to observe message processing from any place in your application using  \b PNObservationCenter:
 @code
 [[PNObservationCenter defaultCenter] addMessageProcessingObserver:self
  withBlock:^(PNMessageState state, id data) {
 
  switch (state) {
      case PNMessageSending:
 
          // PubNub client is sending message at this moment. 'data' stores reference on PNMessage instance which is processing at this moment.
          break;
      case PNMessageSendingError:
 
          // PubNub client failed to send message and reason is in 'data' object.
          break;
      case PNMessageSent:
 
          // PubNub client successfully sent message to specified channel. 'data' stores reference on PNMessage instance which has been sent.
          break;
      }
 }];
 @endcode
 
 @param message
 Object which should be sent to the channel. It can be any object which can be serialized into JSON: \c NSString, \c NSNumber, \c NSArray,
 \c NSDictionary.

 @param apnsPayload
 Valid APNS payload dictionary which should be delivered using push service to all subscribers. You can append some more data except message which should be shown to the user.

 @param gcmPayload
 Valid GCM payload dictionary which should be delivered using cloud service to all subscribers. You can append some more data except message which should be shown to the user.

 @param channel
 \b PNChannel instance to which message should be sent.

 @param shouldCompressMessage
 If set to \c YES \b PubNub client will sent it in GZIPed form.
 
 @return \b PNMessage instance if message payload is correct or \c nil if not.
 */
+ (PNMessage *)sendMessage:(id)message applePushNotification:(NSDictionary *)apnsPayload googleCloudNotification:(NSDictionary *)gcmPayload
                 toChannel:(PNChannel *)channel compressed:(BOOL)shouldCompressMessage;

/**
 Send \c message to the \c channel. All messages placed into queue and will be sent in the same order as they were scheduled.
 
 @code
 @endcode
 This method extends \a +sendMessage:applePushNotification:googleCloudNotification:toChannel:compressed: and allow to specify message sending processing block.
 
 @code
 @endcode
 \b Example:
 
 @code
 [PubNub setConfiguration:[PNConfiguration defaultConfiguration] andDelegate:self];
 [PubNub connect];
 [PubNub sendMessage:@{@"array": @[@"of", @"strings"], @"and": @16} 
 applePushNotification:@{@"aps":@{@"alert":@"Someone sent array of strings"}} 
 googleCloudNotification:@{@"data":@{@"summary":@"Someone sent array of strings"}}
           toChannel:[PNChannel channelWithName:@"iosdev"] compressed:NO];
 @endcode
 
 And handle it with delegates:
 @code
 - (void)pubnubClient:(PubNub *)client willSendMessage:(PNMessage *)message {
 
     // PubNub client is sending message at this moment.
 }
 
 - (void)pubnubClient:(PubNub *)client didFailMessageSend:(PNMessage *)message withError:(PNError *)error {
 
     // PubNub client failed to send message and reason is in 'error'.
 }
 
 - (void)pubnubClient:(PubNub *)client didSendMessage:(PNMessage *)message {
 
     // PubNub client successfully sent message to specified channel.
 }
 @endcode
 
 There is also way to observe message processing from any place in your application using  \b PNObservationCenter:
 @code
 [[PNObservationCenter defaultCenter] addMessageProcessingObserver:self
  withBlock:^(PNMessageState state, id data) {
 
  switch (state) {
      case PNMessageSending:
 
          // PubNub client is sending message at this moment. 'data' stores reference on PNMessage instance which is processing at this moment.
          break;
      case PNMessageSendingError:
 
          // PubNub client failed to send message and reason is in 'data' object.
          break;
      case PNMessageSent:
 
          // PubNub client successfully sent message to specified channel. 'data' stores reference on PNMessage instance which has been sent.
          break;
      }
 }];
 @endcode
 
 @param message
 Object which should be sent to the channel. It can be any object which can be serialized into JSON: \c NSString, \c NSNumber, \c NSArray,
 \c NSDictionary.

 @param apnsPayload
 Valid APNS payload dictionary which should be delivered using push service to all subscribers. You can append some more data except message which should be shown to the user.

 @param gcmPayload
 Valid GCM payload dictionary which should be delivered using cloud service to all subscribers. You can append some more data except message which should be shown to the user.

 @param channel
 \b PNChannel instance to which message should be sent.

 @param shouldCompressMessage
 If set to \c YES \b PubNub client will sent it in GZIPed form.

 @param success
 The block which will be called by \b PubNub client any time when message processing state will be changed. The block takes two arguments:
 \c state - one of \b PNMessageState enumerator fields which tell at which stage message at this moment; \c data - depending on whether message is sending/sent or in state
 of message sending failure it can be one of: \b PNMessage or \b PNError instance.
 
 @return \b PNMessage instance if message payload is correct or \c nil if not.
 */
+ (PNMessage *)sendMessage:(id)message applePushNotification:(NSDictionary *)apnsPayload googleCloudNotification:(NSDictionary *)gcmPayload
                 toChannel:(PNChannel *)channel compressed:(BOOL)shouldCompressMessage withCompletionBlock:(PNClientMessageProcessingBlock)success;

/**
 Send \c message to the \c channel. All messages placed into queue and will be sent in the same order as they were scheduled.
 
 @code
 @endcode
 This method extends \a +sendMessage:applePushNotification:googleCloudNotification:toChannel:compressed: and allow to specify whether message should be stored in history or not.
 
 @code
 @endcode
 \b Example:
 
 @code
 [PubNub setConfiguration:[PNConfiguration defaultConfiguration] andDelegate:self];
 [PubNub connect];
 [PubNub sendMessage:@{@"array": @[@"of", @"strings"], @"and": @16} 
applePushNotification:@{@"aps":@{@"alert":@"Someone sent array of strings"}} 
googleCloudNotification:@{@"data":@{@"summary":@"Someone sent array of strings"}}
           toChannel:[PNChannel channelWithName:@"iosdev"] compressed:NO storeInHistory:YES];
 @endcode
 
 And handle it with delegates:
 @code
 - (void)pubnubClient:(PubNub *)client willSendMessage:(PNMessage *)message {
 
     // PubNub client is sending message at this moment.
 }
 
 - (void)pubnubClient:(PubNub *)client didFailMessageSend:(PNMessage *)message withError:(PNError *)error {
 
     // PubNub client failed to send message and reason is in 'error'.
 }
 
 - (void)pubnubClient:(PubNub *)client didSendMessage:(PNMessage *)message {
 
     // PubNub client successfully sent message to specified channel.
 }
 @endcode
 
 There is also way to observe message processing from any place in your application using  \b PNObservationCenter:
 @code
 [[PNObservationCenter defaultCenter] addMessageProcessingObserver:self
  withBlock:^(PNMessageState state, id data) {
 
  switch (state) {
      case PNMessageSending:
 
          // PubNub client is sending message at this moment. 'data' stores reference on PNMessage instance which is processing at this moment.
          break;
      case PNMessageSendingError:
 
          // PubNub client failed to send message and reason is in 'data' object.
          break;
      case PNMessageSent:
 
          // PubNub client successfully sent message to specified channel. 'data' stores reference on PNMessage instance which has been sent.
          break;
      }
 }];
 @endcode
 
 @param message
 Object which should be sent to the channel. It can be any object which can be serialized into JSON: \c NSString, \c NSNumber, \c NSArray,
 \c NSDictionary.

 @param apnsPayload
 Valid APNS payload dictionary which should be delivered using push service to all subscribers. You can append some more data except message which should be shown to the user.

 @param gcmPayload
 Valid GCM payload dictionary which should be delivered using cloud service to all subscribers. You can append some more data except message which should be shown to the user.
 
 @param channel
 \b PNChannel instance into which message should be sent.
 
 @param shouldCompressMessage
 \c YES will instruct \b PubNub client to compress message before sending it to the target \c channel.
 
 @param shouldStoreInHistory
 \c YES in case if message should be stored on \b PubNub service side and become available with History API.
 
 @return \b PNMessage instance if message payload is correct or \c nil if not.
 */
+ (PNMessage *)sendMessage:(id)message applePushNotification:(NSDictionary *)apnsPayload googleCloudNotification:(NSDictionary *)gcmPayload
                 toChannel:(PNChannel *)channel compressed:(BOOL)shouldCompressMessage storeInHistory:(BOOL)shouldStoreInHistory;

/**
 Send \c message to the \c channel. All messages placed into queue and will be sent in the same order as they were scheduled.
 
 @code
 @endcode
 This method extends \a +sendMessage:applePushNotification:googleCloudNotification:toChannel:compressed:storeInHistory: and allow to specify message sending processing block.
 
 @code
 @endcode
 \b Example:
 
 @code
 [PubNub setConfiguration:[PNConfiguration defaultConfiguration] andDelegate:self];
 [PubNub connect];
 [PubNub sendMessage:@{@"array": @[@"of", @"strings"], @"and": @16} 
applePushNotification:@{@"aps":@{@"alert":@"Someone sent array of strings"}} 
googleCloudNotification:@{@"data":@{@"summary":@"Someone sent array of strings"}}
           toChannel:[PNChannel channelWithName:@"iosdev"] compressed:NO storeInHistory:YES
 withCompletionBlock:^(PNMessageState state, id data) {
 
  switch (state) {
      case PNMessageSending:
 
          // PubNub client is sending message at this moment. 'data' stores reference on PNMessage instance which is processing at this moment.
          break;
      case PNMessageSendingError:
 
          // PubNub client failed to send message and reason is in 'data' object.
          break;
      case PNMessageSent:
 
          // PubNub client successfully sent message to specified channel. 'data' stores reference on PNMessage instance which has been sent.
          break;
      }
 }];
 @endcode
 
 And handle it with delegates:
 @code
 - (void)pubnubClient:(PubNub *)client willSendMessage:(PNMessage *)message {
 
     // PubNub client is sending message at this moment.
 }
 
 - (void)pubnubClient:(PubNub *)client didFailMessageSend:(PNMessage *)message withError:(PNError *)error {
 
     // PubNub client failed to send message and reason is in 'error'.
 }
 
 - (void)pubnubClient:(PubNub *)client didSendMessage:(PNMessage *)message {
 
     // PubNub client successfully sent message to specified channel.
 }
 @endcode
 
 There is also way to observe message processing from any place in your application using  \b PNObservationCenter:
 @code
 [[PNObservationCenter defaultCenter] addMessageProcessingObserver:self
  withBlock:^(PNMessageState state, id data) {
 
  switch (state) {
      case PNMessageSending:
 
          // PubNub client is sending message at this moment. 'data' stores reference on PNMessage instance which is processing at this moment.
          break;
      case PNMessageSendingError:
 
          // PubNub client failed to send message and reason is in 'data' object.
          break;
      case PNMessageSent:
 
          // PubNub client successfully sent message to specified channel. 'data' stores reference on PNMessage instance which has been sent.
          break;
      }
 }];
 @endcode
 
 @param message
 Object which should be sent to the channel. It can be any object which can be serialized into JSON: \c NSString, \c NSNumber, \c NSArray,
 \c NSDictionary.

 @param apnsPayload
 Valid APNS payload dictionary which should be delivered using push service to all subscribers. You can append some more data except message which should be shown to the user.

 @param gcmPayload
 Valid GCM payload dictionary which should be delivered using cloud service to all subscribers. You can append some more data except message which should be shown to the user.
 
 @param channel
 \b PNChannel instance into which message should be sent.
 
 @param shouldCompressMessage
 \c YES will instruct \b PubNub client to compress message before sending it to the target \c channel.
 
 @param shouldStoreInHistory
 \c YES in case if message should be stored on \b PubNub service side and become available with History API.
 
 @param success
 The block which will be called by \b PubNub client any time when message processing state will be changed. The block takes two arguments:
 \c state - one of \b PNMessageState enumerator fields which tell at which stage message at this moment; \c data - depending on whether message is sending/sent or in state
 of message sending failure it can be one of: \b PNMessage or \b PNError instance.
 
 @return \b PNMessage instance if message payload is correct or \c nil if not.
 */
+ (PNMessage *)sendMessage:(id)message applePushNotification:(NSDictionary *)apnsPayload googleCloudNotification:(NSDictionary *)gcmPayload
                 toChannel:(PNChannel *)channel compressed:(BOOL)shouldCompressMessage storeInHistory:(BOOL)shouldStoreInHistory 
       withCompletionBlock:(PNClientMessageProcessingBlock)success;

/**
 Asynchronously send configured message object to PubNub service.
 */
+ (void)sendMessage:(PNMessage *)message;

/**
 Same as +sendMessage: but allow to specify completion block which will be called when message will be sent or in case of error.
 
 Only last call of this method will call completion block. If you need to track message sending from many places, use PNObservationCenter methods
 for this purpose.
 */
+ (void)sendMessage:(PNMessage *)message withCompletionBlock:(PNClientMessageProcessingBlock)success;

/**
 Send configured \b PNMessage instance. All messages will be placed into queue and will be send in the same order as they were scheduled.
 
 @code
 @endcode
 This method extendeds \a +sendMessage: and allow to specify whether message should be stored in history or not.
 
 @code
 @endcode
 \b Example:
 
 @code
 [PubNub setConfiguration:[PNConfiguration defaultConfiguration] andDelegate:self];
 [PubNub connect];
 [PubNub sendMessage:storedMessageInstance storeInHistory:YES];
 @endcode
 
 And handle it with delegates:
 @code
 - (void)pubnubClient:(PubNub *)client willSendMessage:(PNMessage *)message {
 
     // PubNub client is sending message at this moment.
 }
 
 - (void)pubnubClient:(PubNub *)client didFailMessageSend:(PNMessage *)message withError:(PNError *)error {
 
     // PubNub client failed to send message and reason is in 'error'.
 }
 
 - (void)pubnubClient:(PubNub *)client didSendMessage:(PNMessage *)message {
 
     // PubNub client successfully sent message to specified channel.
 }
 @endcode
 
 There is also way to observe message processing from any place in your application using  \b PNObservationCenter:
 @code
 [[PNObservationCenter defaultCenter] addMessageProcessingObserver:self
  withBlock:^(PNMessageState state, id data) {
 
  switch (state) {
      case PNMessageSending:
 
          // PubNub client is sending message at this moment. 'data' stores reference on PNMessage instance which is processing at this moment.
          break;
      case PNMessageSendingError:
 
          // PubNub client failed to send message and reason is in 'data' object.
          break;
      case PNMessageSent:
 
          // PubNub client successfully sent message to specified channel. 'data' stores reference on PNMessage instance which has been sent.
          break;
      }
 }];
 @endcode
 
 @param message
 Configured message which will be sent to the channel for which it previously has been created.
 
 @param shouldStoreInHistory
 \c YES in case if message should be stored on \b PubNub service side and become available with History API.
 */
+ (void)sendMessage:(PNMessage *)message storeInHistory:(BOOL)shouldStoreInHistory;

/**
 Same as +sendMessage:withCompletionBlock: but allow to specify whether message should be stored in history or not.
 
 @param shouldStoreInHistory
 \c YES in case if message should be stored on \b PubNub service side and become available with History API.
 */
+ (void)sendMessage:(PNMessage *)message storeInHistory:(BOOL)shouldStoreInHistory withCompletionBlock:(PNClientMessageProcessingBlock)success;

/**
 Send configured \b PNMessage instance. All messages will be placed into queue and will be send in the same order as they were scheduled.
 
 @code
 @endcode
 This method extendeds \a +sendMessage: and allow to specify whether message should be GZIPed before sending to the \b PubNub service or not.
 
 @code
 @endcode
 \b Example:
 
 @code
 [PubNub setConfiguration:[PNConfiguration defaultConfiguration] andDelegate:self];
 [PubNub connect];
 [PubNub sendMessage:storedMessageInstance compressed:YES];
 @endcode
 
 And handle it with delegates:
 @code
 - (void)pubnubClient:(PubNub *)client willSendMessage:(PNMessage *)message {
 
     // PubNub client is sending message at this moment.
 }
 
 - (void)pubnubClient:(PubNub *)client didFailMessageSend:(PNMessage *)message withError:(PNError *)error {
 
     // PubNub client failed to send message and reason is in 'error'.
 }
 
 - (void)pubnubClient:(PubNub *)client didSendMessage:(PNMessage *)message {
 
     // PubNub client successfully sent message to specified channel.
 }
 @endcode
 
 There is also way to observe message processing from any place in your application using  \b PNObservationCenter:
 @code
 [[PNObservationCenter defaultCenter] addMessageProcessingObserver:self
  withBlock:^(PNMessageState state, id data) {
 
  switch (state) {
      case PNMessageSending:
 
          // PubNub client is sending message at this moment. 'data' stores reference on PNMessage instance which is processing at this moment.
          break;
      case PNMessageSendingError:
 
          // PubNub client failed to send message and reason is in 'data' object.
          break;
      case PNMessageSent:
 
          // PubNub client successfully sent message to specified channel. 'data' stores reference on PNMessage instance which has been sent.
          break;
      }
 }];
 @endcode
 
 @param message
 Object which should be sent to the channel. It can be any object which can be serialized into JSON: \c NSString, \c NSNumber, \c NSArray,
 \c NSDictionary.
 */
+ (void)sendMessage:(PNMessage *)message compressed:(BOOL)shouldCompressMessage;

/**
 Send configured \b PNMessage instance. All messages will be placed into queue and will be send in the same order as they were scheduled.
 
 @code
 @endcode
 This method extendeds \a +sendMessage:withCompletionBlock: and allow to specify whether message should be GZIPed before sending to the \b PubNub service or not.
 
 @code
 @endcode
 \b Example:
 
 @code
 [PubNub setConfiguration:[PNConfiguration defaultConfiguration] andDelegate:self];
 [PubNub connect];
 [PubNub sendMessage:storedMessageInstance compressed:YES
 withCompletionBlock:^(PNMessageState state, id data) {
 
  switch (state) {
      case PNMessageSending:
 
          // PubNub client is sending message at this moment. 'data' stores reference on PNMessage instance which is processing at this moment.
          break;
      case PNMessageSendingError:
 
          // PubNub client failed to send message and reason is in 'data' object.
          break;
      case PNMessageSent:
 
          // PubNub client successfully sent message to specified channel. 'data' stores reference on PNMessage instance which has been sent.
          break;
      }
 }];
 @endcode
 
 And handle it with delegates:
 @code
 - (void)pubnubClient:(PubNub *)client willSendMessage:(PNMessage *)message {
 
     // PubNub client is sending message at this moment.
 }
 
 - (void)pubnubClient:(PubNub *)client didFailMessageSend:(PNMessage *)message withError:(PNError *)error {
 
     // PubNub client failed to send message and reason is in 'error'.
 }
 
 - (void)pubnubClient:(PubNub *)client didSendMessage:(PNMessage *)message {
 
     // PubNub client successfully sent message to specified channel.
 }
 @endcode
 
 There is also way to observe message processing from any place in your application using  \b PNObservationCenter:
 @code
 [[PNObservationCenter defaultCenter] addMessageProcessingObserver:self
  withBlock:^(PNMessageState state, id data) {
 
  switch (state) {
      case PNMessageSending:
 
          // PubNub client is sending message at this moment. 'data' stores reference on PNMessage instance which is processing at this moment.
          break;
      case PNMessageSendingError:
 
          // PubNub client failed to send message and reason is in 'data' object.
          break;
      case PNMessageSent:
 
          // PubNub client successfully sent message to specified channel. 'data' stores reference on PNMessage instance which has been sent.
          break;
      }
 }];
 @endcode
 
 @param message
 Object which should be sent to the channel. It can be any object which can be serialized into JSON: \c NSString, \c NSNumber, \c NSArray,
 \c NSDictionary.
 */
+ (void)sendMessage:(PNMessage *)message compressed:(BOOL)shouldCompressMessage withCompletionBlock:(PNClientMessageProcessingBlock)success;
/**
 Send configured \b PNMessage instance. All messages will be placed into queue and will be send in the same order as they were scheduled.
 
 @code
 @endcode
 This method extendeds \a +sendMessage:compressed: and allow to specify whether message should be stored in history or not.
 
 @code
 @endcode
 \b Example:
 
 @code
 [PubNub setConfiguration:[PNConfiguration defaultConfiguration] andDelegate:self];
 [PubNub connect];
 [PubNub sendMessage:storedMessageInstance compressed:YES storeInHistory:YES];
 @endcode
 
 And handle it with delegates:
 @code
 - (void)pubnubClient:(PubNub *)client willSendMessage:(PNMessage *)message {
 
     // PubNub client is sending message at this moment.
 }
 
 - (void)pubnubClient:(PubNub *)client didFailMessageSend:(PNMessage *)message withError:(PNError *)error {
 
     // PubNub client failed to send message and reason is in 'error'.
 }
 
 - (void)pubnubClient:(PubNub *)client didSendMessage:(PNMessage *)message {
 
     // PubNub client successfully sent message to specified channel.
 }
 @endcode
 
 There is also way to observe message processing from any place in your application using  \b PNObservationCenter:
 @code
 [[PNObservationCenter defaultCenter] addMessageProcessingObserver:self
  withBlock:^(PNMessageState state, id data) {
 
  switch (state) {
      case PNMessageSending:
 
          // PubNub client is sending message at this moment. 'data' stores reference on PNMessage instance which is processing at this moment.
          break;
      case PNMessageSendingError:
 
          // PubNub client failed to send message and reason is in 'data' object.
          break;
      case PNMessageSent:
 
          // PubNub client successfully sent message to specified channel. 'data' stores reference on PNMessage instance which has been sent.
          break;
      }
 }];
 @endcode
 
 @param message
 Configured message which will be sent to the channel for which it previously has been created.
 
 @param shouldCompressMessage
 \c YES in case if message should be compressed before sending to the PubNub service.
 
 @param shouldStoreInHistory
 \c YES in case if message should be stored on \b PubNub service side and become available with History API.
 */
+ (void)sendMessage:(PNMessage *)message compressed:(BOOL)shouldCompressMessage storeInHistory:(BOOL)shouldStoreInHistory;

/**
 Send configured \b PNMessage instance. All messages will be placed into queue and will be send in the same order as they were scheduled.
 
 @code
 @endcode
 This method extendeds \a +sendMessage:compressed:withCompletionBlock: and allow to specify whether message should be stored in history or not.
 
 @code
 @endcode
 \b Example:
 
 @code
 [PubNub setConfiguration:[PNConfiguration defaultConfiguration] andDelegate:self];
 [PubNub connect];
 [PubNub sendMessage:storedMessageInstance compressed:YES storeInHistory:NO
 withCompletionBlock:^(PNMessageState state, id data) {
 
  switch (state) {
      case PNMessageSending:
 
          // PubNub client is sending message at this moment. 'data' stores reference on PNMessage instance which is processing at this moment.
          break;
      case PNMessageSendingError:
 
          // PubNub client failed to send message and reason is in 'data' object.
          break;
      case PNMessageSent:
 
          // PubNub client successfully sent message to specified channel. 'data' stores reference on PNMessage instance which has been sent.
          break;
      }
 }];
 @endcode
 
 And handle it with delegates:
 @code
 - (void)pubnubClient:(PubNub *)client willSendMessage:(PNMessage *)message {
 
     // PubNub client is sending message at this moment.
 }
 
 - (void)pubnubClient:(PubNub *)client didFailMessageSend:(PNMessage *)message withError:(PNError *)error {
 
     // PubNub client failed to send message and reason is in 'error'.
 }
 
 - (void)pubnubClient:(PubNub *)client didSendMessage:(PNMessage *)message {
 
     // PubNub client successfully sent message to specified channel.
 }
 @endcode
 
 There is also way to observe message processing from any place in your application using  \b PNObservationCenter:
 @code
 [[PNObservationCenter defaultCenter] addMessageProcessingObserver:self
  withBlock:^(PNMessageState state, id data) {
 
  switch (state) {
      case PNMessageSending:
 
          // PubNub client is sending message at this moment. 'data' stores reference on PNMessage instance which is processing at this moment.
          break;
      case PNMessageSendingError:
 
          // PubNub client failed to send message and reason is in 'data' object.
          break;
      case PNMessageSent:
 
          // PubNub client successfully sent message to specified channel. 'data' stores reference on PNMessage instance which has been sent.
          break;
      }
 }];
 @endcode
 
 @param message
 Configured message which will be sent to the channel for which it previously has been created.
 
 @param shouldCompressMessage
 \c YES in case if message should be compressed before sending to the PubNub service.
 
 @param shouldStoreInHistory
 \c YES in case if message should be stored on \b PubNub service side and become available with History API.
 */
+ (void)sendMessage:(PNMessage *)message compressed:(BOOL)shouldCompressMessage storeInHistory:(BOOL)shouldStoreInHistory
withCompletionBlock:(PNClientMessageProcessingBlock)success;


#pragma mark - Instance methods

/**
 Send \c message to the \c channel. All messages placed into queue and will be sent in the same order as they were scheduled.
 
 @code
 @endcode
 \b Example:
 
 @code
 PubNub *pubNub = [PubNub clientWithConfiguration:[PNConfiguration defaultConfiguration] andDelegate:self];
 [pubNub connect];
 [pubNub sendMessage:@{@"array": @[@"of", @"strings"], @"and": @16} toChannel:[PNChannel channelWithName:@"iosdev"]];
 @endcode
 
 And handle it with delegates:
 @code
 - (void)pubnubClient:(PubNub *)client willSendMessage:(PNMessage *)message {
 
     // PubNub client is sending message at this moment.
 }
 
 - (void)pubnubClient:(PubNub *)client didFailMessageSend:(PNMessage *)message withError:(PNError *)error {
 
     // PubNub client failed to send message and reason is in 'error'.
 }
 
 - (void)pubnubClient:(PubNub *)client didSendMessage:(PNMessage *)message {
 
     // PubNub client successfully sent message to specified channel.
 }
 @endcode
 
 There is also way to observe message processing from any place in your application using  \b PNObservationCenter:
 @code
 [pubNub.observationCenter addMessageProcessingObserver:self
  withBlock:^(PNMessageState state, id data) {
 
  switch (state) {
      case PNMessageSending:
 
          // PubNub client is sending message at this moment. 'data' stores reference on PNMessage instance which is processing at this moment.
          break;
      case PNMessageSendingError:
 
          // PubNub client failed to send message and reason is in 'data' object.
          break;
      case PNMessageSent:
 
          // PubNub client successfully sent message to specified channel. 'data' stores reference on PNMessage instance which has been sent.
          break;
      }
 }];
 @endcode
 
 @param message
 Object which should be sent to the channel. It can be any object which can be serialized into JSON: \c NSString, \c NSNumber, \c NSArray,
 \c NSDictionary.
 
 @param channel
 \b PNChannel instance into which message should be sent.
 
 @return \b PNMessage instance if message payload is correct or \c nil if not.
 */
- (PNMessage *)sendMessage:(id)message toChannel:(PNChannel *)channel;

/**
 Same as -sendMessage:toChannel: but allow to specify completion block which will be called when message will be sent or in case of error.
 
 Only last call of this method will call completion block. If you need to track message sending from many places, use PNObservationCenter methods
 for this purpose.
 */
- (PNMessage *)sendMessage:(id)message toChannel:(PNChannel *)channel withCompletionBlock:(PNClientMessageProcessingBlock)success;

/**
 Send \c message to the \c channel. All messages placed into queue and will be sent in the same order as they were scheduled.
 
 @code
 @endcode
 This method extendeds \a -sendMessage:toChannel: and allow to specify whether message should be stored in history or not.
 
 @code
 @endcode
 \b Example:
 
 @code
 PubNub *pubNub = [PubNub clientWithConfiguration:[PNConfiguration defaultConfiguration] andDelegate:self];
 [pubNub connect];
 [pubNub sendMessage:@{@"array": @[@"of", @"strings"], @"and": @16} toChannel:[PNChannel channelWithName:@"iosdev"]
      storeInHistory:NO];
 @endcode
 
 And handle it with delegates:
 @code
 - (void)pubnubClient:(PubNub *)client willSendMessage:(PNMessage *)message {
 
     // PubNub client is sending message at this moment.
 }
 
 - (void)pubnubClient:(PubNub *)client didFailMessageSend:(PNMessage *)message withError:(PNError *)error {
 
     // PubNub client failed to send message and reason is in 'error'.
 }
 
 - (void)pubnubClient:(PubNub *)client didSendMessage:(PNMessage *)message {
 
     // PubNub client successfully sent message to specified channel.
 }
 @endcode
 
 There is also way to observe message processing from any place in your application using  \b PNObservationCenter:
 @code
 [pubNub.observationCenter addMessageProcessingObserver:self
  withBlock:^(PNMessageState state, id data) {
 
  switch (state) {
      case PNMessageSending:
 
          // PubNub client is sending message at this moment. 'data' stores reference on PNMessage instance which is processing at this moment.
          break;
      case PNMessageSendingError:
 
          // PubNub client failed to send message and reason is in 'data' object.
          break;
      case PNMessageSent:
 
          // PubNub client successfully sent message to specified channel. 'data' stores reference on PNMessage instance which has been sent.
          break;
      }
 }];
 @endcode
 
 @param message
 Object which should be sent to the channel. It can be any object which can be serialized into JSON: \c NSString, \c NSNumber, \c NSArray,
 \c NSDictionary.
 
 @param channel
 \b PNChannel instance into which message should be sent.
 
 @param shouldStoreInHistory
 \c YES in case if message should be stored on \b PubNub service side and become available with History API.
 
 @return \b PNMessage instance if message payload is correct or \c nil if not.
 */
- (PNMessage *)sendMessage:(id)message toChannel:(PNChannel *)channel storeInHistory:(BOOL)shouldStoreInHistory;

/**
 Same as -sendMessage:toChannel:withCompletionBlock: but allow to specify whether message should be stored in history or not.
 
 @param shouldStoreInHistory
 \c YES in case if message should be stored on \b PubNub service side and become available with History API.
 */
- (PNMessage *)sendMessage:(id)message toChannel:(PNChannel *)channel storeInHistory:(BOOL)shouldStoreInHistory
       withCompletionBlock:(PNClientMessageProcessingBlock)success;

/**
 Send \c message to the \c channel. All messages placed into queue and will be sent in the same order as they were scheduled.
 
 @code
 @endcode
 This method extends \a -sendMessage:toChannel: and allow to specify separate payload which will be sent along with message using APNS.
 
 @code
 @endcode
 \b Example:
 
 @code
 PubNub *pubNub = [PubNub clientWithConfiguration:[PNConfiguration defaultConfiguration] andDelegate:self];
 [pubNub connect];
 [pubNub sendMessage:@{@"array": @[@"of", @"strings"], @"and": @16}
 applePushNotification:@{@"aps":@{@"alert":@"Someone sent array of strings"}} 
           toChannel:[PNChannel channelWithName:@"iosdev"]];
 @endcode
 
 And handle it with delegates:
 @code
 - (void)pubnubClient:(PubNub *)client willSendMessage:(PNMessage *)message {
 
     // PubNub client is sending message at this moment.
 }
 
 - (void)pubnubClient:(PubNub *)client didFailMessageSend:(PNMessage *)message withError:(PNError *)error {
 
     // PubNub client failed to send message and reason is in 'error'.
 }
 
 - (void)pubnubClient:(PubNub *)client didSendMessage:(PNMessage *)message {
 
     // PubNub client successfully sent message to specified channel.
 }
 @endcode
 
 There is also way to observe message processing from any place in your application using  \b PNObservationCenter:
 @code
 [pubNub.observationCenter addMessageProcessingObserver:self
  withBlock:^(PNMessageState state, id data) {
 
  switch (state) {
      case PNMessageSending:
 
          // PubNub client is sending message at this moment. 'data' stores reference on PNMessage instance which is processing at this moment.
          break;
      case PNMessageSendingError:
 
          // PubNub client failed to send message and reason is in 'data' object.
          break;
      case PNMessageSent:
 
          // PubNub client successfully sent message to specified channel. 'data' stores reference on PNMessage instance which has been sent.
          break;
      }
 }];
 @endcode
 
 @param message
 Object which should be sent to the channel. It can be any object which can be serialized into JSON: \c NSString, \c NSNumber, \c NSArray,
 \c NSDictionary.

 @param apnsPayload
 Valid APNS payload dictionary which should be delivered using push service to all subscribers. You can append some more data except message which should be shown to the user.

 @param channel
 \b PNChannel instance to which message should be sent.
 
 @return \b PNMessage instance if message payload is correct or \c nil if not.
 */
- (PNMessage *)sendMessage:(id)message applePushNotification:(NSDictionary *)apnsPayload toChannel:(PNChannel *)channel;

/**
 Send \c message to the \c channel. All messages placed into queue and will be sent in the same order as they were scheduled.
 
 @code
 @endcode
 This method extends \a -sendMessage:applePushNotification:toChannel: and allow to specify message sending processing block.
 
 @code
 @endcode
 \b Example:
 
 @code
 PubNub *pubNub = [PubNub clientWithConfiguration:[PNConfiguration defaultConfiguration] andDelegate:self];
 [pubNub connect];
 [pubNub sendMessage:@{@"array": @[@"of", @"strings"], @"and": @16}
 applePushNotification:@{@"aps":@{@"alert":@"Someone sent array of strings"}} 
           toChannel:[PNChannel channelWithName:@"iosdev"]
 withCompletionBlock:^(PNMessageState state, id data) {
 
  switch (state) {
      case PNMessageSending:
 
          // PubNub client is sending message at this moment. 'data' stores reference on PNMessage instance which is processing at this moment.
          break;
      case PNMessageSendingError:
 
          // PubNub client failed to send message and reason is in 'data' object.
          break;
      case PNMessageSent:
 
          // PubNub client successfully sent message to specified channel. 'data' stores reference on PNMessage instance which has been sent.
          break;
      }
 }];
 @endcode
 
 And handle it with delegates:
 @code
 - (void)pubnubClient:(PubNub *)client willSendMessage:(PNMessage *)message {
 
     // PubNub client is sending message at this moment.
 }
 
 - (void)pubnubClient:(PubNub *)client didFailMessageSend:(PNMessage *)message withError:(PNError *)error {
 
     // PubNub client failed to send message and reason is in 'error'.
 }
 
 - (void)pubnubClient:(PubNub *)client didSendMessage:(PNMessage *)message {
 
     // PubNub client successfully sent message to specified channel.
 }
 @endcode
 
 There is also way to observe message processing from any place in your application using  \b PNObservationCenter:
 @code
 [pubNub.observationCenter addMessageProcessingObserver:self
  withBlock:^(PNMessageState state, id data) {
 
  switch (state) {
      case PNMessageSending:
 
          // PubNub client is sending message at this moment. 'data' stores reference on PNMessage instance which is processing at this moment.
          break;
      case PNMessageSendingError:
 
          // PubNub client failed to send message and reason is in 'data' object.
          break;
      case PNMessageSent:
 
          // PubNub client successfully sent message to specified channel. 'data' stores reference on PNMessage instance which has been sent.
          break;
      }
 }];
 @endcode
 
 @param message
 Object which should be sent to the channel. It can be any object which can be serialized into JSON: \c NSString, \c NSNumber, \c NSArray,
 \c NSDictionary.

 @param apnsPayload
 Valid APNS payload dictionary which should be delivered using push service to all subscribers. You can append some more data except message which should be shown to the user.

 @param channel
 \b PNChannel instance to which message should be sent.

 @param success
 The block which will be called by \b PubNub client any time when message processing state will be changed. The block takes two arguments:
 \c state - one of \b PNMessageState enumerator fields which tell at which stage message at this moment; \c data - depending on whether message is sending/sent or in state
 of message sending failure it can be one of: \b PNMessage or \b PNError instance.
 
 @return \b PNMessage instance if message payload is correct or \c nil if not.
 */
- (PNMessage *)sendMessage:(id)message applePushNotification:(NSDictionary *)apnsPayload toChannel:(PNChannel *)channel
       withCompletionBlock:(PNClientMessageProcessingBlock)success;

/**
 Send \c message to the \c channel. All messages placed into queue and will be sent in the same order as they were scheduled.
 
 @code
 @endcode
 This method extends \a -sendMessage:applePushNotification:toChannel: and allow to specify whether message should be stored in history or not.
 
 @code
 @endcode
 \b Example:
 
 @code
 PubNub *pubNub = [PubNub clientWithConfiguration:[PNConfiguration defaultConfiguration] andDelegate:self];
 [pubNub connect];
 [pubNub sendMessage:@{@"array": @[@"of", @"strings"], @"and": @16}
applePushNotification:@{@"aps":@{@"alert":@"Someone sent array of strings"}}
           toChannel:[PNChannel channelWithName:@"iosdev"] storeInHistory:NO];
 @endcode
 
 And handle it with delegates:
 @code
 - (void)pubnubClient:(PubNub *)client willSendMessage:(PNMessage *)message {
 
     // PubNub client is sending message at this moment.
 }
 
 - (void)pubnubClient:(PubNub *)client didFailMessageSend:(PNMessage *)message withError:(PNError *)error {
 
     // PubNub client failed to send message and reason is in 'error'.
 }
 
 - (void)pubnubClient:(PubNub *)client didSendMessage:(PNMessage *)message {
 
     // PubNub client successfully sent message to specified channel.
 }
 @endcode
 
 There is also way to observe message processing from any place in your application using  \b PNObservationCenter:
 @code
 [pubNub.observationCenter addMessageProcessingObserver:self
  withBlock:^(PNMessageState state, id data) {
 
  switch (state) {
      case PNMessageSending:
 
          // PubNub client is sending message at this moment. 'data' stores reference on PNMessage instance which is processing at this moment.
          break;
      case PNMessageSendingError:
 
          // PubNub client failed to send message and reason is in 'data' object.
          break;
      case PNMessageSent:
 
          // PubNub client successfully sent message to specified channel. 'data' stores reference on PNMessage instance which has been sent.
          break;
      }
 }];
 @endcode
 
 @param message
 Object which should be sent to the channel. It can be any object which can be serialized into JSON: \c NSString, \c NSNumber, \c NSArray,
 \c NSDictionary.
 
 @param apnsPayload
 Valid APNS payload dictionary which should be delivered using push service to all subscribers. You can append some more data except message which should be shown to the user.
 
 @param channel
 \b PNChannel instance into which message should be sent.
 
 @param shouldStoreInHistory
 \c YES in case if message should be stored on \b PubNub service side and become available with History API.
 
 @return \b PNMessage instance if message payload is correct or \c nil if not.
 */
- (PNMessage *)sendMessage:(id)message applePushNotification:(NSDictionary *)apnsPayload toChannel:(PNChannel *)channel
            storeInHistory:(BOOL)shouldStoreInHistory;

/**
 Send \c message to the \c channel. All messages placed into queue and will be sent in the same order as they were scheduled.
 
 @code
 @endcode
 This method extends \a -sendMessage:applePushNotification:toChannel:storeInHistory: and allow to specify message sending processing block.
 
 @code
 @endcode
 \b Example:
 
 @code
 PubNub *pubNub = [PubNub clientWithConfiguration:[PNConfiguration defaultConfiguration] andDelegate:self];
 [pubNub connect];
 [pubNub sendMessage:@{@"array": @[@"of", @"strings"], @"and": @16}
applePushNotification:@{@"aps":@{@"alert":@"Someone sent array of strings"}}
           toChannel:[PNChannel channelWithName:@"iosdev"] storeInHistory:NO
 withCompletionBlock:^(PNMessageState state, id data) {
 
  switch (state) {
      case PNMessageSending:
 
          // PubNub client is sending message at this moment. 'data' stores reference on PNMessage instance which is processing at this moment.
          break;
      case PNMessageSendingError:
 
          // PubNub client failed to send message and reason is in 'data' object.
          break;
      case PNMessageSent:
 
          // PubNub client successfully sent message to specified channel. 'data' stores reference on PNMessage instance which has been sent.
          break;
      }
 }];
 @endcode
 
 And handle it with delegates:
 @code
 - (void)pubnubClient:(PubNub *)client willSendMessage:(PNMessage *)message {
 
     // PubNub client is sending message at this moment.
 }
 
 - (void)pubnubClient:(PubNub *)client didFailMessageSend:(PNMessage *)message withError:(PNError *)error {
 
     // PubNub client failed to send message and reason is in 'error'.
 }
 
 - (void)pubnubClient:(PubNub *)client didSendMessage:(PNMessage *)message {
 
     // PubNub client successfully sent message to specified channel.
 }
 @endcode
 
 There is also way to observe message processing from any place in your application using  \b PNObservationCenter:
 @code
 [pubNub.observationCenter addMessageProcessingObserver:self
  withBlock:^(PNMessageState state, id data) {
 
  switch (state) {
      case PNMessageSending:
 
          // PubNub client is sending message at this moment. 'data' stores reference on PNMessage instance which is processing at this moment.
          break;
      case PNMessageSendingError:
 
          // PubNub client failed to send message and reason is in 'data' object.
          break;
      case PNMessageSent:
 
          // PubNub client successfully sent message to specified channel. 'data' stores reference on PNMessage instance which has been sent.
          break;
      }
 }];
 @endcode
 
 @param message
 Object which should be sent to the channel. It can be any object which can be serialized into JSON: \c NSString, \c NSNumber, \c NSArray,
 \c NSDictionary.
 
 @param apnsPayload
 Valid APNS payload dictionary which should be delivered using push service to all subscribers. You can append some more data except message which should be shown to the user.
 
 @param channel
 \b PNChannel instance into which message should be sent.
 
 @param shouldStoreInHistory
 \c YES in case if message should be stored on \b PubNub service side and become available with History API.
 
 @param success
 The block which will be called by \b PubNub client any time when message processing state will be changed. The block takes two arguments:
 \c state - one of \b PNMessageState enumerator fields which tell at which stage message at this moment; \c data - depending on whether message is sending/sent or in state
 of message sending failure it can be one of: \b PNMessage or \b PNError instance.
 
 @return \b PNMessage instance if message payload is correct or \c nil if not.
 */
- (PNMessage *)sendMessage:(id)message applePushNotification:(NSDictionary *)apnsPayload toChannel:(PNChannel *)channel
            storeInHistory:(BOOL)shouldStoreInHistory withCompletionBlock:(PNClientMessageProcessingBlock)success;

/**
 Send \c message to the \c channel. All messages placed into queue and will be sent in the same order as they were scheduled.
 
 @code
 @endcode
 This method extends \a -sendMessage:toChannel: and allow to specify separate payload which will be sent along with message using GCM.
 
 @code
 @endcode
 \b Example:
 
 @code
 PubNub *pubNub = [PubNub clientWithConfiguration:[PNConfiguration defaultConfiguration] andDelegate:self];
 [pubNub connect];
 [pubNub sendMessage:@{@"array": @[@"of", @"strings"], @"and": @16}
 googleCloudNotification:@{@"data":@{@"summary":@"Someone sent array of strings"}} 
           toChannel:[PNChannel channelWithName:@"iosdev"]];
 @endcode
 
 And handle it with delegates:
 @code
 - (void)pubnubClient:(PubNub *)client willSendMessage:(PNMessage *)message {
 
     // PubNub client is sending message at this moment.
 }
 
 - (void)pubnubClient:(PubNub *)client didFailMessageSend:(PNMessage *)message withError:(PNError *)error {
 
     // PubNub client failed to send message and reason is in 'error'.
 }
 
 - (void)pubnubClient:(PubNub *)client didSendMessage:(PNMessage *)message {
 
     // PubNub client successfully sent message to specified channel.
 }
 @endcode
 
 There is also way to observe message processing from any place in your application using  \b PNObservationCenter:
 @code
 [pubNub.observationCenter addMessageProcessingObserver:self
  withBlock:^(PNMessageState state, id data) {
 
  switch (state) {
      case PNMessageSending:
 
          // PubNub client is sending message at this moment. 'data' stores reference on PNMessage instance which is processing at this moment.
          break;
      case PNMessageSendingError:
 
          // PubNub client failed to send message and reason is in 'data' object.
          break;
      case PNMessageSent:
 
          // PubNub client successfully sent message to specified channel. 'data' stores reference on PNMessage instance which has been sent.
          break;
      }
 }];
 @endcode
 
 @param message
 Object which should be sent to the channel. It can be any object which can be serialized into JSON: \c NSString, \c NSNumber, \c NSArray,
 \c NSDictionary.

 @param gcmPayload
 Valid GCM payload dictionary which should be delivered using cloud service to all subscribers. You can append some more data except message which should be shown to the user.

 @param channel
 \b PNChannel instance to which message should be sent.
 
 @return \b PNMessage instance if message payload is correct or \c nil if not.
 */
- (PNMessage *)sendMessage:(id)message googleCloudNotification:(NSDictionary *)gcmPayload toChannel:(PNChannel *)channel;

/**
 Send \c message to the \c channel. All messages placed into queue and will be sent in the same order as they were scheduled.
 
 @code
 @endcode
 This method extends \a -sendMessage:googleCloudNotification:toChannel: and allow to specify message sending processing block.
 
 @code
 @endcode
 \b Example:
 
 @code
 PubNub *pubNub = [PubNub clientWithConfiguration:[PNConfiguration defaultConfiguration] andDelegate:self];
 [pubNub connect];
 [pubNub sendMessage:@{@"array": @[@"of", @"strings"], @"and": @16}
 googleCloudNotification:@{@"data":@{@"summary":@"Someone sent array of strings"}}
           toChannel:[PNChannel channelWithName:@"iosdev"]
 withCompletionBlock:^(PNMessageState state, id data) {
 
  switch (state) {
      case PNMessageSending:
 
          // PubNub client is sending message at this moment. 'data' stores reference on PNMessage instance which is processing at this moment.
          break;
      case PNMessageSendingError:
 
          // PubNub client failed to send message and reason is in 'data' object.
          break;
      case PNMessageSent:
 
          // PubNub client successfully sent message to specified channel. 'data' stores reference on PNMessage instance which has been sent.
          break;
      }
 }];
 @endcode
 
 And handle it with delegates:
 @code
 - (void)pubnubClient:(PubNub *)client willSendMessage:(PNMessage *)message {
 
     // PubNub client is sending message at this moment.
 }
 
 - (void)pubnubClient:(PubNub *)client didFailMessageSend:(PNMessage *)message withError:(PNError *)error {
 
     // PubNub client failed to send message and reason is in 'error'.
 }
 
 - (void)pubnubClient:(PubNub *)client didSendMessage:(PNMessage *)message {
 
     // PubNub client successfully sent message to specified channel.
 }
 @endcode
 
 There is also way to observe message processing from any place in your application using  \b PNObservationCenter:
 @code
 [pubNub.observationCenter addMessageProcessingObserver:self
  withBlock:^(PNMessageState state, id data) {
 
  switch (state) {
      case PNMessageSending:
 
          // PubNub client is sending message at this moment. 'data' stores reference on PNMessage instance which is processing at this moment.
          break;
      case PNMessageSendingError:
 
          // PubNub client failed to send message and reason is in 'data' object.
          break;
      case PNMessageSent:
 
          // PubNub client successfully sent message to specified channel. 'data' stores reference on PNMessage instance which has been sent.
          break;
      }
 }];
 @endcode
 
 @param message
 Object which should be sent to the channel. It can be any object which can be serialized into JSON: \c NSString, \c NSNumber, \c NSArray,
 \c NSDictionary.

 @param gcmPayload
 Valid GCM payload dictionary which should be delivered using cloud service to all subscribers. You can append some more data except message which should be shown to the user.

 @param channel
 \b PNChannel instance to which message should be sent.

 @param success
 The block which will be called by \b PubNub client any time when message processing state will be changed. The block takes two arguments:
 \c state - one of \b PNMessageState enumerator fields which tell at which stage message at this moment; \c data - depending on whether message is sending/sent or in state
 of message sending failure it can be one of: \b PNMessage or \b PNError instance.
 
 @return \b PNMessage instance if message payload is correct or \c nil if not.
 */
- (PNMessage *)sendMessage:(id)message googleCloudNotification:(NSDictionary *)gcmPayload toChannel:(PNChannel *)channel
       withCompletionBlock:(PNClientMessageProcessingBlock)success;

/**
 Send \c message to the \c channel. All messages placed into queue and will be sent in the same order as they were scheduled.
 
 @code
 @endcode
 This method extends \a -sendMessage:googleCloudNotification:toChannel: and allow to specify whether message should be stored in history or not.
 
 @code
 @endcode
 \b Example:
 
 @code
 PubNub *pubNub = [PubNub clientWithConfiguration:[PNConfiguration defaultConfiguration] andDelegate:self];
 [pubNub connect];
 [pubNub sendMessage:@{@"array": @[@"of", @"strings"], @"and": @16}
googleCloudNotification:@{@"data":@{@"summary":@"Someone sent array of strings"}} 
           toChannel:[PNChannel channelWithName:@"iosdev"] storeInHistory:NO];
 @endcode
 
 And handle it with delegates:
 @code
 - (void)pubnubClient:(PubNub *)client willSendMessage:(PNMessage *)message {
 
     // PubNub client is sending message at this moment.
 }
 
 - (void)pubnubClient:(PubNub *)client didFailMessageSend:(PNMessage *)message withError:(PNError *)error {
 
     // PubNub client failed to send message and reason is in 'error'.
 }
 
 - (void)pubnubClient:(PubNub *)client didSendMessage:(PNMessage *)message {
 
     // PubNub client successfully sent message to specified channel.
 }
 @endcode
 
 There is also way to observe message processing from any place in your application using  \b PNObservationCenter:
 @code
 [pubNub.observationCenter addMessageProcessingObserver:self
  withBlock:^(PNMessageState state, id data) {
 
  switch (state) {
      case PNMessageSending:
 
          // PubNub client is sending message at this moment. 'data' stores reference on PNMessage instance which is processing at this moment.
          break;
      case PNMessageSendingError:
 
          // PubNub client failed to send message and reason is in 'data' object.
          break;
      case PNMessageSent:
 
          // PubNub client successfully sent message to specified channel. 'data' stores reference on PNMessage instance which has been sent.
          break;
      }
 }];
 @endcode
 
 @param message
 Object which should be sent to the channel. It can be any object which can be serialized into JSON: \c NSString, \c NSNumber, \c NSArray,
 \c NSDictionary.

 @param gcmPayload
 Valid GCM payload dictionary which should be delivered using cloud service to all subscribers. You can append some more data except message which should be shown to the user.
 
 @param channel
 \b PNChannel instance into which message should be sent.
 
 @param shouldStoreInHistory
 \c YES in case if message should be stored on \b PubNub service side and become available with History API.
 
 @return \b PNMessage instance if message payload is correct or \c nil if not.
 */
- (PNMessage *)sendMessage:(id)message googleCloudNotification:(NSDictionary *)gcmPayload toChannel:(PNChannel *)channel
            storeInHistory:(BOOL)shouldStoreInHistory;

/**
 Send \c message to the \c channel. All messages placed into queue and will be sent in the same order as they were scheduled.
 
 @code
 @endcode
 This method extends \a -sendMessage:googleCloudNotification:toChannel:storeInHistory: and allow to specify message sending processing block.
 
 @code
 @endcode
 \b Example:
 
 @code
 PubNub *pubNub = [PubNub clientWithConfiguration:[PNConfiguration defaultConfiguration] andDelegate:self];
 [pubNub connect];
 [pubNub sendMessage:@{@"array": @[@"of", @"strings"], @"and": @16}
googleCloudNotification:@{@"data":@{@"summary":@"Someone sent array of strings"}} 
           toChannel:[PNChannel channelWithName:@"iosdev"] storeInHistory:NO
 withCompletionBlock:^(PNMessageState state, id data) {
 
  switch (state) {
      case PNMessageSending:
 
          // PubNub client is sending message at this moment. 'data' stores reference on PNMessage instance which is processing at this moment.
          break;
      case PNMessageSendingError:
 
          // PubNub client failed to send message and reason is in 'data' object.
          break;
      case PNMessageSent:
 
          // PubNub client successfully sent message to specified channel. 'data' stores reference on PNMessage instance which has been sent.
          break;
      }
 }];
 @endcode
 
 And handle it with delegates:
 @code
 - (void)pubnubClient:(PubNub *)client willSendMessage:(PNMessage *)message {
 
     // PubNub client is sending message at this moment.
 }
 
 - (void)pubnubClient:(PubNub *)client didFailMessageSend:(PNMessage *)message withError:(PNError *)error {
 
     // PubNub client failed to send message and reason is in 'error'.
 }
 
 - (void)pubnubClient:(PubNub *)client didSendMessage:(PNMessage *)message {
 
     // PubNub client successfully sent message to specified channel.
 }
 @endcode
 
 There is also way to observe message processing from any place in your application using  \b PNObservationCenter:
 @code
 [pubNub.observationCenter addMessageProcessingObserver:self
  withBlock:^(PNMessageState state, id data) {
 
  switch (state) {
      case PNMessageSending:
 
          // PubNub client is sending message at this moment. 'data' stores reference on PNMessage instance which is processing at this moment.
          break;
      case PNMessageSendingError:
 
          // PubNub client failed to send message and reason is in 'data' object.
          break;
      case PNMessageSent:
 
          // PubNub client successfully sent message to specified channel. 'data' stores reference on PNMessage instance which has been sent.
          break;
      }
 }];
 @endcode
 
 @param message
 Object which should be sent to the channel. It can be any object which can be serialized into JSON: \c NSString, \c NSNumber, \c NSArray,
 \c NSDictionary.

 @param gcmPayload
 Valid GCM payload dictionary which should be delivered using cloud service to all subscribers. You can append some more data except message which should be shown to the user.
 
 @param channel
 \b PNChannel instance into which message should be sent.
 
 @param shouldStoreInHistory
 \c YES in case if message should be stored on \b PubNub service side and become available with History API.
 
 @param success
 The block which will be called by \b PubNub client any time when message processing state will be changed. The block takes two arguments:
 \c state - one of \b PNMessageState enumerator fields which tell at which stage message at this moment; \c data - depending on whether message is sending/sent or in state
 of message sending failure it can be one of: \b PNMessage or \b PNError instance.
 
 @return \b PNMessage instance if message payload is correct or \c nil if not.
 */
- (PNMessage *)sendMessage:(id)message googleCloudNotification:(NSDictionary *)gcmPayload toChannel:(PNChannel *)channel
            storeInHistory:(BOOL)shouldStoreInHistory withCompletionBlock:(PNClientMessageProcessingBlock)success;

/**
 Send \c message to the \c channel. All messages placed into queue and will be sent in the same order as they were scheduled.
 
 @code
 @endcode
 This method extends \a -sendMessage:toChannel: and allow to specify separate payload which will be sent along with message using APNS and GCM.
 
 @code
 @endcode
 \b Example:
 
 @code
 PubNub *pubNub = [PubNub clientWithConfiguration:[PNConfiguration defaultConfiguration] andDelegate:self];
 [pubNub connect];
 [pubNub sendMessage:@{@"array": @[@"of", @"strings"], @"and": @16}
 applePushNotification:@{@"aps":@{@"alert":@"Someone sent array of strings"}} 
googleCloudNotification:@{@"data":@{@"summary":@"Someone sent array of strings"}}
           toChannel:[PNChannel channelWithName:@"iosdev"]];
 @endcode
 
 And handle it with delegates:
 @code
 - (void)pubnubClient:(PubNub *)client willSendMessage:(PNMessage *)message {
 
     // PubNub client is sending message at this moment.
 }
 
 - (void)pubnubClient:(PubNub *)client didFailMessageSend:(PNMessage *)message withError:(PNError *)error {
 
     // PubNub client failed to send message and reason is in 'error'.
 }
 
 - (void)pubnubClient:(PubNub *)client didSendMessage:(PNMessage *)message {
 
     // PubNub client successfully sent message to specified channel.
 }
 @endcode
 
 There is also way to observe message processing from any place in your application using  \b PNObservationCenter:
 @code
 [pubNub.observationCenter addMessageProcessingObserver:self
  withBlock:^(PNMessageState state, id data) {
 
  switch (state) {
      case PNMessageSending:
 
          // PubNub client is sending message at this moment. 'data' stores reference on PNMessage instance which is processing at this moment.
          break;
      case PNMessageSendingError:
 
          // PubNub client failed to send message and reason is in 'data' object.
          break;
      case PNMessageSent:
 
          // PubNub client successfully sent message to specified channel. 'data' stores reference on PNMessage instance which has been sent.
          break;
      }
 }];
 @endcode
 
 @param message
 Object which should be sent to the channel. It can be any object which can be serialized into JSON: \c NSString, \c NSNumber, \c NSArray,
 \c NSDictionary.

 @param apnsPayload
 Valid APNS payload dictionary which should be delivered using push service to all subscribers. You can append some more data except message which should be shown to the user.

 @param gcmPayload
 Valid GCM payload dictionary which should be delivered using cloud service to all subscribers. You can append some more data except message which should be shown to the user.

 @param channel
 \b PNChannel instance to which message should be sent.
 
 @return \b PNMessage instance if message payload is correct or \c nil if not.
 */
- (PNMessage *)sendMessage:(id)message applePushNotification:(NSDictionary *)apnsPayload googleCloudNotification:(NSDictionary *)gcmPayload
                 toChannel:(PNChannel *)channel;

/**
 Send \c message to the \c channel. All messages placed into queue and will be sent in the same order as they were scheduled.
 
 @code
 @endcode
 This method extends \a -sendMessage:applePushNotification:googleCloudNotification:toChannel: and allow to specify message sending processing block.
 
 @code
 @endcode
 \b Example:
 
 @code
 PubNub *pubNub = [PubNub clientWithConfiguration:[PNConfiguration defaultConfiguration] andDelegate:self];
 [pubNub connect];
 [pubNub sendMessage:@{@"array": @[@"of", @"strings"], @"and": @16}
 applePushNotification:@{@"aps":@{@"alert":@"Someone sent array of strings"}} 
 googleCloudNotification:@{@"data":@{@"summary":@"Someone sent array of strings"}}
           toChannel:[PNChannel channelWithName:@"iosdev"]
 withCompletionBlock:^(PNMessageState state, id data) {
 
  switch (state) {
      case PNMessageSending:
 
          // PubNub client is sending message at this moment. 'data' stores reference on PNMessage instance which is processing at this moment.
          break;
      case PNMessageSendingError:
 
          // PubNub client failed to send message and reason is in 'data' object.
          break;
      case PNMessageSent:
 
          // PubNub client successfully sent message to specified channel. 'data' stores reference on PNMessage instance which has been sent.
          break;
      }
 }];
 @endcode
 
 And handle it with delegates:
 @code
 - (void)pubnubClient:(PubNub *)client willSendMessage:(PNMessage *)message {
 
     // PubNub client is sending message at this moment.
 }
 
 - (void)pubnubClient:(PubNub *)client didFailMessageSend:(PNMessage *)message withError:(PNError *)error {
 
     // PubNub client failed to send message and reason is in 'error'.
 }
 
 - (void)pubnubClient:(PubNub *)client didSendMessage:(PNMessage *)message {
 
     // PubNub client successfully sent message to specified channel.
 }
 @endcode
 
 There is also way to observe message processing from any place in your application using  \b PNObservationCenter:
 @code
 [pubNub.observationCenter addMessageProcessingObserver:self
  withBlock:^(PNMessageState state, id data) {
 
  switch (state) {
      case PNMessageSending:
 
          // PubNub client is sending message at this moment. 'data' stores reference on PNMessage instance which is processing at this moment.
          break;
      case PNMessageSendingError:
 
          // PubNub client failed to send message and reason is in 'data' object.
          break;
      case PNMessageSent:
 
          // PubNub client successfully sent message to specified channel. 'data' stores reference on PNMessage instance which has been sent.
          break;
      }
 }];
 @endcode
 
 @param message
 Object which should be sent to the channel. It can be any object which can be serialized into JSON: \c NSString, \c NSNumber, \c NSArray,
 \c NSDictionary.

 @param apnsPayload
 Valid APNS payload dictionary which should be delivered using push service to all subscribers. You can append some more data except message which should be shown to the user.

 @param gcmPayload
 Valid GCM payload dictionary which should be delivered using cloud service to all subscribers. You can append some more data except message which should be shown to the user.

 @param channel
 \b PNChannel instance to which message should be sent.

 @param success
 The block which will be called by \b PubNub client any time when message processing state will be changed. The block takes two arguments:
 \c state - one of \b PNMessageState enumerator fields which tell at which stage message at this moment; \c data - depending on whether message is sending/sent or in state
 of message sending failure it can be one of: \b PNMessage or \b PNError instance.
 
 @return \b PNMessage instance if message payload is correct or \c nil if not.
 */
- (PNMessage *)sendMessage:(id)message applePushNotification:(NSDictionary *)apnsPayload googleCloudNotification:(NSDictionary *)gcmPayload
                 toChannel:(PNChannel *)channel withCompletionBlock:(PNClientMessageProcessingBlock)success;

/**
 Send \c message to the \c channel. All messages placed into queue and will be sent in the same order as they were scheduled.
 
 @code
 @endcode
 This method extends \a -sendMessage:applePushNotification:googleCloudNotification:toChannel: and allow to specify whether message should be stored in history or not.
 
 @code
 @endcode
 \b Example:
 
 @code
 PubNub *pubNub = [PubNub clientWithConfiguration:[PNConfiguration defaultConfiguration] andDelegate:self];
 [pubNub connect];
 [pubNub sendMessage:@{@"array": @[@"of", @"strings"], @"and": @16}
applePushNotification:@{@"aps":@{@"alert":@"Someone sent array of strings"}} 
googleCloudNotification:@{@"data":@{@"summary":@"Someone sent array of strings"}}
           toChannel:[PNChannel channelWithName:@"iosdev"] storeInHistory:NO];
 @endcode
 
 And handle it with delegates:
 @code
 - (void)pubnubClient:(PubNub *)client willSendMessage:(PNMessage *)message {
 
     // PubNub client is sending message at this moment.
 }
 
 - (void)pubnubClient:(PubNub *)client didFailMessageSend:(PNMessage *)message withError:(PNError *)error {
 
     // PubNub client failed to send message and reason is in 'error'.
 }
 
 - (void)pubnubClient:(PubNub *)client didSendMessage:(PNMessage *)message {
 
     // PubNub client successfully sent message to specified channel.
 }
 @endcode
 
 There is also way to observe message processing from any place in your application using  \b PNObservationCenter:
 @code
 [pubNub.observationCenter addMessageProcessingObserver:self
  withBlock:^(PNMessageState state, id data) {
 
  switch (state) {
      case PNMessageSending:
 
          // PubNub client is sending message at this moment. 'data' stores reference on PNMessage instance which is processing at this moment.
          break;
      case PNMessageSendingError:
 
          // PubNub client failed to send message and reason is in 'data' object.
          break;
      case PNMessageSent:
 
          // PubNub client successfully sent message to specified channel. 'data' stores reference on PNMessage instance which has been sent.
          break;
      }
 }];
 @endcode
 
 @param message
 Object which should be sent to the channel. It can be any object which can be serialized into JSON: \c NSString, \c NSNumber, \c NSArray,
 \c NSDictionary.

 @param apnsPayload
 Valid APNS payload dictionary which should be delivered using push service to all subscribers. You can append some more data except message which should be shown to the user.

 @param gcmPayload
 Valid GCM payload dictionary which should be delivered using cloud service to all subscribers. You can append some more data except message which should be shown to the user.
 
 @param channel
 \b PNChannel instance into which message should be sent.
 
 @param shouldStoreInHistory
 \c YES in case if message should be stored on \b PubNub service side and become available with History API.
 
 @return \b PNMessage instance if message payload is correct or \c nil if not.
 */
- (PNMessage *)sendMessage:(id)message applePushNotification:(NSDictionary *)apnsPayload googleCloudNotification:(NSDictionary *)gcmPayload
                 toChannel:(PNChannel *)channel storeInHistory:(BOOL)shouldStoreInHistory;

/**
 Send \c message to the \c channel. All messages placed into queue and will be sent in the same order as they were scheduled.
 
 @code
 @endcode
 This method extends \a -sendMessage:applePushNotification:googleCloudNotification:toChannel:storeInHistory: and allow to specify message sending processing block.
 
 @code
 @endcode
 \b Example:
 
 @code
 PubNub *pubNub = [PubNub clientWithConfiguration:[PNConfiguration defaultConfiguration] andDelegate:self];
 [pubNub connect];
 [pubNub sendMessage:@{@"array": @[@"of", @"strings"], @"and": @16}
applePushNotification:@{@"aps":@{@"alert":@"Someone sent array of strings"}} 
googleCloudNotification:@{@"data":@{@"summary":@"Someone sent array of strings"}}
           toChannel:[PNChannel channelWithName:@"iosdev"] storeInHistory:NO
 withCompletionBlock:^(PNMessageState state, id data) {
 
  switch (state) {
      case PNMessageSending:
 
          // PubNub client is sending message at this moment. 'data' stores reference on PNMessage instance which is processing at this moment.
          break;
      case PNMessageSendingError:
 
          // PubNub client failed to send message and reason is in 'data' object.
          break;
      case PNMessageSent:
 
          // PubNub client successfully sent message to specified channel. 'data' stores reference on PNMessage instance which has been sent.
          break;
      }
 }];
 @endcode
 
 And handle it with delegates:
 @code
 - (void)pubnubClient:(PubNub *)client willSendMessage:(PNMessage *)message {
 
     // PubNub client is sending message at this moment.
 }
 
 - (void)pubnubClient:(PubNub *)client didFailMessageSend:(PNMessage *)message withError:(PNError *)error {
 
     // PubNub client failed to send message and reason is in 'error'.
 }
 
 - (void)pubnubClient:(PubNub *)client didSendMessage:(PNMessage *)message {
 
     // PubNub client successfully sent message to specified channel.
 }
 @endcode
 
 There is also way to observe message processing from any place in your application using  \b PNObservationCenter:
 @code
 [pubNub.observationCenter addMessageProcessingObserver:self
  withBlock:^(PNMessageState state, id data) {
 
  switch (state) {
      case PNMessageSending:
 
          // PubNub client is sending message at this moment. 'data' stores reference on PNMessage instance which is processing at this moment.
          break;
      case PNMessageSendingError:
 
          // PubNub client failed to send message and reason is in 'data' object.
          break;
      case PNMessageSent:
 
          // PubNub client successfully sent message to specified channel. 'data' stores reference on PNMessage instance which has been sent.
          break;
      }
 }];
 @endcode
 
 @param message
 Object which should be sent to the channel. It can be any object which can be serialized into JSON: \c NSString, \c NSNumber, \c NSArray,
 \c NSDictionary.

 @param apnsPayload
 Valid APNS payload dictionary which should be delivered using push service to all subscribers. You can append some more data except message which should be shown to the user.

 @param gcmPayload
 Valid GCM payload dictionary which should be delivered using cloud service to all subscribers. You can append some more data except message which should be shown to the user.
 
 @param channel
 \b PNChannel instance into which message should be sent.
 
 @param shouldStoreInHistory
 \c YES in case if message should be stored on \b PubNub service side and become available with History API.
 
 @param success
 The block which will be called by \b PubNub client any time when message processing state will be changed. The block takes two arguments:
 \c state - one of \b PNMessageState enumerator fields which tell at which stage message at this moment; \c data - depending on whether message is sending/sent or in state
 of message sending failure it can be one of: \b PNMessage or \b PNError instance.
 
 @return \b PNMessage instance if message payload is correct or \c nil if not.
 */
- (PNMessage *)sendMessage:(id)message applePushNotification:(NSDictionary *)apnsPayload googleCloudNotification:(NSDictionary *)gcmPayload
                 toChannel:(PNChannel *)channel storeInHistory:(BOOL)shouldStoreInHistory withCompletionBlock:(PNClientMessageProcessingBlock)success;

/**
 Send \c message to the \c channel. All messages placed into queue and will be sent in the same order as they were scheduled.
 
 @code
 @endcode
 This method extendeds \a -sendMessage:toChannel: and allow to specify whether message should be GZIPed before sending to the \b PubNub service or not.
 
 @code
 @endcode
 \b Example:
 
 @code
 PubNub *pubNub = [PubNub clientWithConfiguration:[PNConfiguration defaultConfiguration] andDelegate:self];
 [pubNub connect];
 [pubNub sendMessage:@{@"array": @[@"of", @"strings"], @"and": @16} toChannel:[PNChannel channelWithName:@"iosdev"] compressed:YES];
 @endcode
 
 And handle it with delegates:
 @code
 - (void)pubnubClient:(PubNub *)client willSendMessage:(PNMessage *)message {
 
     // PubNub client is sending message at this moment.
 }
 
 - (void)pubnubClient:(PubNub *)client didFailMessageSend:(PNMessage *)message withError:(PNError *)error {
 
     // PubNub client failed to send message and reason is in 'error'.
 }
 
 - (void)pubnubClient:(PubNub *)client didSendMessage:(PNMessage *)message {
 
     // PubNub client successfully sent message to specified channel.
 }
 @endcode
 
 There is also way to observe message processing from any place in your application using  \b PNObservationCenter:
 @code
 [pubNub.observationCenter addMessageProcessingObserver:self
  withBlock:^(PNMessageState state, id data) {
 
  switch (state) {
      case PNMessageSending:
 
          // PubNub client is sending message at this moment. 'data' stores reference on PNMessage instance which is processing at this moment.
          break;
      case PNMessageSendingError:
 
          // PubNub client failed to send message and reason is in 'data' object.
          break;
      case PNMessageSent:
 
          // PubNub client successfully sent message to specified channel. 'data' stores reference on PNMessage instance which has been sent.
          break;
      }
 }];
 @endcode
 
 @param message
 Object which should be sent to the channel. It can be any object which can be serialized into JSON: \c NSString, \c NSNumber, \c NSArray,
 \c NSDictionary.
 
 @param channel
 \b PNChannel instance into which message should be sent.
 
 @param shouldCompressMessage
 \c YES will instruct \b PubNub client to compress message before sending it to the target \c channel.
 
 @return \b PNMessage instance if message payload is correct or \c nil if not.
 */
- (PNMessage *)sendMessage:(id)message toChannel:(PNChannel *)channel compressed:(BOOL)shouldCompressMessage;

/**
 Send \c message to the \c channel. All messages placed into queue and will be sent in the same order as they were scheduled.
 
 @code
 @endcode
 This method extendeds \a -sendMessage:toChannel:withCompletionBlock: and allow to specify whether message should be GZIPed before sending to the
 \b PubNub service or not.
 
 @code
 @endcode
 \b Example:
 
 @code
 PubNub *pubNub = [PubNub clientWithConfiguration:[PNConfiguration defaultConfiguration] andDelegate:self];
 [pubNub connect];
 [pubNub sendMessage:@{@"array": @[@"of", @"strings"], @"and": @16} toChannel:[PNChannel channelWithName:@"iosdev"] compressed:YES
 withCompletionBlock:^(PNMessageState state, id data) {
 
  switch (state) {
      case PNMessageSending:
 
          // PubNub client is sending message at this moment. 'data' stores reference on PNMessage instance which is processing at this moment.
          break;
      case PNMessageSendingError:
 
          // PubNub client failed to send message and reason is in 'data' object.
          break;
      case PNMessageSent:
 
          // PubNub client successfully sent message to specified channel. 'data' stores reference on PNMessage instance which has been sent.
          break;
      }
 }];
 @endcode
 
 And handle it with delegates:
 @code
 - (void)pubnubClient:(PubNub *)client willSendMessage:(PNMessage *)message {
 
    // PubNub client is sending message at this moment.
 }
 
 - (void)pubnubClient:(PubNub *)client didFailMessageSend:(PNMessage *)message withError:(PNError *)error {
 
    // PubNub client failed to send message and reason is in 'error'.
 }
 
 - (void)pubnubClient:(PubNub *)client didSendMessage:(PNMessage *)message {
 
    // PubNub client successfully sent message to specified channel.
 }
 @endcode
 
 There is also way to observe message processing from any place in your application using  \b PNObservationCenter:
 @code
 [pubNub.observationCenter addMessageProcessingObserver:self withBlock:^(PNMessageState state, id data) {
 
    switch (state) {
        case PNMessageSending:
 
            // PubNub client is sending message at this moment. 'data' stores reference on PNMessage instance which is processing at this moment.
            break;
    case PNMessageSendingError:
 
            // PubNub client failed to send message and reason is in 'data' object.
            break;
    case PNMessageSent:
 
            // PubNub client successfully sent message to specified channel. 'data' stores reference on PNMessage instance which has been sent.
            break;
    }
 }];
 @endcode
 
 @param message
 Object which should be sent to the channel. It can be any object which can be serialized into JSON: \c NSString, \c NSNumber, \c NSArray,
 \c NSDictionary.
 
 @param channel
 \b PNChannel instance into which message should be sent.
 
 @param shouldCompressMessage
 \c YES will instruct \b PubNub client to compress message before sending it to the target \c channel.
 
 @param success
 The block which will be called by \b PubNub client any time when message processing state will be changed. The block takes two arguments:
 \c state - one of \b PNMessageState enumerator fields which tell at which stage message at this moment; \c data - depending on whether message is sending/sent or in state
 of message sending failure it can be one of: \b PNMessage or \b PNError instance.
 
 @return \b PNMessage instance if message payload is correct or \c nil if not.
 */
- (PNMessage *)sendMessage:(id)message toChannel:(PNChannel *)channel compressed:(BOOL)shouldCompressMessage
       withCompletionBlock:(PNClientMessageProcessingBlock)success;

/**
 Send \c message to the \c channel. All messages placed into queue and will be sent in the same order as they were scheduled.
 @code
 @endcode
 This method extendeds \a -sendMessage:toChannel:compressed: and allow to specify whether message should be stored in history or not.
 
 @code
 @endcode
 \b Example:
 
 @code
 PubNub *pubNub = [PubNub clientWithConfiguration:[PNConfiguration defaultConfiguration] andDelegate:self];
 [pubNub connect];
 [pubNub sendMessage:@{@"array": @[@"of", @"strings"], @"and": @16} toChannel:[PNChannel channelWithName:@"iosdev"]
          compressed:YES storeInHistory:NO];
 @endcode
 
 And handle it with delegates:
 @code
 - (void)pubnubClient:(PubNub *)client willSendMessage:(PNMessage *)message {
 
     // PubNub client is sending message at this moment.
 }
 
 - (void)pubnubClient:(PubNub *)client didFailMessageSend:(PNMessage *)message withError:(PNError *)error {
 
     // PubNub client failed to send message and reason is in 'error'.
 }
 
 - (void)pubnubClient:(PubNub *)client didSendMessage:(PNMessage *)message {
 
     // PubNub client successfully sent message to specified channel.
 }
 @endcode
 
 There is also way to observe message processing from any place in your application using  \b PNObservationCenter:
 @code
 [pubNub.observationCenter addMessageProcessingObserver:self
  withBlock:^(PNMessageState state, id data) {
 
  switch (state) {
      case PNMessageSending:
 
          // PubNub client is sending message at this moment. 'data' stores reference on PNMessage instance which is processing at this moment.
          break;
      case PNMessageSendingError:
 
          // PubNub client failed to send message and reason is in 'data' object.
          break;
      case PNMessageSent:
 
          // PubNub client successfully sent message to specified channel. 'data' stores reference on PNMessage instance which has been sent.
          break;
      }
 }];
 @endcode
 
 @param message
 Object which should be sent to the channel. It can be any object which can be serialized into JSON: \c NSString, \c NSNumber, \c NSArray,
 \c NSDictionary.
 
 @param channel
 \b PNChannel instance into which message should be sent.
 
 @param shouldCompressMessage
 \c YES in case if message should be compressed before sending to the PubNub service.
 
 @param shouldStoreInHistory
 \c YES in case if message should be stored on \b PubNub service side and become available with History API.
 
 @return \b PNMessage instance if message payload is correct or \c nil if not.
 */
- (PNMessage *)sendMessage:(id)message toChannel:(PNChannel *)channel compressed:(BOOL)shouldCompressMessage storeInHistory:(BOOL)shouldStoreInHistory;

/**
 Send \c message to the \c channel. All messages placed into queue and will be sent in the same order as they were scheduled.
 
 @code
 @endcode
 This method extendeds \a -sendMessage:toChannel:compressed:withCompletionBlock: and allow to specify whether message should be stored in history or not.
 
 @code
 @endcode
 \b Example:
 
 @code
 PubNub *pubNub = [PubNub clientWithConfiguration:[PNConfiguration defaultConfiguration] andDelegate:self];
 [pubNub connect];
 [pubNub sendMessage:@{@"array": @[@"of", @"strings"], @"and": @16} toChannel:[PNChannel channelWithName:@"iosdev"] compressed:YES
      storeInHistory:NO withCompletionBlock:^(PNMessageState state, id data) {
 
  switch (state) {
      case PNMessageSending:
 
          // PubNub client is sending message at this moment. 'data' stores reference on PNMessage instance which is processing at this moment.
          break;
      case PNMessageSendingError:
 
          // PubNub client failed to send message and reason is in 'data' object.
          break;
      case PNMessageSent:
 
          // PubNub client successfully sent message to specified channel. 'data' stores reference on PNMessage instance which has been sent.
          break;
      }
 }];
 @endcode
 
 And handle it with delegates:
 @code
 - (void)pubnubClient:(PubNub *)client willSendMessage:(PNMessage *)message {
 
    // PubNub client is sending message at this moment.
 }
 
 - (void)pubnubClient:(PubNub *)client didFailMessageSend:(PNMessage *)message withError:(PNError *)error {
 
    // PubNub client failed to send message and reason is in 'error'.
 }
 
 - (void)pubnubClient:(PubNub *)client didSendMessage:(PNMessage *)message {
 
    // PubNub client successfully sent message to specified channel.
 }
 @endcode
 
 There is also way to observe message processing from any place in your application using  \b PNObservationCenter:
 @code
 [pubNub.observationCenter addMessageProcessingObserver:self withBlock:^(PNMessageState state, id data) {
 
    switch (state) {
        case PNMessageSending:
 
            // PubNub client is sending message at this moment. 'data' stores reference on PNMessage instance which is processing at this moment.
            break;
    case PNMessageSendingError:
 
            // PubNub client failed to send message and reason is in 'data' object.
            break;
    case PNMessageSent:
 
            // PubNub client successfully sent message to specified channel. 'data' stores reference on PNMessage instance which has been sent.
            break;
    }
 }];
 @endcode
 
 @param message
 Object which should be sent to the channel. It can be any object which can be serialized into JSON: \c NSString, \c NSNumber, \c NSArray,
 \c NSDictionary.
 
 @param channel
 \b PNChannel instance into which message should be sent.
 
 @param shouldCompressMessage
 \c YES in case if message should be compressed before sending to the PubNub service.
 
 @param shouldStoreInHistory
 \c YES in case if message should be stored on \b PubNub service side and become available with History API.
 
 @return \b PNMessage instance if message payload is correct or \c nil if not.
 */
- (PNMessage *)sendMessage:(id)message toChannel:(PNChannel *)channel compressed:(BOOL)shouldCompressMessage storeInHistory:(BOOL)shouldStoreInHistory
       withCompletionBlock:(PNClientMessageProcessingBlock)success;

/**
 Send \c message to the \c channel. All messages placed into queue and will be sent in the same order as they were scheduled.
 
 @code
 @endcode
 This method extends \a +sendMessage:applePushNotification:toChannel: and allow to specify whether message should be GZIPed before sending to the \b PubNub service or not.
 
 @code
 @endcode
 \b Example:
 
 @code
 PubNub *pubNub = [PubNub clientWithConfiguration:[PNConfiguration defaultConfiguration] andDelegate:self];
 [pubNub connect];
 [pubNub sendMessage:@{@"array": @[@"of", @"strings"], @"and": @16}
 applePushNotification:@{@"aps":@{@"alert":@"Someone sent array of strings"}} 
           toChannel:[PNChannel channelWithName:@"iosdev"] compressed:NO];
 @endcode
 
 And handle it with delegates:
 @code
 - (void)pubnubClient:(PubNub *)client willSendMessage:(PNMessage *)message {
 
     // PubNub client is sending message at this moment.
 }
 
 - (void)pubnubClient:(PubNub *)client didFailMessageSend:(PNMessage *)message withError:(PNError *)error {
 
     // PubNub client failed to send message and reason is in 'error'.
 }
 
 - (void)pubnubClient:(PubNub *)client didSendMessage:(PNMessage *)message {
 
     // PubNub client successfully sent message to specified channel.
 }
 @endcode
 
 There is also way to observe message processing from any place in your application using  \b PNObservationCenter:
 @code
 [pubNub.observationCenter addMessageProcessingObserver:self withBlock:^(PNMessageState state, id data) {
 
  switch (state) {
      case PNMessageSending:
 
          // PubNub client is sending message at this moment. 'data' stores reference on PNMessage instance which is processing at this moment.
          break;
      case PNMessageSendingError:
 
          // PubNub client failed to send message and reason is in 'data' object.
          break;
      case PNMessageSent:
 
          // PubNub client successfully sent message to specified channel. 'data' stores reference on PNMessage instance which has been sent.
          break;
      }
 }];
 @endcode
 
 @param message
 Object which should be sent to the channel. It can be any object which can be serialized into JSON: \c NSString, \c NSNumber, \c NSArray,
 \c NSDictionary.

 @param apnsPayload
 Valid APNS payload dictionary which should be delivered using push service to all subscribers. You can append some more data except message which should be shown to the user.

 @param channel
 \b PNChannel instance to which message should be sent.
 
 @param shouldCompressMessage
 \c YES will instruct \b PubNub client to compress message before sending it to the target \c channel.
 
 @return \b PNMessage instance if message payload is correct or \c nil if not.
 */
- (PNMessage *)sendMessage:(id)message applePushNotification:(NSDictionary *)apnsPayload toChannel:(PNChannel *)channel
                compressed:(BOOL)shouldCompressMessage;

/**
 Send \c message to the \c channel. All messages placed into queue and will be sent in the same order as they were scheduled.
 
 @code
 @endcode
 This method extends \a -sendMessage:applePushNotification:toChannel:compressed: and allow to specify message sending processing block.
 
 @code
 @endcode
 \b Example:
 
 @code
 PubNub *pubNub = [PubNub clientWithConfiguration:[PNConfiguration defaultConfiguration] andDelegate:self];
 [pubNub connect];
 [pubNub sendMessage:@{@"array": @[@"of", @"strings"], @"and": @16}
 applePushNotification:@{@"aps":@{@"alert":@"Someone sent array of strings"}} 
           toChannel:[PNChannel channelWithName:@"iosdev"] compressed:NO];
 @endcode
 
 And handle it with delegates:
 @code
 - (void)pubnubClient:(PubNub *)client willSendMessage:(PNMessage *)message {
 
     // PubNub client is sending message at this moment.
 }
 
 - (void)pubnubClient:(PubNub *)client didFailMessageSend:(PNMessage *)message withError:(PNError *)error {
 
     // PubNub client failed to send message and reason is in 'error'.
 }
 
 - (void)pubnubClient:(PubNub *)client didSendMessage:(PNMessage *)message {
 
     // PubNub client successfully sent message to specified channel.
 }
 @endcode
 
 There is also way to observe message processing from any place in your application using  \b PNObservationCenter:
 @code
 [pubNub.observationCenter addMessageProcessingObserver:self withBlock:^(PNMessageState state, id data) {
 
  switch (state) {
      case PNMessageSending:
 
          // PubNub client is sending message at this moment. 'data' stores reference on PNMessage instance which is processing at this moment.
          break;
      case PNMessageSendingError:
 
          // PubNub client failed to send message and reason is in 'data' object.
          break;
      case PNMessageSent:
 
          // PubNub client successfully sent message to specified channel. 'data' stores reference on PNMessage instance which has been sent.
          break;
      }
 }];
 @endcode
 
 @param message
 Object which should be sent to the channel. It can be any object which can be serialized into JSON: \c NSString, \c NSNumber, \c NSArray,
 \c NSDictionary.

 @param apnsPayload
 Valid APNS payload dictionary which should be delivered using push service to all subscribers. You can append some more data except message which should be shown to the user.

 @param channel
 \b PNChannel instance to which message should be sent.
 
 @param shouldCompressMessage
 \c YES will instruct \b PubNub client to compress message before sending it to the target \c channel.

 @param success
 The block which will be called by \b PubNub client any time when message processing state will be changed. The block takes two arguments:
 \c state - one of \b PNMessageState enumerator fields which tell at which stage message at this moment; \c data - depending on whether message is sending/sent or in state
 of message sending failure it can be one of: \b PNMessage or \b PNError instance.
 
 @return \b PNMessage instance if message payload is correct or \c nil if not.
 */
- (PNMessage *)sendMessage:(id)message applePushNotification:(NSDictionary *)apnsPayload toChannel:(PNChannel *)channel
                compressed:(BOOL)shouldCompressMessage withCompletionBlock:(PNClientMessageProcessingBlock)success;

/**
 Send \c message to the \c channel. All messages placed into queue and will be sent in the same order as they were scheduled.
 
 @code
 @endcode
 This method extends \a -sendMessage:applePushNotification:toChannel:compressed: and allow to specify whether message should be stored in history or not.
 
 @code
 @endcode
 \b Example:
 
 @code
 PubNub *pubNub = [PubNub clientWithConfiguration:[PNConfiguration defaultConfiguration] andDelegate:self];
 [pubNub connect];
 [pubNub sendMessage:@{@"array": @[@"of", @"strings"], @"and": @16}
applePushNotification:@{@"aps":@{@"alert":@"Someone sent array of strings"}} 
           toChannel:[PNChannel channelWithName:@"iosdev"] compressed:NO storeInHistory:YES];
 @endcode
 
 And handle it with delegates:
 @code
 - (void)pubnubClient:(PubNub *)client willSendMessage:(PNMessage *)message {
 
     // PubNub client is sending message at this moment.
 }
 
 - (void)pubnubClient:(PubNub *)client didFailMessageSend:(PNMessage *)message withError:(PNError *)error {
 
     // PubNub client failed to send message and reason is in 'error'.
 }
 
 - (void)pubnubClient:(PubNub *)client didSendMessage:(PNMessage *)message {
 
     // PubNub client successfully sent message to specified channel.
 }
 @endcode
 
 There is also way to observe message processing from any place in your application using  \b PNObservationCenter:
 @code
 [pubNub.observationCenter addMessageProcessingObserver:self withBlock:^(PNMessageState state, id data) {
 
  switch (state) {
      case PNMessageSending:
 
          // PubNub client is sending message at this moment. 'data' stores reference on PNMessage instance which is processing at this moment.
          break;
      case PNMessageSendingError:
 
          // PubNub client failed to send message and reason is in 'data' object.
          break;
      case PNMessageSent:
 
          // PubNub client successfully sent message to specified channel. 'data' stores reference on PNMessage instance which has been sent.
          break;
      }
 }];
 @endcode
 
 @param message
 Object which should be sent to the channel. It can be any object which can be serialized into JSON: \c NSString, \c NSNumber, \c NSArray,
 \c NSDictionary.

 @param apnsPayload
 Valid APNS payload dictionary which should be delivered using push service to all subscribers. You can append some more data except message which should be shown to the user.
 
 @param channel
 \b PNChannel instance into which message should be sent.
 
 @param shouldCompressMessage
 \c YES will instruct \b PubNub client to compress message before sending it to the target \c channel.
 
 @param shouldStoreInHistory
 \c YES in case if message should be stored on \b PubNub service side and become available with History API.
 
 @return \b PNMessage instance if message payload is correct or \c nil if not.
 */
- (PNMessage *)sendMessage:(id)message applePushNotification:(NSDictionary *)apnsPayload toChannel:(PNChannel *)channel
                compressed:(BOOL)shouldCompressMessage storeInHistory:(BOOL)shouldStoreInHistory;

/**
 Send \c message to the \c channel. All messages placed into queue and will be sent in the same order as they were scheduled.
 
 @code
 @endcode
 This method extends \a -sendMessage:applePushNotification:toChannel:compressed:storeInHistory: and allow to specify message sending processing block.
 
 @code
 @endcode
 \b Example:
 
 @code
 PubNub *pubNub = [PubNub clientWithConfiguration:[PNConfiguration defaultConfiguration] andDelegate:self];
 [pubNub connect];
 [pubNub sendMessage:@{@"array": @[@"of", @"strings"], @"and": @16}
applePushNotification:@{@"aps":@{@"alert":@"Someone sent array of strings"}} 
           toChannel:[PNChannel channelWithName:@"iosdev"] compressed:NO storeInHistory:NO
 withCompletionBlock:^(PNMessageState state, id data) {
 
  switch (state) {
      case PNMessageSending:
 
          // PubNub client is sending message at this moment. 'data' stores reference on PNMessage instance which is processing at this moment.
          break;
      case PNMessageSendingError:
 
          // PubNub client failed to send message and reason is in 'data' object.
          break;
      case PNMessageSent:
 
          // PubNub client successfully sent message to specified channel. 'data' stores reference on PNMessage instance which has been sent.
          break;
      }
 }];
 @endcode
 
 And handle it with delegates:
 @code
 - (void)pubnubClient:(PubNub *)client willSendMessage:(PNMessage *)message {
 
     // PubNub client is sending message at this moment.
 }
 
 - (void)pubnubClient:(PubNub *)client didFailMessageSend:(PNMessage *)message withError:(PNError *)error {
 
     // PubNub client failed to send message and reason is in 'error'.
 }
 
 - (void)pubnubClient:(PubNub *)client didSendMessage:(PNMessage *)message {
 
     // PubNub client successfully sent message to specified channel.
 }
 @endcode
 
 There is also way to observe message processing from any place in your application using  \b PNObservationCenter:
 @code
 [pubNub.observationCenter addMessageProcessingObserver:self withBlock:^(PNMessageState state, id data) {
 
  switch (state) {
      case PNMessageSending:
 
          // PubNub client is sending message at this moment. 'data' stores reference on PNMessage instance which is processing at this moment.
          break;
      case PNMessageSendingError:
 
          // PubNub client failed to send message and reason is in 'data' object.
          break;
      case PNMessageSent:
 
          // PubNub client successfully sent message to specified channel. 'data' stores reference on PNMessage instance which has been sent.
          break;
      }
 }];
 @endcode
 
 @param message
 Object which should be sent to the channel. It can be any object which can be serialized into JSON: \c NSString, \c NSNumber, \c NSArray,
 \c NSDictionary.

 @param apnsPayload
 Valid APNS payload dictionary which should be delivered using push service to all subscribers. You can append some more data except message which should be shown to the user.
 
 @param channel
 \b PNChannel instance into which message should be sent.
 
 @param shouldCompressMessage
 \c YES will instruct \b PubNub client to compress message before sending it to the target \c channel.
 
 @param shouldStoreInHistory
 \c YES in case if message should be stored on \b PubNub service side and become available with History API.
 
 @param success
 The block which will be called by \b PubNub client any time when message processing state will be changed. The block takes two arguments:
 \c state - one of \b PNMessageState enumerator fields which tell at which stage message at this moment; \c data - depending on whether message is sending/sent or in state
 of message sending failure it can be one of: \b PNMessage or \b PNError instance.
 
 @return \b PNMessage instance if message payload is correct or \c nil if not.
 */
- (PNMessage *)sendMessage:(id)message applePushNotification:(NSDictionary *)apnsPayload toChannel:(PNChannel *)channel
                compressed:(BOOL)shouldCompressMessage storeInHistory:(BOOL)shouldStoreInHistory 
       withCompletionBlock:(PNClientMessageProcessingBlock)success;

/**
 Send \c message to the \c channel. All messages placed into queue and will be sent in the same order as they were scheduled.
 
 @code
 @endcode
 This method extends \a -sendMessage:googleCloudNotification:toChannel: and allow to specify whether message should be GZIPed before sending to the \b PubNub service or not.
 
 @code
 @endcode
 \b Example:
 
 @code
 PubNub *pubNub = [PubNub clientWithConfiguration:[PNConfiguration defaultConfiguration] andDelegate:self];
 [pubNub connect];
 [pubNub sendMessage:@{@"array": @[@"of", @"strings"], @"and": @16}
 googleCloudNotification:@{@"data":@{@"summary":@"Someone sent array of strings"}}
           toChannel:[PNChannel channelWithName:@"iosdev"] compressed:NO];
 @endcode
 
 And handle it with delegates:
 @code
 - (void)pubnubClient:(PubNub *)client willSendMessage:(PNMessage *)message {
 
     // PubNub client is sending message at this moment.
 }
 
 - (void)pubnubClient:(PubNub *)client didFailMessageSend:(PNMessage *)message withError:(PNError *)error {
 
     // PubNub client failed to send message and reason is in 'error'.
 }
 
 - (void)pubnubClient:(PubNub *)client didSendMessage:(PNMessage *)message {
 
     // PubNub client successfully sent message to specified channel.
 }
 @endcode
 
 There is also way to observe message processing from any place in your application using  \b PNObservationCenter:
 @code
 [pubNub.observationCenter addMessageProcessingObserver:self withBlock:^(PNMessageState state, id data) {
 
  switch (state) {
      case PNMessageSending:
 
          // PubNub client is sending message at this moment. 'data' stores reference on PNMessage instance which is processing at this moment.
          break;
      case PNMessageSendingError:
 
          // PubNub client failed to send message and reason is in 'data' object.
          break;
      case PNMessageSent:
 
          // PubNub client successfully sent message to specified channel. 'data' stores reference on PNMessage instance which has been sent.
          break;
      }
 }];
 @endcode
 
 @param message
 Object which should be sent to the channel. It can be any object which can be serialized into JSON: \c NSString, \c NSNumber, \c NSArray,
 \c NSDictionary.

 @param gcmPayload
 Valid GCM payload dictionary which should be delivered using cloud service to all subscribers. You can append some more data except message which should be shown to the user.

 @param channel
 \b PNChannel instance to which message should be sent.

 @param shouldCompressMessage
 If set to \c YES \b PubNub client will sent it in GZIPed form.
 
 @return \b PNMessage instance if message payload is correct or \c nil if not.
 */
- (PNMessage *)sendMessage:(id)message googleCloudNotification:(NSDictionary *)gcmPayload toChannel:(PNChannel *)channel compressed:(BOOL)shouldCompressMessage;

/**
 Send \c message to the \c channel. All messages placed into queue and will be sent in the same order as they were scheduled.
 
 @code
 @endcode
 This method extends \a -sendMessage:googleCloudNotification:toChannel:compressed: and allow to specify message sending processing block.
 
 @code
 @endcode
 \b Example:
 
 @code
 PubNub *pubNub = [PubNub clientWithConfiguration:[PNConfiguration defaultConfiguration] andDelegate:self];
 [pubNub connect];
 [pubNub sendMessage:@{@"array": @[@"of", @"strings"], @"and": @16}
 googleCloudNotification:@{@"data":@{@"summary":@"Someone sent array of strings"}}
           toChannel:[PNChannel channelWithName:@"iosdev"] compressed:NO];
 @endcode
 
 And handle it with delegates:
 @code
 - (void)pubnubClient:(PubNub *)client willSendMessage:(PNMessage *)message {
 
     // PubNub client is sending message at this moment.
 }
 
 - (void)pubnubClient:(PubNub *)client didFailMessageSend:(PNMessage *)message withError:(PNError *)error {
 
     // PubNub client failed to send message and reason is in 'error'.
 }
 
 - (void)pubnubClient:(PubNub *)client didSendMessage:(PNMessage *)message {
 
     // PubNub client successfully sent message to specified channel.
 }
 @endcode
 
 There is also way to observe message processing from any place in your application using  \b PNObservationCenter:
 @code
 [pubNub.observationCenter addMessageProcessingObserver:self withBlock:^(PNMessageState state, id data) {
 
  switch (state) {
      case PNMessageSending:
 
          // PubNub client is sending message at this moment. 'data' stores reference on PNMessage instance which is processing at this moment.
          break;
      case PNMessageSendingError:
 
          // PubNub client failed to send message and reason is in 'data' object.
          break;
      case PNMessageSent:
 
          // PubNub client successfully sent message to specified channel. 'data' stores reference on PNMessage instance which has been sent.
          break;
      }
 }];
 @endcode
 
 @param message
 Object which should be sent to the channel. It can be any object which can be serialized into JSON: \c NSString, \c NSNumber, \c NSArray,
 \c NSDictionary.

 @param gcmPayload
 Valid GCM payload dictionary which should be delivered using cloud service to all subscribers. You can append some more data except message which should be shown to the user.

 @param channel
 \b PNChannel instance to which message should be sent.

 @param shouldCompressMessage
 If set to \c YES \b PubNub client will sent it in GZIPed form.

 @param success
 The block which will be called by \b PubNub client any time when message processing state will be changed. The block takes two arguments:
 \c state - one of \b PNMessageState enumerator fields which tell at which stage message at this moment; \c data - depending on whether message is sending/sent or in state
 of message sending failure it can be one of: \b PNMessage or \b PNError instance.
 
 @return \b PNMessage instance if message payload is correct or \c nil if not.
 */
- (PNMessage *)sendMessage:(id)message googleCloudNotification:(NSDictionary *)gcmPayload toChannel:(PNChannel *)channel
                compressed:(BOOL)shouldCompressMessage withCompletionBlock:(PNClientMessageProcessingBlock)success;

/**
 Send \c message to the \c channel. All messages placed into queue and will be sent in the same order as they were scheduled.
 
 @code
 @endcode
 This method extends \a -sendMessage:googleCloudNotification:toChannel:compressed: and allow to specify whether message should be stored in history or not.
 
 @code
 @endcode
 \b Example:
 
 @code
 PubNub *pubNub = [PubNub clientWithConfiguration:[PNConfiguration defaultConfiguration] andDelegate:self];
 [pubNub connect];
 [pubNub sendMessage:@{@"array": @[@"of", @"strings"], @"and": @16}
googleCloudNotification:@{@"data":@{@"summary":@"Someone sent array of strings"}}
           toChannel:[PNChannel channelWithName:@"iosdev"] compressed:NO storeInHistory:YES];
 @endcode
 
 And handle it with delegates:
 @code
 - (void)pubnubClient:(PubNub *)client willSendMessage:(PNMessage *)message {
 
     // PubNub client is sending message at this moment.
 }
 
 - (void)pubnubClient:(PubNub *)client didFailMessageSend:(PNMessage *)message withError:(PNError *)error {
 
     // PubNub client failed to send message and reason is in 'error'.
 }
 
 - (void)pubnubClient:(PubNub *)client didSendMessage:(PNMessage *)message {
 
     // PubNub client successfully sent message to specified channel.
 }
 @endcode
 
 There is also way to observe message processing from any place in your application using  \b PNObservationCenter:
 @code
 [pubNub.observationCenter addMessageProcessingObserver:self withBlock:^(PNMessageState state, id data) {
 
  switch (state) {
      case PNMessageSending:
 
          // PubNub client is sending message at this moment. 'data' stores reference on PNMessage instance which is processing at this moment.
          break;
      case PNMessageSendingError:
 
          // PubNub client failed to send message and reason is in 'data' object.
          break;
      case PNMessageSent:
 
          // PubNub client successfully sent message to specified channel. 'data' stores reference on PNMessage instance which has been sent.
          break;
      }
 }];
 @endcode
 
 @param message
 Object which should be sent to the channel. It can be any object which can be serialized into JSON: \c NSString, \c NSNumber, \c NSArray,
 \c NSDictionary.

 @param gcmPayload
 Valid GCM payload dictionary which should be delivered using cloud service to all subscribers. You can append some more data except message which should be shown to the user.
 
 @param channel
 \b PNChannel instance into which message should be sent.
 
 @param shouldCompressMessage
 \c YES will instruct \b PubNub client to compress message before sending it to the target \c channel.
 
 @param shouldStoreInHistory
 \c YES in case if message should be stored on \b PubNub service side and become available with History API.
 
 @return \b PNMessage instance if message payload is correct or \c nil if not.
 */
- (PNMessage *)sendMessage:(id)message googleCloudNotification:(NSDictionary *)gcmPayload toChannel:(PNChannel *)channel
                compressed:(BOOL)shouldCompressMessage storeInHistory:(BOOL)shouldStoreInHistory;

/**
 Send \c message to the \c channel. All messages placed into queue and will be sent in the same order as they were scheduled.
 
 @code
 @endcode
 This method extends \a -sendMessage:googleCloudNotification:toChannel:compressed:storeInHistory: and allow to specify message sending processing block.
 
 @code
 @endcode
 \b Example:
 
 @code
 PubNub *pubNub = [PubNub clientWithConfiguration:[PNConfiguration defaultConfiguration] andDelegate:self];
 [pubNub connect];
 [pubNub sendMessage:@{@"array": @[@"of", @"strings"], @"and": @16}
googleCloudNotification:@{@"data":@{@"summary":@"Someone sent array of strings"}}
           toChannel:[PNChannel channelWithName:@"iosdev"] compressed:NO storeInHistory:NO
 withCompletionBlock:^(PNMessageState state, id data) {
 
  switch (state) {
      case PNMessageSending:
 
          // PubNub client is sending message at this moment. 'data' stores reference on PNMessage instance which is processing at this moment.
          break;
      case PNMessageSendingError:
 
          // PubNub client failed to send message and reason is in 'data' object.
          break;
      case PNMessageSent:
 
          // PubNub client successfully sent message to specified channel. 'data' stores reference on PNMessage instance which has been sent.
          break;
      }
 }];
 @endcode
 
 And handle it with delegates:
 @code
 - (void)pubnubClient:(PubNub *)client willSendMessage:(PNMessage *)message {
 
     // PubNub client is sending message at this moment.
 }
 
 - (void)pubnubClient:(PubNub *)client didFailMessageSend:(PNMessage *)message withError:(PNError *)error {
 
     // PubNub client failed to send message and reason is in 'error'.
 }
 
 - (void)pubnubClient:(PubNub *)client didSendMessage:(PNMessage *)message {
 
     // PubNub client successfully sent message to specified channel.
 }
 @endcode
 
 There is also way to observe message processing from any place in your application using  \b PNObservationCenter:
 @code
 [pubNub.observationCenter addMessageProcessingObserver:self withBlock:^(PNMessageState state, id data) {
 
  switch (state) {
      case PNMessageSending:
 
          // PubNub client is sending message at this moment. 'data' stores reference on PNMessage instance which is processing at this moment.
          break;
      case PNMessageSendingError:
 
          // PubNub client failed to send message and reason is in 'data' object.
          break;
      case PNMessageSent:
 
          // PubNub client successfully sent message to specified channel. 'data' stores reference on PNMessage instance which has been sent.
          break;
      }
 }];
 @endcode
 
 @param message
 Object which should be sent to the channel. It can be any object which can be serialized into JSON: \c NSString, \c NSNumber, \c NSArray,
 \c NSDictionary.

 @param gcmPayload
 Valid GCM payload dictionary which should be delivered using cloud service to all subscribers. You can append some more data except message which should be shown to the user.
 
 @param channel
 \b PNChannel instance into which message should be sent.
 
 @param shouldCompressMessage
 \c YES will instruct \b PubNub client to compress message before sending it to the target \c channel.
 
 @param shouldStoreInHistory
 \c YES in case if message should be stored on \b PubNub service side and become available with History API.
 
 @param success
 The block which will be called by \b PubNub client any time when message processing state will be changed. The block takes two arguments:
 \c state - one of \b PNMessageState enumerator fields which tell at which stage message at this moment; \c data - depending on whether message is sending/sent or in state
 of message sending failure it can be one of: \b PNMessage or \b PNError instance.
 
 @return \b PNMessage instance if message payload is correct or \c nil if not.
 */
- (PNMessage *)sendMessage:(id)message googleCloudNotification:(NSDictionary *)gcmPayload toChannel:(PNChannel *)channel
                compressed:(BOOL)shouldCompressMessage storeInHistory:(BOOL)shouldStoreInHistory 
       withCompletionBlock:(PNClientMessageProcessingBlock)success;

/**
 Send \c message to the \c channel. All messages placed into queue and will be sent in the same order as they were scheduled.
 
 @code
 @endcode
 This method extends \a -sendMessage:applePushNotification:googleCloudNotification:toChannel: and allow to specify whether message should be GZIPed before sending to the \b PubNub service or not.
 
 @code
 @endcode
 \b Example:
 
 @code
 PubNub *pubNub = [PubNub clientWithConfiguration:[PNConfiguration defaultConfiguration] andDelegate:self];
 [pubNub connect];
 [pubNub sendMessage:@{@"array": @[@"of", @"strings"], @"and": @16}
 applePushNotification:@{@"aps":@{@"alert":@"Someone sent array of strings"}} 
 googleCloudNotification:@{@"data":@{@"summary":@"Someone sent array of strings"}}
           toChannel:[PNChannel channelWithName:@"iosdev"] compressed:NO];
 @endcode
 
 And handle it with delegates:
 @code
 - (void)pubnubClient:(PubNub *)client willSendMessage:(PNMessage *)message {
 
     // PubNub client is sending message at this moment.
 }
 
 - (void)pubnubClient:(PubNub *)client didFailMessageSend:(PNMessage *)message withError:(PNError *)error {
 
     // PubNub client failed to send message and reason is in 'error'.
 }
 
 - (void)pubnubClient:(PubNub *)client didSendMessage:(PNMessage *)message {
 
     // PubNub client successfully sent message to specified channel.
 }
 @endcode
 
 There is also way to observe message processing from any place in your application using  \b PNObservationCenter:
 @code
 [pubNub.observationCenter addMessageProcessingObserver:self withBlock:^(PNMessageState state, id data) {
 
  switch (state) {
      case PNMessageSending:
 
          // PubNub client is sending message at this moment. 'data' stores reference on PNMessage instance which is processing at this moment.
          break;
      case PNMessageSendingError:
 
          // PubNub client failed to send message and reason is in 'data' object.
          break;
      case PNMessageSent:
 
          // PubNub client successfully sent message to specified channel. 'data' stores reference on PNMessage instance which has been sent.
          break;
      }
 }];
 @endcode
 
 @param message
 Object which should be sent to the channel. It can be any object which can be serialized into JSON: \c NSString, \c NSNumber, \c NSArray,
 \c NSDictionary.

 @param apnsPayload
 Valid APNS payload dictionary which should be delivered using push service to all subscribers. You can append some more data except message which should be shown to the user.

 @param gcmPayload
 Valid GCM payload dictionary which should be delivered using cloud service to all subscribers. You can append some more data except message which should be shown to the user.

 @param channel
 \b PNChannel instance to which message should be sent.

 @param shouldCompressMessage
 If set to \c YES \b PubNub client will sent it in GZIPed form.
 
 @return \b PNMessage instance if message payload is correct or \c nil if not.
 */
- (PNMessage *)sendMessage:(id)message applePushNotification:(NSDictionary *)apnsPayload googleCloudNotification:(NSDictionary *)gcmPayload
                 toChannel:(PNChannel *)channel compressed:(BOOL)shouldCompressMessage;

/**
 Send \c message to the \c channel. All messages placed into queue and will be sent in the same order as they were scheduled.
 
 @code
 @endcode
 This method extends \a -sendMessage:applePushNotification:googleCloudNotification:toChannel:compressed: and allow to specify message sending processing block.
 
 @code
 @endcode
 \b Example:
 
 @code
 PubNub *pubNub = [PubNub clientWithConfiguration:[PNConfiguration defaultConfiguration] andDelegate:self];
 [pubNub connect];
 [pubNub sendMessage:@{@"array": @[@"of", @"strings"], @"and": @16}
 applePushNotification:@{@"aps":@{@"alert":@"Someone sent array of strings"}} 
 googleCloudNotification:@{@"data":@{@"summary":@"Someone sent array of strings"}}
           toChannel:[PNChannel channelWithName:@"iosdev"] compressed:NO];
 @endcode
 
 And handle it with delegates:
 @code
 - (void)pubnubClient:(PubNub *)client willSendMessage:(PNMessage *)message {
 
     // PubNub client is sending message at this moment.
 }
 
 - (void)pubnubClient:(PubNub *)client didFailMessageSend:(PNMessage *)message withError:(PNError *)error {
 
     // PubNub client failed to send message and reason is in 'error'.
 }
 
 - (void)pubnubClient:(PubNub *)client didSendMessage:(PNMessage *)message {
 
     // PubNub client successfully sent message to specified channel.
 }
 @endcode
 
 There is also way to observe message processing from any place in your application using  \b PNObservationCenter:
 @code
 [pubNub.observationCenter addMessageProcessingObserver:self withBlock:^(PNMessageState state, id data) {
 
  switch (state) {
      case PNMessageSending:
 
          // PubNub client is sending message at this moment. 'data' stores reference on PNMessage instance which is processing at this moment.
          break;
      case PNMessageSendingError:
 
          // PubNub client failed to send message and reason is in 'data' object.
          break;
      case PNMessageSent:
 
          // PubNub client successfully sent message to specified channel. 'data' stores reference on PNMessage instance which has been sent.
          break;
      }
 }];
 @endcode
 
 @param message
 Object which should be sent to the channel. It can be any object which can be serialized into JSON: \c NSString, \c NSNumber, \c NSArray,
 \c NSDictionary.

 @param apnsPayload
 Valid APNS payload dictionary which should be delivered using push service to all subscribers. You can append some more data except message which should be shown to the user.

 @param gcmPayload
 Valid GCM payload dictionary which should be delivered using cloud service to all subscribers. You can append some more data except message which should be shown to the user.

 @param channel
 \b PNChannel instance to which message should be sent.

 @param shouldCompressMessage
 If set to \c YES \b PubNub client will sent it in GZIPed form.

 @param success
 The block which will be called by \b PubNub client any time when message processing state will be changed. The block takes two arguments:
 \c state - one of \b PNMessageState enumerator fields which tell at which stage message at this moment; \c data - depending on whether message is sending/sent or in state
 of message sending failure it can be one of: \b PNMessage or \b PNError instance.
 
 @return \b PNMessage instance if message payload is correct or \c nil if not.
 */
- (PNMessage *)sendMessage:(id)message applePushNotification:(NSDictionary *)apnsPayload googleCloudNotification:(NSDictionary *)gcmPayload
                 toChannel:(PNChannel *)channel compressed:(BOOL)shouldCompressMessage withCompletionBlock:(PNClientMessageProcessingBlock)success;

/**
 Send \c message to the \c channel. All messages placed into queue and will be sent in the same order as they were scheduled.
 
 @code
 @endcode
 This method extends \a -sendMessage:applePushNotification:googleCloudNotification:toChannel:compressed: and allow to specify whether message should be stored in history or not.
 
 @code
 @endcode
 \b Example:
 
 @code
 PubNub *pubNub = [PubNub clientWithConfiguration:[PNConfiguration defaultConfiguration] andDelegate:self];
 [pubNub connect];
 [pubNub sendMessage:@{@"array": @[@"of", @"strings"], @"and": @16}
applePushNotification:@{@"aps":@{@"alert":@"Someone sent array of strings"}} 
googleCloudNotification:@{@"data":@{@"summary":@"Someone sent array of strings"}}
           toChannel:[PNChannel channelWithName:@"iosdev"] compressed:NO storeInHistory:YES];
 @endcode
 
 And handle it with delegates:
 @code
 - (void)pubnubClient:(PubNub *)client willSendMessage:(PNMessage *)message {
 
     // PubNub client is sending message at this moment.
 }
 
 - (void)pubnubClient:(PubNub *)client didFailMessageSend:(PNMessage *)message withError:(PNError *)error {
 
     // PubNub client failed to send message and reason is in 'error'.
 }
 
 - (void)pubnubClient:(PubNub *)client didSendMessage:(PNMessage *)message {
 
     // PubNub client successfully sent message to specified channel.
 }
 @endcode
 
 There is also way to observe message processing from any place in your application using  \b PNObservationCenter:
 @code
 [pubNub.observationCenter addMessageProcessingObserver:self withBlock:^(PNMessageState state, id data) {
 
  switch (state) {
      case PNMessageSending:
 
          // PubNub client is sending message at this moment. 'data' stores reference on PNMessage instance which is processing at this moment.
          break;
      case PNMessageSendingError:
 
          // PubNub client failed to send message and reason is in 'data' object.
          break;
      case PNMessageSent:
 
          // PubNub client successfully sent message to specified channel. 'data' stores reference on PNMessage instance which has been sent.
          break;
      }
 }];
 @endcode
 
 @param message
 Object which should be sent to the channel. It can be any object which can be serialized into JSON: \c NSString, \c NSNumber, \c NSArray,
 \c NSDictionary.

 @param apnsPayload
 Valid APNS payload dictionary which should be delivered using push service to all subscribers. You can append some more data except message which should be shown to the user.

 @param gcmPayload
 Valid GCM payload dictionary which should be delivered using cloud service to all subscribers. You can append some more data except message which should be shown to the user.
 
 @param channel
 \b PNChannel instance into which message should be sent.
 
 @param shouldCompressMessage
 \c YES will instruct \b PubNub client to compress message before sending it to the target \c channel.
 
 @param shouldStoreInHistory
 \c YES in case if message should be stored on \b PubNub service side and become available with History API.
 
 @return \b PNMessage instance if message payload is correct or \c nil if not.
 */
- (PNMessage *)sendMessage:(id)message applePushNotification:(NSDictionary *)apnsPayload googleCloudNotification:(NSDictionary *)gcmPayload
                 toChannel:(PNChannel *)channel compressed:(BOOL)shouldCompressMessage storeInHistory:(BOOL)shouldStoreInHistory;

/**
 Send \c message to the \c channel. All messages placed into queue and will be sent in the same order as they were scheduled.
 
 @code
 @endcode
 This method extends \a -sendMessage:applePushNotification:googleCloudNotification:toChannel:compressed:storeInHistory: and allow to specify message sending processing block.
 
 @code
 @endcode
 \b Example:
 
 @code
 PubNub *pubNub = [PubNub clientWithConfiguration:[PNConfiguration defaultConfiguration] andDelegate:self];
 [pubNub connect];
 [pubNub sendMessage:@{@"array": @[@"of", @"strings"], @"and": @16}
applePushNotification:@{@"aps":@{@"alert":@"Someone sent array of strings"}} 
googleCloudNotification:@{@"data":@{@"summary":@"Someone sent array of strings"}}
           toChannel:[PNChannel channelWithName:@"iosdev"] compressed:NO storeInHistory:YES
 withCompletionBlock:^(PNMessageState state, id data) {
 
  switch (state) {
      case PNMessageSending:
 
          // PubNub client is sending message at this moment. 'data' stores reference on PNMessage instance which is processing at this moment.
          break;
      case PNMessageSendingError:
 
          // PubNub client failed to send message and reason is in 'data' object.
          break;
      case PNMessageSent:
 
          // PubNub client successfully sent message to specified channel. 'data' stores reference on PNMessage instance which has been sent.
          break;
      }
 }];
 @endcode
 
 And handle it with delegates:
 @code
 - (void)pubnubClient:(PubNub *)client willSendMessage:(PNMessage *)message {
 
     // PubNub client is sending message at this moment.
 }
 
 - (void)pubnubClient:(PubNub *)client didFailMessageSend:(PNMessage *)message withError:(PNError *)error {
 
     // PubNub client failed to send message and reason is in 'error'.
 }
 
 - (void)pubnubClient:(PubNub *)client didSendMessage:(PNMessage *)message {
 
     // PubNub client successfully sent message to specified channel.
 }
 @endcode
 
 There is also way to observe message processing from any place in your application using  \b PNObservationCenter:
 @code
 [pubNub.observationCenter addMessageProcessingObserver:self withBlock:^(PNMessageState state, id data) {
 
  switch (state) {
      case PNMessageSending:
 
          // PubNub client is sending message at this moment. 'data' stores reference on PNMessage instance which is processing at this moment.
          break;
      case PNMessageSendingError:
 
          // PubNub client failed to send message and reason is in 'data' object.
          break;
      case PNMessageSent:
 
          // PubNub client successfully sent message to specified channel. 'data' stores reference on PNMessage instance which has been sent.
          break;
      }
 }];
 @endcode
 
 @param message
 Object which should be sent to the channel. It can be any object which can be serialized into JSON: \c NSString, \c NSNumber, \c NSArray,
 \c NSDictionary.

 @param apnsPayload
 Valid APNS payload dictionary which should be delivered using push service to all subscribers. You can append some more data except message which should be shown to the user.

 @param gcmPayload
 Valid GCM payload dictionary which should be delivered using cloud service to all subscribers. You can append some more data except message which should be shown to the user.
 
 @param channel
 \b PNChannel instance into which message should be sent.
 
 @param shouldCompressMessage
 \c YES will instruct \b PubNub client to compress message before sending it to the target \c channel.
 
 @param shouldStoreInHistory
 \c YES in case if message should be stored on \b PubNub service side and become available with History API.
 
 @param success
 The block which will be called by \b PubNub client any time when message processing state will be changed. The block takes two arguments:
 \c state - one of \b PNMessageState enumerator fields which tell at which stage message at this moment; \c data - depending on whether message is sending/sent or in state
 of message sending failure it can be one of: \b PNMessage or \b PNError instance.
 
 @return \b PNMessage instance if message payload is correct or \c nil if not.
 */
- (PNMessage *)sendMessage:(id)message applePushNotification:(NSDictionary *)apnsPayload googleCloudNotification:(NSDictionary *)gcmPayload
                 toChannel:(PNChannel *)channel compressed:(BOOL)shouldCompressMessage storeInHistory:(BOOL)shouldStoreInHistory 
       withCompletionBlock:(PNClientMessageProcessingBlock)success;

/**
 Asynchronously send configured message object to PubNub service.
 */
- (void)sendMessage:(PNMessage *)message;

/**
 Same as -sendMessage: but allow to specify completion block which will be called when message will be sent or in case of error.
 
 Only last call of this method will call completion block. If you need to track message sending from many places, use PNObservationCenter methods
 for this purpose.
 */
- (void)sendMessage:(PNMessage *)message withCompletionBlock:(PNClientMessageProcessingBlock)success;

/**
 Send configured \b PNMessage instance. All messages will be placed into queue and will be send in the same order as they were scheduled.
 
 @code
 @endcode
 This method extendeds \a -sendMessage: and allow to specify whether message should be stored in history or not.
 
 @code
 @endcode
 \b Example:
 
 @code
 PubNub *pubNub = [PubNub clientWithConfiguration:[PNConfiguration defaultConfiguration] andDelegate:self];
 [pubNub connect];
 [pubNub sendMessage:storedMessageInstance storeInHistory:YES];
 @endcode
 
 And handle it with delegates:
 @code
 - (void)pubnubClient:(PubNub *)client willSendMessage:(PNMessage *)message {
 
     // PubNub client is sending message at this moment.
 }
 
 - (void)pubnubClient:(PubNub *)client didFailMessageSend:(PNMessage *)message withError:(PNError *)error {
 
     // PubNub client failed to send message and reason is in 'error'.
 }
 
 - (void)pubnubClient:(PubNub *)client didSendMessage:(PNMessage *)message {
 
     // PubNub client successfully sent message to specified channel.
 }
 @endcode
 
 There is also way to observe message processing from any place in your application using  \b PNObservationCenter:
 @code
 [pubNub.observationCenter addMessageProcessingObserver:self withBlock:^(PNMessageState state, id data) {
 
  switch (state) {
      case PNMessageSending:
 
          // PubNub client is sending message at this moment. 'data' stores reference on PNMessage instance which is processing at this moment.
          break;
      case PNMessageSendingError:
 
          // PubNub client failed to send message and reason is in 'data' object.
          break;
      case PNMessageSent:
 
          // PubNub client successfully sent message to specified channel. 'data' stores reference on PNMessage instance which has been sent.
          break;
      }
 }];
 @endcode
 
 @param message
 Configured message which will be sent to the channel for which it previously has been created.
 
 @param shouldStoreInHistory
 \c YES in case if message should be stored on \b PubNub service side and become available with History API.
 */
- (void)sendMessage:(PNMessage *)message storeInHistory:(BOOL)shouldStoreInHistory;

/**
 Same as -sendMessage:withCompletionBlock: but allow to specify whether message should be stored in history or not.
 
 @param shouldStoreInHistory
 \c YES in case if message should be stored on \b PubNub service side and become available with History API.
 */
- (void)sendMessage:(PNMessage *)message storeInHistory:(BOOL)shouldStoreInHistory withCompletionBlock:(PNClientMessageProcessingBlock)success;

/**
 Send configured \b PNMessage instance. All messages will be placed into queue and will be send in the same order as they were scheduled.
 
 @code
 @endcode
 This method extendeds \a -sendMessage: and allow to specify whether message should be GZIPed before sending to the \b PubNub service or not.
 
 @code
 @endcode
 \b Example:
 
 @code
 PubNub *pubNub = [PubNub clientWithConfiguration:[PNConfiguration defaultConfiguration] andDelegate:self];
 [pubNub connect];
 [pubNub sendMessage:storedMessageInstance compressed:YES];
 @endcode
 
 And handle it with delegates:
 @code
 - (void)pubnubClient:(PubNub *)client willSendMessage:(PNMessage *)message {
 
     // PubNub client is sending message at this moment.
 }
 
 - (void)pubnubClient:(PubNub *)client didFailMessageSend:(PNMessage *)message withError:(PNError *)error {
 
     // PubNub client failed to send message and reason is in 'error'.
 }
 
 - (void)pubnubClient:(PubNub *)client didSendMessage:(PNMessage *)message {
 
     // PubNub client successfully sent message to specified channel.
 }
 @endcode
 
 There is also way to observe message processing from any place in your application using  \b PNObservationCenter:
 @code
 [pubNub.observationCenter addMessageProcessingObserver:self withBlock:^(PNMessageState state, id data) {
 
  switch (state) {
      case PNMessageSending:
 
          // PubNub client is sending message at this moment. 'data' stores reference on PNMessage instance which is processing at this moment.
          break;
      case PNMessageSendingError:
 
          // PubNub client failed to send message and reason is in 'data' object.
          break;
      case PNMessageSent:
 
          // PubNub client successfully sent message to specified channel. 'data' stores reference on PNMessage instance which has been sent.
          break;
      }
 }];
 @endcode
 
 @param message
 Object which should be sent to the channel. It can be any object which can be serialized into JSON: \c NSString, \c NSNumber, \c NSArray,
 \c NSDictionary.
 */
- (void)sendMessage:(PNMessage *)message compressed:(BOOL)shouldCompressMessage;

/**
 Send configured \b PNMessage instance. All messages will be placed into queue and will be send in the same order as they were scheduled.
 
 @code
 @endcode
 This method extendeds \a -sendMessage:withCompletionBlock: and allow to specify whether message should be GZIPed before sending to the \b PubNub service or not.
 
 @code
 @endcode
 \b Example:
 
 @code
 PubNub *pubNub = [PubNub clientWithConfiguration:[PNConfiguration defaultConfiguration] andDelegate:self];
 [pubNub connect];
 [pubNub sendMessage:storedMessageInstance compressed:YES withCompletionBlock:^(PNMessageState state, id data) {
 
  switch (state) {
      case PNMessageSending:
 
          // PubNub client is sending message at this moment. 'data' stores reference on PNMessage instance which is processing at this moment.
          break;
      case PNMessageSendingError:
 
          // PubNub client failed to send message and reason is in 'data' object.
          break;
      case PNMessageSent:
 
          // PubNub client successfully sent message to specified channel. 'data' stores reference on PNMessage instance which has been sent.
          break;
      }
 }];
 @endcode
 
 And handle it with delegates:
 @code
 - (void)pubnubClient:(PubNub *)client willSendMessage:(PNMessage *)message {
 
     // PubNub client is sending message at this moment.
 }
 
 - (void)pubnubClient:(PubNub *)client didFailMessageSend:(PNMessage *)message withError:(PNError *)error {
 
     // PubNub client failed to send message and reason is in 'error'.
 }
 
 - (void)pubnubClient:(PubNub *)client didSendMessage:(PNMessage *)message {
 
     // PubNub client successfully sent message to specified channel.
 }
 @endcode
 
 There is also way to observe message processing from any place in your application using  \b PNObservationCenter:
 @code
 [pubNub.observationCenter addMessageProcessingObserver:self withBlock:^(PNMessageState state, id data) {
 
  switch (state) {
      case PNMessageSending:
 
          // PubNub client is sending message at this moment. 'data' stores reference on PNMessage instance which is processing at this moment.
          break;
      case PNMessageSendingError:
 
          // PubNub client failed to send message and reason is in 'data' object.
          break;
      case PNMessageSent:
 
          // PubNub client successfully sent message to specified channel. 'data' stores reference on PNMessage instance which has been sent.
          break;
      }
 }];
 @endcode
 
 @param message
 Object which should be sent to the channel. It can be any object which can be serialized into JSON: \c NSString, \c NSNumber, \c NSArray,
 \c NSDictionary.
 */
- (void)sendMessage:(PNMessage *)message compressed:(BOOL)shouldCompressMessage withCompletionBlock:(PNClientMessageProcessingBlock)success;

/**
 Send configured \b PNMessage instance. All messages will be placed into queue and will be send in the same order as they were scheduled.
 
 @code
 @endcode
 This method extendeds \a -sendMessage:compressed: and allow to specify whether message should be stored in history or not.
 
 @code
 @endcode
 \b Example:
 
 @code
 PubNub *pubNub = [PubNub clientWithConfiguration:[PNConfiguration defaultConfiguration] andDelegate:self];
 [pubNub connect];
 [pubNub sendMessage:storedMessageInstance compressed:YES storeInHistory:YES];
 @endcode
 
 And handle it with delegates:
 @code
 - (void)pubnubClient:(PubNub *)client willSendMessage:(PNMessage *)message {
 
     // PubNub client is sending message at this moment.
 }
 
 - (void)pubnubClient:(PubNub *)client didFailMessageSend:(PNMessage *)message withError:(PNError *)error {
 
     // PubNub client failed to send message and reason is in 'error'.
 }
 
 - (void)pubnubClient:(PubNub *)client didSendMessage:(PNMessage *)message {
 
     // PubNub client successfully sent message to specified channel.
 }
 @endcode
 
 There is also way to observe message processing from any place in your application using  \b PNObservationCenter:
 @code
 [pubNub.observationCenter addMessageProcessingObserver:self withBlock:^(PNMessageState state, id data) {
 
  switch (state) {
      case PNMessageSending:
 
          // PubNub client is sending message at this moment. 'data' stores reference on PNMessage instance which is processing at this moment.
          break;
      case PNMessageSendingError:
 
          // PubNub client failed to send message and reason is in 'data' object.
          break;
      case PNMessageSent:
 
          // PubNub client successfully sent message to specified channel. 'data' stores reference on PNMessage instance which has been sent.
          break;
      }
 }];
 @endcode
 
 @param message
 Configured message which will be sent to the channel for which it previously has been created.
 
 @param shouldCompressMessage
 \c YES in case if message should be compressed before sending to the PubNub service.
 
 @param shouldStoreInHistory
 \c YES in case if message should be stored on \b PubNub service side and become available with History API.
 */
- (void)sendMessage:(PNMessage *)message compressed:(BOOL)shouldCompressMessage storeInHistory:(BOOL)shouldStoreInHistory;

/**
 Send configured \b PNMessage instance. All messages will be placed into queue and will be send in the same order as they were scheduled.
 
 @code
 @endcode
 This method extendeds \a -sendMessage:compressed:withCompletionBlock: and allow to specify whether message should be stored in history or not.
 
 @code
 @endcode
 \b Example:
 
 @code
 PubNub *pubNub = [PubNub clientWithConfiguration:[PNConfiguration defaultConfiguration] andDelegate:self];
 [pubNub connect];
 [pubNub sendMessage:storedMessageInstance compressed:YES storeInHistory:NO
 withCompletionBlock:^(PNMessageState state, id data) {
 
  switch (state) {
      case PNMessageSending:
 
          // PubNub client is sending message at this moment. 'data' stores reference on PNMessage instance which is processing at this moment.
          break;
      case PNMessageSendingError:
 
          // PubNub client failed to send message and reason is in 'data' object.
          break;
      case PNMessageSent:
 
          // PubNub client successfully sent message to specified channel. 'data' stores reference on PNMessage instance which has been sent.
          break;
      }
 }];
 @endcode
 
 And handle it with delegates:
 @code
 - (void)pubnubClient:(PubNub *)client willSendMessage:(PNMessage *)message {
 
     // PubNub client is sending message at this moment.
 }
 
 - (void)pubnubClient:(PubNub *)client didFailMessageSend:(PNMessage *)message withError:(PNError *)error {
 
     // PubNub client failed to send message and reason is in 'error'.
 }
 
 - (void)pubnubClient:(PubNub *)client didSendMessage:(PNMessage *)message {
 
     // PubNub client successfully sent message to specified channel.
 }
 @endcode
 
 There is also way to observe message processing from any place in your application using  \b PNObservationCenter:
 @code
 [pubNub.observationCenter addMessageProcessingObserver:self withBlock:^(PNMessageState state, id data) {
 
  switch (state) {
      case PNMessageSending:
 
          // PubNub client is sending message at this moment. 'data' stores reference on PNMessage instance which is processing at this moment.
          break;
      case PNMessageSendingError:
 
          // PubNub client failed to send message and reason is in 'data' object.
          break;
      case PNMessageSent:
 
          // PubNub client successfully sent message to specified channel. 'data' stores reference on PNMessage instance which has been sent.
          break;
      }
 }];
 @endcode
 
 @param message
 Configured message which will be sent to the channel for which it previously has been created.
 
 @param shouldCompressMessage
 \c YES in case if message should be compressed before sending to the PubNub service.
 
 @param shouldStoreInHistory
 \c YES in case if message should be stored on \b PubNub service side and become available with History API.
 */
- (void)sendMessage:(PNMessage *)message compressed:(BOOL)shouldCompressMessage storeInHistory:(BOOL)shouldStoreInHistory
withCompletionBlock:(PNClientMessageProcessingBlock)success;

#pragma mark -


@end
