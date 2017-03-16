#import <Foundation/Foundation.h>
#import "PNStructures.h"


NS_ASSUME_NONNULL_BEGIN

/**
 @brief      \b PubNub client configuration wrapper.
 @discussion Use this instance to provide values which should be by client to communicate with \b PubNub
             network.
 
 @author Sergey Mamontov
 @since 4.0
 @copyright © 2009-2017 PubNub, Inc.
 */
@interface PNConfiguration : NSObject


///------------------------------------------------
/// @name Initialization and Configuration
///------------------------------------------------

/**
 @brief   Reference on host name or IP address which should be used by client to get access to \b PubNub 
          services.
 
 @default Client will use it's own constant (\b pubsub.pubnub.com) value if origin not specified.

 @since 4.0
 */
@property (nonatomic, copy) NSString *origin;

/**
 @brief   Reference on key which is used to push data/state to \b PubNub service.
 @note    This key can be obtained on PubNub's administration portal after free registration
          https://admin.pubnub.com
 
 @since 4.0
 */
@property (nonatomic, copy) NSString *publishKey;

/**
 @brief   Reference on key which is used to fetch data/state from \b PubNub service.
 @note    This key can be obtained on PubNub's administration portal after free registration
          https://admin.pubnub.com
 
 @default Client will use it's own constant (\b demo) value if origin not specified.
 
 @since 4.0
 */
@property (nonatomic, copy) NSString *subscribeKey;

/**
 @brief      Reference on key which is used along with every request to \b PubNub service to identify client 
             user.
 @discussion \b PubNub service provide \b PAM (PubNub Access Manager) functionality which allow to specify 
             access rights to access \b PubNub services with provided \c publishKey and \c subscribeKey keys. 
             Access can be limited to concrete users. \b PAM system use this key to check whether client user
             has rights to access to required service or not.
 
 @default    By default this value set to \b nil.
 
 @since 4.0
 */
@property (nonatomic, nullable, copy) NSString *authKey;

/**
 @brief      Reference on unique client identifier used to identify concrete client user from another which 
             currently use \b PubNub services.
 @discussion This value is different from \c authKey (which is used only by \b PAM) and represent concrete 
             client across server. This identifier is used for presence events to tell what some client joined
             or leaved live feed.
 @warning    There can't be two same client identifiers online at the same time.
 
 @default    Client will use it's own-generated value if won't be specified by user.
 
 @since 4.0
 */
@property (nonatomic, copy, setter = setUUID:) NSString *uuid;

/**
 @brief       Reference on encryption key.
 @discussion  Key which is used to encrypt messages pushed to \b PubNub service and decrypt messages received
              from live feeds on which client subscribed at this moment.
 
 @since 4.0
 */
@property (nonatomic, nullable, copy) NSString *cipherKey;

/**
 @brief Stores reference on unique device identifier based on bundle identifier used by software vendor.

 @since 4.0
 */
@property (nonatomic, readonly, copy) NSString *deviceID;

/**
 @brief      Stores reference on maximum number of seconds which client should wait for events from live feed.
 @discussion By default value is set to \b 310 seconds. If in specified time frame \b PubNub service won't 
             push any events into live feed client will re-subscribe on remote data objects with same time 
             token (if configured).
 
 @since 4.0
 */
@property (nonatomic, assign) NSTimeInterval subscribeMaximumIdleTime;

/**
 @brief      Reference on number of seconds which is used by client during non-subscription operations to 
             check whether response potentially failed with 'timeout' or not.
 @discussion This is maximum time which client should wait fore response from \b PubNub service before 
             reporting reuest error.
 
 @default    Client will use it's own constant (\b 10 seconds) value if origin not specified.
 
 @since 4.0
 */
@property (nonatomic, assign) NSTimeInterval nonSubscribeRequestTimeout;

/**
 @brief      Reference on number of seconds which is used by server to track whether client still subscribed 
             on remote data objects live feed or not.
 @discussion This is time within which \b PubNub service expect to receive heartbeat request from this client.
             If heartbeat request won't be called in time \b PubNub service will send to other subscribers 
             \c 'timeout' presence event for this client.
 @note       This value can't be smaller then \b 5 seconds or larger than \b 300 seconds and will be reset to 
             it automatically.
 
 @default    By default heartbeat functionality disabled.
 
 @since 4.0
 */
@property (nonatomic, assign) NSInteger presenceHeartbeatValue;

/**
 @brief   Reference on number of seconds which is used by client to issue heartbeat requests to \b PubNub 
          service.
 @note    This value should be smaller then \c presenceHeartbeatValue for better presence control.
 
 @default By default heartbeat functionality disabled.
 
 @since 4.0
 */
@property (nonatomic, assign) NSInteger presenceHeartbeatInterval;

/**
 @brief  Stores bitfield which describe client's behavior on which heartbeat request processing states 
         delegate should be notified.
 
 @default By default client use \c PNHeartbeatNotifyFailure to notify only about failed requests.
 
 @since 4.2.7
 */
@property (nonatomic, assign) PNHeartbeatNotificationOptions heartbeatNotificationOptions;

/**
 @brief   Stores whether client should communicate with \b PubNub services using secured connection or not.
 
 @default By default client use \b YES to secure communication with \b PubNub services.
 
 @since 4.0
 */
@property (nonatomic, assign, getter = isTLSEnabled) BOOL TLSEnabled NS_SWIFT_NAME(TLSEnabled);

/**
 @brief  Stores whether client should keep previous time token when subscribe on new set of remote data 
         objects live feeds.
 
 @default By default client use \b YES to and previous time token will be used during subscription 
          on new data objects.
 
 @since 4.0
 */
@property (nonatomic, assign, getter = shouldKeepTimeTokenOnListChange) BOOL keepTimeTokenOnListChange NS_SWIFT_NAME(keepTimeTokenOnListChange);

/**
 @brief      Stores whether client should restore subscription on remote data objects live feed after network 
             connection restoring or not.
 @discussion If set to \c YES as soon as network connection will be restored client will restore subscription
             to previously subscribed remote data objects live feeds.
 
 @default    By default client use \b YES to restore subscription on remote data objects live feeds.
 
 @since 4.0
 */
@property (nonatomic, assign, getter = shouldRestoreSubscription) BOOL restoreSubscription NS_SWIFT_NAME(restoreSubscription) 
          DEPRECATED_MSG_ATTRIBUTE("This option will be deprecated in upcoming releases. Client will restore "
                                   "it's subscription after network issues automatically.");

/**
 @brief      Stores whether client should try to catch up for events which occurred on previously subscribed 
             remote data objects feed while client was off-line.
 @discussion Live feeds return in response with events so called 'time token' which allow client to specify 
             target time from which it should expect new events. If property is set to \c YES then client will
             re-use previously received 'time token' and try to receive messages from the past.
 @warning    If there history/storage feature has been activated for \b PubNub account, some messages can be 
             pushed to it after some period of time and catch up won't be able to receive them.
 
 @default    By default client use \b YES to try catch up on missed messages (while client has been 
             disconnected because of network issues).
 
 @since 4.0
 */
@property (nonatomic, assign, getter = shouldTryCatchUpOnSubscriptionRestore) BOOL catchUpOnSubscriptionRestore NS_SWIFT_NAME(catchUpOnSubscriptionRestore);

/**
 @brief      Stores reference on group identifier which is used to share request cache between application 
             extension and it's containing application.
 @discussion When identifier is set it let configure \b PubNub client instance to operate properly when used 
             in application extension context.
 @discussion There only effective API which can operate in this mode w/o limitations is - \b publish API.
 @discussion \b Important: In this mode client is able to process one API call at time. If multiple requests 
             should be processed - they should be called from completion block of previous API call.
 @note       Because \b NSURLSession for application extensions can operate only as background data pull it 
             doesn't have cache (where temporary data can be loaded) in application extension. Shared data 
             container will be used by \b NSURLSession during request processing.
 @warning    If property is set to valid identifier (registered in 'App Groups' inside of 'Capabilities')
             client will be limited in functionality because of application extension life-cycle. Any API 
             which pull data from \b PubNub service may be useless because as soon as extension will complete 
             it's tasks system will suspend or terminate it and there will be no way to \c 'consume' received 
             data. If extension was able to operate or resumed operation (if wasn't killed by system) 
             requested data will be received and returned in completion block).
 @warning    Subscribe / unsubscribe API calls will be silently ignored.
 
 @since 4.5.4
 */
@property (nonatomic, copy) NSString *applicationExtensionSharedGroupIdentifier NS_SWIFT_NAME(applicationExtensionSharedGroupIdentifier) NS_AVAILABLE(10_10, 8_0);

/**
 @brief      Number of maximum expected messages from \b PubNub service in single response.
 @discussion This value can be set to some specific value and in case if with single subscribe request will 
             get number of messages which is larger than specified threashold 
             \c PNRequestMessageCountExceededCategory status category will be triggered - this may mean what 
             history request should be done.
 
 @since 4.5.4
 */
@property (nonatomic, assign) NSUInteger requestMessageCountThreshold NS_SWIFT_NAME(requestMessageCountThreshold);

/**
 @brief      Messages de-duplication cache size.
 @discussion This value is responsible for messages cache size which is used during messages de-duplication 
             process. In various situations (for rexample in case of enabled multi-regional support) \b PubNub
             service may decide to re-send few messages to ensure what they won't be missed (for example when 
             region switched for better performance).
             De-duplication ensure what at the end listeners won't receive message which has been processed 
             already through real-time channels.
 @default    By default this cache is set to \b 100 messages. It is possible to disable de-duplication by 
             passing \b 0 to this property.
 
 @since 4.5.8
 */
@property (nonatomic, assign) NSUInteger maximumMessagesCacheSize NS_SWIFT_NAME(maximumMessagesCacheSize);

#if TARGET_OS_IOS
/**
 @brief  Stores whether client should try complete all API call which is done before application will be 
         completelly suspended.
 
 @default By default \c client use \b YES to complete tasks which has been scheduled before \c client resign 
          active.
 
 @note    This property ignored when SDK compiled for application with application extension.
 
 @since 4.5.0
 */
@property (nonatomic, assign, getter = shouldCompleteRequestsBeforeSuspension) BOOL completeRequestsBeforeSuspension NS_SWIFT_NAME(completeRequestsBeforeSuspension);
#endif // TARGET_OS_IOS

/**
 @brief  Stores whether client should strip out received messages (real-time and history) from data which has 
         been appended by \c client (like mobile payload for push notifications).
 
 @default By default \c client use \b YES to strip client's data from message and return object with same data
          type and content as it has been sent.
 
 @since 4.5.0
 */
@property (nonatomic, assign, getter = shouldStripMobilePayload) BOOL stripMobilePayload NS_SWIFT_NAME(stripMobilePayload)
          DEPRECATED_MSG_ATTRIBUTE("This option deprecated and will be removed in next general SDK update.");

/**
 @brief  Construct configuration instance using minimal required data.
 
 @param publishKey   Key which allow client to use data push API.
 @param subscribeKey Key which allow client to subscribe on live feeds pushed from \b PubNub service.
 
 @return Configured and ready to se configuration instance.
 
 @since 4.0
 */
+ (instancetype)configurationWithPublishKey:(NSString *)publishKey subscribeKey:(NSString *)subscribeKey NS_SWIFT_NAME(init(publishKey:subscribeKey:));

#pragma mark -


@end

NS_ASSUME_NONNULL_END
