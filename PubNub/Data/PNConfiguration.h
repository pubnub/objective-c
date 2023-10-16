#import <Foundation/Foundation.h>
#import <PubNub/PNCryptoProvider.h>
#import <PubNub/PNStructures.h>


NS_ASSUME_NONNULL_BEGIN

/**
 * @brief \b PubNub client configuration wrapper.
 *
 * @discussion Use this instance to provide values which should be by client to communicate with
 * \b PubNub network.
 *
 * @author Sergey Mamontov
 * @since 4.0
 * @copyright © 2010-2018 PubNub, Inc.
 */
/// **PubNub** client configuration wrapper.
///
/// Use this instance to provide values which should be by client to communicate with **PubNub** network.
///
/// - Since: 4.0.0
/// - Copyright: 2010-2023 PubNub, Inc.
@interface PNConfiguration : NSObject


#pragma mark Initialization and Configuration

/// Host name or IP address which should be used by client to get access to the **PubNub** network.
///
/// This property is set to **ps.pndsn.com** by default.
@property (nonatomic, copy) NSString *origin;

/// Key which is used to push data / state to the **PubNub** network.
///
/// > Note: This key can be obtained on PubNub's [administration](https://admin.pubnub.com) portal after free
/// registration
@property (nonatomic, copy) NSString *publishKey;

/// Key which is used to fetch data / state from the **PubNub** network.
///
/// > Note: This key can be obtained on PubNub's [administration](https://admin.pubnub.com) portal after free
/// registration
@property (nonatomic, copy) NSString *subscribeKey;

/// Key which is used along with every request to the **PubNub** network to identify client user.
///
/// **PubNub** provides **PAM** (PubNub Access Manager) functionality which allow to specify access rights to access
/// **PubNub** network with provided `publishKey` and `subscribeKey` keys.
/// Access can be limited to concrete users. **PAM** system use this key to check whether client user has rights to
/// access to required service or not.
///
/// This property not set by default.
@property (nonatomic, nullable, copy) NSString *authKey;

/// Unique client identifier used to identify concrete client user from another which currently use **PubNub** services.
///
/// This value is different from `authKey` (which is used only by **PAM**) and represent concrete client across server.
/// This identifier is used for presence events to tell what some client joined or leaved live feed.
///
/// > Warning: There can't be two same client identifiers online at the same time.
///
/// - Throws: An exception in case if `uuid` is empty string.
@property (nonatomic, copy, setter = setUUID:) NSString *uuid
    DEPRECATED_MSG_ATTRIBUTE("This property deprecated and will be removed with next major update. Please use `userID` "
                             "instead.");

/// Unique client identifier used to identify concrete client user from another which currently use **PubNub** services.
///
/// This value is different from `authKey` (which is used only by **PAM**) and represent concrete client across server.
/// This identifier is used for presence events to tell what some client joined or leaved live feed.
///
/// > Warning: There can't be two same client identifiers online at the same time.
///
/// - Throws: An exception in case if `userID` is empty string.
@property (nonatomic, copy, setter = setUserID:) NSString *userID;

/// Key for data _encryption_ and _decryption_.
///
/// Key which is used to _encrypt_ messages pushed to the **PubNub** network and decrypt data received from live feeds
/// on which client subscribed at this moment.
@property (nonatomic, nullable, copy) NSString *cipherKey
DEPRECATED_MSG_ATTRIBUTE("This property deprecated and will be removed with next major update. Please use "
                         "`cryptoModule` instead.");

/// Crypto module for data processing.
///
/// **PubNub** client uses this instance to _encrypt_ and _decrypt_ data that has been sent and received from the
/// **PubNub** network.
@property(nonatomic, strong) id<PNCryptoProvider> cryptoModule;

/// Unique device identifier based on bundle identifier used by software vendor.
@property (nonatomic, readonly, copy) NSString *deviceID;

/// Maximum number of seconds which client should wait for events from live feed.
///
/// If in specified time frame **PubNub** network won't push any events into live feed client will re-subscribe on
/// remote data objects with same time token (if configured).
///
/// This property is set to **310** by default.
@property (nonatomic, assign) NSTimeInterval subscribeMaximumIdleTime;

/// Number of seconds which is used by client during non-subscription operations to check whether response potentially
/// failed with `timeout` or not.
///
/// This is maximum time which client should wait fore response from **PubNub** network before reporting request error.
///
/// This property is set to **10** by default.
@property (nonatomic, assign) NSTimeInterval nonSubscribeRequestTimeout;

/// Number of seconds which is used by server to track whether client still subscribed on remote data objects live feed
/// or not.
///
/// This is time within which **PubNub** network expect to receive heartbeat request from this client. If heartbeat
/// request won't be called in time **PubNub** network will send to other subscribers `timeout` presence event for this \
/// client.
@property (nonatomic, assign) NSInteger presenceHeartbeatValue;

/// Number of seconds which is used by client to issue heartbeat requests to **PubNub** network.
///
/// > Note: This value should be smaller than `presenceHeartbeatValue` for better presence control.
///
/// This property not set by default.
@property (nonatomic, assign) NSInteger presenceHeartbeatInterval;

/// Bitfield which describe client's behaviour on which heartbeat request processing states delegate should be notified.
///
/// This property is set to **PNHeartbeatNotifyFailure** by default to notify only about failed requests.
///
/// - Since: 4.2.7
@property (nonatomic, assign) PNHeartbeatNotificationOptions heartbeatNotificationOptions;

/// Whether client shouldn't send presence `leave` events during un-subscription process.
///
/// If this option is set to `YES` client will simply remove unsubscribed channels / groups from subscription loop
/// without notifying remote subscribers about leave.
///
/// - Since: 4.7.3
@property (nonatomic, assign, getter = shouldSuppressLeaveEvents) BOOL suppressLeaveEvents
    NS_SWIFT_NAME(suppressLeaveEvents);

/// Whether heartbeat list managed manually or not.
///
/// By default client automatically manage list of channels and / or groups used in heartbeat requests when subscribe or
/// unsubscribe.
/// With manual management special methods can be used to add channels and/or groups to heartbeat list.
///
/// - Since: 4.8.0
@property (nonatomic, assign, getter = shouldManagePresenceListManually) BOOL managePresenceListManually
    NS_SWIFT_NAME(managePresenceListManually);

/// Whether client should communicate with **PubNub** network using secured connection or not.
///
/// This property is set to **YES** by default.
@property (nonatomic, assign, getter = isTLSEnabled) BOOL TLSEnabled NS_SWIFT_NAME(TLSEnabled);

/// Whether client should keep previous time token when subscribe on new set of remote data objects live feeds.
///
/// This property is set to **YES** by default.
@property (nonatomic, assign, getter = shouldKeepTimeTokenOnListChange) BOOL keepTimeTokenOnListChange
    NS_SWIFT_NAME(keepTimeTokenOnListChange);

/// Whether client should try to catch up for events which occurred on previously subscribed remote data objects feed
/// while client was off-line.
///
/// Live feeds return in response with events so called 'time token' which allow client to specify target time from
/// which it should expect new events. If property is set to `YES` then client will re-use previously received
/// _timetoken_ and try to receive messages from the past.
///
/// > Warning: If there history / storage feature has been activated for **PubNub** account, some messages can be pushed
/// to it after some period of time and catch up won't be able to receive them.
///
/// This property is set to **YES** by default to try catch up on missed messages (while client has been disconnected
/// because of network issues).
@property (nonatomic, assign, getter = shouldTryCatchUpOnSubscriptionRestore) BOOL catchUpOnSubscriptionRestore
    NS_SWIFT_NAME(catchUpOnSubscriptionRestore);

/// Group identifier which is used to share request cache between application extension and it's containing application.
///
/// When identifier is set it let configure **PubNub** client instance to operate properly when used in application
/// extension context.
/// There only effective API which can operate in this mode w/o limitations is - **publish** API.
///
/// > Important: In this mode client is able to process one API call at time. If multiple requests should be 
/// processed - they should be called from completion block of previous API call.
///
/// > Note: Because **NSURLSession** for application extensions can operate only as background data pull it doesn't have
/// cache (where temporary data can be loaded) in application extension. Shared data container will be used by
/// **NSURLSession** during request processing.
///
/// > Warning: If property is set to valid identifier (registered in 'App Groups' inside of 'Capabilities') client will
/// be limited in functionality because of application extension life-cycle. Any API which pull data from **PubNub**
/// network may be useless because as soon as extension will complete it's tasks system will suspend or terminate it and
/// there will be no way to \c `consume` received data. If extension was able to operate or resumed operation (if wasn't
/// killed by system) requested data will be received and returned in completion block).
///
/// > Warning: Subscribe / unsubscribe API calls will be silently ignored.
///
/// - Since: 4.5.4
@property (nonatomic, copy) NSString *applicationExtensionSharedGroupIdentifier
    NS_SWIFT_NAME(applicationExtensionSharedGroupIdentifier) NS_AVAILABLE(10_10, 8_0);

/// Number of maximum expected messages from **PubNub** network in single response.
///
/// This value can be set to some specific value and in case if with single subscribe request will get number of
/// messages which is larger than specified threshold `PNRequestMessageCountExceededCategory` status category will be
/// triggered - this may mean what history request should be done.
///
/// - Since: 4.5.4
@property (nonatomic, assign) NSUInteger requestMessageCountThreshold
    NS_SWIFT_NAME(requestMessageCountThreshold);

/**
 * @brief Messages de-duplication cache size.
 *
 * @discussion This value is responsible for messages cache size which is used during messages
 * de-duplication rocess. In various situations (for rexample in case of enabled multi-regional
 * support) \b PubNub service may decide to re-send few messages to ensure what they won't be missed
 * (for example when region switched for better performance).
 * De-duplication ensure what at the end listeners won't receive message which has been processed
 * already through real-time channels.
 *
 * @default By default this cache is set to \b 100 messages. It is possible to disable
 * de-duplication by passing \b 0 to this property.
 *
 * @since 4.5.8
 */
/// Messages de-duplication cache size.
///
/// This value is responsible for messages cache size which is used during messages de-duplication process. In various
/// situations (for example in case of enabled multi-regional support) **PubNub** service may decide to re-send few
/// messages to ensure what they won't be missed (for example when region switched for better performance).
/// De-duplication ensure what at the end listeners won't receive message which has been processed already through
/// real-time channels.
///
/// De-duplication cache disabled if **0** has been set for property.
///
/// This property is set to **100** by default.
///
/// - Since: 4.5.8
@property (nonatomic, assign) NSUInteger maximumMessagesCacheSize
    NS_SWIFT_NAME(maximumMessagesCacheSize);

#if TARGET_OS_IOS
/// Whether client should try complete all API call which is done before application will be completely suspended.
///
/// > Note: This property ignored when SDK compiled for application with application extension.
///
/// This property is set to **YES** by default to complete tasks which has been scheduled before `client` resign active.
///
/// - Since: 4.5.0
@property (nonatomic, assign, getter = shouldCompleteRequestsBeforeSuspension) BOOL completeRequestsBeforeSuspension
    NS_SWIFT_NAME(completeRequestsBeforeSuspension);
#endif // TARGET_OS_IOS

/// Whether PNAES should use random initialization vector for each encrypted message.
///
/// > Warning: This option doesn't have backward compatibility and if enabled, older messages can't be decrypted.
///
/// This property is set to **NO** by default.
///
/// - Since: 4.16.0
@property (nonatomic, assign, getter = shouldUseRandomInitializationVector) BOOL useRandomInitializationVector
    DEPRECATED_MSG_ATTRIBUTE("This property deprecated and will be removed with next major update. Please use "
                             "`cryptoModule` instead.");

/// How many times **PubNub** client should retry `file message publish` before returning error.
///
/// > Note: Set this property to the **0** to disable automatic `file message publish` retry attempts.
///
/// This property is set to **5** by default.
///
/// - Since: 4.16.0
@property (nonatomic, assign) NSUInteger fileMessagePublishRetryLimit;

/// Create **PubNub** configuration wrapper instance.
///
/// - Throws: Exception in case if `userID` is empty string.
///
/// - Parameters:
///   - publishKey: Key which is used to push data / state to the **PubNub** network.
///   - subscribeKey: Key which is used to fetch data / state from the **PubNub** network.
///   - uuid: Unique client identifier used to identify concrete client user from another which currently use
///   **PubNub** services.
/// - Returns: Initialized **PubNub** configuration wrapper instance.
+ (instancetype)configurationWithPublishKey:(NSString *)publishKey
                               subscribeKey:(NSString *)subscribeKey
                                       uuid:(NSString *)uuid
    NS_SWIFT_NAME(init(publishKey:subscribeKey:uuid:))
    DEPRECATED_MSG_ATTRIBUTE("This method deprecated and will be removed with next major update. Please use "
                             "`+ publishKey:subscribeKey:userID:` instead.");

/// Create **PubNub** configuration wrapper instance.
///
/// - Throws: Exception in case if `userID` is empty string.
///
/// - Parameters:
///   - publishKey: Key which is used to push data / state to the **PubNub** network.
///   - subscribeKey: Key which is used to fetch data / state from the **PubNub** network.
///   - userID: Unique client identifier used to identify concrete client user from another which currently use
///   **PubNub** services.
/// - Returns: Initialized **PubNub** configuration wrapper instance.
+ (instancetype)configurationWithPublishKey:(NSString *)publishKey
                               subscribeKey:(NSString *)subscribeKey
                                     userID:(NSString *)userID
    NS_SWIFT_NAME(init(publishKey:subscribeKey:userID:));

#pragma mark -


@end

NS_ASSUME_NONNULL_END
