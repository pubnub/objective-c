# PubNub 4.0b3 for iOS 7+
### (Beta, not for Production Use)

<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
**Table of Contents**  *generated with [DocToc](https://github.com/thlorenz/doctoc)*

- [Changes from 3.x](#changes-from-3x)
- [Known issues and TODOs in beta3:](#known-issues-and-todos-in-beta3)
- [Installing the Pod](#installing-the-pod)
- [Hello World](#hello-world)
- [Migrating from 3.x](#migrating-from-3x)
  - [Project Setup](#project-setup)
  - [Method Names and Overall Operation have changed](#method-names-and-overall-operation-have-changed)
  - [Removed support for iOS 6 and earlier](#removed-support-for-ios-6-and-earlier)
  - [Removed support for JSONKit](#removed-support-for-jsonkit)
  - [Removed support for blocking, syncronous calls (all calls are now async)](#removed-support-for-blocking-syncronous-calls-all-calls-are-now-async)
  - [Removed support for Singleton, Delegate, Observer, Notifications response patterns](#removed-support-for-singleton-delegate-observer-notifications-response-patterns)
  - [New Configuration Class](#new-configuration-class)
  - [New Logger and Logging Options](#new-logger-and-logging-options)
  - [Optimized / Consolidated instance method names](#optimized--consolidated-instance-method-names)
  - [Sending Logs to Support](#sending-logs-to-support)
- [Configuration](#configuration)
- [New for 4.0](#new-for-40)
  - [How its Received: Result and Status Event Objects](#how-its-received-result-and-status-event-objects)
    - [Operations that only return Status, never a Result](#operations-that-only-return-status-never-a-result)
    - [Operations that can return Status or Result](#operations-that-can-return-status-or-result)
  - [Where its Received: Completion Blocks and Listeners](#where-its-received-completion-blocks-and-listeners)
- [Reference App - Example](#reference-app---example)
- [Beta API Reference](#beta-api-reference)
  - [Initialization](#initialization)
    - [Basic Setup](#basic-setup)
      - [Install the CocoaPod](#install-the-cocoapod)
      - [Import PubNub.h](#import-pubnubh)
      - [Conform to the PNObjectEventListener protocol and Define a client property.](#conform-to-the-pnobjecteventlistener-protocol-and-define-a-client-property)
    - [Create a Config](#create-a-config)
      - [+ configurationWithPublishKey:subscribeKey:](#-configurationwithpublishkeysubscribekey)
      - [– copyWithConfiguration:completion:](#%E2%80%93-copywithconfigurationcompletion)
      - [– copyWithConfiguration:callbackQueue:completion:](#%E2%80%93-copywithconfigurationcallbackqueuecompletion)
    - [Configuration Options](#configuration-options)
      - [publishKey](#publishkey)
      - [subscribeKey](#subscribekey)
      - [authKey](#authkey)
      - [uuid](#uuid)
      - [cipherKey](#cipherkey)
      - [subscribeMaximumIdleTime](#subscribemaximumidletime)
      - [nonSubscribeRequestTimeout](#nonsubscriberequesttimeout)
      - [presenceHeartbeatValue](#presenceheartbeatvalue)
      - [presenceHeartbeatInterval](#presenceheartbeatinterval)
      - [TLSEnabled](#tlsenabled)
      - [keepTimeTokenOnListChange](#keeptimetokenonlistchange)
      - [restoreSubscription](#restoresubscription)
      - [catchUpOnSubscriptionRestore](#catchuponsubscriptionrestore)
    - [Instantiate a Client Instance with a Config](#instantiate-a-client-instance-with-a-config)
      - [+ clientWithConfiguration:](#-clientwithconfiguration)
      - [+ clientWithConfiguration:callbackQueue:](#-clientwithconfigurationcallbackqueue)
    - [Add a Listener in order to Receive Subscribe and Presence Stream Events](#add-a-listener-in-order-to-receive-subscribe-and-presence-stream-events)
  - [Time](#time)
  - [Publish](#publish)
  - [Subcribe / Unsubscribe](#subcribe--unsubscribe)
    - [Subscribing to Channels, Channel Groups, and Presence Events](#subscribing-to-channels-channel-groups-and-presence-events)
    - [Listener Methods](#listener-methods)
    - [Determining Current Subscribtion Status](#determining-current-subscribtion-status)
  - [History](#history)
  - [Here and Where Now Methods](#here-and-where-now-methods)
  - [Admin for Channel Groups](#admin-for-channel-groups)
  - [Admin for State](#admin-for-state)
  - [Admin for 3rd Party Notifications](#admin-for-3rd-party-notifications)
  - [Public Encryption Methods](#public-encryption-methods)
  - [Logging](#logging)
    - [Enable / Disable](#enable--disable)
    - [Log Rotation Settings](#log-rotation-settings)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

## Changes from 3.x
* 4.0 is a non-bw compatible REWRITE with 95% less lines of code than our 3.x!
* Removed support for iOS 6 and earlier
* Removed support for JSONKit
* Removed custom connection, request, logging, and reachability logic, replacing with NSURLSession, DDLog, and AFNetworking libraries
* Simplified serialization/deserialization threading logic
* Removed support for blocking, syncronous calls (all calls are now async)
* Simplified usability by enforcing completion block pattern -- client no longer supports Singleton, Delegate, Observer, Notifications response patterns
* Consolidated instance method namesv
 
## Known issues and TODOs in beta3:

* Provide Swift Bridge and associated docs
* Approach >= 75% automated test code coverage as we approach final release

## Installing the Pod

* Create a new project in Xcode as you would normally.
* Close XCode
* Open a terminal window, and cd into your project directory.
* Create a Podfile. This can be done by running
```
touch Podfile
```

* Open your Podfile.
* Populate it with:

```
source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '7.0'
pod 'PubNub', :git => 'https://github.com/PubNub/objective-c.git', :branch => '4.0b3'
```

* Be sure the git argument in the Podfile is pointing to the [4.0b3 branch](https://github.com/pubnub/objective-c/tree/4.0b3) of the [PubNub source directory](https://github.com/pubnub/objective-c).

* Run:
 ```
 pod install
 ```

* Open the MyApp.xcworkspace that was created with XCode. (Don't open the project! Be sure to open the workspace ... This will be the file you use to write your app.)

You should now have a skeleton PubNub project.

## Hello World

* Open the workspace
* Select myApp in the folder view
* Open AppDelegate.m
* Just after ```#import``` add the PubNub import:
 
```objective-c
#import <PubNub/PubNub.h>
```
* Within the AppDelegate interface, make AppDelegate conform to the PNObjectEventListener protocol, and define a client property. When you are finished, it should look like this:

```objective-c
@interface AppDelegate () <PNObjectEventListener>
@property(nonatomic, strong) PubNub *client;
@end
```

* Make your application:didFinishLaunchingWithOptions look like this:

```objective-c
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

	PNConfiguration *config = [PNConfiguration configurationWithPublishKey:@"demo" subscribeKey:@"demo"];
        self.client = [PubNub clientWithConfiguration:config];
        [self.client addListener:self];


    [self.client subscribeToChannels:@[@"myChannel"] withPresence:NO];        
        
    

    return YES;
}
```

* Add a message listener method to your AppDelegate.m:

```objective-c
- (void)client:(PubNub *)client didReceiveMessage:(PNMessageResult *)message {
    
    if (message) {
 
        NSLog(@"Received message: %@", message.data.message);
    }
}
```

* If you have a [web console running](http://www.pubnub.com/console/?channel=myChannel&origin=d.pubnub.com&sub=demo&pub=demo), you can receive the hello world messages sent from your iOS app, as well as send messages from the web console, and see them appear in the didReceiveMessage listener!

Run the app, and watch it work!

## Migrating from 3.x

Its important to note that a lot of things have changed in 4.x. When migrating your applications from PN 3.x to PN 4.0, please be sure to read this section.

### Project Setup

We're using Cocoapods as our exclusive method of installing the client SDK. Please see "Installing the Source" and "Hello World" above for the new way to configure PubNub 4.0 for iOS.

### Method Names and Overall Operation have changed

Please checkout the "New for 4.0" section below for a general overview of the major changes in the usage pattern introduced in 4.0.

### Removed support for iOS 6 and earlier

PubNub 4.0 for iOS supports iOS 7+. If you regard this as an issue, please contact us at support@pubnub.com.

### Removed support for JSONKit

This should only be an issue for you if you are supporting very old iOS versions. If you regard this as an issue, please contact us at support@pubnub.com.

### Removed support for blocking, syncronous calls (all calls are now async)

In the 3.x version of the client, the developer had the option to call a method blocking, or asyncronously. In the new version, asyncronously is the only option. Be sure that any blocking-dependent code is refactored to take the new 100% async behavior into account.

### Removed support for Singleton, Delegate, Observer, Notifications response patterns

We've removed the Singleton, Delegate, Observer, Notifications pattern support in 4.0, and instead provide you with one of two versitle alternatives on a per-method basis -- Completion Blocks, or Listeners. 

Please checkout the "New for 4.0" section below for a general overview of the major changes in the usage pattern introduced in 4.0, as well as the Example app for more information.

### New Configuration Class

There is a new configuration class which is not backwards compatible with the configuration class introduced in 3.x. Be sure to examine the "Configuration" section below, or the Example app for proper usage. 

### New Logger and Logging Options

In 4.x we use DDLog (Lumberjack) for our logging, and therefore, logging configuration has changed. Please see "Logging" below for more information on how to use the new logger.

### Optimized / Consolidated instance method names

Method names have been optimized. Be sure to consult with the API reference below for more info on the available method names.

### Sending Logs to Support

When filing a ticket with support, its handy to have your logs. Use a tool such as iExplorer to grab the logs off the APPNAME/Documents directory on your device, and be sure to include them in your support ticket as an attachment.

## Configuration

To setup a custom configuration:

* Define a configuration variable:

```objective-c
@property(nonatomic, strong) PNConfiguration *myConfig;
```

* Once you have the configuration variable, the following configuration options are available:

```objective-c
    self.myConfig.TLSEnabled = YES; # Secure Connection
    self.myConfig.uuid = [self randomString]; # Setup a UUID
    self.myConfig.origin = @"pubsub.pubnub.com"; # Setup a custom origin. Don't do this unless support requests.
    self.myConfig.authKey = _authKey; # For PAM, an auth key for authorization

    // Presence Settings
    self.myConfig.presenceHeartbeatValue = 120; # Tell the server that the hearbeat timeout is 120s
    self.myConfig.presenceHeartbeatInterval = 60; # Send the heartbeat to the server every 60 seconds

    // Cipher Key Settings
    //self.client.cipherKey = @"enigma"; # Set this to enable PN AES encryption

    // Time Token Handling Settings
    self.myConfig.keepTimeTokenOnListChange = YES; # When changing channels, 'catchup' ?
    self.myConfig.restoreSubscription = YES; # If you lose the connection, should you resubscribe when it comes back?
    self.myConfig.catchUpOnSubscriptionRestore = YES; # If restoreSubscription == YES, catchup ? Or start at 'now' ?
```

## New for 4.0

Across all PubNub SDK client platforms, we are introducing the Result/Status model in 4.0. The Result/Status model simplifies handling of all types of PubNub Cloud responses, including method call results, status events (such as acknowledgements), errors (from expected errors like PAM 403s, to unexpected errors like timeouts or intermittent network layer issues) commonly encountered by mobile devices on-the-move.

### How its Received: Result and Status Event Objects

For any PubNub operation you call, you will be returned either a Result, or a Status, but never both at the same time.  A generic example of a history call being made in the Result/Status pattern looks like this:

```
pubnub.history("myChannel", myResultHandler, myStatusHandler);
```

Where **myResultHandler** is a callback with history results, and **myStatusHandler** is callback for **everything else**. 

When a result comes in, we can inspect the data attribute on the result object for the messages, start, and end attributes.

When a status comes in, to determine what everything else can be, we inspect attributes on the status object, including:

1. isError - Is this an error, or more informational, such as an ACK, CONNECT, DISCONNECT, RECONNECT event?
2. willAutomaticallyRetry - Do I need to manually retry, or will the system retry for me?
3. category - this can be ACCESS_DENIED (PAM), TIMEOUT, NON_JSON_RESPONSE, API_KEY_ERROR, ENCRYPTION_ERROR

Status objects inherit from Result objects, so both contain common information like raw request, raw response, HTTP response code information, etc.

Its important to keep in mind that although all operations will return a Status, only some have the capacity to return both Status and Results:

#### Operations that only return Status, never a Result

* Publish
* Heartbeat
* Set State
* Channel Group Add|Remove
* Mobile GW Add|Remove
* Leave

#### Operations that can return Status or Result

* Channel / Channel Group / Presence Subscribe
* Time
* History
* Here Now
* Global Here Now
* Where Now
* Get State
* Mobile GW List
* List All Channels in Channel Group
* List All Channel Groups

### Where its Received: Completion Blocks and Listeners

With PubNub, operations can be grouped into two groups: Streamed (Subscribed Messages, Presence Events), and Non-Streamed (History, Here Now, Add Channel to Channel Group, etc).

Streamed operation method calls return Results and Statuses via listeners. For example:

1. [Calling a subscribe operation](Example/PubNub/PNAppDelegate.m#L96) will return Result objects (received messages) to the (didReceiveMessage listener)[Example/PubNub/PNAppDelegate.m#L275] and Status objects  (such as PAM errors, Connect, Disconnect state changes) to the (didReceiveStatus listener)[Example/PubNub/PNAppDelegate.m#L296]

2. [Calling a presence operation](Example/PubNub/PNAppDelegate.m#L111) will return Result objects (Such as Join, Leave Presence Events) to the (didReceivePresenceEvents listener)[Example/PubNub/PNAppDelegate.m#L286] and Status objects to the (didReceiveStatus listener)[Example/PubNub/PNAppDelegate.m#L296]

Non-Streamed operation method calls use completion blocks which return either a result or status object. An example of this can be seen in the [history call example](Example/PubNub/PNAppDelegate.m#L228).

If you have questions about how the Result and Status objects work in the meantime, feel free to contact support@pubnub.com and cc: geremy@pubnub.com, and we'll be happy to assist.

## Reference App - Example

In 4.0, [we provide Example](Example) as a generic reference on how to set config options, make Pub, Sub, and History calls (with and without PAM), and handle the various Status and Result events that may arise from them.  

The Example app is used as a simple reference app. It will evolve over time, along with other example apps -- stay tuned for that!

## Beta API Reference

### Initialization

#### Basic Setup

##### Install the CocoaPod
To get the PubNub source code onto your system first you must [install the Pod](#installing-the-pod).

##### Import PubNub.h

Import PubNub into your application:

```objective-c
#import <PubNub/PubNub.h>
```

##### Conform to the PNObjectEventListener protocol and Define a client property.


```objective-c
# In this example, we implement within AppDelegate.m 
@interface AppDelegate () <PNObjectEventListener>
@property(nonatomic, strong) PubNub *client;
@end
```

#### Create a Config
The first thing you need to do is create a configuration. Configurations are immutable. The most common use case is to instantiate a configuration with your publish an subscribe keys:

##### + configurationWithPublishKey:subscribeKey:
[more info](https://rawgit.com/pubnub/objective-c/4.0b3/docs/data/html/Classes/PNConfiguration.html)

```objective-c
self.myConfig = [PNConfiguration configurationWithPublishKey:_pubKey subscribeKey:_subKey];
```

In addition, if you have an existing Configuration that you simply wish to change the UUID or PAM token on, you can reuse an existing Configuration with one these methods:

##### – copyWithConfiguration:completion:
[more info](https://rawgit.com/pubnub/objective-c/4.0b3/docs/core/html/Classes/PubNub.html#//api/name/copyWithConfiguration:completion:)

##### – copyWithConfiguration:callbackQueue:completion:
[more info](https://rawgit.com/pubnub/objective-c/4.0b3/docs/core/html/Classes/PubNub.html#//api/name/copyWithConfiguration:callbackQueue:completion:)

**By using the above methods to reuse an existing configuration, when you subscribe again with this reused Configuration, you will resume (catchup) at the point in time where you left off.**

#### Configuration Options

Once you create a configuration, you can set the following options:

##### publishKey
[more info](https://rawgit.com/pubnub/objective-c/4.0b3/docs/data/html/Classes/PNConfiguration.html#//api/name/publishKey)

Your publish key is assigned to you via admin.pubnub.com. You can set it to nil if you prefer not to include this in your client, however, if you don't include it, you won't be able to publish.

##### subscribeKey
[more info](https://rawgit.com/pubnub/objective-c/4.0b3/docs/data/html/Classes/PNConfiguration.html#//api/name/subscribeKey)

Your subscribe key is assigned to you via admin.pubnub.com. It is mandatory.

##### authKey
[more info](https://rawgit.com/pubnub/objective-c/4.0b3/docs/data/html/Classes/PNConfiguration.html#//api/name/authKey)

authKey is used as an authorization token. You don't need to set this value, unless you are in a PAM-enabled environment.

##### uuid
[more info](https://rawgit.com/pubnub/objective-c/4.0b3/docs/data/html/Classes/PNConfiguration.html#//api/name/uuid)

UUID is used to uniquely ID a user. If you do not set one explicitly, a random one is generated for you.

##### cipherKey
[more info](https://rawgit.com/pubnub/objective-c/4.0b3/docs/data/html/Classes/PNConfiguration.html#//api/name/cipherKey)

cipherKey is the value used when enabling built-in AES encryption. If you do not set this value, all traffic is sent in plain text (unless TLS is enabled, and then, data is sent plaintext over an encrypted TLS connection.) This same value must be set across all client SDKs (regardless of platform) or you will not be able to bidirectionally communicate.

##### subscribeMaximumIdleTime
[more info](https://rawgit.com/pubnub/objective-c/4.0b3/docs/data/html/Classes/PNConfiguration.html#//api/name/subscribeMaximumIdleTime)

This is the subscribe request timeout. Do not modify this unless instructed by support.

##### nonSubscribeRequestTimeout
[more info](https://rawgit.com/pubnub/objective-c/4.0b3/docs/data/html/Classes/PNConfiguration.html#//api/name/nonSubscribeRequestTimeout)

This is the non-subscribe request timeout. Do not modify this unless instructed by support.

##### presenceHeartbeatValue
[more info](https://rawgit.com/pubnub/objective-c/4.0b3/docs/data/html/Classes/PNConfiguration.html#//api/name/presenceHeartbeatValue)

This value instructs the server to wait this amount of seconds without hearing from you. Not hearing from you is defined by not receiving a message, or you not sending a heartbeat. The default is 5 minutes.

##### presenceHeartbeatInterval
[more info](https://rawgit.com/pubnub/objective-c/4.0b3/docs/data/html/Classes/PNConfiguration.html#//api/name/presenceHeartbeatInterval)

This is the rate that the client will send heartbeats to the server. By default, it autosets at ((presenceHeartbeatValue/2) - 1) seconds.

##### TLSEnabled
[more info](https://rawgit.com/pubnub/objective-c/4.0b3/docs/data/html/Classes/PNConfiguration.html#//api/name/TLSEnabled)

This enables TLS (encrypted data transfer between client and server).

##### keepTimeTokenOnListChange
[more info](https://rawgit.com/pubnub/objective-c/4.0b3/docs/data/html/Classes/PNConfiguration.html#//api/name/keepTimeTokenOnListChange)
  
When changing channels, do you catchup where you left off (default YES), or do you get all new messages as of channel change completion?
  
##### restoreSubscription
[more info](https://rawgit.com/pubnub/objective-c/4.0b3/docs/data/html/Classes/PNConfiguration.html#//api/name/restoreSubscription)

If you lose the connection, do you automatically resubscribe (default YES) when you reconnect?

##### catchUpOnSubscriptionRestore
[more info](https://rawgit.com/pubnub/objective-c/4.0b3/docs/data/html/Classes/PNConfiguration.html#//api/name/catchUpOnSubscriptionRestore)
  
If you automatically resubscribe on connection restore, do you catchup? (default YES)

```objective-c
- (void)updateClientConfiguration {

    // Set PubNub Configuration
    self.myConfig.TLSEnabled = NO;
    self.myConfig.uuid = [self randomString];
    self.myConfig.origin = @"pubsub.pubnub.com";
    self.myConfig.authKey = _authKey;

    // Presence Settings
    self.myConfig.presenceHeartbeatValue = 120;
    self.myConfig.presenceHeartbeatInterval = 60;

    // Cipher Key Settings
    //self.client.cipherKey = @"enigma";

    // Time Token Handling Settings
    self.myConfig.keepTimeTokenOnListChange = YES;
    self.myConfig.restoreSubscription = YES;
    self.myConfig.catchUpOnSubscriptionRestore = YES;
}
```
#### Instantiate a Client Instance with a Config

Once you've created the instance, instantiate the instance using one of the below methods:

##### + clientWithConfiguration:
[more info](https://rawgit.com/pubnub/objective-c/4.0b3/docs/core/html/Classes/PubNub.html#//api/name/clientWithConfiguration:)

##### + clientWithConfiguration:callbackQueue:
[more info](https://rawgit.com/pubnub/objective-c/4.0b3/docs/core/html/Classes/PubNub.html#//api/name/clientWithConfiguration:callbackQueue:)

```objective-c
self.client = [PubNub clientWithConfiguration:self.myConfig];
```

#### Add a Listener in order to Receive Subscribe and Presence Stream Events

```objective-c
[self.client addListeners:@[self]];
```

A completed example of this step [can be found in the Hello World snippet](#hello-world)

### Time

– timeWithCompletion:
[more info](https://rawgit.com/pubnub/objective-c/4.0b3/docs/core/html/Classes/PubNub.html#//api/name/timeWithCompletion:)

Request current time from PubNub network.

```objective-c
    [self.client timeWithCompletion:^(PNTimeResult *result, PNErrorStatus *status) {
        if (result.data) {
            NSLog(@"Result from Time: %@", result.data.timetoken);
        }
        else if (status) {
            [self handleStatus:status];
        }
    }];
```

On success, result.data.timetoken will include the timetoken value. On status, review isError and category attributes to pinpoint the exact situation, and handle accordingly. See the [handleStatus:(PNStatus)status](Example/PubNub/PNAppDelegate.m#L528) method in Example for an example.

You can have multiple listeners across multiple files.


### Publish

– publish:toChannel:withCompletion:

– publish:toChannel:compressed:withCompletion:

– publish:toChannel:storeInHistory:withCompletion:

– publish:toChannel:storeInHistory:compressed:withCompletion:

– publish:toChannel:mobilePushPayload:withCompletion:

– publish:toChannel:mobilePushPayload:compressed:withCompletion:

– publish:toChannel:mobilePushPayload:storeInHistory:withCompletion:

– publish:toChannel:mobilePushPayload:storeInHistory:compressed:withCompletion:

– sizeOfMessage:toChannel:withCompletion:

– sizeOfMessage:toChannel:compressed:withCompletion:

– sizeOfMessage:toChannel:storeInHistory:withCompletion:

– sizeOfMessage:toChannel:compressed:storeInHistory:withCompletion:

[Full reference on Publish Methods is available here.](https://rawgit.com/pubnub/objective-c/4.0b3/docs/core/html/Classes/PubNub.html#//api/name/publish:toChannel:withCompletion:)

Publish a message.

```objective-c
    [self.client publish:@"Connected! I'm here!" toChannel:_channel1
          withCompletion:^(PNPublishStatus *status) {
              if (!status.isError) {
                  NSLog(@"Message sent at TT: %@", status.data.timetoken);
              } else {
                  [self handleStatus:status];
              }
          }];
    /*
    [self.client publish:<#(id)message#> toChannel:<#(NSString *)channel#> compressed:<#(BOOL)compressed#> withCompletion:<#(PNPublishCompletionBlock)block#>];
    [self.client publish:<#(id)message#> toChannel:<#(NSString *)channel#> withCompletion:<#(PNPublishCompletionBlock)block#>];
    [self.client publish:<#(id)message#> toChannel:<#(NSString *)channel#> storeInHistory:<#(BOOL)shouldStore#> withCompletion:<#(PNPublishCompletionBlock)block#>];
    [self.client publish:<#(id)message#> toChannel:<#(NSString *)channel#> storeInHistory:<#(BOOL)shouldStore#> compressed:<#(BOOL)compressed#> withCompletion:<#(PNPublishCompletionBlock)block#>];
    [self.client publish:<#(id)message#> toChannel:<#(NSString *)channel#> mobilePushPayload:<#(NSDictionary *)payloads#> withCompletion:<#(PNPublishCompletionBlock)block#>];
    [self.client publish:<#(id)message#> toChannel:<#(NSString *)channel#> mobilePushPayload:<#(NSDictionary *)payloads#> compressed:<#(BOOL)compressed#> withCompletion:<#(PNPublishCompletionBlock)block#>];
    [self.client publish:<#(id)message#> toChannel:<#(NSString *)channel#> mobilePushPayload:<#(NSDictionary *)payloads#> storeInHistory:<#(BOOL)shouldStore#> withCompletion:<#(PNPublishCompletionBlock)block#>];
    [self.client publish:<#(id)message#> toChannel:<#(NSString *)channel#> mobilePushPayload:<#(NSDictionary *)payloads#> storeInHistory:<#(BOOL)shouldStore#> compressed:<#(BOOL)compressed#> withCompletion:<#(PNPublishCompletionBlock)block#>];
    */
```

If sending with a 3rd Party Push payload, use a dictionary, with key(s) of "apns" and/or "gcm", with the correct corresponding payloads native for that platform. For example, to publish with an APNS specific payload, and a "for everyone else" payload, your dict may look like:

```javascript
{
    "apns": {
        "aps": {
            "alert": "Only associated iOS devices get this.",
            "badge": "5"
        },
        "fooDataForEveryone": {
            "bar": "Non-iOS devices will get payload, and the apns data as well.",
            "foobaz": "baz"
        }
    }
}
```

On success, isError will be NO, and status.data.timetoken will include the ingress timetoken value. If isError is YES, review the category attribute to pinpoint the exact situation, and handle accordingly. See the [handleStatus:(PNStatus)status](Example/PubNub/PNAppDelegate.m#L528) method in Example for an example.

### Subcribe / Unsubscribe

#### Subscribing to Channels, Channel Groups, and Presence Events

– subscribeToChannels:withPresence:

– subscribeToChannels:withPresence:clientState:

– subscribeToChannelGroups:withPresence:

– subscribeToChannelGroups:withPresence:clientState:

– subscribeToPresenceChannels:

– unsubscribeFromChannels:withPresence:

– unsubscribeFromChannelGroups:withPresence:

– unsubscribeFromPresenceChannels:

[The full subscribe and unsubscribe method reference can be found here.](https://rawgit.com/pubnub/objective-c/4.0b3/docs/core/html/Classes/PubNub.html#//api/name/subscribeToChannels:withPresence:)

Subscribe and Unsubscribe to Channels, Channel Groups, and Presence events.

PubNub returns data to the user via Result or Status objects. Because of the asyncronous, long-running characteristics of subscribe data, unlike other methods which return Result or Status objects via their associated completion blocks, subscribe Result and Status data is instead returned via listeners.

Add the class you wish to receive streaming Result and Status on as a listener (this is mandatory in order to receive streaming messages and statuses), using the [– addListeners:](https://rawgit.com/pubnub/objective-c/4.0b3/docs/core/html/Classes/PubNub.html#//api/name/addListeners:) method call.

Once the class is added as a listener, it will receive streaming events on the [following listener methods](PubNub/Misc/Protocols/PNObjectEventListener.h):

- (void)client:(PubNub *)client didReceiveMessage:(PNMessageResult *)message;

- (void)client:(PubNub *)client didReceivePresenceEvent:(PNPresenceEventResult *)event;

- (void)client:(PubNub *)client didReceiveStatus:(PNSubscribeStatus *)status;
    
A completed example of subscribing [can be found in the Hello World snippet](#hello-world). You can also see it in the Example app.  Example implementations of the above listeners, taken from Example, may look similar to:

```objective-c
- (void)client:(PubNub *)client didReceiveMessage:(PNMessageResult *)message {

    if (message) {
 
        NSLog(@"Received message: %@ on channel %@ at %@", message.data.message, message.data.subscribedChannel, message.data.timetoken);
    }
}

#pragma mark - Streaming Data didReceivePresenceEvent Listener

- (void)client:(PubNub *)client didReceivePresenceEvent:(PNPresenceEventResult *)event {
    NSLog(@"^^^^^ Did receive presence event: %@", event.data.data);
}

#pragma mark - Streaming Data didReceiveStatus Listener

- (void)client:(PubNub *)client didReceiveStatus:(PNSubscribeStatus *)status {

    // This is where we'll find ongoing status events from our subscribe loop
    // Results (messages) from our subscribe loop will be found in didReceiveMessage
    // Results (presence events) from our subscribe loop will be found in didReceiveStatus

    [self handleStatus:status];
}
```

When subscribing to channels and channel groups, message.data.message, message.data.subscribedChannel, and message.data.timetoken are the fields you can receive message data on.

When subscribing to Presence Events, event.data.data will contain the presence data dictionary.

All other streaming non-Result (Status) data is monitored via the didReceiveStatus listener. See the [handleStatus:(PNStatus)status](Example/PubNub/PNAppDelegate.m#L528) method in Example for an example on how to handle these sorts of things.

#### Listener Methods

Before a class can receive messages, it must be assigned as a listener. You can use the following methods to add and remove listeners:

– addListeners:

– removeListeners:

[The complete reference for these methods is available here.](https://rawgit.com/pubnub/objective-c/4.0b3/docs/core/html/Classes/PubNub.html#//api/name/addListeners:)


#### Determining Current Subscribtion Status

Use the following methods to determine which channels you are already subscribed to:

– channels

– channelGroups

– presenceChannels

– isSubscribedOn:

[The complete reference for these methods is available here](https://rawgit.com/pubnub/objective-c/4.0b3/docs/core/html/Classes/PubNub.html#//api/name/channels)

### History

[History methods](https://rawgit.com/pubnub/objective-c/4.0b3/docs/core/html/Classes/PubNub.html#//api/name/historyForChannel:withCompletion:) let you access PubNub's Storage and Playback system.

– historyForChannel:withCompletion:

– historyForChannel:start:end:withCompletion:

– historyForChannel:start:end:limit:withCompletion:

– historyForChannel:start:end:includeTimeToken:withCompletion:

– historyForChannel:start:end:limit:includeTimeToken:withCompletion:

– historyForChannel:start:end:limit:reverse:withCompletion:

– historyForChannel:start:end:limit:reverse:includeTimeToken:withCompletion:

```objective-c
    [self.client historyForChannel:_channel1 withCompletion:^(PNHistoryResult *result,
                                                              PNErrorStatus *status) {
        // For completion blocks that provide both result and status parameters, you will only ever
        // have a non-nil status or result.
        // If you have a result, the data you specifically requested (in this case, history response) is available in result.data
        // If you have a status, error or non-error status information is available regarding the call.

        if (status) {
            // As a status, this contains error or non-error information about the history request, but not the actual history data I requested.
            // Timeout Error, PAM Error, etc.

            [self handleStatus:status];
        }
        else if (result) {
            // As a result, this contains the messages, start, and end timetoken in the data attribute

            NSLog(@"Loaded history data: %@ with start %@ and end %@", result.data.messages, result.data.start, result.data.end);
        }
    }];
```
### Here and Where Now Methods

To determine [who is here now, and where someone is now we provide the Here Now and Where Now method calls.](https://rawgit.com/pubnub/objective-c/4.0b3/docs/core/html/Classes/PubNub.html#//api/name/hereNowWithCompletion:)

– hereNowWithCompletion:

– hereNowWithVerbosity:completion:

– hereNowForChannel:withCompletion:

– hereNowForChannel:withVerbosity:completion:

– hereNowForChannelGroup:withCompletion:

– hereNowForChannelGroup:withVerbosity:completion:

– whereNowUUID:withCompletion:

Who is here now, on this channel? Verbosity contructor allows us to set level of information returned. Using with non-verbosity version of method returns full information.

```objective-c

    // If you want to control the 'verbosity' of the server response -- restrict to (values are additive):

    // Occupancy                : PNHereNowOccupancy
    // Occupancy + UUID         : PNHereNowUUID
    // Occupancy + UUID + State : PNHereNowState

    [self.client hereNowForChannel:_channel1 withVerbosity:PNHereNowState
                        completion:^(PNPresenceChannelHereNowResult *result, PNErrorStatus *status) {
        if (status) {
            [self handleStatus:status];
        }
        else if (result) {
            NSLog(@"^^^^ Loaded hereNowForChannel data: occupancy: %@, uuids: %@", result.data.occupancy, result.data.uuids);
        }
    }];
```

Here now without a channel results in a "Global Here Now" -- shows everyone everywhere! Verbosity contructor allows us to set level of information returned. Using with non-verbosity version of method returns full information.

```objective-c
    // If you want to control the 'verbosity' of the server response -- restrict to (values are additive):

    // Occupancy                : PNHereNowOccupancy
    // Occupancy + UUID         : PNHereNowUUID
    // Occupancy + UUID + State : PNHereNowState

    [self.client hereNowWithVerbosity:PNHereNowOccupancy completion:^(PNPresenceGlobalHereNowResult *result,
                                                                      PNErrorStatus *status) {
        if (status) {
            [self handleStatus:status];
        }
        else if (result) {
            NSLog(@"^^^^ Loaded Global hereNow data: channels: %@, total channels: %@, total occupancy: %@", result.data.channels, result.data.totalChannels, result.data.totalOccupancy);
        }
    }];
    
```

Where is UUID x now? User Where Now to find out!

```objective-c
    [self.client whereNowUUID:@"123456" withCompletion:^(PNPresenceWhereNowResult *result,
                                                         PNErrorStatus *status) {
        if (status) {
            [self handleStatus:status];
        }
        else if (result) {
            NSLog(@"^^^^ Loaded whereNow data: %@", result.data.channels);
        }
    }];
```

### Admin for Channel Groups

[Channel Groups admin methods](https://rawgit.com/pubnub/objective-c/4.0b3/docs/core/html/Classes/PubNub.html#//api/name/channelGroupsWithCompletion:) enable you to administer which channels are included within which channel groups.

– channelGroupsWithCompletion:

– channelsForGroup:withCompletion:

– addChannels:toGroup:withCompletion:

– removeChannels:fromGroup:withCompletion:

– removeChannelsFromGroup:withCompletion:

Add Channels:

```objective-c
    [self.client addChannels:@[_channel1, _channel2] toGroup:_channelGroup1 withCompletion:^(PNAcknowledgmentStatus *status) {
        if (!status.isError) {
            NSLog(@"^^^^CGAdd request succeeded");
        } else {
            NSLog(@"^^^^CGAdd Subscribe request did not succeed. All subscribe operations will autoretry when possible.");
            [weakSelf handleStatus:status];
        }
    }];
```
    
Remove some channels from a group:

```objective-c
    [self.client removeChannels:@[_channel2] fromGroup:_channelGroup1 withCompletion:^(PNAcknowledgmentStatus *status) {
        if (!status.isError) {
            NSLog(@"^^^^CG Remove Some Channels request succeeded at timetoken %@.", status);
        } else {
            NSLog(@"^^^^CG Remove Some Channels request did not succeed. All subscribe operations will autoretry when possible.");
            [self handleStatus:status];
        }
    }];
```

Remove all channels from a group:

```objective-c
    [self.client removeChannelsFromGroup:_channelGroup1
                          withCompletion:^(PNAcknowledgmentStatus *status) {
        if (!status.isError) {
            NSLog(@"^^^^CG Remove All Channels request succeeded");
        } else {
            NSLog(@"^^^^CG Remove All Channels request did not succeed. All subscribe operations will autoretry when possible.");
            [self handleStatus:status];
        }
    }];
```

List all existing channels associated with a channel group:

```objective-c
    [self.client channelsForGroup:_channelGroup1
                   withCompletion:^(PNChannelGroupChannelsResult *result, PNErrorStatus *status) {
        if (status) {
            [self handleStatus:status];
        }
        else if (result) {
            NSLog(@"^^^^ Loaded all channels %@ for group %@",
                  result.data.channels, self->_channelGroup1);
        }
    }];
```

Note that only channelsForGroup:withCompletion: returns a Result or Status. The other Admin Channel Group methods will only return Status.

### Admin for State

The [Admin methods for State](https://rawgit.com/pubnub/objective-c/4.0b3/docs/core/html/Classes/PubNub.html#//api/name/setState:forUUID:onChannel:withCompletion:) allow you to set and get state which is displayed in Presence Results.

– setState:forUUID:onChannel:withCompletion:

– setState:forUUID:onChannelGroup:withCompletion:

– stateForUUID:onChannel:withCompletion:

– stateForUUID:onChannelGroup:withCompletion:

To get state:

```objective-c
    [self.client stateForUUID:_myConfig.uuid onChannel:_channel1
               withCompletion:^(PNChannelClientStateResult *result, PNErrorStatus *status) {
        if (status) {
            [self handleStatus:status];
        }
        else if (result) {
            
            NSLog(@"^^^^ Loaded state %@ for channel %@", result.data.state, self->_channel1);
        }

    }];
```

To set state:

```objective-c
    [self.client setState:@{[self randomString] : @{[self randomString] : [self randomString]}} forUUID:_myConfig.uuid onChannel:_channel1 withCompletion:^(PNClientStateUpdateStatus *status) {
        [self handleStatus:status];
    }];
```

### Admin for 3rd Party Notifications
[To associate deviceIDs with the PubNub Mobile Gateway](https://rawgit.com/pubnub/objective-c/4.0b3/docs/core/html/Classes/PubNub.html#//api/name/addPushNotificationsOnChannels:withDevicePushToken:andCompletion:) in order to fork messages sent via PubNub to APNS devices, use the Admin methods for 3rd Party Notifications.

– addPushNotificationsOnChannels:withDevicePushToken:andCompletion:

– removePushNotificationsFromChannels:withDevicePushToken:andCompletion:

– removeAllPushNotificationsFromDeviceWithPushToken:andCompletion:

– pushNotificationEnabledChannelsForDeviceWithPushToken:andCompletion:

### Public Encryption Methods

Sometimes its neccesary to manually encrypt and decrypt data using the same cipher PubNub uses internally. The [public AES Encrytpion Methods](https://github.com/pubnub/objective-c/blob/4.0b3/PubNub/Data/PNAES.h) provide the ability to do just that.

+ (NSString *)encrypt:(NSData *)data withKey:(NSString *)key;

+ (NSString *)encrypt:(NSData *)data withKey:(NSString *)key
             andError:(NSError *__autoreleasing *)error;
             
+ (NSData *)decrypt:(NSString *)object withKey:(NSString *)key;

+ (NSData *)decrypt:(NSString *)object withKey:(NSString *)key
           andError:(NSError *__autoreleasing *)error;             

### Logging

PNLog is the logging configuration Singleton that handles logging and log levels.

#### Enable / Disable

```objective-c
[PNLog enabled:YES]; # Enable
[PNLog enabled:NO];  # Disable
```


#### Log Rotation Settings

```objective-c
    [PNLog setMaximumLogFileSize:5];      # Value in MB. 5 is the default
    [PNLog setMaximumNumberOfLogFiles:5]; # 5 is the default
```
    



