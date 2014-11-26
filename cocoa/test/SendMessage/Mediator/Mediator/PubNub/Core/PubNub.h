#import <Foundation/Foundation.h>
#import "PNStructures.h"
#import "PNDelegate.h"


#pragma mark Class forward

@class PNObservationCenter, PNConfiguration;


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


#pragma mark - Properties

/**
 Stores reference on observation center which has been configured for this \b PubNub client.
 */
@property (nonatomic, readonly, strong) PNObservationCenter *observationCenter;


#pragma mark - Class (singleton) methods

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
 Create and initialize \b PubNub client with pre-configuration. Provided configuration will be used to complete components configuration.
 
 @param configuration
 \b PNConfiguration stores all required parameters to make sure that \b PubNub client will operate as it has been requested.
 
 @return Initialized and ready to use \b PubNub client instance.
 
 @since 3.7.0
 */
+ (PubNub *)clientWithConfiguration:(PNConfiguration *)configuration;

/**
 Create and initialize \b PubNub client with pre-configuration. Provided configuration will be used to complete components configuration.
 
 @param configuration
 \b PNConfiguration stores all required parameters to make sure that \b PubNub client will operate as it has been requested.
 
 @param delegate
 Reference on instance which would like to receive callbacks from \b PubNub client.
 
 @return Initialized and ready to use \b PubNub client instance.
 
 @since 3.7.0
 */
+ (PubNub *)clientWithConfiguration:(PNConfiguration *)configuration andDelegate:(id<PNDelegate>)delegate;

/**
 @brief Create and initialize \b PubNub client instance with pre-defined configuration. Returned instance automatically
 will attempt to establish connection.
 
 @param configuration \b PNConfiguration stores all required parameters to make sure that \b PubNub client will operate
                      as it has been requested.
 
 @return Initialized and ready to use \b PubNub client instance.
 
 @since 3.7.3
 */
+ (PubNub *)connectingClientWithConfiguration:(PNConfiguration *)configuration;

/**
 @brief Create and initialize \b PubNub client instance with pre-defined configuration. Returned instance automatically
 will attempt to establish connection.
 
 @code
 @endcode
 This method extends \a +connectingClientWithConfiguration: and allow to specify connection success and failure 
 handling blocks.
 
 @param configuration \b PNConfiguration stores all required parameters to make sure that \b PubNub client will operate
                      as it has been requested.
 @param success       The block which will be called by \b PubNub client as soon as it will complete handshake and all
                      preparations. The block takes one argument: \c origin - name of the origin to which \b PubNub
                      client connected.
 @param failure       The block which will be called by \b PubNub client in case of any errors which occurred during
                      connection. The block takes one argument: \c connectionError - error which describes what exactly
                      went wrong. Always check \a connectionError.code to find out what caused error (check 
                      PNErrorCodes header file and use \a -localizedDescription / \a -localizedFailureReason and 
                      \a -localizedRecoverySuggestion to get human readable description for error).
 
 @note \c failure block may be called few times in few cases:
       1) connection really failed and it will pass \b PNError instance in block.
       2) at the moment when this method has been called there was no connection or \b PubNub client doesn't have
          enough time to validate its availability.
 
 @return Initialized and ready to use \b PubNub client instance.
 
 @since 3.7.3
 */
+ (PubNub *)connectingClientWithConfiguration:(PNConfiguration *)configuration
                              andSuccessBlock:(PNClientConnectionSuccessBlock)success
                                   errorBlock:(PNClientConnectionFailureBlock)failure;

/**
 @brief Create and initialize \b PubNub client instance with pre-defined configuration. Returned instance automatically
 will attempt to establish connection.
 
 @param configuration \b PNConfiguration stores all required parameters to make sure that \b PubNub client will operate
                      as it has been requested.
 @param delegate      Reference on instance which would like to receive callbacks from \b PubNub client.
 
 @return Initialized and ready to use \b PubNub client instance.
 
 @since 3.7.3
 */
+ (PubNub *)connectingClientWithConfiguration:(PNConfiguration *)configuration andDelegate:(id<PNDelegate>)delegate;

/**
 @brief Create and initialize \b PubNub client instance with pre-defined configuration. Returned instance automatically
 will attempt to establish connection.
 
 @code
 @endcode
 This method extends \a +connectingClientWithConfiguration:andDelegate: and allow to specify connection success and 
 failure handling blocks.
 
 @param configuration \b PNConfiguration stores all required parameters to make sure that \b PubNub client will operate
                      as it has been requested.
 @param delegate      Reference on instance which would like to receive callbacks from \b PubNub client.
  @param success       The block which will be called by \b PubNub client as soon as it will complete handshake and all
                      preparations. The block takes one argument: \c origin - name of the origin to which \b PubNub
                      client connected.
 @param failure       The block which will be called by \b PubNub client in case of any errors which occurred during
                      connection. The block takes one argument: \c connectionError - error which describes what exactly
                      went wrong. Always check \a connectionError.code to find out what caused error (check 
                      PNErrorCodes header file and use \a -localizedDescription / \a -localizedFailureReason and 
                      \a -localizedRecoverySuggestion to get human readable description for error).
 
 @note \c failure block may be called few times in few cases:
       1) connection really failed and it will pass \b PNError instance in block.
       2) at the moment when this method has been called there was no connection or \b PubNub client doesn't have
          enough time to validate its availability.
 
 @return Initialized and ready to use \b PubNub client instance.
 
 @since 3.7.3
 */
+ (PubNub *)connectingClientWithConfiguration:(PNConfiguration *)configuration delegate:(id<PNDelegate>)delegate
                              andSuccessBlock:(PNClientConnectionSuccessBlock)success
                                   errorBlock:(PNClientConnectionFailureBlock)failure;

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
       2) at the moment when this method has been called there was no connection or \b PubNub client doesn't have enough time to validate its availability. In this case \c error will be \c nil

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


#pragma mark - Instance methods

/**
 Initialize \b PubNub client with pre-configuration. Provided configuration will be used to complete components configuration.
 
 @param configuration
 \b PNConfiguration stores all required parameters to make sure that \b PubNub client will operate as it has been requested.
 
 @param delegate
 Reference on instance which would like to receive callbacks from \b PubNub client.
 
 @return Initialized and ready to use \b PubNub client instance.
 */
- (id)initWithConfiguration:(PNConfiguration *)configuration andDelegate:(id<PNDelegate>)delegate;


#pragma mark - Client configuration

/**
 Allow fetch configuration which is currently used by \b PubNub client for operation and communication with \b PubNub services.
 
 @note Because this method will return copy of real object which is used by \b PubNub client any changes on this 
 instance won't take effect. To apply changed from this \b PNConfiguration instance use \a -setConfiguration: method
 (please read special notes for setting configuration while client is connected).
 
 @return PNConfiguration instance copy.
 */
- (PNConfiguration *)configuration;

/**
 Perform initial configuration or update existing one.
 
 @code
 @endcode
 This method will use delegate specified with \a -setDelegate: method.
 
 @code
 @endcode
 \b Example:
 
 @code
 PubNub *pubNub = [PubNub new];
 [pubNub setConfiguration:[PNConfiguration defaultConfiguration]];
 [pubNub connect];
 @endcode
 
 @code
 @endcode
 \b Example with custom configuration:
 
 @code
 [pubNub setConfiguration:[PNConfiguration configurationForOrigin:@"pubsub.pubnub.com" publishKey:@"demo" subscribeKey:@"demo"
                                                        secretKey:nil authorizationKey:@"authKey"]];
 [pubNub connect];

 // In this case PubNub client will reconnect to apply updated configuration.
 [pubNub setConfiguration:[PNConfiguration configurationForOrigin:@"ios.pubnub.com" publishKey:@"demo" subscribeKey:@"demo"
                                                        secretKey:nil authorizationKey:@"authKey"]];
 @endcode
 
 @param configuration
 \b PNConfiguration instance which specify \b PubNub client behaviour and operation routes.

 @note In case \c configuration override \b SSL, \b origin name or \b authorization key, \b PubNub client may decide to reconnect (if client
 were connected before configuration update).

 @note It is strongly advised change configuration in really rare cases and most of the time provide configuration during \b PubNub client configuration.
 Configuration update on connected client will cause additional overhead to reinitialize client with new configuration and connect back to server (time overhead).

 @since 3.7.0
 */
- (void)setConfiguration:(PNConfiguration *)configuration;

/**
 Perform initial configuration or update existing one.
 
 @code
 @endcode
 This method extends \a -setConfiguration: and allow to specify delegate for callbacks.
 
 @code
 @endcode
 \b Example:
 
 @code
 PubNub *pubNub = [PubNub new];
 [pubNub setConfiguration:[PNConfiguration defaultConfiguration] andDelegate:self];
 [pubNub connect];

 // In this case PubNub client will reconnect to apply updated configuration.
 [pubNub setConfiguration:[PNConfiguration configurationForOrigin:@"ios.pubnub.com" publishKey:@"demo" subscribeKey:@"demo"
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

 @since 3.7.0
 */
- (void)setupWithConfiguration:(PNConfiguration *)configuration andDelegate:(id<PNDelegate>)delegate;

/**
 Specify \b PubNub client delegate for event callbacks.
 
 @code
 @endcode
 \b Example:
 
 @code
 PubNub *pubNub = [PubNub new];
 [pubNub setConfiguration:[PNConfiguration defaultConfiguration]];
 [pubNub setDelegate:self];
 [pubNub connect];
 @endcode
 
 @param delegate
 Instance which conforms to \b PNDelegate protocol and will receive events from \b PubNub client via delegate callbacks.
 
 @note There can be only one \b PubNub client delegate at once. If you need to observe for events from different part of application, you should check
 \b PNObservationCenter and subscribe on events in which you are interested.

 @since 3.7.0
 */
- (void)setDelegate:(id<PNDelegate>)delegate;


#pragma mark - Client identification

/**
 Update current \b PubNub client identifier (unique user identifier or basically username/nickname).
 
 @code
 @endcode
 \b Example:
 
 @code
 PubNub *pubNub = [PubNub new];
 [pubNub setConfiguration:[PNConfiguration defaultConfiguration] andDelegate:self];
 [pubNub setClientIdentifier:@"pubnub-user"];
 [pubNub connect];
 @endcode
 
 @param identifier
 \a NSString instance which represent client identifier which will be used to identify concrete client on another
 side of the channel route.
 
 @warning If \b PubNub client was previously connected to the service it will gracefully \a 'leave' channels on which it has been subscribed
 (\a 'leave' presence event will be generated) and subscribe back with new identifier (\a 'join' event will be generated).
 
 @since 3.7.0
 */
- (void)setClientIdentifier:(NSString *)identifier;

/**
 Update current \b PubNub client identifier (unique user identifier or basically username/nickname).
 
 @code
 @endcode
 Extends \a -setClientIdentifier: and allow to specify whether client should restore subscription on channels with 
 last time token or re-subscribe with presence event.
 
 @code
 @endcode
 \b Example:
 
 @code
 PubNub *pubNub = [PubNub new];
 [pubNub setConfiguration:[PNConfiguration defaultConfiguration] andDelegate:self];
 [pubNub setClientIdentifier:@"pubnub-user"];
 [pubNub connect];
 @endcode
 
 @param identifier
 \a NSString instance which represent client identifier which will be used to identify concrete client on another
 side of the channel route.
 
 @param shouldCatchup
 If set o \c YES \b PubNub client will try to restore subscription on channels (if subscribed) from the moment when this method has been called and 
 all messages which has been sent into the channel from that moment will be received.
 
 @warning If \b PubNub client was previously connected to the service it will gracefully \a 'leave' channels on which it has been subscribed
 (\a 'leave' presence event will be generated) and subscribe back with new identifier (\a 'join' event will be generated).

 @since 3.7.0
 */
- (void)setClientIdentifier:(NSString *)identifier shouldCatchup:(BOOL)shouldCatchup;

/**
 Retrieve current \b PubNub client identifier which will/used to establish connection with \b PubNub services.
 
 @code
 @endcode
 \b Example:
 
 @code
 PubNub *pubNub = [PubNub new];
 [pubNub setConfiguration:[PNConfiguration defaultConfiguration] andDelegate:self];
 [pubNub setClientIdentifier:@"pubnub-user"];
 [pubNub connect];
 
 NSLog(@"Client identifier: %@", [pubNub clientIdentifier]); // Client identifier: pubnub-user
 @endcode

 @note If \b PubNub client has been connected before client identifier change, new value will be available only after
 \b PubNub client will reconnect with new identifier.

 @since 3.7.0
 */
- (NSString *)clientIdentifier;


#pragma mark - Client connection management methods

/**
 Check whether PubNub client connected to origin and ready to work or not
 */
- (BOOL)isConnected;

/**
 Connect \b PubNub client to remote servers.
 
 @code
 @endcode
 \b Example:
 
 @code 
 PubNub *pubNub = [PubNub clientWithConfiguration:[PNConfiguration defaultConfiguration] andDelegate:self];
 [pubNub connect];
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
 [pubNub.observationCenter addClientConnectionStateObserver:self
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

 @warning Connection will fail in case if \b PubNub client not configured.

 @since 3.7.0
 */
- (void)connect;

/**
 Connect \b PubNub client to remote servers.
 
 @code
 @endcode
 This method extends \a -connect and allow to specify connection success and failure handling blocks.
 
 @code
 @endcode
 \b Example:
 
 @code 
 PubNub *pubNub = [PubNub clientWithConfiguration:[PNConfiguration defaultConfiguration] andDelegate:self];
 [pubNub connectWithSuccessBlock:^(NSString *origin){
 
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
 [pubNub.observationCenter addClientConnectionStateObserver:self
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

 @since 3.7.0
 */
- (void)connectWithSuccessBlock:(PNClientConnectionSuccessBlock)success errorBlock:(PNClientConnectionFailureBlock)failure;

/**
 Will disconnect from all channels w/o sending \a 'leave' presence event and terminate all socket connection which
 has been established for \b PubNub client. All scheduled messages and requests will be discarded.
 
 @code
 @endcode
 \b Example:
 
 @code
 PubNub *pubNub = [PubNub clientWithConfiguration:[PNConfiguration defaultConfiguration] andDelegate:self];
 [pubNub connect];
 [pubNub subscribeOnChannels:[PNChannel channelsWithNames:@[@"iosdev", @"macdev"]]];
 [pubNub sendMessage:@"PubNub welcomes iOS developers" toChannel:[PNChannel channelWithName:@"iosdev"]];
 [pubNub sendMessage:@"PubNub welcomes Mac OS developers" toChannel:[PNChannel channelWithName:@"iosdev"]];
 [pubNub disconnect];
 @endcode

 And handle it with delegates:
 @code
 - (void)pubnubClient:(PubNub *)client didDisconnectFromOrigin:(NSString *)origin {

     // PubNub client disconnected from specified origin.
 }
 @endcode

 There is also way to observe disconnection state from any place in your application using  \b PNObservationCenter:
 @code
 [pubNub.observationCenter addClientConnectionStateObserver:self
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

 @since 3.7.0
 */
- (void)disconnect;

#pragma mark -


@end
