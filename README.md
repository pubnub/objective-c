<img width="1920" height="600" alt="objective-c-header" src="https://github.com/user-attachments/assets/b11e7793-d926-4f73-bd84-83546293cf0a" />

# PubNub Objective-C SDK

[![CocoaPods](https://img.shields.io/cocoapods/v/PubNub.svg)](https://cocoapods.org/pods/PubNub)

PubNub provides global infrastructure for real-time, interactive applications.

Publish and receive messages in Objective-C. Use this SDK for Objective-C applications on supported Apple platforms.

[Documentation](https://www.pubnub.com/docs/sdks/objective-c) · [API reference](https://www.pubnub.com/docs/sdks/objective-c/api-reference/publish-and-subscribe) · [Changelog](https://www.pubnub.com/docs/sdks/objective-c/changelog) · [Support](https://support.pubnub.com/)

## Requirements

| Requirement | Supported version or setup |
| --- | --- |
| Xcode / Objective-C | [Use the Apple platform versions listed in Platform Support](https://www.pubnub.com/docs/sdks/objective-c/platform-support) |
| Apple platforms | [iOS, macOS, tvOS, and watchOS targets supported by the SDK](https://www.pubnub.com/docs/sdks/objective-c/platform-support) |
| CocoaPods | Add PubNub 7.x to the Podfile, run `pod install`, and open the generated `.xcworkspace`. |

## Installation

Add the following to the application's Podfile:

```ruby
pod 'PubNub', '~> 7.0'
```

For other installation methods, see [environment setup](https://www.pubnub.com/docs/sdks/objective-c).

## Quickstart

This example runs in an Objective-C iOS application. It subscribes to `hello_world`, publishes one message, and prints the received text.

### Get your keys

1. Open the [PubNub Admin Portal](https://admin.pubnub.com/).
2. Create an app and a keyset for development, or select an existing development keyset.
3. Copy its publish key and subscribe key.

If Access Manager is enabled, obtain a token from your trusted backend and call `[client setAuthToken:token]`. Keep the secret key on the backend.

### Send and receive a message

Add the following to `ViewController.m` and make the view controller conform to `PNEventsListener`:

Replace the key placeholders. Use a User ID that identifies the user or device in your app.

```objective-c
#import "ViewController.h"
#import <PubNub/PubNub.h>

@interface ViewController () <PNEventsListener>
@property (nonatomic, strong) PubNub *client;
@property (nonatomic, assign) BOOL published;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    PNConfiguration *configuration =
        [PNConfiguration configurationWithPublishKey:@"YOUR_PUBLISH_KEY"
                                        subscribeKey:@"YOUR_SUBSCRIBE_KEY"
                                              userID:@"hello-world-user"];

    self.client = [PubNub clientWithConfiguration:configuration];
    [self.client addListener:self];

    PNSubscribeRequest *request = [PNSubscribeRequest requestWithChannels:@[@"hello_world"]
                                                            channelGroups:nil];
    [self.client subscribeWithRequest:request];
}

- (void)client:(PubNub *)client didReceiveStatus:(PNStatus *)status {
    if (status.category == PNConnectedCategory && !self.published) {
        self.published = YES;

        PNPublishRequest *request = [PNPublishRequest requestWithChannel:@"hello_world"];
        request.message = @"Hello world";
        [client publishWithRequest:request completion:^(PNPublishStatus *publishStatus) {
            if (publishStatus.isError) {
                NSLog(@"Publish failed: %@", publishStatus.errorData.information);
            }
        }];
    }
}

- (void)client:(PubNub *)client didReceiveMessage:(PNMessageResult *)message {
    NSLog(@"%@", message.data.message);

    PNPresenceLeaveRequest *request = [PNPresenceLeaveRequest requestWithChannels:@[@"hello_world"]
                                                                    channelGroups:nil];
    [client unsubscribeWithRequest:request];
    [client removeListener:self];
}

@end
```

### Run the example

```
Run the application target from Xcode.
```

The Xcode console should show:

```
Hello world
```

The example calls `unsubscribeWithRequest:` and `removeListener:` after receiving the message. Use `[client unsubscribeFromAll]` when all subscriptions should stop.

For a complete application, see the [getting started guide](https://www.pubnub.com/docs/sdks/objective-c).

## Next steps

| Task | Documentation |
| --- | --- |
| Configure the client | [Configuration](https://www.pubnub.com/docs/sdks/objective-c/api-reference/configuration) |
| Work with subscriptions and messages | [Publish & Subscribe](https://www.pubnub.com/docs/sdks/objective-c/api-reference/publish-and-subscribe) |
| Check channel occupancy | [Presence](https://www.pubnub.com/docs/sdks/objective-c/api-reference/presence) |
| Read message history | [Message Persistence](https://www.pubnub.com/docs/sdks/objective-c/api-reference/storage-and-playback) |

## Build with an AI coding assistant

The [PubNub MCP server](https://www.pubnub.com/docs/ai/pubnub-mcp-server) gives an AI coding assistant access to PubNub SDK documentation and PubNub APIs. Connect the assistant to the hosted server at `https://mcp.pubnub.com`, or run `npx @pubnub/mcp@latest` locally.

The [server repository](https://github.com/pubnub/pubnub-mcp-server) has setup steps for VS Code, Cursor, Claude Code, Claude Desktop, Codex, Gemini CLI, and OpenCode.

## Before production

Use [Access Manager](https://www.pubnub.com/docs/sdks/objective-c/api-reference/access-manager) to grant each client the permissions it needs. Keep the secret key on your backend. Never include it in a distributed client.

Reuse the PubNub client for the application/session. Unsubscribe channels that are no longer needed, use `[client unsubscribeFromAll]` to stop every subscription, and remove listeners with `removeListener:` when their owner is released.

Live delivery through PubNub SDKs is at-most-once. A subscriber can miss messages while disconnected or if its buffer overflows. For longer-gap recovery, see [Message Persistence](https://www.pubnub.com/docs/sdks/objective-c/api-reference/storage-and-playback).

## Troubleshooting

| Symptom | Check |
| --- | --- |
| Xcode cannot import PubNub after CocoaPods installation | Run `pod install` and open the generated `.xcworkspace`, not the original `.xcodeproj`. See the [Objective-C SDK guide](https://www.pubnub.com/docs/sdks/objective-c). |
| A publish succeeds but no message appears | Check the message handler, subscription readiness, keyset, and channel name. |
| `pod install` fails because the target's deployment target is lower than the PubNub minimum | Raise the `platform` version in the Podfile and the Xcode deployment target to the minimum listed in [Platform Support](https://www.pubnub.com/docs/sdks/objective-c/platform-support). |
| Extra clients or duplicate messages during development | Keep one client/listener set for the owning application component. Unsubscribe and remove listeners during lifecycle cleanup instead of accumulating listeners as controllers are recreated. |

For setup help, see [troubleshooting](https://www.pubnub.com/docs/sdks/objective-c/troubleshoot). Check [network status](https://status.pubnub.com/) for service incidents.

## Releases

Read the [changelog](https://www.pubnub.com/docs/sdks/objective-c/changelog) before upgrading.

For a major version change, review the [Objective-C SDK changelog](https://www.pubnub.com/docs/sdks/objective-c/changelog) for breaking changes before upgrading.

## Support and contributions

For setup or account help, contact [PubNub Support](https://support.pubnub.com/).

For a reproducible SDK bug, use [GitHub Issues](https://github.com/pubnub/objective-c/issues). Include the SDK version, runtime, and a small reproduction with credentials removed.

Build the supported Apple targets, run the repository test suite, and include tests for behavioral changes before opening a pull request.

## License

See the [PubNub Software Development Kit License Agreement](https://github.com/pubnub/objective-c/blob/master/LICENSE).
