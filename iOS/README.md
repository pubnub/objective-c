# PubNub 3.4.1 for iOS (iPhone and iPad)
PubNub 3.4.1 for iOS provides iOS ARC support in Objective-C for the [PubNub.com](http://www.pubnub.com/) real-time messaging network.  

All requests made by the client are asynchronous, and are handled by:

1. blocks (via calling method)
2. delegate methods
3. notifications
4. Observation Center

Detailed information on methods, constants, and notifications can be found in the corresponding header files.
## Important Changes from 3.4 to 3.4.1
Better precision for pulling history is provided client-side via the new PNDate types.

If you were previously using history in 3.4, you will need to convert your **NSDate** parameter types to **PNDate** types, as the history methods now
take PNDate arguments, not NSDate arguments. This is as easy as replacing:

```objective-c
NSDate *startDate = [NSDate date];
```
with
```objective-c
PNDate *startDate = [PNDate dateWithDate:[NSDate date]]; // Convert from a date
```
or
```objective-c
PNDate *startDate = [PNDate dateWithToken:[NSNumber numberWithInt:1234567]; // Convert from a timetoken
```
## Adding PubNub to your project  

1. Add the JSONKit support files to your project (/libs/JSONKit)  
2. Add the PubNub library folder to your project (/libs/PubNub)  
3. Add PNImports to your project precompile header (.pch)  

        #import "PNImports.h"
        
4. Set the -fno-objc-arc compile option for JSON.m and JSONKit.m
5. Add the CFNetwork.Framework, SystemConfiguration.Framework, and libz.dylib link options

For a more detailed walkthrough of the above steps, be sure to follow the [Hello World walkthrough doc](https://raw.github.com/pubnub/objective-c/master/iOS/HOWTO/HelloWorld/HelloWorldHOWTO_34.pdf) (more details on that in the next section...)

## Jumping Right In - Try out the Hello World and Reference Apps!

There are three iOS PubNub 3.4 client demo apps available!

### SimpleSubscribe HOWTO

The [SimpleSubscribe](HOWTO/SimpleSubscribe/3.4) app references how to create a simple subscribe-only, non-ui application using PubNub and iOS. 
[A getting started walkthrough document is also available](https://raw.github.com/pubnub/objective-c/master/iOS/HOWTO/SimpleSubscribe/SimpleSubscribeHOWTO_34.pdf).

This is the most basic example of how to wire it all up, and as such, should take beginners and experts alike about 5-10 minutes to complete.

### Hello World HOWTO

The [Hello World](HOWTO/HelloWorld/3.4) app references how to create a simple application using PubNub and iOS. 
[A getting started walkthrough document is also available](https://raw.github.com/pubnub/objective-c/master/iOS/HOWTO/HelloWorld/HelloWorldHOWTO_34.pdf).

### Deluxe iPad Full Featured Demo

Once you are familiar with the [Hello World](HOWTO_3.4) app, The deluxe iPad-only app demonstrates all API functions in greater detail than
the Hello World app. It is intended to be a reference application.

## APNS Setup

If you've enabled your keys for APNS, you can use native PubNub publish operations to send messages to iPhones and iPads via iOS push notifications!
Refer to the [APNS documentation HOWTO](https://github.com/pubnub/objective-c/blob/master/iOS/README_FOR_APNS.md) for more information on PubNub APNS setup.
(A more formal "PubNub APNS Hello World" document is on its way!)

### Beta APNS Video and Client Library ###

We've just added a video walkthrough, along with a sample application (based on the video) that shows from start to
end how to setup APNS with PubNub. It includes all Apple-specific setup (which appears to be the most misunderstood) as
well as the PubNub-specific setup, along with the end product app available in [HOWTO/APNSVideo](HOWTO/APNSVideo).

** NOTE:  The video walkthrough uses beta client API calls which are only available in the APNSVideo/lib/PubNub directory. 
Be sure to use this lib path if you are following this video. It is in final beta, and will be merged to master shortly. **

#### APNS Video HOWTO ####

Watch the following in order:

[1 Creating the App ID and PEM Cert File](https://vimeo.com/67419903)

[2 Create the Provisioning Profile](https://vimeo.com/67420404)

[3 Create and Configure PubNub Account for APNS](https://vimeo.com/67420596)

[4 Create empty PubNub App Template](https://vimeo.com/67420599)

[5 Configure for PNDelegate Protocol and create didReceiveMessage delegate method](https://vimeo.com/67420597)

[6 Set keys, channel, connect, and subscribe and Test Run](https://vimeo.com/67420598)

[7 Enable and Test for correct APNS configuration (Apple Config)](https://vimeo.com/67423576)

[8 Provision PubNub APNS](https://vimeo.com/67423577)

Two files referenced from the video, [generateAPNSPemKey.sh](generateAPNSPemKey.sh) and [verifyCertWithApple.sh](verifyCertWithApple.sh) are also availble 

Final product is available here: [HOWTO/APNSVideo](HOWTO/APNSVideo)

## Client configuration

You can test-drive the PubNub client out-of-the-box without additional configuration changes. As you get a feel for it, you can fine tune it's behaviour by tweaking the available settings.

The client is configured via an instance of the [__PNConfiguration__](3.4/pubnub/libs/PubNub/Data/PNConfiguration.h) class. All default configuration data is stored in [__PNDefaultConfiguration.h__](3.4/pubnub/libs/PubNub/Misc/PNDefaultConfiguration.h) under appropriate keys.  

Data from [__PNDefaultConfiguration.h__](3.4/pubnub/libs/PubNub/Misc/PNDefaultConfiguration.h) override any settings not explicitly set during initialisation.  

You can use few class methods to intialise and update instance properties:  

1. Retrieve reference on default client configuration (all values taken from [__PNDefaultConfiguration.h__](3.4/pubnub/libs/PubNub/Misc/PNDefaultConfiguration.h))  

        + (PNConfiguration *)defaultConfiguration;  
  
2. Retrieve the reference on the configuration instance via these methods:  

        + (PNConfiguration *)configurationWithPublishKey:(NSString *)publishKey  
                                            subscribeKey:(NSString *)subscribeKey  
                                               secretKey:(NSString *)secretKey;  

        + (PNConfiguration *)configurationForOrigin:(NSString *)originHostName  
                                         publishKey:(NSString *)publishKey                                        
                                       subscribeKey:(NSString *)subscribeKey
                                          secretKey:(NSString *)secretKey;		                                 

        + (PNConfiguration *)configurationForOrigin:(NSString *)originHostName  
                                         publishKey:(NSString *)publishKey  
                                       subscribeKey:(NSString *)subscribeKey  
                                          secretKey:(NSString *)secretKey  
                                          cipherKey:(NSString *)cipherKey;  // To initialize with encryption, use cipherKey

***NOTE:  When encryption is enabled, and non-encrypted messages will be passed through as the string "DECRYPTION_ERROR".**

3. Update the configuration instance using this next set of parameters:  

    1.  Timeout after which the library will report any ***non-subscription-related*** request (here now, leave, message history, message post, time token) or execution failure.  
  
            nonSubscriptionRequestTimeout  
        __Default:__ 15 seconds (_kPNNonSubscriptionRequestTimeout_ key in [__PNDefaultConfiguration.h__](3.4/pubnub/libs/PubNub/Misc/PNDefaultConfiguration.h))  
        
    2.  Timeout after which the library will report ***subscription-related*** request (subscribe on channel(s)) execution failure.
        The default configuration value is stored inside [__PNDefaultConfiguration.h__](3.4/pubnub/libs/PubNub/Misc/PNDefaultConfiguration.h) under __kPNSubscriptionRequestTimeout__ key.
      
            subscriptionRequestTimeout  
        __Default:__ 310 seconds (_kPNSubscriptionRequestTimeout_ key in [__PNDefaultConfiguration.h__](3.4/pubnub/libs/PubNub/Misc/PNDefaultConfiguration.h))
        ***Please consult with PubNub support before setting this value lower than the default to avoid incurring additional charges.***
    
    3.  After experiencing network connectivity loss, if network access is restored, should the client reconnect to PubNub, or stay disconnected?
      
            (getter = shouldAutoReconnectClient) autoReconnectClient  
        __Default:__ YES (_kPNShouldResubscribeOnConnectionRestore_ key in [__PNDefaultConfiguration.h__](3.4/pubnub/libs/PubNub/Misc/PNDefaultConfiguration.h))  
    
    4.  If autoReconnectClient == YES, after experiencing network connectivity loss and subsequent reconnect, should the client resume (aka  "catchup") to where it left off before the disconnect?
      
            (getter = shouldResubscribeOnConnectionRestore) resubscribeOnConnectionRestore  
        __Default:__ YES (_kPNShouldResubscribeOnConnectionRestore_ key in [__PNDefaultConfiguration.h__](3.4/pubnub/libs/PubNub/Misc/PNDefaultConfiguration.h))  
    
    5.  Upon connection restore, should the PubNub client "catch-up" to where it left off upon reconnecting?

             (getter = shouldRestoreSubscriptionFromLastTimeToken) restoreSubscriptionFromLastTimeToken
         __Default:__ YES (_kPNShouldRestoreSubscriptionFromLastTimeToken key in [__PNDefaultConfiguration.h__](3.4/pubnub/libs/PubNub/Misc/PNDefaultConfiguration.h))

    6.  Should the PubNub client establish the connection to PubNub using SSL?
      
            (getter = shouldUseSecureConnection) useSecureConnection  
        __Default:__ YES (_kPNSecureConnectionRequired__ key in [__PNDefaultConfiguration.h__](3.4/pubnub/libs/PubNub/Misc/PNDefaultConfiguration.h))  
    
    7.  When SSL is enabled, should PubNub client ignore all SSL certificate-handshake issues and still continue in SSL mode if it experiences issues handshaking across local proxies, firewalls, etc?
      
            (getter = shouldReduceSecurityLevelOnError) reduceSecurityLevelOnError  
        __Default:__ YES (_kPNShouldReduceSecurityLevelOnError_ key in [__PNDefaultConfiguration.h__](3.4/pubnub/libs/PubNub/Misc/PNDefaultConfiguration.h))  
    
    8.  When SSL is enabled, should the client fallback to a non-SSL connection if it experiences issues handshaking across local proxies, firewalls, etc?
      
            (getter = canIgnoreSecureConnectionRequirement) ignoreSecureConnectionRequirement
            
        __Default:__ YES (_kPNCanIgnoreSecureConnectionRequirement_ key in [__PNDefaultConfiguration.h__](3.4/pubnub/libs/PubNub/Misc/PNDefaultConfiguration.h))  
  
***NOTE: If you are using the `+defaultConfiguration` method to create your configuration instance, than you will need to update:  _kPNPublishKey_, _kPNSubscriptionKey_ and _kPNOriginHost_ keys in [__PNDefaultConfiguration.h__](3.4/pubnub/libs/PubNub/Misc/PNDefaultConfiguration.h).***
  
PubNub client configuration is then set via:
  
    [PubNub setConfiguration:[PNConfiguration defaultConfiguration]];  
        
After this call, your PubNub client will be configured with the default values taken from [__PNDefaultConfiguration.h__](3.4/pubnub/libs/PubNub/Misc/PNDefaultConfiguration.h) and is now ready to connect to the PubNub real-time network!
  
Other methods which allow you to adjust the client configuration are:  
  
    + (void)setConfiguration:(PNConfiguration *)configuration;  
    + (void)setupWithConfiguration:(PNConfiguration *)configuration andDelegate:(id<PNDelegate>)delegate;  
    + (void)setDelegate:(id<PNDelegate>)delegate;  
    + (void)setClientIdentifier:(NSString *)identifier;  
    
The above first two methods (which update client configuration) may require a __hard state reset__ if the client is already connected. A "__hard state reset__" is when the client closes all connections to the server and reconnects back using the new configuration (including previous channel list).

Changing the UUID mid-connection requires a "__soft state reset__".  A "__soft state reset__" is when the client sends an explicit `leave` request on any subscribed channels, and then resubscribes with its new UUID.

To access the client configuration and state, the following methods are provided:  
    
    + (PubNub *)sharedInstance;  
    + (NSString *)clientIdentifier;  
    + (NSArray *)subscribedChannels;  
    
    + (BOOL)isSubscribedOnChannel:(PNChannel *)channel;  
    + (BOOL)isPresenceObservationEnabledForChannel:(PNChannel *)channel;  
    
    - (BOOL)isConnected;  

## PubNub client methods  

### Connecting and Disconnecting from the PubNub Network

You can use the callback-less connection methods `+connect` to establish a connection to the remote PubNub service, or the method with state callback blocks `+connectWithSuccessBlock:errorBlock:`.  

For example, you can use the provided method in the form that best suits your needs:
    
    // Configure client (we will use client generated identifier)  
    [PubNub setConfiguration:[PNConfiguration defaultConfiguration]];  
    
    [PubNub connect];  

or
    
    // Configure client  
    [PubNub setConfiguration:[PNConfiguration defaultConfiguration]];
    [PubNub setClientIdentifier:@"test_user"];  
    
    [PubNub connectWithSuccessBlock:^(NSString *origin) {  
    
                             // Do something after client connected  
                         } 
                         errorBlock:^(PNError *error) {
                                              
                             // Handle error which occurred while client tried to  
                             // establish connection with remote service
                         }];
                                          
Disconnecting is as simple as calling `[PubNub disconnect]`.  The client will close the connection and clean up memory.

### Channels representation  

The client uses the [__PNChannel__](3.4/pubnub/libs/PubNub/Data/Channels/PNChannel.h) instance instead of string literals to identify the channel.  When you need to send a message to the channel, specify the corresponding [__PNChannel__](3.4/pubnub/libs/PubNub/Data/Channels/PNChannel.h) instance in the message sending methods.  

The [__PNChannel__](3.4/pubnub/libs/PubNub/Data/Channels/PNChannel.h) interface provides methods for channel instantiation (instance is only created if it doesn't already exist):  
    
    + (NSArray *)channelsWithNames:(NSArray *)channelsName;  
    
    + (id)channelWithName:(NSString *)channelName;  
    + (id)channelWithName:(NSString *)channelName shouldObservePresence:(BOOL)observePresence;  

You can use the first method if you want to receive a set of [__PNChannel__](3.4/pubnub/libs/PubNub/Data/Channels/PNChannel.h) instances from the list of channel identifiers.  The `observePresence` property is used to set whether or not the client should observe presence events on the specified channel.

As for the channel name, you can use any characters you want except ',' and '/', as they are reserved.

The [__PNChannel__](3.4/pubnub/libs/PubNub/Data/Channels/PNChannel.h) instance can provide information about itself:  
    
* `name` - channel name  
* `updateTimeToken` - time token of last update on this channel  
* `presenceUpdateDate` - date when last presence update arrived to this channel  
* `participantsCount` - number of participants in this channel
* `participants` - list of participant UUIDs  
  
For example, to receive a reference on a list of channel instances:  
  
    NSArray *channels = [PNChannel channelsWithNames:@[@"iosdev", @"andoirddev", @"wpdev", @"ubuntudev"]];  

### Subscribing and Unsubscribing from Channels

The client provides a set of methods which allow you to subscribe to channel(s):  
    
    + (void)subscribeOnChannel:(PNChannel *)channel;  
    + (void) subscribeOnChannel:(PNChannel *)channel  
    withCompletionHandlingBlock:(PNClientChannelSubscriptionHandlerBlock)handlerBlock;  
    
    + (void)subscribeOnChannel:(PNChannel *)channel withPresenceEvent:(BOOL)withPresenceEvent;  
    + (void)subscribeOnChannel:(PNChannel *)channel  
             withPresenceEvent:(BOOL)withPresenceEvent  
    andCompletionHandlingBlock:(PNClientChannelSubscriptionHandlerBlock)handlerBlock;  
    
    + (void)subscribeOnChannels:(NSArray *)channels;  
    + (void)subscribeOnChannels:(NSArray *)channels  
    withCompletionHandlingBlock:(PNClientChannelSubscriptionHandlerBlock)handlerBlock;  
    
    + (void)subscribeOnChannels:(NSArray *)channels withPresenceEvent:(BOOL)withPresenceEvent;  
    + (void)subscribeOnChannels:(NSArray *)channels  
              withPresenceEvent:(BOOL)withPresenceEvent  
     andCompletionHandlingBlock:(PNClientChannelSubscriptionHandlerBlock)handlerBlock;  

Each subscription method has designated methods, one to add a presence flag, and another to add a handling block.  If `withPresenceEvent` is set to `YES`, the client will automatically receive "Presence" ('join', 'leave', and 'timeout') events for channels as you subscribe to them.

Here are some subscribe examples:

    // Subscribe to the channel "iosdev" and because shouldObservePresence is true,
    // also automatically subscribes to "iosdev-pnpres" (the Presence channel for "iosdev")    
    [PubNub subscribeOnChannel:[PNChannel channelWithName:@"iosdev" shouldObservePresence:YES]];  

    // Subscribe on set of channels with subscription state handling block
    [PubNub subscribeOnChannels:[PNChannel channelsWithNames:@[@"iosdev", @"andoirddev", @"wpdev", @"ubuntudev"]]  
    withCompletionHandlingBlock:^(PNSubscriptionProcessState state, NSArray *channels, PNError *subscriptionError) {  
        
        switch(state) {  
        
            case PNSubscriptionProcessNotSubscribedState:  
            
                // Check whether 'subscriptionError' instance is nil or not (if not, handle error)  
                break;  
            case PNSubscriptionProcessSubscribedState:  
            
                // Do something after subscription completed  
                break;  
            case PNSubscriptionProcessWillRestoreState:  
            
                // Library is about to restore subscription on channels after connection went down and restored  
                break;  
            case PNSubscriptionProcessRestoredState:  
            
                // Handle event that client completed resubscription  
                break;  
        }  
    }];  

The client of course also provides a set of methods which allow you to unsubscribe from channels:  
    
    + (void)unsubscribeFromChannel:(PNChannel *)channel;  
    + (void)unsubscribeFromChannel:(PNChannel *)channel  
       withCompletionHandlingBlock:(PNClientChannelUnsubscriptionHandlerBlock)handlerBlock;  
       
    + (void)unsubscribeFromChannel:(PNChannel *)channel withPresenceEvent:(BOOL)withPresenceEvent;  
    + (void)unsubscribeFromChannel:(PNChannel *)channel  
                 withPresenceEvent:(BOOL)withPresenceEvent  
        andCompletionHandlingBlock:(PNClientChannelUnsubscriptionHandlerBlock)handlerBlock;  
        
    + (void)unsubscribeFromChannels:(NSArray *)channels;  
	+ (void)unsubscribeFromChannels:(NSArray *)channels  
	    withCompletionHandlingBlock:(PNClientChannelUnsubscriptionHandlerBlock)handlerBlock;  
	    
	+ (void)unsubscribeFromChannels:(NSArray *)channels withPresenceEvent:(BOOL)withPresenceEvent;  
	+ (void)unsubscribeFromChannels:(NSArray *)channels  
	              withPresenceEvent:(BOOL)withPresenceEvent  
	     andCompletionHandlingBlock:(PNClientChannelUnsubscriptionHandlerBlock)handlerBlock;  
	     
As for the subscription methods, there are a set of methods which perform unsubscribe requests.  The `withPresenceEvent` parameter set to `YES` when unsubscribing will mean that the client will send a `leave` message to channels when unsubscribed.

Lets see how we can use some of this methods to unsubscribe from channel(s):
    
    // Unsubscribe from set of channels and notify everyone that we are left
    [PubNub unsubscribeFromChannels:[PNChannel channelsWithNames:@[@"iosdev/networking", @"andoirddev", @"wpdev", @"ubuntudev"]]  
                 withPresenceEvent:YES   
        andCompletionHandlingBlock:^(NSArray *channels, PNError *unsubscribeError) {  
        
            // Check whether "unsubscribeError" is nil or not (if not, than handle error)  
        }];  

### Presence

If you've enabled the Presence feature for your account, then the client can be used to also receive real-time updates about a particual UUID's presence events, such as join, leave, and timeout.  

To use the Presence feature in your app, the follow methods are provided:
    
    + (void)enablePresenceObservationForChannel:(PNChannel *)channel;  
    + (void)enablePresenceObservationForChannels:(NSArray *)channels;  
    + (void)disablePresenceObservationForChannel:(PNChannel *)channel;  
    + (void)disablePresenceObservationForChannels:(NSArray *)channels;
    
### Who is "Here Now" ?

As Presence provides a way to receive occupancy information in real-time, the ***Here Now*** feature allows you enumerate current channel occupancy information on-demand.

Two methods are provided for this:
  
    + (void)requestParticipantsListForChannel:(PNChannel *)channel;  
    + (void)requestParticipantsListForChannel:(PNChannel *)channel  
                      withCompletionBlock:(PNClientParticipantsHandlingBlock)handleBlock;  
                      
Example:  
  
    [PubNub requestParticipantsListForChannel:[PNChannel channelWithName:@"iosdev"]  
                          withCompletionBlock:^(NSArray *udids,  
                                                PNChannel *channel,  
                                                PNError *error) {  
        if (error == nil) {  
        
            // Handle participants UDIDs retrival  
        }  
        else {  
            
            // Handle participants request error  
        }  
    }];      

### Timetoken

You can fetch the current PubNub timetoken by using the following methods:  
  
    + (void)requestServerTimeToken;  
    + (void)requestServerTimeTokenWithCompletionBlock:(PNClientTimeTokenReceivingCompleteBlock)success;  
    
Usage is very simple:  

    [PubNub requestServerTimeTokenWithCompletionBlock:^(NSNumber *timeToken, PNError *error) {  
        
        if (error == nil) {  
        
            // Use received time token as you whish  
        }  
        else {  
            
            // Handle time token retrival error  
        }  
    }];  

### Publishing Messages

Messages can be an instance of one of the following classed: __NSString__, __NSNumber__, __NSArray__, __NSDictionary__, or __NSNull__.  
If you use some other JSON serialization kit or do it by yourself, ensure that JSON comply with all requirements. If JSON string is mailformed you will receive corresponding error from remote server.  

You can use the following methods to send messages:  
  
    + (PNMessage *)sendMessage:(id)message toChannel:(PNChannel *)channel;   
    + (PNMessage *)sendMessage:(id)message  
                 toChannel:(PNChannel *)channel  
       withCompletionBlock:(PNClientMessageProcessingBlock)success;  
       
    + (void)sendMessage:(PNMessage *)message;  
    + (void)sendMessage:(PNMessage *)message withCompletionBlock:(PNClientMessageProcessingBlock)success;  

The first two methods return a [__PNMessage__](3.4/pubnub/libs/PubNub/Data/PNMessage.h) instance. If there is a need to re-publish this message for any reason, (for example, the publish request timed-out due to lack of Internet connection), it can be passed back to the last two methods to easily re-publish.
  
    PNMessage *helloMessage = [PubNub sendMessage:@"Hello PubNub"  
                                        toChannel:[PNChannel channelWithName:@"iosdev"]  
                              withCompletionBlock:^(PNMessageState messageSendingState, id data) {  
                                    
                                  switch (messageSendingState) {  
                                        
                                      case PNMessageSending:  
                                            
                                          // Handle message sending event (it means that message processing started and  
                                          // still in progress)  
                                          break;  
                                      case PNMessageSent:  
                                          
                                          // Handle message sent event  
                                          break;  
                                      case PNMessageSendingError:  
                                          
                                          // Retry message sending (but in real world should check error and hanle it)  
                                          [PubNub sendMessage:helloMessage];  
                                          break;  
                                  }  
                              }];  
Here is examplehow to send __NSDictionary__:  

    [PubNub sendMessage:@{@"message":@"Hello from dictionary object"} 
              toChannel:[PNChannel channelWithName:@"iosdev"];  
              

### History

If you have enabled the history feature for your account, the following methods can be used to fetch message history:  
  
    + (void)requestFullHistoryForChannel:(PNChannel *)channel;  
    + (void)requestFullHistoryForChannel:(PNChannel *)channel   
                     withCompletionBlock:(PNClientHistoryLoadHandlingBlock)handleBlock;  
                     
    + (void)requestHistoryForChannel:(PNChannel *)channel from:(PNDate *)startDate to:(PNDate *)endDate;  
    + (void)requestHistoryForChannel:(PNChannel *)channel  
                                from:(PNDate *)startDate  
                                  to:(PNDate *)endDate  
                 withCompletionBlock:(PNClientHistoryLoadHandlingBlock)handleBlock;  
                 
	+ (void)requestHistoryForChannel:(PNChannel *)channel  
	                            from:(PNDate *)startDate  
	                              to:(PNDate *)endDate  
	                           limit:(NSUInteger)limit;  
	+ (void)requestHistoryForChannel:(PNChannel *)channel  
	                            from:(PNDate *)startDate  
	                              to:(PNDate *)endDate  
	                           limit:(NSUInteger)limit  
	             withCompletionBlock:(PNClientHistoryLoadHandlingBlock)handleBlock;  

	+ (void)requestHistoryForChannel:(PNChannel *)channel  
	                            from:(PNDate *)startDate  
	                              to:(PNDate *)endDate  
	                           limit:(NSUInteger)limit  
	                  reverseHistory:(BOOL)shouldReverseMessageHistory;  
	+ (void)requestHistoryForChannel:(PNChannel *)channel  
	                            from:(PNDate *)startDate  
	                              to:(PNDate *)endDate  
	                           limit:(NSUInteger)limit  
	                  reverseHistory:(BOOL)shouldReverseMessageHistory  
	             withCompletionBlock:(PNClientHistoryLoadHandlingBlock)handleBlock;  
	             
The first two methods will receive the full message history for a specified channel.  ***Be careful, this could be a lot of messages, and consequently, a very long process!***
  
In the following example, we pull history for the `iosdev` channel within the specified time frame, limiting the maximum number of messages returned to 34:
    
    PNDate *startDate = [PNDate dateWithDate:[NSDate dateWithTimeIntervalSinceNow:(-3600.0f)]];  
    PNDate *endDate = [PNDate dateWithDate:[NSDate date]];  
    int limit = 34;  
    [PubNub requestHistoryForChannel:[PNChannel channelWithName:@"iosdev"]  
                                from:startDate  
                                  to:endDate  
                               limit:limit  
                      reverseHistory:NO  
                 withCompletionBlock:^(NSArray *messages,  
                                       PNChannel *channel,  
                                       PNDate *startDate,  
                                       PNDate *endDate,  
                                       PNError *error) {  
                                       
                     if (error == nil) {  
                     
                         // Handle received messages history  
                     }  
                     else {  
                     
                         // Handle history fetch error  
                     }  
                 }];  


## Error handling

In the event of an error, the client will generate an instance of ***PNError***, which will include the error code (defined in PNErrorCodes.h), as well as additional information which is available via the `localizedDescription`,`localizedFailureReason`, and `localizedRecoverySuggestion` methods.  

In some cases, the error object will contain the "context instance object" via the `associatedObject` attribute.  This is the object  (such as a PNMessage) which is directly related to the error at hand.
  
## Event handling

The client provides different methods of handling different events:  

1. Delegate callback methods  
2. Block callbacks
3. Observation center
4. Notifications  

### Delegate callback methods  

At any given time, there can be only one PubNub client delegate. The delegate class must conform to the [__PNDelegate__](pubnub/libs/PubNub/Misc/Protocols/PNDelegate.h) protocol in order to receive callbacks.  

Here is full set of callbacks which are available:
  
    - (void)pubnubClient:(PubNub *)client error:(PNError *)error;  
    
    - (void)pubnubClient:(PubNub *)client willConnectToOrigin:(NSString *)origin;  
    - (void)pubnubClient:(PubNub *)client didConnectToOrigin:(NSString *)origin;  
    - (void)pubnubClient:(PubNub *)client didDisconnectFromOrigin:(NSString *)origin;  
    - (void)pubnubClient:(PubNub *)client didDisconnectFromOrigin:(NSString *)origin withError:(PNError *)error;  
    - (void)pubnubClient:(PubNub *)client willDisconnectWithError:(PNError *)error;  
    - (void)pubnubClient:(PubNub *)client connectionDidFailWithError:(PNError *)error;  
    
    - (void)pubnubClient:(PubNub *)client didSubscribeOnChannels:(NSArray *)channels;  
    - (void)pubnubClient:(PubNub *)client willRestoreSubscriptionOnChannels:(NSArray *)channels;  
    - (void)pubnubClient:(PubNub *)client didRestoreSubscriptionOnChannels:(NSArray *)channels;  
    - (void)pubnubClient:(PubNub *)client subscriptionDidFailWithError:(PNError *)error;  
    
    - (void)pubnubClient:(PubNub *)client didUnsubscribeOnChannels:(NSArray *)channels;  
    - (void)pubnubClient:(PubNub *)client unsubscriptionDidFailWithError:(PNError *)error;  
    
    - (void)pubnubClient:(PubNub *)client didReceiveTimeToken:(NSNumber *)timeToken;  
    - (void)pubnubClient:(PubNub *)client timeTokenReceiveDidFailWithError:(PNError *)error;  
    
    - (void)pubnubClient:(PubNub *)client willSendMessage:(PNMessage *)message;  
    - (void)pubnubClient:(PubNub *)client didFailMessageSend:(PNMessage *)message withError:(PNError *)error;  
    - (void)pubnubClient:(PubNub *)client didSendMessage:(PNMessage *)message;  
    - (void)pubnubClient:(PubNub *)client didReceiveMessage:(PNMessage *)message;  
    - (void)pubnubClient:(PubNub *)client didReceivePresenceEvent:(PNPresenceEvent *)event;  
    
    - (void)    pubnubClient:(PubNub *)client  
    didReceiveMessageHistory:(NSArray *)messages  
                  forChannel:(PNChannel *)channel  
                startingFrom:(PNDate *)startDate  
                          to:(PNDate *)endDate;  
    - (void)pubnubClient:(PubNub *)client didFailHistoryDownloadForChannel:(PNChannel *)channel withError:(PNError *)error;  
    
    - (void)      pubnubClient:(PubNub *)client  
    didReceiveParticipantsLits:(NSArray *)participantsList  
                    forChannel:(PNChannel *)channel;  
    
    - (void)                         pubnubClient:(PubNub *)client
        didFailParticipantsListDownloadForChannel:(PNChannel *)channel  
                                        withError:(PNError *)error;  
	                                
    - (NSNumber *)shouldReconnectPubNubClient:(PubNub *)client;  
    - (NSNumber *)shouldResubscribeOnConnectionRestore;  
	
### Block callbacks

Many of the client methods support callback blocks as a way to handle events in lieu of a delegate. For each method, only the last block callback will be triggered -- that is, in the case you send many identical requests via a handling block, only last one will register.  

### Observation center

[__PNObservationCenter__](3.4/pubnub/libs/PubNub/Core/PNObservationCenter.h) is used in the same way as NSNotificationCenter, but instead of observing with selectors it allows you to specify a callback block for particular events.  

These blocks are described in [__PNStructures.h__](3.4/pubnub/libs/PubNub/Misc/PNStructures.h).  

This is the set of methods which can be used to handle events:  
  
    - (void)addClientConnectionStateObserver:(id)observer  
                           withCallbackBlock:(PNClientConnectionStateChangeBlock)callbackBlock;
                           
    - (void)removeClientConnectionStateObserver:(id)observer;  
	
    - (void)addClientChannelSubscriptionStateObserver:(id)observer  
                                    withCallbackBlock:(PNClientChannelSubscriptionHandlerBlock)callbackBlock;  
    
    - (void)removeClientChannelSubscriptionStateObserver:(id)observer;  

    - (void)addClientChannelUnsubscriptionObserver:(id)observer  
	                             withCallbackBlock:(PNClientChannelUnsubscriptionHandlerBlock)callbackBlock;  

    - (void)removeClientChannelUnsubscriptionObserver:(id)observer;  
	
    - (void)addTimeTokenReceivingObserver:(id)observer  
                        withCallbackBlock:(PNClientTimeTokenReceivingCompleteBlock)callbackBlock;  

    - (void)removeTimeTokenReceivingObserver:(id)observer;  
	
    - (void)addMessageProcessingObserver:(id)observer withBlock:(PNClientMessageProcessingBlock)handleBlock;  
    - (void)removeMessageProcessingObserver:(id)observer;  
	
    - (void)addMessageReceiveObserver:(id)observer withBlock:(PNClientMessageHandlingBlock)handleBlock;  
    - (void)removeMessageReceiveObserver:(id)observer;  
	
    - (void)addPresenceEventObserver:(id)observer withBlock:(PNClientPresenceEventHandlingBlock)handleBlock;  
    - (void)removePresenceEventObserver:(id)observer;  
	
    - (void)addMessageHistoryProcessingObserver:(id)observer withBlock:(PNClientHistoryLoadHandlingBlock)handleBlock;  
    - (void)removeMessageHistoryProcessingObserver:(id)observer;  
	
    - (void)addChannelParticipantsListProcessingObserver:(id)observer  
                                               withBlock:(PNClientParticipantsHandlingBlock)handleBlock;  
    
    - (void)removeChannelParticipantsListProcessingObserver:(id)observer;  
	
### Notifications

The client also triggers notifications with custom user information, so from any place in your application you can listen for notifications and perform appropriate actions.

A full list of notifications are stored in [__PNNotifications.h__](3.4/pubnub/libs/PubNub/Misc/PNNotifications.h) along with their description, their parameters, and how to handle them.  

### Logging

Logging can be controlled via the following booleans:

    #define PNLOG_GENERAL_LOGGING_ENABLED 0
    #define PNLOG_REACHABILITY_LOGGING_ENABLED 0
    #define PNLOG_COMMUNICATION_CHANNEL_LAYER_ERROR_LOGGING_ENABLED 0
    #define PNLOG_COMMUNICATION_CHANNEL_LAYER_INFO_LOGGING_ENABLED 0
    #define PNLOG_COMMUNICATION_CHANNEL_LAYER_WARN_LOGGING_ENABLED 0
    #define PNLOG_CONNECTION_LAYER_ERROR_LOGGING_ENABLED 0
    #define PNLOG_CONNECTION_LAYER_INFO_LOGGING_ENABLED 0

in [3.4/pubnub/libs/PubNub/Misc/PNMacro.h](3.4/pubnub/libs/PubNub/Misc/PNMacro.h#L37)

In the above example, all logging is disabled. By default, all logging is enabled.
