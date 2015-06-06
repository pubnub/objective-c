# PubNub 4.0b2 for iOS 7+ (Beta, not for Production Use)

## Changes from 3.x
* 4.0 is a non-bw compatible REWRITE with 96% less lines of code than our 3.x!
* Removed support for iOS 6 and earlier
* Removed support for JSONKit
* Removed custom connection, request, logging, and reachability logic, replacing with NSURLSession, DDLog, and AFNetworking libraries
* Simplified serialization/deserialization threading logic
* Removed support for blocking, syncronous calls (all calls are now async)
* Simplified usability by enforcing completion block pattern -- client no longer supports Singleton, Delegate, Observer, Notifications response patterns
* Replaced configuration class with setter configuration pattern (same as NSURLSession)
* Consolidated instance method names
 
## Known issues and TODOs in beta2:

* Needs better handling for invalid API keys (right now fails with undefined error)
* Not all result status field attributes are being populated at Status emission time for all operations (will address via testing)
* Better documentation of logging options
* Verify HTTP pipelining behavior
* Provide Swift Bridge and associated docs
* Add automated integration testing
* Approach >= 75% automated test code coverage as we approach final release
* Subscribe catchup on unexpected disconnect/reconnect needs more testing

## Installing the Source

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
pod 'PubNub', :git => 'https://github.com/PubNub/objective-c.git', :branch => '4.0b2'
```

* Be sure the git argument in the Podfile is pointing to the [4.0b2 branch](https://github.com/pubnub/objective-c/tree/4.0b2) of the [PubNub source directory](https://github.com/pubnub/objective-c).

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
    [self.client addListeners:@[self]];

    [self.client subscribeToChannels:@[@"myChannel"] withPresence:NO];        
        
    

    return YES;
}
```

* Add a message listener method to your AppDelegate.m:

```objective-c
- (void)client:(PubNub *)client didReceiveMessage:(PNResult <PNMessageResult>*)message withStatus:(PNStatus *)status {
    
    if (status) {
        // analyze the status object for next steps -- See Example for in-depth examples
    } else if (message) {
        NSLog(@"Received message: %@", message.data.message);
    }
}
```

* If you have a [web console running](http://www.pubnub.com/console/?channel=myChannel&origin=d.pubnub.com&sub=demo&pub=demo), you can receive the hello world messages sent from your iOS app, as well as send messages from the web console, and see them appear in the didReceiveMessage listener!

Run the app, and watch it work!

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

1. [Calling a subscribe operation] (https://github.com/pubnub/objective-c/blob/4.0b2/Example/PubNub/PNAppDelegate.m#L96) will return Result objects (received messages) to the (didReceiveMessage listener)[https://github.com/pubnub/objective-c/blob/4.0b2/Example/PubNub/PNAppDelegate.m#L275] and Status objects  (such as PAM errors, Connect, Disconnect state changes) to the (didReceiveStatus listener)[https://github.com/pubnub/objective-c/blob/4.0b2/Example/PubNub/PNAppDelegate.m#L296]

2. [Calling a presence operation](https://github.com/pubnub/objective-c/blob/4.0b2/Example/PubNub/PNAppDelegate.m#L111) will return Result objects (Such as Join, Leave Presence Events) to the (didReceivePresenceEvents listener)[https://github.com/pubnub/objective-c/blob/4.0b2/Example/PubNub/PNAppDelegate.m#L286] and Status objects to the (didReceiveStatus listener)[https://github.com/pubnub/objective-c/blob/4.0b2/Example/PubNub/PNAppDelegate.m#L296]

Non-Streamed operation method calls use completion blocks which return either a result or status object. An example of this can be seen in the [history call example](https://github.com/pubnub/objective-c/blob/4.0b2/Example/PubNub/PNAppDelegate.m#L228).

## Reference App - Example

In Beta2, [we provide Example](https://github.com/pubnub/objective-c/tree/4.0b2/Example) as a generic reference on how to set config options, make Pub, Sub, and History calls (with and without PAM), and handle the various Status and Result events that may arise from them.  

As we approach final beta, full docs will become available as well. For now, the Example app is used as a reference app. It will evolve over time as we approach release and final docs.

If you have questions about how the Result and Status objects work in the meantime, feel free to contact support@pubnub.com and cc: geremy@pubnub.com, and we'll be happy to assist.
