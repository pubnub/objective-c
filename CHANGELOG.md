## v5.7.0
November 18 2024

#### Added
- Add custom message type support for the following APIs: publish, signal, share file, subscribe and history.

## v5.6.1
July 08 2024

#### Fixed
- Fix issue because of which wrong request timeout has been used.
- Fix issue with `PNSubscribeCursorData` which should have an optional `region` to handle user timetoken in received real-time messages.

## v5.6.0
June 27 2024

#### Added
- Decoder to map server response directly to the data models.
- Configurable request objects require less convenience methods to interact with PubNub REST API.
- Network layer rewritten as module.

## v5.5.0
June 12 2024

#### Added
- Adjusting to FCM HTTP v1 API.

## v5.4.1
April 30 2024

#### Fixed
- Match `include` folder content to the `import` in source code.

## v5.4.0
April 16 2024

#### Added
- Adding PrivacyInfo.xcprivacy.

## v5.3.0
December 19 2023

#### Added
- Add the ability to set automatic request retry configuration in `PNConfiguration`.

## v5.2.1
October 30 2023

#### Modified
- Update license information.

## v5.2.0
October 16 2023

#### Added
- Add a crypto module with a set of implemented cryptors.

#### Modified
- Mark `uuid` as deprecated configuration property.
- Fix warnings after project settings update.

## v5.1.3
December 13 2022

#### Fixed
- Serialise access to previously created session configuration objects from different threads.

## v5.1.2
December 09 2022

#### Fixed
- Fix issue because of which message de-duplication code leaked memory.

## v5.1.1
September 06 2022

#### Fixed
- Fix the issue because of which `PNFilesManager` leaked each time when PubNub client was created.

## v5.1.0
March 11 2022

#### Added
- Make it possible to use PubNub Objective-C SDK using SPM.

## v5.0.0
January 12 2022

#### Modified
- BREAKING CHANGES: Disable automated `uuid` generation and make it mandatory to specify during PNConfiguration instance creation.

## v4.17.0
September 22 2021

#### Added
- Add method which allow to set or parse auth token.

## [v4.16.2](https://github.com/pubnub/objective-c/releases/tag/v4.16.2)
June 9 2021

[Full Changelog](https://github.com/pubnub/objective-c/compare/v4.16.1...v4.16.2)

#### Modified
- Add download error checks in Files API integration tests to have ability investigate random test failure with data download on Travis. 
- Add `arm64` architecture to pre-compiled PubNub SDK Framework bundles for their usage on Apple M1 enabled computers. 

#### Fixed
- Fix issue because of which null-able completion block wasn't properly verified and caused application crash. 
- Fix compiler warnings on type mismatch. 

## [v4.16.1](https://github.com/pubnub/objective-c/releases/tag/v4.16.1)
March 16 2021

[Full Changelog](https://github.com/pubnub/objective-c/compare/v4.16.0...v4.16.1)

#### Fixed
- Replace `os_unfair_lock` with `pthread_mutex` to avoid cases when `os_unfair_lock_lock` called from same thread more than once. 

## [v4.16.0](https://github.com/pubnub/objective-c/releases/tag/v4.16.0)
March 9 2021

#### Added
- BREAKING CHANGE: Add randomized initialization vector usage by default for data encryption / decryption in publish / subscribe / history API calls. 

## [v4.15.11](https://github.com/pubnub/objective-c/releases/tag/v4.15.11)
February 6 2021

[Full Changelog](https://github.com/pubnub/objective-c/compare/v4.15.10...v4.15.11)

#### Added
- Add `heartbeat` to `subscribe` REST API call when `managePresenceListManually` is set to YES. 

## [v4.15.10](https://github.com/pubnub/objective-c/releases/tag/v4.15.10)
February 6 2021

[Full Changelog](https://github.com/pubnub/objective-c/compare/v4.15.9...v4.15.10)

#### Fixed
- Fix `copyWithConfiguration:completion:` which sometime stuck because of long-poll subscribe. 

## [v4.15.9](https://github.com/pubnub/objective-c/releases/tag/v4.15.9)
February 4 2021

#### Fixed
- Make `PNBasePublishRequest` header publicly visible. Addresses the following PRs from [@dymv](https://github.com/dymv): [#424](https://github.com/pubnub/objective-c/pull/424).
- Fix issue because of which subscriber reset heartbeat timer while in manual presence management mode. 

## [v4.15.8](https://github.com/pubnub/objective-c/releases/tag/v4.15.8)
November 16 2020

[Full Changelog](https://github.com/pubnub/objective-c/compare/v4.15.7...v4.15.8)

#### Added
- Add new parameters to `Here Now` builder-based API to get presence information for list of channels or channel groups. 

## [v4.15.7](https://github.com/pubnub/objective-c/releases/tag/v4.15.7)
October 3 2020

[Full Changelog](https://github.com/pubnub/objective-c/compare/v4.15.6...v4.15.7)

#### Added
- Add `timetoken` from file information publish call into `PNSendFileStatus` object. 

## [v4.15.6](https://github.com/pubnub/objective-c/releases/tag/v4.15.6)
September 26 2020

[Full Changelog](https://github.com/pubnub/objective-c/compare/v4.15.5...v4.15.6)

#### Fixed
- Fix issue because of which `PNPublishSequence` metrics data migration caused application crash. 
- Fix subscription loop issue caused by broken bytes array with null-byte in it. 

## [v4.15.5](https://github.com/pubnub/objective-c/releases/tag/v4.15.5)
September 18 2020

[Full Changelog](https://github.com/pubnub/objective-c/compare/v4.15.4...v4.15.5)

#### Modified
- Increase default number of messages returned by History v3, when single channel passed, to 100 messages per single call. 

## [v4.15.4](https://github.com/pubnub/objective-c/releases/tag/v4.15.4)
September 10 2020

[Full Changelog](https://github.com/pubnub/objective-c/compare/v4.15.3...v4.15.4)

#### Modified
- Update code to ensure that persistent and in-memory storage accessed in thread-safe way. 

#### Fixed
- Fix issue because of which migrated data didn't placed at proper place. 

## [v4.15.3](https://github.com/pubnub/objective-c/releases/tag/v4.15.3)
August 13 2020

[Full Changelog](https://github.com/pubnub/objective-c/compare/v4.15.2...v4.15.3)

#### Added
- Add `include_message_type` option to fetch messages and history with message actions APIs. 
- Add `include_uuid` option to fetch messages and history with message actions APIs. 

#### Modified
- Replace content type, which is returned by server during upload url generation, using system capabilities to detect MIME type by file extension. 
- Split current Keychain helper to two separate storage options: in-memory and Keychain. Keychain will be used when possible and in-memory for cases when Keychain not available and macOS. 

#### Fixed
- After Keychain reorganization publish sequence manager has been restructured to use dispatch queue instead of SpinLock. 

## [v4.15.2](https://github.com/pubnub/objective-c/releases/tag/v4.15.2)
August 1 2020

[Full Changelog](https://github.com/pubnub/objective-c/compare/v4.15.1...v4.15.2)

#### Fixed
- Add same set of query parameters to download URL as any regular operation to PubNub service. 
- Fix issue with files larger than 32 kilobytes. 

## [v4.15.1](https://github.com/pubnub/objective-c/releases/tag/v4.15.1)
July 28 2020

[Full Changelog](https://github.com/pubnub/objective-c/compare/v4.15.0...v4.15.1)

#### Fixed
- Fix default issues after migration to publish requests objects usage because of which `replicate` and `store` has been reset to `false`. 

## [v4.15.0](https://github.com/pubnub/objective-c/releases/tag/v4.15.0)
July 27 2020

[Full Changelog](https://github.com/pubnub/objective-c/compare/v4.14.2...v4.15.0)

#### Added
- Add send file API support which allow encrypt (if configured) and upload file to `channel`. 
- Add download file API support which allow download file from `channel` and decrypt (if configured). 
- Add list files API support which allow retrieve information about files sent to `channel`. 
- Add delete file API support to permanently remove file from `channel`. 
- Add file message publish API which allow notify about new file upload completion (should be used to recover from internal publish error). 
- Add new subscribe events listener to handle new files events. 
- Add new methods to PNAES which allow to encrypt / decrypt file at local file system. 
- Add new option for PubNub client configuration and PNAES methods to use random initialization vector instead of hard-coded when files / data is encrypted / decrypted. 

## [v4.14.2](https://github.com/pubnub/objective-c/releases/tag/v4.14.2)
June 19 2020

[Full Changelog](https://github.com/pubnub/objective-c/compare/v4.14.1...v4.14.2)

#### Fixed
- Make device push tokens added to `excluded_devices` lowercase. 

## [v4.14.1](https://github.com/pubnub/objective-c/releases/tag/v4.14.1)
June 6 2020

[Full Changelog](https://github.com/pubnub/objective-c/compare/v4.14.0...v4.14.1)

#### Added
- By default, all requests which is able to return multiple objects, will return their total count (corresponding `includeFields` flag is set). 

#### Modified
- Renamed group of methods which is responsible for `channel` members management / audit. 

## [v4.14.0](https://github.com/pubnub/objective-c/releases/tag/v4.14.0)
May 29 2020

[Full Changelog](https://github.com/pubnub/objective-c/compare/v4.13.2...v4.14.0)

#### Added
- Add simplified Objects API support with UUID and Channel metadata / membership management. 

#### Modified
- Deprecate and replace old `PNObjectEventListener` protocol with new one `PNEventsListener`. 
- Update tests which has been used for previous Objects API version to test simplified Objects. 

## [v4.13.2](https://github.com/pubnub/objective-c/releases/tag/v4.13.2)
May 18 2020

[Full Changelog](https://github.com/pubnub/objective-c/compare/v4.13.1...v4.13.2)

#### Modified
- Update `.pubnub.yml` features matrix with missing features. 

#### Fixed
- Don't create lowercase string when FCM device registration token provided to PubNub notifications API. 

## [v4.13.1](https://github.com/pubnub/objective-c/releases/tag/v4.13.1)
March 26 2020

[Full Changelog](https://github.com/pubnub/objective-c/compare/v4.13.0...v4.13.1)

#### Modified
- Remove line breaks which affect change log generator. Addresses the following PRs from [@samiahmedsiddiqui](https://github.com/samiahmedsiddiqui): [#423](https://github.com/pubnub/objective-c/pull/423).

#### Fixed
- Remove Fabric components from `PubNub.podspec` because they have been removed from SDK with latest release. 

## [v4.13.0](https://github.com/pubnub/objective-c/releases/tag/v4.13.0)
March 9 2020

[Full Changelog](https://github.com/pubnub/objective-c/compare/v4.12.0...v4.13.0)

#### Added
- Add additional functionality which allow to filter out received Objects (memberships, members, spaces or users) by specified criteria. 
- Add new parameters which allow specify criteria (list of field names with sort direction `:asc` / `:desc` for each) order in which objects appear in response. 
- Add scripts which is responsible for SDK release roll out from tag in private repository. 

#### Modified
- Presence state should set / fetch fail w/o actual request to server when list of channels / groups and uuid is missing. 
- Increase covered up to 85% with integration tests on all functionality (75%) and unit tests on builder-pattern / request interface. 

#### Fixed
- Fix issue because of which `connected` interface didn't called completion block when `managePresenceListManually` is set to `NO`. 
- Fix issue because of which `includeMetadata` and `includeMessageActions` flags has been swapped. 
- Fix issue because of which actual retry never happened in case if subscription failed because PAM reported that client with current `authKey` doesn't have access rights to channels / groups. 
- Fix issue which didn't reset subscribe time-token when `keepTimeTokenOnListChange` is set to `NO` and `tryCatchUpOnSubscriptionRestore` is set to `YES`. 
- Remove 'macOS' from supported platforms in iOS Framework targets and rely on command-line specified flags to build Framework with Catalyst support. 

## [v4.12.0](https://github.com/pubnub/objective-c/releases/tag/v4.12.0)
December 5 2019

[Full Changelog](https://github.com/pubnub/objective-c/compare/v4.11.1...v4.12.0)

#### Added
- Add support for new endpoint which allow register and use devices with APNS2.
- Add new interfaces (builder-based API also has been modified) which allow pass device push token / identifier (not only NSData) using specific push service type.
- Add class which simplify basic notifications composition for multiple platforms / providers at once.
#### Modified
- Expose utility class which allow to manage data in `Keychain` (iOS).
#### Fixed
- Fix non-JSON response handling from `History` v2 endpoints when storage add-on not enabled for used keys.

## [v4.11.1](https://github.com/pubnub/objective-c/releases/tag/v4.11.1)
November 25 2019

[Full Changelog](https://github.com/pubnub/objective-c/compare/v4.11.0...v4.11.1)

#### Added
- Add proper Catalyst framework support with separate build target `XCFramework (Catalyst)` which is bundled with binaries which allow it to be used for: device / simulator and macOS.
#### Modified
- Change build scripts which now produce `XCFrameworks` with separate slices for device and simulator instead of `fat` binaries created with `lipo`.
#### Fixed
- Fix headers visibility in frameworks project. 

## [v4.11.0](https://github.com/pubnub/objective-c/releases/tag/v4.11.0)
October 8 2019

[Full Changelog](https://github.com/pubnub/objective-c/compare/v4.10.1...v4.11.0)

#### Added
- Add Message Actions API support which allow to: add, remove and fetch previously added actions.
- Add new method to simple interface and argument to builder pattern interface which allow to fetch previously added actions and message metadata.
- Add new argument to history builder pattern to fetch message metadata.
- Add new callback to `PNObjectEventListener` to track `message actions` events.
#### Modified
- Enhance publish sequence manager performance by making save only if any change has been done.

## [v4.10.1](https://github.com/pubnub/objective-c/releases/tag/v4.10.1)
August 30 2019

[Full Changelog](https://github.com/pubnub/objective-c/compare/v4.10.0...v4.10.1)

#### Fixed
- Add missing import of Objects API interface to frameworks umbrella header.

## [v4.10.0](https://github.com/pubnub/objective-c/releases/tag/v4.10.0)
August 27 2019

[Full Changelog](https://github.com/pubnub/objective-c/compare/v4.9.0...v4.10.0)

#### Added
- Add support for Space Objects API.
- Add support for User Objects API.
- Add support for Membership / Member Objects API.
- Add new callback to `PNObjectEventListener` to track `space` events.
- Add new callback to `PNObjectEventListener` to track `user` events.
- Add new callback to `PNObjectEventListener` to track `membership` events.

## [v4.9.0](https://github.com/pubnub/objective-c/releases/tag/v4.9.0)
August 8 2019

[Full Changelog](https://github.com/pubnub/objective-c/compare/v4.8.11...v4.9.0)

#### Added
- Add support for Signal API.
- Add new callback to `PNObjectEventListener` to track `signal` events.
#### Modified
- Remove deprecated `stripMobilePayload` configuration option from SDK along with code, which used it.
- Disable pipelining for requests.
#### Fixed
- Fix crash which is caused by attempt to de-duplicate message which PubNub client wasn't able to decrypt with configured `cipherKey`.

## [v4.8.11](https://github.com/pubnub/objective-c/releases/tag/v4.8.11)
July 15 2019

[Full Changelog](https://github.com/pubnub/objective-c/compare/v4.8.10...v4.8.11)

#### Added
- Add macOS support for iOS frameworks.

## [v4.8.10](https://github.com/pubnub/objective-c/releases/tag/v4.8.10)
June 27 2019

[Full Changelog](https://github.com/pubnub/objective-c/compare/v4.8.9...v4.8.10)

#### Modified
- Update outdated configuration object inline help documentation.
#### Fixed
- Fix subscribe request timeout missing `reconnect` event.
- Fix empty heartbeat value set to minimum on configuration copy.

## [v4.8.9](https://github.com/pubnub/objective-c/releases/tag/v4.8.9)
June 17 2019

[Full Changelog](https://github.com/pubnub/objective-c/compare/v4.8.8...v4.8.9)

#### Added
- Add ability to specify FCM token for APNS API.
#### Fixed
- Fix system version parsing when OS language set to Japanese.

## [v4.8.8](https://github.com/pubnub/objective-c/releases/tag/v4.8.8)
May 16 2019

[Full Changelog](https://github.com/pubnub/objective-c/compare/v4.8.7...v4.8.8)

#### Modified
- Add value wrapping around heartbeat 'value'.
- Separate tests project from main workspace.
#### Fixed
- Fix universal Frameworks build script.

## [v4.8.7](https://github.com/pubnub/objective-c/releases/tag/v4.8.7)
March 28 2019

[Full Changelog](https://github.com/pubnub/objective-c/compare/v4.8.6...v4.8.7)

#### Modified
- Resolve project warnings, which caused issues with Carthage framework build.

## [v4.8.6](https://github.com/pubnub/objective-c/releases/tag/v4.8.6)
March 26 2019

[Full Changelog](https://github.com/pubnub/objective-c/compare/v4.8.5...v4.8.6)

#### Fixed
- Fix builder API interface visibility for frameworks.

## [v4.8.5](https://github.com/pubnub/objective-c/releases/tag/v4.8.5)
March 16 2019

[Full Changelog](https://github.com/pubnub/objective-c/compare/v4.8.4...v4.8.5)

#### Modified
- Move `Keychain` records update calls to secondary queue (sometime `Keychain` take too much time to update and block main queue).
#### Fixed
- Fix message count result object header file visibility for frameworks.

## [v4.8.4](https://github.com/pubnub/objective-c/releases/tag/v4.8.4)
March 11 2019

[Full Changelog](https://github.com/pubnub/objective-c/compare/v4.8.3...v4.8.4)

#### Added
- Add ability to retrieve number of messages in specified channels using timetoken as reference date.
#### Modified
- Remove channel names sorting from utility class (because of which new API wasn't able to work properly).

## [v4.8.3](https://github.com/pubnub/objective-c/releases/tag/v4.8.3)
November 13 2018

[Full Changelog](https://github.com/pubnub/objective-c/compare/v4.8.2...v4.8.3)

#### Added
- Add ability to get / set presence state for multiple channel / groups (at once).

## [v4.8.2](https://github.com/pubnub/objective-c/releases/tag/v4.8.2)
November 7 2018

[Full Changelog](https://github.com/pubnub/objective-c/compare/v4.8.1...v4.8.2)

#### Added
- Add ability to set arbitrary query parameters during API call.

## [v4.8.1](https://github.com/pubnub/objective-c/releases/tag/v4.8.1)
June 21 2018

[Full Changelog](https://github.com/pubnub/objective-c/compare/v4.8.0...v4.8.1)

#### Modified
- Change client's data storage on macOS from `Keychain` to file-based.

## [v4.8.0](https://github.com/pubnub/objective-c/releases/tag/v4.8.0)
June 19 2018

[Full Changelog](https://github.com/pubnub/objective-c/compare/v4.7.8...v4.8.0)

#### Added
- Add methods which allow to manually manage presence.
- Add client configuration option to enable manual presence list management.
#### Fixed
- Fix implicit `self` retain in block warnings.

## [v4.7.8](https://github.com/pubnub/objective-c/releases/tag/v4.7.8)
May 7 2018

[Full Changelog](https://github.com/pubnub/objective-c/compare/v4.7.7...v4.7.8)

#### Modified
- Silence implicit `self` usage in blocks.
- Move listeners collection access serialization on queue to prevent access to property during non-atomic store.

## [v4.7.7](https://github.com/pubnub/objective-c/releases/tag/v4.7.7)
February 14 2018

[Full Changelog](https://github.com/pubnub/objective-c/compare/v4.7.6...v4.7.7)

#### Fixed
- Fix issue because of which channel(s) and/or group(s) wasn't able to maintain user's presence with heartbeat.
- Fix log file attributes to prevent their backup locally or to iCloud.

## [v4.7.6](https://github.com/pubnub/objective-c/releases/tag/v4.7.6)
February 1 2018

[Full Changelog](https://github.com/pubnub/objective-c/compare/v4.7.5...v4.7.6)

#### Fixed
- Fix issue because of which new `connected` presence API wasn't able to `disconnect` user.
- Fix behavior during unsubscribe - connect event won't fire after user `disconnect`, because there is no new channels about which listeners should be notified.

## [v4.7.5](https://github.com/pubnub/objective-c/releases/tag/v4.7.5)
December 16 2017

[Full Changelog](https://github.com/pubnub/objective-c/compare/v4.7.4...v4.7.5)

#### Added
- Add ability to change client's presence without actual subscription to channels/groups (based on heartbeat and presence leave API).
#### Fixed
- Fix Xcode warnings about partly API availability.
- Fix race of conditions for logger.
- Fix pre-compile macro usage to send metrics when code is running on device with pre-iOS 10 version.

## [v4.7.4](https://github.com/pubnub/objective-c/releases/tag/v4.7.4)
November 15 2017

[Full Changelog](https://github.com/pubnub/objective-c/compare/v4.7.3...v4.7.4)

#### Added
- Add ability to completely disable PubNub's client logger with `PUBNUB_DISABLE_LOGGER` build configuration macro.

## [v4.7.3](https://github.com/pubnub/objective-c/releases/tag/v4.7.3)
October 31 2017

[Full Changelog](https://github.com/pubnub/objective-c/compare/v4.7.2...v4.7.3)

#### Added
- Add `suppressLeaveEvents` parameter to `PNConfiguration` which allow to suppress presence leave API call on unsubscription.
#### Fixed
- Fix issue because of which there was a chance to create second subscribe request while subscription loop has been restarted with new timetoken.

## [v4.7.2](https://github.com/pubnub/objective-c/releases/tag/v4.7.2)
October 16 2017

[Full Changelog](https://github.com/pubnub/objective-c/compare/v4.7.1...v4.7.2)

#### Added
- Add new method to unsubscribe from all channels and groups with completion block.
#### Modified
- Remove `receiver-is-weak` clang warning suppression since it has been deprecated.
#### Fixed
- Fix issue because of which unsubscribe requests didn't terminated previous long-poll subscribe request.

## [v4.7.1](https://github.com/pubnub/objective-c/releases/tag/v4.7.1)
September 15 2017

[Full Changelog](https://github.com/pubnub/objective-c/compare/v4.7.0...v4.7.1)

#### Fixed
- Fix telemetry shared data access issues.

## [v4.7.0](https://github.com/pubnub/objective-c/releases/tag/v4.7.0)
August 28 2017

[Full Changelog](https://github.com/pubnub/objective-c/compare/v4.6.3...v4.7.0)

#### Added
- Add `delete message` functionality.
#### Modified
- Remove deprecated flag from `stripMobilePayload` so it will only print out deprecation warning in console w/o actual warning in Xcode.
- Adjust telemetry cache clean up interval.
#### Fixed
- Fix issue with wildcard subscription and presence events which treated as messages.
- Fix issue with `copyWithConfiguration` method which removed client itself from state change observers.
- Fix de-duplication messages cache size issue.
- Fix issue because of which requests metrics gathered only if `metrics` log level has been enabled.

## [v4.6.3](https://github.com/pubnub/objective-c/releases/tag/v4.6.3)
August 21 2017

[Full Changelog](https://github.com/pubnub/objective-c/compare/v4.6.2...v4.6.3)

#### Fixed
- Fix bug with channel group subscription from previous release.

## [v4.6.2](https://github.com/pubnub/objective-c/releases/tag/v4.6.2)
July 19 2017

[Full Changelog](https://github.com/pubnub/objective-c/compare/v4.6.1...v4.6.2)

#### Added
- Add ability to gather service performance information.
- Add new error category `PNRequestURITooLongCategory` to properly handle and report issues to callbacks and completion blocks.
#### Modified
- Remove unsubscribe request cancellation by sequential call to subscribe API.
- Reorganize code which is responsible for subscribe requests cancellation.
#### Fixed
- Fix issue with macOS Keychain access in multi-user environment when none authorized.
- Fix inline documentation.

## [v4.6.1](https://github.com/pubnub/objective-c/releases/tag/v4.6.1)
April 26 2017

[Full Changelog](https://github.com/pubnub/objective-c/compare/v4.6.0...v4.6.1)

#### Fixed
- Fix dependency analysis warnings for Fabric integration via CocoaPods.

## [v4.6.0](https://github.com/pubnub/objective-c/releases/tag/v4.6.0)
March 31 2017

[Full Changelog](https://github.com/pubnub/objective-c/compare/v4.5.15...v4.6.0)

#### Added
- Add support for presence deltas.

## [v4.5.15](https://github.com/pubnub/objective-c/releases/tag/v4.5.15)
March 15 2017

[Full Changelog](https://github.com/pubnub/objective-c/compare/v4.5.14...v4.5.15)

#### Added
- Add `pn-` prefix for client-provided unique user identifiers.
- Add `OSSpinLock` and `os_unfair_lock` switch.
#### Modified
- Change pre-compile macro for URLSession metrics gathering delegate usage.
- Persistent UUID storage and tests deprecated API silenced.

## [v4.5.14](https://github.com/pubnub/objective-c/releases/tag/v4.5.14)
March 8 2017

[Full Changelog](https://github.com/pubnub/objective-c/compare/v4.5.13...v4.5.14)

#### Fixed
- Fix uuid and auth keys encoding in query string.

## [v4.5.13](https://github.com/pubnub/objective-c/releases/tag/v4.5.13)
March 3 2017

[Full Changelog](https://github.com/pubnub/objective-c/compare/v4.5.12...v4.5.13)

#### Added
- Add TCP metrics output to PubNub logs (added corresponding logger level).
- Add information about `stripMobilePayload` deprecation to Xcode console with guide what can be done next.
#### Modified
- Deprecate `stripMobilePayload` property.

## [v4.5.12](https://github.com/pubnub/objective-c/releases/tag/v4.5.12)
January 5 2017

[Full Changelog](https://github.com/pubnub/objective-c/compare/v4.5.11...v4.5.12)

#### Modified
- Change default origin.

## [v4.5.11](https://github.com/pubnub/objective-c/releases/tag/v4.5.11)
December 16 2016

[Full Changelog](https://github.com/pubnub/objective-c/compare/v4.5.10...v4.5.11)

#### Modified
- Revert default origin reverted back to `pubsub.pubnub.com`

## [v4.5.10](https://github.com/pubnub/objective-c/releases/tag/v4.5.10)
December 16 2016

[Full Changelog](https://github.com/pubnub/objective-c/compare/v4.5.9...v4.5.10)

#### Modified
- Change object which is stored in cache which is used for de-duplication.
- Change default origin.

## [v4.5.9](https://github.com/pubnub/objective-c/releases/tag/v4.5.9)
November 26 2016

[Full Changelog](https://github.com/pubnub/objective-c/compare/v4.5.8...v4.5.9)

#### Fixed
- Fix cached messages identifier list clean up.

## [v4.5.8](https://github.com/pubnub/objective-c/releases/tag/v4.5.8)
November 25 2016

[Full Changelog](https://github.com/pubnub/objective-c/compare/v4.5.7...v4.5.8)

#### Added
- Add new configuration property `maximumMessagesCacheSize` which allow to enable (when non-zero value passed) messages de-duplication logic.

## [v4.5.7](https://github.com/pubnub/objective-c/releases/tag/v4.5.7)
November 20 2016

[Full Changelog](https://github.com/pubnub/objective-c/compare/v4.5.6...v4.5.7)

#### Added
- Add additional service response check and wrap (in case if still somehow non-dictionary reached data objects).
- Add `APPLICATION_EXTENSION_API_ONLY` flag to `PubNub.podspec` and Framework targets.
#### Modified
- Remove `PNClass` and added manual service response parsers registration (in attempt to solve third-party classes initialization at run-time).
#### Fixed
- Fix issue because of which `reverse` flag had same value as `include timetokens`.

## [v4.5.6](https://github.com/pubnub/objective-c/releases/tag/v4.5.6)
November 16 2016

[Full Changelog](https://github.com/pubnub/objective-c/compare/v4.5.5...v4.5.6)

#### Added
- Add multi-channel history request API to API call builder interface.
- Add ability to subscribe / unsubscribe to/from channels and/or groups with single API call.
- Add ability to receive message sender identifier.
- Add verbose logs around subscription loop timetoken usage.
#### Modified
- Deprecate `restoreSubscription` property.

## [v4.5.5](https://github.com/pubnub/objective-c/releases/tag/v4.5.5)
November 2 2016

[Full Changelog](https://github.com/pubnub/objective-c/compare/v4.5.4...v4.5.5)

#### Added
- Add ability to specify for how long published message should be stored in channel's storage (added into API call builder interface)
#### Fixed
- Fix `instanceID` which is placed inside of `PNConfiguration` - if it require to setup new client it will have same `instanceID`. Now `instanceID` is set per PubNub client instance.

## [v4.5.4](https://github.com/pubnub/objective-c/releases/tag/v4.5.4)
October 27 2016

[Full Changelog](https://github.com/pubnub/objective-c/compare/v4.5.3...v4.5.4)

#### Added
- Add application extension environment support (`applicationExtensionSharedGroupIdentifier` PNConfiguration property).
- Add `fire` and `replicate` options to publish API call builder.
- Add messages count threshold configuration property (`requestMessageCountThreshold`) which allow to specify how many messages client can receive without `PNRequestMessageCountExceededCategory` status object sending (to `-client:didReceiveStatus:` observer callback).
- Add `instanceid` query property to simplify multi client debug.
- Add `requestid` query property for each request to force proxy servers to not cache responses and debug purposes.
- Add builder pattern for API calls.
#### Modified
- Updated Fastlane configuration to speed test stage up.
#### Fixed
- Fix issue with shared auto-updating user calendar which is used with logger (calendar instance created every time when timestamp information is required).

## [v4.5.3](https://github.com/pubnub/objective-c/releases/tag/v4.5.3)
September 26 2016

[Full Changelog](https://github.com/pubnub/objective-c/compare/v4.5.2...v4.5.3)

#### Added
- Add `NS_SWIFT_NAME` with Swift equivalent specified in it to all public API. This allow to prevent Swift function signature generator from changing it between Swift releases.

## [v4.5.2](https://github.com/pubnub/objective-c/releases/tag/v4.5.2)
September 13 2016

[Full Changelog](https://github.com/pubnub/objective-c/compare/v4.5.1...v4.5.2)

#### Added
- Add published message sequence number to publish API call (this information arrive as message envelope and used for issues debugging).
- Add logger method which will allow to use it from Swift.
- Add automatic heartbeat interval using formula and heartbeat value for calculated value.
- Add `channel` and `subscription` properties to represent channel from which event arrived and actual data stream name which is used by PubNub client for subscription.
#### Modified
- Deprecate `actualChannel` and `subscribedChannel` in favor of `channel` and `subscription` (properties still available, but will be eventually will be completely removed).

## [v4.5.1](https://github.com/pubnub/objective-c/releases/tag/v4.5.1)
September 2 2016

[Full Changelog](https://github.com/pubnub/objective-c/compare/v4.5.0...v4.5.1)

#### Modified
- Change default logs directory which should be used for tvOS client.

## [v4.5.0](https://github.com/pubnub/objective-c/releases/tag/v4.5.0)
August 31 2016

[Full Changelog](https://github.com/pubnub/objective-c/compare/v4.4.1...v4.5.0)

#### Added
- Add ability to complete issued API calls before application will be suspended (happens by default for iOS).
- Add PNConfiguration property called `completeRequestsBeforeSuspension` which allow to change default behavior (for iOS).
- Add ability to disable message stripping (removing data which has been added by client during publish with mobile payload) which is enabled by default
- Add Carthage support.
#### Modified
- Framework targets build bundle with bitcode enabled by default.
- Remove dependency against `CocoaLumberjack` and replaced with own logger. 

## [v4.4.1](https://github.com/pubnub/objective-c/releases/tag/v4.4.1)
July 8 2016

[Full Changelog](https://github.com/pubnub/objective-c/compare/v4.4.0...v4.4.1)

#### Added
- Add tests to cover fixed issue.
#### Fixed
- Fix timeout issue which caused by recently added shared `NSURLSessionConfiguration` configuration.

## [v4.4.0](https://github.com/pubnub/objective-c/releases/tag/v4.4.0)
July 8 2016

[Full Changelog](https://github.com/pubnub/objective-c/compare/v4.3.3...v4.4.0)

#### Added
- Add ability provide limited customization of `NSURLSessionConfiguration`.
- Add bitcode support for frameworks.

## [v4.3.3](https://github.com/pubnub/objective-c/releases/tag/v4.3.3)
May 17 2016

[Full Changelog](https://github.com/pubnub/objective-c/compare/v4.3.2...v4.3.3)

#### Fixed
- Fix podspec dependency version format compatibiliyty with CocoaPods 0.39.

## [v4.3.2](https://github.com/pubnub/objective-c/releases/tag/v4.3.2)
May 13 2016

[Full Changelog](https://github.com/pubnub/objective-c/compare/v4.3.1...v4.3.2)

#### Added
- Add original message (in case of decryption error) will be passed into `associatedObject` of `PNStatus` error instance.
#### Fixed
- Fix issue for case when client doesn't use encryption and message has been received w/o mobile payload to clean up.

## [v4.3.1](https://github.com/pubnub/objective-c/releases/tag/v4.3.1)
May 12 2016

[Full Changelog](https://github.com/pubnub/objective-c/compare/v4.3.0...v4.3.1)

#### Modified
- `pn_other` key has been removed and original object will be returned in delegate callback (this field used with message encryption and/or mobile push payload).
- Mobile push payload removed from received message.
#### Fixed
- Fix issue with PNNumber on 32bit system, when passed NSNumber instance created from unix-timestamp multiplied on 10000000.
- Fix message content descryption in case if it has been sent along with mobile push payload.

## [v4.3.0](https://github.com/pubnub/objective-c/releases/tag/v4.3.0)
May 3 2016

[Full Changelog](https://github.com/pubnub/objective-c/compare/v4.2.7...v4.3.0)

#### Added
- Add Pub/Sub V2 API support.
- Add message filtering basing on published message metadata.
- Add ability to publish message with additional metadata for filtering purposes.
- Add generics to collection properties and arguments.
- Add nulability annotations.
#### Modified
- Update inline documentation formatting.
- Update tests.
#### Fixed
- Fix occupancy value storage for state-change (it will be set if available).
- Fix issue with presence here now request where 'nil' passed as channel / group.
- Fix script responsible for module map update in built frameworks.
- Fix `Universal Startic Frameork (iOS)` to use correct platform.
- Add missing files to Mac Framework.

## [v4.2.7](https://github.com/pubnub/objective-c/releases/tag/v4.2.7)
September 2 2016

[Full Changelog](https://github.com/pubnub/objective-c/compare/v4.2.6...v4.2.7)

#### Added
- Add `heartbeatNotificationOptions` bitfield to PNConfiguration which can set how heartbeat state reported to listeners (using `PNHeartbeatNotificationOptions`).
#### Modified
- Remove `notifyAboutFailedHeartbeatsOnly` PNConfiguration property in favor of `heartbeatNotificationOptions` bitfield.

## [v4.2.6](https://github.com/pubnub/objective-c/releases/tag/v4.2.6)
September 2 2016

[Full Changelog](https://github.com/pubnub/objective-c/compare/v4.2.5...v4.2.6)

#### Added
- Add new property to PNConfiguration class called `notifyAboutFailedHeartbeatsOnly` which allow to configure client to notify not only about failed heartbeat statuses but for success as well.

## [v4.2.5](https://github.com/pubnub/objective-c/releases/tag/v4.2.5)
January 27 2016

[Full Changelog](https://github.com/pubnub/objective-c/compare/v4.2.4...v4.2.5)

#### Added
- Add private persistent storage which allow to keep crucial data safe on device.
- Add new target to build dynamic framework for tvOS.
#### Fixed
- Fix issue with time token precision verification in case if non-PubNub's time token value has been passe.

## [v4.2.4](https://github.com/pubnub/objective-c/releases/tag/v4.2.4)
January 12 2016

[Full Changelog](https://github.com/pubnub/objective-c/compare/v4.2.3...v4.2.4)

#### Fixed
- Fix issue because of which client may not restore subscription on list of channels which has been left after previous unsubscription request.

## [v4.2.3](https://github.com/pubnub/objective-c/releases/tag/v4.2.3)
December 20 2015

[Full Changelog](https://github.com/pubnub/objective-c/compare/v4.2.2...v4.2.3)

#### Fixed
- Fix unsubscription issue because of which time token didn't get reset if there is no more channels on which client may continue subscription.
- Fix issue with `-unsubscribeFromAll` which may issue unwanted subscribe requests in case if method call followed by subscribe method call.

## [v4.2.2](https://github.com/pubnub/objective-c/releases/tag/v4.2.2)
December 14 2015

[Full Changelog](https://github.com/pubnub/objective-c/compare/v4.2.1...v4.2.2)

#### Added
- Add ability to build static library based frameworks (universal as well).
- Add Fabric support.

## [v4.2.1](https://github.com/pubnub/objective-c/releases/tag/v4.2.1)
December 10 2015

[Full Changelog](https://github.com/pubnub/objective-c/compare/v4.2.0...v4.2.1)

#### Fixed
- Fix client state cache issue because of which channel group state itself get updated even if state has been changed for one of channels from this group.

## [v4.2.0](https://github.com/pubnub/objective-c/releases/tag/v4.2.0)
December 2 2015

[Full Changelog](https://github.com/pubnub/objective-c/compare/v4.1.4...v4.2.0)

#### Added
- Add ability to set arbitrarily time token to catch up from into Subscribe API.
- Add ability to specify time tokens not only as 17 digit, but time interval from NSDate acceptable too.
- Add stringified representation for category and operation fields.
#### Modified
- Remove client initialisation code which affected PNLogger configuration.
#### Fixed
- Fix Mac OSX target and scripts for dynamic framework creation.

## [v4.1.4](https://github.com/pubnub/objective-c/releases/tag/v4.1.4)
November 24 2015

[Full Changelog](https://github.com/pubnub/objective-c/compare/v4.1.3...v4.1.4)

#### Added
- Add watchOS deployment information to PubNub.podspec file.

## [v4.1.3](https://github.com/pubnub/objective-c/releases/tag/v4.1.3)
November 20 2015

[Full Changelog](https://github.com/pubnub/objective-c/compare/v4.1.2...v4.1.3)

#### Modified
- Update Base64 decoding settings which will allow to decode encrypted messages from some clients which changed base64 encoding algorithms.

## [v4.1.2](https://github.com/pubnub/objective-c/releases/tag/v4.1.2)
November 16 2015

[Full Changelog](https://github.com/pubnub/objective-c/compare/v4.1.1...v4.1.2)

#### Modified
- Change `build configuration` from Debug to Release for framework building targets.
- Updated demo projects to correctly handle disconnection event (which happen for unsubscribe operation not for subscribe).
- Logger will print out current verbosity level information every time when it will be changed.
- All components (except core components) will add information about component to log output in format `<PubNub::{component}>`.
#### Fixed
- Fix listener `disconnect` status handling after client stumbled on network issues and reported `unexpected disconnect`.
- Fix issue because of which string has been stored inside of serviceData for PNErrorStatus created from NSError.

## [v4.1.1](https://github.com/pubnub/objective-c/releases/tag/v4.1.1)
October 22 2015

[Full Changelog](https://github.com/pubnub/objective-c/compare/v4.1.0...v4.1.1)

#### Modified
- Remove deprecated string encoding methods.
#### Fixed
- Fix memory issues with PNNetwork instance.

## [v4.1.0](https://github.com/pubnub/objective-c/releases/tag/v4.1.0)
October 15 2015

[Full Changelog](https://github.com/pubnub/objective-c/compare/v4.0.8...v4.1.0)

#### Added
- Add ability to build dynamic frameworks for iOS 8.0+.

## [v4.0.8](https://github.com/pubnub/objective-c/releases/tag/v4.0.8)
October 14 2015

[Full Changelog](https://github.com/pubnub/objective-c/compare/v4.0.7...v4.0.8)

#### Added
- Exposed heartbeat error to `-client:didReceiveStatus:`.
#### Fixed
- FIx ping triggering logic after corner case with network issues.

## [v4.0.7](https://github.com/pubnub/objective-c/releases/tag/v4.0.7)
October 3 2015

[Full Changelog](https://github.com/pubnub/objective-c/compare/v4.0.6...v4.0.7)

#### Fixed
- Fix issue which prevented proper `-retry` execution.

## [v4.0.6](https://github.com/pubnub/objective-c/releases/tag/v4.0.6)
October 1 2015

[Full Changelog](https://github.com/pubnub/objective-c/compare/v4.0.5...v4.0.6)

#### Modified
- Downgrade deployment target in Podspec file from 8.0 to 7.0.
- Update Podspec file organization.
- Update logger macro usage.

## [v4.0.5](https://github.com/pubnub/objective-c/releases/tag/v4.0.5)
September 20 2015

[Full Changelog](https://github.com/pubnub/objective-c/compare/v4.0.4...v4.0.5)

#### Added
- Add conditional device ID specification in request constructor.
- Add client information class.
- Add ObjC/Swift test for crypto issue.
#### Modified
- Suppress designated initializer warnings.
#### Fixed
- Fix issue with messages decryption in history and real-time messaging API.

## [v4.0.4](https://github.com/pubnub/objective-c/releases/tag/v4.0.4)
September 2 2015

[Full Changelog](https://github.com/pubnub/objective-c/compare/v4.0.3...v4.0.4)

#### Added
- Add additional presence events tests.
#### Fixed
- Fix subscriber parser issue because of which channel group name and actual channel changed their places in status object for presence event.
- Fix non-multiplexing subscription issue.
- Fix issue with missing presence event handling.

## [v4.0.3](https://github.com/pubnub/objective-c/releases/tag/v4.0.3)
July 24 2015

[Full Changelog](https://github.com/pubnub/objective-c/compare/v4.0.2...v4.0.3)

#### Added
- Add custom `User-Agent` header field.
#### Modified
- Remove CocoaPods post-install script from Podfile.
- Change test environment check.
#### Fixed
- Fix and change data types for few data objects (which caused crash in swift environment).
- Fix size tests to handle updated packet size during tests.
- Fix Podfile.

## [v4.0.2](https://github.com/pubnub/objective-c/releases/tag/v4.0.2)
July 13 2015

[Full Changelog](https://github.com/pubnub/objective-c/compare/v4.0.1...v4.0.2)

#### Added
- Add `associatedObject` field to PNErrorStatus (for now only for decryption error on live feed).
#### Modified
- Report real-time messages decryption error to `-client:didReceiveMessage:`.
- Report error if empty array of channels passed to enable push notifications.
- Replace AFNetworking with native NSURLSession wrapper.
#### Fixed
- Fix issues with composed message publish (with mobile push payloads).
- Fix inability to publish mobile gateway payloads only.
- Fix issue with number publishing.
- Fix code which had warnings from clang.
- Fix logger levels manipulation.
- Fix demo application which provided wrong logger configuration for log file size.
- Fix podspec to suppress warnings which appeared because private headers has been exposed to public.

## [v4.0.1](https://github.com/pubnub/objective-c/releases/tag/v4.0.1)
June 30 2015

[Full Changelog](https://github.com/pubnub/objective-c/compare/v4.0...v4.0.1)

#### Modified
- Update documentation hosted by CocoaPods.

## [v4.0.0](https://github.com/pubnub/objective-c/releases/tag/v4.0)
June 30 2015

[Full Changelog](https://github.com/pubnub/objective-c/compare/v3.7.11...v4.0)

#### Added
- The new, refactored PN 4.0 for iOS is Here!
