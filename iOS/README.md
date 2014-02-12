# PubNub 3.6.0 for iOS 5.1+ (iPhone, iPad, iPod)
Provides iOS ARC support in Objective-C for the [PubNub.com](http://www.pubnub.com/) real-time messaging network.  

All requests made by the client are asynchronous, and are handled by:

1. blocks (via calling method)
2. delegate methods
3. notifications
4. Observation Center

Detailed information on methods, constants, and notifications can be found in the corresponding header files.


## Important Changes from Earlier Versions
### JSONKit
PubNub forked JSONKit and made some enhancements that remove by-default fatal warnings on XCode 5. 

If you find yourself needing to use JSONKit with PubNub, [you should use the PubNub fork of JSONKit](https://github.com/pubnub/JSONKit), not the original.

### 3.5.1
JSONKit support has been refactored so that it will only use JSONKit if your iOS version does not support NSJson.  By default in 3.5.2, JSONKit is not a required library. However, if its found, and its needed, PubNub will use it.

### iPadDemoApp.x

If you were previously using history in iPadDemoApp.x, you will need to convert your **NSDate** parameter types to **PNDate** types, as the history methods now
take PNDate arguments, not NSDate arguments. This is as easy as replacing:

```objc
NSDate *startDate = [NSDate date]; // this is the old way. replace it with:

PNDate *startDate = [PNDate dateWithDate:[NSDate date]]; // Convert from a date
// or
PNDate *startDate = [PNDate dateWithToken:[NSNumber numberWithInt:1234567]; // Convert from a time token
```

Also, there are new files in the library that were not present in iPadDemoApp.x. Be sure when updating the library that you add these new files to your project,
or you will certainly get compile errors for missing files. Easiest thing to do is remove all PubNub files, and add the new PubNub files back.

## Coming Soon... XCode Project Template Support!
But until then...

## Adding PubNub to your project via CocoaPods
**NOTE:** Be sure you are running CocoaPods 0.26.2 or above!

[These steps are documented in our Emmy-winning CocoaPod's Setup Video, check it out here!](https://vimeo.com/69284108)

By far the easiest, quickest way to add PubNub.  **Current PubNub for CocoaPods version is 3.5.3**

+   Create an empty XCode Project
+   Add the following to your project's Podfile:

```
pod 'PubNub', '3.6.0'
```

+   Run

```
pod install
```

+   Open the resulting workspace.
+   Add

```objc
// Make this the FIRST import statement
#import "PNImports.h"
```

To your project's .pch file.  
**Note:** It must be the first import in your pch, or it will not work correctly.

[Finish up by setting up your delegate](#finishing-up-configuration-common-to-manual-and-cocoapods-setup)

## Adding PubNub to your project manually

1. Add the PubNub library folder to your project (/libs/PubNub)  

2. Add PNImports to your project precompile header (.pch)  
```objc
// Make this the FIRST import statement
#import "PNImports.h"
```

Add the following link options:


* CFNetwork.Framework
* SystemConfiguration.Framework
* libz.dylib

 
**NOTE:** The Mac OS X version also requires CoreWLAN.framework.

## Setting up JSONKit for legacy JSON Support
### Only needed when targeting iOS 5.0 and earlier

We provide a special build of JSONKit in the iOS subdirectory (which fixes some default fatal warnings in XCode 5) only to target older versions (5 and earlier) of iOS, which do not support Apples native JSON (NSJson).

PubNub core code is ARC-compliant.  But since JSONKit (which is 3rd party) performs all memory management on it's own (it doesn't support ARC), we'll show you how to remove ARC warnings for it with the -fno-objc-arc setting.

1. Add the [JSONKit support files to your project](JSONKit).

2. Set the -fno-objc-arc compile option for JSON.m and JSONKit.m

## Finishing up configuration (Common to Manual and CocoaPods setup)

1. In AppDelegate.h, adopt the PNDelegate protocol:

```objc
@interface PNAppDelegate : UIResponder <UIApplicationDelegate, PNDelegate>
```

2. In AppDelegate.m, in application:didFinishLaunchingWithOptions: (right before the return YES line works fine), add setDelegate:

```objc
[PubNub setDelegate:self]; 
```

## Start Coding now with PubNub!

If you just can't wait to start using PubNub for iOS (we totally know the feeling), after performing the steps 
from [Adding PubNub to your Project](#adding-pubnub-to-your-project):

## Set config and connect
In your ViewController.m, add this to viewDidLoad():

```objc
[PubNub setConfiguration:[PNConfiguration configurationForOrigin:@"pubsub.pubnub.com" publishKey:@"demo" 
                                                    subscribeKey:@"demo" secretKey:@"mySecret"]];
[PubNub connect];

// Define a channel
PNChannel *channel_1 = [PNChannel channelWithName:@"a" shouldObservePresence:YES];

// Subscribe on the channel
[PubNub subscribeOnChannel:channel_1];

// Publish on the channel
[PubNub sendMessage:@"hello from PubNub iOS!" toChannel:channel_1];
```

2. In your AppDelegate.m, define a didReceiveMessage delegate method:

```objc
- (void)pubnubClient:(PubNub *)client didReceiveMessage:(PNMessage *)message {

   NSLog( @"%@", [NSString stringWithFormat:@"received: %@", message.message] );
}
```

This results in a simple app that displays a PubNub 'Ping' message, published every second from PubNub PHP Bot.    

That was just a quick and dirty demo to cut your teeth on... There are other iOS for PubNub client demo apps available! These demonstrate in more detail how you can use the delegate and completion block features of the PubNub client for iOS.

They include:

### SimpleSubscribe HOWTO

The [SimpleSubscribe](HOWTO/SimpleSubscribe) app references how to create a simple subscribe-only, non-ui application using PubNub and iOS. 
[A getting started walk-through document is also available](https://raw.github.com/pubnub/objective-c/master/iOS/HOWTO/SimpleSubscribe/SimpleSubscribeHOWTO_34.pdf).

This is the most basic example of how to wire it all up, and as such, should take beginners and experts alike about 5-10 minutes to complete.

### Hello World HOWTO

The [Hello World](HOWTO/HelloWorld) app references how to create a simple application using PubNub and iOS. 
[A getting started walk-through document is also available](https://raw.github.com/pubnub/objective-c/master/iOS/HOWTO/HelloWorld/HelloWorldHOWTO_34.pdf).

### CallsWithoutBlocks

The [CallsWithoutBlocks](HOWTO/CallsWithoutBlocks) app references how to use PubNub more procedurally than asynchronously. If you just want to make calls, without much care
for server responses (fire and forget).

### APNSDemo

The [APNSVideo](HOWTO/APNSVideo) app is the companion to the APNS Tutorial Videos -- [Be sure to checkout the APNS API methods before reviewing this video](#apns-methods).
### Deluxe iPad Full Featured Demo

Once you are familiar with the [Hello World](HOWTO) app, The deluxe iPad-only app demonstrates all API functions in greater detail than
the Hello World app. It is intended to be a reference application.

## APNS Setup

If you've enabled your keys for APNS, you can use native PubNub publish operations to send messages to iPhones and iPads via iOS push notifications!

### APNS Video Walkthrough ###

We've just added a video walk-through, along with a sample application (based on the video) that shows from start to
end how to setup APNS with PubNub. It includes all Apple-specific setup (which appears to be the most misunderstood) as
well as the PubNub-specific setup, along with the end product app available in [HOWTO/APNSVideo](HOWTO/APNSVideo).

#### APNS Video HOWTO ####

[0 Review the APNS Methods API](#apns-methods)

Then, watch the following in order:

[1 Creating the App ID and PEM Cert File](https://vimeo.com/67419903)

An easy way to generate the cert/keypair [can be found here](http://code.google.com/p/apns-php/wiki/CertificateCreation#Generate_a_Push_Certificate)

Verify your cert was created correctly by running this command (replace with your key/cert name):
```bash
openssl s_client -connect gateway.sandbox.push.apple.com:2195 -cert server_certificates_bundle_sandbox.pem -key server_certificates_bundle_sandbox.pem
````

[2 Create the Provisioning Profile](https://vimeo.com/67420404)

[3 Create and Configure PubNub Account for APNS](https://vimeo.com/67420596)

[4 Create empty PubNub App Template](https://vimeo.com/67420599)

[5 Configure for PNDelegate Protocol and create didReceiveMessage delegate method](https://vimeo.com/67420597)

[6 Set keys, channel, connect, and subscribe and Test Run](https://vimeo.com/67420598)

[7 Enable and Test for correct APNS configuration (Apple Config)](https://vimeo.com/67423576)

[8 Provision PubNub APNS](https://vimeo.com/67423577)

Two files referenced from the video, [generateAPNSPemKey.sh](generateAPNSPemKey.sh) and [verifyCertWithApple.sh](verifyCertWithApple.sh) are also available 

Final product is available here: [HOWTO/APNSVideo](HOWTO/APNSVideo)

## Client configuration

You can test-drive the PubNub client out-of-the-box without additional configuration changes. As you get a feel for it, you can fine tune it's behavior by tweaking the available settings.

The client is configured via an instance of the [__PNConfiguration__](iPadDemoApp/pubnub/libs/PubNub/Data/PNConfiguration.h) class. All default configuration data is stored in [__PNDefaultConfiguration.h__](iPadDemoApp/pubnub/libs/PubNub/Misc/PNDefaultConfiguration.h) under appropriate keys.  

Data from [__PNDefaultConfiguration.h__](iPadDemoApp/pubnub/libs/PubNub/Misc/PNDefaultConfiguration.h) override any settings not explicitly set during initialization.  

You can use few class methods to intialise and update instance properties:  

1. Retrieve reference on default client configuration (all values taken from [__PNDefaultConfiguration.h__](iPadDemoApp/pubnub/libs/PubNub/Misc/PNDefaultConfiguration.h))  

```objc
+ (PNConfiguration *)defaultConfiguration;  
```
  
2. Retrieve the reference on the configuration instance via these methods:  

```objc
+ (PNConfiguration *)configurationWithPublishKey:(NSString *)publishKey subscribeKey:(NSString *)subscribeKey  
                                       secretKey:(NSString *)secretKey;
+ (PNConfiguration *)configurationWithPublishKey:(NSString *)publishKey subscribeKey:(NSString *)subscribeKey  
                                       secretKey:(NSString *)secretKey authorizationKey:(NSString *)authorizationKey;  

+ (PNConfiguration *)configurationForOrigin:(NSString *)originHostName publishKey:(NSString *)publishKey
                               subscribeKey:(NSString *)subscribeKey secretKey:(NSString *)secretKey;
+ (PNConfiguration *)configurationForOrigin:(NSString *)originHostName publishKey:(NSString *)publishKey
                               subscribeKey:(NSString *)subscribeKey secretKey:(NSString *)secretKey
                           authorizationKey:(NSString *)authorizationKey;

+ (PNConfiguration *)configurationForOrigin:(NSString *)originHostName publishKey:(NSString *)publishKey  
                               subscribeKey:(NSString *)subscribeKey secretKey:(NSString *)secretKey  
                                  cipherKey:(NSString *)cipherKey;  // To initialize with encryption, use cipherKey
+ (PNConfiguration *)configurationForOrigin:(NSString *)originHostName publishKey:(NSString *)publishKey  
                               subscribeKey:(NSString *)subscribeKey secretKey:(NSString *)secretKey  
                                  cipherKey:(NSString *)cipherKey  // To initialize with encryption, use cipherKey
                           authorizationKey:(NSString *)authorizationKey;
```

3. Update the configuration instance using this next set of parameters:  

    1. Timeout after which the library will report any ***non-subscription-related*** request (here now, leave, message history, message post, time token) or execution failure.  
        ```objc
        nonSubscriptionRequestTimeout  
        ```
        __Default:__ 15 seconds (_kPNNonSubscriptionRequestTimeout_ key in [__PNDefaultConfiguration.h__](iPadDemoApp/pubnub/libs/PubNub/Misc/PNDefaultConfiguration.h))   

    2.  Timeout after which the library will report ***subscription-related*** request (subscribe on channel(s)) execution failure.
        The default configuration value is stored inside [__PNDefaultConfiguration.h__](iPadDemoApp/pubnub/libs/PubNub/Misc/PNDefaultConfiguration.h) under __kPNSubscriptionRequestTimeout__ key.
        ```objc
        subscriptionRequestTimeout  
        ```
        __Default:__ 310 seconds (_kPNSubscriptionRequestTimeout_ key in [__PNDefaultConfiguration.h__](iPadDemoApp/pubnub/libs/PubNub/Misc/PNDefaultConfiguration.h))
        ***Please consult with PubNub support before setting this value lower than the default to avoid incurring additional charges.***
    
    3. Client will pass this value during subscription to inform it after which period of inactivity (when client will stop send ping to the server) it should mark client and __timed out__.
        ```objc
        presenceExpirationTimeout // DEPRECATED
        ```
        ```objc
        presenceHeartbeatTimeout
        ```
        __Default:__ 0 seconds (_kPNPresenceHeartbeatTimeout_ key in [__PNDefaultConfiguration.h__](iPadDemoApp/pubnub/libs/PubNub/Misc/PNDefaultConfiguration.h)) which will force server to use it's own timeout value.
    
    4. Used by client as heartbeat requests rate (interval for scheduling next request). This value should be less then **300** seconds and less then **presenceExpirationTimeout** value, or it will be automatically adjusted.
        ```objc
        presenceHeartbeatInterval
        ```
        __Default:__ 0 seconds (_kPNPresenceHeartbeatInterval_ key in [__PNDefaultConfiguration.h__](iPadDemoApp/pubnub/libs/PubNub/Misc/PNDefaultConfiguration.h)) but it will be adjusted as soon as **presenceExpirationTimeout** will be changed.

    5. After experiencing network connectivity loss, if network access is restored, should the client reconnect to PubNub, or stay disconnected?
        ```objc
        (getter = shouldAutoReconnectClient) autoReconnectClient  
        ```
        __Default:__ YES (_kPNShouldAutoReconnectClient_ key in [__PNDefaultConfiguration.h__](iPadDemoApp/pubnub/libs/PubNub/Misc/PNDefaultConfiguration.h))  
         
        This can also be controlled via returning __@(YES)__ or __@(NO)__ via the __shouldReconnectPubNubClient:__ delegate.
    
    6. If autoReconnectClient == YES, after experiencing network connectivity loss and subsequent reconnect, should the client resume (aka  "catchup") to where it left off before the disconnect?
        ```objc
        (getter = shouldResubscribeOnConnectionRestore) resubscribeOnConnectionRestore
        ```
        __Default:__ YES (_kPNShouldResubscribeOnConnectionRestore_ key in [__PNDefaultConfiguration.h__](iPadDemoApp/pubnub/libs/PubNub/Misc/PNDefaultConfiguration.h))  
         
        This can also be controlled via returning __@(YES)__ or __@(NO)__ via the __shouldResubscribeOnConnectionRestore__ delegate.
    
    7. Upon connection restore, should the PubNub client "catch-up" to where it left off upon reconnecting?
        ```objc
        (getter = shouldRestoreSubscriptionFromLastTimeToken) restoreSubscriptionFromLastTimeToken
        ```
         __Default:__ YES (_kPNShouldRestoreSubscriptionFromLastTimeToken key in [__PNDefaultConfiguration.h__](iPadDemoApp/pubnub/libs/PubNub/Misc/PNDefaultConfiguration.h))
         
         This can also be controlled via returning __@(YES)__ or __@(NO)__ via the __shouldRestoreSubscriptionFromLastTimeToken__ delegate.

    8. Should the PubNub client establish the connection to PubNub using SSL?
        ```objc
        (getter = shouldUseSecureConnection) useSecureConnection  
        ```
        __Default:__ YES (_kPNSecureConnectionRequired__ key in [__PNDefaultConfiguration.h__](iPadDemoApp/pubnub/libs/PubNub/Misc/PNDefaultConfiguration.h))  
    
    9. When SSL is enabled, should PubNub client ignore all SSL certificate-handshake issues and still continue in SSL mode if it experiences issues handshaking across local proxies, firewalls, etc?
        ```objc
        (getter = shouldReduceSecurityLevelOnError) reduceSecurityLevelOnError
        ```
        __Default:__ YES (_kPNShouldReduceSecurityLevelOnError_ key in [__PNDefaultConfiguration.h__](iPadDemoApp/pubnub/libs/PubNub/Misc/PNDefaultConfiguration.h))  
    
    10. When SSL is enabled, should the client fallback to a non-SSL connection if it experiences issues handshaking across local proxies, firewalls, etc?
        ```objc
        (getter = canIgnoreSecureConnectionRequirement) ignoreSecureConnectionRequirement
        ```
        __Default:__ YES (_kPNCanIgnoreSecureConnectionRequirement_ key in [__PNDefaultConfiguration.h__](iPadDemoApp/pubnub/libs/PubNub/Misc/PNDefaultConfiguration.h))  
    
    11. To reduce incoming traffic client can be configured to accept compressed responses from server and this property specify on whether it should do so or not?  
        ```objc
        (getter = shouldAcceptCompressedResponse) acceptCompressedResponse
        ```
        __Default:__ YES (_kPNShouldAcceptCompressedResponse_ key in [__PNDefaultConfiguration.h__](iPadDemoApp/pubnub/libs/PubNub/Misc/PNDefaultConfiguration.h))  

    12. When this value is set client will enable encryption on published and received messages.
        ```objc
        cipherKey
        ```
        __Default:__ nil (_kPNCipherKey_ key in [__PNDefaultConfiguration.h__](iPadDemoApp/pubnub/libs/PubNub/Misc/PNDefaultConfiguration.h))  

    13. If client should work with PAM it should be configured with appropriate authorization key which will be used by PAM for access management.
        ```objc
        authorizationKey
        ```
        __Default:__ nil (_kPNAuthorizationKey_ key in [__PNDefaultConfiguration.h__](iPadDemoApp/pubnub/libs/PubNub/Misc/PNDefaultConfiguration.h))  
  
***NOTE: If you are using the `+defaultConfiguration` method to create your configuration instance, then you will need to update:  _kPNPublishKey_, _kPNSubscriptionKey_ and _kPNOriginHost_ keys in [__PNDefaultConfiguration.h__](iPadDemoApp/pubnub/libs/PubNub/Misc/PNDefaultConfiguration.h).***
  
PubNub client configuration is then set via:
```objc
[PubNub setConfiguration:[PNConfiguration defaultConfiguration]];  
```

After this call, your PubNub client will be configured with the default values taken from [__PNDefaultConfiguration.h__](iPadDemoApp/pubnub/libs/PubNub/Misc/PNDefaultConfiguration.h) and is now ready to connect to the PubNub real-time network!
  
Other methods which allow you to adjust the client configuration are:  
```objc
+ (void)setConfiguration:(PNConfiguration *)configuration;  
+ (void)setupWithConfiguration:(PNConfiguration *)configuration andDelegate:(id<PNDelegate>)delegate;  
+ (void)setDelegate:(id<PNDelegate>)delegate;
+ (void)setClientIdentifier:(NSString *)identifier;  
+ (void)setClientIdentifier:(NSString *)identifier shouldCatchup:(BOOL)shouldCatchup;
```

FIrst and the second methods from list above (which update client configuration) may require client reconnection (if client already connected). As soon as all connections will be closed client will reconnect with updated configuration. It is strongly advised change configuration in really rare cases and most of the time provide configuration during PubNub client configuration. Configuration update on connected client will cause additional overhead to reinitialize client with new configuration and connect back to server (time overhead).

Changing the UUID mid-connection requires a "__soft state reset__".  A "__soft state reset__" is when the client sends an explicit `leave` request on any subscribed channels, and then resubscribes with its new UUID.

**NOTE:** If you wish to change the client identifier, then catchup in time where you left-off before you changed client identifier, use:
```objc
[PubNub setClientIdentifier:@"moonlight" shouldCatchup:YES];
```     
To access the client configuration and state, the following methods are provided:  
```objc
+ (PubNub *)sharedInstance;  
+ (PNConfiguration *)configuration;
+ (NSString *)clientIdentifier;  
+ (NSArray *)subscribedChannels;  
   
+ (BOOL)isSubscribedOnChannel:(PNChannel *)channel;  
+ (BOOL)isPresenceObservationEnabledForChannel:(PNChannel *)channel;  

- (BOOL)isConnected;  
```

Second method from the list above allow to retrieve reference on configuration which is currently used by client. It will return copy of [__PNConfiguration__](iPadDemoApp/pubnub/libs/PubNub/Data/PNConfiguration.h) instance and any changes in it won't take any effect till it explicitly will be set to the client (`+setConfiguration:` or `+setupWithConfiguration:andDelegate:`)


### Determining Connection State
You can easily determine the current PubNub connection state via:
```objc
[[PNObservationCenter defaultCenter] addClientConnectionStateObserver:self
                                                    withCallbackBlock:^(NSString *origin, BOOL connected, PNError *error) {
  if (connectionError) {

    // Handle connection error which occurred during connection or while client was connected. Error also can be sent 
    // by PubNub client if you tried to connect while already connected 
    // or just launched connection.
    //
    // Always check error.code to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
    // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
  }
  else if (!isConnected) {

    if (error == nil) {

      // Looks like there is no Internet connection at the moment when this method has been called or PubNub client doesn't 
      // have enough time to validate its availability.
      //
      // In this case connection will be established automatically as soon as Internet connection will be detected.
    }
    else {
      
      // Client has been disconnected by request.
    }
  }
  else {

    // We are connected and ready to go.
  }
}];
```
```objc
if ([PubNub sharedInstance].isConnected) {

  // We are connected and ready to go.
}
```

Note, that just because your network is up, does not mean your connection to PubNub is up, so be sure to use this logic for authoritative PubNub connection state status.

### Encryption Notes

This client supports the PubNub AES Encryption standard, which enables this client to speak with all other PubNub iPadDemoApp+ clients securely via AES.

When encryption is enabled, non-encrypted messages, or messages encrypted with the wrong key will be passed through as the string "**DECRYPTION_ERROR**".

To initialize with encryption enabled:
```objc
+ (PNConfiguration *)configurationForOrigin:(NSString *)originHostName publishKey:(NSString *)publishKey  
                               subscribeKey:(NSString *)subscribeKey secretKey:(NSString *)secretKey  
                                  cipherKey:(NSString *)cipherKey;  // To initialize with encryption, use cipherKey
+ (PNConfiguration *)configurationForOrigin:(NSString *)originHostName publishKey:(NSString *)publishKey  
                               subscribeKey:(NSString *)subscribeKey secretKey:(NSString *)secretKey  
                                  cipherKey:(NSString *)cipherKey  // To initialize with encryption, use cipherKey
                           authorizationKey:(NSString *)authorizationKey;
```

To dynamically change the encryption key during runtime, you can run 
```objc
[myConfiguration setCipherKey:@"myCipherKey"];
[PubNub setConfiguration:myConfiguration];
```

To enable backwards compatibility with PubNub iOS 3.3, add this line to your .pch:

```objc
#define CRYPTO_BACKWARD_COMPATIBILITY_MODE 1
```

The above directive will allow this current PubNub iOS client to speak **ONLY** with earlier PubNub iOS 3.3 clients.

It is advised for security and network/battery/power considerations to upgrade all clients to iPadDemoApp+ encryption as soon as possible, and to only use this backward compatibility mode if absolutely necessary.

#### Encrypt / Descrypt Methods

If you wish to manually utilize the encryption logic for your own purposes (decrypt messages sent via PubNub from APNS for example), the following public methods can be used:

```objc
/**
 * Cryptographic function which allow to decrypt AES hash stored inside 'base64' string and return object.
 */
+ (id)AESDecrypt:(id)object;
+ (id)AESDecrypt:(id)object error:(PNError **)decryptionError;

/**
 * Cryptographic function which allow to encrypt object into 'base64' string using AES and return hash string.
 */
+ (NSString *)AESEncrypt:(id)object;
+ (NSString *)AESEncrypt:(id)object error:(PNError **)encryptionError;
```


## PubNub client methods  

### Connecting and Disconnecting from the PubNub Network

You can use the callback-less connection methods `+connect` to establish a connection to the remote PubNub service, or the method with state callback blocks `+connectWithSuccessBlock:errorBlock:`.  

For example, you can use the provided method in the form that best suits your needs:
```objc
// Configure client (we will use client generated identifier)  
[PubNub setConfiguration:[PNConfiguration defaultConfiguration]];  

[PubNub connect];
```

or
```objc
// Configure client  
[PubNub setConfiguration:[PNConfiguration defaultConfiguration]];
[PubNub setClientIdentifier:@"test_user"];  

[PubNub connectWithSuccessBlock:^(NSString *origin) {  

                         // Do something after client connected  
                     } 
                      errorBlock:^(PNError *error) {

                        if (error == nil) {

                          // Looks like there is no Internet connection at the moment when this method has been 
                          // called or PubNub client doesn't have enough time to validate its availability.
                          //
                          // In this case connection will be established automatically as soon as Internet connection 
                          // will be detected.
                        }
                        else {

                          // Happened something really bad and PubNub client can't establish connection, so we should 
                          // update our interface to let user know and do something to recover from this situation.
                          //
                          // Error also can be sent by PubNub client if you tried to connect while already connected 
                          /// or just launched connection.
                          //
                          // Always check error.code to find out what caused error (check PNErrorCodes header
                          // file and use 
                          // -localizedDescription / -localizedFailureReason and -localizedRecoverySuggestion
                          // to get human readable description for error).
                        }
                     }];
```
                                          
Disconnecting is as simple as calling `[PubNub disconnect]`.  The client will close the connection and clean up memory.

### Channels representation  

The client uses the [__PNChannel__](iPadDemoApp/pubnub/libs/PubNub/Data/Channels/PNChannel.h) instance instead of string literals to identify the channel. When you need to send a message to the channel, specify the corresponding [__PNChannel__](iPadDemoApp/pubnub/libs/PubNub/Data/Channels/PNChannel.h) instance in the message sending methods.  

The [__PNChannel__](iPadDemoApp/pubnub/libs/PubNub/Data/Channels/PNChannel.h) interface provides methods for channel instantiation (instance is only created if it doesn't already exist):  
```objc
+ (NSArray *)channelsWithNames:(NSArray *)channelsName;  
+ (id)channelWithName:(NSString *)channelName;  
+ (id)channelWithName:(NSString *)channelName shouldObservePresence:(BOOL)observePresence;
```
You can use the first method if you want to receive a set of [__PNChannel__](iPadDemoApp/pubnub/libs/PubNub/Data/Channels/PNChannel.h) instances from the list of channel identifiers. The `observePresence` property is used to set whether or not the client should observe presence events on the specified channel.

As for the channel name, you can use any characters you want except ',' and '/', as they are reserved.

The [__PNChannel__](iPadDemoApp/pubnub/libs/PubNub/Data/Channels/PNChannel.h) instance can provide information about itself:  
    
* `name` - channel name  
* `updateTimeToken` - time token of last update on this channel  
* `presenceUpdateDate` - date when last presence update arrived to this channel  
* `participantsCount` - number of participants in this channel
* `participants` - list of participant UUIDs  
  
For example, to receive a reference on a list of channel instances:  
```objc
NSArray *channels = [PNChannel channelsWithNames:@[@"iosdev", @"andoirddev", @"wpdev", @"ubuntudev"]];
```

### Subscribing and Unsubscribing from Channels

The client provides a set of methods which allow you to subscribe to channel(s):  
```objc
+ (void)subscribeOnChannel:(PNChannel *)channel;  
+ (void) subscribeOnChannel:(PNChannel *)channel 
withCompletionHandlingBlock:(PNClientChannelSubscriptionHandlerBlock)handlerBlock;  
+ (void)subscribeOnChannel:(PNChannel *)channel withMetadata:(NSDictionary *)clientMetadata; // DEPRECATED
+ (void)subscribeOnChannel:(PNChannel *)channel withClientState:(NSDictionary *)clientState;
+ (void) subscribeOnChannel:(PNChannel *)channel withMetadata:(NSDictionary *)clientMetadata
 andCompletionHandlingBlock:(PNClientChannelSubscriptionHandlerBlock)handlerBlock; // DEPRECATED
+ (void) subscribeOnChannel:(PNChannel *)channel withClientState:(NSDictionary *)clientState
 andCompletionHandlingBlock:(PNClientChannelSubscriptionHandlerBlock)handlerBlock;

+ (void)subscribeOnChannel:(PNChannel *)channel withPresenceEvent:(BOOL)withPresenceEvent;
+ (void)subscribeOnChannel:(PNChannel *)channel withPresenceEvent:(BOOL)withPresenceEvent  
andCompletionHandlingBlock:(PNClientChannelSubscriptionHandlerBlock)handlerBlock;  
+ (void)subscribeOnChannel:(PNChannel *)channel withPresenceEvent:(BOOL)withPresenceEvent 
                  metadata:(NSDictionary *)clientMetadata; // DEPRECATED
+ (void)subscribeOnChannel:(PNChannel *)channel withPresenceEvent:(BOOL)withPresenceEvent 
                  clientState:(NSDictionary *)clientState;
+ (void) subscribeOnChannel:(PNChannel *)channel withPresenceEvent:(BOOL)withPresenceEvent 
                   metadata:(NSDictionary *)clientMetadata
 andCompletionHandlingBlock:(PNClientChannelSubscriptionHandlerBlock)handlerBlock; // DEPRECATED
 + (void) subscribeOnChannel:(PNChannel *)channel withPresenceEvent:(BOOL)withPresenceEvent 
                   clientState:(NSDictionary *)clientState
 andCompletionHandlingBlock:(PNClientChannelSubscriptionHandlerBlock)handlerBlock;

+ (void)subscribeOnChannels:(NSArray *)channels;  
+ (void)subscribeOnChannels:(NSArray *)channels  
withCompletionHandlingBlock:(PNClientChannelSubscriptionHandlerBlock)handlerBlock;  
+ (void)subscribeOnChannels:(NSArray *)channels withMetadata:(NSDictionary *)clientMetadata; // DEPRECATED
+ (void)subscribeOnChannels:(NSArray *)channels withClientState:(NSDictionary *)clientState;
+ (void)subscribeOnChannels:(NSArray *)channels withMetadata:(NSDictionary *)clientMetadata
 andCompletionHandlingBlock:(PNClientChannelSubscriptionHandlerBlock)handlerBlock; // DEPRECATED
+ (void)subscribeOnChannels:(NSArray *)channels withClientState:(NSDictionary *)clientState
 andCompletionHandlingBlock:(PNClientChannelSubscriptionHandlerBlock)handlerBlock;

+ (void)subscribeOnChannels:(NSArray *)channels withPresenceEvent:(BOOL)withPresenceEvent;  
+ (void)subscribeOnChannels:(NSArray *)channels withPresenceEvent:(BOOL)withPresenceEvent  
 andCompletionHandlingBlock:(PNClientChannelSubscriptionHandlerBlock)handlerBlock;
+ (void)subscribeOnChannels:(NSArray *)channels withPresenceEvent:(BOOL)withPresenceEvent 
                   metadata:(NSDictionary *)clientMetadata; // DEPRECATED
+ (void)subscribeOnChannels:(NSArray *)channels withPresenceEvent:(BOOL)withPresenceEvent 
                clientState:(NSDictionary *)clientState;
+ (void)subscribeOnChannels:(NSArray *)channels withPresenceEvent:(BOOL)withPresenceEvent 
                   metadata:(NSDictionary *)clientMetadata
 andCompletionHandlingBlock:(PNClientChannelSubscriptionHandlerBlock)handlerBlock; // DEPRECATED
+ (void)subscribeOnChannels:(NSArray *)channels withPresenceEvent:(BOOL)withPresenceEvent 
                clientState:(NSDictionary *)clientState
 andCompletionHandlingBlock:(PNClientChannelSubscriptionHandlerBlock)handlerBlock;
```
Each subscription method has designated methods, to add a presence flag, client state and/or add a handling block.  If `withPresenceEvent` is set to `YES`, the client will will gracefully `leave` channels on which it has been subscribed before and `join` to the new one.

**NOTE: Values remain bound to the client while it subscribed at specific channel. As soon as you will unsubscribe or subscribe to another set of channels enabling presence event generation or client will timeout, server will destroy stored client's state.**  

PubNub client also provide methods to exam channels on which it is subscribed at this moment:
```objc
+ (NSArray *)subscribedChannels;
+ (BOOL)isSubscribedOnChannel:(PNChannel *)channel;
```

Here are some subscribe examples:
```objc
// Subscribe to channels: "iosdev" and because shouldObservePresence is true,
// also automatically subscribes to "iosdev-pnpres" (the Presence channel for "iosdev").
// Because 'withPresenceEvent' for subscribe request is set to 'YES', all other subscribers on "iosdev"
// channel will receive event that new client joined to the channel.
[PubNub subscribeOnChannel:[PNChannel channelWithName:@"iosdev" shouldObservePresence:YES]];  

// Subscribe on set of channels with subscription state handling block
[PubNub subscribeOnChannels:[PNChannel channelsWithName:@"iosdev" shouldObservePresence:YES] withPresenceEvent:YES
 andCompletionHandlingBlock:^(PNSubscriptionProcessState state, NSArray *channels, PNError *subscriptionError) {  
    
    switch(state) {  
    
      case PNSubscriptionProcessNotSubscribedState:  

            // There should be a reason because of which subscription failed and it can be found in 'error' instance.
            //
            // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use 
            // -localizedDescription / -localizedFailureReason and -localizedRecoverySuggestion to get human readable 
            // description for error).'error.associatedObject' contains array of PNChannel instances on which PubNub client
            // was unable to subscribe.
          break;  
      case PNSubscriptionProcessSubscribedState:  
      
          // PubNub client completed subscription on specified set of channels.
          break;  
    }  
}];
```
  
```objc
// Subscribe to channels: "iosdev" and because shouldObservePresence is true,
// also automatically subscribes to "iosdev-pnpres" (the Presence channel for "iosdev").
// Because 'withPresenceEvent' for subscribe request is set to 'YES', all other subscribers on "iosdev"
// channel will receive event that new client joined to the channel and also provide state which has
// been passed to the subscribe methods to all subscribers.
[PubNub subscribeOnChannel:[PNChannel channelWithName:@"iosdev" shouldObservePresence:YES]];  

// Subscribe on set of channels with subscription state handling block
[PubNub subscribeOnChannels:[PNChannel channelsWithName:@"iosdev" shouldObservePresence:YES] withPresenceEvent:YES
    clientState:@{@"iosdev": {@"firstName":@"John", @"lastName":@"Appleseed", @"age":@(240)}}
 andCompletionHandlingBlock:^(PNSubscriptionProcessState state, NSArray *channels, PNError *subscriptionError) {  
    
    switch(state) {  
    
      case PNSubscriptionProcessNotSubscribedState:  

            // There should be a reason because of which subscription failed and it can be found in 'error' instance.
            //
            // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use 
            // -localizedDescription / -localizedFailureReason and -localizedRecoverySuggestion to get human readable 
            // description for error).'error.associatedObject' contains array of PNChannel instances on which PubNub client
            // was unable to subscribe.
          break;  
      case PNSubscriptionProcessSubscribedState:  
      
          // PubNub client completed subscription on specified set of channels.
          break;  
    }  
}
}];
```

The client of course also provides a set of methods which allow you to unsubscribe from channels:  
```objc
+ (void)unsubscribeFromChannel:(PNChannel *)channel;  
+ (void)unsubscribeFromChannel:(PNChannel *)channel  
   withCompletionHandlingBlock:(PNClientChannelUnsubscriptionHandlerBlock)handlerBlock;  
   
+ (void)unsubscribeFromChannel:(PNChannel *)channel withPresenceEvent:(BOOL)withPresenceEvent;  
+ (void)unsubscribeFromChannel:(PNChannel *)channel withPresenceEvent:(BOOL)withPresenceEvent  
    andCompletionHandlingBlock:(PNClientChannelUnsubscriptionHandlerBlock)handlerBlock;  
    
+ (void)unsubscribeFromChannels:(NSArray *)channels;  
+ (void)unsubscribeFromChannels:(NSArray *)channels  
  withCompletionHandlingBlock:(PNClientChannelUnsubscriptionHandlerBlock)handlerBlock;  
  
+ (void)unsubscribeFromChannels:(NSArray *)channels withPresenceEvent:(BOOL)withPresenceEvent;  
+ (void)unsubscribeFromChannels:(NSArray *)channels withPresenceEvent:(BOOL)withPresenceEvent  
     andCompletionHandlingBlock:(PNClientChannelUnsubscriptionHandlerBlock)handlerBlock;
```
	     
As for the unsubscription methods, there are a set of methods which perform unsubscribe requests. The `withPresenceEvent` parameter set to `YES` when unsubscribing will mean that the client will send a `leave` message to channels when unsubscribed.

Lets see how we can use some of this methods to unsubscribe from channel(s):
```objc
// Unsubscribe from set of channels and notify everyone that we are left
[PubNub unsubscribeFromChannels:[PNChannel channelsWithNames:@[@"iosdev/networking", @"andoirddev", @"wpdev", @"ubuntudev"]]
              withPresenceEvent:YES   
     andCompletionHandlingBlock:^(NSArray *channels, PNError *unsubscribeError) {  
    
      if (error == nil) {
 
        // PubNub client successfully unsubscribed from specified channels.
      }
      else {

        // PubNub did fail to unsubscribed from specified channels and reason can be found in error instance.
        //
        // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use 
        // -localizedDescription / -localizedFailureReason and -localizedRecoverySuggestion to get human readable 
        // description for error). 'error.associatedObject' contains array of PNChannel instances from which PubNub client
        // was unable to unsubscribe.
      }
    }];
```

### Presence

If you've enabled the Presence feature for your account, then the client can be used to also receive real-time updates about a particual UUID's presence events, such as join, leave, and timeout.  

To use the Presence feature in your app, the follow methods are provided:
```objc
+ (BOOL)isPresenceObservationEnabledForChannel:(PNChannel *)channel;
+ (void)enablePresenceObservationForChannel:(PNChannel *)channel;
+ (void)enablePresenceObservationForChannel:(PNChannel *)channel 
                withCompletionHandlingBlock:(PNClientPresenceEnableHandlingBlock)handlerBlock;
+ (void)enablePresenceObservationForChannels:(NSArray *)channels;
+ (void)enablePresenceObservationForChannels:(NSArray *)channels 
                 withCompletionHandlingBlock:(PNClientPresenceEnableHandlingBlock)handlerBlock;
+ (void)disablePresenceObservationForChannel:(PNChannel *)channel;  
+ (void)disablePresenceObservationForChannel:(PNChannel *)channel 
                 withCompletionHandlingBlock:(PNClientPresenceDisableHandlingBlock)handlerBlock;
+ (void)disablePresenceObservationForChannels:(NSArray *)channels;
+ (void)disablePresenceObservationForChannels:(NSArray *)channels 
                  withCompletionHandlingBlock:(PNClientPresenceDisableHandlingBlock)handlerBlock;
```
    
### Who is "Here Now" ?

As Presence provides a way to receive occupancy information in real-time, the ***Here Now*** feature allows you enumerate current channel occupancy information on-demand.

There is a set of methods which provide you access to the presence data:
```objc
+ (void)requestParticipantsList;
+ (void)requestParticipantsListWithCompletionBlock:(PNClientParticipantsHandlingBlock)handleBlock;
+ (void)requestParticipantsListWithClientIdentifiers:(BOOL)isClientIdentifiersRequired;
+ (void)requestParticipantsListWithClientIdentifiers:(BOOL)isClientIdentifiersRequired
                                  andCompletionBlock:(PNClientParticipantsHandlingBlock)handleBlock;
+ (void)requestParticipantsListWithClientIdentifiers:(BOOL)isClientIdentifiersRequired 
                                      clientMetadata:(BOOL)shouldFetchClientMetadata; // DEPRECATED
+ (void)requestParticipantsListWithClientIdentifiers:(BOOL)isClientIdentifiersRequired
                                         clientState:(BOOL)shouldFetchClientState;
+ (void)requestParticipantsListWithClientIdentifiers:(BOOL)isClientIdentifiersRequired
                                      clientMetadata:(BOOL)shouldFetchClientMetadata
                                  andCompletionBlock:(PNClientParticipantsHandlingBlock)handleBlock; // DEPRECATED
+ (void)requestParticipantsListWithClientIdentifiers:(BOOL)isClientIdentifiersRequired
                                         clientState:(BOOL)shouldFetchClientState
                                  andCompletionBlock:(PNClientParticipantsHandlingBlock)handleBlock;

+ (void)requestParticipantsListForChannel:(PNChannel *)channel;  
+ (void)requestParticipantsListForChannel:(PNChannel *)channel  
                      withCompletionBlock:(PNClientParticipantsHandlingBlock)handleBlock;  
+ (void)requestParticipantsListForChannel:(PNChannel *)channel 
+               clientIdentifiersRequired:(BOOL)isClientIdentifiersRequired;
+ (void)requestParticipantsListForChannel:(PNChannel *)channel 
                clientIdentifiersRequired:(BOOL)isClientIdentifiersRequired
                      withCompletionBlock:(PNClientParticipantsHandlingBlock)handleBlock;
+ (void)requestParticipantsListForChannel:(PNChannel *)channel
                clientIdentifiersRequired:(BOOL)isClientIdentifiersRequired
                           clientMetadata:(BOOL)shouldFetchClientMetadata; // DEPRECATED
+ (void)requestParticipantsListForChannel:(PNChannel *)channel clientIdentifiersRequired:(BOOL)isClientIdentifiersRequired
                              clientState:(BOOL)shouldFetchClientState;
+ (void)requestParticipantsListForChannel:(PNChannel *)channel
                clientIdentifiersRequired:(BOOL)isClientIdentifiersRequired
                           clientMetadata:(BOOL)shouldFetchClientMetadata   
                      withCompletionBlock:(PNClientParticipantsHandlingBlock)handleBlock; // DEPRECATED
+ (void)requestParticipantsListForChannel:(PNChannel *)channel clientIdentifiersRequired:(BOOL)isClientIdentifiersRequired
                              clientState:(BOOL)shouldFetchClientState
                      withCompletionBlock:(PNClientParticipantsHandlingBlock)handleBlock;

+ (void)requestParticipantChannelsList:(NSString *)clientIdentifier;
+ (void)requestParticipantChannelsList:(NSString *)clientIdentifier
                   withCompletionBlock:(PNClientParticipantChannelsHandlingBlock)handleBlock;
```
Example:  
```objc
[PubNub requestParticipantsListForChannel:[PNChannel channelWithName:@"iosdev"]  
                      withCompletionBlock:^(NSArray *udids, PNChannel *channel, PNError *error) {

    if (error == nil) {
        
      // PubNub client successfully retrieved participants list for specified channel. 
    }  
    else {  

      // PubNub did fail to retrieve participants list for specified channel and reason can be found in error instance.
      //
      // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use 
      // -localizedDescription / -localizedFailureReason and -localizedRecoverySuggestion to get human readable 
      // description for error). 'error.associatedObject' contains array of PNChannel instance for which PubNub client
      // was unable to pull out list of participants.
    }  
}];
```
  
`requestParticipantsList` methods "family" can be used to pull out information about how is where globally for your `subscribe` key.  
Each of presence methods allow to specify whether client identifiers required or not (if not, than response will contain list of PNClient instances with **unknown** identifier set). Also methods allow to specify whether client's state should be fetched as well or not.  
All client information now represented with [**PNClinet**](iPadDemoApp/pubnub/libs/PubNub/Data/PNClinet.h).    

### Where Now

This feature allow to pull out full list of subscribers along with information on which channels they subscribed at this moment.

PubNub client provide two methods which allow you receive this information:  
```objc
+ (void)requestParticipantChannelsList:(NSString *)clientIdentifier;
+ (void)requestParticipantChannelsList:(NSString *)clientIdentifier
                   withCompletionBlock:(PNClientParticipantChannelsHandlingBlock)handleBlock;
```

Usage is very simple:  
```objc
[PubNub requestParticipantChannelsList:@"admin" 
                   withCompletionBlock:^(NSString *identifier, NSArray *channels, PNError *error){
    
    if (error == nil) {
        
      // PubNub client successfully retrieved channels list for concrete client identifier.
    }  
    else {  

      // PubNub did fail to retrieve channels list for concrete client identifier and reason can be 
      // found in error instance.
      //
      // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use 
      // -localizedDescription / -localizedFailureReason and -localizedRecoverySuggestion to get human readable 
      // description for error). 'error.associatedObject' contains client identifier for which PubNub client
      // was unable to pullout channels list.
    }  
}];
```
  
All client information now represented with [**PNClinet**](iPadDemoApp/pubnub/libs/PubNub/Data/PNClinet.h).  
**NOTE: Too frequent usage of this API may force server to disable it for you on some period of time. Don't misuse this API.**

### Presence State Data - Setting and Changing it

PubNub client provide endpoints for client's state manipulation. They allow you to get or set / update existing values.  

```objc
+ (void)requestClientMetadata:(NSString *)clientIdentifier forChannel:(PNChannel *)channel; // DEPRECATED
+ (void)requestClientState:(NSString *)clientIdentifier forChannel:(PNChannel *)channel;
+ (void)requestClientMetadata:(NSString *)clientIdentifier forChannel:(PNChannel *)channel
  withCompletionHandlingBlock:(PNClientMetadataRetrieveHandlingBlock)handlerBlock; // DEPRECATED
+ (void) requestClientState:(NSString *)clientIdentifier forChannel:(PNChannel *)channel
withCompletionHandlingBlock:(PNClientStateRetrieveHandlingBlock)handlerBlock;
+ (void)updateClientMetadata:(NSString *)clientIdentifier metadata:(NSDictionary *)clientMetadata
                  forChannel:(PNChannel *)channel; // DEPRECATED
+ (void)updateClientState:(NSString *)clientIdentifier state:(NSDictionary *)clientState
               forChannel:(PNChannel *)channel;
+ (void)updateClientMetadata:(NSString *)clientIdentifier metadata:(NSDictionary *)clientMetadata 
+                 forChannel:(PNChannel *)channel
 withCompletionHandlingBlock:(PNClientMetadataUpdateHandlingBlock)handlerBlock; // DEPRECATED
+ (void)   updateClientState:(NSString *)clientIdentifier state:(NSDictionary *)clientState
                  forChannel:(PNChannel *)channel
 withCompletionHandlingBlock:(PNClientStateUpdateHandlingBlock)handlerBlock;
```
  
#### Example: Set state at subscribe time
This JOIN event will include the state information:
```json
{"action":"join", "timestamp":1391818344, "data":{"appEvent":"demo app started"}, "uuid":"SimpleSubscribe", "occupancy":3}
```
```objc
// Set UUID
[PubNub setClientIdentifier:@"SimpleSubscribe"];

// Set Channel
PNChannel *myChannel = [PNChannel channelWithName:@"zz" shouldObservePresence:YES];

// Subscribe with State at Join Time
[PubNub subscribeOnChannel:myChannel withClientState:@{@"appEvent": @"demo app started"}];
```

#### Example: Modify State post-subscribe time
```objc
[PubNub setupWithConfiguration:[PNConfiguration defaultConfiguration] andDelegate:self];
[PubNub setClientIdentifier:@"demouser"];
[PubNub connect];
[PubNub subscribeOnChannel:[PNChannel channelsWithName:@"iosdev"]
  withCompletionHandlingBlock:^(PNSubscriptionProcessState state, NSArray *channels, PNError *subscriptionError) {
 
      switch (state) {
          case PNSubscriptionProcessNotSubscribedState:

              // There should be a reason because of which subscription failed and it can be found in 'error' instance.
              //
              // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and 
              // use -localizedDescription / -localizedFailureReason and -localizedRecoverySuggestion to get human readable 
              // description for error). 'error.associatedObject' contains array of PNChannel instances on which 
              // PubNub client was unable to subscribe.
              break;
          case PNSubscriptionProcessSubscribedState:

              [PubNub updateClientState:[PubNub clientIdentifier]
                                  state:@{@"firstName": @"John", @"lastName": @"Appleseed", @"age": @(240)}
                             forChannel:((PNClient *)[array lastObject]).channel
             witCompletionHandlingBlock:^(PNClient *updatedClient, PNError *updateError) {

                  if (error == nil) {

                    // PubNub client successfully updated state.
                  }
                  else {

                    // PubNub client did fail to update state.
                    //
                    // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and
                    // use -localizedDescription / -localizedFailureReason and -localizedRecoverySuggestion to get 
                    // human readable description for error). 'error.associatedObject' contains PNClient instance 
                    // for which PubNub client was unable to update state.
                  }
                }];
              }];
              break;
      }
}];
```
  
If you need to remove some value from state dictionary, you can pass `[NSNull null]` for key, which you want to reset.  
Values in state dictionary should be one of: NSNumber (int, float) or NSString.  

**NOTE: Values remain bound to the client while it subscribed at specific channel. As soon as you will unsubscribe or subscribe to another set of channels enabling presence event generation or client will timeout, server will destroy stored client's state.**


### Timetoken

You can fetch the current PubNub time token by using the following methods:  
```objc
+ (void)requestServerTimeToken;  
+ (void)requestServerTimeTokenWithCompletionBlock:(PNClientTimeTokenReceivingCompleteBlock)success;
```
    
Usage is very simple:  
```objc
[PubNub requestServerTimeTokenWithCompletionBlock:^(NSNumber *timeToken, PNError *error) {  
    
    if (error == nil) {
        
      // PubNub client successfully retrieved time token.
    }  
    else {  

      // PubNub did fail to retrieve time token and reason can be found in error instance.
      //
      // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use 
      // -localizedDescription / -localizedFailureReason and -localizedRecoverySuggestion to get human readable 
      // description for error).
    }  
}];
```

### Publishing Messages

Messages can be an instance of one of the following classed: __NSString__, __NSNumber__, __NSArray__, __NSDictionary__, or __NSNull__.  
If you use some other JSON serialization kit or do it by yourself, ensure that JSON comply with all requirements. If JSON string is malformed you will receive corresponding error from remote server.  

You can use the following methods to send messages:  
```objc
+ (PNMessage *)sendMessage:(id)message toChannel:(PNChannel *)channel;   
+ (PNMessage *)sendMessage:(id)message toChannel:(PNChannel *)channel 
+      withCompletionBlock:(PNClientMessageProcessingBlock)success;  
 
+ (void)sendMessage:(PNMessage *)message;  
+ (void)sendMessage:(PNMessage *)message withCompletionBlock:(PNClientMessageProcessingBlock)success;
```

The first two methods return a [__PNMessage__](iPadDemoApp/pubnub/libs/PubNub/Data/PNMessage.h) instance. If there is a need to re-publish this message for any reason, (for example, the publish request timed-out due to lack of Internet connection), it can be passed back to the last two methods to easily re-publish.
```objc
PNMessage *helloMessage = [PubNub sendMessage:@"Hello PubNub" toChannel:[PNChannel channelWithName:@"iosdev"]  
                          withCompletionBlock:^(PNMessageState messageSendingState, id data) {  
                                
  switch (messageSendingState) {  
        
    case PNMessageSending:

      // PubNub client is sending message at this moment. 'data' stores reference on PNMessage instance which is processing 
      // at this moment.
      break;  
    case PNMessageSent:  

      // PubNub client successfully sent message to specified channel. 'data' stores reference on PNMessage instance which
      // has been sent.
      break;  
    case PNMessageSendingError:  

      // PubNub client failed to send message and reason is in 'data' object.

      // PubNub did fail to send message to specified channel and reason can be found in error instance.
      //
      // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use 
      // -localizedDescription / -localizedFailureReason and -localizedRecoverySuggestion to get human readable 
      // description for error). 'error.associatedObject' PNMessage instance which PubNub client
      // was unable to send.
        
      // Retry message sending (but in real world should check error and hanle it)  
      [PubNub sendMessage:helloMessage];  
      break;  
  }  
}];  
```
Here is example how to send __NSDictionary__:
```objc
[PubNub sendMessage:@{@"message":@"Hello from dictionary object"} toChannel:[PNChannel channelWithName:@"iosdev"];  
```
              

### History

If you have enabled the history feature for your account, the following methods can be used to fetch message history:  
```objc
+ (void)requestFullHistoryForChannel:(PNChannel *)channel;  
+ (void)requestFullHistoryForChannel:(PNChannel *)channel 
                 withCompletionBlock:(PNClientHistoryLoadHandlingBlock)handleBlock;

+ (void)requestFullHistoryForChannel:(PNChannel *)channel includingTimeToken:(BOOL)shouldIncludeTimeToken;
+ (void)requestFullHistoryForChannel:(PNChannel *)channel includingTimeToken:(BOOL)shouldIncludeTimeToken
                 withCompletionBlock:(PNClientHistoryLoadHandlingBlock)handleBlock;

+ (void)requestHistoryForChannel:(PNChannel *)channel from:(PNDate *)startDate;
+ (void)requestHistoryForChannel:(PNChannel *)channel from:(PNDate *)startDate 
             withCompletionBlock:(PNClientHistoryLoadHandlingBlock)handleBlock;

+ (void)requestHistoryForChannel:(PNChannel *)channel from:(PNDate *)startDate 
              includingTimeToken:(BOOL)shouldIncludeTimeToken;
+ (void)requestHistoryForChannel:(PNChannel *)channel from:(PNDate *)startDate 
              includingTimeToken:(BOOL)shouldIncludeTimeToken 
              withCompletionBlock:(PNClientHistoryLoadHandlingBlock)handleBlock;

+ (void)requestHistoryForChannel:(PNChannel *)channel from:(PNDate *)startDate to:(PNDate *)endDate;
+ (void)requestHistoryForChannel:(PNChannel *)channel from:(PNDate *)startDate to:(PNDate *)endDate
             withCompletionBlock:(PNClientHistoryLoadHandlingBlock)handleBlock;

+ (void)requestHistoryForChannel:(PNChannel *)channel from:(PNDate *)startDate to:(PNDate *)endDate
              includingTimeToken:(BOOL)shouldIncludeTimeToken;
+ (void)requestHistoryForChannel:(PNChannel *)channel from:(PNDate *)startDate to:(PNDate *)endDate
              includingTimeToken:(BOOL)shouldIncludeTimeToken
             withCompletionBlock:(PNClientHistoryLoadHandlingBlock)handleBlock;

+ (void)requestHistoryForChannel:(PNChannel *)channel from:(PNDate *)startDate limit:(NSUInteger)limit;
+ (void)requestHistoryForChannel:(PNChannel *)channel from:(PNDate *)startDate limit:(NSUInteger)limit
             withCompletionBlock:(PNClientHistoryLoadHandlingBlock)handleBlock;

+ (void)requestHistoryForChannel:(PNChannel *)channel from:(PNDate *)startDate limit:(NSUInteger)limit
              includingTimeToken:(BOOL)shouldIncludeTimeToken;
+ (void)requestHistoryForChannel:(PNChannel *)channel from:(PNDate *)startDate limit:(NSUInteger)limit
              includingTimeToken:(BOOL)shouldIncludeTimeToken
             withCompletionBlock:(PNClientHistoryLoadHandlingBlock)handleBlock;

+ (void)requestHistoryForChannel:(PNChannel *)channel from:(PNDate *)startDate to:(PNDate *)endDate limit:(NSUInteger)limit;
+ (void)requestHistoryForChannel:(PNChannel *)channel from:(PNDate *)startDate to:(PNDate *)endDate limit:(NSUInteger)limit
           withCompletionBlock:(PNClientHistoryLoadHandlingBlock)handleBlock;

+ (void)requestHistoryForChannel:(PNChannel *)channel from:(PNDate *)startDate to:(PNDate *)endDate limit:(NSUInteger)limit
              includingTimeToken:(BOOL)shouldIncludeTimeToken;
+ (void)requestHistoryForChannel:(PNChannel *)channel from:(PNDate *)startDate to:(PNDate *)endDate limit:(NSUInteger)limit
              includingTimeToken:(BOOL)shouldIncludeTimeToken
             withCompletionBlock:(PNClientHistoryLoadHandlingBlock)handleBlock;

+ (void)requestHistoryForChannel:(PNChannel *)channel from:(PNDate *)startDate limit:(NSUInteger)limit 
                  reverseHistory:(BOOL)shouldReverseMessageHistory;
+ (void)requestHistoryForChannel:(PNChannel *)channel from:(PNDate *)startDate limit:(NSUInteger)limit 
                  reverseHistory:(BOOL)shouldReverseMessageHistory
             withCompletionBlock:(PNClientHistoryLoadHandlingBlock)handleBlock;

+ (void)requestHistoryForChannel:(PNChannel *)channel from:(PNDate *)startDate limit:(NSUInteger)limit
                  reverseHistory:(BOOL)shouldReverseMessageHistory includingTimeToken:(BOOL)shouldIncludeTimeToken;
+ (void)requestHistoryForChannel:(PNChannel *)channel from:(PNDate *)startDate limit:(NSUInteger)limit
                  reverseHistory:(BOOL)shouldReverseMessageHistory includingTimeToken:(BOOL)shouldIncludeTimeToken
             withCompletionBlock:(PNClientHistoryLoadHandlingBlock)handleBlock;

+ (void)requestHistoryForChannel:(PNChannel *)channel from:(PNDate *)startDate to:(PNDate *)endDate limit:(NSUInteger)limit
                reverseHistory:(BOOL)shouldReverseMessageHistory;  
+ (void)requestHistoryForChannel:(PNChannel *)channel from:(PNDate *)startDate to:(PNDate *)endDate limit:(NSUInteger)limit
                reverseHistory:(BOOL)shouldReverseMessageHistory  
           withCompletionBlock:(PNClientHistoryLoadHandlingBlock)handleBlock;

+ (void)requestHistoryForChannel:(PNChannel *)channel from:(PNDate *)startDate to:(PNDate *)endDate limit:(NSUInteger)limit
                  reverseHistory:(BOOL)shouldReverseMessageHistory includingTimeToken:(BOOL)shouldIncludeTimeToken;
+ (void)requestHistoryForChannel:(PNChannel *)channel from:(PNDate *)startDate to:(PNDate *)endDate limit:(NSUInteger)limit
                  reverseHistory:(BOOL)shouldReverseMessageHistory includingTimeToken:(BOOL)shouldIncludeTimeToken
             withCompletionBlock:(PNClientHistoryLoadHandlingBlock)handleBlock;
```

The first two methods will receive the full message history for a specified channel.  ***Be careful, this could be a lot of messages, and consequently, a very long process!***
  
If you set **from** or **to** as nil, that argument will be ignored.  For example:
```objc
[PubNub requestHistoryForChannel:myChannel from:nil to:myEndDate limit:100 reverseHistory:YES];
```
the **start** value will be omitted from the server request. Likewise with:
```objc
[PubNub requestHistoryForChannel:myChannel from:myStartDate to:nil limit:100 reverseHistory:YES];
```
the **end** value will be omitted from the server request. Setting both start and end to nil:
```objc
[PubNub requestHistoryForChannel:myChannel from:nil to:nil limit:100 reverseHistory:YES];
```

Will omit both from the server request, thus simply returning the last **[limit]** results from history.

In the following example, we pull history for the `iosdev` channel within the specified time frame, limiting the maximum number of messages returned to 34:
```objc
PNDate *startDate = [PNDate dateWithDate:[NSDate dateWithTimeIntervalSinceNow:(-3600.0f)]];  
PNDate *endDate = [PNDate dateWithDate:[NSDate date]];  
int limit = 34;  
[PubNub requestHistoryForChannel:[PNChannel channelWithName:@"iosdev"] from:startDate to:endDate limit:limit  
                  reverseHistory:NO withCompletionBlock:^(NSArray *messages, PNChannel *channel, 
                                                          PNDate *startDate, PNDate *endDate, PNError *error) {  
                                   
  if (error == nil) {

    // PubNub client successfully retrieved history for channel. 
  }
  else {

      // PubNub did fail to retrieve history for specified channel and reason can be found in error instance.
      //
      // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use 
      // -localizedDescription / -localizedFailureReason and -localizedRecoverySuggestion to get human readable 
      // description for error). 'error.associatedObject' contains PNChannel instance for which PubNub client
      // was unable to receive history.
  }
}];
```

In the following example, we pull all messages from `iosdev` channel history:
```objc
[PubNub requestFullHistoryForChannel:[PNChannel channelWithName:@"iosdev"] includingTimeToken:YES
                 withCompletionBlock:^(NSArray *messages, PNChannel *channel, PNDate *startDate, 
                                       PNDate *endDate, PNError *error) {

  if (error == nil) {

    // PubNub client successfully retrieved history for channel. 
  }
  else {

      // PubNub did fail to retrieve history for specified channel and reason can be found in error instance.
      //
      // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use 
      // -localizedDescription / -localizedFailureReason and -localizedRecoverySuggestion to get human readable 
      // description for error). 'error.associatedObject' contains PNChannel instance for which PubNub client
      // was unable to receive history.
  }
}];
```

## APNS Methods
**Be sure you enabled APNS in your admin under the option "Mobile Push". If you don't, it won't work!**

PubNub provides the ability to send APNS push notifications from any client (iOS, Android, Java, Ruby, etc) using the native PubNub publish() mechanism. APNS push notifications can only be received on supported iOS devices (iPad, iPhone, etc).

Normally, when you publish a message, it stays on the PubNub network, and is only accessible by native PubNub subscribers.  If you want that same message to be received on an iOS device via APNS, you must first associate the PubNub channel with the destination device's device ID (also known as a push token).

To perform this association, use one of the following:
```objc
+ (void)enablePushNotificationsOnChannel:(PNChannel *)channel withDevicePushToken:(NSData *)pushToken;
+ (void)enablePushNotificationsOnChannel:(PNChannel *)channel withDevicePushToken:(NSData *)pushToken
              andCompletionHandlingBlock:(PNClientPushNotificationsEnableHandlingBlock)handlerBlock;
+ (void)enablePushNotificationsOnChannels:(NSArray *)channels withDevicePushToken:(NSData *)pushToken;
+ (void)enablePushNotificationsOnChannels:(NSArray *)channels withDevicePushToken:(NSData *)pushToken
               andCompletionHandlingBlock:(PNClientPushNotificationsEnableHandlingBlock)handlerBlock;
```
To disable this association, use one of the following:
```objc
+ (void)disablePushNotificationsOnChannel:(PNChannel *)channel withDevicePushToken:(NSData *)pushToken;
+ (void)disablePushNotificationsOnChannel:(PNChannel *)channel withDevicePushToken:(NSData *)pushToken
               andCompletionHandlingBlock:(PNClientPushNotificationsDisableHandlingBlock)handlerBlock;
+ (void)disablePushNotificationsOnChannels:(NSArray *)channels withDevicePushToken:(NSData *)pushToken;
+ (void)disablePushNotificationsOnChannels:(NSArray *)channels withDevicePushToken:(NSData *)pushToken
                andCompletionHandlingBlock:(PNClientPushNotificationsDisableHandlingBlock)handlerBlock;
```
You can remove them all, instead of individually using:
```objc
+ (void)removeAllPushNotificationsForDevicePushToken:(NSData *)pushToken
                         withCompletionHandlingBlock:(PNClientPushNotificationsRemoveHandlingBlock)handlerBlock;
```
                         
And to get an active list (audit) of whats currently associated:
```objc
+ (void)requestPushNotificationEnabledChannelsForDevicePushToken:(NSData *)pushToken
                        withCompletionHandlingBlock:(PNClientPushNotificationsEnabledChannelsHandlingBlock)handlerBlock;
```

Check out a working example in the APNS Demo HOWTO app.

### Underlying APNS REST calls

If you ever wanted to directly call the underlying APNS methods directly through REST, here are the endpoints:

#### Add channel(s) for a device
```xhtml
http://pubsub.pubnub.com/v1/push/sub-key/<sub_key>/devices/<device_push_token>?add=channel,channel,...
```

#### Remove channel(s) from a device
```xhtml
http://pubsub.pubnub.com/v1/push/sub-key/<sub_key>/devices/<device_push_token>?remove=channel,channel,...
```

#### Remove device (and all channel subscriptions)
```xhtml
http://pubsub.pubnub.com/v1/push/sub-key/<sub_key>/devices/<device_push_token>/remove
```

#### Get channels for a device
```xhtml
http://pubsub.pubnub.com/v1/push/sub-key/<sub_key>/devices/<device_push_token>
```

### Publish to APNS
**Be sure you enabled APNS in your admin under the option "Mobile Push". If you don't, it won't work!**

To test, publish a string (not an object!) on the associated channel via the web console.  You should receive this string
as an APNS push message on your APNS-enabled app.

If it works, you can publish an object, but it must follow a pre-defined Apple format.  More info on that here -- search for 'Examples of JSON Payloads' at 
[developers.apple.com](https://developer.apple.com/library/mac/documentation/NetworkingInternet/Conceptual/RemoteNotificationsPG/Chapters/ApplePushService.html)

If you wish to publish **an object** (versus a string) to an APNS-enabled channel using another PubNub client, below
we show some examples of how to do this in various languages:

#### Java, BlackBerry, Android, J2ME, Codename One
```java
Pubnub pubnub = new Pubnub("demo","demo");
JSONObject jso = null;

try {
    jso = new JSONObject("{'aps' : {'alert' : 'You got your emails.'," + "'badge' : 9,'sound' : 'bingbong.aiff'}," +
                         "'acme 1': 42}");
    pubnub.publish("my_channel", jso, new Callback(){

        @Override
        public void successCallback(String arg0, Object arg1) {
            System.out.println(arg1);
        }
    });
} catch (JSONException e) {

    e.printStackTrace();
}
```

#### Ruby
```ruby
pubnub.publish(
    :channel  => 'my_channel',
    :message => {

      "aps" : {
        "alert": "You got your emails.",
        "badge": 9,
        "sound": "bingbong.aiff"
      },
      "acme 1": 42
    }
)
```

#### Python
```python
pubnub.publish({
    'channel': 'my_channel',
    'message': {
      "aps" : {
        "alert": "You got your emails.",
        "badge": 9,
        "sound": "bingbong.aiff"
      },
      "acme 1": 42
    }
})
```

## PAM Methods
**Be sure you enabled PAM in your admin under the option "Access Manager". If you don't, it won't work!**

**NOTE: As soon as you enable PAM feature, you will have to grant permissions first, or all applications will be unable to operate because of all of them won't have any rights.**

PubNub provides ability to control who has access and what he can do there. There is three configurable access levels: application wide, channel and user (levels at the beginning of the list has larger wight in overall access rights  computation). If read / write access rights has been granted on application level, they can't be revoked for particular user. If channel has been configured for read-only, user can be configured to be ale to post messages into it.  
  
PubNub client provide large set of methods which allow to specify any aspect of access rights in the way which will keep your code clean and small (a lot of designated methods).
```objc
+ (void)grantReadAccessRightForApplicationAtPeriod:(NSInteger)accessPeriodDuration;
+ (void)grantReadAccessRightForApplicationAtPeriod:(NSInteger)accessPeriodDuration
                        andCompletionHandlingBlock:(PNClientChannelAccessRightsChangeBlock)handlerBlock;
+ (void)grantWriteAccessRightForApplicationAtPeriod:(NSInteger)accessPeriodDuration;
+ (void)grantWriteAccessRightForApplicationAtPeriod:(NSInteger)accessPeriodDuration
                         andCompletionHandlingBlock:(PNClientChannelAccessRightsChangeBlock)handlerBlock;
+ (void)grantAllAccessRightsForApplicationAtPeriod:(NSInteger)accessPeriodDuration;
+ (void)grantAllAccessRightsForApplicationAtPeriod:(NSInteger)accessPeriodDuration
                        andCompletionHandlingBlock:(PNClientChannelAccessRightsChangeBlock)handlerBlock;
+ (void)revokeAccessRightsForApplication;
+ (void)revokeAccessRightsForApplicationWithCompletionHandlingBlock:(PNClientChannelAccessRightsChangeBlock)handlerBlock;

+ (void)grantReadAccessRightForChannel:(PNChannel *)channel forPeriod:(NSInteger)accessPeriodDuration;
+ (void)grantReadAccessRightForChannel:(PNChannel *)channel forPeriod:(NSInteger)accessPeriodDuration
           withCompletionHandlingBlock:(PNClientChannelAccessRightsChangeBlock)handlerBlock;
+ (void)grantReadAccessRightForChannel:(PNChannel *)channel forPeriod:(NSInteger)accessPeriodDuration
                                client:(NSString *)clientAuthorizationKey;
+ (void)grantReadAccessRightForChannel:(PNChannel *)channel forPeriod:(NSInteger)accessPeriodDuration
                                client:(NSString *)clientAuthorizationKey
           withCompletionHandlingBlock:(PNClientChannelAccessRightsChangeBlock)handlerBlock;
+ (void)grantReadAccessRightForChannels:(NSArray *)channels forPeriod:(NSInteger)accessPeriodDuration;
+ (void)grantReadAccessRightForChannels:(NSArray *)channels forPeriod:(NSInteger)accessPeriodDuration
            withCompletionHandlingBlock:(PNClientChannelAccessRightsChangeBlock)handlerBlock;
+ (void)grantReadAccessRightForChannel:(PNChannel *)channel forPeriod:(NSInteger)accessPeriodDuration
                               clients:(NSArray *)clientsAuthorizationKeys;
+ (void)grantReadAccessRightForChannel:(PNChannel *)channel forPeriod:(NSInteger)accessPeriodDuration
                               clients:(NSArray *)clientsAuthorizationKeys
           withCompletionHandlingBlock:(PNClientChannelAccessRightsChangeBlock)handlerBlock;

+ (void)grantWriteAccessRightForChannel:(PNChannel *)channel forPeriod:(NSInteger)accessPeriodDuration;
+ (void)grantWriteAccessRightForChannel:(PNChannel *)channel forPeriod:(NSInteger)accessPeriodDuration
            withCompletionHandlingBlock:(PNClientChannelAccessRightsChangeBlock)handlerBlock;
+ (void)grantWriteAccessRightForChannel:(PNChannel *)channel forPeriod:(NSInteger)accessPeriodDuration
                                 client:(NSString *)clientAuthorizationKey;
+ (void)grantWriteAccessRightForChannel:(PNChannel *)channel forPeriod:(NSInteger)accessPeriodDuration
                                 client:(NSString *)clientAuthorizationKey
            withCompletionHandlingBlock:(PNClientChannelAccessRightsChangeBlock)handlerBlock;
+ (void)grantWriteAccessRightForChannels:(NSArray *)channels forPeriod:(NSInteger)accessPeriodDuration;
+ (void)grantWriteAccessRightForChannels:(NSArray *)channels forPeriod:(NSInteger)accessPeriodDuration
             withCompletionHandlingBlock:(PNClientChannelAccessRightsChangeBlock)handlerBlock;
+ (void)grantWriteAccessRightForChannel:(PNChannel *)channel forPeriod:(NSInteger)accessPeriodDuration
                                clients:(NSArray *)clientsAuthorizationKeys;
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
+ (void)revokeAccessRightsForChannel:(PNChannel *)channel
         withCompletionHandlingBlock:(PNClientChannelAccessRightsChangeBlock)handlerBlock;
+ (void)revokeAccessRightsForChannel:(PNChannel *)channel client:(NSString *)clientAuthorizationKey;
+ (void)revokeAccessRightsForChannel:(PNChannel *)channel client:(NSString *)clientAuthorizationKey
         withCompletionHandlingBlock:(PNClientChannelAccessRightsChangeBlock)handlerBlock;
+ (void)revokeAccessRightsForChannels:(NSArray *)channels;
+ (void)revokeAccessRightsForChannels:(NSArray *)channels
          withCompletionHandlingBlock:(PNClientChannelAccessRightsChangeBlock)handlerBlock;
+ (void)revokeAccessRightsForChannel:(PNChannel *)channel clients:(NSArray *)clientsAuthorizationKeys;
+ (void)revokeAccessRightsForChannel:(PNChannel *)channel clients:(NSArray *)clientsAuthorizationKeys
         withCompletionHandlingBlock:(PNClientChannelAccessRightsChangeBlock)handlerBlock;

+ (void)auditAccessRightsForApplication;
+ (void)auditAccessRightsForApplicationWithCompletionHandlingBlock:(PNClientChannelAccessRightsAuditBlock)handlerBlock;
+ (void)auditAccessRightsForChannel:(PNChannel *)channel;
+ (void)auditAccessRightsForChannel:(PNChannel *)channel 
        withCompletionHandlingBlock:(PNClientChannelAccessRightsAuditBlock)handlerBlock;
+ (void)auditAccessRightsForChannel:(PNChannel *)channel client:(NSString *)clientAuthorizationKey;
+ (void)auditAccessRightsForChannel:(PNChannel *)channel client:(NSString *)clientAuthorizationKey
        withCompletionHandlingBlock:(PNClientChannelAccessRightsAuditBlock)handlerBlock;
+ (void)auditAccessRightsForChannels:(NSArray *)channels;
+ (void)auditAccessRightsForChannels:(NSArray *)channels 
         withCompletionHandlingBlock:(PNClientChannelAccessRightsAuditBlock)handlerBlock;
+ (void)auditAccessRightsForChannel:(PNChannel *)channel clients:(NSArray *)clientsAuthorizationKeys;
+ (void)auditAccessRightsForChannel:(PNChannel *)channel clients:(NSArray *)clientsAuthorizationKeys
        withCompletionHandlingBlock:(PNClientChannelAccessRightsAuditBlock)handlerBlock;
```
Here is a small demo of how this methods can be used:
```objc
[PubNub setupWithConfiguration:[PNConfiguration configurationForOrigin:@"pubsub.pubnub.com" publishKey:@"demo"
                                                          subscribeKey:@"demo" secretKey:@"my-secret-key"]
                   andDelegate:self];
[PubNub connect];

[PubNub grantReadAccessRightForChannel:[PNChannel channelWithName:@"iosdev"] forPeriod:10 
                               clients:@[@"spectator", @"visitor"]
           withCompletionHandlingBlock:^(PNAccessRightsCollection *collection, PNError *error) {

  if (error == nil) {

    // PubNub client successfully changed access rights for 'user' access level.
  }
  else {

    // PubNub client did fail to change access rights for 'user' access level.
    //
    // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use 
    // -localizedDescription / -localizedFailureReason and -localizedRecoverySuggestion to get human readable description 
    // for error). 'error.associatedObject' contains PNAccessRightOptions instance which describes access level for which
    // change has been requested.
  }
}];
[PubNub grantWriteAccessRightForChannel:[PNChannel channelWithName:@"iosdev"] forPeriod:10];
```
Code above configure access rights in a way, which won't allow message posting for clients with _spectator_ and _visitor_ authorization keys into _iosdev_ channel for **10** minutes. But despite the fact that _iosdev_ channel access rights allow only subscription for _spectator_ and _visitor_, PubNub client allowed to post messages to any channels because of upper-layer configuration (__channel__ access level allow message posting to any channels for **10** minutes).



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
“error” will contain the details of the error.  
Example usage follows:
```objc
- (void)pubnubClient:(PubNub *)client error:(PNError *)error {

  PNLog(PNLogGeneralLevel, self, @"An error occurred: %@", error);
}
```
####- (void)pubnubClient:(PubNub *)client willConnectToOrigin:(NSString *)origin;  

This delegate method is called when the client is about to connect to the PubNub origin. “origin” will contain the PubNub origin url.  
Example usage follows:
```objc
- (void)pubnubClient:(PubNub *)client willConnectToOrigin:(NSString *)origin { 

  PNLog(PNLogGeneralLevel, self, @"PubNub client is about to connect to PubNub origin at: %@", origin);
}
```
####- (void)pubnubClient:(PubNub *)client didConnectToOrigin:(NSString *)origin;  

This delegate method is called when the client is successfully connected to the PubNub origin. “origin” will contain the PubNub origin url.  
Example usage follows:
```objc
- (void)pubnubClient:(PubNub *)client didConnectToOrigin:(NSString *)origin { 

  PNLog(PNLogGeneralLevel, self, @"PubNub client successfully connected to PubNub origin at: %@", origin);
}
```
####- (void)pubnubClient:(PubNub *)client didDisconnectFromOrigin:(NSString *)origin;

This delegate method is called when the client is successfully disconnected from the PubNub origin. “origin” will contain the PubNub origin url.  
Example usage follows:
```objc
- (void)pubnubClient:(PubNub *)client didDisconnectFromOrigin:(NSString *)origin {

  PNLog(PNLogGeneralLevel, self, @"PubNub client disconnected from PubNub origin at: %@", origin);
}
```
####- (void)pubnubClient:(PubNub *)client didDisconnectFromOrigin:(NSString *)origin withError:(PNError *)error;  

This delegate method is called when the client is disconnected from the PubNub origin due to an error. “error” will contain the details of the error. “origin” will contain the PubNub origin url.  
Example usage follows:
```objc
- (void)pubnubClient:(PubNub *)client didDisconnectFromOrigin:(NSString *)origin withError:(PNError *)error {

  PNLog(PNLogGeneralLevel, self, @"PubNub client closed connection because of error: %@", error);
}
```
####- (void)pubnubClient:(PubNub *)client willDisconnectWithError:(PNError *)error;  

This delegate method is called if an error occurred when disconnecting from the PubNub origin.
“error” will contain the details of the error.  
Example usage follows:
```objc
- (void)pubnubClient:(PubNub *)client willDisconnectWithError:(PNError *)error {

  PNLog(PNLogGeneralLevel, self, @"PubNub client will close connection because of error: %@", error);
}
```
####- (void)pubnubClient:(PubNub *)client connectionDidFailWithError:(PNError *)error;  

This delegate method is called if an error occurred when connecting to the PubNub origin.
“error” will contain the details of the error.  
Example usage follows:
```objc
- (void)pubnubClient:(PubNub *)client connectionDidFailWithError:(PNError *)error {

  PNLog(PNLogGeneralLevel, self, @"PubNub client was unable to connect because of error: %@", error);
}
```
####- (void)pubnubClient:(PubNub *)client didSubscribeOnChannels:(NSArray *)channels;  

This delegate method is called when the client is successfully subscribed call to the channels. 
“channels” will contain the array of channels to which the client is subscribed.  
Example usage follows:
```objc
- (void)pubnubClient:(PubNub *)client didSubscribeOnChannels:(NSArray *)channels {
  
  PNLog(PNLogGeneralLevel, self, @"PubNub client successfully subscribed to channels:%@", channels);
}
```
####- (void)pubnubClient:(PubNub *)client willRestoreSubscriptionOnChannels:(NSArray *)channels; 

This delegate method is called when the subscription on the channels is about to be restored after a network disconnect.
“channels” will contain the array of channels to which the subscription is about to be restored.  
Example usage follows:
```objc
- (void)pubnubClient:(PubNub *)client willRestoreSubscriptionOnChannels:(NSArray *)channels {
   
  PNLog(PNLogGeneralLevel, self, @"PubNub client resuming subscription on: %@", channels);
}
```
####- (void)pubnubClient:(PubNub *)client didRestoreSubscriptionOnChannels:(NSArray *)channels;  

This delegate method is called when the subscription on the channels is successfully restored after a network disconnect.
“channels” will contain the array of channels to which the subscription has been restored.  
Example usage follows:
```objc
- (void)pubnubClient:(PubNub *)client didRestoreSubscriptionOnChannels:(NSArray *)channels {

  PNLog(PNLogGeneralLevel, self, @"PubNub client successfully restored subscription on channels: %@", channels);
}
```
####- (void)pubnubClient:(PubNub *)client subscriptionDidFailWithError:(PNError *)error;  

This delegate method is called if an error occurred when subscribing to a channel.
“error” will contain the details of the error.  
Example usage follows:
```objc
- (void)pubnubClient:(PubNub *)client subscriptionDidFailWithError:(NSError *)error {

  PNLog(PNLogGeneralLevel, self, @"PubNub client failed to subscribe because of error: %@", error);
}
```
####- (void)pubnubClient:(PubNub *)client didUnsubscribeOnChannels:(NSArray *)channels;  

This delegate method is called if the channels are successfully unsubscribed.
“channels” will contain the array of channels which have been unsubscribed.  
Example usage follows:
```objc
- (void)pubnubClient:(PubNub *)client didUnsubscribeOnChannels:(NSArray *)channels {    

  PNLog(PNLogGeneralLevel, self, @"PubNub client successfully unsubscribed from channels: %@", channels);
}
```
####- (void)pubnubClient:(PubNub *)client unsubscriptionDidFailWithError:(PNError *)error;  

This delegate method is called if an error occurs when a channel is unsubscribed.
“error” will contain the details of the error.  
Example usage follows:
```objc
- (void)pubnubClient:(PubNub *)client unsubscriptionDidFailWithError:(PNError *)error {

  PNLog(PNLogGeneralLevel, self, @"PubNub client failed to unsubscribe because of 	error: %@", error);
}
```
####- (void)pubnubClient:(PubNub *)client didEnablePresenceObservationOnChannels:(NSArray *)channels;

This delegate method is called if the presence notifications are successfully enabled.
“channels” will contain the array of channels which have presence notifications enabled.  
Example usage follows:
```objc
- (void)pubnubClient:(PubNub *)client didEnablePresenceObservationOnChannels:(NSArray *)channels {
    
  PNLog(PNLogGeneralLevel, self, @"PubNub client successfully enabled presence observation on channels: %@", channels);
}
```
####- (void)pubnubClient:(PubNub *)client presenceObservationEnablingDidFailWithError:(PNError *)error;

This delegate method is called if an error occurs on enabling presence notifications.
“error” will contain the details of the error.  
Example usage follows:
```objc
- (void)pubnubClient:(PubNub *)client presenceObservationEnablingDidFailWithError:(PNError *)error {
  
  PNLog(PNLogGeneralLevel, self, @"PubNub client failed to enable presence observation because of error: %@", error);
}
```
####- (void)pubnubClient:(PubNub *)client didDisablePresenceObservationOnChannels:(NSArray *)channels;

This delegate method is called if the presence notifications are successfully disabled.
“channels” will contain the array of channels which have presence notifications disabled.  
Example usage follows:
```objc
- (void)pubnubClient:(PubNub *)client didDisablePresenceObservationOnChannels:(NSArray *)channels {
  
  PNLog(PNLogGeneralLevel, self, @"PubNub client successfully disabled presence observation on channels: %@", channels);
}
```
####- (void)pubnubClient:(PubNub *)client presenceObservationDisablingDidFailWithError:(PNError *)error;

This delegate method is called if an error occurs on disabling presence notifications.
“error” will contain the details of the error.  
Example usage follows:
```objc
- (void)pubnubClient:(PubNub *)client presenceObservationDisablingDidFailWithError:(PNError *)error {
  
  PNLog(PNLogGeneralLevel, self, @"PubNub client failed to disable presence observation because of error: %@", error);
}
```
####- (void)pubnubClient:(PubNub *)client didEnablePushNotificationsOnChannels:(NSArray *)channels;

This delegate method is called if push notifications for all channels are successfully enabled.
“channels” will contain the array of channels which have push notifications enabled.  
Example usage follows:
```objc
- (void)pubnubClient:(PubNub *)client didEnablePushNotificationsOnChannels:(NSArray *)channels {

  PNLog(PNLogGeneralLevel, self, @"PubNub client enabled push notifications on channels: %@", channels);
}
```
####- (void)pubnubClient:(PubNub *)client pushNotificationEnableDidFailWithError:(PNError *)error;

This delegate method is called when an error occurs on enabling push notifications for all channels.
“error” will contain the details of the error.  
Example usage follows:
```objc
- (void)pubnubClient:(PubNub *)client pushNotificationEnableDidFailWithError:(PNError *)error {

  PNLog(PNLogGeneralLevel, self, @"PubNub client failed push notification enable because of error: %@", error);
}
```
####- (void)pubnubClient:(PubNub *)client didDisablePushNotificationsOnChannels:(NSArray *)channels;

This delegate method is called when push notifications for all channels are successfully disabled.
“channels” will contain the array of channels which have push notifications disabled.  
Example usage follows:
```objc
- (void)pubnubClient:(PubNub *)client didDisablePushNotificationsOnChannels:(NSArray *)channels {

  PNLog(PNLogGeneralLevel, self, @"PubNub client disabled push notifications on channels: %@", channels);
}
```
####- (void)pubnubClient:(PubNub *)client pushNotificationDisableDidFailWithError:(PNError *)error;

This delegate method is called when an error occurs on disabling push notifications for all channels.
“error” will contain the details of the error.  
Example usage follows:
```objc
- (void)pubnubClient:(PubNub *)client pushNotificationDisableDidFailWithError:(PNError *)error {

  PNLog(PNLogGeneralLevel, self, @"PubNub client failed to disable push notifications because of error: %@", error);
}
```
####- (void)pubnubClientDidRemovePushNotifications:(PubNub *)client;

This delegate method is called when push notifications for all channels are successfully removed.  
Example usage follows:
```objc
- (void)pubnubClientDidRemovePushNotifications:(PubNub *)client {

  PNLog(PNLogGeneralLevel, self, @"PubNub client removed push notifications from all channels");
}
```
####- (void)pubnubClient:(PubNub *)client pushNotificationsRemoveFromChannelsDidFailWithError:(PNError *)error;

This delegate method is called when an error occurs on removing push notifications for all channels.
“error” will contain the details of the error.  
Example usage follows:
```objc
- (void)pubnubClient:(PubNub *)client pushNotificationsRemoveFromChannelsDidFailWithError:(PNError *)error {

  PNLog(PNLogGeneralLevel, self, @"PubNub client failed remove push notifications from channels because of error: %@",
        error);
}
```
####- (void)pubnubClient:(PubNub *)client didReceivePushNotificationEnabledChannels:(NSArray *)channels;

This delegate method is called when the client successfully receives to receive push notifications for a channel. “channels” will contain the array of channels which received push notifications.  
Example usage follows:
```objc
- (void)pubnubClient:(PubNub *)client didReceivePushNotificationEnabledChannels:(NSArray *)channels {

  PNLog(PNLogGeneralLevel, self, @"PubNub client received push notifications for these enabled channels: %@", channels);
}
```
####- (void)pubnubClient:(PubNub *)client pushNotificationEnabledChannelsReceiveDidFailWithError:(PNError *)error;

This delegate method is called when the client fails to receive push notifications for a channel.
“error” will contain the details of the error.  
Example usage follows:
```objc
- (void)pubnubClient:(PubNub *)client pushNotificationEnabledChannelsReceiveDidFailWithError:(PNError *)error {
  
  PNLog(PNLogGeneralLevel, self, @"PubNub client failed to receive list of channels because of error: %@", error);
}
```
####- (void)pubnubClient:(PubNub *)client didChangeAccessRights:(PNAccessRightsCollection *)accessRightsCollection;

This delegate method is called when PubNub client did complete access rights change operation. [PNAccessRightsCollection](iPadDemoApp/pubnub/libs/PubNub/Data/PNAccessRightsCollection.h) contains set of [PNAccessRightsInformation](iPadDemoApp/pubnub/libs/PubNub/Data/PNAccessRightsCollection.h) instance which is used to describe access rights which has been applied by the server at the end (parameters may differ from the one which is required by user).  
Example usage follows:
```objc
- (void)pubnubClient:(PubNub *)client didChangeAccessRights:(PNAccessRightsCollection *)accessRightsCollection {
    
  PNLog(PNLogGeneralLevel, self, @"PubNub client changed access rights configuration: %@", accessRightsCollection);
}
```
####- (void)pubnubClient:(PubNub *)client accessRightsChangeDidFailWithError:(PNError *)error;

This delegate method is called when PubNub client did fail access rights change operation. “error” will contain the details of the error and _error.associatedObject_ contains reference on [PNAccessRightOptions](iPadDemoApp/pubnub/libs/PubNub/Data/PNAccessRightOptions.h) instance which contains information about access rights which user tried to apply to some object.  
Example usage follows:
```objc
- (void)pubnubClient:(PubNub *)client accessRightsChangeDidFailWithError:(PNError *)error {
    
  PNLog(PNLogGeneralLevel, self, @"PubNub client failed to change access rights configuration because of error: %@", error);
}
```
####- (void)pubnubClient:(PubNub *)client didAuditAccessRights:(PNAccessRightsCollection *)accessRightsCollection;

This delegate method is called when PubNub client did complete access rights audition operation. [PNAccessRightsCollection](iPadDemoApp/pubnub/libs/PubNub/Data/PNAccessRightsCollection.h) contains set of [PNAccessRightsInformation](iPadDemoApp/pubnub/libs/PubNub/Data/PNAccessRightsCollection.h) instance which is used to describe access rights which has been give during previous PAM API grant / revoke usage.  
Example usage follows:
```objc
- (void)pubnubClient:(PubNub *)client didAuditAccessRights:(PNAccessRightsCollection *)accessRightsCollection {
    
  PNLog(PNLogGeneralLevel, self, @"PubNub client completed access rights audition: %@", accessRightsCollection);
}
```
####- (void)pubnubClient:(PubNub *)client accessRightsAuditDidFailWithError:(PNError *)error;

This delegate method is called when PubNub client did fail access rights audition operation. “error” will contain the details of the error and _error.associatedObject_ contains reference on [PNAccessRightOptions](iPadDemoApp/pubnub/libs/PubNub/Data/PNAccessRightOptions.h) instance which contains information about object for which user tried to pull our access rights information.  
Example usage follows:
```objc
- (void)pubnubClient:(PubNub *)client accessRightsAuditDidFailWithError:(PNError *)error {
    
  PNLog(PNLogGeneralLevel, self, @"PubNub client failed to audit access rights because of error: %@", error);
}
```
####- (void)pubnubClient:(PubNub *)client didReceiveClientMetadata:(PNClient *)remoteClient; // DEPRECATED
####- (void)pubnubClient:(PubNub *)client didReceiveClientState:(PNClient *)remoteClient;

This delegate method is called when PubNub client successfully retrieved client state information. [PNClinet](iPadDemoApp/pubnub/libs/PubNub/Data/PNClinet.h) represent all information via properties.  
Example usage follows:
```objc
- (void)pubnubClient:(PubNub *)client didReceiveClientState:(PNClient *)remoteClient {

  PNLog(PNLogGeneralLevel, self, @"PubNub client successfully received state for client %@ on channel %@: %@ ",
        remoteClient.identifier, remoteClient.channel, remoteClient.data);
}
```
####- (void)pubnubClient:(PubNub *)client clientMetadataRetrieveDidFailWithError:(PNError *)error; // DEPRECATED
####- (void)pubnubClient:(PubNub *)client clientStateRetrieveDidFailWithError:(PNError *)error;

This delegate method is called when PubNub client was unable to receive client state. "error" will contain details of this error.  
Example usage follows:
```objc
- (void)pubnubClient:(PubNub *)client clientStateRetrieveDidFailWithError:(PNError *)error {

  PNLog(PNLogGeneralLevel, self, @"PubNub client did fail to receive state for client %@ on channel %@ because of "
        "error: %@", ((PNClient *)error.associatedObject).identifier, ((PNClient *)error.associatedObject).channel, error);
}
```
####- (void)pubnubClient:(PubNub *)client didUpdateClientMetadata:(PNClient *)remoteClient; // DEPRECATED
####- (void)pubnubClient:(PubNub *)client didUpdateClientState:(PNClient *)remoteClient;

This delegate method is called when PubNub client successfully updated client's state. "remoteClient" will hold updated information.  
Example usage follows:
```objc
- (void)pubnubClient:(PubNub *)client didUpdateClientState:(PNClient *)remoteClient {

  PNLog(PNLogGeneralLevel, self, @"PubNub client successfully updated state for client %@ at channel %@: %@ ",
        remoteClient.identifier, remoteClient.channel, remoteClient.data);
}
```
####- (void)pubnubClient:(PubNub *)client clientMetadataUpdateDidFailWithError:(PNError *)error; // DEPRECATED
####- (void)pubnubClient:(PubNub *)client clientStateUpdateDidFailWithError:(PNError *)error;

This delegate method is called when PubNub client was unable to update client's state. "error" will contains details of this error.  
Example usage follows:
```objc
- (void)pubnubClient:(PubNub *)client clientStateUpdateDidFailWithError:(PNError *)error {

  PNLog(PNLogGeneralLevel, self, @"PubNub client did fail to update state for client %@ at channel %@ because of "
        "error: %@", ((PNClient *)error.associatedObject).identifier, ((PNClient *)error.associatedObject).channel, error);
}
```
####- (void)pubnubClient:(PubNub *)client didReceiveTimeToken:(NSNumber *)timeToken;  

This delegate method is called when the client successfully retrieves the timetoken from the server. 
“timeToken” will contain the retrieved timetoken.  
Example usage follows:
```objc
- (void)pubnubClient:(PubNub *)client didReceiveTimeToken:(NSNumber *)timeToken {
  
  PNLog(PNLogGeneralLevel, self, @"PubNub client received time token: %@", timeToken);
}
```
####- (void)pubnubClient:(PubNub *)client timeTokenReceiveDidFailWithError:(PNError *)error;  

This delegate method is called when the client fails to retrieve the timetoken from the server. 
“error” will contain the details of the error.  
Example usage follows:
```objc
- (void)pubnubClient:(PubNub *)client timeTokenReceiveDidFailWithError:(PNError *)error 

  PNLog(PNLogGeneralLevel, self, @"PubNub client failed to receive time token because of error: %@", error);
}
```
####- (void)pubnubClient:(PubNub *)client willSendMessage:(PNMessage *)message;  
This delegate method is called when the client is about to send a message on a channel. 
“message” will contain the details of the message including the channel info.  
Example usage follows:
```objc
- (void)pubnubClient:(PubNub *)client willSendMessage:(PNMessage *)message {

  PNLog(PNLogGeneralLevel, self, @"PubNub client is about to send message: %@", message);
}
```
####- (void)pubnubClient:(PubNub *)client didFailMessageSend:(PNMessage *)message withError:(PNError *)error;  

This delegate method is called when the client fails to send a message on a channel. 
“message” will contain the details of the message including the channel info.
“error” will contain the details of the error.  
Example usage follows:
```objc
- (void)pubnubClient:(PubNub *)client didFailMessageSend:(PNMessage *)message withError:(PNError *)error {    

  PNLog(PNLogGeneralLevel, self, @"PubNub client failed to send message '%@' because of error: %@", message, error);
}
```
####- (void)pubnubClient:(PubNub *)client didSendMessage:(PNMessage *)message;  
This delegate method is called when the client successfully sends a message on a channel. 
“message” will contain the details of the message including the channel info.  
Example usage follows:
```objc
- (void)pubnubClient:(PubNub *)client didSendMessage:(PNMessage *)message{ 

  PNLog(PNLogGeneralLevel, self, @"PubNub client sent message: %@", message);
}
```
####- (void)pubnubClient:(PubNub *)client didReceiveMessage:(PNMessage *)message; 

This delegate method is called when the client successfully receives a message on a subscribed channel. 
“message” will contain the details of the message including the channel info.  
Example usage follows:
```objc
- (void)pubnubClient:(PubNub *)client didReceiveMessage:(PNMessage *)message {    
    PNLog(PNLogGeneralLevel, self, @"PubNub client received message: %@", message);
}
```
####- (void)pubnubClient:(PubNub *)client didReceivePresenceEvent:(PNPresenceEvent *)event;  

This delegate method is called when the client successfully receives a presence event on a channel whose presence notifications are subscribed. 
“event” will contain the presence event.  
Example usage follows:
```objc
- (void)pubnubClient:(PubNub *)client didReceivePresenceEvent:(PNPresenceEvent *)event {

  PNLog(PNLogGeneralLevel, self, @"PubNub client received presence event: %@", event);
}
```
####- (void)pubnubClient:(PubNub *)client didReceiveMessageHistory:(NSArray *)messages forChannel:(PNChannel *)channel startingFrom:(PNDate *)startDate to:(PNDate *)endDate;  

This delegate method is called when the client successfully retrieves the history of messages on the channel. 
“channel” will contain the value of the PubNub channel.
“messages” will contain the retrieved messages as an NSArray.
“startDate” and “endDate” are the datetime range of the retrieved messages.  
Example usage follows:
```objc
- (void)pubnubClient:(PubNub *)client didReceiveMessageHistory:(NSArray *)messages forChannel:(PNChannel *)channel 
        startingFrom:(NSDate *)startDate to:(NSDate *)endDate {

  PNLog(PNLogGeneralLevel, self, @"PubNub client received history for %@ starting from %@ to %@: %@", channel, 
                                   startDate, endDate, messages);
}
```
####- (void)pubnubClient:(PubNub *)client didFailHistoryDownloadForChannel:(PNChannel *)channel withError:(PNError *)error;  

This delegate method is called when the client fails to get history of messages on the channel. 
“channel” will contain the value of the PubNub channel and 
“error” will contain the error info.  
Example usage follows:
```objc
- (void)pubnubClient:(PubNub *)client didFailHistoryDownloadForChannel:(PNChannel *)channel withError:(PNError *)error {

  PNLog(PNLogGeneralLevel, self, @"PubNub client failed to download history for %@ because of error: %@", channel, error);
}
```
####- (void)pubnubClient:(PubNub *)client didReceiveParticipantsLits:(NSArray *)participantsList forChannel:(PNChannel *)channel;  

This delegate method is called when the client successfully retrieves the info of other connected users on the channel. "participantsList" will contain list of [PNClinet](iPadDemoApp/pubnub/libs/PubNub/Data/PNClinet.h) instances. “channel” will contain the value of the PubNub channel.  
Example usage follows:
```objc
- (void)pubnubClient:(PubNub *)client didReceiveParticipantsLits:(NSArray *)participantsList 
-         forChannel:(PNChannel *)channel {

  PNLog(PNLogGeneralLevel, self, @"PubNub client received participants list for channel %@: %@", participantsList, channel);
}
```
####- (void)pubnubClient:(PubNub *)client didFailParticipantsListDownloadForChannel:(PNChannel *)channel withError:(PNError *)error;  

This delegate method is called when the client fails to get the info of other connected users on the channel. 
“channel” will contain the value of the PubNub channel and “error” will contain the error info.  
Example usage follows:
```objc
- (void) pubnubClient:(PubNub *)client didFailParticipantsListDownloadForChannel:(PNChannel *)channel 
            withError:(PNError *)error {

  PNLog(PNLogGeneralLevel, self, @"PubNub client failed to download participants list for channel %@ because of error: %@",
                                   channel, error);
}
```
####- (void)pubnubClient:(PubNub *)client didReceiveParticipantChannelsList:(NSArray *)participantChannelsList forIdentifier:(NSString *)clientIdentifier;

This delegate method is called when PubNub client successfully retrieved list of channels on which target client subscribed at this moment.  
Example usage follows:
```objc
- (void)pubnubClient:(PubNub *)client didReceiveParticipantChannelsList:(NSArray *)participantChannelsList
       forIdentifier:(NSString *)clientIdentifier {

  PNLog(PNLogGeneralLevel, self, @"PubNub client received participant channels list for identifier %@: %@",
        participantChannelsList, clientIdentifier);
}
```
####- (void)pubnubClient:(PubNub *)client didFailParticipantChannelsListDownloadForIdentifier:(NSString *)clientIdentifier withError:(PNError *)error;

This delegate method is called when PubNub client can't pull out list of channels on which target client subscribed at this moment. "error" will contain error information.  
Example usage follows:
```objc
- (void)pubnubClient:(PubNub *)client didFailParticipantChannelsListDownloadForIdentifier:(NSString *)clientIdentifier
           withError:(PNError *)error {

  PNLog(PNLogGeneralLevel, self, @"PubNub client failed to download participant channels list for identifier %@ "
        "because of error: %@", clientIdentifier, error);
}
```
####- (BOOL)shouldRunClientInBackground;

This method returns the setting to determine if the client is configured to run in the background mode when the app goes into the background. If this method not implemented by delegate, then the app property list is read to determine if the app is configured to run in the background mode.  
Example usage follows:
```objc
- (BOOL)shouldRunClientInBackground {
  
  return NO;
}
```
####- (NSNumber *)shouldReconnectPubNubClient:(PubNub *)client;  

This method allow to override value passed in configuration during client initialization. This method called when service reachabilty reported that service are available and previous session is failed because of network error or even not launched. We can change client configuration, but it will trigger client hard reset (if connected).  
Example usage follows:
```objc
- (NSNumber *)shouldReconnectPubNubClient:(PubNub *)client {
  
  return @(NO);
}
```
####- (NSNumber *)shouldResubscribeOnConnectionRestore;  

This method allow to override value passed in configuration during client initialization. This method called when service reachabilty reported that service are available and previous session is failed because of network error or even not launched. It allow to specify whether client should restore subscription or previously subscribed channels or not.  
Example usage follows:
```objc
- (NSNumber *)shouldResubscribeOnConnectionRestore {
    
  NSNumber *shouldResubscribeOnConnectionRestore = @(YES);
  
  PNLog(PNLogGeneralLevel, self, @"PubNub client should restore subscription? %@",
                                  [shouldResubscribeOnConnectionRestore boolValue]?@"YES":@"NO");
  

  return shouldResubscribeOnConnectionRestore;
}
```
####- (NSNumber *)shouldRestoreSubscriptionFromLastTimeToken;

This method allow to override value passed in configuration during client initialization. This method is called by library right after connection has been restored and client was configured to restore subscription on channels..  
Example usage follows:
```objc
- (NSNumber *)shouldRestoreSubscriptionFromLastTimeToken {

  NSNumber *shouldRestoreSubscriptionFromLastTimeToken = @(NO);

  NSString *lastTimeToken = @"0";
  if ([[PubNub subscribedChannels] count] > 0) {

    lastTimeToken = [[[PubNub subscribedChannels] lastObject] updateTimeToken];
  }
  
  PNLog(PNLogGeneralLevel, self, @"PubNub client should restore subscription from last time token? %@ (last time token: %@)",
                                  [shouldRestoreSubscriptionFromLastTimeToken boolValue]?@"YES":@"NO", lastTimeToken);
  

  return shouldRestoreSubscriptionFromLastTimeToken;
}
```
	
### Block callbacks

Many of the client methods support callback blocks as a way to handle events in lieu of a delegate. For each method, only the last block callback will be triggered -- that is, in the case you send many identical requests via a handling block, only last one will register.  

### Observation center

[__PNObservationCenter__](iPadDemoApp/pubnub/libs/PubNub/Core/PNObservationCenter.h) is used in the same way as NSNotificationCenter, but instead of observing with selectors it allows you to specify a callback block for particular events.  

These blocks are described in [__PNStructures.h__](iPadDemoApp/pubnub/libs/PubNub/Misc/PNStructures.h).  

This is the set of methods which can be used to handle events:  
```objc
- (void)addClientConnectionStateObserver:(id)observer withCallbackBlock:(PNClientConnectionStateChangeBlock)callbackBlock;
- (void)removeClientConnectionStateObserver:(id)observer;

- (void)addClientStateRequestObserver:(id)observer withBlock:(PNClientStateRetrieveHandlingBlock)handleBlock;
- (void)removeClientStateRequestObserver:(id)observer;

- (void)addClientStateUpdateObserver:(id)observer withBlock:(PNClientStateUpdateHandlingBlock)handleBlock;
- (void)removeClientStateUpdateObserver:(id)observer;

- (void)addClientChannelSubscriptionStateObserver:(id)observer 
                                withCallbackBlock:(PNClientChannelSubscriptionHandlerBlock)callbackBlock;
- (void)removeClientChannelSubscriptionStateObserver:(id)observer;

- (void)addClientChannelUnsubscriptionObserver:(id)observer 
                             withCallbackBlock:(PNClientChannelUnsubscriptionHandlerBlock)callbackBlock;
- (void)removeClientChannelUnsubscriptionObserver:(id)observer;

- (void)addClientPresenceEnablingObserver:(id)observer withCallbackBlock:(PNClientPresenceEnableHandlingBlock)handlerBlock;
- (void)removeClientPresenceEnablingObserver:(id)observer;
- (void)addClientPresenceDisablingObserver:(id)observer 
                         withCallbackBlock:(PNClientPresenceDisableHandlingBlock)handlerBlock;
- (void)removeClientPresenceDisablingObserver:(id)observer;

- (void)addClientPushNotificationsEnableObserver:(id)observer
                               withCallbackBlock:(PNClientPushNotificationsEnableHandlingBlock)handlerBlock;
- (void)removeClientPushNotificationsEnableObserver:(id)observer;
- (void)addClientPushNotificationsDisableObserver:(id)observer
                                withCallbackBlock:(PNClientPushNotificationsDisableHandlingBlock)handlerBlock;
- (void)removeClientPushNotificationsDisableObserver:(id)observer;
- (void)addClientPushNotificationsEnabledChannelsObserver:(id)observer
                                      withCallbackBlock:(PNClientPushNotificationsEnabledChannelsHandlingBlock)handlerBlock;
- (void)removeClientPushNotificationsEnabledChannelsObserver:(id)observer;
- (void)addClientPushNotificationsRemoveObserver:(id)observer
                               withCallbackBlock:(PNClientPushNotificationsRemoveHandlingBlock)handlerBlock;
- (void)removeClientPushNotificationsRemoveObserver:(id)observer;

- (void)addTimeTokenReceivingObserver:(id)observer withCallbackBlock:(PNClientTimeTokenReceivingCompleteBlock)callbackBlock;
- (void)removeTimeTokenReceivingObserver:(id)observer;

- (void)addMessageProcessingObserver:(id)observer withBlock:(PNClientMessageProcessingBlock)handleBlock;
- (void)removeMessageProcessingObserver:(id)observer;

- (void)addMessageReceiveObserver:(id)observer withBlock:(PNClientMessageHandlingBlock)handleBlock;
- (void)removeMessageReceiveObserver:(id)observer;

- (void)addPresenceEventObserver:(id)observer withBlock:(PNClientPresenceEventHandlingBlock)handleBlock;
- (void)removePresenceEventObserver:(id)observer;

- (void)addMessageHistoryProcessingObserver:(id)observer withBlock:(PNClientHistoryLoadHandlingBlock)handleBlock;
- (void)removeMessageHistoryProcessingObserver:(id)observer;

- (void)addAccessRightsChangeObserver:(id)observer withBlock:(PNClientChannelAccessRightsChangeBlock)handlerBlock;
- (void)removeAccessRightsObserver:(id)observer;
- (void)addAccessRightsAuditObserver:(id)observer withBlock:(PNClientChannelAccessRightsAuditBlock)handlerBlock;
- (void)removeAccessRightsAuditObserver:(id)observer;

- (void)addChannelParticipantsListProcessingObserver:(id)observer withBlock:(PNClientParticipantsHandlingBlock)handleBlock;
- (void)removeChannelParticipantsListProcessingObserver:(id)observer;
```

### Notifications

The client also triggers notifications with custom user information, so from any place in your application you can listen for notifications and perform appropriate actions.

A full list of notifications are stored in [__PNNotifications.h__](iPadDemoApp/pubnub/libs/PubNub/Misc/PNNotifications.h) along with their description, their parameters, and how to handle them.  

### Logging

Logging can be controlled via the following booleans:

```c
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
```
in [pubnub/libs/PubNub/Misc/PNMacro.h](pubnub/libs/PubNub/Misc/PNMacro.h#L37)

To disable logging, set **PNLOG_LOGGING_ENABLED** to 0.

By default, all non-http response logging is enabled to file with a 10MB, single archived file log rotation.
```c
kPNLogMaximumLogFileSize (10 * 1024 * 1024)
```
    
In the above, 10 represents the size in MB. Set it to the size you desire.  

**Keep in mind, this file size is only checked/rotated at application start. If it rises above the max size during application run-time, it will not rotate until after the application has been restarted.**

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
