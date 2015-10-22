# PubNub 4.1.1 for iOS 7+
## Please direct all Support Questions and Concerns to Support@PubNub.com
## Complete Docs
Check out our [official docs page](http://www.pubnub.com/docs/ios-objective-c/pubnub-objective-c-sdk-v4)

<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
**Table of Contents**  *generated with [DocToc](https://github.com/thlorenz/doctoc)*

- [Changes from 3.x](#changes-from-3x)
- [Changes from 4.0.7](#changes-from-407)
- [Setup and Hello World](#setup-and-hello-world)
- [Migrating from 3.x](#migrating-from-3x)
  - [Project Setup](#project-setup)
  - [Method Names and Overall Operation have changed](#method-names-and-overall-operation-have-changed)
  - [Removed support for iOS 6 and earlier](#removed-support-for-ios-6-and-earlier)
  - [Removed support for JSONKit](#removed-support-for-jsonkit)
  - [Removed support for blocking, synchronous calls (all calls are now async)](#removed-support-for-blocking-synchronous-calls-all-calls-are-now-async)
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
- [Complete Docs](#complete-docs)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

## Changes from 3.x
* 4.0 is a non-bw compatible REWRITE with 95% less lines of code than our 3.x!
* Removed support for iOS 6 and earlier
* Removed support for JSONKit
* Removed custom connection, request, logging, and reachability logic, replacing with NSURLSession, DDLog, and AFNetworking libraries
* Simplified serialization/deserialization threading logic
* Removed support for blocking, synchronous calls (all calls are now async)
* Simplified usability by enforcing completion block pattern -- client no longer supports Singleton, Delegate, Observer, Notifications response patterns
* Consolidated instance method namesv

## Changes from 4.0.7
* Added ability to build dynamic frameworks for iOS 8.0+
* Changed data type in -client:didReceiveStatus: callback from **PNSubscribeStatus** to **PNStatus**  
  This callback can accept at least three operation types: **PNSubscribeOperation**, **PNUnsubscribeOperation** and **PNHeartbeatOperation**.  
  **WARNING:** Ensure what you deal with expected status by checking _operation_ property for received status object.

## Setup and Hello World
To setup and get started immediately with a Hello World demo, check out our [offical docs page](http://www.pubnub.com/docs/ios-objective-c/pubnub-objective-c-sdk-v4).

## Migrating from 3.x

Its important to note that a lot of things have changed in 4.x. When migrating your applications from PN 3.x to PN 4.0, please be sure to read this section.

### Project Setup

We're using Cocoapods as our exclusive method of installing the client SDK. Please see "Setup and Hello World" above for the new way to configure PubNub 4.0 for iOS.

### Method Names and Overall Operation have changed

Please checkout the "New for 4.0" section below for a general overview of the major changes in the usage pattern introduced in 4.0.

### Removed support for iOS 6 and earlier

PubNub 4.0 for iOS supports iOS 7+. If you regard this as an issue, please contact us at support@pubnub.com.

### Removed support for JSONKit

This should only be an issue for you if you are supporting very old iOS versions. If you regard this as an issue, please contact us at support@pubnub.com.

### Removed support for blocking, synchronous calls (all calls are now async)

In the 3.x version of the client, the developer had the option to call a method blocking, or asynchronously. In the new version, asynchronously is the only option. Be sure that any blocking-dependent code is refactored to take the new 100% async behavior into account.

### Removed support for Singleton, Delegate, Observer, Notifications response patterns

We've removed the Singleton, Delegate, Observer, Notifications pattern support in 4.0, and instead provide you with one of two versitle alternatives on a per-method basis -- Completion Blocks, or Listeners.

Please checkout the "New for 4.0" section below for a general overview of the major changes in the usage pattern introduced in 4.0, as well as the Example app for more information.

### New Configuration Class

There is a new configuration class which is not backwards compatible with the configuration class introduced in 3.x. Be sure to examine the "Configuration" section below, or the Example app for proper usage.

### New Logger and Logging Options

In 4.x we use DDLog (Lumberjack) for our logging, and therefore, logging configuration has changed. Please see "Logging" below for more information on how to use the new logger.

Example:
```objective-c
[DDLog addLogger:[DDTTYLogger sharedInstance]];
```

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
    self.myConfig.TLSEnabled = YES; // Secure Connection
    self.myConfig.uuid = [self randomString]; // Setup a UUID
    self.myConfig.origin = @"pubsub.pubnub.com"; // Setup a custom origin. Don't do this unless support requests.
    self.myConfig.authKey = _authKey; // For PAM, an auth key for authorization

    // Presence Settings
    self.myConfig.presenceHeartbeatValue = 120; // Tell the server that the hearbeat timeout is 120s
    self.myConfig.presenceHeartbeatInterval = 60; // Send the heartbeat to the server every 60 seconds

    // Cipher Key Settings
    //self.client.cipherKey = @"enigma"; // Set this to enable PN AES encryption

    // Time Token Handling Settings
    self.myConfig.keepTimeTokenOnListChange = YES; // When changing channels, 'catchup' ?
    self.myConfig.restoreSubscription = YES; // If you lose the connection, should you resubscribe when it comes back?
    self.myConfig.catchUpOnSubscriptionRestore = YES; // If restoreSubscription == YES, catchup ? Or start at 'now' ?
```

## New for 4.0

Across all PubNub SDK client platforms, we are introducing the Result/Status model in 4.0. The Result/Status model simplifies handling of all types of PubNub Cloud responses, including method call results, status events (such as acknowledgements), errors (from expected errors like PAM 403s, to unexpected errors like timeouts or intermittent network layer issues) commonly encountered by mobile devices on-the-move.

### How its Received: Result and Status Event Objects

For any PubNub operation you call, you will be returned either a Result, or a Status, but never both at the same time.  A generic example of a history call being made in the Result/Status pattern looks like this:

```objc
[self.client historyForChannel:@"my_channel" start:nil end:nil limit:100
                withCompletion:^(PNHistoryResult *result, PNErrorStatus *status) {

    // Check whether request successfully completed or not.
    if (!status.isError) {

       // Handle downloaded history using:
       //   result.data.start - oldest message time stamp in response
       //   result.data.end - newest message time stamp in response
       //   result.data.messages - list of messages
    }
    // Request processing failed.
    else {

       // Handle message history download error. Check 'category' property to find
       // out possible issue because of which request did fail.
       //
       // Request can be resent using: [status retry];
    }
}];
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

1. [Calling a subscribe operation](Example/PubNub/PNAppDelegate.m#L260) will return Result objects (received messages) to the [didReceiveMessage listener](Example/PubNub/PNAppDelegate.m#L504) and Status objects  (such as PAM errors, Connect, Disconnect state changes) to the [didReceiveStatus listener](Example/PubNub/PNAppDelegate.m#L533)

2. [Calling a presence operation](Example/PubNub/PNAppDelegate.m#L250) will return Result objects (Such as Join, Leave Presence Events) to the [didReceivePresenceEvents listener](Example/PubNub/PNAppDelegate.m#L513) and Status objects to the [didReceiveStatus listener](Example/PubNub/PNAppDelegate.m#L533)

Non-Streamed operation method calls use completion blocks which return either a result or status object. An example of this can be seen in the [history call example](Example/PubNub/PNAppDelegate.m#L432).

If you have questions about how the Result and Status objects work in the meantime, feel free to contact support@pubnub.com and cc: geremy@pubnub.com, and we'll be happy to assist.

## Reference App - Example

In 4.0, [we provide Example](Example) as a generic reference on how to set config options, make Pub, Sub, and History calls (with and without PAM), and handle the various Status and Result events that may arise from them.  

The Example app is used as a simple reference app. It will evolve over time, along with other example apps -- stay tuned for that!

## Complete Docs
Check out our [official docs page](http://www.pubnub.com/docs/ios-objective-c/pubnub-objective-c-sdk-v4).

# Please direct all Support Questions and Concerns to Support@PubNub.com
