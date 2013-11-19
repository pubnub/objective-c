# PubNub 3.5.2 for iOS 5.1+ (iPhone, iPad, iPod)
Provides iOS ARC support in Objective-C for the [PubNub.com](http://www.pubnub.com/) real-time messaging network.  

All requests made by the client are asynchronous, and are handled by:

1. blocks (via calling method)
2. delegate methods
3. notifications
4. Observation Center

Detailed information on methods, constants, and notifications can be found in the corresponding header files.


## Important Changes from Earlier Versions
### 3.5.1
JSONKit support has been refactored so that it will only use JSONKit if your iOS version does not support NSJson.  By default in 3.5.2, JSONKit is not a required library. However, if its found, and its needed, PubNub will use it.

### 3.4.x

If you were previously using history in 3.4.x, you will need to convert your **NSDate** parameter types to **PNDate** types, as the history methods now
take PNDate arguments, not NSDate arguments. This is as easy as replacing:

```objective-c
        NSDate *startDate = [NSDate date]; // this is the old way. replace it with:

        PNDate *startDate = [PNDate dateWithDate:[NSDate date]]; // Convert from a date
        // or
        PNDate *startDate = [PNDate dateWithToken:[NSNumber numberWithInt:1234567]; // Convert from a timetoken
```

Also, there are new files in the libary that were not present in 3.4.x. Be sure when updating the library that you add these new files to your project,
or you will certainly get compile errors for missing files. Easiest thing to do is remove all PubNub files, and add the new PubNub files back.

## Coming Soon... XCode Project Template Support!
But until then...

## Adding PubNub to your project via CocoaPods
**NOTE:** Be sure you are running CocoaPods 0.26.2 or above!

[These steps are documented in our Emmy-winning CocoaPod's Setup Video, check it out here!](https://vimeo.com/69284108)

By far the easiest, quickest way to add PubNub.  **Current PubNub for CocoaPods version is 3.5.2**

+   Create an empty XCode Project
+   Add the following to your project's Podfile:

```
pod 'PubNub', '3.5.2b'
```

+   Run

```
pod install
```

+   Open the resulting workspace.
+   Add

```
#import "PNImports.h"
```

To your project's .pch file. 
**Note:** It must be the first import in your pch, or it will not work correctly.

[Finish up by setting up your delegate](#finishing-up-configuration-common-to-manual-and-cocoapods-setup)

## Adding PubNub to your project manually

1. Add the PubNub library folder to your project (/libs/PubNub)  

2. Add PNImports to your project precompile header (.pch)  
```objective-c
        #import "PNImports.h"
```

Add the following link options:


* CFNetwork.Framework
* SystemConfiguration.Framework
* libz.dylib

 
** NOTE: ** The Mac OS X version also requires CoreWLAN.framework.

## Setting up JSONKit for legacy JSON Support
### Only needed when targetting iOS 5.0 and earlier

We provide a special build of JSONKit in the iOS subdirectory (which fixes some default fatal warnings in XCode 5) only to target older versions (5 and earlier) of iOS, which do not support Apples native JSON (NSJson).

PubNub core code is ARC-compliant.  But since JSONKit (which is 3rd party) performs all memory management on it's own (it doesn't support ARC), we'll show you how to remove ARC warnings for it with the -fno-objc-arc setting.

1. Add the [JSONKit support files to your project](JSONKit)

2. Set the -fno-objc-arc compile option for JSON.m and JSONKit.m

## Finishing up configuration (Common to Manual and CocoaPods setup)

1. In AppDelegate.h, adopt the PNDelegate protocol:

```objective-c
        @interface PNAppDelegate : UIResponder <UIApplicationDelegate, PNDelegate>
```

2. In AppDelegate.m (right before the return YES line works fine), add setDelegate:

```objective-c
        [PubNub setDelegate:self] 
```

## Start Coding now with PubNub!

If you just can't wait to start using PubNub for iOS (we totally know the feeling), after performing the steps 
from [Adding PubNub to your Project](#adding-pubnub-to-your-project):

## Set config and connect
In your ViewController.m, add this to viewDidLoad():

```obj-c
[PubNub setConfiguration:[PNConfiguration configurationForOrigin:@"pubsub.pubnub.com" publishKey:@"demo" subscribeKey:@"demo" secretKey:@"mySecret"]];
[PubNub connect];

## Define a channel
PNChannel *channel_1 = [PNChannel channelWithName:@"a" shouldObservePresence:YES];

## Subscribe on the channel
[PubNub subscribeOnChannel:channel_1];

## Publish on the channel
[PubNub sendMessage:@"hello from PubNub iOS!" toChannel:channel_1];
```

2. In your AppDelegate.m, define a didReceiveMessage delegate method:

```obj-c
- (void)pubnubClient:(PubNub *)client didReceiveMessage:(PNMessage *)message {
   NSLog( @"%@", [NSString stringWithFormat:@"received: %@", message.message] );
}
```

This results in a simple app that displays a PubNub 'Ping' message, published every second from PubNub PHP Bot.    

That was just a quick and dirty demo to cut your teeth on... There are other iOS for PubNub client demo apps available! These demonstrate in more detail how you can use the delegate and completion block features of the PubNub client for iOS.

They include:

### SimpleSubscribe HOWTO

The [SimpleSubscribe](HOWTO/SimpleSubscribe) app references how to create a simple subscribe-only, non-ui application using PubNub and iOS. 
[A getting started walkthrough document is also available](https://raw.github.com/pubnub/objective-c/master/iOS/HOWTO/SimpleSubscribe/SimpleSubscribeHOWTO_34.pdf).

This is the most basic example of how to wire it all up, and as such, should take beginners and experts alike about 5-10 minutes to complete.

### Hello World HOWTO

The [Hello World](HOWTO/HelloWorld) app references how to create a simple application using PubNub and iOS. 
[A getting started walkthrough document is also available](https://raw.github.com/pubnub/objective-c/master/iOS/HOWTO/HelloWorld/HelloWorldHOWTO_34.pdf).

### CallsWithoutBlocks

The [CallsWithoutBlocks](HOWTO/CallsWithoutBlocks) app references how to use PubNub more procedurally than asyncronously. If you just want to make calls, without much care
for server responses (fire and forget).

### APNSDemo

The [APNSVideo](HOWTO/APNSVideo) app is the companion to the APNS Tutorial Videos -- keep reading for more info on this...
### Deluxe iPad Full Featured Demo

Once you are familiar with the [Hello World](HOWTO) app, The deluxe iPad-only app demonstrates all API functions in greater detail than
the Hello World app. It is intended to be a reference application.

## APNS Setup

If you've enabled your keys for APNS, you can use native PubNub publish operations to send messages to iPhones and iPads via iOS push notifications!

### APNS Video Walkthrough ###

We've just added a video walkthrough, along with a sample application (based on the video) that shows from start to
end how to setup APNS with PubNub. It includes all Apple-specific setup (which appears to be the most misunderstood) as
well as the PubNub-specific setup, along with the end product app available in [HOWTO/APNSVideo](HOWTO/APNSVideo).

If after watching the video you'd like to get a more behind-the-scenes breakdown of how PubNub and APNS work together, 
refer to [APNS Development Notes](https://github.com/pubnub/objective-c/blob/master/iOS/README_FOR_APNS.md).

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
         
         This can also be controlled via returning __YES__ or __NO__ via the __shouldRestoreSubscriptionFromLastTimeToken__ delegate.

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

```objective-c  
    [PubNub setConfiguration:[PNConfiguration defaultConfiguration]];  
```

After this call, your PubNub client will be configured with the default values taken from [__PNDefaultConfiguration.h__](3.4/pubnub/libs/PubNub/Misc/PNDefaultConfiguration.h) and is now ready to connect to the PubNub real-time network!
  
Other methods which allow you to adjust the client configuration are:  

    + (void)setConfiguration:(PNConfiguration *)configuration;  
    + (void)setupWithConfiguration:(PNConfiguration *)configuration andDelegate:(id<PNDelegate>)delegate;  
    + (void)setDelegate:(id<PNDelegate>)delegate;  
    + (void)setClientIdentifier:(NSString *)identifier;  
    
The above first two methods (which update client configuration) may require a __hard state reset__ if the client is already connected. A "__hard state reset__" is when the client closes all connections to the server and reconnects back using the new configuration (including previous channel list).

Changing the UUID mid-connection requires a "__soft state reset__".  A "__soft state reset__" is when the client sends an explicit `leave` request on any subscribed channels, and then resubscribes with its new UUID.


** NOTE:** If you wish to change the client identifier, then catchup in time where you left-off before you changed client identifier, use:

```objective-c
[PubNub setClientIdentifier:@"moonlight" shouldCatchup:YES];
```        
        
To access the client configuration and state, the following methods are provided:  

    + (PubNub *)sharedInstance;  
    + (NSString *)clientIdentifier;  
    + (NSArray *)subscribedChannels;  
       
    + (BOOL)isSubscribedOnChannel:(PNChannel *)channel;  
    + (BOOL)isPresenceObservationEnabledForChannel:(PNChannel *)channel;  
    
    - (BOOL)isConnected;  


### Determing Connection State
You can easily determine the current PubNub connection state via:

```objective-c
[[PNObservationCenter defaultCenter] addClientConnectionStateObserver:self
                                                    withCallbackBlock:^(NSString *origin,
                                                               BOOL connected,
                                                                PNError *error) {
                                                                    NSLog(@"connection %@", error);
                                                            }];
```

```objective-c
[PubNub sharedInstance].isConnected
```

Note, that just because your network is up, does not mean your connection to PubNub is up, so be sure to use this logic
for authoritative PubNub connection state status.

### Encryption Notes

This client supports the PubNub AES Encryption standard, which enables this client to speak with all other PubNub 3.4+ clients securely via AES.

When encryption is enabled, non-encrypted messages, or messages encrypted with the wrong key will be passed through as the string "DECRYPTION_ERROR".

To initialize with encryption enabled:

```objective-c

+ (PNConfiguration *)configurationForOrigin:(NSString *)originHostName  
                                 publishKey:(NSString *)publishKey  
                               subscribeKey:(NSString *)subscribeKey  
                                  secretKey:(NSString *)secretKey  
                                  cipherKey:(NSString *)cipherKey;  // To initialize with encryption, use cipherKey
```

To dynamically change the encryption key during runtime, you can run 

```objective-c
    [myConfiguration setCipherKey]
    [PubNub setConfiguration:myConfiguration]
```

To enable backwards compatibility with PubNub iOS 3.3, add this line to your .pch:

```objective-c
    #define CRYPTO_BACKWARD_COMPATIBILITY_MODE 1
```

The above directive will allow this current PubNub iOS client to speak with earlier PubNub iOS 3.3 clients.

It is advised for security and network/battery/power considerations to upgrade all clients to 3.4+ encryption as soon as possible, and to only use this
backward compatibility mode if absolutely neccesary.

#### Encrypt / Descrypt Methods

If you wish to manually utilize the encryption logic for your own purposes (decrypt messages sent via PubNub from APNS for example), the following public methods can be used:

```objective-c
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
```


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
  
If you set **from** or **to** as nil, that argument will be ignored.  For example:

```objective-c
requestHistoryForChannel:(myChannel)  
                            from:(nil)
                              to:(myEndDate)
                           limit:(NSUInteger)100  
                  reverseHistory:(YES);
```

the **start** value will be omitted from the server request. Likewise with:

```objective-c
requestHistoryForChannel:(myChannel)  
                            from:(myStartDate)
                              to:(nil)
                           limit:(NSUInteger)100  
                  reverseHistory:(YES);
```

the **end** value will be omitted from the server request.  Setting both start and end to nil:

```objective-c

requestHistoryForChannel:(myChannel)  
                            from:(nil)
                              to:(nil)
                           limit:(NSUInteger)100  
                  reverseHistory:(YES);
```

Will omit both from the server request, thus simply returning the last **[limit]** results from history.

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

## APNS Methods
PubNub provides the ability to send APNS push notifications from any client (iOS, Android, Java, Ruby, etc) using the native PubNub publish() mechanism. APNS push notifications can only be received on supported iOS devices (iPad, iPhone, etc).

Normally, when you publish a message, it stays on the PubNub network, and is only accessible by native PubNub subscribers.  If you want that same message to be recieved on an iOS device via APNS, you must first associate the PubNub channel with the destination device's device ID (also known as a push token).

To perform this association, use one of the following:

```objective-c
+ (void)enablePushNotificationsOnChannel:(PNChannel *)channel withDevicePushToken:(NSData *)pushToken;
+ (void)enablePushNotificationsOnChannel:(PNChannel *)channel
                     withDevicePushToken:(NSData *)pushToken
              andCompletionHandlingBlock:(PNClientPushNotificationsEnableHandlingBlock)handlerBlock;
+ (void)enablePushNotificationsOnChannels:(NSArray *)channels withDevicePushToken:(NSData *)pushToken;
+ (void)enablePushNotificationsOnChannels:(NSArray *)channels
                      withDevicePushToken:(NSData *)pushToken
               andCompletionHandlingBlock:(PNClientPushNotificationsEnableHandlingBlock)handlerBlock;
```

To disable this association, use one of the following:

```objective-c
+ (void)disablePushNotificationsOnChannel:(PNChannel *)channel withDevicePushToken:(NSData *)pushToken;
+ (void)disablePushNotificationsOnChannel:(PNChannel *)channel
                     withDevicePushToken:(NSData *)pushToken
              andCompletionHandlingBlock:(PNClientPushNotificationsDisableHandlingBlock)handlerBlock;
+ (void)disablePushNotificationsOnChannels:(NSArray *)channels withDevicePushToken:(NSData *)pushToken;
+ (void)disablePushNotificationsOnChannels:(NSArray *)channels
                       withDevicePushToken:(NSData *)pushToken
                andCompletionHandlingBlock:(PNClientPushNotificationsDisableHandlingBlock)handlerBlock;
```

You can remove them all, instead of individually using:

```objective-c
+ (void)removeAllPushNotificationsForDevicePushToken:(NSData *)pushToken
                         withCompletionHandlingBlock:(PNClientPushNotificationsRemoveHandlingBlock)handlerBlock;
```
                         
And to get an active list (audit) of whats currently associated:

```objective-c
+ (void)requestPushNotificationEnabledChannelsForDevicePushToken:(NSData *)pushToken
                                     withCompletionHandlingBlock:(PNClientPushNotificationsEnabledChannelsHandlingBlock)handlerBlock;
```

Check out a working example in the APNS Demo HOWTO app.


## Error handling

In the event of an error, the client will generate an instance of ***PNError***, which will include the error code (defined in PNErrorCodes.h), as well as additional information which is available via the `localizedDescription`,`localizedFailureReason`, and `localizedRecoverySuggestion` methods.  

In some cases, the error object will contain the "context instance object" via the `associatedObject` attribute.  This is the object  (such as a PNMessage) which is directly related to the error at hand.
  
## Event handling

The client provides different methods of handling different events:  

1. Delegate callback methods  
2. Block callbacks
3. Observation center
4. Notifications  

## Delegate callback methods

In the PubNub iOS client, delegate callback methods provide one way to handle different events. At any given time, there can be only one PubNub client delegate. 

The delegate class must conform to the PNDelegate protocol in order to receive callbacks. 

Lets go through each delegate with a small example.


####- (void)pubnubClient:(PubNub *)client error:(PNError *)error;

This delegate method is called when an error occurs in the PubNub client.
“error” will contain the details of the error. Example usage follows:

```objective-c
- (void)pubnubClient:(PubNub *)client error:(PNError *)error {
PNLog(PNLogGeneralLevel, self, @"An error occurred: %@", error);
}
```
####- (void)pubnubClient:(PubNub *)client willConnectToOrigin:(NSString *)origin;  


This delegate method is called when the client is about to connect to the PubNub origin. “origin” will contain the PubNub origin url.  Example usage follows:

```objective-c
- (void)pubnubClient:(PubNub *)client willConnectToOrigin:(NSString *)origin { 
PNLog(PNLogGeneralLevel, self, @"PubNub client is about to connect to PubNub origin at: %@", origin);
}
```

####- (void)pubnubClient:(PubNub *)client didConnectToOrigin:(NSString *)origin;  

This delegate method is called when the client is successfully connected to the PubNub origin. “origin” will contain the PubNub origin url. Example usage follows:

```objective-c
- (void)pubnubClient:(PubNub *)client didConnectToOrigin:(NSString *)origin { 					PNLog(PNLogGeneralLevel, self, @"PubNub client successfully connected to PubNub origin at: %@", origin);
}
```

####- (void)pubnubClient:(PubNub *)client didDisconnectFromOrigin:(NSString *)origin;

This delegate method is called when the client is successfully disconnected from the PubNub origin. “origin” will contain the PubNub origin url.  Example usage follows:

```objective-c
- (void)pubnubClient:(PubNub *)client didDisconnectFromOrigin:(NSString *)origin {
PNLog(PNLogGeneralLevel, self, @"PubNub client disconnected from PubNub origin at: %@", origin);
}
```

####- (void)pubnubClient:(PubNub *)client didDisconnectFromOrigin:(NSString *)origin withError:(PNError *)error;  

This delegate method is called when the client is disconnected from the PubNub origin due to an error. “error” will contain the details of the error. “origin” will contain the PubNub origin url.  Example usage follows:

```objective-c
- (void)pubnubClient:(PubNub *)client didDisconnectFromOrigin:(NSString *)origin withError:(PNError *)error {
    PNLog(PNLogGeneralLevel, self, @"PubNub client closed connection because of error: %@", error);
}
```

####- (void)pubnubClient:(PubNub *)client willDisconnectWithError:(PNError *)error;  
This delegate method is called if an error occurred when disconnecting from the PubNub origin.
“error” will contain the details of the error.  Example usage follows:

```objective-c
- (void)pubnubClient:(PubNub *)client willDisconnectWithError:(PNError *)error {
PNLog(PNLogGeneralLevel, self, @"PubNub client will close connection because of error: %@", error);
}
```

####- (void)pubnubClient:(PubNub *)client connectionDidFailWithError:(PNError *)error;  
This delegate method is called if an error occurred when connecting to the PubNub origin.
“error” will contain the details of the error.  Example usage follows:

```objective-c
- (void)pubnubClient:(PubNub *)client connectionDidFailWithError:(PNError *)error {
PNLog(PNLogGeneralLevel, self, @"PubNub client was unable to connect because of error: %@", error);
}
```

####- (void)pubnubClient:(PubNub *)client didSubscribeOnChannels:(NSArray *)channels;  
This delegate method is called when the client is successfully subscribed call to the channels. 
“channels” will contain the array of channels to which the client is subscribed.  Example usage follows:

```objective-c
- (void)pubnubClient:(PubNub *)client didSubscribeOnChannels:(NSArray *)channels {
PNLog(PNLogGeneralLevel, self, @"PubNub client successfully subscribed to channels:%@", channels);
}
```

####- (void)pubnubClient:(PubNub *)client willRestoreSubscriptionOnChannels:(NSArray *)channels;  
This delegate method is called when the subscription on the channels is about to be restored after a network disconnect.
“channels” will contain the array of channels to which the subscription is about to be restored.  Example usage follows:

```objective-c
- (void)pubnubClient:(PubNub *)client willRestoreSubscriptionOnChannels:(NSArray *)channels {
    PNLog(PNLogGeneralLevel, self, @"PubNub client resuming subscription on: %@", channels);
}
```

####- (void)pubnubClient:(PubNub *)client didRestoreSubscriptionOnChannels:(NSArray *)channels;  
This delegate method is called when the subscription on the channels is successfully restored after a network disconnect.
“channels” will contain the array of channels to which the subscription has been restored.  Example usage follows:

```objective-c
- (void)pubnubClient:(PubNub *)client didRestoreSubscriptionOnChannels:(NSArray *)channels {
    PNLog(PNLogGeneralLevel, self, @"PubNub client successfully restored subscription on channels: %@", channels);
}
```

####- (void)pubnubClient:(PubNub *)client subscriptionDidFailWithError:(PNError *)error;  
This delegate method is called if an error occurred when subscribing to a channel.
“error” will contain the details of the error.  Example usage follows:

```objective-c
- (void)pubnubClient:(PubNub *)client subscriptionDidFailWithError:(NSError *)error {
PNLog(PNLogGeneralLevel, self, @"PubNub client failed to subscribe because of error: %@", error);
}
```

####- (void)pubnubClient:(PubNub *)client didUnsubscribeOnChannels:(NSArray *)channels;  
This delegate method is called if the channels are successfully unsubscribed.
“channels” will contain the array of channels which have been unsubscribed.  Example usage follows:

```objective-c
- (void)pubnubClient:(PubNub *)client didUnsubscribeOnChannels:(NSArray *)channels {    
PNLog(PNLogGeneralLevel, self, @"PubNub client successfully unsubscribed from channels: %@", channels);
}
```

####- (void)pubnubClient:(PubNub *)client unsubscriptionDidFailWithError:(PNError *)error;  
This delegate method is called if an error occurs when a channel is unsubscribed.
“error” will contain the details of the error.  Example usage follows:

```objective-c
- (void)pubnubClient:(PubNub *)client unsubscriptionDidFailWithError:(PNError *)error {
PNLog(PNLogGeneralLevel, self, @"PubNub client failed to unsubscribe because of 	error: %@", error);
}
```

####- (void)pubnubClient:(PubNub *)client didEnablePresenceObservationOnChannels:(NSArray *)channels;
This delegate method is called if the presence notifications are successfully enabled.
“channels” will contain the array of channels which have presence notifications enabled.  Example usage follows:

```objective-c
- (void)pubnubClient:(PubNub *)client didEnablePresenceObservationOnChannels:(NSArray *)channels {
    PNLog(PNLogGeneralLevel, self, @"PubNub client successfully enabled presence observation on channels: %@", channels);
}
```

####- (void)pubnubClient:(PubNub *)client presenceObservationEnablingDidFailWithError:(PNError *)error;
This delegate method is called if an error occurs on enabling presence notifications.
“error” will contain the details of the error.  Example usage follows:

```objective-c
- (void)pubnubClient:(PubNub *)client presenceObservationEnablingDidFailWithError:(PNError *)error {
    PNLog(PNLogGeneralLevel, self, @"PubNub client failed to enable presence observation because of error: %@", error);
}
```

####- (void)pubnubClient:(PubNub *)client didDisablePresenceObservationOnChannels:(NSArray *)channels;
This delegate method is called if the presence notifications are successfully disabled.
“channels” will contain the array of channels which have presence notifications disabled.  Example usage follows:

```objective-c
- (void)pubnubClient:(PubNub *)client didDisablePresenceObservationOnChannels:(NSArray *)channels {
    PNLog(PNLogGeneralLevel, self, @"PubNub client successfully disabled presence observation on channels: %@", channels);
}
```

####- (void)pubnubClient:(PubNub *)client presenceObservationDisablingDidFailWithError:(PNError *)error;
This delegate method is called if an error occurs on disabling presence notifications.
“error” will contain the details of the error.  Example usage follows:

```objective-c
- (void)pubnubClient:(PubNub *)client presenceObservationDisablingDidFailWithError:(PNError *)error {
    PNLog(PNLogGeneralLevel, self, @"PubNub client failed to disable presence observation      because of error: %@", error);
}
```

####- (void)pubnubClient:(PubNub *)client didEnablePushNotificationsOnChannels:(NSArray *)channels;
This delegate method is called if push notifications for all channels are successfully enabled.
“channels” will contain the array of channels which have push notifications enabled.  Example usage follows:

```objective-c
- (void)pubnubClient:(PubNub *)client didEnablePushNotificationsOnChannels:(NSArray *)channels {
PNLog(PNLogGeneralLevel, self, @"PubNub client enabled push notifications on channels: %@", channels);
}
```

####- (void)pubnubClient:(PubNub *)client pushNotificationEnableDidFailWithError:(PNError *)error;
This delegate method is called when an error occurs on enabling push notifications for all channels.
“error” will contain the details of the error.  Example usage follows:

```objective-c
- (void)pubnubClient:(PubNub *)client pushNotificationEnableDidFailWithError:(PNError *)error {
PNLog(PNLogGeneralLevel, self, @"PubNub client failed push notification enable because of error: %@", error);
}
```

####- (void)pubnubClient:(PubNub *)client didDisablePushNotificationsOnChannels:(NSArray *)channels;
This delegate method is called when push notifications for all channels are successfully disabled.
“channels” will contain the array of channels which have push notifications disabled.   Example usage follows:

```objective-c
- (void)pubnubClient:(PubNub *)client didDisablePushNotificationsOnChannels:(NSArray *)channels {
PNLog(PNLogGeneralLevel, self, @"PubNub client disabled push notifications on channels: %@", channels);
}
```

####- (void)pubnubClient:(PubNub *)client pushNotificationDisableDidFailWithError:(PNError *)error;
This delegate method is called when an error occurs on disabling push notifications for all channels.
“error” will contain the details of the error.  Example usage follows:

```objective-c
- (void)pubnubClient:(PubNub *)client pushNotificationDisableDidFailWithError:(PNError *)error {
PNLog(PNLogGeneralLevel, self, @"PubNub client failed to disable push notifications because of error: %@", error);
}
```

####- (void)pubnubClientDidRemovePushNotifications:(PubNub *)client;
This delegate method is called when push notifications for all channels are successfully removed.  Example usage follows:

```objective-c
- (void)pubnubClientDidRemovePushNotifications:(PubNub *)client {
PNLog(PNLogGeneralLevel, self, @"PubNub client removed push notifications from all channels");
}
```

####- (void)pubnubClient:(PubNub *)client pushNotificationsRemoveFromChannelsDidFailWithError:(PNError *)error;
This delegate method is called when an error occurs on removing push notifications for all channels.
“error” will contain the details of the error.  Example usage follows:

```objective-c
- (void)pubnubClient:(PubNub *)client pushNotificationsRemoveFromChannelsDidFailWithError:(PNError *)error {
PNLog(PNLogGeneralLevel, self, @"PubNub client failed remove push notifications from channels because of error: %@", error);
}
```

####- (void)pubnubClient:(PubNub *)client didReceivePushNotificationEnabledChannels:(NSArray *)channels;
This delegate method is called when the client successfully receives to receive push notifications for a channel. “channels” will contain the array of channels which received push notifications.   Example usage follows:

```objective-c
- (void)pubnubClient:(PubNub *)client didReceivePushNotificationEnabledChannels:(NSArray *)channels {
PNLog(PNLogGeneralLevel, self, @"PubNub client received push notifications for these enabled channels: %@", channels);
}
```

####- (void)pubnubClient:(PubNub *)client pushNotificationEnabledChannelsReceiveDidFailWithError:(PNError *)error;
This delegate method is called when the client fails to receive push notifications for a channel.
“error” will contain the details of the error.  Example usage follows:

```objective-c
- (void)pubnubClient:(PubNub *)client pushNotificationEnabledChannelsReceiveDidFailWithError:(PNError *)error {
PNLog(PNLogGeneralLevel, self, @"PubNub client failed to receive list of channels because of error: %@", error);
}
```

####- (void)pubnubClient:(PubNub *)client didReceiveTimeToken:(NSNumber *)timeToken;  
This delegate method is called when the client successfully retrieves the timetoken from the server. 
“timeToken” will contain the retrieved timetoken.  Example usage follows:

```objective-c
- (void)pubnubClient:(PubNub *)client didReceiveTimeToken:(NSNumber *)timeToken {
    PNLog(PNLogGeneralLevel, self, @"PubNub client received time token: %@", timeToken);
}
```

####- (void)pubnubClient:(PubNub *)client timeTokenReceiveDidFailWithError:(PNError *)error;  
This delegate method is called when the client fails to retrieve the timetoken from the server. 
“error” will contain the details of the error.  Example usage follows:

```objective-c
- (void)pubnubClient:(PubNub *)client timeTokenReceiveDidFailWithError:(PNError *)error 
PNLog(PNLogGeneralLevel, self, @"PubNub client failed to receive time token because of error: %@", error);
}
```

####- (void)pubnubClient:(PubNub *)client willSendMessage:(PNMessage *)message;  
This delegate method is called when the client is about to send a message on a channel. 
“message” will contain the details of the message including the channel info.  Example usage follows:

```objective-c
- (void)pubnubClient:(PubNub *)client willSendMessage:(PNMessage *)message {
PNLog(PNLogGeneralLevel, self, @"PubNub client is about to send message: %@", message);
}
```

####- (void)pubnubClient:(PubNub *)client didFailMessageSend:(PNMessage *)message withError:(PNError *)error;  
This delegate method is called when the client fails to send a message on a channel. 
“message” will contain the details of the message including the channel info.
“error” will contain the details of the error.  Example usage follows:

```objective-c
- (void)pubnubClient:(PubNub *)client didFailMessageSend:(PNMessage *)message withError:(PNError *)error {    
PNLog(PNLogGeneralLevel, self, @"PubNub client failed to send message '%@' because of error: %@", message, error);
}
```

####- (void)pubnubClient:(PubNub *)client didSendMessage:(PNMessage *)message;  
This delegate method is called when the client successfully sends a message on a channel. 
“message” will contain the details of the message including the channel info.  Example usage follows:

```objective-c
- (void)pubnubClient:(PubNub *)client didSendMessage:(PNMessage *)message{ 
PNLog(PNLogGeneralLevel, self, @"PubNub client sent message: %@", message);
}
```

####- (void)pubnubClient:(PubNub *)client didReceiveMessage:(PNMessage *)message; 
This delegate method is called when the client successfully receives a message on a subscribed channel. 
“message” will contain the details of the message including the channel info.  Example usage follows:

```objective-c
- (void)pubnubClient:(PubNub *)client didReceiveMessage:(PNMessage *)message {    
    PNLog(PNLogGeneralLevel, self, @"PubNub client received message: %@", message);
}
```

####- (void)pubnubClient:(PubNub *)client didReceivePresenceEvent:(PNPresenceEvent *)event;  
This delegate method is called when the client successfully receives a presence event on a channel whose presence notifications are subscribed. 
“event” will contain the presence event.  Example usage follows:

```objective-c
- (void)pubnubClient:(PubNub *)client didReceivePresenceEvent:(PNPresenceEvent *)event {
PNLog(PNLogGeneralLevel, self, @"PubNub client received presence event: %@", event);
}
```

####- (void)    pubnubClient:(PubNub *)client didReceiveMessageHistory:(NSArray *)messages          forChannel:(PNChannel *)channel  
            startingFrom:(PNDate *)startDate  
                      to:(PNDate *)endDate;  
This delegate method is called when the client successfully retrieves the history of messages on the channel. 
“channel” will contain the value of the PubNub channel.
“messages” will contain the retrieved messages as an NSArray.
“startDate” and “endDate” are the datetime range of the retrieved messages.  Example usage follows:

```objective-c
- (void)pubnubClient:(PubNub *)client
didReceiveMessageHistory:(NSArray *)messages
          forChannel:(PNChannel *)channel
        startingFrom:(NSDate *)startDate
                  to:(NSDate *)endDate {
PNLog(PNLogGeneralLevel, self, @"PubNub client received history for %@ starting from %@ to %@: %@", channel, startDate, endDate, messages);
}
```

####- (void)pubnubClient:(PubNub *)client didFailHistoryDownloadForChannel:(PNChannel *)channel withError:(PNError *)error;  
This delegate method is called when the client fails to get history of messages on the channel. 
“channel” will contain the value of the PubNub channel and 
“error” will contain the error info.  Example usage follows:

```objective-c
- (void)pubnubClient:(PubNub *)client didFailHistoryDownloadForChannel:(PNChannel *)channel withError:(PNError *)error {
PNLog(PNLogGeneralLevel, self, @"PubNub client failed to download history for %@ because of error: %@", channel, error);
}
```

####- (void) pubnubClient:(PubNub *)client  didReceiveParticipantsLits:(NSArray *)participantsList forChannel:(PNChannel *)channel;  
This delegate method is called when the client successfully retrieves the info of other connected users on the channel. The users info will be contained the “participantsList” which is an NSArray. “channel” will contain the value of the PubNub channel.  Example usage follows:

```objective-c
- (void) pubnubClient:(PubNub *)client
didReceiveParticipantsLits:(NSArray *)participantsList
                forChannel:(PNChannel *)channel {
PNLog(PNLogGeneralLevel, self, @"PubNub client received participants list for channel %@: %@", participantsList, channel);
}
```

####- (void) pubnubClient:(PubNub *)client didFailParticipantsListDownloadForChannel:(PNChannel *)channel withError:(PNError *)error;  
This delegate method is called when the client fails to get the info of other connected users on the channel. 
“channel” will contain the value of the PubNub channel and 
“error” will contain the error info.  Example usage follows:

```objective-c
- (void) pubnubClient:(PubNub *)client
didFailParticipantsListDownloadForChannel:(PNChannel *)channel
                                withError:(PNError *)error {
PNLog(PNLogGeneralLevel, self, @"PubNub client failed to download participants list for channel %@ because of error: %@", channel, error);
}
```

####- (BOOL)shouldRunClientInBackground;
This method returns the setting to determine if the client is configured to run in the background mode when the app goes into the background. If this method not implemented by delegate, then the app property list is read to determine if the app is configured to run in the background mode.  Example usage follows:

```objective-c
BOOL canRunInBackground = [UIApplication canRunInBackground];
if ([self.delegate respondsToSelector:@selector(shouldRunClientInBackground)]) {
      canRunInBackground = [self.delegate shouldRunClientInBackground];
}
```

####- (NSNumber *)shouldReconnectPubNubClient:(PubNub *)client;  
This is a delegate method to override the value in the configuration which was passed at the time of initialization. This method is called on reconnect, if the previous session had failed due to network issues or on first launch. This will connect the client automatically on reconnect. If called manually this will trigger hard reset of the client connection.  Example usage follows:

```objective-c
- (NSNumber *)shouldResubscribeOnConnectionRestore {
    return @(NO);
}
```

####- (NSNumber *)shouldResubscribeOnConnectionRestore;  
This is a delegate method to override the value in the configuration which was passed at the time of initialization. This method is called on reconnect, if the previous session had failed due to network issues or on first launch. If this is true the subscription of the PubNub channel(s) is restored.  Example usage follows:

```objective-c
- (NSNumber *)shouldResubscribeOnConnectionRestore {
    NSNumber *shouldResubscribeOnConnectionRestore = @(YES);
    PNLog(PNLogGeneralLevel, self, @"PubNub client should restore subscription? %@",[shouldResubscribeOnConnectionRestore boolValue]?@"YES":@"NO");
    return shouldResubscribeOnConnectionRestore;
}
```

####- (NSNumber *)shouldRestoreSubscriptionFromLastTimeToken;
This is a delegate method to override the value in the configuration which was passed at the time of initialization. It is called by the library after reconnect, if the client was configured to restore subscription on channels.  Example usage follows:

```objective-c
- (NSNumber *)shouldRestoreSubscriptionFromLastTimeToken {
      NSNumber *shouldRestoreSubscriptionFromLastTimeToken = @(NO);
      NSString *lastTimeToken = @"0";
if ([[PubNub subscribedChannels] count] > 0) {
         lastTimeToken = [[[PubNub subscribedChannels] lastObject] updateTimeToken];
     }
     PNLog(PNLogGeneralLevel, self, @"PubNub client should restore subscription from last time token? %@ (last time token: %@)", [shouldRestoreSubscriptionFromLastTimeToken boolValue]?@"YES":@"NO", lastTimeToken);
return shouldRestoreSubscriptionFromLastTimeToken;
}
```
	
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

    #define kPNLogMaximumLogFileSize (10 * 1024 * 1024)

    #define PNLOG_LOGGING_ENABLED 1
    #define PNLOG_STORE_LOG_TO_FILE 1
    #define PNLOG_GENERAL_LOGGING_ENABLED 1
    #define PNLOG_DELEGATE_LOGGING_ENABLED 1
    #define PNLOG_REACHABILITY_LOGGING_ENABLED 1
    #define PNLOG_DESERIALIZER_INFO_LOGGING_ENABLED 1
    #define PNLOG_DESERIALIZER_ERROR_LOGGING_ENABLED 1
    #define PNLOG_COMMUNICATION_CHANNEL_LAYER_ERROR_LOGGING_ENABLED 1
    #define PNLOG_COMMUNICATION_CHANNEL_LAYER_INFO_LOGGING_ENABLED 1
    #define PNLOG_COMMUNICATION_CHANNEL_LAYER_WARN_LOGGING_ENABLED 1
    #define PNLOG_CONNECTION_LAYER_ERROR_LOGGING_ENABLED 1
    #define PNLOG_CONNECTION_LAYER_INFO_LOGGING_ENABLED 1
    #define PNLOG_CONNECTION_LAYER_RAW_HTTP_RESPONSE_LOGGING_ENABLED 0
    #define PNLOG_CONNECTION_LAYER_RAW_HTTP_RESPONSE_STORING_ENABLED 0

in [pubnub/libs/PubNub/Misc/PNMacro.h](pubnub/libs/PubNub/Misc/PNMacro.h#L37)

By default, all non-http response logging is enabled to file with a 10MB, single archived file log rotation.

    kPNLogMaximumLogFileSize (10 * 1024 * 1024)
    
In the above, 10 represents the size in MB. Set it to the size you desire.  

** Keep in mind, this file size is only checked/rotated at application start. If it rises above the max size during application run-time, it will not rotate until after the application has been restarted. **

If you choose the PNLOG_STORE_LOG_TO_FILE option, you will find your log written to you app's Document directory as 

```
pubnub-console-dump.txt
```


### Tests with OCUnit and OCMock

Unit-tests integrated in XCode allow the developer to easily start them anytime during development. 

#### Running

1. Choose pubnubTests from Product -> Scheme
2. Run -> Test or Product -> Test or CMD+U

#### Configuring

Unit-tests for each class are grouped by class. To configure the test scheme further:

1. Product -> Scheme -> pubnubTests -> Edit
2. Select the test item from the left menu
3. Select tests to run as wanted from right menu
