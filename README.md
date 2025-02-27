# PubNub 5.8.0 for iOS 9+
[![Twitter](https://img.shields.io/badge/twitter-%40PubNub-blue.svg?style=flat)](https://twitter.com/PubNub)
[![Twitter Releases](https://img.shields.io/badge/twitter-%40PubNubRelease-blue.svg?style=flat)](https://twitter.com/PubNubRelease)
[![CocoaPods Compatible](https://img.shields.io/cocoapods/v/PubNub.svg?style=flat)](https://img.shields.io/cocoapods/v/PubNub.svg)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![Platform](https://img.shields.io/cocoapods/p/PubNub.svg?style=flat)](https://img.shields.io/cocoapods/p/PubNub.svg)
[![Docs Coverage](https://img.shields.io/cocoapods/metrics/doc-percent/PubNub.svg?style=flat)](https://img.shields.io/cocoapods/metrics/doc-percent/PubNub.svg)

This is the official PubNub Objective-C SDK repository.

PubNub takes care of the infrastructure and APIs needed for the realtime communication layer of your application. Work on your app's logic and let PubNub handle sending and receiving data across the world in less than 100ms.

## Get keys

You will need the publish and subscribe keys to authenticate your app. Get your keys from the [Admin Portal](https://dashboard.pubnub.com/login).

## Configure PubNub

1. Install the latest [`cocoapods`](https://guides.cocoapods.org/using/getting-started.html) gem by running the `gem install cocoapods` command. If you already have this gem, make sure to update to the latest version by running the `gem update cocoapods` command.

2. Create a new Xcode project and create a `Podfile` in the root folder of the project:

    ```
    pod init
    ```

    ```groovy
    platform :ios, '9.0'

    target 'application-target-name' do
        use_frameworks!

        pod "PubNub", "~> 4"
    end
    ```

    If you want to include additional pods or add other targets, add their entries to this Podfile as well. Refer to the [CocoaPods documentation](https://guides.cocoapods.org/syntax/podfile.html#target) for more information on Podfile configuration.

3. Install your pods by running the `pod install` command from the directory which contains your Podfile. After installing your Pods, you should work with the CocoaPods-generated workspace and not the original project file.

4. Import the PubNub headers in the classes where you want to use PubNub:

    ```objectivec
    #import <PubNub/PubNub.h>
    ```

5. Configure your keys:

    ```objectivec
    // Initialize and configure PubNub client instance
    PNConfiguration *configuration = [PNConfiguration configurationWithPublishKey: @"myPublishKey" subscribeKey:@"mySubscribeKey"];
    configuration.uuid = @"myUniqueUUID";

    self.client = [PubNub clientWithConfiguration:configuration];
    ```

## Add event listeners

```objectivec
// Listener's class should conform to `PNEventsListener` protocol
// in order to have access to available callbacks.

// Adding listener.
[pubnub addListener:self];

// Callbacks listed below.

- (void)client:(PubNub *)pubnub didReceiveMessage:(PNMessageResult *)message {
    NSString *channel = message.data.channel; // Channel on which the message has been published
    NSString *subscription = message.data.subscription; // Wild-card channel or channel on which PubNub client actually subscribed
    NSNumber *timetoken = message.data.timetoken; // Publish timetoken
    id msg = message.data.message; // Message payload
    NSString *publisher = message.data.publisher; // Message publisher
}

- (void)client:(PubNub *)pubnub didReceiveSignal:(PNSignalResult *)signal {
    NSString *channel = message.data.channel; // Channel on which the signal has been published
    NSString *subscription = message.data.subscription; // Wild-card channel or channel on which PubNub client actually subscribed
    NSNumber *timetoken = message.data.timetoken; // Signal timetoken
    id msg = message.data.message; // Signal payload
    NSString *publisher = message.data.publisher; // Signal publisher
}

- (void)client:(PubNub *)pubnub didReceiveMessageAction:(PNMessageActionResult *)action {
    NSString *channel = action.data.channel; // Channel on which the message has been published
    NSString *subscription = action.data.subscription; // Wild-card channel or channel on which PubNub client actually subscribed
    NSString *event = action.data.event; // Can be: added or removed
    NSString *type = action.data.action.type; // Message action type
    NSString *value = action.data.action.value; // Message action value
    NSNumber *messageTimetoken = action.data.action.messageTimetoken; // Timetoken of the original message
    NSNumber *actionTimetoken = action.data.action.actionTimetoken; // Timetoken of the message action
    NSString *uuid = action.data.action.uuid; // UUID of user which added / removed message action
}

- (void)client:(PubNub *)pubnub didReceivePresenceEvent:(PNPresenceEventResult *)event {
    NSString *channel = message.data.channel; // Channel on which presence changes
    NSString *subscription = message.data.subscription; // Wild-card channel or channel on which PubNub client actually subscribed
    NSString *presenceEvent = event.data.presenceEvent; // Can be: join, leave, state-change, timeout or interval
    NSNumber *occupancy = event.data.presence.occupancy; // Number of users subscribed to the channel (not available for state-change event)
    NSNumber *timetoken = event.data.presence.timetoken; // Presence change timetoken
    NSString *uuid = event.data.presence.uuid; // UUID of user for which presence change happened

    // Only for 'state-change' event
    NSDictionary *state = event.data.presence.state; // User state (only for state-change event)

    // Only for 'interval' event
    NSArray<NSString *> *join = event.data.presence.join; // UUID of users which recently joined channel
    NSArray<NSString *> *leave = event.data.presence.leave; // UUID of users which recently leaved channel
    NSArray<NSString *> *timeout = event.data.presence.timeout; // UUID of users which recently timed out on channel
}

- (void)client:(PubNub *)pubnub didReceiveObjectEvent:(PNObjectEventResult *)event {
    NSString *channel = event.data.channel; // Channel to which the event belongs
    NSString *subscription = event.data.subscription; // Wild-card channel or channel on which PubNub client actually subscribed
    NSString *event = event.data.event; // Can be: set or delete
    NSString *type = event.data.type; // Entity type: channel, uuid or membership
    NSNumber *timestamp = event.data.timestamp; // Event timestamp

    PNChannelMetadata *channelMetadata = event.data.channelMetadata; // Updated channel metadata (only for channel entity type)
    PNUUIDMetadata *uuidMetadata = event.data.uuidMetadata; // Updated channel metadata (only for uuid entity type)
    PNMembership *membership = event.data.membership; // Updated channel metadata (only for membership entity type)
}

- (void)client:(PubNub *)pubnub didReceiveFileEvent:(PNFileEventResult *)event {
    NSString *channel = event.data.channel; // Channel to which file has been uploaded
    NSString *subscription = event.data.subscription; // Wild-card channel or channel on which PubNub client actually subscribed
    id message = event.data.message; // Message added for uploaded file
    NSString *publisher = event.data.publisher; // UUID of file uploader
    NSURL *fileDownloadURL = event.data.file.downloadURL; // URL which can be used to download file
    NSString *fileIdentifier = event.data.file.identifier; // Unique file identifier
    NSString *fileName = event.data.file.name; // Name with which file has been stored remotely
}

- (void)client:(PubNub *)pubnub didReceiveStatus:(PNStatus *)status {
    PNStatusCategory category = status.category; // One of PNStatusCategory fields to identify status of operation processing
    PNOperationType operation = status.operation; // One of PNOperationType fields to identify for which operation status received
    BOOL isError = status.isError; // Whether any kind of error happened.
    NSInteger statusCode = status.statusCode; // Related request processing status code
    BOOL isTLSEnabled = status.isTLSEnabled; // Whether secured connection enabled
    NSString *uuid = status.uuid; // UUID which configured for passed client
    NSString *authKey = status.authKey; // Auth key configured for passed client
    NSString *origin = status.origin; // Origin against which request has been sent
    NSURLRequest *clientRequest = status.clientRequest; // Request which has been used to send last request (may be nil)
    BOOL willAutomaticallyRetry = status.willAutomaticallyRetry; // Whether client will try to perform automatic retry

    // Following is available when operation == PNSubscribeOperation,
    // because status is PNSubscribeStatus instance in this case
    PNSubscribeStatus *subscribeStatus = (PNSubscribeStatus *)status;
    NSNumber *currentTimetoken = subscribeStatus.currentTimetoken; // Timetoken which has been used for current subscribe request
    NSNumber *lastTimeToken = subscribeStatus.lastTimeToken; // Timetoken which has been used for previous subscribe request
    NSArray<NSString *> *subscribedChannels = subscribeStatus.subscribedChannels; // List of channels on which client currently subscribed
    NSArray<NSString *> *subscribedChannelGroups = subscribeStatus.subscribedChannelGroups; // List of channel groups on which client currently subscribed
    NSString *channel = subscribeStatus.data.channel; // Name of channel to which status has been received
    NSString *subscription = subscribeStatus.data.subscription; // Wild-card channel or channel on which PubNub client actually subscribed
    NSNumber *timetoken = subscribeStatus.data.timetoken; // Timetoken at which event arrived
    NSDictionary *userMetadata = subscribeStatus.data.userMetadata; // Metadata / envelope which has been passed along with event

    // Following is available when isError == YES,
    // because status is PNErrorStatus instance in this case
    PNErrorStatus *errorStatus = (PNErrorStatus *)status;
    id associatedObject = errorStatus.associatedObject; // Data which may contain related information (not decrypted message for example)
    NSArray<NSString *> *erroredChannels = errorStatus.errorData.channels; // List of channels for which error reported (mostly because of PAM)
    NSArray<NSString *> *erroredChannelGroups = errorStatus.errorData.channelGroups; // List of channel groups for which error reported (mostly because of PAM)
    NSString *errorInformation = errorStatus.errorData.information; // Stringified information about error
    id errorData = errorStatus.errorData.data; // Additional error information from PubNub service
}
```

## Publish/subscribe

```objectivec
[self.client publish:@{ @ "msg": @"hello" } toChannel:targetChannel 
      withCompletion:^(PNPublishStatus *publishStatus) {
          if (!publishStatus.isError) {
              // Message successfully published to specified channel.
          } else {
              /**
               * Handle message publish error. Check 'category' property to find out
               * possible reason because of which request did fail.
               * Review 'errorData' property (which has PNErrorData data type) of status
               * object to get additional information about issue.
               *
               * Request can be resent using: [publishStatus retry];
               */
          }
}];

[self.client subscribeToChannels: @[@"hello-world-channel"] withPresence:YES];
```

## Documentation

* [API reference for Objective-C (iOS)](https://www.pubnub.com/docs/ios-objective-c/pubnub-objective-c-sdk)
* [API reference for Objective-C (Cocoa)](https://www.pubnub.com/docs/cocoa-objective-c/pubnub-objective-c-sdk)

## Support

If you **need help** or have a **general question**, contact support@pubnub.com.

## License

The PubNub Swift SDK is released under the `PubNub Software Development Kit License`.

[See LICENSE](https://github.com/pubnub/objective-c/blob/master/LICENSE) for details.
