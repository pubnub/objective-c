#import <Foundation/Foundation.h>
#import "PNStructures.h"
#import "PNDelegate.h"


#pragma mark Class forward

@class PNConfiguration, PNChannel, PNMessage, PNDate;

/**
 This is base and main class which is responsible for communication with \b PubNub services and handle all events and notifications.
 
 @code
 @endcode
 \b Example:
 
 @code
 [PubNub setConfiguration:[PNConfiguration defaultConfiguration]];
 [PubNub connect];
 [PubNub subscribeOnChannels:[PNChannel channelsWithNames:@[@"iosdev", @"macdev"]]];
 [PubNub sendMessage:@"PubNub welcomes iOS developers" toChannel:[PNChannel channelWithName:@"iosdev"]];
 [PubNub sendMessage:@"PubNub welcomes Mac OS developers" toChannel:[PNChannel channelWithName:@"iosdev"]];
 [PubNub disconnect];
 @endcode
 
 Code above will be executed in same order as it called. In case of network issues all requests will be terminated with error.

 @note Library designed to support \b procedural coding style, so you can easily subscribe set of commands and they will be issued
 \b one-by-one.

 @warning While \b PubNub client not configured (\a +setConfiguration:) and not connected (\a +connect) all requests will be
 completed with error.
 
 @author Sergey Mamontov
 @version 3.5.1
 @copyright © 2009-13 PubNub Inc.
 */
@interface PubNub : NSObject


#pragma mark - Class methods

/**
 Return reference on initialized shared \b PubNub client instance which is ready to use.
 
 @return \b PubNub client shared instance.

 @since 3.4.0
 
 @see -isConnected
 
 @see +setConfiguration:
 
 @see +connect
 */
+ (PubNub *)sharedInstance;

/**
 Allow completely reset \b PubNub client. All caches, scheduled messages, transport layer instances will be discarded.
 
 @code
 @endcode
 \b Example:
 
 @code
 [PubNub setConfiguration:[PNConfiguration defaultConfiguration]];
 [PubNub setDelegate:self];
 [PubNub connect];
 [PubNub sendMessage:@"PubNub welcomes iOS developers" toChannel:[PNChannel channelWithName:@"iosdev"]];
 
 // Resetting client and repeat same (or different) configuration route as we did before.
 [PubNub resetClient];
 [PubNub setConfiguration:[PNConfiguration defaultConfiguration]];
 [PubNub setDelegate:self];
 @endcode
 
 @note Any further requests after this point, not related to configuration update or connection will end up with error.
 
 @warning Because everything will be reset, you will have to configure \b PubNub client again and subscribe on all
 notifications.

 @since 3.4.2

 @see PNConfiguration class

 @see PNChannel class
 
 @see +setConfiguration:
 
 @see +connect
 
 @see +disconnect
 */
+ (void)resetClient;


#pragma mark - Client connection management methods

/**
 Connect \b PubNub client to remote servers.
 
 @code
 @endcode
 \b Example:
 
 @code 
 [PubNub setConfiguration:[PNConfiguration defaultConfiguration]];
 [PubNub setDelegate:self];
 [PubNub connect];
 @endcode

 And handle it with delegates:
 @code 
 - (void)pubnubClient:(PubNub *)client willConnectToOrigin:(NSString *)origin {
 
     // Update your interface / data model to mark that PubNub client is connecting to the service.
 }
 
 - (void)pubnubClient:(PubNub *)client didConnectToOrigin:(NSString *)origin {
 
     // Update your interface to let user know that we are ready to work.
 }
 
 - (void)pubnubClient:(PubNub *)client connectionDidFailWithError:(PNError *)error {
 
     // Looks like something went wrong during connection, so we should handle it somehow.
 
     if (error == nil) {
         
         // Looks like there is no internet connection at the moment when this method has been called or PubNub client doesn't have enough time 
         // to validate its availability.
         //
         // In this case connection will be established automatically as soon as internet connection will be detected.
     }
     else {
         
         // Happened something really bad and PubNub client can't establish connection, so we should update our interface to let user know and do 
         // something to recover from this situation.
         //
         // Error also can be sent by PubNub client if you tried to connect while already connected or just launched connection 
         //
         // Always check error.code to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
         // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
     }
 }
 
 - (void)pubnubClient:(PubNub *)client willDisconnectWithError:(PNError *)error {
     
     // PubNub client will disconnect from server because of some error and we should prepare our user interface to tell user sad news.
     //
     // Always check error.code to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
     // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
 }
 
 - (void)pubnubClient:(PubNub *)client didDisconnectFromOrigin:(NSString *)origin withError:(PNError *)error {
     
     // PubNub client disconnected from the server because of error and we should update interface to let user know and do something to recover 
     // from this situation.
     //
     // Always check error.code to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
     // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
 }
 
 - (void)pubnubClient:(PubNub *)client didDisconnectFromOrigin:(NSString *)origin {
     
     // PubNub client completed disconnection from the service by user request.
 }
 @endcode
 
 There is also way to observe connection state from any place in your application using \b PNObservationCenter:
 @code
 [[PNObservationCenter defaultCenter] addClientConnectionStateObserver:self
   withCallbackBlock:^(NSString *origin, BOOL isConnected, PNError *connectionError) {
 
       if (connectionError) {
           
           // Handle connection error which occurred during connection or while client was connected. Error also can be sent by PubNub client if 
           // you tried to connect while already connected or just launched connection.
           //
           // Always check error.code to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
           // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
       }
       else if (!isConnected) {
           
           // Looks like we in situation when there is no internet connection or PubNub client doesn't have enough time to validate its availability.
           //
           // Just wait and library will connect automatically as soon as connection will be detected.
       }
       else {
           
           // We are connected and ready to go.
       }
   }];
 @endcode

 Also observation can be done using \b NSNotificationCenter to observe this notifications: kPNClientErrorNotification,
 kPNClientDidConnectToOriginNotification, kPNClientWillConnectToOriginNotification, kPNClientDidDisconnectFromOriginNotification,
 kPNClientConnectionDidFailWithErrorNotification.
 
 @note This method may end up right after it was called with error in case if you tried to connect w/o \b PubNub client configuration 
 (\a +setConfiguration:) or when there is no internet connection (it will call error callbacks with empty \a 'error' just to tell you that we still not
 connecting).

 @warning Connection will fail in case if \b PubNub client not configured (\a +setConfiguration:).

 @since 3.4.0

 @see PNConfiguration class

 @see PNChannel class

 @see PNError class

 @see PNObservationCenter class
 
 @see +setConfiguration:
 
 @see +connectWithSuccessBlock:errorBlock:
 */
+ (void)connect;

/**
 Connect \b PubNub client to remote servers.
 
 @code
 @endcode
 This method extends \a +connect and allow to specify connection success and failure handling blocks.
 
 @code
 @endcode
 \b Example:
 
 @code 
 [PubNub setConfiguration:[PNConfiguration defaultConfiguration]];
 [PubNub setDelegate:self];
 [PubNub connectWithSuccessBlock:^(NSString *origin){
 
         // Update your interface to let user know that we are ready to work
     }
                      errorBlock:^(PNError *connectionError){
 
                          // Looks like something went wrong during connection, so we should handle it somehow.
 
                          if (error == nil) {
 
                              // Looks like there is no internet connection at the moment when this method has been called or PubNub client doesn't 
                              // have enough time to validate its availability.
                              //
                              // In this case connection will be established automatically as soon as internet connection will be detected.
                          }
                          else {
 
                              // Happened something really bad and PubNub client can't establish connection, so we should update
                              // our interface to let user know and do something to recover from this situation.
                              //
                              // Error also can be sent by PubNub client if you tried to connect while already connected or just
                              // launched connection.
                              //
                              // Always check error.code to find out what caused error (check PNErrorCodes header
                              // file and use -localizedDescription / -localizedFailureReason and -localizedRecoverySuggestion
                              // to get human readable description for error).
                          }
 
 }];
 @endcode
 
 And handle it with delegates:
 @code 
 - (void)pubnubClient:(PubNub *)client willConnectToOrigin:(NSString *)origin {
 
     // Update your interface/data model to mark that PubNub client is connecting to the service.
 }
 
 - (void)pubnubClient:(PubNub *)client didConnectToOrigin:(NSString *)origin {
 
     // Update your interface to let user know that we are ready to work.
 }
 
 - (void)pubnubClient:(PubNub *)client connectionDidFailWithError:(PNError *)error {
 
     // Looks like something went wrong during connection, so we should handle it somehow.
 
     if (error == nil) {
 
         // Looks like there is no internet connection at the moment when this method has been called or PubNub client doesn't have enough time 
         // to validate its availability.
         //
         // In this case connection will be established automatically as soon as internet connection will be detected.
     }
     else {
 
         // Happened something really bad and PubNub client can't establish connection, so we should update our interface to let user know and
         // do something to recover from this situation.
         //
         // Error also can be sent by PubNub client if you tried to connect while already connected or just launched connection.
         //
         // Always check error.code to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
         // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
     }
 }
 
 - (void)pubnubClient:(PubNub *)client willDisconnectWithError:(PNError *)error {
 
     // PubNub client will disconnect from server because of some error and we should prepare our user interface to tell user sad news.
     // from this situation.
     //
     // Always check error.code to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
     // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
 }
 
 - (void)pubnubClient:(PubNub *)client didDisconnectFromOrigin:(NSString *)origin withError:(PNError *)error {
 
     // PubNub client disconnected from the server because of error and we should update interface to let user know and do something to recover 
     // from this situation.
     //
     // Always check error.code to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
     // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
 }
 
 - (void)pubnubClient:(PubNub *)client didDisconnectFromOrigin:(NSString *)origin {
 
     // PubNub client completed disconnection from the service by user request.
 }
 @endcode
 
 There is also way to observe connection state from any place in your application using  \b PNObservationCenter:
 @code
 [[PNObservationCenter defaultCenter] addClientConnectionStateObserver:self
  withCallbackBlock:^(NSString *origin, BOOL isConnected, PNError *connectionError) {
 
      if (connectionError) {
           
           // Handle connection error which occurred during connection or while client was connected. Error also can be sent by PubNub client if 
           // you tried to connect while already connected or just launched connection.
           //
           // Always check error.code to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
           // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
      }
      else if (!isConnected) {
 
          // Looks like we in situation when there is no internet connection or PubNub client doesn't
          // have enough time to validate its availability.
          //
          // Just wait and library will connect automatically as soon as connection will be detected.
      }
      else {
 
          // We are connected and ready to go.
      }
  }];
 @endcode

 Also observation can be done using \b NSNotificationCenter to observe this notifications: kPNClientErrorNotification,
 kPNClientDidConnectToOriginNotification, kPNClientWillConnectToOriginNotification, kPNClientDidDisconnectFromOriginNotification,
 kPNClientConnectionDidFailWithErrorNotification.

 @param success 
 The block which will be called by \b PubNub client as soon as it will complete handshake and all preparations. The block takes one argument:
 \c origin - name of the origin to which \b PubNub client connected.
 
 @param failure 
 The block which will be called by \b PubNub client in case of any errors which occurred during connection. The block takes one argument:
 \c connectionError - error which describes what exactly went wrong. Always check \a connectionError.code to find out what caused error
 (check PNErrorCodes header file and use \a -localizedDescription / \a -localizedFailureReason and \a -localizedRecoverySuggestion to
 get human readable description for error).
 
 @note \c failure block may be called few times in few cases:
       1) connection really failed and it will pass \b PNError instance in block.
       2) at the moment when this method has been called there was no connection or \b PubNub client doesn't have enough time to validate its availability.

 @warning Connection will fail in case if \b PubNub client not configured (\a +setConfiguration:).

 @since 3.4.0

 @see PNConfiguration class

 @see PNChannel class

 @see PNError class

 @see PNObservationCenter class
 
 @see +setConfiguration:
 
 @see +connect
 */
+ (void)connectWithSuccessBlock:(PNClientConnectionSuccessBlock)success errorBlock:(PNClientConnectionFailureBlock)failure;

/**
 Will disconnect from all channels w/o sending \a 'leave' presence event and terminate all socket connection which
 has been established for \b PubNub client. All scheduled messages and requests will be discarded.
 
 @code
 @endcode
 \b Example:
 
 @code
 [PubNub setConfiguration:[PNConfiguration defaultConfiguration]];
 [PubNub connect];
 [PubNub subscribeOnChannels:[PNChannel channelsWithNames:@[@"iosdev", @"macdev"]]];
 [PubNub sendMessage:@"PubNub welcomes iOS developers" toChannel:[PNChannel channelWithName:@"iosdev"]];
 [PubNub sendMessage:@"PubNub welcomes Mac OS developers" toChannel:[PNChannel channelWithName:@"iosdev"]];
 [PubNub disconnect];
 @endcode

 And handle it with delegates:
 @code
 - (void)pubnubClient:(PubNub *)client didDisconnectFromOrigin:(NSString *)origin {

     // PubNub client disconnected from specified origin.
 }
 @endcode

 There is also way to observe disconnection state from any place in your application using  \b PNObservationCenter:
 @code
 [[PNObservationCenter defaultCenter] addClientConnectionStateObserver:self
  withCallbackBlock:^(NSString *origin, BOOL isConnected, PNError *connectionError) {

      if (!isConnected) {

          // Looks like PubNub client disconnected.

          if (connectionError) {

              // Connection failed / disconnected because of this error.
              //
              // Always check error.code to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
              // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
          }
          else {

              // Looks like we in situation when there is no internet connection or PubNub client doesn't
              // have enough time to validate its availability.
              //
              // Also at this moment we are not connected yet / anymore.
          }
      }
  }];
 @endcode

 Also observation can be done using \b NSNotificationCenter to observe this notifications: kPNClientDidDisconnectFromOriginNotification.
 
 @note Any further requests after this point, not related to configuration update or connection will end up with error.

 @since 3.4.0

 @see PNConfiguration class

 @see PNChannel class

 @see PNObservationCenter class

 @see +connect
 
 @see +connectWithSuccessBlock:errorBlock:
 */
+ (void)disconnect;


#pragma mark - Client configuration

/**
 Allow fetch configuration which is currently used by \b PubNub client for operation and communication with \b PubNub services.
 
 @note Because this method will return copy of real object which is used by \b PubNub client any changes on this instance won't take effect. To apply changed from this \b PNConfiguration instance use \a +setConfiguration: method (please read special notes for setting configuration while client is connected).
 
 @return PNConfiguration instance copy.
 
 @see PNConfiguration class
 
 @see +setConfiguration:
 */
+ (PNConfiguration *)configuration;

/**
 Perform initial configuration or update existing one.
 
 @code
 @endcode
 This method will use delegate specified with \a +setDelegate: method.
 
 @code
 @endcode
 \b Example:
 
 @code
 [PubNub setConfiguration:[PNConfiguration defaultConfiguration]];
 [PubNub connect];
 @endcode
 
 @code
 @endcode
 \b Example with custom configuration:
 
 @code
 [PubNub setConfiguration:[PNConfiguration configurationForOrigin:@"pubsub.pubnub.com" publishKey:@"demo" subscribeKey:@"demo"
                                                        secretKey:nil authorizationKey:@"authKey"]];
 [PubNub connect];

 // In this case PubNub client will reconnect to apply updated configuration.
 [PubNub setConfiguration:[PNConfiguration configurationForOrigin:@"ios.pubnub.com" publishKey:@"demo" subscribeKey:@"demo"
                                                        secretKey:nil authorizationKey:@"authKey"]];
 @endcode
 
 @param configuration
 \b PNConfiguration instance which specify \b PubNub client behaviour and operation routes.

 @note In case \c configuration override \b SSL, \b origin name or \b authorization key, \b PubNub client may decide to reconnect (if client
 were connected before configuration update).

 @note It is strongly advised change configuration in really rare cases and most of the time provide configuration during \b PubNub client configuration.
 Configuration update on connected client will cause additional overhead to reinitialize client with new configuration and connect back to server (time overhead).

 @since 3.4.0

 @see PNConfiguration class
 
 @see +configuration
 
 @see +setupWithConfiguration:andDelegate:
 */
+ (void)setConfiguration:(PNConfiguration *)configuration;

/**
 Perform initial configuration or update existing one.
 
 @code
 @endcode
 This method extends \a +setConfiguration: and allow to specify delegate for callbacks.
 
 @code
 @endcode
 \b Example:
 
 @code
 [PubNub setConfiguration:[PNConfiguration defaultConfiguration] andDelegate:self];
 [PubNub connect];

 // In this case PubNub client will reconnect to apply updated configuration.
 [PubNub setConfiguration:[PNConfiguration configurationForOrigin:@"ios.pubnub.com" publishKey:@"demo" subscribeKey:@"demo"
                                                        secretKey:nil authorizationKey:@"authKey"]
              andDelegate:self];
 @endcode
 
 @param configuration 
 \b PNConfiguration instance which specify \b PubNub client behaviour and operation routes.
 
 @param delegate 
 Instance which conforms to \b PNDelegate protocol and will receive events from \b PubNub client via delegate callbacks.

 @note In case \c configuration override \b SSL, \b origin name or \b authorization key, \b PubNub client may decide to reconnect (if client
 were connected before configuration update).

 @note It is strongly advised change configuration in really rare cases and most of the time provide configuration during \b PubNub client configuration.
 Configuration update on connected client will cause additional overhead to reinitialize client with new configuration and connect back to server (time overhead).
 
 @note There can be only one \b PubNub client delegate at once. If you need to observe for events from different part of application, you should check
 \b PNObservationCenter and subscribe on events in which you are interested.

 @since 3.4.0

 @see PNConfiguration class

 @see PNDelegate protocol reference

 @see PNObservationCenter class
 
 @see +configuration
 
 @see +setConfiguration:
 */
+ (void)setupWithConfiguration:(PNConfiguration *)configuration andDelegate:(id<PNDelegate>)delegate;

/**
 Specify \b PubNub client delegate for event callbacks.
 
 @code
 @endcode
 \b Example:
 
 @code
 [PubNub setConfiguration:[PNConfiguration defaultConfiguration]];
 [PubNub setDelegate:self];
 [PubNub connect];
 @endcode
 
 @param delegate
 Instance which conforms to \b PNDelegate protocol and will receive events from \b PubNub client via delegate callbacks.
 
 @note There can be only one \b PubNub client delegate at once. If you need to observe for events from different part of application, you should check
 \b PNObservationCenter and subscribe on events in which you are interested.

 @since 3.4.0

 @see PNConfiguration class

 @see PNDelegate protocol reference
 
 @see PNObservationCenter class
 
 @see +setupWithConfiguration:andDelegate:
 */
+ (void)setDelegate:(id<PNDelegate>)delegate;


#pragma mark - Client identification

/**
 Update current \b PubNub client identifier (unique user identifier or basically username/nickname).
 
 @code
 @endcode
 \b Example:
 
 @code
 [PubNub setConfiguration:[PNConfiguration defaultConfiguration] andDelegate:self];
 [PubNub setClientIdentifier:@"pubnub-user"];
 [PubNub connect];
 @endcode
 
 @param identifier
 \a NSString instance which represent client identifier which will be used to identify concrete client on another
 side of the channel route.
 
 @warning If \b PubNub client was previously connected to the service it will gracefully \a 'leave' channels on which it has been subscribed
 (\a 'leave' presence event will be generated) and subscribe back with new identifier (\a 'join' event will be generated).
 
 @since 3.4.0
 
 @see PNConfiguration class
 
 @see +clientIdentifier
 */
+ (void)setClientIdentifier:(NSString *)identifier;

/**
 Update current \b PubNub client identifier (unique user identifier or basically username/nickname).
 
 @code
 @endcode
 Extends \a +setClientIdentifier: and allow to specify whether client should restore subscription on channels with last time token or re-subscribe with presence event.
 
 @code
 @endcode
 \b Example:
 
 @code
 [PubNub setConfiguration:[PNConfiguration defaultConfiguration] andDelegate:self];
 [PubNub setClientIdentifier:@"pubnub-user"];
 [PubNub connect];
 @endcode
 
 @param identifier
 \a NSString instance which represent client identifier which will be used to identify concrete client on another
 side of the channel route.
 
 @param shouldCatchup
 If set o \c YES \b PubNub client will try to restore subscription on channels (if subscribed) from the moment when this method has been called and 
 all messages which has been sent into the channel from that moment will be received.
 
 @warning If \b PubNub client was previously connected to the service it will gracefully \a 'leave' channels on which it has been subscribed
 (\a 'leave' presence event will be generated) and subscribe back with new identifier (\a 'join' event will be generated).

 @since 3.4.0

 @see PNConfiguration class
 
 @see +clientIdentifier
 */
+ (void)setClientIdentifier:(NSString *)identifier shouldCatchup:(BOOL)shouldCatchup;

/**
 Retrieve current \b PubNub client identifier which will/used to establish connection with \b PubNub services.
 
 @code
 @endcode
 \b Example:
 
 @code
 [PubNub setConfiguration:[PNConfiguration defaultConfiguration] andDelegate:self];
 [PubNub setClientIdentifier:@"pubnub-user"];
 [PubNub connect];
 
 NSLog(@"Client identifier: %@", [PubNub clientIdentifier]); // Client identifier: pubnub-user
 @endcode

 @note If \b PubNub client has been connected before client identifier change, new value will be available only after
 \b PubNub client will reconnect with new identifier.

 @since 3.4.0
 
 @return client identifier.

 @see PNConfiguration class
 
 @see +setClientIdentifier:
 */
+ (NSString *)clientIdentifier;


#pragma mark - Client state management

/**
 Retrieve client state information from \b PubNub service.

 @param clientIdentifier
 Client identifier for which \b PubNub client should retrieve state.

 @param channel
 \b PNChannel instance from which client's state should be pulled out.

 @since 3.6.0
 */
+ (void)requestClientState:(NSString *)clientIdentifier forChannel:(PNChannel *)channel;

/**
 Retrieve client state information from \b PubNub service.

 @code
 @endcode
 This method extends \a +requestClientState:forChannel: and allow to specify state retrieval process handling
 block.

 @param clientIdentifier
 Client identifier for which \b PubNub client should retrieve state.

 @param channel
 \b PNChannel instance from which client's state should be pulled out.

 @param handlerBlock
 The block which will be called by \b PubNub client as soon as client state retrieval process operation will be
 completed. The block takes three arguments:
 \c clientIdentifier - identifier for which \b PubNub client search for channels;
 \c state - is \b PNDictionary instance which store state previously bounded to the client at specified channel;
 \c error - describes what exactly went wrong (check error code and compare it with \b PNErrorCodes ).

 @warning Only last call of this method will call completion block. If you need to track participants loading events
 from many places, use PNObservationCenter methods for this purpose.

 @since 3.6.0
 */
+ (void) requestClientState:(NSString *)clientIdentifier forChannel:(PNChannel *)channel
withCompletionHandlingBlock:(PNClientStateRetrieveHandlingBlock)handlerBlock;

/**
 Update client state information.

 @param clientIdentifier
 Client identifier for which \b PubNub client should bound state.

 @param clientState
 \b NSDictionary instance with list of parameters which should be bound to the client.

 @param channel
 \b PNChannel instance for which client's state should be bound.

 @note You can delete previously configured key from state by passing [NSNull null] as value for target key and \b
  PubNub service will remove specified key from client's state at specified channel.

 @warning Client state shouldn't contain any nesting and values should be one of: int, float or string.

 @since 3.6.0
 */
+ (void)updateClientState:(NSString *)clientIdentifier state:(NSDictionary *)clientState
               forChannel:(PNChannel *)channel;

/**
 Update client state information.

 @code
 @endcode
 This method extends \a +updateClientState:state:forChannel: and allow to specify state update process
 handling block.

 @param clientIdentifier
 Client identifier for which \b PubNub client should bound state.

 @param clientState
 \b NSDictionary instance with list of parameters which should be bound to the client.

 @param channel
 \b PNChannel instance for which client's state should be bound.

 @param handlerBlock
 The block which will be called by \b PubNub client as soon as client state update process operation will be
 completed. The block takes three arguments:
 \c clientIdentifier - identifier for which \b PubNub client search for channels;
 \c channels - is list of \b PNChannel instances in which \c clientIdentifier has been found as subscriber; \c error -
 describes what exactly went wrong (check error code and compare it with \b PNErrorCodes ).

 @note You can delete previously configured key from state by passing [NSNull null] as value for target key and \b
  PubNub service will remove specified key from client's state at specified channel.

 @warning Only last call of this method will call completion block. If you need to track participants loading events
 from many places, use PNObservationCenter methods for this purpose.

 @warning Client state shouldn't contain any nesting and values should be one of: int, float or string.

 @since 3.6.0
 */
+ (void)   updateClientState:(NSString *)clientIdentifier state:(NSDictionary *)clientState
                  forChannel:(PNChannel *)channel
 withCompletionHandlingBlock:(PNClientStateUpdateHandlingBlock)handlerBlock;


#pragma mark - Channels subscription management

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
+ (NSArray *)subscribedChannels;

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
+ (BOOL)isSubscribedOnChannel:(PNChannel *)channel;

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
+ (void)subscribeOnChannel:(PNChannel *)channel;

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
 
 @warning Only last call of this method will call completion block. If you need to track subscribe process from many places, use \b PNObservationCenter
 methods for this purpose.

 @since 3.4.0

 @see PNChannel class

 @see PNError class

 @see PNObservationCenter class
 
 @sse +subscribeOnChannel:
 */
+ (void)subscribeOnChannel:(PNChannel *)channel withCompletionHandlingBlock:(PNClientChannelSubscriptionHandlerBlock)handlerBlock;

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
+ (void)subscribeOnChannel:(PNChannel *)channel withClientState:(NSDictionary *)clientState;

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

 @warning Only last call of this method will call completion block. If you need to track subscribe process from many places, use \b PNObservationCenter
 methods for this purpose.

 @warning Client state shouldn't contain any nesting and values should be one of: int, float or string.

 @warning If you already subscribed on channel (for which already specified state) and will subscribe to another
 one, it will override old state (if keys are the same or will add new keys into old one).

 @since 3.6.0

 @see PNChannel class

 @see PNError class

 @see PNObservationCenter class

 @sse +subscribeOnChannel:
 */
+ (void) subscribeOnChannel:(PNChannel *)channel withClientState:(NSDictionary *)clientState
 andCompletionHandlingBlock:(PNClientChannelSubscriptionHandlerBlock)handlerBlock;

/**
 Subscribe client to one more channel.
 
 @code
 @endcode
 This method extends \a +subscribeOnChannel: method and allow to specify on whether presence event should be generated or not. If \b PubNub client
 already subscribed on some channels and \a 'withPresenceEvent' will be set to \c YES, then \b PubNub will issue \a 'leave' presence event on old
 channels and generate \a 'join' presence event on both old and new channels. If \a 'withPresenceEvent' is set to \c NO then \b PubNub client will
 silently unsubscribe from old channels and subscribe on them back along with new one w/o any presence events.
 
 @code
 @endcode
 \b Example:
 
 @code
 [PubNub setConfiguration:[PNConfiguration defaultConfiguration] andDelegate:self];
 [PubNub connect];
 [PubNub subscribeOnChannel:[PNChannel channelsWithName:@"macosdev"]];
 [PubNub subscribeOnChannel:[PNChannel channelsWithName:@"iosdev"] withPresenceEvent:NO];
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
 
 @param withPresenceEvent
 \c BOOL which specify on whether client should generate \a 'leave'/\a 'join' presence events (if set to \c YES) or not (if set to \c NO).

 @since 3.4.0

 @see PNChannel class

 @see PNError class

 @see PNObservationCenter class
 
 @see +subscribeOnChannel:withPresenceEvent:andCompletionHandlingBlock:
 */
+ (void)subscribeOnChannel:(PNChannel *)channel withPresenceEvent:(BOOL __unused)withPresenceEvent DEPRECATED_MSG_ATTRIBUTE(" Use '+subscribeOnChannel:' instead.");

/**
 Subscribe client to one more channel.
 
 @code
 @endcode
 This method extends \a +subscribeOnChannel:withPresenceEvent: and allow to specify subscription process state change handler block.
 
 @code
 @endcode
 \b Example:
 
 @code
 [PubNub setConfiguration:[PNConfiguration defaultConfiguration] andDelegate:self];
 [PubNub connect];
 [PubNub subscribeOnChannel:[PNChannel channelsWithName:@"macosdev"]];
 [PubNub subscribeOnChannel:[PNChannel channelsWithName:@"iosdev"] withPresenceEvent:YES
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
 
 @param channel
 Instance of \b PNChannel on which client will subscribe.
 
 @param withPresenceEvent
 \c BOOL which specify on whether client should generate \a 'leave'/\a 'join' presence events (if set to \c YES) or not (if set to \c NO).
 
 @param handlerBlock
 The block which will be called by PubNub client as soon as subscription process state will change. The block takes three arguments:
 \c state - is \b PNSubscriptionProcessState enumerator field which describes current subscription state; \c channels - array of channels for which
 subscription process changed state; \c error - error because of which subscription failed. Always check \a error.code to find out what caused error
 (check \b PNErrorCodes header file and use \a -localizedDescription / \a -localizedFailureReason and \a -localizedRecoverySuggestion to get human
 readable description for error).
 
 @warning Only last call of this method will call completion block. If you need to track subscribe process from many places, 
 use \b PNObservationCenter methods for this purpose.

 @since 3.4.0

 @see PNChannel class

 @see PNError class

 @see PNObservationCenter class
 
 @see +subscribeOnChannel:withPresenceEvent:
 */
+ (void)subscribeOnChannel:(PNChannel *)channel withPresenceEvent:(BOOL __unused)withPresenceEvent
andCompletionHandlingBlock:(PNClientChannelSubscriptionHandlerBlock)handlerBlock DEPRECATED_MSG_ATTRIBUTE(" Use '+subscribeOnChannel:withCompletionHandlingBlock:' instead.");

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
+ (void)subscribeOnChannels:(NSArray *)channels;

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
 
 @warning Only last call of this method will call completion block. If you need to track subscribe process from many places,
 use \b PNObservationCenter methods for this purpose.

 @since 3.4.0

 @see PNChannel class

 @see PNError class

 @see PNObservationCenter class
 
 @see +subscribeOnChannels:
 */
+ (void)subscribeOnChannels:(NSArray *)channels withCompletionHandlingBlock:(PNClientChannelSubscriptionHandlerBlock)handlerBlock;

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
+ (void)subscribeOnChannels:(NSArray *)channels withClientState:(NSDictionary *)clientState;

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

 @warning Only last call of this method will call completion block. If you need to track subscribe process from many places,
 use \b PNObservationCenter methods for this purpose.
 
 @warning Client state should be represented with dictionary with channel names as keys and channel state as values. Channel state shouldn't contain any nesting and values should be one of: int, float or string. As keys should be used \b only channel names on which you are subscribing or already subscribed.

 @warning If you already subscribed on channel (for which already specified state) and will subscribe to another
 one, it will override old state (if keys are the same or will add new keys into old one).

 @since 3.4.0

 @see PNChannel class

 @see PNError class

 @see PNObservationCenter class

 @see +subscribeOnChannels:
 */
+ (void)subscribeOnChannels:(NSArray *)channels withClientState:(NSDictionary *)clientState
 andCompletionHandlingBlock:(PNClientChannelSubscriptionHandlerBlock)handlerBlock;

/**
 Subscribe client to the set of new channels.
 
 @code
 @endcode
 This method extends \a +subscribeOnChannel: method and allow to specify on whether presence event should be generated or not. If \b PubNub client
 already subscribed on some channels and \a 'withPresenceEvent' will be set to \c YES, than \b PubNub will issue \a 'leave' presence event on old
 channels and generate \a 'join' presence event on both old and new channels. If \a 'withPresenceEvent' is set to \c NO than \b PubNub client will
 silently unsubscribe from old channels and subscribe on them back along with new one w/o any presence events.
 
 @code
 @endcode
 \b Example:
 
 @code
 [PubNub setConfiguration:[PNConfiguration defaultConfiguration] andDelegate:self];
 [PubNub connect];
 [PubNub subscribeOnChannel:[PNChannel channelsWithName:@"pubnub"]];
 [PubNub subscribeOnChannels:[PNChannel channelsWithNames:@[@"iosdev", @"macosdev"]] withPresenceEvent:YES];
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
 
 @param withPresenceEvent
 \c BOOL which specify on whether client should generate \a 'leave'/\a 'join' presence events (if set to \c YES) or not (if set to \c NO).

 @since 3.4.0

 @see PNChannel class

 @see PNError class

 @see PNObservationCenter class
 
 @see +subscribeOnChannels:withPresenceEvent:andCompletionHandlingBlock:
 */
+ (void)subscribeOnChannels:(NSArray *)channels withPresenceEvent:(BOOL __unused)withPresenceEvent DEPRECATED_MSG_ATTRIBUTE(" Use '+subscribeOnChannels:' instead.");

/**
 Subscribe client to the set of new channels.
 
 @code
 @endcode
 This method extends \a +subscribeOnChannel:withPresenceEvent: and allow to specify subscription process state change handler block.
 
 @code
 @endcode
 \b Example:
 
 @code
 [PubNub setConfiguration:[PNConfiguration defaultConfiguration] andDelegate:self];
 [PubNub connect];
 [PubNub subscribeOnChannel:[PNChannel channelsWithName:@"pubnub"]];
 [PubNub subscribeOnChannels:[PNChannel channelsWithNames:@[@"iosdev", @"macosdev"]] withPresenceEvent:YES
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
 
 @param withPresenceEvent
 \c BOOL which specify on whether client should generate \a 'leave'/\a 'join' presence events (if set to \c YES) or not (if set to \c NO).
 
 @param handlerBlock
 The block whichh will be called by \b PubNub client as soon as subscription process state will change. The block takes three arguments:
 \c state - is \b PNSubscriptionProcessState enumerator field which describes current subscription state; \c channels - array of channels for which
 subscription process changed state; \c error - error because of which subscription failed. Always check \a error.code to find out what caused error
 (check PNErrorCodes header file and use \a -localizedDescription / \a -localizedFailureReason and \a -localizedRecoverySuggestion to get human
 readable description for error).
 
 @warning Only last call of this method will call completion block. If you need to track subscribe process from many places,
 use \b PNObservationCenter methods for this purpose.

 @since 3.4.0

 @see PNChannel class

 @see PNError class

 @see PNObservationCenter class
 
 @see +subscribeOnChannels:withPresenceEvent:
 */
+ (void)subscribeOnChannels:(NSArray *)channels withPresenceEvent:(BOOL __unused)withPresenceEvent
 andCompletionHandlingBlock:(PNClientChannelSubscriptionHandlerBlock)handlerBlock DEPRECATED_MSG_ATTRIBUTE(" Use '+subscribeOnChannels:withCompletionHandlingBlock:' instead.");

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
+ (void)unsubscribeFromChannel:(PNChannel *)channel;

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
 
 @warning Only last call of this method will call completion block. If you need to track unsubscribe process from many places, 
 use \b PNObservationCenter methods for this purpose.

 @since 3.4.0

 @see PNChannel class

 @see PNError class

 @see PNObservationCenter class
 
 @see +unsubscribeFromChannel:
 */
+ (void)unsubscribeFromChannel:(PNChannel *)channel withCompletionHandlingBlock:(PNClientChannelUnsubscriptionHandlerBlock)handlerBlock;

/**
 Unsubscribe client from one channel.
 
 @code
 @endcode
 This method extends \a +unsubscribeFromChannel: method and allow to specify on whether presence event should be generated or not.
 If \b PubNub client already subscribed on some channels and \a 'withPresenceEvent' will be set to \c YES, than \b PubNub will issue \a 'leave' 
 presence event on old channels and generate \a 'join' presence event on rest of the channels. If \a 'withPresenceEvent' is set to \c NO than 
 \b PubNub client will silently unsubscribe from old channels and re-subscribe on rest on the channels w/o any presence events.
 
 @code
 @endcode
 \b Example:
 
 @code
 [PubNub setConfiguration:[PNConfiguration defaultConfiguration] andDelegate:self];
 [PubNub connect];
 [PubNub subscribeFromChannel:[PNChannel channelsWithName:@"iosdev"]];
 [PubNub sendMessage:@"PubNub welcomes iOS developers" toChannel:[PNChannel channelWithName:@"iosdev"]];
 [PubNub unsubscribeFromChannel:[PNChannel channelsWithName:@"iosdev"] withPresenceEvent:YES];
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

 @since 3.4.0

 @see PNChannel class

 @see PNError class

 @see PNObservationCenter class
 
 @see +unsubscribeFromChannel:withPresenceEvent:withCompletionHandlingBlock:
 */
+ (void)unsubscribeFromChannel:(PNChannel *)channel withPresenceEvent:(BOOL __unused)withPresenceEvent DEPRECATED_MSG_ATTRIBUTE(" Use '+unsubscribeFromChannel:' instead.");

/**
 Unsubscribe client from one channel.
 
 @code
 @endcode
 This method extends \a +unsubscribeFromChannel:withPresenceEvent: and allow to specify unsubscription process state change handler block.
 
 @code
 @endcode
 \b Example:
 
 @code
 [PubNub setConfiguration:[PNConfiguration defaultConfiguration] andDelegate:self];
 [PubNub connect];
 [PubNub subscribeFromChannel:[PNChannel channelsWithName:@"iosdev"]];
 [PubNub sendMessage:@"PubNub welcomes iOS developers" toChannel:[PNChannel channelWithName:@"iosdev"]];
 [PubNub unsubscribeFromChannel:[PNChannel channelWithName:@"iosdev"] withPresenceEvent:YES
  andCompletionHandlingBlock:^(NSArray *channels, PNError *error) {
 
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
 The block which will be called by PubNub client as soon as subscription process state will change. The block takes two arguments:
 \c channels - array of \b PNChannel instances from which client unsubscribe; \c error - error because of which unsubscription failed.
 Always check \a error.code to find out what caused error (check PNErrorCodes header file and use \a -localizedDescription /
 \a -localizedFailureReason and \a -localizedRecoverySuggestion to get human readable description for error).
 
 @warning Only last call of this method will call completion block. If you need to track unsubscribe process from many places,
 use \b PNObservationCenter methods for this purpose.

 @since 3.4.0

 @see PNChannel class

 @see PNError class

 @see PNObservationCenter class
 
 @see +unsubscribeFromChannel:withPresenceEvent:
 */
+ (void)unsubscribeFromChannel:(PNChannel *)channel withPresenceEvent:(BOOL __unused)withPresenceEvent
    andCompletionHandlingBlock:(PNClientChannelUnsubscriptionHandlerBlock)handlerBlock DEPRECATED_MSG_ATTRIBUTE(" Use '+unsubscribeFromChannel:withCompletionHandlingBlock:' instead.");

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
+ (void)unsubscribeFromChannels:(NSArray *)channels;

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
 
 @warning Only last call of this method will call completion block. If you need to track unsubscribe process from many places, 
 use \b PNObservationCenter methods for this purpose.

 @since 3.4.0

 @see PNChannel class

 @see PNError class

 @see PNObservationCenter class
 
 @see +unsubscribeFromChannels:
 */
+ (void)unsubscribeFromChannels:(NSArray *)channels withCompletionHandlingBlock:(PNClientChannelUnsubscriptionHandlerBlock)handlerBlock;

/**
 Unsubscribe client from set of channels.
 
 @code
 @endcode
 This method extends \a +unsubscribeFromChannels: method and allow to specify on whether presence event should be generated or not.
 If \b PubNub client already subscribed on some channels and \a 'withPresenceEvent' will be set to \c YES, than \b PubNub will issue \a 'leave' 
 presence event on old channels and generate \a 'join' presence event on rest of the channels. If \a 'withPresenceEvent' is set to \c NO than 
 \b PubNub client will silently unsubscribe from old channels and re-subscribe on rest on the channels w/o any presence events.
 
 @code
 @endcode
 \b Example:
 
 @code
 [PubNub setConfiguration:[PNConfiguration defaultConfiguration] andDelegate:self];
 [PubNub connect];
 [PubNub subscribeFromChannel:[PNChannel channelsWithName:@"iosdev"]];
 [PubNub sendMessage:@"PubNub welcomes iOS developers" toChannel:[PNChannel channelWithName:@"iosdev"]];
 [PubNub unsubscribeFromChannel:[PNChannel channelsWithName:@"iosdev"] withPresenceEvent:YES];
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

 @since 3.4.0

 @see PNChannel class

 @see PNError class

 @see PNObservationCenter class
 
 @see +unsubscribeFromChannels:withPresenceEvent:withCompletionHandlingBlock:
 */
+ (void)unsubscribeFromChannels:(NSArray *)channels withPresenceEvent:(BOOL __unused)withPresenceEvent DEPRECATED_MSG_ATTRIBUTE(" Use '+unsubscribeFromChannels:' instead.");

/**
 Unsubscribe client from set of channels.
 
 @code
 @endcode
 This method extends \a +unsubscribeFromChannels:withPresenceEvent: and allow to specify unsubscription process state change handler block.
 
 @code
 @endcode
 \b Example:
 
 @code
 [PubNub setConfiguration:[PNConfiguration defaultConfiguration] andDelegate:self];
 [PubNub connect];
 [PubNub subscribeFromChannel:[PNChannel channelsWithName:@"iosdev"]];
 [PubNub sendMessage:@"PubNub welomes iOS developers" toChannel:[PNChannel channelWithName:@"iosdev"]];
 [PubNub unsubscribeFromChannels:[PNChannel channelsWithNames:@[@"iosdev", @"macosdev"]] withPresenceEvent:YES
  andCompletionHandlingBlock:^(NSArray *channels, PNError *error) {
 
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
 Array of \b PNChannel instances from which client will unsubscribe.
 
 @param handlerBlock
 The block which will be called by PubNub client as soon as unsubscription process state will change. The block takes two arguments:
 \c channels - array of \b PNChannel instances from which client unsubscribe; \c error - error because of which unsubscription failed.
 Always check \a error.code to find out what caused error (check PNErrorCodes header file and use \a -localizedDescription /
 \a -localizedFailureReason and \a -localizedRecoverySuggestion to get human readable description for error).
 
 @warning Only last call of this method will call completion block. If you need to track unsubscribe process from many places,
 use \b PNObservationCenter methods for this purpose.

 @since 3.4.0

 @see PNChannel class

 @see PNError class

 @see PNObservationCenter class
 
 @see +unsubscribeFromChannels:withPresenceEvent:
 */
+ (void)unsubscribeFromChannels:(NSArray *)channels withPresenceEvent:(BOOL __unused)withPresenceEvent
     andCompletionHandlingBlock:(PNClientChannelUnsubscriptionHandlerBlock)handlerBlock DEPRECATED_MSG_ATTRIBUTE(" Use '+unsubscribeFromChannels:withCompletionHandlingBlock:' instead.");


#pragma mark - APNS management

/**
 Enable push notifications on specified channel. This API allow to observer for messages in specific channel via
 Apple Push Notifications even if application is not running. Each time when someone post message into channel for which
 this API has been called from client side, server will send push notification to the device which used this API to
 observe for new messages. Device identification (to which push notification should be sent) done using \c pushToken.
 
 @code
 @endcode
 \b Example:
 
 @code
 [PubNub setConfiguration:[PNConfiguration defaultConfiguration] andDelegate:self];
 [PubNub connect];
 [PubNub enablePushNotificationsOnChannel:[PNChannel channelWithName:@"iosdev"] withDevicePushToken:self.devicePushToken];
 @endcode
 
 Device push token can be received using Apple's API:
 @code
 - (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
     
     // Your code here
     // ......
     // ......
     // ......
     //
 
     // Examine launch options to detect whether application was launched because of remote push notification or not
     if ([launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey]) {
        
         // Application launched because of remote push notification.
         // '[launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey]' contains dictionary with push notification payload
     }
     // Set of types may vary from the needs of your application
     UIRemoteNotificationType types = (UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound);
     
 
     // Registering your application with Apple Push Notification Server to make it possible receive push notifications
     [[UIApplication sharedApplication] registerForRemoteNotificationTypes:types];
     
 
     return YES;
 }
 
 - (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    
     // You are free to register channel for push notifications right from this callback or store device push token in property and use it later.
     [PubNub enablePushNotificationsOnChannel:[PNChannel channelWithName:@"iosdev"] withDevicePushToken:deviceToken];
 }

 - (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
 
     // Application was unable to register for remote push notifications and reason stored inside 'error' instance. If application were registered
     // for remote notifications before there is a chance that it won't be able to receive remote push notifications anymore.
 }
 
 - (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {
 
     // Application received push notification (only in foreground or if application is able to work in background),
 }
 @endcode
 
 And handle it with delegates:
 @code
 - (void)pubnubClient:(PubNub *)client didEnablePushNotificationsOnChannels:(NSArray *)channels {

     // PubNub client successfully enabled push notifications on specified set of channels and now you should prepare for remote push notifications
     // to arrive.
 }

 - (void)pubnubClient:(PubNub *)client pushNotificationEnableDidFailWithError:(PNError *)error {
 
     // PubNub client did fail to enable push notifications on specified set of channels.
     //
     // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
     // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
     // 'error.associatedObject' contains array of PNChannel instances for which PubNub client wasn't able to enable
     // push notifications.
 }
 @endcode
 
 There is also way to observe push notification enabling state from any place in your application using  \b PNObservationCenter:
 @code
 [[PNObservationCenter defaultCenter] addClientPushNotificationsEnableObserver:self
  withCallbackBlock:^(NSArray *channels, PNError *error) {

      if (error == nil) {
 
          // PubNub client successfully enabled push notifications on specified set of channels and now you should prepare for remote push
          // notifications to arrive.
      }
      else {
 
          // PubNub did fail to enable push notifications on specified channels and reason can be found in error instance.
          //
          // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
          // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
          // 'error.associatedObject' contains array of PNChannel instances for which PubNub client wasn't able to enable
          // push notifications.
      }
 }];
 @endcode

 Also observation can be done using \b NSNotificationCenter to observe this notifications: kPNClientPushNotificationEnableDidCompleteNotification,
 kPNClientPushNotificationEnableDidFailNotification.
 
 @param channel
 \b PNChannel instance for which push notification should be enabled.
 
 @param pushToken
 Device push token which is used to identify push notification recipient.
 
 @note PubNub service will keep sending push notifications till PubNub client explicitly disable them on specified channel or on all at once.

 @since 3.4.2

 @see PNChannel class

 @see PNError class

 @see PNObservationCenter class
 
 @see +enablePushNotificationsOnChannel:withDevicePushToken:andCompletionHandlingBlock:
 
 @see +disablePushNotificationsOnChannel:withDevicePushToken:
 
 @see +removeAllPushNotificationsForDevicePushToken:withDevicePushToken:
 */
+ (void)enablePushNotificationsOnChannel:(PNChannel *)channel withDevicePushToken:(NSData *)pushToken;

/**
 Enable push notifications on specified channel.
 
 @code
 @endcode
 This method extends \a +enablePushNotificationsOnChannel:withDevicePushToken: and allow to specify push
 notification enabling process handling block.
 
 @code
 @endcode
 \b Example:
 
 @code
 [PubNub setConfiguration:[PNConfiguration defaultConfiguration] andDelegate:self];
 [PubNub connect];
 [PubNub enablePushNotificationsOnChannel:[PNChannel channelWithName:@"iosdev"] withDevicePushToken:self.devicePushToken
  andCompletionHandlingBlock:^(NSArray *channels, PNError *error){
 
      if (error == nil) {

          // PubNub client successfully enabled push notifications on specified set of channels and now you should prepare for remote push 
          // notifications to arrive.
      }
      else {
 
          // PubNub did fail to enable push notifications on specified channels and reason can be found in error instance.
          //
          // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
          // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
          // 'error.associatedObject' contains array of PNChannel instances for which PubNub client wasn't able to enable
          // push notifications.
      }
 }];
 @endcode
 
 Device push token can be received using Apple's API:
 @code
 - (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
     
     // Your code here
     // ......
     // ......
     // ......
     //
 
     // Examine launch options to detect whether application was launched because of remote push notification or not
     if ([launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey]) {
        
         // Application launched because of remote push notification.
         // '[launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey]' contains dictionary with push notification payload
     }
     // Set of types may vary from the needs of your application
     UIRemoteNotificationType types = (UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound);
     
 
     // Registering your application with Apple Push Notification Server to make it possible receive push notifications
     [[UIApplication sharedApplication] registerForRemoteNotificationTypes:types];
     
 
     return YES;
 }
 
 - (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    
     // You are free to register channel for push notifications right from this callback or store device push token in property and use it later.
     [PubNub enablePushNotificationsOnChannel:[PNChannel channelWithName:@"iosdev"] withDevicePushToken:deviceToken
      andCompletionHandlingBlock:^(NSArray *channels, PNError *error){
 
          if (error == nil) {
 
             // PubNub client successfully enabled push notifications on specified set of channels and now you should prepare for remote push
             // notifications to arrive.
          }
          else {
 
              // PubNub did fail to enable push notifications on specified channels and reason can be found in error instance.
              //
              // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
              // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
              // 'error.associatedObject' contains array of PNChannel instances for which PubNub client wasn't able to enable
              // push notifications.
          }
     }];
 }

 - (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
 
     // Application was unable to register for remote push notifications and reason stored inside 'error' instance. If application were registered
     // for remote notifications before there is a chance that it won't be able to receive remote push notifications anymore.
 }
 
 - (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {
 
     // Application received push notification (only in foreground or if application is able to work in background),
 }
 @endcode
 
 And handle it with delegates:
 @code
 - (void)pubnubClient:(PubNub *)client didEnablePushNotificationsOnChannels:(NSArray *)channels {

     // PubNub client successfully enabled push notifications on specified set of channels and now you should prepare for remote push notifications
     // to arrive.
 }

 - (void)pubnubClient:(PubNub *)client pushNotificationEnableDidFailWithError:(PNError *)error {
 
     // PubNub client did fail to enable push notifications on specified set of channels.
     //
     // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
     // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
     // 'error.associatedObject' contains array of PNChannel instances for which PubNub client wasn't able to enable
     // push notifications.
 }
 @endcode
 
 There is also way to observe push notification enabling state from any place in your application using  \b PNObservationCenter:
 @code
 [[PNObservationCenter defaultCenter] addClientPushNotificationsEnableObserver:self
  withCallbackBlock:^(NSArray *channels, PNError *error) {

      if (error == nil) {
 
          // PubNub client successfully enabled push notifications on specified set of channels and now you should prepare for remote push
          // notifications to arrive.
      }
      else {
 
          // PubNub did fail to enable push notifications on specified channels and reason can be found in error instance.
          //
          // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
          // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
          // 'error.associatedObject' contains array of PNChannel instances for which PubNub client wasn't able to enable
          // push notifications.
      }
 }];
 @endcode

 Also observation can be done using \b NSNotificationCenter to observe this notifications: kPNClientPushNotificationEnableDidCompleteNotification,
 kPNClientPushNotificationEnableDidFailNotification.
 
 @param channel
 \b PNChannel instance for which push notification should be enabled.
 
 @param pushToken
 Device push token which is used to identify push notification recipient.
 
 @param handlerBlock
 The block which is called when push notification enabling state changed. The block takes two arguments:
 \c channels - list of channels for which push notification enabling state changed; \c error - error because of which push notification enabling
 failed. Always check \a error.code to find out what caused error (check PNErrorCodes header file and use \a -localizedDescription /
 \a -localizedFailureReason and \a -localizedRecoverySuggestion to get human readable description for error).
 
 @note PubNub service will keep sending push notifications till PubNub client explicitly disable them on specified channel or on all at once.
 
 @warning Only last call of this method will call completion block. If you need to track push notification enabling process from many places,
 use \b PNObservationCenter methods for this purpose.

 @since 3.4.2

 @see PNChannel class

 @see PNError class

 @see PNObservationCenter class
 
 @see +enablePushNotificationsOnChannel:withDevicePushToken:
 
 @see +disablePushNotificationsOnChannel:withDevicePushToken:
 
 @see +removeAllPushNotificationsForDevicePushToken:withDevicePushToken:
 */
+ (void)enablePushNotificationsOnChannel:(PNChannel *)channel withDevicePushToken:(NSData *)pushToken
              andCompletionHandlingBlock:(PNClientPushNotificationsEnableHandlingBlock)handlerBlock;

/**
 Enable push notifications on set of channels. This API allow to observer for messages in specified set of channels
 via Apple Push Notifications even if application is not running. Each time when someone post message into channels
 for which this API was called from client side, server will send push notification to the device which used this API to
 observe for new messages. Device identification (to which push notification should be sent) done using \c pushToken.
 
 @code
 @endcode
 \b Example:
 
 @code
 [PubNub setConfiguration:[PNConfiguration defaultConfiguration] andDelegate:self];
 [PubNub connect];
 [PubNub enablePushNotificationsOnChannels:[PNChannel channelsWithNames:@[@"iosdev", @"macosdev"]] withDevicePushToken:self.devicePushToken];
 @endcode
 
 Device push token can be received using Apple's API:
 @code
 - (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
     
     // Your code here
     // ......
     // ......
     // ......
     //
 
     // Examine launch options to detect whether application was launched because of remote push notification or not
     if ([launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey]) {
        
         // Application launched because of remote push notification.
         // '[launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey]' contains dictionary with push notification payload
     }
     // Set of types may vary from the needs of your application
     UIRemoteNotificationType types = (UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound);
     
 
     // Registering your application with Apple Push Notification Server to make it possible receive push notifications
     [[UIApplication sharedApplication] registerForRemoteNotificationTypes:types];
     
 
     return YES;
 }
 
 - (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    
     // You are free to register channel for push notifications right from this callback or store device push token in property and use it later.
     [PubNub enablePushNotificationsOnChannels:[PNChannel channelsWithNames:@[@"iosdev", @"macosdev"]] withDevicePushToken:deviceToken];
 }

 - (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
 
     // Application was unable to register for remote push notifications and reason stored inside 'error' instance. If application were registered
     // for remote notifications before there is a chance that it won't be able to receive remote push notifications anymore.
 }
 
 - (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {
 
     // Application received push notification (only in foreground or if application is able to work in background),
 }
 @endcode
 
 And handle it with delegates:
 @code
 - (void)pubnubClient:(PubNub *)client didEnablePushNotificationsOnChannels:(NSArray *)channels {

     // PubNub client successfully enabled push notifications on specified set of channels and now you should prepare for remote push notifications
     // to arrive.
 }

 - (void)pubnubClient:(PubNub *)client pushNotificationEnableDidFailWithError:(PNError *)error {
 
     // PubNub client did fail to enable push notifications on specified set of channels.
     //
     // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
     // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
     // 'error.associatedObject' contains array of PNChannel instances for which PubNub client wasn't able to enable
     // push notifications.
 }
 @endcode
 
 There is also way to observe push notification enabling state from any place in your application using  \b PNObservationCenter:
 @code
 [[PNObservationCenter defaultCenter] addClientPushNotificationsEnableObserver:self
  withCallbackBlock:^(NSArray *channels, PNError *error) {

      if (error == nil) {
 
          // PubNub client successfully enabled push notifications on specified set of channels and now you should prepare for remote push
          // notifications to arrive.
      }
      else {
 
          // PubNub did fail to enable push notifications on specified channels and reason can be found in error instance..
          //
          // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
          // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
          // 'error.associatedObject' contains array of PNChannel instances for which PubNub client wasn't able to enable
          // push notifications.
      }
 }];
 @endcode

 Also observation can be done using \b NSNotificationCenter to observe this notifications: kPNClientPushNotificationEnableDidCompleteNotification,
 kPNClientPushNotificationEnableDidFailNotification.
 
 @param channels
 Array of \b PNChannel instances for which push notification should be enabled.
 
 @param pushToken
 Device push token which is used to identify push notification recipient.
 
 @note PubNub service will keep sending push notifications till PubNub client explicitly disable them on specified channel or on all at once.

 @since 3.4.2

 @see PNChannel class

 @see PNError class

 @see PNObservationCenter class
 
 @see +enablePushNotificationsOnChannels:withDevicePushToken:andCompletionHandlingBlock:
 
 @see +disablePushNotificationsOnChannels:withDevicePushToken:
 
 @see +removeAllPushNotificationsForDevicePushToken:withDevicePushToken:
 */
+ (void)enablePushNotificationsOnChannels:(NSArray *)channels withDevicePushToken:(NSData *)pushToken;

/**
 Enable push notifications on set of channels.
 
 @code
 @endcode
 This method extends \a +enablePushNotificationsOnChannels:withDevicePushToken: and allow to specify push
 notification enabling process handling block.
 
 @code
 @endcode
 \b Example:
 
 @code
 [PubNub setConfiguration:[PNConfiguration defaultConfiguration] andDelegate:self];
 [PubNub connect];
 [PubNub enablePushNotificationsOnChannels:[PNChannel channelsWithNames:@[@"iosdev", @"macosdev"]] withDevicePushToken:self.devicePushToken
  andCompletionHandlingBlock:^(NSArray *channels, PNError *error){
 
      if (error == nil) {

          // PubNub client successfully enabled push notifications on specified set of channels and now you should prepare for remote push 
          // notifications to arrive.
      }
      else {
 
          // PubNub did fail to enable push notifications on specified channels and reason can be found in error instance.
          //
          // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
          // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
          // 'error.associatedObject' contains array of PNChannel instances for which PubNub client wasn't able to enable
          // push notifications.
      }
 }];
 @endcode
 
 Device push token can be received using Apple's API:
 @code
 - (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
     
     // Your code here
     // ......
     // ......
     // ......
     //
 
     // Examine launch options to detect whether application was launched because of remote push notification or not
     if ([launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey]) {
        
         // Application launched because of remote push notification.
         // '[launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey]' contains dictionary with push notification payload
     }
     // Set of types may vary from the needs of your application
     UIRemoteNotificationType types = (UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound);
     
 
     // Registering your application with Apple Push Notification Server to make it possible receive push notifications
     [[UIApplication sharedApplication] registerForRemoteNotificationTypes:types];
     
 
     return YES;
 }
 
 - (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    
     // You are free to register channel for push notifications right from this callback or store device push token in property and use it later.
     [PubNub enablePushNotificationsOnChannels:[PNChannel channelsWithNames:@[@"iosdev", @"macosdev"]] withDevicePushToken:self.devicePushToken
      andCompletionHandlingBlock:^(NSArray *channels, PNError *error){

          if (error == nil) {

              // PubNub client successfully enabled push notifications on specified set of channels and now you should prepare for remote push
              // notifications to arrive.
          }
          else {

              // PubNub did fail to enable push notifications on specified channels and reason can be found in error instance.
              //
              // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
              // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
              // 'error.associatedObject' contains array of PNChannel instances for which PubNub client wasn't able to enable
              // push notifications.
          }
     }];
 }

 - (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
 
     // Application was unable to register for remote push notifications and reason stored inside 'error' instance. If application were registered
     // for remote notifications before there is a chance that it won't be able to receive remote push notifications anymore.
 }
 
 - (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {
 
     // Application received push notification (only in foreground or if application is able to work in background),
 }
 @endcode
 
 And handle it with delegates:
 @code
 - (void)pubnubClient:(PubNub *)client didEnablePushNotificationsOnChannels:(NSArray *)channels {

     // PubNub client successfully enabled push notifications on specified set of channels and now you should prepare for remote push notifications
     // to arrive.
 }

 - (void)pubnubClient:(PubNub *)client pushNotificationEnableDidFailWithError:(PNError *)error {
 
     // PubNub client did fail to enable push notifications on specified set of channels.
     //
     // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
     // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
     // 'error.associatedObject' contains array of PNChannel instances for which PubNub client wasn't able to enable
     // push notifications.
 }
 @endcode
 
 There is also way to observe push notification enabling state from any place in your application using  \b PNObservationCenter:
 @code
 [[PNObservationCenter defaultCenter] addClientPushNotificationsEnableObserver:self
  withCallbackBlock:^(NSArray *channels, PNError *error) {

      if (error == nil) {
 
          // PubNub client successfully enabled push notifications on specified set of channels and now you should prepare for remote push
          // notifications to arrive.
      }
      else {
 
          // PubNub did fail to enable push notifications on specified channels and reason can be found in error instance.
          //
          // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
          // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
          // 'error.associatedObject' contains array of PNChannel instances for which PubNub client wasn't able to enable
          // push notifications.
      }
 }];
 @endcode

 Also observation can be done using \b NSNotificationCenter to observe this notifications: kPNClientPushNotificationEnableDidCompleteNotification,
 kPNClientPushNotificationEnableDidFailNotification.

 @param channels
 Array of \b PNChannel instances for which push notification should be enabled.
 
 @param pushToken
 Device push token which is used to identify push notification recipient.
 
 @param handlerBlock
 The block which is called when push notification enabling state changed. The block takes two arguments:
 \c channels - list of channels for which push notification enabling state changed; \c error - error because of which push notification enabling
 failed. Always check \a error.code to find out what caused error (check PNErrorCodes header file and use \a -localizedDescription /
 \a -localizedFailureReason and \a -localizedRecoverySuggestion to get human readable description for error).
 
 @note PubNub service will keep sending push notifications till PubNub client explicitly disable them on specified channel or on all at once.
 
 @warning Only last call of this method will call completion block. If you need to track push notification enabling process from many places,
 use \b PNObservationCenter methods for this purpose.

 @since 3.4.2

 @see PNChannel class

 @see PNError class

 @see PNObservationCenter class
 
 @see +enablePushNotificationsOnChannel:withDevicePushToken:
 
 @see +disablePushNotificationsOnChannel:withDevicePushToken:
 
 @see +removeAllPushNotificationsForDevicePushToken:withDevicePushToken:
 */
+ (void)enablePushNotificationsOnChannels:(NSArray *)channels withDevicePushToken:(NSData *)pushToken
               andCompletionHandlingBlock:(PNClientPushNotificationsEnableHandlingBlock)handlerBlock;

/**
 Disable push notifications on specified channel. After usage of this API, observation will be removed from specified
 channel and no more push notifications will be delivered to the device. Device identification (to which push
 notification should be sent) done using \c pushToken.
 
 @code
 @endcode
 \b Example:
 
 @code
 [PubNub setConfiguration:[PNConfiguration defaultConfiguration] andDelegate:self];
 [PubNub connect];
 [PubNub disablePushNotificationsOnChannel:[PNChannel channelWithName:@"iosdev"] withDevicePushToken:self.devicePushToken];
 @endcode
 
 Device push token can be received using Apple's API:
 @code
 - (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
     
     // Your code here
     // ......
     // ......
     // ......
     //
 
     // Examine launch options to detect whether application was launched because of remote push notification or not
     if ([launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey]) {
        
         // Application launched because of remote push notification.
         // '[launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey]' contains dictionary with push notification payload
     }
     // Set of types may vary from the needs of your application
     UIRemoteNotificationType types = (UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound);
     
 
     // Registering your application with Apple Push Notification Server to make it possible receive push notifications
     [[UIApplication sharedApplication] registerForRemoteNotificationTypes:types];
     
 
     return YES;
 }
 
 - (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    
     // You are free to disable push notifications from channel right from this callback or store device push token
     // in property and use it later.
     [PubNub disablePushNotificationsOnChannel:[PNChannel channelWithName:@"iosdev"] withDevicePushToken:deviceToken];
 }

 - (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
 
     // Application was unable to register for remote push notifications and reason stored inside 'error' instance. If application were registered
     // for remote notifications before there is a chance that it won't be able to receive remote push notifications anymore.
 }
 @endcode
 
 And handle it with delegates:
 @code
 - (void)pubnubClient:(PubNub *)client didDisablePushNotificationsOnChannels:(NSArray *)channels {

     // PubNub client successfully disabled push notifications on specified set of channels.
 }

 - (void)pubnubClient:(PubNub *)client pushNotificationDisableDidFailWithError:(PNError *)error {
 
     // PubNub client did fail to disable push notifications on specified set of channels.
     //
     // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
     // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
     // 'error.associatedObject' contains array of PNChannel instances for which PubNub client wasn't able to disable
     // push notifications.
 }
 @endcode
 
 There is also way to observe push notification disabling state from any place in your application using  \b PNObservationCenter:
 @code
 [[PNObservationCenter defaultCenter] addClientPushNotificationsDisableObserver:self
  withCallbackBlock:^(NSArray *channels, PNError *error) {

      if (error == nil) {
 
          // PubNub client successfully disabled push notifications on specified set of channels.
      }
      else {
 
          // PubNub did fail to disable push notifications on specified channels and reason can be found in error instance.
          //
          // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
          // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
          // 'error.associatedObject' contains array of PNChannel instances for which PubNub client wasn't able to disable
          // push notifications.
      }
 }];
 @endcode

 Also observation can be done using \b NSNotificationCenter to observe this notifications: kPNClientPushNotificationDisableDidCompleteNotification,
 kPNClientPushNotificationDisableDidFailNotification.
 
 @param channel
 \b PNChannel instance for which push notification should be disabled.
 
 @param pushToken
 Device push token which previously has been used to register for messages observation via Apple Push Notifications.

 @since 3.4.2

 @see PNChannel class

 @see PNError class

 @see PNObservationCenter class
 
 @see +disablePushNotificationsOnChannel:withDevicePushToken:andCompletionHandlingBlock:
 
 @see +removeAllPushNotificationsForDevicePushToken:withDevicePushToken:
 */
+ (void)disablePushNotificationsOnChannel:(PNChannel *)channel withDevicePushToken:(NSData *)pushToken;

/**
 Disable push notifications on specified channel.
 
 @code
 @endcode
 This method extends \a +disablePushNotificationsOnChannel:withDevicePushToken: and allow to specify push
 notifications disable process handling block.

 @code
 @endcode
 \b Example:
 
 @code
 [PubNub setConfiguration:[PNConfiguration defaultConfiguration] andDelegate:self];
 [PubNub connect];
 [PubNub disablePushNotificationsOnChannel:[PNChannel channelWithName:@"iosdev"] withDevicePushToken:self.devicePushToken
  andCompletionHandlingBlock:^(NSArray *channels, PNError *error){
      
     if (error == nil) {

         // PubNub client successfully disabled push notifications on specified set of channels.
     }
     else {
 
         // PubNub did fail to disable push notifications on specified channels and reason can be found in error instance.
         //
         // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
         // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
         // 'error.associatedObject' contains array of PNChannel instances for which PubNub client wasn't able to disable
         // push notifications.
     }
 }];
 @endcode
 
 Device push token can be received using Apple's API:
 @code
 - (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
     
     // Your code here
     // ......
     // ......
     // ......
     //
 
     // Examine launch options to detect whether application was launched because of remote push notification or not
     if ([launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey]) {
        
         // Application launched because of remote push notification.
         // '[launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey]' contains dictionary with push notification payload
     }
     // Set of types may vary from the needs of your application
     UIRemoteNotificationType types = (UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound);
     
 
     // Registering your application with Apple Push Notification Server to make it possible receive push notifications
     [[UIApplication sharedApplication] registerForRemoteNotificationTypes:types];
     
 
     return YES;
 }
 
 - (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {

     // You are free to disable push notifications from channel right from this callback or store device push token
     // in property and use it later.
     [PubNub disablePushNotificationsOnChannel:[PNChannel channelWithName:@"iosdev"] withDevicePushToken:deviceToken
      andCompletionHandlingBlock:^(NSArray *channels, PNError *error){
      
          if (error == nil) {
              
              // PubNub client successfully disabled push notifications on specified set of channels.
          }
          else {
 
              // PubNub did fail to disable push notifications on specified channels and reason can be found in error instance.
              //
              // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
              // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
              // 'error.associatedObject' contains array of PNChannel instances for which PubNub client wasn't able to disable
              // push notifications.
          }
     }];
 }

 - (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
 
     // Application was unable to register for remote push notifications and reason stored inside 'error' instance. If application were registered
     // for remote notifications before there is a chance that it won't be able to receive remote push notifications anymore.
 }
 @endcode
 
 And handle it with delegates:
 @code
 - (void)pubnubClient:(PubNub *)client didDisablePushNotificationsOnChannels:(NSArray *)channels {

     // PubNub client successfully disabled push notifications on specified set of channels.
 }

 - (void)pubnubClient:(PubNub *)client pushNotificationDisableDidFailWithError:(PNError *)error {
 
     // PubNub client did fail to disable push notifications on specified set of channels.
     //
     // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
     // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
     // 'error.associatedObject' contains array of PNChannel instances for which PubNub client wasn't able to disable
     // push notifications.
 }
 @endcode
 
 There is also way to observe push notification disabling state from any place in your application using  \b PNObservationCenter:
 @code
 [[PNObservationCenter defaultCenter] addClientPushNotificationsDisableObserver:self
  withCallbackBlock:^(NSArray *channels, PNError *error) {

      if (error == nil) {
 
          // PubNub client successfully disabled push notifications on specified set of channels.
      }
      else {
 
          // PubNub did fail to disable push notifications on specified channels and reason can be found in error instance.
          //
          // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
          // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
          // 'error.associatedObject' contains array of PNChannel instances for which PubNub client wasn't able to disable
          // push notifications.
      }
 }];
 @endcode

 Also observation can be done using \b NSNotificationCenter to observe this notifications: kPNClientPushNotificationDisableDidCompleteNotification,
 kPNClientPushNotificationDisableDidFailNotification.
 
 @param channel
 \b PNChannel instance for which push notification should be disabled.
 
 @param pushToken
 Device push token which previously has been used to register for messages observation via Apple Push Notifications.
 
 @param handlerBlock
 The block which is called when push notification disabling state changed. The block takes two arguments:
 \c channels - list of channels for which push notification disabling state changed; \c error - error because of which push notification disabling
 failed. Always check \a error.code to find out what caused error (check PNErrorCodes header file and use \a -localizedDescription /
 \a -localizedFailureReason and \a -localizedRecoverySuggestion to get human readable description for error).
 
 @warning Only last call of this method will call completion block. If you need to track push notification disabling
 process from many places, use \b PNObservationCenter methods for this purpose.

 @since 3.4.2

 @see PNChannel class

 @see PNError class

 @see PNObservationCenter class
 
 @see +disablePushNotificationsOnChannel:withDevicePushToken:
 
 @see +removeAllPushNotificationsForDevicePushToken:withDevicePushToken:
 */
+ (void)disablePushNotificationsOnChannel:(PNChannel *)channel withDevicePushToken:(NSData *)pushToken
              andCompletionHandlingBlock:(PNClientPushNotificationsDisableHandlingBlock)handlerBlock;

/**
 Disable push notifications on set of channels. After usage of this API, observation will be removed from specified
 channel and no more push notifications will be delivered to the device. Device identification (to which push
 notification should be sent) done using \c pushToken.
 
 @code
 @endcode
 \b Example:
 
 @code
 [PubNub setConfiguration:[PNConfiguration defaultConfiguration] andDelegate:self];
 [PubNub connect];
 [PubNub disablePushNotificationsOnChannels:[PNChannel channelsWithNames:@[@"iosdev", @"macosdev"]] withDevicePushToken:self.devicePushToken];
 @endcode
 
 Device push token can be received using Apple's API:
 @code
 - (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
     
     // Your code here
     // ......
     // ......
     // ......
     //
 
     // Examine launch options to detect whether application was launched because of remote push notification or not
     if ([launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey]) {
        
         // Application launched because of remote push notification.
         // '[launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey]' contains dictionary with push notification payload
     }
     // Set of types may vary from the needs of your application
     UIRemoteNotificationType types = (UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound);
     
 
     // Registering your application with Apple Push Notification Server to make it possible receive push notifications
     [[UIApplication sharedApplication] registerForRemoteNotificationTypes:types];
     
 
     return YES;
 }
 
 - (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    
     // You are free to disable push notifications from channel right from this callback or store device push token
     // in property and use it later.
     [PubNub disablePushNotificationsOnChannels:[PNChannel channelsWithNames:@[@"iosdev", @"macosdev"]] withDevicePushToken:deviceToken];
 }

 - (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
 
     // Application was unable to register for remote push notifications and reason stored inside 'error' instance. If application were registered
     // for remote notifications before there is a chance that it won't be able to receive remote push notifications anymore.
 }
 @endcode
 
 And handle it with delegates:
 @code
 - (void)pubnubClient:(PubNub *)client didDisablePushNotificationsOnChannels:(NSArray *)channels {

     // PubNub client successfully disabled push notifications on specified set of channels.
 }

 - (void)pubnubClient:(PubNub *)client pushNotificationDisableDidFailWithError:(PNError *)error {
 
     // PubNub client did fail to disable push notifications on specified set of channels.
     //
     // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
     // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
     // 'error.associatedObject' contains array of PNChannel instances for which PubNub client wasn't able to disable
     // push notifications.
 }
 @endcode
 
 There is also way to observe push notification disabling state from any place in your application using  \b PNObservationCenter:
 @code
 [[PNObservationCenter defaultCenter] addClientPushNotificationsDisableObserver:self
  withCallbackBlock:^(NSArray *channels, PNError *error) {

      if (error == nil) {
 
          // PubNub client successfully disabled push notifications on specified set of channels.
      }
      else {
 
          // PubNub did fail to disable push notifications on specified channels and reason can be found in error instance.
          //
          // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
          // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
          // 'error.associatedObject' contains array of PNChannel instances for which PubNub client wasn't able to disable
          // push notifications.
      }
 }];
 @endcode

 Also observation can be done using \b NSNotificationCenter to observe this notifications: kPNClientPushNotificationDisableDidCompleteNotification,
 kPNClientPushNotificationDisableDidFailNotification.
 
 @param channels
 Array of \b PNChannel instances for which push notification should be disabled.
 
 @param pushToken
 Device push token which previously has been used to register for messages observation via Apple Push Notifications.

 @since 3.4.2

 @see PNChannel class

 @see PNError class

 @see PNObservationCenter class
 
 @see +disablePushNotificationsOnChannels:withDevicePushToken:andCompletionHandlingBlock:
 
 @see +removeAllPushNotificationsForDevicePushToken:withDevicePushToken:
 */
+ (void)disablePushNotificationsOnChannels:(NSArray *)channels withDevicePushToken:(NSData *)pushToken;

/**
 Disable push notifications on set of channel.
 
 @code
 @endcode
 This method extends \a +disablePushNotificationsOnChannels:withDevicePushToken: and allow to specify push
 notifications disable process handling block.
 
 @code
 @endcode
 \b Example:
 
 @code
 [PubNub setConfiguration:[PNConfiguration defaultConfiguration] andDelegate:self];
 [PubNub connect];
 [PubNub disablePushNotificationsOnChannels:[PNChannel channelsWithNames:@[@"iosdev", @"macosdev"]] withDevicePushToken:self.devicePushToken
  andCompletionHandlingBlock:^(NSArray *channels, PNError *error){
      
     if (error == nil) {
 
         // PubNub client successfully disabled push notifications on specified set of channels.
     }
     else {
 
         // PubNub did fail to disable push notifications on specified channels and reason can be found in error instance.
         //
         // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
         // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
         // 'error.associatedObject' contains array of PNChannel instances for which PubNub client wasn't able to disable
         // push notifications.
     }
 }];
 @endcode
 
 Device push token can be received using Apple's API:
 @code
 - (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
     
     // Your code here
     // ......
     // ......
     // ......
     //
 
     // Examine launch options to detect whether application was launched because of remote push notification or not
     if ([launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey]) {
        
         // Application launched because of remote push notification.
         // '[launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey]' contains dictionary with push notification payload
     }
     // Set of types may vary from the needs of your application
     UIRemoteNotificationType types = (UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound);
     
 
     // Registering your application with Apple Push Notification Server to make it possible receive push notifications
     [[UIApplication sharedApplication] registerForRemoteNotificationTypes:types];
     
 
     return YES;
 }
 
 - (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    
     // You are free to disable push notifications from channel right from this callback or store device push token
     // in property and use it later.
     [PubNub disablePushNotificationsOnChannels:[PNChannel channelsWithNames:@[@"iosdev", @"macosdev"]] withDevicePushToken:deviceToken
      andCompletionHandlingBlock:^(NSArray *channels, PNError *error){
      
          if (error == nil) {
              
              // PubNub client successfully disabled push notifications on specified set of channels.
          }
          else {
 
              // PubNub did fail to disable push notifications on specified channels and reason can be found in error instance.
              //
              // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
              // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
              // 'error.associatedObject' contains array of PNChannel instances for which PubNub client wasn't able to disable
              // push notifications.
          }
     }];
 }

 - (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
 
     // Application was unable to register for remote push notifications and reason stored inside 'error' instance. If application were registered
     // for remote notifications before there is a chance that it won't be able to receive remote push notifications anymore.
 }
 @endcode
 
 And handle it with delegates:
 @code
 - (void)pubnubClient:(PubNub *)client didDisablePushNotificationsOnChannels:(NSArray *)channels {

     // PubNub client successfully disabled push notifications on specified set of channels.
 }

 - (void)pubnubClient:(PubNub *)client pushNotificationDisableDidFailWithError:(PNError *)error {
 
     // PubNub client did fail to disable push notifications on specified set of channels.
     //
     // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
     // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
     // 'error.associatedObject' contains array of PNChannel instances for which PubNub client wasn't able to disable
     // push notifications.
 }
 @endcode
 
 There is also way to observe push notification disabling state from any place in your application using  \b PNObservationCenter:
 @code
 [[PNObservationCenter defaultCenter] addClientPushNotificationsDisableObserver:self
  withCallbackBlock:^(NSArray *channels, PNError *error) {

      if (error == nil) {
 
          // PubNub client successfully disabled push notifications on specified set of channels.
      }
      else {
 
          // PubNub did fail to disable push notifications on specified channels and reason can be found in error instance.
          //
          // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
          // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
          // 'error.associatedObject' contains array of PNChannel instances for which PubNub client wasn't able to disable
          // push notifications.
      }
 }];
 @endcode

 Also observation can be done using \b NSNotificationCenter to observe this notifications: kPNClientPushNotificationDisableDidCompleteNotification,
 kPNClientPushNotificationDisableDidFailNotification.
 
 @param channels
 Array of \b PNChannel instances for which push notification should be disabled.
 
 @param pushToken
 Device push token which previously has been used to register for messages observation via Apple Push Notifications.
 
 @param handlerBlock
 The block which is called when push notification disabling state changed. The block takes two arguments:
 \c channels - list of channels for which push notification disabling state changed; \c error - error because of which push notification disabling
 failed. Always check \a error.code to find out what caused error (check PNErrorCodes header file and use \a -localizedDescription /
 \a -localizedFailureReason and \a -localizedRecoverySuggestion to get human readable description for error).
 
 @warning Only last call of this method will call completion block. If you need to track push notification disabling
 process from many places, use \b PNObservationCenter methods for this purpose.

 @since 3.4.2

 @see PNChannel class

 @see PNError class

 @see PNObservationCenter class
 
 @see +disablePushNotificationsOnChannels:withDevicePushToken:
 
 @see +removeAllPushNotificationsForDevicePushToken:withDevicePushToken:
 */
+ (void)disablePushNotificationsOnChannels:(NSArray *)channels withDevicePushToken:(NSData *)pushToken
                andCompletionHandlingBlock:(PNClientPushNotificationsDisableHandlingBlock)handlerBlock;

/**
 Disable push notification from all channels at which it has been enabled with specified \c pushToken. As soon as this
 request will be completed, \b PubNub client won't receive remote push notification on any of the channels when new message is posted into it.
 
 @code
 @endcode
 \b Example:
 
 @code
 [PubNub setConfiguration:[PNConfiguration defaultConfiguration] andDelegate:self];
 [PubNub connect];
 [PubNub removeAllPushNotificationsForDevicePushToken:self.devicePushToken
  withCompletionHandlingBlock:^(PNError *error) {

         if (error == nil) {

             // Push notifications has been disabled from all channels on which it has been enabled using specified
             // device push notification.
         }
         else {

             // PubNub did fail to disable push notifications from all channels on which client subscribed with
             // specified device push notification. Error reason can be found in error instance.
         }
  }];
 @endcode
 
 Device push token can be received using Apple's API:
 @code
 - (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
     
     // Your code here
     // ......
     // ......
     // ......
     //
 
     // Examine launch options to detect whether application was launched because of remote push notification or not
     if ([launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey]) {
        
         // Application launched because of remote push notification.
         // '[launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey]' contains dictionary with push notification payload
     }
     // Set of types may vary from the needs of your application
     UIRemoteNotificationType types = (UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound);
     
 
     // Registering your application with Apple Push Notification Server to make it possible receive push notifications
     [[UIApplication sharedApplication] registerForRemoteNotificationTypes:types];
     
 
     return YES;
 }
 
 - (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {

     // You are free to disable push notifications from all channels right from this callback or store device push token in property and use it later.
     [PubNub removeAllPushNotificationsForDevicePushToken:deviceToken withCompletionHandlingBlock:^(PNError *error) {

         if (error == nil) {

             // Push notifications has been disabled from all channels on which it has been enabled using specified
             // device push notification.
         }
         else {

             // PubNub did fail to disable push notifications from all channels on which client subscribed with
             // specified device push notification. Error reason can be found in error instance.
         }
     }];
 }

 - (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
 
     // Application was unable to register for remote push notifications and reason stored inside 'error' instance. If application were registered
     // for remote notifications before there is a chance that it won't be able to receive remote push notifications anymore.
 }
 @endcode
 
 And handle it with delegates:
 @code
 - (void)pubnubClientDidRemovePushNotifications:(PubNub *)client {

     // Push notifications has been disabled from all channels on which it has been enabled using specified device
     // push notification.
 }

 - (void)pubnubClient:(PubNub *)client pushNotificationsRemoveFromChannelsDidFailWithError:(PNError *)error {

     // PubNub did fail to disable push notifications from all channels on which client subscribed with specified
     // device push notification. Error reason can be found in error instance.
 }
 @endcode
 
 There is also way to observe push notification disable process from any place in your application using \b PNObservationCenter:
 @code
 [[PNObservationCenter defaultCenter] addClientPushNotificationsRemoveObserver:self withCallbackBlock:^(PNError *error) {
 
     if (error == nil) {

         // Push notifications has been disabled from all channels on which it has been enabled using specified
         // device push notification.
     }
     else {

         // PubNub did fail to disable push notifications from all channels on which client subscribed with
         // specified device push notification. Error reason can be found in error instance.
     }
 }];
 @endcode

 Also observation can be done using \b NSNotificationCenter to observe this notifications: kPNClientPushNotificationRemoveDidCompleteNotification,
 kPNClientPushNotificationRemoveDidFailNotification.
 
 @param pushToken
 Device push token which previously has been used to register for messages observation via Apple Push Notifications.
 
 @param handlerBlock
 The block which is called when push notification disabling state changed. The block takes one argument:
 \c error - error because of which push notification disabling failed. Always check \a error.code to find out what caused error (check PNErrorCodes
 header file and use \a -localizedDescription / \a -localizedFailureReason and \a -localizedRecoverySuggestion to get human readable description for error).

 @warning Only last call of this method will call completion block. If you need to track push notification removal
 process from many places, use \b PNObservationCenter methods for this purpose.

 @since 3.4.2

 @see PNChannel class

 @see PNError class

 @see PNObservationCenter class

 @see +requestPushNotificationEnabledChannelsForDevicePushToken:withCompletionHandlingBlock:
 */
+ (void)removeAllPushNotificationsForDevicePushToken:(NSData *)pushToken
                         withCompletionHandlingBlock:(PNClientPushNotificationsRemoveHandlingBlock)handlerBlock;

/**
 Receive list of channels on which push notifications has been enabled with specified \c pushToken.
 
 @code
 @endcode
 \b Example:
 
 @code
 [PubNub setConfiguration:[PNConfiguration defaultConfiguration] andDelegate:self];
 [PubNub connect];
 [PubNub requestPushNotificationEnabledChannelsForDevicePushToken:self.devicePushToken
  withCompletionHandlingBlock:^(NSArray *channels, PNError *error) {

      if (error == nil) {

          // PubNub client successfully pulled out list of channels for which message observation has been enabled
          // with specified device push token.
      }
      else {

          // PubNub client did fail to pull out list of channels for which message observation has been enabled with
          // specified device push token.
      }
  }];
 @endcode
 
 Device push token can be received using Apple's API:
 @code
 - (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
     
     // Your code here
     // ......
     // ......
     // ......
     //
 
     // Examine launch options to detect whether application was launched because of remote push notification or not
     if ([launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey]) {
        
         // Application launched because of remote push notification.
         // '[launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey]' contains dictionary with push notification payload
     }
     // Set of types may vary from the needs of your application
     UIRemoteNotificationType types = (UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound);
     
 
     // Registering your application with Apple Push Notification Server to make it possible receive push notifications
     [[UIApplication sharedApplication] registerForRemoteNotificationTypes:types];
     
 
     return YES;
 }
 
 - (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    
     // You are free to pull out all channels for which push notification hass been enabled right from this callback or store device push 
     // token in property and use it later.
     [PubNub requestPushNotificationEnabledChannelsForDevicePushToken:deviceToken
      withCompletionHandlingBlock:^(NSArray *channels, PNError *error) {

          if (error == nil) {

              // PubNub client successfully pulled out list of channels for which message observation has been enabled
              // with specified device push token.
          }
          else {

              // PubNub client did fail to pull out list of channels for which message observation has been enabled with
              // specified device push token.
          }
     }];
 }

 - (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
 
     // Application was unable to register for remote push notifications and reason stored inside 'error' instance. If application were registered
     // for remote notifications before there is a chance that it won't be able to receive remote push notifications anymore.
 }
 @endcode
 
 And handle it with delegates:
 @code
  - (void)pubnubClient:(PubNub *)client didReceivePushNotificationEnabledChannels:(NSArray *)channels {
 
     // PubNub client successfully pulled out list of channels for which message observation has been enabled with
     // specified device push token.
 }
 
 - (void)pubnubClient:(PubNub *)client pushNotificationEnabledChannelsReceiveDidFailWithError:(PNError *)error {

     // PubNub client did fail to pull out list of channels for which message observation has been enabled with
     // specified device push token.
 }
 @endcode
 
 There is also way to observe connection state from any place in your application using  \b PNObservationCenter:
 @code
 [[PNObservationCenter defaultCenter] addClientPushNotificationsEnabledChannelsObserver:self
  withCallbackBlock:^(NSArray *channels, PNError *error) {
 
     if (error == nil) {
 
         // PubNub client successfully pulled out list of channels for which message observation has been enabled with
         // specified device push token.
     }
     else {

         // PubNub client did fail to pull out list of channels for which message observation has been enabled with
         // specified device push token.
     }
 }];
 @endcode

 Also observation can be done using \b NSNotificationCenter to observe this notifications: kPNClientPushNotificationChannelsRetrieveDidCompleteNotification,
 kPNClientPushNotificationChannelsRetrieveDidFailNotification.
 
 @param pushToken
 Device push token which previously has been used to register for messages observation via Apple Push Notifications.
 
 @param handlerBlock
 The block which is called when push notification disabling state changed. The block takes two arguments:
 \c channels - return list of channels for which push notification has been enabled with specified device push token;
 \c error - error because of push notification enabled channels fetch failed. Always check \a error.code to find out what
 caused error (check PNErrorCodes header file and use \a -localizedDescription / \a -localizedFailureReason and
 \a -localizedRecoverySuggestion to get human readable description for error).

 @warning Only last call of this method will call completion block. If you need to track push notification enabled
 channels retrieval process from many places, use \b PNObservationCenter methods for this purpose.

 @since 3.4.2

 @see PNChannel class

 @see PNError class

 @see PNObservationCenter class

 @see +removeAllPushNotificationsForDevicePushToken:withCompletionHandlingBlock:
 */
+ (void)requestPushNotificationEnabledChannelsForDevicePushToken:(NSData *)pushToken
                                     withCompletionHandlingBlock:(PNClientPushNotificationsEnabledChannelsHandlingBlock)handlerBlock;


#pragma mark - PAM management

/**
 Grant \a 'read' access right on \a 'application' access level which will be valid for specified amount of time.

 @code
 @endcode
 \b Example:

 @code
 [PubNub setupWithConfiguration:[PNConfiguration configurationForOrigin:@"pubsub.pubnub.com" publishKey:@"demo"
                                                           subscribeKey:@"demo" secretKey:@"my-secret-key"]
                    andDelegate:self];
 [PubNub connect];
 [PubNub grantReadAccessRightForApplicationAtPeriod:10];
 [PubNub grantWriteAccessRightForChannel:[PNChannel channelWithName:@"iosdev"] forPeriod:10];
 @endcode

 Code above configure access rights in a way, which won't allow message posting to any channels except \a 'iosdev'
 channel for which \a 'write' access rights has been granted for \b 10 minutes. But despite the fact that channel
 configured only for \a 'write' access rights, because of upper-layer configuration,
 \b PubNub client allowed to subscribe on \a 'iosdev' channel.

 And handle it with delegates:
 @code
 - (void)pubnubClient:(PubNub *)client didChangeAccessRights:(PNAccessRightsCollection *)accessRightsCollection {

     // PubNub client successfully changed access rights for 'application' access level.
 }

 - (void)pubnubClient:(PubNub *)client accessRightsChangeDidFailWithError:(PNError *)error {

     // PubNub client did fail to revoke access rights from application level.
     //
     // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
     // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
     // 'error.associatedObject' contains PNAccessRightOptions instance which describes access level for which change
     // has been requested.
 }
 @endcode

 There is also way to observe access rights change process from any place in your application using \b PNObservationCenter:
 @code
 [[PNObservationCenter defaultCenter] addAccessRightsChangeObserver:self withBlock:^(PNAccessRightsCollection *collection, PNError *error) {

     if (error == nil) {

         // PubNub client successfully changed access rights for 'application' access level.
     }
     else {

         // PubNub client did fail to revoke access rights from application level.
         //
         // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
         // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
         // 'error.associatedObject' contains PNAccessRightOptions instance which describes access level for which change
         // has been requested.
     }
 }];
 @endcode

 Also observation can be done using \b NSNotificationCenter to observe this notifications: kPNClientAccessRightsChangeDidCompleteNotification,
 kPNClientAccessRightsChangeDidFailNotification.

 @note To be able use this API, you should provide \a 'secret' key which is used for signature generation.

 @note Make sure that you enabled "Access Manager" on https://admin.pubnub.com.

 @note You can pass a value less than \c 0 as \a 'accessPeriodDuration' argument to use default value (default value is \b 1440 minutes).

 @note When this API is used, it will grant \a 'read' access right and revoke \a 'write' access right for
 \a 'application' access level.

 @warning \a 'application' access level is top-layer of access tree. If any of child access levels (\a 'channel' or
 \a 'user') grant \a 'write' access rights, then \b PubNub client will ignore the fact that top-layer forbid \a 'write'
 access rights and allow to post messages into target channel (for which \a 'write' access right has been granted).

 @param accessPeriodDuration
 Duration in minutes during which \a 'application' access level is granted with \a 'read' access rights.

 @since 3.5.3

 @see PNConfiguration class

 @see PNChannel class

 @see PNAccessRightOptions class

 @see PNAccessRightsCollection class

 @see PNObservationCenter class

 @see +grantReadAccessRightForApplicationAtPeriod:andCompletionHandlingBlock:

 @see +grantWriteAccessRightForChannel:forPeriod:
 */
+ (void)grantReadAccessRightForApplicationAtPeriod:(NSInteger)accessPeriodDuration;

/**
 Grant \a 'read' access right on \a 'application' access level which will be valid for specified amount of time.

 @code
 @endcode
 This method extends \a +grantReadAccessRightForApplicationAtPeriod: and allow to specify access rights change
 handler block.

 @code
 @endcode
 \b Example:

 @code
 [PubNub setupWithConfiguration:[PNConfiguration configurationForOrigin:@"pubsub.pubnub.com" publishKey:@"demo"
                                                           subscribeKey:@"demo" secretKey:@"my-secret-key"]
                    andDelegate:self];
 [PubNub connect];
 [PubNub grantReadAccessRightForApplicationAtPeriod:10
                         andCompletionHandlingBlock:^(PNAccessRightsCollection *collection, PNError *error) {

     if (error == nil) {

         // PubNub client successfully changed access rights for 'application' access level.
     }
     else {

         // PubNub client did fail to revoke access rights from application level.
         //
         // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
         // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
         // 'error.associatedObject' contains PNAccessRightOptions instance which describes access level for which change
         // has been requested.
     }
 }];
 [PubNub grantWriteAccessRightForChannel:[PNChannel channelWithName:@"iosdev"] forPeriod:10];
 @endcode

 Code above configure access rights in a way, which won't allow message posting to any channels except \a 'iosdev'
 channel for which \a 'write' access rights has been granted for \b 10 minutes. But despite the fact that channel
 configured only for \a 'write' access rights, because of upper-layer configuration,
 \b PubNub client allowed to subscribe on \a 'iosdev' channel.

 And handle it with delegates:
 @code
 - (void)pubnubClient:(PubNub *)client didChangeAccessRights:(PNAccessRightsCollection *)accessRightsCollection {

     // PubNub client successfully changed access rights for 'application' access level.
 }

 - (void)pubnubClient:(PubNub *)client accessRightsChangeDidFailWithError:(PNError *)error {

     // PubNub client did fail to revoke access rights from application level.
     //
     // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
     // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
     // 'error.associatedObject' contains PNAccessRightOptions instance which describes access level for which change
     // has been requested.
 }
 @endcode

 There is also way to observe access rights change process from any place in your application using \b PNObservationCenter:
 @code
 [[PNObservationCenter defaultCenter] addAccessRightsChangeObserver:self withBlock:^(PNAccessRightsCollection *collection, PNError *error) {

     if (error == nil) {

         // PubNub client successfully changed access rights for 'application' access level.
     }
     else {

         // PubNub client did fail to revoke access rights from application level.
         //
         // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
         // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
         // 'error.associatedObject' contains PNAccessRightOptions instance which describes access level for which change
         // has been requested.
     }
 }];
 @endcode

 Also observation can be done using \b NSNotificationCenter to observe this notifications: kPNClientAccessRightsChangeDidCompleteNotification,
 kPNClientAccessRightsChangeDidFailNotification.

 @note To be able use this API, you should provide \a 'secret' key which is used for signature generation.

 @note Make sure that you enabled "Access Manager" on https://admin.pubnub.com.

 @note You can pass a value less than \c 0 as \a 'accessPeriodDuration' argument to use default value (default value is \b 1440 minutes).

 @note When this API is used, it will grant \a 'read' access right and revoke \a 'write' access right for
 \a 'application' access level.

 @warning \a 'application' access level is top-layer of access tree. If any of child access levels (\a 'channel' or
 \a 'user') grant \a 'write' access rights, then \b PubNub client will ignore the fact that top-layer forbid \a 'write'
 access rights and allow to post messages into target channel (for which \a 'write' access right has been granted).

 @param accessPeriodDuration
 Duration in minutes during which \a 'application' access level is granted with \a 'read' access rights.

 @param handlerBlock
 The block which will be called by \b PubNub client when one of success or error events will be received. The block
 takes two arguments:
 \c collection - \b PNAccessRightsCollection instance which hold set of \b PNAccessRightsInformation instances to
 describe new \a 'application' access rights; \c error - error which describes what exactly went wrong
 during access rights change. Always check \a error.code to find out what caused error (check PNErrorCodes header file
 and use \a -localizedDescription / \a -localizedFailureReason and \a -localizedRecoverySuggestion to get human readable description for error).

 @since 3.5.3

 @see PNConfiguration class

 @see PNChannel class

 @see PNAccessRightOptions class

 @see PNAccessRightsCollection class

 @see PNObservationCenter class

 @see +grantReadAccessRightForApplicationAtPeriod:andCompletionHandlingBlock:

 @see +grantWriteAccessRightForChannel:forPeriod:
 */
+ (void)grantReadAccessRightForApplicationAtPeriod:(NSInteger)accessPeriodDuration
                        andCompletionHandlingBlock:(PNClientChannelAccessRightsChangeBlock)handlerBlock;

/**
 Grant \a 'write' access right on \a 'application' access level which will be valid for specified amount of time.

 @code
 @endcode
 \b Example:

 @code
 [PubNub setupWithConfiguration:[PNConfiguration configurationForOrigin:@"pubsub.pubnub.com" publishKey:@"demo"
                                                           subscribeKey:@"demo" secretKey:@"my-secret-key"]
                    andDelegate:self];
 [PubNub connect];
 [PubNub grantWriteAccessRightForApplicationAtPeriod:10];
 [PubNub grantReadAccessRightForChannel:[PNChannel channelWithName:@"iosdev"] forPeriod:10];
 @endcode

 Code above configure access rights in a way, which won't allow subscription to any channels except \a 'iosdev'
 channel for which \a 'read' access rights has been granted for \b 10 minutes. But despite the fact that channel
 configured only for \a 'read' access rights, because of upper-layer configuration, \b PubNub client allowed to
 publish on \a 'iosdev' channel.

 And handle it with delegates:
 @code
 - (void)pubnubClient:(PubNub *)client didChangeAccessRights:(PNAccessRightsCollection *)accessRightsCollection {

     // PubNub client successfully changed access rights for 'application' access level.
 }

 - (void)pubnubClient:(PubNub *)client accessRightsChangeDidFailWithError:(PNError *)error {

     // PubNub client did fail to revoke access rights from application level.
     //
     // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
     // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
     // 'error.associatedObject' contains PNAccessRightOptions instance which describes access level for which change
     // has been requested.
 }
 @endcode

 There is also way to observe access rights change process from any place in your application using \b PNObservationCenter:
 @code
 [[PNObservationCenter defaultCenter] addAccessRightsChangeObserver:self withBlock:^(PNAccessRightsCollection *collection, PNError *error) {

     if (error == nil) {

         // PubNub client successfully changed access rights for 'application' access level.
     }
     else {

         // PubNub client did fail to revoke access rights from application level.
         //
         // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
         // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
         // 'error.associatedObject' contains PNAccessRightOptions instance which describes access level for which change
         // has been requested.
     }
 }];
 @endcode

 Also observation can be done using \b NSNotificationCenter to observe this notifications: kPNClientAccessRightsChangeDidCompleteNotification,
 kPNClientAccessRightsChangeDidFailNotification.

 @note To be able use this API, you should provide \a 'secret' key which is used for signature generation.

 @note Make sure that you enabled "Access Manager" on https://admin.pubnub.com.

 @note You can pass a value less than \c 0 as \a 'accessPeriodDuration' argument to use default value (default value is \b 1440 minutes).

 @note When this API is used, it will grant \a 'write' access right and revoke \a 'read' access right for
 \a 'application' access level.

 @warning \a 'application' access level is top-layer of access tree. If any of child access levels (\a 'channel' or
 \a 'user') grant \a 'read' access rights, then \b PubNub client will ignore the fact that top-layer forbid \a 'read'
 access rights and allow to subscribe on target channel (for which \a 'read' access right has been granted).

 @param accessPeriodDuration
 Duration in minutes during which \a 'application' access level is granted with \a 'write' access rights.

 @since 3.5.3

 @see PNConfiguration class

 @see PNChannel class

 @see PNAccessRightOptions class

 @see PNAccessRightsCollection class

 @see PNObservationCenter class

 @see +grantReadAccessRightForApplicationAtPeriod:andCompletionHandlingBlock:

 @see +grantWriteAccessRightForChannel:forPeriod:
 */
+ (void)grantWriteAccessRightForApplicationAtPeriod:(NSInteger)accessPeriodDuration;

/**
 Grant \a 'write' access right on \a 'application' access level which will be valid for specified amount of time.

 @code
 @endcode
 This method extends \a +grantWriteAccessRightForApplicationAtPeriod: and allow to specify access rights change
 handler block.

 @code
 @endcode
 \b Example:

 @code
 [PubNub setupWithConfiguration:[PNConfiguration configurationForOrigin:@"pubsub.pubnub.com" publishKey:@"demo"
                                                           subscribeKey:@"demo" secretKey:@"my-secret-key"]
                    andDelegate:self];
 [PubNub connect];
 [PubNub grantWriteAccessRightForApplicationAtPeriod:10
                          andCompletionHandlingBlock:^(PNAccessRightsCollection *collection, PNError *error) {

     if (error == nil) {

         // PubNub client successfully changed access rights for 'application' access level.
     }
     else {

         // PubNub client did fail to revoke access rights from application level.
         //
         // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
         // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
         // 'error.associatedObject' contains PNAccessRightOptions instance which describes access level for which change
         // has been requested.
     }
 }];
 [PubNub grantReadAccessRightForChannel:[PNChannel channelWithName:@"iosdev"] forPeriod:10];
 @endcode

 Code above configure access rights in a way, which won't allow subscription to any channels except \a 'iosdev'
 channel for which \a 'read' access rights has been granted for \b 10 minutes. But despite the fact that channel
 configured only for \a 'read' access rights, because of upper-layer configuration, \b PubNub client allowed to
 publish on \a 'iosdev' channel.

 And handle it with delegates:
 @code
 - (void)pubnubClient:(PubNub *)client didChangeAccessRights:(PNAccessRightsCollection *)accessRightsCollection {

     // PubNub client successfully changed access rights for 'application' access level.
 }

 - (void)pubnubClient:(PubNub *)client accessRightsChangeDidFailWithError:(PNError *)error {

     // PubNub client did fail to revoke access rights from application level.
     //
     // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
     // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
     // 'error.associatedObject' contains PNAccessRightOptions instance which describes access level for which change
     // has been requested.
 }
 @endcode

 There is also way to observe access rights change process from any place in your application using \b PNObservationCenter:
 @code
 [[PNObservationCenter defaultCenter] addAccessRightsChangeObserver:self withBlock:^(PNAccessRightsCollection *collection, PNError *error) {

     if (error == nil) {

         // PubNub client successfully changed access rights for 'application' access level.
     }
     else {

         // PubNub client did fail to revoke access rights from application level.
         //
         // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
         // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
         // 'error.associatedObject' contains PNAccessRightOptions instance which describes access level for which change
         // has been requested.
     }
 }];
 @endcode

 Also observation can be done using \b NSNotificationCenter to observe this notifications: kPNClientAccessRightsChangeDidCompleteNotification,
 kPNClientAccessRightsChangeDidFailNotification.

 @note To be able use this API, you should provide \a 'secret' key which is used for signature generation.

 @note Make sure that you enabled "Access Manager" on https://admin.pubnub.com.

 @note You can pass a value less than \c 0 as \a 'accessPeriodDuration' argument to use default value (default value is \b 1440 minutes).

 @note When this API is used, it will grant \a 'write' access right and revoke \a 'read' access right for
 \a 'application' access level.

 @warning \a 'application' access level is top-layer of access tree. If any of child access levels (\a 'channel' or
 \a 'user') grant \a 'read' access rights, then \b PubNub client will ignore the fact that top-layer forbid \a 'read'
 access rights and allow to to subscribe on target channel (for which \a 'read' access right has been granted).

 @param accessPeriodDuration
 Duration in minutes during which \a 'application' access level is granted with \a 'write' access rights.

 @param handlerBlock
 The block which will be called by \b PubNub client when one of success or error events will be received. The block
 takes two arguments:
 \c collection - \b PNAccessRightsCollection instance which hold set of \b PNAccessRightsInformation instances to
 describe new \a 'application' access rights; \c error - error which describes what exactly went wrong
 during access rights change. Always check \a error.code to find out what caused error (check PNErrorCodes header file
 and use \a -localizedDescription / \a -localizedFailureReason and \a -localizedRecoverySuggestion to get human readable description for error).

 @since 3.5.3

 @see PNConfiguration class

 @see PNChannel class

 @see PNAccessRightOptions class

 @see PNAccessRightsCollection class

 @see PNObservationCenter class

 @see +grantReadAccessRightForApplicationAtPeriod:andCompletionHandlingBlock:

 @see +grantWriteAccessRightForChannel:forPeriod:
 */
+ (void)grantWriteAccessRightForApplicationAtPeriod:(NSInteger)accessPeriodDuration
                         andCompletionHandlingBlock:(PNClientChannelAccessRightsChangeBlock)handlerBlock;

/**
 Grant \a 'read'/ \a 'write' access rights on \a 'application' access level which will be valid for specified amount of time.

 @code
 @endcode
 \b Example:

 @code
 [PubNub setupWithConfiguration:[PNConfiguration configurationForOrigin:@"pubsub.pubnub.com" publishKey:@"demo"
                                                           subscribeKey:@"demo" secretKey:@"my-secret-key"]
                    andDelegate:self];
 [PubNub connect];
 [PubNub grantAllAccessRightForApplicationAtPeriod:10];
 [PubNub grantWriteAccessRightForChannel:[PNChannel channelWithName:@"iosdev"] forPeriod:10];
 @endcode

 Code above configure access rights in a way, which will allow to subscribe and post messages to any channel for \b 10
 minutes. But despite the fact that channel configured only for \a 'write' access rights, because of upper-layer configuration,
 \b PubNub client allowed to subscribe on \a 'iosdev' channel.

 And handle it with delegates:
 @code
 - (void)pubnubClient:(PubNub *)client didChangeAccessRights:(PNAccessRightsCollection *)accessRightsCollection {

     // PubNub client successfully changed access rights for 'application' access level.
 }

 - (void)pubnubClient:(PubNub *)client accessRightsChangeDidFailWithError:(PNError *)error {

     // PubNub client did fail to revoke access rights from application level.
     //
     // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
     // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
     // 'error.associatedObject' contains PNAccessRightOptions instance which describes access level for which change
     // has been requested.
 }
 @endcode

 There is also way to observe access rights change process from any place in your application using \b PNObservationCenter:
 @code
 [[PNObservationCenter defaultCenter] addAccessRightsChangeObserver:self withBlock:^(PNAccessRightsCollection *collection, PNError *error) {

     if (error == nil) {

         // PubNub client successfully changed access rights for 'application' access level.
     }
     else {

         // PubNub client did fail to revoke access rights from application level.
         //
         // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
         // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
         // 'error.associatedObject' contains PNAccessRightOptions instance which describes access level for which change
         // has been requested.
     }
 }];
 @endcode

 Also observation can be done using \b NSNotificationCenter to observe this notifications: kPNClientAccessRightsChangeDidCompleteNotification,
 kPNClientAccessRightsChangeDidFailNotification.

 @note To be able use this API, you should provide \a 'secret' key which is used for signature generation.

 @note Make sure that you enabled "Access Manager" on https://admin.pubnub.com.

 @note You can pass a value less than \c 0 as \a 'accessPeriodDuration' argument to use default value (default value is \b 1440 minutes).

 @warning \a 'application' access level is top-layer of access tree. If any of child access levels (\a 'channel' or
 \a 'user') grant only one of \a 'read' or \a 'write' access rights, \b PubNub client will ignore them and provide
 abilty to subscribe and post messages into any channels.

 @param accessPeriodDuration
 Duration in minutes during which \a 'application' access level is granted with \a 'read'/ \a 'write' access rights.

 @since 3.5.3

 @see PNConfiguration class

 @see PNChannel class

 @see PNAccessRightOptions class

 @see PNAccessRightsCollection class

 @see PNObservationCenter class

 @see +grantReadAccessRightForApplicationAtPeriod:andCompletionHandlingBlock:

 @see +grantWriteAccessRightForChannel:forPeriod:
 */
+ (void)grantAllAccessRightsForApplicationAtPeriod:(NSInteger)accessPeriodDuration;

/**
 Grant \a 'read'/ \a 'write' access rights on \a 'application' access level which will be valid for specified amount of time.

 @code
 @endcode
 This method extends \a +revokeAccessRightsForApplication: and allow to specify access rights change handler block.

 @code
 @endcode
 \b Example:

 @code
 [PubNub setupWithConfiguration:[PNConfiguration configurationForOrigin:@"pubsub.pubnub.com" publishKey:@"demo"
                                                           subscribeKey:@"demo" secretKey:@"my-secret-key"]
                    andDelegate:self];
 [PubNub connect];
 [PubNub grantAllAccessRightForApplicationAtPeriod:10
                        andCompletionHandlingBlock:^(PNAccessRightsCollection *collection, PNError *error) {

     if (error == nil) {

         // PubNub client successfully changed access rights for 'application' access level.
     }
     else {

         // PubNub client did fail to revoke access rights from application level.
         //
         // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
         // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
         // 'error.associatedObject' contains PNAccessRightOptions instance which describes access level for which change
         // has been requested.
     }
 }];
 [PubNub grantWriteAccessRightForChannel:[PNChannel channelWithName:@"iosdev"] forPeriod:10];
 @endcode

 Code above configure access rights in a way, which will allow to subscribe and post messages to any channel for \b 10
 minutes. But despite the fact that channel configured only for \a 'write' access rights, because of upper-layer configuration,
 \b PubNub client allowed to subscribe on \a 'iosdev' channel.

 And handle it with delegates:
 @code
 - (void)pubnubClient:(PubNub *)client didChangeAccessRights:(PNAccessRightsCollection *)accessRightsCollection {

     // PubNub client successfully changed access rights for 'application' access level.
 }

 - (void)pubnubClient:(PubNub *)client accessRightsChangeDidFailWithError:(PNError *)error {

     // PubNub client did fail to revoke access rights from application level.
     //
     // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
     // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
     // 'error.associatedObject' contains PNAccessRightOptions instance which describes access level for which change
     // has been requested.
 }
 @endcode

 There is also way to observe access rights change process from any place in your application using \b PNObservationCenter:
 @code
 [[PNObservationCenter defaultCenter] addAccessRightsChangeObserver:self withBlock:^(PNAccessRightsCollection *collection, PNError *error) {

     if (error == nil) {

         // PubNub client successfully changed access rights for 'application' access level.
     }
     else {

         // PubNub client did fail to revoke access rights from application level.
         //
         // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
         // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
         // 'error.associatedObject' contains PNAccessRightOptions instance which describes access level for which change
         // has been requested.
     }
 }];
 @endcode

 Also observation can be done using \b NSNotificationCenter to observe this notifications: kPNClientAccessRightsChangeDidCompleteNotification,
 kPNClientAccessRightsChangeDidFailNotification.

 @note To be able use this API, you should provide \a 'secret' key which is used for signature generation.

 @note Make sure that you enabled "Access Manager" on https://admin.pubnub.com.

 @note You can pass a value less than \c 0 as \a 'accessPeriodDuration' argument to use default value (default value is \b 1440 minutes).

 @warning \a 'application' access level is top-layer of access tree. If any of child access levels (\a 'channel' or
 \a 'user') grant only one of \a 'read' or \a 'write' access rights, \b PubNub client will ignore them and provide
 abilty to subscribe and post messages into any channels.

 @param accessPeriodDuration
 Duration in minutes during which \a 'application' access level is granted with \a 'read'/ \a 'write' access rights.

 @param handlerBlock
 The block which will be called by \b PubNub client when one of success or error events will be received. The block
 takes two arguments:
 \c collection - \b PNAccessRightsCollection instance which hold set of \b PNAccessRightsInformation instances to
 describe new \a 'application' access rights; \c error - error which describes what exactly went wrong
 during access rights change. Always check \a error.code to find out what caused error (check PNErrorCodes header file
 and use \a -localizedDescription / \a -localizedFailureReason and \a -localizedRecoverySuggestion to get human readable description for error).

 @since 3.5.3

 @see PNConfiguration class

 @see PNChannel class

 @see PNAccessRightOptions class

 @see PNAccessRightsCollection class

 @see PNObservationCenter class

 @see +grantReadAccessRightForApplicationAtPeriod:andCompletionHandlingBlock:

 @see +grantWriteAccessRightForChannel:forPeriod:
 */
+ (void)grantAllAccessRightsForApplicationAtPeriod:(NSInteger)accessPeriodDuration
                        andCompletionHandlingBlock:(PNClientChannelAccessRightsChangeBlock)handlerBlock;

/**
 Revoke all access rights on whole \a 'application' level.

 @code
 @endcode
 \b Example:

 @code
 [PubNub setConfiguration:[PNConfiguration defaultConfiguration] andDelegate:self];
 [PubNub connect];
 [PubNub grantAllAccessRightsForChannel:[PNChannel channelWithName:@"iosdev"] forPeriod:10];
 [PubNub revokeAccessRightsForApplication];
 @endcode

 Despite the fact that all access rights has been revoked on \a 'application' level in code above,
 \b PubNub client will be able to subscribe and post into \a "iosdev" channel for \b 10 minutes (access rights has been
 granted exactly for this period of time).

 And handle it with delegates:
 @code
 - (void)pubnubClient:(PubNub *)client didChangeAccessRights:(PNAccessRightsCollection *)accessRightsCollection {

     // PubNub client successfully revoked all access rights from application level.
 }

 - (void)pubnubClient:(PubNub *)client accessRightsChangeDidFailWithError:(PNError *)error {

     // PubNub client did fail to revoke access rights from application level.
     //
     // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
     // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
     // 'error.associatedObject' contains PNAccessRightOptions instance which describes access level for which revoke has been requested.
 }
 @endcode

 There is also way to observe revoke process from any place in your application using \b PNObservationCenter:
 @code
 [[PNObservationCenter defaultCenter] addAccessRightsChangeObserver:self withBlock:^(PNAccessRightsCollection *collection, PNError *error) {

     if (error == nil) {

         // PubNub client successfully revoked all access rights from application level.
     }
     else {

         // PubNub client did fail to revoke access rights from application level.
         //
         // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
         // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
         // 'error.associatedObject' contains PNAccessRightOptions instance which describes access level for which revoke has been requested.
     }
 }];
 @endcode

 Also observation can be done using \b NSNotificationCenter to observe this notifications: kPNClientAccessRightsChangeDidCompleteNotification,
 kPNClientAccessRightsChangeDidFailNotification.

 @note To be able use this API, you should provide \a 'secret' key which is used for signature generation.

 @note Make sure that you enabled "Access Manager" on https://admin.pubnub.com.

 @warning As soon as "Access Manager" will be enabled, all \b PubNub clients won't be able to subscribe / publish to
 any channels till the moment, when access rights will be configured.

 @see PNError class

 @see PNAccessRightOptions class

 @see PNAccessRightsCollection class

 @see PNObservationCenter class

 @see +revokeAccessRightsForApplicationWithCompletionHandlingBlock:

 @see +grantAllAccessRightsForChannel:forPeriod:
 */
+ (void)revokeAccessRightsForApplication;

/**
 Revoke all access rights on whole \a 'application' level.

 @code
 @endcode
 This method extends \a +revokeAccessRightsForApplication and allow to specify access rights change handler block.

 @code
 @endcode
 \b Example:

 @code
 [PubNub setConfiguration:[PNConfiguration defaultConfiguration] andDelegate:self];
 [PubNub connect];
 [PubNub grantAllAccessRightsForChannel:[PNChannel channelWithName:@"iosdev"] forPeriod:10];
 [PubNub revokeAccessRightsForApplicationWithCompletionHandlingBlock:^(PNAccessRightsCollection *collection, PNError *error) {

     if (error == nil) {

         // PubNub client successfully revoked all access rights from application level.
     }
     else {

         // PubNub client did fail to revoke access rights from application level.
         //
         // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
         // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
         // 'error.associatedObject' contains PNAccessRightOptions instance which describes access level for which revoke has been requested.
     }
 }];
 @endcode

 Despite the fact that all access rights has been revoked on \a 'application' level in code above,
 \b PubNub client will be able to subscribe and post into \a "iosdev" channel for \b 10 minutes (access rights has been
 granted exactly for this period of time).

 And handle it with delegates:
 @code
 - (void)pubnubClient:(PubNub *)client didChangeAccessRights:(PNAccessRightsCollection *)accessRightsCollection {

     // PubNub client successfully revoked all access rights from application level.
 }

 - (void)pubnubClient:(PubNub *)client accessRightsChangeDidFailWithError:(PNError *)error {

     // PubNub client did fail to revoke access rights from application level.
     //
     // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
     // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
     // 'error.associatedObject' contains PNAccessRightOptions instance which describes access level for which revoke has been requested.
 }
 @endcode

 There is also way to observe revoke process from any place in your application using \b PNObservationCenter:
 @code
 [[PNObservationCenter defaultCenter] addAccessRightsChangeObserver:self withBlock:^(PNAccessRightsCollection *collection, PNError *error) {

     if (error == nil) {

         // PubNub client successfully revoked all access rights from application.
     }
     else {

         // PubNub client did fail to revoke access rights from application.
         //
         // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
         // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
         // 'error.associatedObject' contains PNAccessRightOptions instance which describes access level for which revoke has been requested.
     }
 }];
 @endcode

 Also observation can be done using \b NSNotificationCenter to observe this notifications: kPNClientAccessRightsChangeDidCompleteNotification,
 kPNClientAccessRightsChangeDidFailNotification.

 @param handlerBlock
 The block which will be called by \b PubNub client when one of success or error events will be received. The block
 takes two arguments:
 \c collection - \b PNAccessRightsCollection instance which hold set of \b PNAccessRightsInformation instances to
 describe new \a 'application' access rights; \c error - error which describes what exactly went wrong
 during access rights revoke. Always check \a error.code to find out what caused error (check PNErrorCodes header file
 and use \a -localizedDescription / \a -localizedFailureReason and \a -localizedRecoverySuggestion to get human readable description for error).

 @note Make sure that you enabled "Access Manager" on https://admin.pubnub.com.

 @warning As soon as "Access Manager" will be enabled, all \b PubNub clients won't be able to subscribe / publish to
 any channels till the moment, when access rights will be configured.

 @see PNError class

 @see PNAccessRightOptions class

 @see PNAccessRightsCollection class

 @see PNAccessRightsInformation class

 @see PNObservationCenter class

 @see +revokeAccessRightsForApplication

 @see +grantAllAccessRightsForChannel:forPeriod:
 */
+ (void)revokeAccessRightsForApplicationWithCompletionHandlingBlock:(PNClientChannelAccessRightsChangeBlock)handlerBlock;

/**
 Grant \a 'read' access right on \a 'channel' access level which will be valid for specified amount of time.

 @code
 @endcode
 \b Example:

 @code
 [PubNub setupWithConfiguration:[PNConfiguration configurationForOrigin:@"pubsub.pubnub.com" publishKey:@"demo"
                                                           subscribeKey:@"demo" secretKey:@"my-secret-key"]
                    andDelegate:self];
 [PubNub connect];
 [PubNub grantReadAccessRightForChannel:[PNChannel channelWithName:@"iosdev"] forPeriod:10];
 [PubNub grantWriteAccessRightForApplicationAtPeriod:10];
 @endcode

 Code above configure access rights in a way, which won't allow message posting to \a 'iosdev' channel for \b 10 minutes. 
 But despite the fact that \a 'iosdev' channel access rights allow only subscription, \b PubNub client allowed to post
 messages to any channels because of upper-layer configuration (\a 'application' access level allow message posting to any 
 channels for \b 10 minutes).

 And handle it with delegates:
 @code
 - (void)pubnubClient:(PubNub *)client didChangeAccessRights:(PNAccessRightsCollection *)accessRightsCollection {

     // PubNub client successfully changed access rights for 'channel' access level.
 }

 - (void)pubnubClient:(PubNub *)client accessRightsChangeDidFailWithError:(PNError *)error {

     // PubNub client did fail to revoke access rights from 'channel' access level.
     //
     // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
     // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
     // 'error.associatedObject' contains PNAccessRightOptions instance which describes access level for which change
     // has been requested.
 }
 @endcode

 There is also way to observe access rights change process from any place in your application using \b PNObservationCenter:
 @code
 [[PNObservationCenter defaultCenter] addAccessRightsChangeObserver:self withBlock:^(PNAccessRightsCollection *collection, PNError *error) {

     if (error == nil) {

         // PubNub client successfully changed access rights for 'channel' access level.
     }
     else {

         // PubNub client did fail to revoke access rights from 'channel' access level.
         //
         // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
         // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
         // 'error.associatedObject' contains PNAccessRightOptions instance which describes access level for which change
         // has been requested.
     }
 }];
 @endcode

 Also observation can be done using \b NSNotificationCenter to observe this notifications: kPNClientAccessRightsChangeDidCompleteNotification,
 kPNClientAccessRightsChangeDidFailNotification.

 @note To be able use this API, you should provide \a 'secret' key which is used for signature generation.

 @note Make sure that you enabled "Access Manager" on https://admin.pubnub.com.

 @note You can pass a value less than \c 0 as \a 'accessPeriodDuration' argument to use default value (default value is \b 1440 minutes).

 @note When this API is used, it will grant \a 'read' access right and revoke \a 'write' access right for
 \a 'channel' access level.

 @warning \a 'channel' access level is mid-layer of access tree. If \a 'user' access level grant \a 'write' access rights, 
 then \b PubNub client will ignore the fact that mid-layer forbid \a 'write' access right and allow specific user (which has been granted 
 with \a 'write' access right) to post messages into target channel (for which \a 'write' access right has been granted).
 
 @param channel
 \b PNChannel instance for which \b PubNub client should change access rights to \a 'read'.

 @param accessPeriodDuration
 Duration in minutes during which \a 'channel' access level is granted with \a 'read' access rights.

 @since 3.5.3

 @see PNConfiguration class

 @see PNChannel class

 @see PNAccessRightOptions class

 @see PNAccessRightsCollection class

 @see PNObservationCenter class
 
 @see +grantReadAccessRightForChannel:forPeriod:withCompletionHandlingBlock:

 @see +grantWriteAccessRightForApplicationAtPeriod:
 */
+ (void)grantReadAccessRightForChannel:(PNChannel *)channel forPeriod:(NSInteger)accessPeriodDuration;

/**
 Grant \a 'read' access right on \a 'channel' access level which will be valid for specified amount of time.
 
 @code
 @endcode
 This method extends \a +grantReadAccessRightForChannel:forPeriod: and allow to specify access rights change handler block.

 @code
 @endcode
 \b Example:

 @code
 [PubNub setupWithConfiguration:[PNConfiguration configurationForOrigin:@"pubsub.pubnub.com" publishKey:@"demo"
                                                           subscribeKey:@"demo" secretKey:@"my-secret-key"]
                    andDelegate:self];
 [PubNub connect];
 [PubNub grantReadAccessRightForChannel:[PNChannel channelWithName:@"iosdev"] forPeriod:10 
            withCompletionHandlingBlock:^(PNAccessRightsCollection *collection, PNError *error) {

                if (error == nil) {

                    // PubNub client successfully changed access rights for 'channel' access level.
                }
                else {
 
                    // PubNub client did fail to revoke access rights from 'channel' access level.
                    //
                    // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
                    // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
                    // 'error.associatedObject' contains PNAccessRightOptions instance which describes access level for which change
                    // has been requested.
                }
 }];
 [PubNub grantWriteAccessRightForApplicationAtPeriod:10];
 @endcode

 Code above configure access rights in a way, which won't allow message posting to \a 'iosdev' channel for \b 10 minutes. 
 But despite the fact that \a 'iosdev' channel access rights allow only subscription, \b PubNub client allowed to post
 messages to any channels because of upper-layer configuration (\a 'application' access level allow message posting to any 
 channels for \b 10 minutes).

 And handle it with delegates:
 @code
 - (void)pubnubClient:(PubNub *)client didChangeAccessRights:(PNAccessRightsCollection *)accessRightsCollection {

     // PubNub client successfully changed access rights for 'channel' access level.
 }

 - (void)pubnubClient:(PubNub *)client accessRightsChangeDidFailWithError:(PNError *)error {

     // PubNub client did fail to revoke access rights from 'channel' access level.
     //
     // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
     // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
     // 'error.associatedObject' contains PNAccessRightOptions instance which describes access level for which change
     // has been requested.
 }
 @endcode

 There is also way to observe access rights change process from any place in your application using \b PNObservationCenter:
 @code
 [[PNObservationCenter defaultCenter] addAccessRightsChangeObserver:self withBlock:^(PNAccessRightsCollection *collection, PNError *error) {

     if (error == nil) {

         // PubNub client successfully changed access rights for 'channel' access level.
     }
     else {

         // PubNub client did fail to revoke access rights from 'channel' access level.
         //
         // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
         // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
         // 'error.associatedObject' contains PNAccessRightOptions instance which describes access level for which change
         // has been requested.
     }
 }];
 @endcode

 Also observation can be done using \b NSNotificationCenter to observe this notifications: kPNClientAccessRightsChangeDidCompleteNotification,
 kPNClientAccessRightsChangeDidFailNotification.

 @note To be able use this API, you should provide \a 'secret' key which is used for signature generation.

 @note Make sure that you enabled "Access Manager" on https://admin.pubnub.com.

 @note You can pass a value less than \c 0 as \a 'accessPeriodDuration' argument to use default value (default value is \b 1440 minutes).

 @note When this API is used, it will grant \a 'read' access right and revoke \a 'write' access right for
 \a 'channel' access level.

 @warning \a 'channel' access level is mid-layer of access tree. If \a 'user' access level grant \a 'write' access rights, 
 then \b PubNub client will ignore the fact that mid-layer forbid \a 'write' access right and allow specific user (which has been granted 
 with \a 'write' access right) to post messages into target channel (for which \a 'write' access right has been granted).
 
 @param channel
 \b PNChannel instance for which \b PubNub client should change access rights to \a 'read'.

 @param accessPeriodDuration
 Duration in minutes during which \a 'channel' access level is granted with \a 'read' access rights.
 
 @param handlerBlock
 The block which will be called by \b PubNub client when one of success or error events will be received. The block takes two arguments:
 \c collection - \b PNAccessRightsCollection instance which hold set of \b PNAccessRightsInformation instances to
 describe new \a 'channel' access rights; \c error - error which describes what exactly went wrong
 during access rights change. Always check \a error.code to find out what caused error (check PNErrorCodes header file
 and use \a -localizedDescription / \a -localizedFailureReason and \a -localizedRecoverySuggestion to get human readable description for error).

 @since 3.5.3

 @see PNConfiguration class

 @see PNChannel class

 @see PNAccessRightOptions class

 @see PNAccessRightsCollection class

 @see PNObservationCenter class
 
 @see +grantReadAccessRightForChannel:forPeriod:

 @see +grantWriteAccessRightForApplicationAtPeriod:
 */
+ (void)grantReadAccessRightForChannel:(PNChannel *)channel forPeriod:(NSInteger)accessPeriodDuration
           withCompletionHandlingBlock:(PNClientChannelAccessRightsChangeBlock)handlerBlock;

/**
 Grant \a 'read' access right on \a 'user' access level which will be valid for specified amount of time.

 @code
 @endcode
 \b Example:

 @code
 [PubNub setupWithConfiguration:[PNConfiguration configurationForOrigin:@"pubsub.pubnub.com" publishKey:@"demo"
                                                           subscribeKey:@"demo" secretKey:@"my-secret-key"]
                    andDelegate:self];
 [PubNub connect];
 [PubNub grantReadAccessRightForChannel:[PNChannel channelWithName:@"iosdev"] forPeriod:10 client:@"spectator"];
 [PubNub grantWriteAccessRightForChannel:[PNChannel channelWithName:@"iosdev"] forPeriod:10];
 @endcode

 Code above configure access rights in a way, which won't allow message posting for client with \a 'spectator' authorization key 
 into \a 'iosdev' channel for \b 10 minutes. But despite the fact that \a 'iosdev' channel access rights allow only
 subscription for \a 'spectator', \b PubNub client allowed to post messages to any channels because of upper-layer configuration (\a 'channel' access level allow message
 posting to any channels for \b 10 minutes).

 And handle it with delegates:
 @code
 - (void)pubnubClient:(PubNub *)client didChangeAccessRights:(PNAccessRightsCollection *)accessRightsCollection {

     // PubNub client successfully changed access rights for 'user' access level.
 }

 - (void)pubnubClient:(PubNub *)client accessRightsChangeDidFailWithError:(PNError *)error {

     // PubNub client did fail to revoke access rights from 'user' access level.
     //
     // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
     // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
     // 'error.associatedObject' contains PNAccessRightOptions instance which describes access level for which change
     // has been requested.
 }
 @endcode

 There is also way to observe access rights change process from any place in your application using \b PNObservationCenter:
 @code
 [[PNObservationCenter defaultCenter] addAccessRightsChangeObserver:self withBlock:^(PNAccessRightsCollection *collection, PNError *error) {

     if (error == nil) {

         // PubNub client successfully changed access rights for 'user' access level.
     }
     else {

         // PubNub client did fail to revoke access rights from 'user' access level.
         //
         // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
         // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
         // 'error.associatedObject' contains PNAccessRightOptions instance which describes access level for which change
         // has been requested.
     }
 }];
 @endcode

 Also observation can be done using \b NSNotificationCenter to observe this notifications: kPNClientAccessRightsChangeDidCompleteNotification,
 kPNClientAccessRightsChangeDidFailNotification.

 @note To be able use this API, you should provide \a 'secret' key which is used for signature generation.

 @note Make sure that you enabled "Access Manager" on https://admin.pubnub.com.

 @note You can pass a value less than \c 0 as \a 'accessPeriodDuration' argument to use default value (default value is \b 1440 minutes).

 @note When this API is used, it will grant \a 'read' access right and revoke \a 'write' access right for
 \a 'user' access level.

 @warning \a 'user' access level is low-layer of access tree. If one of upper layers will grant \a 'write' access rights,
 then \b PubNub client will ignore the fact that low-layer forbid \a 'write' access rights and depending on who override 
 this value (\a 'application' or \a 'channel' access level) will allow message posting to all channels and for all 
 (in case if \a 'write' access rights granted on \a 'application' access level) or allow messsage posting for all into specific 
 channel (for channel which is granted with \a 'write' access rights).
 
 @param channel
 \b PNChannel instance for which \b PubNub client should change access rights for specific client.
 
 @param clientAuthorizationKey
 \a NSString instance which identify client which should be granted with \a 'read' access right on specific \c channel.

 @param accessPeriodDuration
 Duration in minutes during which \a 'user' access level is granted with \a 'read' access rights.

 @since 3.5.3

 @see PNConfiguration class

 @see PNChannel class

 @see PNAccessRightOptions class

 @see PNAccessRightsCollection class

 @see PNObservationCenter class
 
 @see +grantReadAccessRightForChannel:forPeriod:client:withCompletionHandlingBlock:

 @see +grantWriteAccessRightForChannel:forPeriod:
 */
+ (void)grantReadAccessRightForChannel:(PNChannel *)channel forPeriod:(NSInteger)accessPeriodDuration
                                client:(NSString *)clientAuthorizationKey;

/**
 Grant \a 'read' access right on \a 'user' access level which will be valid for specified amount of time. 
 
 @code
 @endcode
 This method extends \a +grantReadAccessRightForChannel:forPeriod:client: and allow to specify access rights change handler block.

 @code
 @endcode
 \b Example:

 @code
 [PubNub setupWithConfiguration:[PNConfiguration configurationForOrigin:@"pubsub.pubnub.com" publishKey:@"demo"
                                                           subscribeKey:@"demo" secretKey:@"my-secret-key"]
                    andDelegate:self];
 [PubNub connect];
 [PubNub grantReadAccessRightForChannel:[PNChannel channelWithName:@"iosdev"] forPeriod:10 client:@"spectator" 
            withCompletionHandlingBlock:^(PNAccessRightsCollection *collection, PNError *error) {

                if (error == nil) {

                    // PubNub client successfully changed access rights for 'user' access level.
                }
                else {
 
                    // PubNub client did fail to revoke access rights from 'user' access level.
                    //
                    // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
                    // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
                    // 'error.associatedObject' contains PNAccessRightOptions instance which describes access level for which change
                    // has been requested.
                }
 }];
 [PubNub grantWriteAccessRightForChannel:[PNChannel channelWithName:@"iosdev"] forPeriod:10];
 @endcode

 Code above configure access rights in a way, which won't allow message posting for client with \a 'spectator' authorization key 
 into \a 'iosdev' channel for \b 10 minutes. But despite the fact that \a 'iosdev' channel access rights allow only
 subscription for \a 'spectator', \b PubNub client allowed to post messages to any channels because of upper-layer configuration (\a 'channel' access level allow message
 posting to any channels for \b 10 minutes).

 And handle it with delegates:
 @code
 - (void)pubnubClient:(PubNub *)client didChangeAccessRights:(PNAccessRightsCollection *)accessRightsCollection {

     // PubNub client successfully changed access rights for 'user' access level.
 }

 - (void)pubnubClient:(PubNub *)client accessRightsChangeDidFailWithError:(PNError *)error {

     // PubNub client did fail to revoke access rights from 'user' access level.
     //
     // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
     // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
     // 'error.associatedObject' contains PNAccessRightOptions instance which describes access level for which change
     // has been requested.
 }
 @endcode

 There is also way to observe access rights change process from any place in your application using \b PNObservationCenter:
 @code
 [[PNObservationCenter defaultCenter] addAccessRightsChangeObserver:self withBlock:^(PNAccessRightsCollection *collection, PNError *error) {

     if (error == nil) {

         // PubNub client successfully changed access rights for 'user' access level.
     }
     else {

         // PubNub client did fail to revoke access rights from 'user' access level.
         //
         // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
         // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
         // 'error.associatedObject' contains PNAccessRightOptions instance which describes access level for which change
         // has been requested.
     }
 }];
 @endcode

 Also observation can be done using \b NSNotificationCenter to observe this notifications: kPNClientAccessRightsChangeDidCompleteNotification,
 kPNClientAccessRightsChangeDidFailNotification.

 @note To be able use this API, you should provide \a 'secret' key which is used for signature generation.

 @note Make sure that you enabled "Access Manager" on https://admin.pubnub.com.

 @note You can pass a value less than \c 0 as \a 'accessPeriodDuration' argument to use default value (default value is \b 1440 minutes).

 @note When this API is used, it will grant \a 'read' access right and revoke \a 'write' access right for
 \a 'user' access level.

 @warning \a 'user' access level is low-layer of access tree. If one of upper layers will grant \a 'write' access rights,
 then \b PubNub client will ignore the fact that low-layer forbid \a 'write' access rights and depending on who override 
 this value (\a 'application' or \a 'channel' access level) will allow message posting to all channels and for all 
 (in case if \a 'write' access rights granted on \a 'application' access level) or allow messsage posting for all into specific 
 channel (for channel which is granted with \a 'write' access rights).
 
 @param channel
 \b PNChannel instance for which \b PubNub client should change access rights for specific client.
 
 @param clientAuthorizationKey
 \a NSString instance which identify client which should be granted with \a 'read' access right on specific \c channel.

 @param accessPeriodDuration
 Duration in minutes during which \a 'user' access level is granted with \a 'read' access rights.
 
 @param handlerBlock
 The block which will be called by \b PubNub client when one of success or error events will be received. The block takes two arguments:
 \c collection - \b PNAccessRightsCollection instance which hold set of \b PNAccessRightsInformation instances to
 describe new \a 'user' access rights; \c error - error which describes what exactly went wrong
 during access rights change. Always check \a error.code to find out what caused error (check PNErrorCodes header file
 and use \a -localizedDescription / \a -localizedFailureReason and \a -localizedRecoverySuggestion to get human readable description for error).

 @since 3.5.3

 @see PNConfiguration class

 @see PNChannel class

 @see PNAccessRightOptions class

 @see PNAccessRightsCollection class

 @see PNObservationCenter class
 
 @see +grantReadAccessRightForChannel:forPeriod:client:

 @see +grantWriteAccessRightForChannel:forPeriod:
 */
+ (void)grantReadAccessRightForChannel:(PNChannel *)channel forPeriod:(NSInteger)accessPeriodDuration
                                client:(NSString *)clientAuthorizationKey
           withCompletionHandlingBlock:(PNClientChannelAccessRightsChangeBlock)handlerBlock;

/**
 Grant \a 'read' access right on \a 'channel' access level which will be valid for specified amount of time for specific set of channels.

 @code
 @endcode
 \b Example:

 @code
 [PubNub setupWithConfiguration:[PNConfiguration configurationForOrigin:@"pubsub.pubnub.com" publishKey:@"demo"
                                                           subscribeKey:@"demo" secretKey:@"my-secret-key"]
                    andDelegate:self];
 [PubNub connect];
 [PubNub grantReadAccessRightForChannels:[PNChannel channelsWithNames:@[@"iosdev", @"androiddev", @"macosdev"]] forPeriod:10];
 [PubNub grantWriteAccessRightForApplicationAtPeriod:10];
 @endcode

 Code above configure access rights in a way, which won't allow message posting to \a 'iosdev', \a 'androiddev' and \a 'macosdev' channels
 for \b 10 minutes. But despite the fact that \a 'iosdev', \a 'androiddev' and \a 'macosdev' channels access rights
 allow only subscription, \b PubNub client allowed to post messages to any channels because of upper-layer configuration (\a 'application' access level allow message
 posting to any channels for \b 10 minutes).

 And handle it with delegates:
 @code
 - (void)pubnubClient:(PubNub *)client didChangeAccessRights:(PNAccessRightsCollection *)accessRightsCollection {

     // PubNub client successfully changed access rights for 'channel' access level.
 }

 - (void)pubnubClient:(PubNub *)client accessRightsChangeDidFailWithError:(PNError *)error {

     // PubNub client did fail to revoke access rights from 'channel' access level.
     //
     // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
     // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
     // 'error.associatedObject' contains PNAccessRightOptions instance which describes access level for which change
     // has been requested.
 }
 @endcode

 There is also way to observe access rights change process from any place in your application using \b PNObservationCenter:
 @code
 [[PNObservationCenter defaultCenter] addAccessRightsChangeObserver:self withBlock:^(PNAccessRightsCollection *collection, PNError *error) {

     if (error == nil) {

         // PubNub client successfully changed access rights for 'channel' access level.
     }
     else {

         // PubNub client did fail to revoke access rights from 'channel' access level.
         //
         // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
         // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
         // 'error.associatedObject' contains PNAccessRightOptions instance which describes access level for which change
         // has been requested.
     }
 }];
 @endcode

 Also observation can be done using \b NSNotificationCenter to observe this notifications: kPNClientAccessRightsChangeDidCompleteNotification,
 kPNClientAccessRightsChangeDidFailNotification.

 @note To be able use this API, you should provide \a 'secret' key which is used for signature generation.

 @note Make sure that you enabled "Access Manager" on https://admin.pubnub.com.

 @note You can pass a value less than \c 0 as \a 'accessPeriodDuration' argument to use default value (default value is \b 1440 minutes).

 @note When this API is used, it will grant \a 'read' access right and revoke \a 'write' access right for
 \a 'channel' access level.

 @warning \a 'channel' access level is mid-layer of access tree. If \a 'user' access level grant \a 'write' access rights, 
 then \b PubNub client will ignore the fact that mid-layer forbid \a 'write' access right and allow specific user (which has been granted 
 with \a 'write' access right) to post messages into target channel (for which \a 'write' access right has been granted).
 
 @param channels
 List of \b PNChannel instances for which \b PubNub client should change access rights to \a 'read'.

 @param accessPeriodDuration
 Duration in minutes during which \a 'channel' access level is granted with \a 'read' access rights.

 @since 3.5.3

 @see PNConfiguration class

 @see PNChannel class

 @see PNAccessRightOptions class

 @see PNAccessRightsCollection class

 @see PNObservationCenter class
 
 @see +grantReadAccessRightForChannels:forPeriod:withCompletionHandlingBlock:

 @see +grantWriteAccessRightForApplicationAtPeriod:
 */
+ (void)grantReadAccessRightForChannels:(NSArray *)channels forPeriod:(NSInteger)accessPeriodDuration;

/**
 Grant \a 'read' access right on \a 'channel' access level which will be valid for specified amount of time for specific set of channels.
 
 @code
 @endcode
 This method extends \a +grantReadAccessRightForChannels:forPeriod: and allow to specify access rights change handler block.

 @code
 @endcode
 \b Example:

 @code
 [PubNub setupWithConfiguration:[PNConfiguration configurationForOrigin:@"pubsub.pubnub.com" publishKey:@"demo"
                                                           subscribeKey:@"demo" secretKey:@"my-secret-key"]
                    andDelegate:self];
 [PubNub connect];
 [PubNub grantReadAccessRightForChannels:[PNChannel channelsWithNames:@[@"iosdev", @"androiddev", @"macosdev"]] forPeriod:10
             withCompletionHandlingBlock:^(PNAccessRightsCollection *collection, PNError *error) {

                 if (error == nil) {

                     // PubNub client successfully changed access rights for 'channel' access level.
                 }
                 else {
 
                     // PubNub client did fail to revoke access rights from 'channel' access level.
                     //
                     // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
                     // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
                     // 'error.associatedObject' contains PNAccessRightOptions instance which describes access level for which change
                     // has been requested.
                 }
 }];
 [PubNub grantWriteAccessRightForApplicationAtPeriod:10];
 @endcode

 Code above configure access rights in a way, which won't allow message posting to \a 'iosdev', \a 'androiddev' and \a 'macosdev' channels
 for \b 10 minutes. But despite the fact that \a 'iosdev', \a 'androiddev' and \a 'macosdev' channels access rights
 allow only subscription, \b PubNub client allowed to post messages to any channels because of upper-layer configuration (\a 'application' access level allow message
 posting to any channels for \b 10 minutes).

 And handle it with delegates:
 @code
 - (void)pubnubClient:(PubNub *)client didChangeAccessRights:(PNAccessRightsCollection *)accessRightsCollection {

     // PubNub client successfully changed access rights for 'channel' access level.
 }

 - (void)pubnubClient:(PubNub *)client accessRightsChangeDidFailWithError:(PNError *)error {

     // PubNub client did fail to revoke access rights from 'channel' access level.
     //
     // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
     // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
     // 'error.associatedObject' contains PNAccessRightOptions instance which describes access level for which change
     // has been requested.
 }
 @endcode

 There is also way to observe access rights change process from any place in your application using \b PNObservationCenter:
 @code
 [[PNObservationCenter defaultCenter] addAccessRightsChangeObserver:self withBlock:^(PNAccessRightsCollection *collection, PNError *error) {

     if (error == nil) {

         // PubNub client successfully changed access rights for 'channel' access level.
     }
     else {

         // PubNub client did fail to revoke access rights from 'channel' access level.
         //
         // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
         // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
         // 'error.associatedObject' contains PNAccessRightOptions instance which describes access level for which change
         // has been requested.
     }
 }];
 @endcode

 Also observation can be done using \b NSNotificationCenter to observe this notifications: kPNClientAccessRightsChangeDidCompleteNotification,
 kPNClientAccessRightsChangeDidFailNotification.

 @note To be able use this API, you should provide \a 'secret' key which is used for signature generation.

 @note Make sure that you enabled "Access Manager" on https://admin.pubnub.com.

 @note You can pass a value less than \c 0 as \a 'accessPeriodDuration' argument to use default value (default value is \b 1440 minutes).

 @note When this API is used, it will grant \a 'read' access right and revoke \a 'write' access right for
 \a 'channel' access level.

 @warning \a 'channel' access level is mid-layer of access tree. If \a 'user' access level grant \a 'write' access rights, 
 then \b PubNub client will ignore the fact that mid-layer forbid \a 'write' access right and allow specific user (which has been granted 
 with \a 'write' access right) to post messages into target channel (for which \a 'write' access right has been granted).
 
 @param channels
 List of \b PNChannel instances for which \b PubNub client should change access rights to \a 'read'.

 @param accessPeriodDuration
 Duration in minutes during which \a 'channel' access level is granted with \a 'read' access rights.
 
 @param handlerBlock
 The block which will be called by \b PubNub client when one of success or error events will be received. The block takes two arguments:
 \c collection - \b PNAccessRightsCollection instance which hold set of \b PNAccessRightsInformation instances to
 describe new \a 'channel' access rights; \c error - error which describes what exactly went wrong
 during access rights change. Always check \a error.code to find out what caused error (check PNErrorCodes header file
 and use \a -localizedDescription / \a -localizedFailureReason and \a -localizedRecoverySuggestion to get human readable description for error).

 @since 3.5.3

 @see PNConfiguration class

 @see PNChannel class

 @see PNAccessRightOptions class

 @see PNAccessRightsCollection class

 @see PNObservationCenter class
 
 @see +grantReadAccessRightForChannels:forPeriod:withCompletionHandlingBlock:

 @see +grantWriteAccessRightForApplicationAtPeriod:
 */
+ (void)grantReadAccessRightForChannels:(NSArray *)channels forPeriod:(NSInteger)accessPeriodDuration
            withCompletionHandlingBlock:(PNClientChannelAccessRightsChangeBlock)handlerBlock;

/**
 Grant \a 'read' access right on \a 'user' access level which will be valid for specified amount of time for specific set of cliens authorization keys.

 @code
 @endcode
 \b Example:

 @code
 [PubNub setupWithConfiguration:[PNConfiguration configurationForOrigin:@"pubsub.pubnub.com" publishKey:@"demo"
                                                           subscribeKey:@"demo" secretKey:@"my-secret-key"]
                    andDelegate:self];
 [PubNub connect];
 [PubNub grantReadAccessRightForChannel:[PNChannel channelWithName:@"iosdev"] forPeriod:10 clients:@[@"spectator", @"visitor"]];
 [PubNub grantWriteAccessRightForChannel:[PNChannel channelWithName:@"iosdev"] forPeriod:10];
 @endcode

 Code above configure access rights in a way, which won't allow message posting for clients with \a 'spectator' and \a 'visitor' 
 authorization keys into \a 'iosdev' channel for \b 10 minutes. But despite the fact that \a 'iosdev' channel access
 rights allow only subscription for \a 'spectator' and \a 'visitor', \b PubNub client allowed to post messages to any channels because of upper-layer
 configuration (\a 'channel' access level allow message posting to any channels for \b 10 minutes).

 And handle it with delegates:
 @code
 - (void)pubnubClient:(PubNub *)client didChangeAccessRights:(PNAccessRightsCollection *)accessRightsCollection {

     // PubNub client successfully changed access rights for 'user' access level.
 }

 - (void)pubnubClient:(PubNub *)client accessRightsChangeDidFailWithError:(PNError *)error {

     // PubNub client did fail to revoke access rights from 'user' access level.
     //
     // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
     // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
     // 'error.associatedObject' contains PNAccessRightOptions instance which describes access level for which change
     // has been requested.
 }
 @endcode

 There is also way to observe access rights change process from any place in your application using \b PNObservationCenter:
 @code
 [[PNObservationCenter defaultCenter] addAccessRightsChangeObserver:self withBlock:^(PNAccessRightsCollection *collection, PNError *error) {

     if (error == nil) {

         // PubNub client successfully changed access rights for 'user' access level.
     }
     else {

         // PubNub client did fail to revoke access rights from 'user' access level.
         //
         // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
         // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
         // 'error.associatedObject' contains PNAccessRightOptions instance which describes access level for which change
         // has been requested.
     }
 }];
 @endcode

 Also observation can be done using \b NSNotificationCenter to observe this notifications: kPNClientAccessRightsChangeDidCompleteNotification,
 kPNClientAccessRightsChangeDidFailNotification.

 @note To be able use this API, you should provide \a 'secret' key which is used for signature generation.

 @note Make sure that you enabled "Access Manager" on https://admin.pubnub.com.

 @note You can pass a value less than \c 0 as \a 'accessPeriodDuration' argument to use default value (default value is \b 1440 minutes).

 @note When this API is used, it will grant \a 'read' access right and revoke \a 'write' access right for
 \a 'user' access level.

 @warning \a 'user' access level is low-layer of access tree. If one of upper layers will grant \a 'write' access rights,
 then \b PubNub client will ignore the fact that low-layer forbid \a 'write' access rights and depending on who override 
 this value (\a 'application' or \a 'channel' access level) will allow message posting to all channels and for all 
 (in case if \a 'write' access rights granted on \a 'application' access level) or allow messsage posting for all into specific 
 channel (for channel which is granted with \a 'write' access rights).
 
 @param channel
 \b PNChannel instance for which \b PubNub client should change access rights for specific client.
 
 @param clientsAuthorizationKeys
 Set of \a NSString instances which identify clients which should be granted with \a 'read' access right on specific \c channel.

 @param accessPeriodDuration
 Duration in minutes during which \a 'user' access level is granted with \a 'read' access rights.

 @since 3.5.3

 @see PNConfiguration class

 @see PNChannel class

 @see PNAccessRightOptions class

 @see PNAccessRightsCollection class

 @see PNObservationCenter class
 
 @see +grantReadAccessRightForChannel:forPeriod:clients:withCompletionHandlingBlock:

 @see +grantWriteAccessRightForChannel:forPeriod:
 */
+ (void)grantReadAccessRightForChannel:(PNChannel *)channel forPeriod:(NSInteger)accessPeriodDuration
                               clients:(NSArray *)clientsAuthorizationKeys;

/**
 Grant \a 'read' access right on \a 'user' access level which will be valid for specified amount of time for specific set of cliens authorization keys.
 
 @code
 @endcode
 This method extends \a +grantReadAccessRightForChannel:forPeriod:clients: and allow to specify access rights change handler block.

 @code
 @endcode
 \b Example:

 @code
 [PubNub setupWithConfiguration:[PNConfiguration configurationForOrigin:@"pubsub.pubnub.com" publishKey:@"demo"
                                                           subscribeKey:@"demo" secretKey:@"my-secret-key"]
                    andDelegate:self];
 [PubNub connect];
 [PubNub grantReadAccessRightForChannel:[PNChannel channelWithName:@"iosdev"] forPeriod:10 client:@[@"spectator", @"visitor"]
            withCompletionHandlingBlock:^(PNAccessRightsCollection *collection, PNError *error) {

                if (error == nil) {

                    // PubNub client successfully changed access rights for 'user' access level.
                }
                else {
 
                    // PubNub client did fail to revoke access rights from 'user' access level.
                    //
                    // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
                    // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
                    // 'error.associatedObject' contains PNAccessRightOptions instance which describes access level for which change
                    // has been requested.
                }
 }];
 [PubNub grantWriteAccessRightForChannel:[PNChannel channelWithName:@"iosdev"] forPeriod:10];
 @endcode
 
 Code above configure access rights in a way, which won't allow message posting for clients with \a 'spectator' and \a 'visitor'
 authorization keys into \a 'iosdev' channel for \b 10 minutes. But despite the fact that \a 'iosdev' channel access
 rights allow only subscription for \a 'spectator' and \a 'visitor', \b PubNub client allowed to post messages to any channels because of upper-layer
 configuration (\a 'channel' access level allow message posting to any channels for \b 10 minutes).

 And handle it with delegates:
 @code
 - (void)pubnubClient:(PubNub *)client didChangeAccessRights:(PNAccessRightsCollection *)accessRightsCollection {

     // PubNub client successfully changed access rights for 'user' access level.
 }

 - (void)pubnubClient:(PubNub *)client accessRightsChangeDidFailWithError:(PNError *)error {

     // PubNub client did fail to revoke access rights from 'user' access level.
     //
     // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
     // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
     // 'error.associatedObject' contains PNAccessRightOptions instance which describes access level for which change
     // has been requested.
 }
 @endcode

 There is also way to observe access rights change process from any place in your application using \b PNObservationCenter:
 @code
 [[PNObservationCenter defaultCenter] addAccessRightsChangeObserver:self withBlock:^(PNAccessRightsCollection *collection, PNError *error) {

     if (error == nil) {

         // PubNub client successfully changed access rights for 'user' access level.
     }
     else {

         // PubNub client did fail to revoke access rights from 'user' access level.
         //
         // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
         // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
         // 'error.associatedObject' contains PNAccessRightOptions instance which describes access level for which change
         // has been requested.
     }
 }];
 @endcode

 Also observation can be done using \b NSNotificationCenter to observe this notifications: kPNClientAccessRightsChangeDidCompleteNotification,
 kPNClientAccessRightsChangeDidFailNotification.

 @note To be able use this API, you should provide \a 'secret' key which is used for signature generation.

 @note Make sure that you enabled "Access Manager" on https://admin.pubnub.com.

 @note You can pass a value less than \c 0 as \a 'accessPeriodDuration' argument to use default value (default value is \b 1440 minutes).

 @note When this API is used, it will grant \a 'read' access right and revoke \a 'write' access right for
 \a 'user' access level.

 @warning \a 'user' access level is low-layer of access tree. If one of upper layers will grant \a 'write' access rights,
 then \b PubNub client will ignore the fact that low-layer forbid \a 'write' access rights and depending on who override 
 this value (\a 'application' or \a 'channel' access level) will allow message posting to all channels and for all 
 (in case if \a 'write' access rights granted on \a 'application' access level) or allow messsage posting for all into specific 
 channel (for channel which is granted with \a 'write' access rights).
 
 @param channel
 \b PNChannel instance for which \b PubNub client should change access rights for specific client.
 
 @param clientsAuthorizationKeys
 Set of \a NSString instances which identify clients which should be granted with \a 'read' access right on specific \c channel.

 @param accessPeriodDuration
 Duration in minutes during which \a 'user' access level is granted with \a 'read' access rights.
 
 @param handlerBlock
 The block which will be called by \b PubNub client when one of success or error events will be received. The block takes two arguments:
 \c collection - \b PNAccessRightsCollection instance which hold set of \b PNAccessRightsInformation instances to
 describe new \a 'user' access rights; \c error - error which describes what exactly went wrong
 during access rights change. Always check \a error.code to find out what caused error (check PNErrorCodes header file
 and use \a -localizedDescription / \a -localizedFailureReason and \a -localizedRecoverySuggestion to get human readable description for error).

 @since 3.5.3

 @see PNConfiguration class

 @see PNChannel class

 @see PNAccessRightOptions class

 @see PNAccessRightsCollection class

 @see PNObservationCenter class
 
 @see +grantReadAccessRightForChannel:forPeriod:client:

 @see +grantWriteAccessRightForChannel:forPeriod:
 */
+ (void)grantReadAccessRightForChannel:(PNChannel *)channel forPeriod:(NSInteger)accessPeriodDuration
                               clients:(NSArray *)clientsAuthorizationKeys
           withCompletionHandlingBlock:(PNClientChannelAccessRightsChangeBlock)handlerBlock;

/**
 Grant \a 'write' access right on \a 'channel' access level which will be valid for specified amount of time.

 @code
 @endcode
 \b Example:

 @code
 [PubNub setupWithConfiguration:[PNConfiguration configurationForOrigin:@"pubsub.pubnub.com" publishKey:@"demo"
                                                           subscribeKey:@"demo" secretKey:@"my-secret-key"]
                    andDelegate:self];
 [PubNub connect];
 [PubNub grantWriteAccessRightForChannel:[PNChannel channelWithName:@"iosdev"] forPeriod:10];
 [PubNub grantReadAccessRightForApplicationAtPeriod:10];
 @endcode

 Code above configure access rights in a way, which won't allow subscription to \a 'iosdev' channel for \b 10 minutes. 
 But despite the fact that \a 'iosdev' channel access rights allow only message posting,
 \b PubNub client allowed to post subscribe to any channels because of upper-layer configuration (\a 'application' access level allow subscription
 to any channels for \b 10 minutes).

 And handle it with delegates:
 @code
 - (void)pubnubClient:(PubNub *)client didChangeAccessRights:(PNAccessRightsCollection *)accessRightsCollection {

     // PubNub client successfully changed access rights for 'channel' access level.
 }

 - (void)pubnubClient:(PubNub *)client accessRightsChangeDidFailWithError:(PNError *)error {

     // PubNub client did fail to revoke access rights from 'channel' access level.
     //
     // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
     // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
     // 'error.associatedObject' contains PNAccessRightOptions instance which describes access level for which change
     // has been requested.
 }
 @endcode

 There is also way to observe access rights change process from any place in your application using \b PNObservationCenter:
 @code
 [[PNObservationCenter defaultCenter] addAccessRightsChangeObserver:self withBlock:^(PNAccessRightsCollection *collection, PNError *error) {

     if (error == nil) {

         // PubNub client successfully changed access rights for 'channel' access level.
     }
     else {

         // PubNub client did fail to revoke access rights from 'channel' access level.
         //
         // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
         // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
         // 'error.associatedObject' contains PNAccessRightOptions instance which describes access level for which change
         // has been requested.
     }
 }];
 @endcode

 Also observation can be done using \b NSNotificationCenter to observe this notifications: kPNClientAccessRightsChangeDidCompleteNotification,
 kPNClientAccessRightsChangeDidFailNotification.

 @note To be able use this API, you should provide \a 'secret' key which is used for signature generation.

 @note Make sure that you enabled "Access Manager" on https://admin.pubnub.com.

 @note You can pass a value less than \c 0 as \a 'accessPeriodDuration' argument to use default value (default value is \b 1440 minutes).

 @note When this API is used, it will grant \a 'write' access right and revoke \a 'read' access right for
 \a 'channel' access level.

 @warning \a 'channel' access level is mid-layer of access tree. If \a 'user' access level grant \a 'read' access rights,
 then \b PubNub client will ignore the fact that mid-layer forbid \a 'read' access right and allow specific user (which has been granted
 with \a 'read' access right) to subscribe on target channel (for which \a 'read' access right has been granted).
 
 @param channel
 \b PNChannel instance for which \b PubNub client should change access rights to \a 'write'.

 @param accessPeriodDuration
 Duration in minutes during which \a 'channel' access level is granted with \a 'write' access rights.

 @since 3.5.3

 @see PNConfiguration class

 @see PNChannel class

 @see PNAccessRightOptions class

 @see PNAccessRightsCollection class

 @see PNObservationCenter class
 
 @see +grantWriteAccessRightForChannel:forPeriod:withCompletionHandlingBlock:

 @see +grantReadAccessRightForApplicationAtPeriod:
 */
+ (void)grantWriteAccessRightForChannel:(PNChannel *)channel forPeriod:(NSInteger)accessPeriodDuration;

/**
 Grant \a 'write' access right on \a 'channel' access level which will be valid for specified amount of time.
 
 @code
 @endcode
 This method extends \a +grantWriteAccessRightForChannel:forPeriod: and allow to specify access rights change handler block.

 @code
 @endcode
 \b Example:

 @code
 [PubNub setupWithConfiguration:[PNConfiguration configurationForOrigin:@"pubsub.pubnub.com" publishKey:@"demo"
                                                           subscribeKey:@"demo" secretKey:@"my-secret-key"]
                    andDelegate:self];
 [PubNub connect];
 [PubNub grantWriteAccessRightForChannel:[PNChannel channelWithName:@"iosdev"] forPeriod:10
             withCompletionHandlingBlock:^(PNAccessRightsCollection *collection, PNError *error) {

                 if (error == nil) {

                     // PubNub client successfully changed access rights for 'channel' access level.
                 }
                 else {
 
                     // PubNub client did fail to revoke access rights from 'channel' access level.
                     //
                     // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
                     // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
                     // 'error.associatedObject' contains PNAccessRightOptions instance which describes access level for which change
                     // has been requested.
                 }
 }];
 [PubNub grantReadAccessRightForApplicationAtPeriod:10];
 @endcode

 Code above configure access rights in a way, which won't allow subscription to \a 'iosdev' channel for \b 10 minutes. 
 But despite the fact that \a 'iosdev' channel access rights allow only message posting, \b PubNub client allowed to post
 subscribe to any channels because of upper-layer configuration (\a 'application' access level allow subscription
 to any channels for \b 10 minutes).

 And handle it with delegates:
 @code
 - (void)pubnubClient:(PubNub *)client didChangeAccessRights:(PNAccessRightsCollection *)accessRightsCollection {

     // PubNub client successfully changed access rights for 'channel' access level.
 }

 - (void)pubnubClient:(PubNub *)client accessRightsChangeDidFailWithError:(PNError *)error {

     // PubNub client did fail to revoke access rights from 'channel' access level.
     //
     // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
     // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
     // 'error.associatedObject' contains PNAccessRightOptions instance which describes access level for which change
     // has been requested.
 }
 @endcode

 There is also way to observe access rights change process from any place in your application using \b PNObservationCenter:
 @code
 [[PNObservationCenter defaultCenter] addAccessRightsChangeObserver:self withBlock:^(PNAccessRightsCollection *collection, PNError *error) {

     if (error == nil) {

         // PubNub client successfully changed access rights for 'channel' access level.
     }
     else {

         // PubNub client did fail to revoke access rights from 'channel' access level.
         //
         // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
         // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
         // 'error.associatedObject' contains PNAccessRightOptions instance which describes access level for which change
         // has been requested.
     }
 }];
 @endcode

 Also observation can be done using \b NSNotificationCenter to observe this notifications: kPNClientAccessRightsChangeDidCompleteNotification,
 kPNClientAccessRightsChangeDidFailNotification.

 @note To be able use this API, you should provide \a 'secret' key which is used for signature generation.

 @note Make sure that you enabled "Access Manager" on https://admin.pubnub.com.

 @note You can pass a value less than \c 0 as \a 'accessPeriodDuration' argument to use default value (default value is \b 1440 minutes).

 @note When this API is used, it will grant \a 'write' access right and revoke \a 'read' access right for
 \a 'channel' access level.

 @warning \a 'channel' access level is mid-layer of access tree. If \a 'user' access level grant \a 'read' access rights,
 then \b PubNub client will ignore the fact that mid-layer forbid \a 'read' access right and allow specific user (which has been granted
 with \a 'read' access right) to subscribe on target channel (for which \a 'read' access right has been granted).
 
 @param channel
 \b PNChannel instance for which \b PubNub client should change access rights to \a 'write'.

 @param accessPeriodDuration
 Duration in minutes during which \a 'channel' access level is granted with \a 'write' access rights.
 
 @param handlerBlock
 The block which will be called by \b PubNub client when one of success or error events will be received. The block takes two arguments:
 \c collection - \b PNAccessRightsCollection instance which hold set of \b PNAccessRightsInformation instances to
 describe new \a 'channel' access rights; \c error - error which describes what exactly went wrong
 during access rights change. Always check \a error.code to find out what caused error (check PNErrorCodes header file
 and use \a -localizedDescription / \a -localizedFailureReason and \a -localizedRecoverySuggestion to get human readable description for error).

 @since 3.5.3

 @see PNConfiguration class

 @see PNChannel class

 @see PNAccessRightOptions class

 @see PNAccessRightsCollection class

 @see PNObservationCenter class
 
 @see +grantWriteAccessRightForChannel:forPeriod:

 @see +grantReadAccessRightForApplicationAtPeriod:
 */
+ (void)grantWriteAccessRightForChannel:(PNChannel *)channel forPeriod:(NSInteger)accessPeriodDuration
            withCompletionHandlingBlock:(PNClientChannelAccessRightsChangeBlock)handlerBlock;
+ (void)grantWriteAccessRightForChannel:(PNChannel *)channel forPeriod:(NSInteger)accessPeriodDuration
                                 client:(NSString *)clientAuthorizationKey;
+ (void)grantWriteAccessRightForChannel:(PNChannel *)channel forPeriod:(NSInteger)accessPeriodDuration
                                 client:(NSString *)clientAuthorizationKey
            withCompletionHandlingBlock:(PNClientChannelAccessRightsChangeBlock)handlerBlock;

/**
 Grant \a 'write' access right on \a 'channel' access level which will be valid for specified amount of time for specific set of channels.

 @code
 @endcode
 \b Example:

 @code
 [PubNub setupWithConfiguration:[PNConfiguration configurationForOrigin:@"pubsub.pubnub.com" publishKey:@"demo"
                                                           subscribeKey:@"demo" secretKey:@"my-secret-key"]
                    andDelegate:self];
 [PubNub connect];
 [PubNub grantWriteAccessRightForChannels:[PNChannel channelsWithNames:@[@"iosdev", @"androiddev", @"macosdev"]] forPeriod:10];
 [PubNub grantReadAccessRightForApplicationAtPeriod:10];
 @endcode

 Code above configure access rights in a way, which won't allow subscription to \a 'iosdev', \a 'androiddev' and \a 'macosdev' channels
 for \b 10 minutes. But despite the fact that\a 'iosdev', \a 'androiddev' and \a 'macosdev' channels access rights
 allow only message posting, \b PubNub client allowed to post subscribe to any channels because of upper-layer configuration (\a 'application' access level allow subscription
 to any channels for \b 10 minutes).

 And handle it with delegates:
 @code
 - (void)pubnubClient:(PubNub *)client didChangeAccessRights:(PNAccessRightsCollection *)accessRightsCollection {

     // PubNub client successfully changed access rights for 'channel' access level.
 }

 - (void)pubnubClient:(PubNub *)client accessRightsChangeDidFailWithError:(PNError *)error {

     // PubNub client did fail to revoke access rights from 'channel' access level.
     //
     // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
     // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
     // 'error.associatedObject' contains PNAccessRightOptions instance which describes access level for which change
     // has been requested.
 }
 @endcode

 There is also way to observe access rights change process from any place in your application using \b PNObservationCenter:
 @code
 [[PNObservationCenter defaultCenter] addAccessRightsChangeObserver:self withBlock:^(PNAccessRightsCollection *collection, PNError *error) {

     if (error == nil) {

         // PubNub client successfully changed access rights for 'channel' access level.
     }
     else {

         // PubNub client did fail to revoke access rights from 'channel' access level.
         //
         // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
         // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
         // 'error.associatedObject' contains PNAccessRightOptions instance which describes access level for which change
         // has been requested.
     }
 }];
 @endcode

 Also observation can be done using \b NSNotificationCenter to observe this notifications: kPNClientAccessRightsChangeDidCompleteNotification,
 kPNClientAccessRightsChangeDidFailNotification.

 @note To be able use this API, you should provide \a 'secret' key which is used for signature generation.

 @note Make sure that you enabled "Access Manager" on https://admin.pubnub.com.

 @note You can pass a value less than \c 0 as \a 'accessPeriodDuration' argument to use default value (default value is \b 1440 minutes).

 @note When this API is used, it will grant \a 'write' access right and revoke \a 'read' access right for
 \a 'channel' access level.

 @warning \a 'channel' access level is mid-layer of access tree. If \a 'user' access level grant \a 'read' access rights,
 then \b PubNub client will ignore the fact that mid-layer forbid \a 'read' access right and allow specific user (which has been granted
 with \a 'read' access right) to subscribe on target channel (for which \a 'read' access right has been granted).
 
 @param channels
 List of \b PNChannel instances for which \b PubNub client should change access rights to \a 'write'.

 @param accessPeriodDuration
 Duration in minutes during which \a 'channel' access level is granted with \a 'write' access rights.

 @since 3.5.3

 @see PNConfiguration class

 @see PNChannel class

 @see PNAccessRightOptions class

 @see PNAccessRightsCollection class

 @see PNObservationCenter class
 
 @see +grantWriteAccessRightForChannels:forPeriod:withCompletionHandlingBlock:

 @see +grantReadAccessRightForApplicationAtPeriod:
 */
+ (void)grantWriteAccessRightForChannels:(NSArray *)channels forPeriod:(NSInteger)accessPeriodDuration;

/**
 Grant \a 'write' access right on \a 'channel' access level which will be valid for specified amount of time for specific set of channels.
 
 @code
 @endcode
 This method extends \a +grantWriteAccessRightForChannels:forPeriod: and allow to specify access rights change handler block.

 @code
 @endcode
 \b Example:

 @code
 [PubNub setupWithConfiguration:[PNConfiguration configurationForOrigin:@"pubsub.pubnub.com" publishKey:@"demo"
                                                           subscribeKey:@"demo" secretKey:@"my-secret-key"]
                    andDelegate:self];
 [PubNub connect];
 [PubNub grantWriteAccessRightForChannels:[PNChannel channelsWithNames:@[@"iosdev", @"androiddev", @"macosdev"]] forPeriod:10
              withCompletionHandlingBlock:^(PNAccessRightsCollection *collection, PNError *error) {

                  if (error == nil) {

                      // PubNub client successfully changed access rights for 'channel' access level.
                  }
                  else {
 
                      // PubNub client did fail to revoke access rights from 'channel' access level.
                      //
                      // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
                      // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
                      // 'error.associatedObject' contains PNAccessRightOptions instance which describes access level for which change
                      // has been requested.
                  }
 }];
 [PubNub grantReadAccessRightForApplicationAtPeriod:10];
 @endcode

 Code above configure access rights in a way, which won't allow subscription to \a 'iosdev', \a 'androiddev' and \a 'macosdev' channels
 for \b 10 minutes. But despite the fact that\a 'iosdev', \a 'androiddev' and \a 'macosdev' channels access rights
 allow only message posting, \b PubNub client allowed to post subscribe to any channels because of upper-layer configuration (\a 'application' access level allow subscription
 to any channels for \b 10 minutes).

 And handle it with delegates:
 @code
 - (void)pubnubClient:(PubNub *)client didChangeAccessRights:(PNAccessRightsCollection *)accessRightsCollection {

     // PubNub client successfully changed access rights for 'channel' access level.
 }

 - (void)pubnubClient:(PubNub *)client accessRightsChangeDidFailWithError:(PNError *)error {

     // PubNub client did fail to revoke access rights from 'channel' access level.
     //
     // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
     // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
     // 'error.associatedObject' contains PNAccessRightOptions instance which describes access level for which change
     // has been requested.
 }
 @endcode

 There is also way to observe access rights change process from any place in your application using \b PNObservationCenter:
 @code
 [[PNObservationCenter defaultCenter] addAccessRightsChangeObserver:self withBlock:^(PNAccessRightsCollection *collection, PNError *error) {

     if (error == nil) {

         // PubNub client successfully changed access rights for 'channel' access level.
     }
     else {

         // PubNub client did fail to revoke access rights from 'channel' access level.
         //
         // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
         // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
         // 'error.associatedObject' contains PNAccessRightOptions instance which describes access level for which change
         // has been requested.
     }
 }];
 @endcode

 Also observation can be done using \b NSNotificationCenter to observe this notifications: kPNClientAccessRightsChangeDidCompleteNotification,
 kPNClientAccessRightsChangeDidFailNotification.

 @note To be able use this API, you should provide \a 'secret' key which is used for signature generation.

 @note Make sure that you enabled "Access Manager" on https://admin.pubnub.com.

 @note You can pass a value less than \c 0 as \a 'accessPeriodDuration' argument to use default value (default value is \b 1440 minutes).

 @note When this API is used, it will grant \a 'write' access right and revoke \a 'read' access right for
 \a 'channel' access level.

 @warning \a 'channel' access level is mid-layer of access tree. If \a 'user' access level grant \a 'read' access rights,
 then \b PubNub client will ignore the fact that mid-layer forbid \a 'read' access right and allow specific user (which has been granted
 with \a 'read' access right) to subscribe on target channel (for which \a 'read' access right has been granted).
 
 @param channels
 List of \b PNChannel instances for which \b PubNub client should change access rights to \a 'write'.

 @param accessPeriodDuration
 Duration in minutes during which \a 'channel' access level is granted with \a 'write' access rights.
 
 @param handlerBlock
 The block which will be called by \b PubNub client when one of success or error events will be received. The block takes two arguments:
 \c collection - \b PNAccessRightsCollection instance which hold set of \b PNAccessRightsInformation instances to
 describe new \a 'channel' access rights; \c error - error which describes what exactly went wrong
 during access rights change. Always check \a error.code to find out what caused error (check PNErrorCodes header file
 and use \a -localizedDescription / \a -localizedFailureReason and \a -localizedRecoverySuggestion to get human readable description for error).

 @since 3.5.3

 @see PNConfiguration class

 @see PNChannel class

 @see PNAccessRightOptions class

 @see PNAccessRightsCollection class

 @see PNObservationCenter class
 
 @see +grantWriteAccessRightForChannels:forPeriod:

 @see +grantReadAccessRightForApplicationAtPeriod:
 */
+ (void)grantWriteAccessRightForChannels:(NSArray *)channels forPeriod:(NSInteger)accessPeriodDuration
             withCompletionHandlingBlock:(PNClientChannelAccessRightsChangeBlock)handlerBlock;

/**
 Grant \a 'write' access right on \a 'user' access level which will be valid for specified amount of time.

 @code
 @endcode
 \b Example:

 @code
 [PubNub setupWithConfiguration:[PNConfiguration configurationForOrigin:@"pubsub.pubnub.com" publishKey:@"demo"
                                                           subscribeKey:@"demo" secretKey:@"my-secret-key"]
                    andDelegate:self];
 [PubNub connect];
 [PubNub grantWriteAccessRightForChannel:[PNChannel channelWithName:@"iosdev"] forPeriod:10 client:@[@"spectator", @"visitor"]];
 [PubNub grantReadAccessRightForChannel:[PNChannel channelWithName:@"iosdev"] forPeriod:10];
 @endcode
 
 Code above configure access rights in a way, which won't allow subscription on \a 'iosdev' channel for clients with \a 'spectator' and \a 'visitor'
 authorization keys for \b 10 minutes. But despite the fact that \a 'iosdev' channel access rights allow only subscription for \a 'spectator' and \a 'visitor', \b PubNub client allowed to post messages to any channels because of upper-layer configuration (\a 'channel' access level allow message posting to any channels for \b 10 minutes).

 And handle it with delegates:
 @code
 - (void)pubnubClient:(PubNub *)client didChangeAccessRights:(PNAccessRightsCollection *)accessRightsCollection {

     // PubNub client successfully changed access rights for 'user' access level.
 }

 - (void)pubnubClient:(PubNub *)client accessRightsChangeDidFailWithError:(PNError *)error {

     // PubNub client did fail to revoke access rights from 'user' access level.
     //
     // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
     // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
     // 'error.associatedObject' contains PNAccessRightOptions instance which describes access level for which change
     // has been requested.
 }
 @endcode

 There is also way to observe access rights change process from any place in your application using \b PNObservationCenter:
 @code
 [[PNObservationCenter defaultCenter] addAccessRightsChangeObserver:self withBlock:^(PNAccessRightsCollection *collection, PNError *error) {

     if (error == nil) {

         // PubNub client successfully changed access rights for 'user' access level.
     }
     else {

         // PubNub client did fail to revoke access rights from 'user' access level.
         //
         // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
         // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
         // 'error.associatedObject' contains PNAccessRightOptions instance which describes access level for which change
         // has been requested.
     }
 }];
 @endcode

 Also observation can be done using \b NSNotificationCenter to observe this notifications: kPNClientAccessRightsChangeDidCompleteNotification,
 kPNClientAccessRightsChangeDidFailNotification.

 @note To be able use this API, you should provide \a 'secret' key which is used for signature generation.

 @note Make sure that you enabled "Access Manager" on https://admin.pubnub.com.

 @note You can pass a value less than \c 0 as \a 'accessPeriodDuration' argument to use default value (default value is \b 1440 minutes).

 @note When this API is used, it will grant \a 'write' access right and revoke \a 'read' access right for
 \a 'user' access level.

 @warning \a 'user' access level is low-layer of access tree. If one of upper layers will grant \a 'read' access rights,
 then \b PubNub client will ignore the fact that low-layer forbid \a 'read' access rights and depending on who override
 this value (\a 'application' or \a 'channel' access level) will allow subscription to all channels and for all
 (in case if \a 'read' access rights granted on \a 'application' access level) or allow subscription for all on specific
 channel (for channel which is granted with \a 'read' access rights).
 
 @param channel
 \b PNChannel instance for which \b PubNub client should change access rights for specific client.
 
 @param clientsAuthorizationKeys
 Set of \a NSString instances which identify clients which should be granted with \a 'write' access right on specific \c channel.

 @param accessPeriodDuration
 Duration in minutes during which \a 'user' access level is granted with \a 'write' access rights.
 
 @param handlerBlock
 The block which will be called by \b PubNub client when one of success or error events will be received. The block takes two arguments:
 \c collection - \b PNAccessRightsCollection instance which hold set of \b PNAccessRightsInformation instances to
 describe new \a 'user' access rights; \c error - error which describes what exactly went wrong
 during access rights change. Always check \a error.code to find out what caused error (check PNErrorCodes header file
 and use \a -localizedDescription / \a -localizedFailureReason and \a -localizedRecoverySuggestion to get human readable description for error).

 @since 3.5.3

 @see PNConfiguration class

 @see PNChannel class

 @see PNAccessRightOptions class

 @see PNAccessRightsCollection class

 @see PNObservationCenter class
 
 @see +grantWriteAccessRightForChannel:forPeriod:clients:withCompletionHandlingBlock:

 @see +grantReadAccessRightForChannel:forPeriod:
 */
+ (void)grantWriteAccessRightForChannel:(PNChannel *)channel forPeriod:(NSInteger)accessPeriodDuration
                                clients:(NSArray *)clientsAuthorizationKeys;

/**
 Grant \a 'write' access right on \a 'user' access level which will be valid for specified amount of time for specific set of cliens authorization keys.
 
 @code
 @endcode
 This method extends \a +grantWriteAccessRightForChannel:forPeriod:clients: and allow to specify access rights change handler block.

 @code
 @endcode
 \b Example:

 @code
 [PubNub setupWithConfiguration:[PNConfiguration configurationForOrigin:@"pubsub.pubnub.com" publishKey:@"demo"
                                                           subscribeKey:@"demo" secretKey:@"my-secret-key"]
                    andDelegate:self];
 [PubNub connect];
 [PubNub grantWriteAccessRightForChannel:[PNChannel channelWithName:@"iosdev"] forPeriod:10 client:@[@"spectator", @"visitor"]
             withCompletionHandlingBlock:^(PNAccessRightsCollection *collection, PNError *error) {

                 if (error == nil) {

                     // PubNub client successfully changed access rights for 'user' access level.
                 }
                 else {
 
                     // PubNub client did fail to revoke access rights from 'user' access level.
                     //
                     // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
                     // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
                     // 'error.associatedObject' contains PNAccessRightOptions instance which describes access level for which change
                     // has been requested.
                 }
 }];
 [PubNub grantWriteAccessRightForChannel:[PNChannel channelWithName:@"iosdev"] forPeriod:10];
 @endcode
 
 Code above configure access rights in a way, which won't allow message posting for clients with \a 'spectator' and \a 'visitor'
 authorization keys into \a 'iosdev' channel for \b 10 minutes. But despite the fact that \a 'iosdev' channel access
 rights allow only subscription for \a 'spectator' and \a 'visitor', \b PubNub client allowed to post messages to any channels because of upper-layer
 configuration (\a 'channel' access level allow message posting to any channels for \b 10 minutes).

 And handle it with delegates:
 @code
 - (void)pubnubClient:(PubNub *)client didChangeAccessRights:(PNAccessRightsCollection *)accessRightsCollection {

     // PubNub client successfully changed access rights for 'user' access level.
 }

 - (void)pubnubClient:(PubNub *)client accessRightsChangeDidFailWithError:(PNError *)error {

     // PubNub client did fail to revoke access rights from 'user' access level.
     //
     // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
     // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
     // 'error.associatedObject' contains PNAccessRightOptions instance which describes access level for which change
     // has been requested.
 }
 @endcode

 There is also way to observe access rights change process from any place in your application using \b PNObservationCenter:
 @code
 [[PNObservationCenter defaultCenter] addAccessRightsChangeObserver:self withBlock:^(PNAccessRightsCollection *collection, PNError *error) {

     if (error == nil) {

         // PubNub client successfully changed access rights for 'user' access level.
     }
     else {

         // PubNub client did fail to revoke access rights from 'user' access level.
         //
         // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
         // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
         // 'error.associatedObject' contains PNAccessRightOptions instance which describes access level for which change
         // has been requested.
     }
 }];
 @endcode

 Also observation can be done using \b NSNotificationCenter to observe this notifications: kPNClientAccessRightsChangeDidCompleteNotification,
 kPNClientAccessRightsChangeDidFailNotification.

 @note To be able use this API, you should provide \a 'secret' key which is used for signature generation.

 @note Make sure that you enabled "Access Manager" on https://admin.pubnub.com.

 @note You can pass a value less than \c 0 as \a 'accessPeriodDuration' argument to use default value (default value is \b 1440 minutes).

 @note When this API is used, it will grant \a 'write' access right and revoke \a 'read' access right for
 \a 'user' access level.

 @warning \a 'user' access level is low-layer of access tree. If one of upper layers will grant \a 'read' access rights,
 then \b PubNub client will ignore the fact that low-layer forbid \a 'read' access rights and depending on who override
 this value (\a 'application' or \a 'channel' access level) will allow subscription to all channels and for all
 (in case if \a 'read' access rights granted on \a 'application' access level) or allow subscription for all on specific
 channel (for channel which is granted with \a 'read' access rights).
 
 @param channel
 \b PNChannel instance for which \b PubNub client should change access rights for specific client.
 
 @param clientsAuthorizationKeys
 Set of \a NSString instances which identify clients which should be granted with \a 'write' access right on specific \c channel.

 @param accessPeriodDuration
 Duration in minutes during which \a 'user' access level is granted with \a 'write' access rights.
 
 @param handlerBlock
 The block which will be called by \b PubNub client when one of success or error events will be received. The block takes two arguments:
 \c collection - \b PNAccessRightsCollection instance which hold set of \b PNAccessRightsInformation instances to
 describe new \a 'user' access rights; \c error - error which describes what exactly went wrong
 during access rights change. Always check \a error.code to find out what caused error (check PNErrorCodes header file
 and use \a -localizedDescription / \a -localizedFailureReason and \a -localizedRecoverySuggestion to get human readable description for error).

 @since 3.5.3

 @see PNConfiguration class

 @see PNChannel class

 @see PNAccessRightOptions class

 @see PNAccessRightsCollection class

 @see PNObservationCenter class
 
 @see +grantWriteAccessRightForChannel:forPeriod:clients:

 @see +grantReadAccessRightForChannel:forPeriod:
 */
+ (void)grantWriteAccessRightForChannel:(PNChannel *)channel forPeriod:(NSInteger)accessPeriodDuration
                                clients:(NSArray *)clientsAuthorizationKeys
            withCompletionHandlingBlock:(PNClientChannelAccessRightsChangeBlock)handlerBlock;

+ (void)grantAllAccessRightsForChannel:(PNChannel *)channel forPeriod:(NSInteger)accessPeriodDuration;
+ (void)grantAllAccessRightsForChannel:(PNChannel *)channel forPeriod:(NSInteger)accessPeriodDuration
           withCompletionHandlingBlock:(PNClientChannelAccessRightsChangeBlock)handlerBlock;
+ (void)grantAllAccessRightsForChannel:(PNChannel *)channel forPeriod:(NSInteger)accessPeriodDuration
                                client:(NSString *)clientAuthorizationKey;
+ (void)grantAllAccessRightsForChannel:(PNChannel *)channel forPeriod:(NSInteger)accessPeriodDuration
                                client:(NSString *)clientAuthorizationKey
           withCompletionHandlingBlock:(PNClientChannelAccessRightsChangeBlock)handlerBlock;
+ (void)grantAllAccessRightsForChannels:(NSArray *)channels forPeriod:(NSInteger)accessPeriodDuration;
+ (void)grantAllAccessRightsForChannels:(NSArray *)channels forPeriod:(NSInteger)accessPeriodDuration
            withCompletionHandlingBlock:(PNClientChannelAccessRightsChangeBlock)handlerBlock;
+ (void)grantAllAccessRightsForChannel:(PNChannel *)channel forPeriod:(NSInteger)accessPeriodDuration
                               clients:(NSArray *)clientsAuthorizationKeys;
+ (void)grantAllAccessRightsForChannel:(PNChannel *)channel forPeriod:(NSInteger)accessPeriodDuration
                               clients:(NSArray *)clientsAuthorizationKeys
           withCompletionHandlingBlock:(PNClientChannelAccessRightsChangeBlock)handlerBlock;

+ (void)revokeAccessRightsForChannel:(PNChannel *)channel;


/**
 Revoke all access rights on whole \a 'channel' level.

 @code
 @endcode
 This method extends \a +revokeAccessRightsForChannel: and allow to specify access rights change handler block.

 @code
 @endcode
 \b Example:

 @code
 [PubNub setConfiguration:[PNConfiguration defaultConfiguration] andDelegate:self];
 [PubNub connect];
 [PubNub grantAllAccessRightsForChannel:[PNChannel channelWithName:@"iosdev"] forPeriod:10 client:@"admin"];
 [PubNub revokeAccessRightsForChannel:[PNChannel channelWithName:@"iosdev"] withCompletionHandlingBlock:^(PNAccessRightsCollection *collection, PNError *error) {

     if (error == nil) {

         // PubNub client successfully revoked all access rights from channel level.
     }
     else {

         // PubNub client did fail to revoke access rights from channel level.
         //
         // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
         // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
         // 'error.associatedObject' contains PNAccessRightOptions instance which describes access level for which revoke has been requested.
     }
 }];
 @endcode

 Despite the fact that all access rights has been revoked on \a 'channel' level in code above,
 \b PubNub client will be able to subscribe and post into \a "iosdev" channel for \b 10 minutes from the client which
 use \a "admin" authorization key.

 And handle it with delegates:
 @code
 - (void)pubnubClient:(PubNub *)client didChangeAccessRights:(PNAccessRightsCollection *)accessRightsCollection {

     // PubNub client successfully revoked all access rights from channel level.
 }

 - (void)pubnubClient:(PubNub *)client accessRightsChangeDidFailWithError:(PNError *)error {

     // PubNub client did fail to revoke access rights from channel level.
     //
     // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
     // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
     // 'error.associatedObject' contains PNAccessRightOptions instance which describes access level for which revoke has been requested.
 }

 There is also way to observe revoke process from any place in your application using \b PNObservationCenter:
 @code
 [[PNObservationCenter defaultCenter] addAccessRightsChangeObserver:self withBlock:^(PNAccessRightsCollection *collection, PNError *error) {

     if (error == nil) {

         // PubNub client successfully revoked all access rights from channel level.
     }
     else {

         // PubNub client did fail to revoke access rights from channel level.
         //
         // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
         // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
         // 'error.associatedObject' contains PNAccessRightOptions instance which describes access level for which revoke has been requested.
     }
 }];

 Also observation can be done using \b NSNotificationCenter to observe this notifications: kPNClientAccessRightsChangeDidCompleteNotification,
 kPNClientAccessRightsChangeDidFailNotification.

 @param channel
 \b PNChannel instance from which \b PubNub client should revoke all access rights.

 @param handlerBlock
 The block which will be called by \b PubNub client when one of success or error events will be received. The block
 takes two arguments:
 \c collection - \b PNAccessRightsCollection instance which hold set of \b PNAccessRightsInformation instances to
 describe new \a 'channel' access rights; \c error - error which describes what exactly went wrong
 during access rights revoke. Always check \a error.code to find out what caused error (check PNErrorCodes header file
 and use \a -localizedDescription / \a -localizedFailureReason and \a -localizedRecoverySuggestion to get human readable description for error).

 @note Make sure that you enabled "Access Manager" on https://admin.pubnub.com.

 @warning As soon as "Access Manager" will be enabled, all \b PubNub clients won't be able to subscribe / publish to
 any channels till the moment, when access rights will be configured.

 @see \b PNError class

 @see \b PNAccessRightOptions class

 @see \b PNAccessRightsCollection class

 @see \b PNAccessRightsInformation class

 @see \b PNObservationCenter class

 @see \a +revokeAccessRightsForChannel:

 @see \a +grantAllAccessRightsForChannel:forPeriod:client:
 */
+ (void)revokeAccessRightsForChannel:(PNChannel *)channel
         withCompletionHandlingBlock:(PNClientChannelAccessRightsChangeBlock)handlerBlock;
+ (void)revokeAccessRightsForChannel:(PNChannel *)channel client:(NSString *)clientAuthorizationKey;

/**
 Revoke all access rights on \a 'user' level. Access rights will be revoked for specific user on specific channel.

 @code
 @endcode
 This method extends \a +revokeAccessRightsForChannel:client: and allow to specify access rights change handler block.

 @code
 @endcode
 \b Example:

 @code
 [PubNub setConfiguration:[PNConfiguration defaultConfiguration] andDelegate:self];
 [PubNub connect];
 [PubNub grantAllAccessRightsForChannel:[PNChannel channelWithName:@"iosdev"] forPeriod:10 clients:@[@"client", @"admin"]];
 [PubNub revokeAccessRightsForChannel:[PNChannel channelWithName:@"iosdev"] client:@"admin"
           withCompletionHandlingBlock:^(PNAccessRightsCollection *collection, PNError *error) {

     if (error == nil) {

         // PubNub client successfully revoked all access rights for user at channel level.
     }
     else {

         // PubNub client did fail to revoke access rights for user at channel level.
         //
         // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
         // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
         // 'error.associatedObject' contains PNAccessRightOptions instance which describes access level for which revoke has been requested.
     }
 }];
 @endcode

 And handle it with delegates:
 @code
 - (void)pubnubClient:(PubNub *)client didChangeAccessRights:(PNAccessRightsCollection *)accessRightsCollection {

     // PubNub client successfully revoked all access rights for user at channel level.
 }

 - (void)pubnubClient:(PubNub *)client accessRightsChangeDidFailWithError:(PNError *)error {

     // PubNub client did fail to revoke access rights for user at channel level.
     //
     // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
     // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
     // 'error.associatedObject' contains PNAccessRightOptions instance which describes access level for which revoke has been requested.
 }

 There is also way to observe revoke process from any place in your application using \b PNObservationCenter:
 @code
 [[PNObservationCenter defaultCenter] addAccessRightsChangeObserver:self withBlock:^(PNAccessRightsCollection *collection, PNError *error) {

     if (error == nil) {

         // PubNub client successfully revoked all access rights for user at channel level.
     }
     else {

         // PubNub client did fail to revoke access rights for user at channel level.
         //
         // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
         // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
         // 'error.associatedObject' contains PNAccessRightOptions instance which describes access level for which revoke has been requested.
     }
 }];

 Also observation can be done using \b NSNotificationCenter to observe this notifications: kPNClientAccessRightsChangeDidCompleteNotification,
 kPNClientAccessRightsChangeDidFailNotification.

 @param channel
 \b PNChannel instance for which \b PubNub client should revoke all access rights on specific user \c clientAuthorizationKey.

 @param clientAuthorizationKey
 \a NSString instance which holds client authorization key from which access rights should be revoked.

 @param handlerBlock
 The block which will be called by \b PubNub client when one of success or error events will be received. The block
 takes two arguments:
 \c collection - \b PNAccessRightsCollection instance which hold set of \b PNAccessRightsInformation instances to
 describe new \a 'channel' access rights; \c error - error which describes what exactly went wrong
 during access rights revoke. Always check \a error.code to find out what caused error (check PNErrorCodes header file
 and use \a -localizedDescription / \a -localizedFailureReason and \a -localizedRecoverySuggestion to get human readable description for error).

 @note Make sure that you enabled "Access Manager" on https://admin.pubnub.com.

 @warning As soon as "Access Manager" will be enabled, all \b PubNub clients won't be able to subscribe / publish to
 any channels till the moment, when access rights will be configured.

 @see \b PNError class

 @see \b PNAccessRightOptions class

 @see \b PNAccessRightsCollection class

 @see \b PNAccessRightsInformation class

 @see \b PNObservationCenter class

 @see \a +revokeAccessRightsForChannel:client:

 @see \a +grantAllAccessRightsForChannel:forPeriod:clients:
 */
+ (void)revokeAccessRightsForChannel:(PNChannel *)channel client:(NSString *)clientAuthorizationKey
         withCompletionHandlingBlock:(PNClientChannelAccessRightsChangeBlock)handlerBlock;
+ (void)revokeAccessRightsForChannels:(NSArray *)channels;

/**
 Revoke all access rights on whole \a 'channel' level. This method allow to revoke access rights for the set of \b
 PNChannel instances.

 @code
 @endcode
 This method extends \a +revokeAccessRightsForChannels: and allow to specify access rights change handler block.

 @code
 @endcode
 \b Example:

 @code
 [PubNub setConfiguration:[PNConfiguration defaultConfiguration] andDelegate:self];
 [PubNub connect];
 [PubNub grantAllAccessRightsForChannel:[PNChannel channelWithName:@"iosdev"] forPeriod:10 clients:@[@"client", @"admin"]];
 [PubNub revokeAccessRightsForChannels:[PNChannel channelsWithNames:@[@"iosdev", @"macosdev"]]
           withCompletionHandlingBlock:^(PNAccessRightsCollection *collection, PNError *error) {

     if (error == nil) {

         // PubNub client successfully revoked all access rights from channel level.
     }
     else {

         // PubNub client did fail to revoke access rights from channel level.
         //
         // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
         // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
         // 'error.associatedObject' contains PNAccessRightOptions instance which describes access level for which revoke has been requested.
     }
 }];
 @endcode

 Despite the fact that all access rights has been revoked on \a 'channel' level in code above,
 \b PubNub client will be able to subscribe and post into \a "iosdev" channel for \b 10 minutes from the client which
 use \a "admin" authorization key.

 And handle it with delegates:
 @code
 - (void)pubnubClient:(PubNub *)client didChangeAccessRights:(PNAccessRightsCollection *)accessRightsCollection {

     // PubNub client successfully revoked all access rights from channel level.
 }

 - (void)pubnubClient:(PubNub *)client accessRightsChangeDidFailWithError:(PNError *)error {

     // PubNub client did fail to revoke access rights from channel level.
     //
     // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
     // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
     // 'error.associatedObject' contains PNAccessRightOptions instance which describes access level for which revoke has been requested.
 }

 There is also way to observe revoke process from any place in your application using \b PNObservationCenter:
 @code
 [[PNObservationCenter defaultCenter] addAccessRightsChangeObserver:self withBlock:^(PNAccessRightsCollection *collection, PNError *error) {

     if (error == nil) {

         // PubNub client successfully revoked all access rights from channel level.
     }
     else {

         // PubNub client did fail to revoke access rights from channel level.
         //
         // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
         // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
         // 'error.associatedObject' contains PNAccessRightOptions instance which describes access level for which revoke has been requested.
     }
 }];

 Also observation can be done using \b NSNotificationCenter to observe this notifications: kPNClientAccessRightsChangeDidCompleteNotification,
 kPNClientAccessRightsChangeDidFailNotification.

 @param channels
 List of \b PNChannel instances from which \b PubNub client should revoke all access rights.

 @param handlerBlock
 The block which will be called by \b PubNub client when one of success or error events will be received. The block
 takes two arguments:
 \c collection - \b PNAccessRightsCollection instance which hold set of \b PNAccessRightsInformation instances to
 describe new \a 'channel' access rights; \c error - error which describes what exactly went wrong
 during access rights revoke. Always check \a error.code to find out what caused error (check PNErrorCodes header file
 and use \a -localizedDescription / \a -localizedFailureReason and \a -localizedRecoverySuggestion to get human readable description for error).

 @note Make sure that you enabled "Access Manager" on https://admin.pubnub.com.

 @warning As soon as "Access Manager" will be enabled, all \b PubNub clients won't be able to subscribe / publish to
 any channels till the moment, when access rights will be configured.

 @see \b PNError class

 @see \b PNAccessRightOptions class

 @see \b PNAccessRightsCollection class

 @see \b PNAccessRightsInformation class

 @see \b PNObservationCenter class

 @see \a +revokeAccessRightsForChannels:

 @see \a +grantAllAccessRightsForChannel:forPeriod:clients:
 */
+ (void)revokeAccessRightsForChannels:(NSArray *)channels
          withCompletionHandlingBlock:(PNClientChannelAccessRightsChangeBlock)handlerBlock;
+ (void)revokeAccessRightsForChannel:(PNChannel *)channel clients:(NSArray *)clientsAuthorizationKeys;
+ (void)revokeAccessRightsForChannel:(PNChannel *)channel clients:(NSArray *)clientsAuthorizationKeys
         withCompletionHandlingBlock:(PNClientChannelAccessRightsChangeBlock)handlerBlock;

/**
 Audit access rights for \a 'application' level. \a 'application' level is top-layer of access rights tree which will
 also provide information about it's child levels: \a 'channel' and \a 'user' levels.

 @code
 @endcode
 \b Example:

 @code
 [PubNub setConfiguration:[PNConfiguration defaultConfiguration] andDelegate:self];
 [PubNub connect];
 [PubNub grantReadAccessRightsForApplicationAtPeriod:10];
 [PubNub auditAccessRightsForApplication];
 @endcode

 And handle it with delegates:
 @code
 - (void)pubnubClient:(PubNub *)client didAuditAccessRights:(PNAccessRightsCollection *)accessRightsCollection {

     // PubNub client successfully pulled out access rights information for specified object (object defined by set
     // of parameters used for \a 'audit' request.
 }

 - (void)pubnubClient:(PubNub *)client accessRightsAuditDidFailWithError:(PNError *)error {

     // PubNub client did fail to pull out access rights information for specified object (object defined by set
     // of parameters used for \a 'audit' request.
     //
     // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
     // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
     // 'error.associatedObject' contains PNAccessRightOptions instance which describes access level for which audition has been requested.
 }
 @endcode

 There is also way to observe audition process from any place in your application using \b PNObservationCenter:
 @code
 [[PNObservationCenter defaultCenter] addAccessRightsAuditObserver:self withBlock:^(PNAccessRightsCollection *collection, PNError *error) {

     if (error == nil) {

         // PubNub client successfully pulled out access rights information for specified object (object defined by set
         // of parameters used for \a 'audit' request.
     }
     else {

         // PubNub client did fail to pull out access rights information for specified object (object defined by set
         // of parameters used for \a 'audit' request.
         //
         // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
         // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
         // 'error.associatedObject' contains PNAccessRightOptions instance which describes access level for which audition has been requested.
     }
 }];

 Also observation can be done using \b NSNotificationCenter to observe this notifications: kPNClientAccessRightsAuditDidCompleteNotification,
 kPNClientAccessRightsAuditDidFailNotification.

 @note Make sure that you enabled "Access Manager" on https://admin.pubnub.com.

 @warning As soon as "Access Manager" will be enabled, all \b PubNub clients won't be able to subscribe / publish to
 any channels till the moment, when access rights will be configured.

 @see \b PNError class

 @see \b PNAccessRightOptions class

 @see \b PNChannel class

 @see \b PNAccessRightsCollection class

 @see \b PNObservationCenter class

 @see \a +auditAccessRightsForApplicationWithCompletionHandlingBlock:

 @see \a +grantReadAccessRightsForApplicationAtPeriod:
 */
+ (void)auditAccessRightsForApplication;

/**
 Audit access rights for \a 'application' level.

 @code
 @endcode
 This method extends \a +auditAccessRightsForApplication: and allow to specify audition process handler block.

 @code
 @endcode
 \b Example:

 @code
 [PubNub setConfiguration:[PNConfiguration defaultConfiguration] andDelegate:self];
 [PubNub connect];
 [PubNub grantReadAccessRightsForApplicationAtPeriod:10];
 [PubNub auditAccessRightsForApplicationWithCompletionHandlingBlock:^(PNAccessRightsCollection *collection, PNError *error) {

     if (error == nil) {

         // PubNub client successfully pulled out access rights information for specified object (object defined by set
         // of parameters used for \a 'audit' request.
     }
     else {

         // PubNub client did fail to pull out access rights information for specified object (object defined by set
         // of parameters used for \a 'audit' request.
         //
         // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
         // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
         // 'error.associatedObject' contains PNAccessRightOptions instance which describes access level for which audition has been requested.
     }
 }];
 @endcode

 And handle it with delegates:
 @code
 - (void)pubnubClient:(PubNub *)client didAuditAccessRights:(PNAccessRightsCollection *)accessRightsCollection {

     // PubNub client successfully pulled out access rights information for specified object (object defined by set
     // of parameters used for \a 'audit' request.
 }

 - (void)pubnubClient:(PubNub *)client accessRightsAuditDidFailWithError:(PNError *)error {

     // PubNub client did fail to pull out access rights information for specified object (object defined by set
     // of parameters used for \a 'audit' request.
     //
     // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
     // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
     // 'error.associatedObject' contains PNAccessRightOptions instance which describes access level for which audition has been requested.
 }
 @endcode

 There is also way to observe audition process from any place in your application using \b PNObservationCenter:
 @code
 [[PNObservationCenter defaultCenter] addAccessRightsAuditObserver:self withBlock:^(PNAccessRightsCollection *collection, PNError *error) {

     if (error == nil) {

         // PubNub client successfully pulled out access rights information for specified object (object defined by set
         // of parameters used for \a 'audit' request.
     }
     else {

         // PubNub client did fail to pull out access rights information for specified object (object defined by set
         // of parameters used for \a 'audit' request.
         //
         // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
         // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
         // 'error.associatedObject' contains PNAccessRightOptions instance which describes access level for which audition has been requested.
     }
 }];

 Also observation can be done using \b NSNotificationCenter to observe this notifications: kPNClientAccessRightsAuditDidCompleteNotification,
 kPNClientAccessRightsAuditDidFailNotification.

 @param handlerBlock
 The block which will be called by \b PubNub client when one of success or error events will be received. The block
 takes two arguments:
 \c collection - \b PNAccessRightsCollection instance which hold set of \b PNAccessRightsInformation instances to
 describe \a 'user' access rights for specific \c channel; \c error - error which describes what exactly went wrong
 during access rights audition. Always check \a error.code to find out what caused error (check PNErrorCodes header file and use
 \a -localizedDescription / \a -localizedFailureReason and \a -localizedRecoverySuggestion to get human readable description for error).

 @note Make sure that you enabled "Access Manager" on https://admin.pubnub.com.

 @warning As soon as "Access Manager" will be enabled, all \b PubNub clients won't be able to subscribe / publish to
 any channels till the moment, when access rights will be configured.

 @see \b PNError class

 @see \b PNAccessRightOptions class

 @see \b PNChannel class

 @see \b PNAccessRightsCollection class

 @see \b PNAccessRightsInformation class

 @see \b PNObservationCenter class

 @see \a +auditAccessRightsForApplication:

 @see \a +grantReadAccessRightsForApplicationAtPeriod:
 */
+ (void)auditAccessRightsForApplicationWithCompletionHandlingBlock:(PNClientChannelAccessRightsAuditBlock)handlerBlock;

/**
 Audit access rights for \a 'channel' level. \a 'channel' level is mid-layer of access rights tree, which will also
 provide information about it's child levels: \a 'user' level.

 @code
 @endcode
 \b Example:

 @code
 [PubNub setConfiguration:[PNConfiguration defaultConfiguration] andDelegate:self];
 [PubNub connect];
 [PubNub grantAllAccessRightsForChannel:[PNChannel channelWithName:@"iosdev"] forPeriod:10];
 [PubNub auditAccessRightsForChannel:[PNChannel channelWithName:@"iosdev"]];
 @endcode

 And handle it with delegates:
 @code
 - (void)pubnubClient:(PubNub *)client didAuditAccessRights:(PNAccessRightsCollection *)accessRightsCollection {

     // PubNub client successfully pulled out access rights information for specified object (object defined by set
     // of parameters used for \a 'audit' request.
 }

 - (void)pubnubClient:(PubNub *)client accessRightsAuditDidFailWithError:(PNError *)error {

     // PubNub client did fail to pull out access rights information for specified object (object defined by set
     // of parameters used for \a 'audit' request.
     //
     // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
     // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
     // 'error.associatedObject' contains PNAccessRightOptions instance which describes access level for which audition has been requested.
 }
 @endcode

 There is also way to observe audition process from any place in your application using \b PNObservationCenter:
 @code
 [[PNObservationCenter defaultCenter] addAccessRightsAuditObserver:self withBlock:^(PNAccessRightsCollection *collection, PNError *error) {

     if (error == nil) {

         // PubNub client successfully pulled out access rights information for specified object (object defined by set
         // of parameters used for \a 'audit' request.
     }
     else {

         // PubNub client did fail to pull out access rights information for specified object (object defined by set
         // of parameters used for \a 'audit' request.
         //
         // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
         // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
         // 'error.associatedObject' contains PNAccessRightOptions instance which describes access level for which audition has been requested.
     }
 }];

 Also observation can be done using \b NSNotificationCenter to observe this notifications: kPNClientAccessRightsAuditDidCompleteNotification,
 kPNClientAccessRightsAuditDidFailNotification.

 @param channel
 \b PNChannel instance for which \b PubNub client check rights.

 @note Event if you never configured access rights for \c channel it's value will be calculated and returned in
 response.

 @note Make sure that you enabled "Access Manager" on https://admin.pubnub.com.

 @warning As soon as "Access Manager" will be enabled, all \b PubNub clients won't be able to subscribe / publish to
 any channels till the moment, when access rights will be configured.

 @see \b PNError class

 @see \b PNAccessRightOptions class

 @see \b PNChannel class

 @see \b PNAccessRightsCollection class

 @see \b PNObservationCenter class

 @see \a +auditAccessRightsForChannel:withCompletionHandlingBlock:

 @see \a +grantAllAccessRightsForChannel:forPeriod:
 */
+ (void)auditAccessRightsForChannel:(PNChannel *)channel;

/**
 Audit access rights for \a 'channel' level.

 @code
 @endcode
 This method extends \a +auditAccessRightsForChannel: and allow to specify audition process handler block.

 @code
 @endcode
 \b Example:

 @code
 [PubNub setConfiguration:[PNConfiguration defaultConfiguration] andDelegate:self];
 [PubNub connect];
 [PubNub grantAllAccessRightsForChannel:[PNChannel channelWithName:@"iosdev"] forPeriod:10];
 [PubNub auditAccessRightsForChannel:[PNChannel channelWithName:@"iosdev"]
         withCompletionHandlingBlock:^(PNAccessRightsCollection *collection, PNError *error) {

     if (error == nil) {

         // PubNub client successfully pulled out access rights information for specified object (object defined by set
         // of parameters used for \a 'audit' request.
     }
     else {

         // PubNub client did fail to pull out access rights information for specified object (object defined by set
         // of parameters used for \a 'audit' request.
         //
         // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
         // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
         // 'error.associatedObject' contains PNAccessRightOptions instance which describes access level for which audition has been requested.
     }
 }];
 @endcode

 And handle it with delegates:
 @code
 - (void)pubnubClient:(PubNub *)client didAuditAccessRights:(PNAccessRightsCollection *)accessRightsCollection {

     // PubNub client successfully pulled out access rights information for specified object (object defined by set
     // of parameters used for \a 'audit' request.
 }

 - (void)pubnubClient:(PubNub *)client accessRightsAuditDidFailWithError:(PNError *)error {

     // PubNub client did fail to pull out access rights information for specified object (object defined by set
     // of parameters used for \a 'audit' request.
     //
     // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
     // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
     // 'error.associatedObject' contains PNAccessRightOptions instance which describes access level for which audition has been requested.
 }
 @endcode

 There is also way to observe audition process from any place in your application using \b PNObservationCenter:
 @code
 [[PNObservationCenter defaultCenter] addAccessRightsAuditObserver:self withBlock:^(PNAccessRightsCollection *collection, PNError *error) {

     if (error == nil) {

         // PubNub client successfully pulled out access rights information for specified object (object defined by set
         // of parameters used for \a 'audit' request.
     }
     else {

         // PubNub client did fail to pull out access rights information for specified object (object defined by set
         // of parameters used for \a 'audit' request.
         //
         // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
         // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
         // 'error.associatedObject' contains PNAccessRightOptions instance which describes access level for which audition has been requested.
     }
 }];

 Also observation can be done using \b NSNotificationCenter to observe this notifications: kPNClientAccessRightsAuditDidCompleteNotification,
 kPNClientAccessRightsAuditDidFailNotification.

 @param channel
 \b PNChannel instance for which \b PubNub client check rights.

 @param handlerBlock
 The block which will be called by \b PubNub client when one of success or error events will be received. The block
 takes two arguments:
 \c collection - \b PNAccessRightsCollection instance which hold set of \b PNAccessRightsInformation instances to
 describe \a 'user' access rights for specific \c channel; \c error - error which describes what exactly went wrong
 during access rights audition. Always check \a error.code to find out what caused error (check PNErrorCodes header file and use
 \a -localizedDescription / \a -localizedFailureReason and \a -localizedRecoverySuggestion to get human readable description for error).

 @note Event if you never configured access rights for \c channel it's value will be calculated and returned in
 response.

 @note Make sure that you enabled "Access Manager" on https://admin.pubnub.com.

 @warning As soon as "Access Manager" will be enabled, all \b PubNub clients won't be able to subscribe / publish to
 any channels till the moment, when access rights will be configured.

 @see \b PNError class

 @see \b PNAccessRightOptions class

 @see \b PNChannel class

 @see \b PNAccessRightsCollection class

 @see \b PNAccessRightsInformation class

 @see \b PNObservationCenter class

 @see \a +auditAccessRightsForChannel:

 @see \a +grantAllAccessRightsForChannel:forPeriod:
 */
+ (void)auditAccessRightsForChannel:(PNChannel *)channel withCompletionHandlingBlock:(PNClientChannelAccessRightsAuditBlock)handlerBlock;

/**
 Audit access rights for \a 'user' level.

 @code
 @endcode
 \b Example:

 @code
 [PubNub setConfiguration:[PNConfiguration defaultConfiguration] andDelegate:self];
 [PubNub connect];
 [PubNub grantAllAccessRightsForChannel:[PNChannel channelWithName:@"iosdev"] forPeriod:10 client:@"admin"];
 [PubNub auditAccessRightsForChannel:[PNChannel channelWithName:@"iosdev"] client:@"admin"];
 @endcode

 And handle it with delegates:
 @code
 - (void)pubnubClient:(PubNub *)client didAuditAccessRights:(PNAccessRightsCollection *)accessRightsCollection {

     // PubNub client successfully pulled out access rights information for specified object (object defined by set
     // of parameters used for \a 'audit' request.
 }

 - (void)pubnubClient:(PubNub *)client accessRightsAuditDidFailWithError:(PNError *)error {

     // PubNub client did fail to pull out access rights information for specified object (object defined by set
     // of parameters used for \a 'audit' request.
     //
     // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
     // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
     // 'error.associatedObject' contains PNAccessRightOptions instance which describes access level for which audition has been requested.
 }
 @endcode

 There is also way to observe audition process from any place in your application using \b PNObservationCenter:
 @code
 [[PNObservationCenter defaultCenter] addAccessRightsAuditObserver:self withBlock:^(PNAccessRightsCollection *collection, PNError *error) {

     if (error == nil) {

         // PubNub client successfully pulled out access rights information for specified object (object defined by set
         // of parameters used for \a 'audit' request.
     }
     else {

         // PubNub client did fail to pull out access rights information for specified object (object defined by set
         // of parameters used for \a 'audit' request.
         //
         // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
         // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
         // 'error.associatedObject' contains PNAccessRightOptions instance which describes access level for which audition has been requested.
     }
 }];

 Also observation can be done using \b NSNotificationCenter to observe this notifications: kPNClientAccessRightsAuditDidCompleteNotification,
 kPNClientAccessRightsAuditDidFailNotification.

 @param channel
 \b PNChannel instance for which \b PubNub client check rights for specific client authorization key.

 @param clientAuthorizationKey
 \a NSString instances of client authorization key.

 @note Event if you never configured access rights for \c channel or \c clientAuthorizationKey
 it's value will be calculated and returned in response.

 @note Make sure that you enabled "Access Manager" on https://admin.pubnub.com.

 @warning As soon as "Access Manager" will be enabled, all \b PubNub clients won't be able to subscribe / publish to
 any channels till the moment, when access rights will be configured.

 @see \b PNError class

 @see \b PNAccessRightOptions class

 @see \b PNChannel class

 @see \b PNAccessRightsCollection class

 @see \b PNObservationCenter class

 @see \a +auditAccessRightsForChannel:client:withCompletionHandlingBlock:

 @see \a +grantAllAccessRightsForChannel:forPeriod:client:
 */
+ (void)auditAccessRightsForChannel:(PNChannel *)channel client:(NSString *)clientAuthorizationKey;

/**
 Audit access rights for \a 'user' level.

 @code
 @endcode
 This method extends \a +auditAccessRightsForChannel:client: and allow to specify audition process handler block.

 @code
 @endcode
 \b Example:

 @code
 [PubNub setConfiguration:[PNConfiguration defaultConfiguration] andDelegate:self];
 [PubNub connect];
 [PubNub grantAllAccessRightsForChannel:[PNChannel channelWithName:@"iosdev"] forPeriod:10 client:@"admin"];
 [PubNub auditAccessRightsForChannel:[PNChannel channelWithName:@"iosdev"] client:@"admin"
         withCompletionHandlingBlock:^(PNAccessRightsCollection *collection, PNError *error) {

     if (error == nil) {

         // PubNub client successfully pulled out access rights information for specified object (object defined by set
         // of parameters used for \a 'audit' request.
     }
     else {

         // PubNub client did fail to pull out access rights information for specified object (object defined by set
         // of parameters used for \a 'audit' request.
         //
         // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
         // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
         // 'error.associatedObject' contains PNAccessRightOptions instance which describes access level for which audition has been requested.
     }
 }];
 @endcode

 And handle it with delegates:
 @code
 - (void)pubnubClient:(PubNub *)client didAuditAccessRights:(PNAccessRightsCollection *)accessRightsCollection {

     // PubNub client successfully pulled out access rights information for specified object (object defined by set
     // of parameters used for \a 'audit' request.
 }

 - (void)pubnubClient:(PubNub *)client accessRightsAuditDidFailWithError:(PNError *)error {

     // PubNub client did fail to pull out access rights information for specified object (object defined by set
     // of parameters used for \a 'audit' request.
     //
     // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
     // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
     // 'error.associatedObject' contains PNAccessRightOptions instance which describes access level for which audition has been requested.
 }
 @endcode

 There is also way to observe audition process from any place in your application using \b PNObservationCenter:
 @code
 [[PNObservationCenter defaultCenter] addAccessRightsAuditObserver:self withBlock:^(PNAccessRightsCollection *collection, PNError *error) {

     if (error == nil) {

         // PubNub client successfully pulled out access rights information for specified object (object defined by set
         // of parameters used for \a 'audit' request.
     }
     else {

         // PubNub client did fail to pull out access rights information for specified object (object defined by set
         // of parameters used for \a 'audit' request.
         //
         // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
         // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
         // 'error.associatedObject' contains PNAccessRightOptions instance which describes access level for which audition has been requested.
     }
 }];

 Also observation can be done using \b NSNotificationCenter to observe this notifications: kPNClientAccessRightsAuditDidCompleteNotification,
 kPNClientAccessRightsAuditDidFailNotification.

 @param channel
 \b PNChannel instance for which \b PubNub client check rights for specific client authorization key.

 @param clientAuthorizationKey
 \a NSString instances of client authorization key.

 @param handlerBlock
 The block which will be called by \b PubNub client when one of success or error events will be received. The block
 takes two arguments:
 \c collection - \b PNAccessRightsCollection instance which hold set of \b PNAccessRightsInformation instances to
 describe \a 'user' access rights for specific \c channel; \c error - error which describes what exactly went wrong
 during access rights audition. Always check \a error.code to find out what caused error (check PNErrorCodes header file and use
 \a -localizedDescription / \a -localizedFailureReason and \a -localizedRecoverySuggestion to get human readable description for error).

 @note Event if you never configured access rights for \c channel or \c clientAuthorizationKey
 it's value will be calculated and returned in response.

 @note Make sure that you enabled "Access Manager" on https://admin.pubnub.com.

 @warning As soon as "Access Manager" will be enabled, all \b PubNub clients won't be able to subscribe / publish to
 any channels till the moment, when access rights will be configured.

 @see \b PNError class

 @see \b PNAccessRightOptions class

 @see \b PNChannel class

 @see \b PNAccessRightsCollection class

 @see \b PNAccessRightsInformation class

 @see \b PNObservationCenter class

 @see \a +auditAccessRightsForChannel:client:

 @see \a +grantAllAccessRightsForChannel:forPeriod:client:
 */
+ (void)auditAccessRightsForChannel:(PNChannel *)channel client:(NSString *)clientAuthorizationKey
        withCompletionHandlingBlock:(PNClientChannelAccessRightsAuditBlock)handlerBlock;

/**
 Audit access rights for \a 'channel' level. \a 'channel' level is mid-layer of access rights tree,
 which will also provide information about it's child levels: \a 'user' level. This method allot to retrieve access
 rights information for set of \b PNChannel instances.

 @code
 @endcode
 \b Example:

 @code
 [PubNub setConfiguration:[PNConfiguration defaultConfiguration] andDelegate:self];
 [PubNub connect];
 [PubNub grantWriteAccessRightsForChannels:[PNChannel channelsWithNames:@[@"iosdev", @"macosdev"]] forPeriod:10];
 [PubNub auditAccessRightsForChannels:[PNChannel channelsWithNames:@[@"iosdev", @"macosdev", @"androiddev"]]];
 @endcode

 And handle it with delegates:
 @code
 - (void)pubnubClient:(PubNub *)client didAuditAccessRights:(PNAccessRightsCollection *)accessRightsCollection {

     // PubNub client successfully pulled out access rights information for specified object (object defined by set
     // of parameters used for \a 'audit' request.
 }

 - (void)pubnubClient:(PubNub *)client accessRightsAuditDidFailWithError:(PNError *)error {

     // PubNub client did fail to pull out access rights information for specified object (object defined by set
     // of parameters used for \a 'audit' request.
     //
     // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
     // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
     // 'error.associatedObject' contains PNAccessRightOptions instance which describes access level for which audition has been requested.
 }
 @endcode

 There is also way to observe audition process from any place in your application using \b PNObservationCenter:
 @code
 [[PNObservationCenter defaultCenter] addAccessRightsAuditObserver:self withBlock:^(PNAccessRightsCollection *collection, PNError *error) {

     if (error == nil) {

         // PubNub client successfully pulled out access rights information for specified object (object defined by set
         // of parameters used for \a 'audit' request.
     }
     else {

         // PubNub client did fail to pull out access rights information for specified object (object defined by set
         // of parameters used for \a 'audit' request.
         //
         // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
         // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
         // 'error.associatedObject' contains PNAccessRightOptions instance which describes access level for which audition has been requested.
     }
 }];

 Also observation can be done using \b NSNotificationCenter to observe this notifications: kPNClientAccessRightsAuditDidCompleteNotification,
 kPNClientAccessRightsAuditDidFailNotification.

 @param channels
 List of \b PNChannel instances for which \b PubNub client should retrieve access rights information.

 @note Event if you never configured access rights for \c channel it's value will be calculated and returned in response.

 @note Make sure that you enabled "Access Manager" on https://admin.pubnub.com.

 @warning As soon as "Access Manager" will be enabled, all \b PubNub clients won't be able to subscribe / publish to
 any channels till the moment, when access rights will be configured.

 @see \b PNError class

 @see \b PNAccessRightOptions class

 @see \b PNChannel class

 @see \b PNAccessRightsCollection class

 @see \b PNObservationCenter class

 @see \a +auditAccessRightsForChannels:withCompletionHandlingBlock:

 @see \a +grantWriteAccessRightsForChannels:forPeriod:
 */
+ (void)auditAccessRightsForChannels:(NSArray *)channels;

/**
 Audit access rights for \a 'channel' level.

 @code
 @endcode
 This method extends \a +auditAccessRightsForChannels: and allow to specify audition process handler block.

 @code
 @endcode
 \b Example:

 @code
 [PubNub setConfiguration:[PNConfiguration defaultConfiguration] andDelegate:self];
 [PubNub connect];
 [PubNub grantWriteAccessRightsForChannels:[PNChannel channelsWithNames:@[@"iosdev", @"macosdev"]] forPeriod:10];
 [PubNub auditAccessRightsForChannels:[PNChannel channelsWithNames:@[@"iosdev", @"macosdev", @"androiddev"]]
          withCompletionHandlingBlock:^(PNAccessRightsCollection *collection, PNError *error) {

     if (error == nil) {

         // PubNub client successfully pulled out access rights information for specified object (object defined by set
         // of parameters used for \a 'audit' request.
     }
     else {

         // PubNub client did fail to pull out access rights information for specified object (object defined by set
         // of parameters used for \a 'audit' request.
         //
         // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
         // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
         // 'error.associatedObject' contains PNAccessRightOptions instance which describes access level for which audition has been requested.
     }
 }];
 @endcode

 And handle it with delegates:
 @code
 - (void)pubnubClient:(PubNub *)client didAuditAccessRights:(PNAccessRightsCollection *)accessRightsCollection {

     // PubNub client successfully pulled out access rights information for specified object (object defined by set
     // of parameters used for \a 'audit' request.
 }

 - (void)pubnubClient:(PubNub *)client accessRightsAuditDidFailWithError:(PNError *)error {

     // PubNub client did fail to pull out access rights information for specified object (object defined by set
     // of parameters used for \a 'audit' request.
     //
     // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
     // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
     // 'error.associatedObject' contains PNAccessRightOptions instance which describes access level for which audition has been requested.
 }
 @endcode

 There is also way to observe audition process from any place in your application using \b PNObservationCenter:
 @code
 [[PNObservationCenter defaultCenter] addAccessRightsAuditObserver:self withBlock:^(PNAccessRightsCollection *collection, PNError *error) {

     if (error == nil) {

         // PubNub client successfully pulled out access rights information for specified object (object defined by set
         // of parameters used for \a 'audit' request.
     }
     else {

         // PubNub client did fail to pull out access rights information for specified object (object defined by set
         // of parameters used for \a 'audit' request.
         //
         // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
         // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
         // 'error.associatedObject' contains PNAccessRightOptions instance which describes access level for which audition has been requested.
     }
 }];

 Also observation can be done using \b NSNotificationCenter to observe this notifications: kPNClientAccessRightsAuditDidCompleteNotification,
 kPNClientAccessRightsAuditDidFailNotification.

 @param channels
 List of \b PNChannel instances for which \b PubNub client should retrieve access rights information.

 @param handlerBlock
 The block which will be called by \b PubNub client when one of success or error events will be received. The block
 takes two arguments:
 \c collection - \b PNAccessRightsCollection instance which hold set of \b PNAccessRightsInformation instances to
 describe \a 'user' access rights for specific \c channel; \c error - error which describes what exactly went wrong
 during access rights audition. Always check \a error.code to find out what caused error (check PNErrorCodes header file and use
 \a -localizedDescription / \a -localizedFailureReason and \a -localizedRecoverySuggestion to get human readable description for error).

 @note Event if you never configured access rights for \c channel or one of clients from \c clientsAuthorizationKeys
 it's value will be calculated and returned in response.

 @note Make sure that you enabled "Access Manager" on https://admin.pubnub.com.

 @warning As soon as "Access Manager" will be enabled, all \b PubNub clients won't be able to subscribe / publish to
 any channels till the moment, when access rights will be configured.

 @see \b PNError class

 @see \b PNAccessRightOptions class

 @see \b PNChannel class

 @see \b PNAccessRightsCollection class

 @see \b PNAccessRightsInformation class

 @see \b PNObservationCenter class

 @see \a +auditAccessRightsForChannels:

 @see \a +grantWriteAccessRightsForChannels:forPeriod:
 */
+ (void)auditAccessRightsForChannels:(NSArray *)channels withCompletionHandlingBlock:(PNClientChannelAccessRightsAuditBlock)handlerBlock;

/**
 Audit access rights for \a 'user' level. This method allow to audit access rights to specific \a channel set of
 clients (authorization keys).

 @code
 @endcode
 \b Example:

 @code
 [PubNub setConfiguration:[PNConfiguration defaultConfiguration] andDelegate:self];
 [PubNub connect];
 [PubNub grantReadAccessRightForChannel:[PNChannel channelWithName:@"iosdev"] forPeriod:10 clients:@[@"client1", @"client2", @"admin"]];
 [PubNub auditAccessRightsForChannel:[PNChannel channelWithName:@"iosdev"] clients:@[@"client1", @"client2", @"admin", @"spectator]];
 @endcode

 And handle it with delegates:
 @code
 - (void)pubnubClient:(PubNub *)client didAuditAccessRights:(PNAccessRightsCollection *)accessRightsCollection {

     // PubNub client successfully pulled out access rights information for specified object (object defined by set
     // of parameters used for \a 'audit' request.
 }

 - (void)pubnubClient:(PubNub *)client accessRightsAuditDidFailWithError:(PNError *)error {

     // PubNub client did fail to pull out access rights information for specified object (object defined by set
     // of parameters used for \a 'audit' request.
     //
     // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
     // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
     // 'error.associatedObject' contains PNAccessRightOptions instance which describes access level for which audition has been requested.
 }
 @endcode

 There is also way to observe audition process from any place in your application using \b PNObservationCenter:
 @code
 [[PNObservationCenter defaultCenter] addAccessRightsAuditObserver:self withBlock:^(PNAccessRightsCollection *collection, PNError *error) {

     if (error == nil) {

         // PubNub client successfully pulled out access rights information for specified object (object defined by set
         // of parameters used for \a 'audit' request.
     }
     else {

         // PubNub client did fail to pull out access rights information for specified object (object defined by set
         // of parameters used for \a 'audit' request.
         //
         // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
         // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
         // 'error.associatedObject' contains PNAccessRightOptions instance which describes access level for which audition has been requested.
     }
 }];

 Also observation can be done using \b NSNotificationCenter to observe this notifications: kPNClientAccessRightsAuditDidCompleteNotification,
 kPNClientAccessRightsAuditDidFailNotification.

 @param channel
 \b PNChannel instance for which \b PubNub client check rights for specified set of clients (authorization keys).

 @param clientsAuthorizationKeys
 Array of \a NSString instances each of which represent client authorization key.

 @note Event if you never configured access rights for \c channel or one of clients from \c clientsAuthorizationKeys
 it's value will be calculated and returned in response.

 @note Make sure that you enabled "Access Manager" on https://admin.pubnub.com.

 @warning As soon as "Access Manager" will be enabled, all \b PubNub clients won't be able to subscribe / publish to
 any channels till the moment, when access rights will be configured.

 @see \b PNError class

 @see \b PNAccessRightOptions class

 @see \b PNChannel class

 @see \b PNAccessRightsCollection class

 @see \b PNObservationCenter class

 @see \a +auditAccessRightsForChannel:clients:withCompletionHandlingBlock:

 @see \a +grantReadAccessRightForChannel:forPeriod:clients:
 */
+ (void)auditAccessRightsForChannel:(PNChannel *)channel clients:(NSArray *)clientsAuthorizationKeys;

/**
 Audit access rights for \a 'user' level.

 @code
 @endcode
 This method extends \a +auditAccessRightsForChannel:clients: and allow to specify audition process handler block.

 @code
 @endcode
 \b Example:

 @code
 [PubNub setConfiguration:[PNConfiguration defaultConfiguration] andDelegate:self];
 [PubNub connect];
 [PubNub grantReadAccessRightForChannel:[PNChannel channelWithName:@"iosdev"] forPeriod:10 clients:@[@"client1", @"client2", @"admin"]];
 [PubNub auditAccessRightsForChannel:[PNChannel channelWithName:@"iosdev"] clients:@[@"client1", @"client2", @"admin", @"spectator]
         withCompletionHandlingBlock:^(PNAccessRightsCollection *collection, PNError *error) {

     if (error == nil) {

         // PubNub client successfully pulled out access rights information for specified object (object defined by set
         // of parameters used for \a 'audit' request.
     }
     else {

         // PubNub client did fail to pull out access rights information for specified object (object defined by set
         // of parameters used for \a 'audit' request.
         //
         // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
         // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
         // 'error.associatedObject' contains PNAccessRightOptions instance which describes access level for which audition has been requested.
     }
 }];
 @endcode

 And handle it with delegates:
 @code
 - (void)pubnubClient:(PubNub *)client didAuditAccessRights:(PNAccessRightsCollection *)accessRightsCollection {

     // PubNub client successfully pulled out access rights information for specified object (object defined by set
     // of parameters used for \a 'audit' request.
 }

 - (void)pubnubClient:(PubNub *)client accessRightsAuditDidFailWithError:(PNError *)error {

     // PubNub client did fail to pull out access rights information for specified object (object defined by set
     // of parameters used for \a 'audit' request.
     //
     // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
     // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
     // 'error.associatedObject' contains PNAccessRightOptions instance which describes access level for which audition has been requested.
 }
 @endcode

 There is also way to observe audition process from any place in your application using \b PNObservationCenter:
 @code
 [[PNObservationCenter defaultCenter] addAccessRightsAuditObserver:self withBlock:^(PNAccessRightsCollection *collection, PNError *error) {

     if (error == nil) {

         // PubNub client successfully pulled out access rights information for specified object (object defined by set
         // of parameters used for \a 'audit' request.
     }
     else {

         // PubNub client did fail to pull out access rights information for specified object (object defined by set
         // of parameters used for \a 'audit' request.
         //
         // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
         // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
         // 'error.associatedObject' contains PNAccessRightOptions instance which describes access level for which audition has been requested.
     }
 }];

 Also observation can be done using \b NSNotificationCenter to observe this notifications: kPNClientAccessRightsAuditDidCompleteNotification,
 kPNClientAccessRightsAuditDidFailNotification.

 @param channel
 \b PNChannel instance for which \b PubNub client check rights for specified set of clients (authorization keys).

 @param clientsAuthorizationKeys
 Array of \a NSString instances each of which represent client authorization key.

 @param handlerBlock
 The block which will be called by \b PubNub client when one of success or error events will be received. The block
 takes two arguments:
 \c collection - \b PNAccessRightsCollection instance which hold set of \b PNAccessRightsInformation instances to
 describe \a 'user' access rights for specific \c channel; \c error - error which describes what exactly went wrong
 during access rights audition. Always check \a error.code to find out what caused error (check PNErrorCodes header file and use
 \a -localizedDescription / \a -localizedFailureReason and \a -localizedRecoverySuggestion to get human readable description for error).

 @note Event if you never configured access rights for \c channel or one of clients from \c clientsAuthorizationKeys
 it's value will be calculated and returned in response.

 @note Make sure that you enabled "Access Manager" on https://admin.pubnub.com.

 @warning As soon as "Access Manager" will be enabled, all \b PubNub clients won't be able to subscribe / publish to
 any channels till the moment, when access rights will be configured.

 @see \b PNError class

 @see \b PNAccessRightOptions class

 @see \b PNChannel class

 @see \b PNAccessRightsCollection class

 @see \b PNAccessRightsInformation class

 @see \b PNObservationCenter class

 @see \a +auditAccessRightsForChannel:clients:

 @see \a +grantReadAccessRightForChannel:forPeriod:clients:
 */
+ (void)auditAccessRightsForChannel:(PNChannel *)channel clients:(NSArray *)clientsAuthorizationKeys
        withCompletionHandlingBlock:(PNClientChannelAccessRightsAuditBlock)handlerBlock;


#pragma mark - Presence management

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
 - (void)pubnubClient:(PubNub *)client didEnablePresenceObservationOnChannels:(NSArray *)channels {
 
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
 This method extendeds \a +subscribeOnChannel: and allow to specify presence enabling process state change handler block.
 
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
 - (void)pubnubClient:(PubNub *)client didEnablePresenceObservationOnChannels:(NSArray *)channels {
 
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
 - (void)pubnubClient:(PubNub *)client didEnablePresenceObservationOnChannels:(NSArray *)channels {
 
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
 This method extendeds \a +subscribeOnChannels: and allow to specify presence enabling process state change handler block.
 
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
 - (void)pubnubClient:(PubNub *)client didEnablePresenceObservationOnChannels:(NSArray *)channels {
 
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
 - (void)pubnubClient:(PubNub *)client didDisablePresenceObservationOnChannels:(NSArray *)channels {
 
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
 - (void)pubnubClient:(PubNub *)client didDisablePresenceObservationOnChannels:(NSArray *)channels {
 
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
 - (void)pubnubClient:(PubNub *)client didDisablePresenceObservationOnChannels:(NSArray *)channels {
 
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
 - (void)pubnubClient:(PubNub *)client didDisablePresenceObservationOnChannels:(NSArray *)channels {
 
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


#pragma mark - Time token

/**
 Request time token from \b PubNub service. Service will respond with unixtimestamp (UTC+0).
 
 @code
 @endcode
 \b Example:
 
 @code
 [PubNub setConfiguration:[PNConfiguration defaultConfiguration] andDelegate:self];
 [PubNub connect];
 [PubNub requestServerTimeToken];
 @endcode
 
 And handle it with delegates:
 @code
 - (void)pubnubClient:(PubNub *)client didReceiveTimeToken:(NSNumber *)timeToken {
 
     // PubNub client successfully received time token.
 }
 
 - (void)pubnubClient:(PubNub *)client timeTokenReceiveDidFailWithError:(PNError *)error {
 
     // PubNub client did fail to receive time token.
 }
 @endcode
 
 There is also way to observe connection state from any place in your application using  \b PNObservationCenter:
 @code
 [[PNObservationCenter defaultCenter] addTimeTokenReceivingObserver:self withCallbackBlock:^(NSNumber *timeToken, PNError *error) {
 
     if (error == nil) {
 
         // PubNub client successfully received time token.
     }
     else {
 
         // PubNub client did fail to receive time token.
     }
 }];
 @endcode
 
 @see +requestServerTimeTokenWithCompletionBlock:
 */
+ (void)requestServerTimeToken;

/**
 Request time token from \b PubNub service. Service will respond with unixtimestamp (UTC+0).
 
 @code
 @endcode
 This method extendeds \a +requestServerTimeToken and allow to specify subscription process state change handler block.
 
 @code
 @endcode
 \b Example:
 
 @code
 [PubNub setConfiguration:[PNConfiguration defaultConfiguration] andDelegate:self];
 [PubNub connect];
 [PubNub requestServerTimeTokenWithCompletionBlock:^(NSNumber *timeToken, PNError *error) {
 
     if (error == nil) {
 
         // PubNub client successfully received time token.
     }
     else {
 
         // PubNub client did fail to receive time token.
     }
 }];
 @endcode
 
 And handle it with delegates:
 @code
 - (void)pubnubClient:(PubNub *)client didReceiveTimeToken:(NSNumber *)timeToken {
 
     // PubNub client successfully received time token.
 }
 
 - (void)pubnubClient:(PubNub *)client timeTokenReceiveDidFailWithError:(PNError *)error {
 
     // PubNub client did fail to receive time token.
 }
 @endcode
 
 There is also way to observe connection state from any place in your application using  \b PNObservationCenter:
 @code
 [[PNObservationCenter defaultCenter] addTimeTokenReceivingObserver:self withCallbackBlock:^(NSNumber *timeToken, PNError *error) {
 
     if (error == nil) {
 
         // PubNub client successfully received time token.
     }
     else {
 
         // PubNub client did fail to receive time token.
     }
 }];
 @endcode
 
 @see +requestServerTimeToken
 */
+ (void)requestServerTimeTokenWithCompletionBlock:(PNClientTimeTokenReceivingCompleteBlock)success;


#pragma mark - Messages processing methods

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
 
 There is also way to observe connection state from any place in your application using  \b PNObservationCenter:
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
 \c NSDictionary .
 
 @return \b PNMessage instance if message payload is correct or \c nil if not.
 */
+ (PNMessage *)sendMessage:(id)message toChannel:(PNChannel *)channel;

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
 
 There is also way to observe connection state from any place in your application using  \b PNObservationCenter:
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
 \c NSDictionary .
 
 @return \b PNMessage instance if message payload is correct or \c nil if not.
 */
+ (PNMessage *)sendMessage:(id)message toChannel:(PNChannel *)channel compressed:(BOOL)shouldCompressMessage;

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
 
 There is also way to observe connection state from any place in your application using  \b PNObservationCenter:
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
 \c NSDictionary .
 
 @return \b PNMessage instance if message payload is correct or \c nil if not.
 */
+ (PNMessage *)sendMessage:(id)message toChannel:(PNChannel *)channel compressed:(BOOL)shouldCompressMessage
       withCompletionBlock:(PNClientMessageProcessingBlock)success;

/**
 Asynchronously send configured message object to PubNub service.
 */
+ (void)sendMessage:(PNMessage *)message;

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
 
 There is also way to observe connection state from any place in your application using  \b PNObservationCenter:
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
 \c NSDictionary .
 */
+ (void)sendMessage:(PNMessage *)message compressed:(BOOL)shouldCompressMessage;

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
 
 There is also way to observe connection state from any place in your application using  \b PNObservationCenter:
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
 \c NSDictionary .
 */
+ (void)sendMessage:(PNMessage *)message compressed:(BOOL)shouldCompressMessage withCompletionBlock:(PNClientMessageProcessingBlock)success;


#pragma mark - History methods

/**
 Fetch all messages from history for specified channel.
 
 @param channel
 \b PNChannel instance for which \b PubNub client should fetch messages history.
 */
+ (void)requestFullHistoryForChannel:(PNChannel *)channel;

/**
 Fetch all messages from history for specified channel.
 
 @code
 @endcode
 This method extends \a +requestFullHistoryForChannel: and allow to specify history request handling block.
 
 @param channel
 \b PNChannel instance for which \b PubNub client should fetch messages history.
 
 @param handlerBlock
 The block which will be called by \b PubNub client as soon as history request will be completed. The block takes five arguments:
 \c messages - array of \b PNMessage instances which represent messages sent to the specified \c channel;
 \c channel - \b PNChannel instance for which history request has been made; \c startDate - \b PNDate instance which represent date
 of the first message from returned list of messages; \c endDate - \b PNDate instance which represent date of the last message
 from returned list of messages; \c error - describes what exactly went wrong (check error code and compare it with \b PNErrorCodes).
 
 @warning Only last call of this method will call completion block. If you need to track history request process, 
 use \b PNObservationCenter methods for this purpose.
 */
+ (void)requestFullHistoryForChannel:(PNChannel *)channel withCompletionBlock:(PNClientHistoryLoadHandlingBlock)handleBlock;

/**
 Fetch all messages from history for specified channel.
 
 @code
 @endcode
 This method extends \a +requestFullHistoryForChannel: and allow to specify whether message time token should be included
 or not.
 
 @param channel
 \b PNChannel instance for which \b PubNub client should fetch messages history.
 
 @param shouldIncludeTimeToken
 Whether message post date (time token) should be added to the message in history response.
 */
+ (void)requestFullHistoryForChannel:(PNChannel *)channel includingTimeToken:(BOOL)shouldIncludeTimeToken;

/**
 Fetch all messages from history for specified channel.
 
 @code
 @endcode
 This method extends \a +requestFullHistoryForChannel:includingTimeToken: and allow to specify history request handling block.
 
 @param channel
 \b PNChannel instance for which \b PubNub client should fetch messages history.
 
 @param shouldIncludeTimeToken
 Whether message post date (time token) should be added to the message in history response.
 
 @param handlerBlock
 The block which will be called by \b PubNub client as soon as history request will be completed. The block takes five arguments:
 \c messages - array of \b PNMessage instances which represent messages sent to the specified \c channel; 
 \c channel - \b PNChannel instance for which history request has been made; \c startDate - \b PNDate instance which represent date
 of the first message from returned list of messages; \c endDate - \b PNDate instance which represent date of the last message
 from returned list of messages; \c error - describes what exactly went wrong (check error code and compare it with \b PNErrorCodes).
 
 @warning Only last call of this method will call completion block. If you need to track history request process,
 use \b PNObservationCenter methods for this purpose.
 */
+ (void)requestFullHistoryForChannel:(PNChannel *)channel includingTimeToken:(BOOL)shouldIncludeTimeToken
                 withCompletionBlock:(PNClientHistoryLoadHandlingBlock)handleBlock;

/**
 Fetch messages from history for specified channel starting from specified date and till current time.
 
 @param channel
 \b PNChannel instance for which \b PubNub client should fetch messages history.
 
 @param startDate
 \b PNDate instance which represent time token starting from which messages should be returned from history.
 */
+ (void)requestHistoryForChannel:(PNChannel *)channel from:(PNDate *)startDate;

/**
 Fetch messages from history for specified channel starting from specified date and till current time.
 
 @code
 @endcode
 This method extends \a +requestHistoryForChannel:from: and allow to specify history request handling block.
 
 @param channel
 \b PNChannel instance for which \b PubNub client should fetch messages history.
 
 @param startDate
 \b PNDate instance which represent time token starting from which messages should be returned from history.
 
 @param handlerBlock
 The block which will be called by \b PubNub client as soon as history request will be completed. The block takes five arguments:
 \c messages - array of \b PNMessage instances which represent messages sent to the specified \c channel;
 \c channel - \b PNChannel instance for which history request has been made; \c startDate - \b PNDate instance which represent date
 of the first message from returned list of messages; \c endDate - \b PNDate instance which represent date of the last message
 from returned list of messages; \c error - describes what exactly went wrong (check error code and compare it with \b PNErrorCodes).
 
 @warning Only last call of this method will call completion block. If you need to track history request process,
 use \b PNObservationCenter methods for this purpose.
 */
+ (void)requestHistoryForChannel:(PNChannel *)channel from:(PNDate *)startDate
             withCompletionBlock:(PNClientHistoryLoadHandlingBlock)handleBlock;

/**
 Fetch messages from history for specified channel starting from specified date and till current time.
 
 @code
 @endcode
 This method extends \a +requestHistoryForChannel:from: and allow to specify whether message time token should be included
 or not.
 
 @param channel
 \b PNChannel instance for which \b PubNub client should fetch messages history.
 
 @param startDate
 \b PNDate instance which represent time token starting from which messages should be returned from history.
 
 @param shouldIncludeTimeToken
 Whether message post date (time token) should be added to the message in history response.
 */
+ (void)requestHistoryForChannel:(PNChannel *)channel from:(PNDate *)startDate includingTimeToken:(BOOL)shouldIncludeTimeToken;

/**
 Fetch messages from history for specified channel starting from specified date and till current time.
 
 @code
 @endcode
 This method extends \a +requestHistoryForChannel:from:includingTimeToken: and allow to specify history request handling block.
 
 @param channel
 \b PNChannel instance for which \b PubNub client should fetch messages history.
 
 @param startDate
 \b PNDate instance which represent time token starting from which messages should be returned from history.
 
 @param shouldIncludeTimeToken
 Whether message post date (time token) should be added to the message in history response.
 
 @param handlerBlock
 The block which will be called by \b PubNub client as soon as history request will be completed. The block takes five arguments:
 \c messages - array of \b PNMessage instances which represent messages sent to the specified \c channel;
 \c channel - \b PNChannel instance for which history request has been made; \c startDate - \b PNDate instance which represent date
 of the first message from returned list of messages; \c endDate - \b PNDate instance which represent date of the last message
 from returned list of messages; \c error - describes what exactly went wrong (check error code and compare it with \b PNErrorCodes).
 
 @warning Only last call of this method will call completion block. If you need to track history request process,
 use \b PNObservationCenter methods for this purpose.
 */
+ (void)requestHistoryForChannel:(PNChannel *)channel from:(PNDate *)startDate includingTimeToken:(BOOL)shouldIncludeTimeToken
             withCompletionBlock:(PNClientHistoryLoadHandlingBlock)handleBlock;

/**
 Fetch messages from history for specified channel in defined time frame.
 
 @code
 @endcode
 This method extends \a +requestHistoryForChannel:from: and allow to specify end time token for history request.
 
 @param channel
 \b PNChannel instance for which \b PubNub client should fetch messages history.
 
 @param startDate
 \b PNDate instance which represent time token starting from which messages should be returned from history.
 
 @param endDate
 \b PNDate instance which represent time token which is used to specify concrete time frame from which messages should be 
 returned.
 */
+ (void)requestHistoryForChannel:(PNChannel *)channel from:(PNDate *)startDate to:(PNDate *)endDate;

/**
 Fetch messages from history for specified channel in defined time frame.
 
 @code
 @endcode
 This method extends \a +requestHistoryForChannel:from:to: and allow to specify history request handling block.
 
 @param channel
 \b PNChannel instance for which \b PubNub client should fetch messages history.
 
 @param startDate
 \b PNDate instance which represent time token starting from which messages should be returned from history.
 
 @param endDate
 \b PNDate instance which represent time token which is used to specify concrete time frame from which messages should be
 returned.
 
 @param handlerBlock
 The block which will be called by \b PubNub client as soon as history request will be completed. The block takes five arguments:
 \c messages - array of \b PNMessage instances which represent messages sent to the specified \c channel;
 \c channel - \b PNChannel instance for which history request has been made; \c startDate - \b PNDate instance which represent date
 of the first message from returned list of messages; \c endDate - \b PNDate instance which represent date of the last message
 from returned list of messages; \c error - describes what exactly went wrong (check error code and compare it with \b PNErrorCodes).
 
 @warning Only last call of this method will call completion block. If you need to track history request process,
 use \b PNObservationCenter methods for this purpose.
 */
+ (void)requestHistoryForChannel:(PNChannel *)channel from:(PNDate *)startDate to:(PNDate *)endDate
             withCompletionBlock:(PNClientHistoryLoadHandlingBlock)handleBlock;

/**
 Fetch messages from history for specified channel in defined time frame.
 
 @code
 @endcode
 This method extends \a +requestHistoryForChannel:from:to: and allow to specify whether message time token should be included
 or not.
 
 @param channel
 \b PNChannel instance for which \b PubNub client should fetch messages history.
 
 @param startDate
 \b PNDate instance which represent time token starting from which messages should be returned from history.
 
 @param endDate
 \b PNDate instance which represent time token which is used to specify concrete time frame from which messages should be
 returned.
 
 @param shouldIncludeTimeToken
 Whether message post date (time token) should be added to the message in history response.
 */
+ (void)requestHistoryForChannel:(PNChannel *)channel from:(PNDate *)startDate to:(PNDate *)endDate
              includingTimeToken:(BOOL)shouldIncludeTimeToken;

/**
 Fetch messages from history for specified channel in defined time frame.
 
 @code
 @endcode
 This method extends \a +requestHistoryForChannel:from:to:includingTimeToken: and allow to specify history request handling block.
 
 @param channel
 \b PNChannel instance for which \b PubNub client should fetch messages history.
 
 @param startDate
 \b PNDate instance which represent time token starting from which messages should be returned from history.
 
 @param endDate
 \b PNDate instance which represent time token which is used to specify concrete time frame from which messages should be
 returned.
 
 @param shouldIncludeTimeToken
 Whether message post date (time token) should be added to the message in history response.
 
 @param handlerBlock
 The block which will be called by \b PubNub client as soon as history request will be completed. The block takes five arguments:
 \c messages - array of \b PNMessage instances which represent messages sent to the specified \c channel;
 \c channel - \b PNChannel instance for which history request has been made; \c startDate - \b PNDate instance which represent date
 of the first message from returned list of messages; \c endDate - \b PNDate instance which represent date of the last message
 from returned list of messages; \c error - describes what exactly went wrong (check error code and compare it with \b PNErrorCodes).
 
 @warning Only last call of this method will call completion block. If you need to track history request process,
 use \b PNObservationCenter methods for this purpose.
 */
+ (void)requestHistoryForChannel:(PNChannel *)channel from:(PNDate *)startDate to:(PNDate *)endDate
              includingTimeToken:(BOOL)shouldIncludeTimeToken withCompletionBlock:(PNClientHistoryLoadHandlingBlock)handleBlock;

/**
 Fetch messages from history for specified channel starting from specified date and till current time.
 
 @code
 @endcode
 This method extends \a +requestHistoryForChannel:from: and allow to specify maximum number of messages which should be
 returned for history request.
 
 @param channel
 \b PNChannel instance for which \b PubNub client should fetch messages history.
 
 @param startDate
 \b PNDate instance which represent time token starting from which messages should be returned from history.
 
 @param limit
 Maximum number of messages which should be pulled out from history.
 */
+ (void)requestHistoryForChannel:(PNChannel *)channel from:(PNDate *)startDate limit:(NSUInteger)limit;

/**
 Fetch messages from history for specified channel starting from specified date and till current time.
 
 @code
 @endcode
 This method extends \a +requestHistoryForChannel:from:limit: and allow to specify history request handling block.
 
 @param channel
 \b PNChannel instance for which \b PubNub client should fetch messages history.
 
 @param startDate
 \b PNDate instance which represent time token starting from which messages should be returned from history.
 
 @param limit
 Maximum number of messages which should be pulled out from history.
 
 @param handlerBlock
 The block which will be called by \b PubNub client as soon as history request will be completed. The block takes five arguments:
 \c messages - array of \b PNMessage instances which represent messages sent to the specified \c channel;
 \c channel - \b PNChannel instance for which history request has been made; \c startDate - \b PNDate instance which represent date
 of the first message from returned list of messages; \c endDate - \b PNDate instance which represent date of the last message
 from returned list of messages; \c error - describes what exactly went wrong (check error code and compare it with \b PNErrorCodes).
 
 @warning Only last call of this method will call completion block. If you need to track history request process,
 use \b PNObservationCenter methods for this purpose.
 */
+ (void)requestHistoryForChannel:(PNChannel *)channel from:(PNDate *)startDate limit:(NSUInteger)limit
             withCompletionBlock:(PNClientHistoryLoadHandlingBlock)handleBlock;

/**
 Fetch messages from history for specified channel starting from specified date and till current time.
 
 @code
 @endcode
 This method extends \a +requestHistoryForChannel:from:limit: and allow to specify whether message time token should be
 included or not.
 
 @param channel
 \b PNChannel instance for which \b PubNub client should fetch messages history.
 
 @param startDate
 \b PNDate instance which represent time token starting from which messages should be returned from history.
 
 @param limit
 Maximum number of messages which should be pulled out from history.
 
 @param shouldIncludeTimeToken
 Whether message post date (time token) should be added to the message in history response.
 */
+ (void)requestHistoryForChannel:(PNChannel *)channel from:(PNDate *)startDate limit:(NSUInteger)limit
              includingTimeToken:(BOOL)shouldIncludeTimeToken;

/**
 Fetch messages from history for specified channel starting from specified date and till current time.
 
 @code
 @endcode
 This method extends \a +requestHistoryForChannel:from:limit:includingTimeToken: and allow to specify history request 
 handling block.
 
 @param channel
 \b PNChannel instance for which \b PubNub client should fetch messages history.
 
 @param startDate
 \b PNDate instance which represent time token starting from which messages should be returned from history.
 
 @param limit
 Maximum number of messages which should be pulled out from history.
 
 @param shouldIncludeTimeToken
 Whether message post date (time token) should be added to the message in history response.
 
 @param handlerBlock
 The block which will be called by \b PubNub client as soon as history request will be completed. The block takes five arguments:
 \c messages - array of \b PNMessage instances which represent messages sent to the specified \c channel;
 \c channel - \b PNChannel instance for which history request has been made; \c startDate - \b PNDate instance which represent date
 of the first message from returned list of messages; \c endDate - \b PNDate instance which represent date of the last message
 from returned list of messages; \c error - describes what exactly went wrong (check error code and compare it with \b PNErrorCodes).
 
 @warning Only last call of this method will call completion block. If you need to track history request process,
 use \b PNObservationCenter methods for this purpose.
 */
+ (void)requestHistoryForChannel:(PNChannel *)channel from:(PNDate *)startDate limit:(NSUInteger)limit
              includingTimeToken:(BOOL)shouldIncludeTimeToken withCompletionBlock:(PNClientHistoryLoadHandlingBlock)handleBlock;

/**
 Fetch messages from history for specified channel in defined time frame.
 
 @code
 @endcode
 This method extends \a +requestHistoryForChannel:from:to: and allow to specify maximum number of messages which should be
 returned for history request.
 
 @param channel
 \b PNChannel instance for which \b PubNub client should fetch messages history.
 
 @param startDate
 \b PNDate instance which represent time token starting from which messages should be returned from history.
 
 @param endDate
 \b PNDate instance which represent time token which is used to specify concrete time frame from which messages should be
 returned.
 
 @param limit
 Maximum number of messages which should be pulled out from history.
 */
+ (void)requestHistoryForChannel:(PNChannel *)channel from:(PNDate *)startDate to:(PNDate *)endDate limit:(NSUInteger)limit;

/**
 Fetch messages from history for specified channel in defined time frame.
 
 @code
 @endcode
 This method extends \a +requestHistoryForChannel:from:to:limit: and allow to specify history request handling block.
 
 @param channel
 \b PNChannel instance for which \b PubNub client should fetch messages history.
 
 @param startDate
 \b PNDate instance which represent time token starting from which messages should be returned from history.
 
 @param endDate
 \b PNDate instance which represent time token which is used to specify concrete time frame from which messages should be
 returned.
 
 @param limit
 Maximum number of messages which should be pulled out from history.
 
 @param handlerBlock
 The block which will be called by \b PubNub client as soon as history request will be completed. The block takes five arguments:
 \c messages - array of \b PNMessage instances which represent messages sent to the specified \c channel;
 \c channel - \b PNChannel instance for which history request has been made; \c startDate - \b PNDate instance which represent date
 of the first message from returned list of messages; \c endDate - \b PNDate instance which represent date of the last message
 from returned list of messages; \c error - describes what exactly went wrong (check error code and compare it with \b PNErrorCodes).
 
 @warning Only last call of this method will call completion block. If you need to track history request process,
 use \b PNObservationCenter methods for this purpose.
 */
+ (void)requestHistoryForChannel:(PNChannel *)channel from:(PNDate *)startDate to:(PNDate *)endDate limit:(NSUInteger)limit
             withCompletionBlock:(PNClientHistoryLoadHandlingBlock)handleBlock;

/**
 Fetch messages from history for specified channel in defined time frame.
 
 @code
 @endcode
 This method extends \a +requestHistoryForChannel:from:to:limit: and allow to specify whether message time token should be
 included or not.
 
 @param channel
 \b PNChannel instance for which \b PubNub client should fetch messages history.
 
 @param startDate
 \b PNDate instance which represent time token starting from which messages should be returned from history.
 
 @param endDate
 \b PNDate instance which represent time token which is used to specify concrete time frame from which messages should be
 returned.
 
 @param limit
 Maximum number of messages which should be pulled out from history.
 
 @param shouldIncludeTimeToken
 Whether message post date (time token) should be added to the message in history response.
 */
+ (void)requestHistoryForChannel:(PNChannel *)channel from:(PNDate *)startDate to:(PNDate *)endDate limit:(NSUInteger)limit
              includingTimeToken:(BOOL)shouldIncludeTimeToken;

/**
 Fetch messages from history for specified channel in defined time frame.
 
 @code
 @endcode
 This method extends \a +requestHistoryForChannel:from:to:limit:includingTimeToken: and allow to specify history request
 handling block.
 
 @param channel
 \b PNChannel instance for which \b PubNub client should fetch messages history.
 
 @param startDate
 \b PNDate instance which represent time token starting from which messages should be returned from history.
 
 @param endDate
 \b PNDate instance which represent time token which is used to specify concrete time frame from which messages should be
 returned.
 
 @param limit
 Maximum number of messages which should be pulled out from history.
 
 @param shouldIncludeTimeToken
 Whether message post date (time token) should be added to the message in history response.
 
 @param handlerBlock
 The block which will be called by \b PubNub client as soon as history request will be completed. The block takes five arguments:
 \c messages - array of \b PNMessage instances which represent messages sent to the specified \c channel;
 \c channel - \b PNChannel instance for which history request has been made; \c startDate - \b PNDate instance which represent date
 of the first message from returned list of messages; \c endDate - \b PNDate instance which represent date of the last message
 from returned list of messages; \c error - describes what exactly went wrong (check error code and compare it with \b PNErrorCodes).
 
 @warning Only last call of this method will call completion block. If you need to track history request process,
 use \b PNObservationCenter methods for this purpose.
 */
+ (void)requestHistoryForChannel:(PNChannel *)channel from:(PNDate *)startDate to:(PNDate *)endDate limit:(NSUInteger)limit
              includingTimeToken:(BOOL)shouldIncludeTimeToken withCompletionBlock:(PNClientHistoryLoadHandlingBlock)handleBlock;

/**
 Fetch messages from history for specified channel starting from specified date and till current time.
 
 @code
 @endcode
 This method extends \a +requestHistoryForChannel:from:limit: and allow to specify whether messages order in history response
 should be inverted or not.
 
 @param channel
 \b PNChannel instance for which \b PubNub client should fetch messages history.
 
 @param startDate
 \b PNDate instance which represent time token starting from which messages should be returned from history.
 
 @param limit
 Maximum number of messages which should be pulled out from history.
 
 @param shouldReverseMessageHistory
 If set to \c YES all older messages will come first in response. Default value is \b NO.
 */
+ (void)requestHistoryForChannel:(PNChannel *)channel from:(PNDate *)startDate limit:(NSUInteger)limit
                  reverseHistory:(BOOL)shouldReverseMessageHistory;

/**
 Fetch messages from history for specified channel starting from specified date and till current time.
 
 @code
 @endcode
 This method extends \a +requestHistoryForChannel:from:limit:reverseHistory: and allow to specify history request handling block.
 
 @param channel
 \b PNChannel instance for which \b PubNub client should fetch messages history.
 
 @param startDate
 \b PNDate instance which represent time token starting from which messages should be returned from history.
 
 @param limit
 Maximum number of messages which should be pulled out from history.
 
 @param shouldReverseMessageHistory
 If set to \c YES all older messages will come first in response. Default value is \b NO.
 
 @param handlerBlock
 The block which will be called by \b PubNub client as soon as history request will be completed. The block takes five arguments:
 \c messages - array of \b PNMessage instances which represent messages sent to the specified \c channel;
 \c channel - \b PNChannel instance for which history request has been made; \c startDate - \b PNDate instance which represent date
 of the first message from returned list of messages; \c endDate - \b PNDate instance which represent date of the last message
 from returned list of messages; \c error - describes what exactly went wrong (check error code and compare it with \b PNErrorCodes).
 
 @warning Only last call of this method will call completion block. If you need to track history request process,
 use \b PNObservationCenter methods for this purpose.
 */
+ (void)requestHistoryForChannel:(PNChannel *)channel from:(PNDate *)startDate limit:(NSUInteger)limit
                  reverseHistory:(BOOL)shouldReverseMessageHistory withCompletionBlock:(PNClientHistoryLoadHandlingBlock)handleBlock;

/**
 Fetch messages from history for specified channel starting from specified date and till current time.
 
 @code
 @endcode
 This method extends \a +requestHistoryForChannel:from:limit:reverseHistory: and allow to specify whether message 
 time token should be included or not.
 
 @param channel
 \b PNChannel instance for which \b PubNub client should fetch messages history.
 
 @param startDate
 \b PNDate instance which represent time token starting from which messages should be returned from history.
 
 @param limit
 Maximum number of messages which should be pulled out from history.
 
 @param shouldReverseMessageHistory
 If set to \c YES all older messages will come first in response. Default value is \b NO.
 
 @param shouldIncludeTimeToken
 Whether message post date (time token) should be added to the message in history response.
 */
+ (void)requestHistoryForChannel:(PNChannel *)channel from:(PNDate *)startDate limit:(NSUInteger)limit
                  reverseHistory:(BOOL)shouldReverseMessageHistory includingTimeToken:(BOOL)shouldIncludeTimeToken;

/**
 Fetch messages from history for specified channel starting from specified date and till current time.
 
 @code
 @endcode
 This method extends \a +requestHistoryForChannel:from:limit:reverseHistory:includingTimeToken: and allow to specify 
 history request handling block.
 
 @param channel
 \b PNChannel instance for which \b PubNub client should fetch messages history.
 
 @param startDate
 \b PNDate instance which represent time token starting from which messages should be returned from history.
 
 @param limit
 Maximum number of messages which should be pulled out from history.
 
 @param shouldReverseMessageHistory
 If set to \c YES all older messages will come first in response. Default value is \b NO.
 
 @param shouldIncludeTimeToken
 Whether message post date (time token) should be added to the message in history response.
 
 @param handlerBlock
 The block which will be called by \b PubNub client as soon as history request will be completed. The block takes five arguments:
 \c messages - array of \b PNMessage instances which represent messages sent to the specified \c channel;
 \c channel - \b PNChannel instance for which history request has been made; \c startDate - \b PNDate instance which represent date
 of the first message from returned list of messages; \c endDate - \b PNDate instance which represent date of the last message
 from returned list of messages; \c error - describes what exactly went wrong (check error code and compare it with \b PNErrorCodes).
 
 @warning Only last call of this method will call completion block. If you need to track history request process,
 use \b PNObservationCenter methods for this purpose.
 */
+ (void)requestHistoryForChannel:(PNChannel *)channel from:(PNDate *)startDate limit:(NSUInteger)limit
                  reverseHistory:(BOOL)shouldReverseMessageHistory includingTimeToken:(BOOL)shouldIncludeTimeToken
             withCompletionBlock:(PNClientHistoryLoadHandlingBlock)handleBlock;

/**
 Fetch messages from history for specified channel in defined time frame.
 
 @code
 @endcode
 This method extends \a +requestHistoryForChannel:from:to:limit: and allow to specify whether messages order in history response
 should be inverted or not.
 
 @param channel
 \b PNChannel instance for which \b PubNub client should fetch messages history.
 
 @param startDate
 \b PNDate instance which represent time token starting from which messages should be returned from history.
 
 @param endDate
 \b PNDate instance which represent time token which is used to specify concrete time frame from which messages should be
 returned.
 
 @param limit
 Maximum number of messages which should be pulled out from history.
 
 @param shouldReverseMessageHistory
 If set to \c YES all older messages will come first in response. Default value is \b NO.
 */
+ (void)requestHistoryForChannel:(PNChannel *)channel from:(PNDate *)startDate to:(PNDate *)endDate limit:(NSUInteger)limit
                  reverseHistory:(BOOL)shouldReverseMessageHistory;

/**
 Fetch messages from history for specified channel in defined time frame.
 
 @code
 @endcode
 This method extends \a +requestHistoryForChannel:from:to:limit:reverseHistory: and allow to specify history request handling block.
 
 @param channel
 \b PNChannel instance for which \b PubNub client should fetch messages history.
 
 @param startDate
 \b PNDate instance which represent time token starting from which messages should be returned from history.
 
 @param endDate
 \b PNDate instance which represent time token which is used to specify concrete time frame from which messages should be
 returned.
 
 @param limit
 Maximum number of messages which should be pulled out from history.
 
 @param shouldReverseMessageHistory
 If set to \c YES all older messages will come first in response. Default value is \b NO.
 
 @param handlerBlock
 The block which will be called by \b PubNub client as soon as history request will be completed. The block takes five arguments:
 \c messages - array of \b PNMessage instances which represent messages sent to the specified \c channel;
 \c channel - \b PNChannel instance for which history request has been made; \c startDate - \b PNDate instance which represent date
 of the first message from returned list of messages; \c endDate - \b PNDate instance which represent date of the last message
 from returned list of messages; \c error - describes what exactly went wrong (check error code and compare it with \b PNErrorCodes).
 
 @warning Only last call of this method will call completion block. If you need to track history request process,
 use \b PNObservationCenter methods for this purpose.
 */
+ (void)requestHistoryForChannel:(PNChannel *)channel from:(PNDate *)startDate to:(PNDate *)endDate limit:(NSUInteger)limit
                  reverseHistory:(BOOL)shouldReverseMessageHistory withCompletionBlock:(PNClientHistoryLoadHandlingBlock)handleBlock;

/**
 Fetch messages from history for specified channel in defined time frame.
 
 @code
 @endcode
 This method extends \a +requestHistoryForChannel:from:ot:limit:reverseHistory: and allow to specify whether message
 time token should be included or not.
 
 @param channel
 \b PNChannel instance for which \b PubNub client should fetch messages history.
 
 @param startDate
 \b PNDate instance which represent time token starting from which messages should be returned from history.
 
 @param endDate
 \b PNDate instance which represent time token which is used to specify concrete time frame from which messages should be
 returned.
 
 @param limit
 Maximum number of messages which should be pulled out from history.
 
 @param shouldReverseMessageHistory
 If set to \c YES all older messages will come first in response. Default value is \b NO.
 
 @param shouldIncludeTimeToken
 Whether message post date (time token) should be added to the message in history response.
 */
+ (void)requestHistoryForChannel:(PNChannel *)channel from:(PNDate *)startDate to:(PNDate *)endDate limit:(NSUInteger)limit
                  reverseHistory:(BOOL)shouldReverseMessageHistory includingTimeToken:(BOOL)shouldIncludeTimeToken;

/**
 Fetch messages from history for specified channel in defined time frame.
 
 @code
 @endcode
 This method extends \a +requestHistoryForChannel:from:to:limit:reverseHistory:includingTimeToken: and allow to specify
 history request handling block.
 
 @param channel
 \b PNChannel instance for which \b PubNub client should fetch messages history.
 
 @param startDate
 \b PNDate instance which represent time token starting from which messages should be returned from history.
 
 @param endDate
 \b PNDate instance which represent time token which is used to specify concrete time frame from which messages should be
 returned.
 
 @param limit
 Maximum number of messages which should be pulled out from history.
 
 @param shouldReverseMessageHistory
 If set to \c YES all older messages will come first in response. Default value is \b NO.
 
 @param shouldIncludeTimeToken
 Whether message post date (time token) should be added to the message in history response.
 
 @param handlerBlock
 The block which will be called by \b PubNub client as soon as history request will be completed. The block takes five arguments:
 \c messages - array of \b PNMessage instances which represent messages sent to the specified \c channel;
 \c channel - \b PNChannel instance for which history request has been made; \c startDate - \b PNDate instance which represent date
 of the first message from returned list of messages; \c endDate - \b PNDate instance which represent date of the last message
 from returned list of messages; \c error - describes what exactly went wrong (check error code and compare it with \b PNErrorCodes).
 
 @warning Only last call of this method will call completion block. If you need to track history request process,
 use \b PNObservationCenter methods for this purpose.
 */
+ (void)requestHistoryForChannel:(PNChannel *)channel from:(PNDate *)startDate to:(PNDate *)endDate limit:(NSUInteger)limit
                  reverseHistory:(BOOL)shouldReverseMessageHistory includingTimeToken:(BOOL)shouldIncludeTimeToken
             withCompletionBlock:(PNClientHistoryLoadHandlingBlock)handleBlock;


#pragma mark - Participant methods

/**
 Request list of participants for all channels.

 @since 3.6.0
 */
+ (void)requestParticipantsList;

/**
 Request list of participants for all channels.

 @code
 @endcode
 This method extends \a +requestParticipantsList: and allow to specify
 participants retrieval process block.

 @param handleBlock
 The block which will be called by \b PubNub client as soon as participants list request operation will be completed.
 The block takes three arguments:
 \c clients - array of \b PNClient instances which represent client which is subscribed on target channel (if
 \a 'isClientIdentifiersRequired' is set to \c NO than all objects will have \c kPNAnonymousParticipantIdentifier value);
 \c channel - will be empty for this type of request; \c error - describes what
 exactly went wrong (check error code and compare it with \b PNErrorCodes ).

 @note This method by default won't request client's state.

 @warning Only last call of this method will call completion block. If you need to track participants loading events
 from many places, use PNObservationCenter methods for this purpose.

 @since 3.6.0
 */
+ (void)requestParticipantsListWithCompletionBlock:(PNClientParticipantsHandlingBlock)handleBlock;

/**
 Request list of participants for all channels.

 @code
 @endcode
 This method extends \a +requestParticipantsList: and allow to specify whether server should return client
 identifiers or not.

 @param isClientIdentifiersRequired
 Whether or not \b PubNub client should fetch list of client identifiers or only number of them will be returned by
 server.

 @since 3.6.0
 */
+ (void)requestParticipantsListWithClientIdentifiers:(BOOL)isClientIdentifiersRequired;

/**
 Request list of participants for all channels.

 @code
 @endcode
 This method extends \a +requestParticipantsListWithClientIdentifiers: and allow to specify participants retrieval
 process block.

 @param isClientIdentifiersRequired
 Whether or not \b PubNub client should fetch list of client identifiers or only number of them will be returned by
 server.

 @param handleBlock
 The block which will be called by \b PubNub client as soon as participants list request operation will be completed.
 The block takes three arguments:
 \c clients - array of \b PNClient instances which represent client which is subscribed on target channel (if
 \a 'isClientIdentifiersRequired' is set to \c NO than all objects will have \c kPNAnonymousParticipantIdentifier value);
 \c channel - will be empty for this type of request; \c error - describes what
 exactly went wrong (check error code and compare it with \b PNErrorCodes ).

 @note This method by default won't request client's state.

 @warning Only last call of this method will call completion block. If you need to track participants loading events
 from many places, use PNObservationCenter methods for this purpose.

 @since 3.6.0
 */
+ (void)requestParticipantsListWithClientIdentifiers:(BOOL)isClientIdentifiersRequired
                                  andCompletionBlock:(PNClientParticipantsHandlingBlock)handleBlock;

/**
 Request list of participants for all channels.
 
 @code
 @endcode
 This method extends \a +requestParticipantsListWithClientIdentifiers: and allow to specify
 whether server should return state which is set to the client or not.
 
 @param isClientIdentifiersRequired
 Whether or not \b PubNub client should fetch list of client identifiers or only number of them will be returned by
 server.
 
 @param shouldFetchClientState
 Whether or not \b PubNub client should fetch additional information which has been added to the client during
 subscription or specific API endpoints.
 
 @note If \a 'isClientIdentifiersRequired' is set to \c NO then value of \a 'shouldFetchClientState' will be
 ignored and returned result array will contain list of \b PNClient instances with names set to \a 'unknown'.
 
 @since 3.6.0
 */
+ (void)requestParticipantsListWithClientIdentifiers:(BOOL)isClientIdentifiersRequired
                                         clientState:(BOOL)shouldFetchClientState;

/**
 Request list of participants for all channels.

 @code
 @endcode
 This method extends \a +requestParticipantsListWithClientIdentifiers:clientState: and allow to specify
 participants retrieval process block.

 @param isClientIdentifiersRequired
 Whether or not \b PubNub client should fetch list of client identifiers or only number of them will be returned by
 server.

 @param shouldFetchClientState
 Whether or not \b PubNub client should fetch additional information which has been added to the client during
 subscription or specific API endpoints.

 @param handleBlock
 The block which will be called by \b PubNub client as soon as participants list request operation will be completed.
 The block takes three arguments:
 \c clients - array of \b PNClient instances which represent client which is subscribed on target channel (if
 \a 'isClientIdentifiersRequired' is set to \c NO than all objects will have \c kPNAnonymousParticipantIdentifier value);
 \c channel - will be empty for this type of request; \c error - describes what
 exactly went wrong (check error code and compare it with \b PNErrorCodes ).

 @note If \a 'isClientIdentifiersRequired' is set to \c NO then value of \a 'shouldFetchClientState' will be
 ignored and returned result array will contain list of \b PNClient instances with names set to \a 'unknown'.

 @warning Only last call of this method will call completion block. If you need to track participants loading events
 from many places, use PNObservationCenter methods for this purpose.

 @since 3.6.0
 */
+ (void)requestParticipantsListWithClientIdentifiers:(BOOL)isClientIdentifiersRequired
                                         clientState:(BOOL)shouldFetchClientState
                                  andCompletionBlock:(PNClientParticipantsHandlingBlock)handleBlock;

/**
 Request list of participants for specified channel.

 @param channel
 \b PNChannel instance on for which \b PubNub client should retrieve information about participants.

 @note This method by default won't request client's state.
 */
+ (void)requestParticipantsListForChannel:(PNChannel *)channel;

/**
 Request list of participants for specified channel.

 @code
 @endcode
 This method extends \a +requestParticipantsListForChannel: and allow to specify
 participants retrieval process block.

 @param channel
 \b PNChannel instance on for which \b PubNub client should retrieve information about participants.

 @param handleBlock
 The block which will be called by \b PubNub client as soon as participants list request operation will be completed.
 The block takes three arguments:
 \c clients - array of \b PNClient instances which represent client which is subscribed on target channel (if
 \a 'isClientIdentifiersRequired' is set to \c NO than all objects will have \c kPNAnonymousParticipantIdentifier value);
 \c channel - is \b PNChannel instance for which \b PubNub client received participants list; \c error - describes what
 exactly went wrong (check error code and compare it with \b PNErrorCodes ).

 @note This method by default won't request client's state.

 @warning Only last call of this method will call completion block. If you need to track participants loading events
 from many places, use PNObservationCenter methods for this purpose.
 */
+ (void)requestParticipantsListForChannel:(PNChannel *)channel withCompletionBlock:(PNClientParticipantsHandlingBlock)handleBlock;

/**
 Request list of participants for specified channel. Depending on whether \a 'isIdentifiersListRequired' is set to \C
  YES or not, \b PubNub client will receive from server list of client identifiers or just number of subscribers in
  specified channel.

 @param channel
 \b PNChannel instance on for which \b PubNub client should retrieve information about participants.

 @param isClientIdentifiersRequired
 Whether or not \b PubNub client should fetch list of client identifiers or only number of them will be returned by
 server.

 @note This method by default won't request client's state.

 @note If \a 'isClientIdentifiersRequired' is set to \c NO then result array will contain list of \b PNClient
 instances with names set to \a 'unknown'.

 @since 3.6.0
 */
+ (void)requestParticipantsListForChannel:(PNChannel *)channel
                clientIdentifiersRequired:(BOOL)isClientIdentifiersRequired;

/**
 Request list of participants for specified channel. Depending on whether \a 'isIdentifiersListRequired' is set to \C
  YES or not, \b PubNub client will receive from server list of client identifiers or just number of subscribers in
  specified channel.

 @code
 @endcode
 This method extends \a +requestParticipantsListForChannel:clientIdentifiersRequired: and allow to specify
 participants retrieval process block.

 @param channel
 \b PNChannel instance on for which \b PubNub client should retrieve information about participants.

 @param isClientIdentifiersRequired
 Whether or not \b PubNub client should fetch list of client identifiers or only number of them will be returned by
 server.

 @param handleBlock
 The block which will be called by \b PubNub client as soon as participants list request operation will be completed.
 The block takes three arguments:
 \c clients - array of \b PNClient instances which represent client which is subscribed on target channel (if
 \a 'isClientIdentifiersRequired' is set to \c NO than all objects will have \c kPNAnonymousParticipantIdentifier value);
 \c channel - is \b PNChannel instance for which \b PubNub client received participants list; \c error - describes what
 exactly went wrong (check error code and compare it with \b PNErrorCodes ).

 @note This method by default won't request client's state.

 @note If \a 'isClientIdentifiersRequired' is set to \c NO then result array will contain list of \b PNClient
 instances with names set to \a 'unknown'.

 @warning Only last call of this method will call completion block. If you need to track participants loading events
 from many places, use PNObservationCenter methods for this purpose.

 @since 3.6.0
 */
+ (void)requestParticipantsListForChannel:(PNChannel *)channel clientIdentifiersRequired:(BOOL)isClientIdentifiersRequired
                      withCompletionBlock:(PNClientParticipantsHandlingBlock)handleBlock;

/**
 Request list of participants for specified channel. Depending on whether \a 'isIdentifiersListRequired' is set to \C
  YES or not, \b PubNub client will receive from server list of client identifiers or just number of subscribers in
  specified channel.

 @code
 @endcode
 This method extends \a +requestParticipantsListForChannel:clientIdentifiersRequired: and allow to specify
 whether server should return state which is set to the client or not.

 @param channel
 \b PNChannel instance on for which \b PubNub client should retrieve information about participants.

 @param isClientIdentifiersRequired
 Whether or not \b PubNub client should fetch list of client identifiers or only number of them will be returned by
 server.

 @param shouldFetchClientState
 Whether or not \b PubNub client should fetch additional information which has been added to the client during
 subscription or specific API endpoints.

 @note If \a 'isClientIdentifiersRequired' is set to \c NO then value of \a 'shouldFetchClientState' will be
 ignored and returned result array will contain list of \b PNClient instances with names set to \a 'unknown'.

 @since 3.6.0
 */
+ (void)requestParticipantsListForChannel:(PNChannel *)channel clientIdentifiersRequired:(BOOL)isClientIdentifiersRequired
                              clientState:(BOOL)shouldFetchClientState;

/**
 Request list of participants for specified channel. Depending on whether \a 'isIdentifiersListRequired' is set to \C
  YES or not, \b PubNub client will receive from server list of client identifiers or just number of subscribers in
  specified channel.

 @code
 @endcode
 This method extends \a +requestParticipantsListForChannel:clientIdentifiersRequired:clientState: and allow to
 specify participants retrieval process block.

 @param channel
 \b PNChannel instance on for which \b PubNub client should retrieve information about participants.

 @param isClientIdentifiersRequired
 Whether or not \b PubNub client should fetch list of client identifiers or only number of them will be returned by
 server.

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

 @warning Only last call of this method will call completion block. If you need to track participants loading events
 from many places, use PNObservationCenter methods for this purpose.

 @since 3.6.0
 */
+ (void)requestParticipantsListForChannel:(PNChannel *)channel clientIdentifiersRequired:(BOOL)isClientIdentifiersRequired
                              clientState:(BOOL)shouldFetchClientState
                      withCompletionBlock:(PNClientParticipantsHandlingBlock)handleBlock;

/**
 Request list of channels in which current client identifier reside at this moment.

 @param clientIdentifier
 Client identifier for which \b PubNub client should get list of channels in which it reside.

 @since 3.6.0
 */
+ (void)requestParticipantChannelsList:(NSString *)clientIdentifier;

/**
 Request list of channels in which current client identifier reside at this moment.

 @code
 @endcode
 This method extends \a +requestParticipantChannelsList: and allow to specify participant channels retrieval process
 block.

 @param clientIdentifier
 Client identifier for which \b PubNub client should get list of channels in which it reside.

 @param handleBlock
 The block which will be called by \b PubNub client as soon as participant channels list request operation will be
 completed. The block takes three arguments:
 \c clientIdentifier - identifier for which \b PubNub client search for channels;
 \c channels - is list of \b PNChannel instances in which \c clientIdentifier has been found as subscriber; \c error -
 describes what exactly went wrong (check error code and compare it with \b PNErrorCodes ).

 @warning Only last call of this method will call completion block. If you need to track participants loading events
 from many places, use PNObservationCenter methods for this purpose.

 @since 3.6.0
 */
+ (void)requestParticipantChannelsList:(NSString *)clientIdentifier
                   withCompletionBlock:(PNClientParticipantChannelsHandlingBlock)handleBlock;


#pragma mark - Crypto helper methods

/**
 * Cryptographic function which allow to decrypt AES hash stored inside 'base64' string and return object
 */
+ (id)AESDecrypt:(id)object;
+ (id)AESDecrypt:(id)object error:(PNError **)decryptionError;

/**
 * Cryptographic function which allow to encrypt object into 'base64' string using AES and return hash string
 */
+ (NSString *)AESEncrypt:(id)object;
+ (NSString *)AESEncrypt:(id)object error:(PNError **)encryptionError;


#pragma mark - Instance methods

/**
 Check whether PubNub client connected to origin and ready to work or not
 */
- (BOOL)isConnected;

#pragma mark -


@end
