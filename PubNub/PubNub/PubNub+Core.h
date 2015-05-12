#import <Foundation/Foundation.h>
#import "PNStructures.h"


///------------------------------------------------
/// @name Information and configuration
///------------------------------------------------

/**
 @brief      PubNub client core class which is responsible for communication with \b PubNub 
             services and responses processing.
 @discussion Basically used by \b PubNub categories (each for own API group) and manage 
             communication with \b PubNub service and share user-specified configuration.

 @author Sergey Mamontov
 @since 4.0
 @copyright © 2009-2015 PubNub, Inc.
 */
@interface PubNub : NSObject

/**
 @brief   Reference on host name or IP address which should be used by client to get access to
          \b PubNub services.
 
 @default Client will use it's own constant (\b pubsub.pubnub.com) value if origin not
          specified.

 @since 4.0
 */
@property (nonatomic, copy) NSString *origin;

/**
 @brief   Reference on key which is used to push data/state to \b PubNub service.
 @note    This key can be obtained on PubNub's administration portal after free registration
          https://admin.pubnub.com
 
 @default Client will use it's own constant (\b demo) value if origin not specified.
 
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
 @brief      Reference on key which is used along with every request to \b PubNub service to
             identify client user.
 @discussion \b PubNub service provide \ PAM (PubNub Access Manager) functionality which allow
             to specify access rights to access \b PubNub services with provided \c publishKey
             and \c subscribeKey keys. Access can be limited to concrete users. \b PAM system
             use this key to check whether client user has rights to access to required service
             or not.
 
 @default    By default this value set to \b nil.
 
 @since 4.0
 */
@property (nonatomic, copy) NSString *authorizationKey;

/**
 @brief      Reference on unique client identifier used to identify concrete client user from
             another which currently use \b PubNub services.
 @discussion This value is different from \c authorizationKey (which is used only by \b PAM) and
             represent concrete client across server. This identifier is used for presence events
             to tell what some client joined or leaved live feed.
 @warning    There can't be two same client identifiers online at the same time.
 
 @default    Client will use it's own-generated value if won't be specified by user.
 
 @since 4.0
 */
@property (nonatomic, copy, setter = setUUID:) NSString *uuid;

/**
 @brief      Reference on number of seconds which is used during initial subscription on remote 
             data objects live feed.
 @discussion Initial subscription process should provide immediately response with data which 
             should be used to perform long-poll request. If in specified time frame client won't
             receive response from server it will report about subscription error.
 
 @default    Client will use it's own constant (\b 10 seconds) value if origin not specified.
 
 @since 4.0
 */
@property (nonatomic, assign) NSTimeInterval subscribeRequestTimeout;

/**
 @brief      Reference on number of seconds which is used by client during non-subscription 
             operations to check whether response potentially failed with 'timeout' or not.
 @discussion This is maximum time which client should wait fore response from \b PubNub service
             before reporting reuest error.
 
 @default    Client will use it's own constant (\b 10 seconds) value if origin not specified.
 
 @since 4.0
 */
@property (nonatomic, assign) NSTimeInterval nonSubscribeRequestTimeout;

/**
 @brief      Reference on number of seconds which is used by server to track whether client still
             subscribed on remote data objects live feed or not.
 @discussion This is time within which \b PubNub service expect to receive heartbeat request from
             this client. If heartbeat request won't be called in time \b PubNub service will 
             send to other subscribers \c 'timeout' presence event for this client.
 @note       This value can't be smaller then \b 5 seconds and larget then \b 300 seconds and 
             will be reset to it automatically.
 
 @default    By default heartbeat functionality disabled.
 
 @since 4.0
 */
@property (nonatomic, assign) NSInteger presenceHeartbeatValue;

/**
 @brief   Reference on number of seconds which is used by client to issue heartbeat requests to
          \b PubNub service.
 @note    This vlaue should be smaller then \c presenceHeartbeatTimeout for better presence
          control.
 
 @default By default heartbeat functionality disabled.
 
 @since 4.0
 */
@property (nonatomic, assign) NSInteger presenceHeartbeatInterval;

/**
 @brief   Stores whether client should communicate with \b PubNub services using secured
          connection or not.
 
 @default By default client use \b YES to secure communication with \b PubNub services.
 
 @since 4.0
 */
@property (nonatomic, assign, getter = shouldUseSecureConnection) BOOL secureConnection;

/**
 @brief   Stores whether client is permitted to use insecure connection in case if it failed to
          use secured connection to communicate with \b PubNub services.
 
 @default By default client use \b NO and will report about error in case if any secure
          connection handshakes will appear.
 
 @since 4.0
 */
@property (nonatomic, assign, getter = canFallbackToInsecureConnection) BOOL fallbackToInsecureConnection;

/**
 @brief      Stores whether client should restore subscription on remote data objects live feed 
             after network connection restoring or not.
 @discussion If set to \c YES as soon as network connection will be restored client will restore
             subscription to previously subscribed remote data objects live feeds.
 
 @default    By default client use \b YES to restore subscription on remote data objects live 
             feeds.
 
 @since 4.0
 */
@property (nonatomic, assign, getter = shouldRestoreSubscription) BOOL restoreSubscription;

/**
 @brief      Stores whether client should try to catch up for events which occurred on previously
             subscribed remote data objects feed while client was off-line.
 @discussion Live feeds return in response with events so called 'time token' which allow client
             to specify target time from which it should expect new events. If property is set to
             \c YES then client will re-use previously received 'time token' and try to receive
             messages from the past.
 @warning    If there history/storage feature has been activated for \b PubNub account, some 
             messages can be pushed to it after some period of time and catch up won't be able to
             receive them.
 
 @since 4.0
 */
@property (nonatomic, assign, getter = shouldTryCatchUpOnSubscriptionRestore) BOOL catchUpOnSubscriptionRestore;

/**
 @brief      Reference on queue on which completion/processing blocks will be called.
 @discussion At the end of each operation completion blocks will be called asynchronously on
             provided queue.
 
 @default    By default all callback blocks will be called on main queue 
             (\c dispatch_get_main_queue()).
 
 @since 4.0
 */
@property (nonatomic, strong) dispatch_queue_t callbackQueue;

/**
 @brief Reference on handler block which will be called on main or \c callbackQueue when new message
        will arrive from live feed on which client subscribed at this moment.
 
 @since 4.0
 */
@property (nonatomic, copy) PNEventHandlingBlock messageHandlingBlock;

/**
 @brief Reference on handler block which will be called on main or \c callbackQueue when new 
        presence even will arrive from live feed on which client subscribed at this moment.
 
 @since 4.0
 */
@property (nonatomic, copy) PNEventHandlingBlock presenceEventHandlingBlock;


///------------------------------------------------
/// @name Initialization
///------------------------------------------------

/**
 @brief      Construct new \b PubNub client instance with pre-defined publish and subscrib keys.
 @discussion If all keys will be specified, client will be able to read and modify data on 
             \b PubNub service.
 @note       All required keys can be found on https://admin.pubnub.com
 
 @code
 @endcode
 \b Example:
 @code
 PubNub *client = [PubNub clientWithPublishKey:@"demo" andSubscribeKey:@"demo"];
 @endcode
 
 Also client can be initialized with default keys using this example:
 @code
 PubNub *client = [PubNub new];
 @endcode

 @param publishKey   Key which allow client to use data push API.
 @param subscribeKey Key which allow client to subscribe on live feeds pushed from \b PubNub 
                     service.

 @return Configured and ready to use \b PubNub client.
 @since 4.0
*/
+ (instancetype)clientWithPublishKey:(NSString *)publishKey
                     andSubscribeKey:(NSString *)subscribeKey;

#pragma mark -


@end
