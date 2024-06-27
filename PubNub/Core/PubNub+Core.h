#import <Foundation/Foundation.h>
#import <PubNub/PNAcknowledgmentStatus.h>
#import <PubNub/PNClientInformation.h>
#import <PubNub/PNErrorStatus.h>
#import <PubNub/PNStructures.h>
#ifndef PUBNUB_DISABLE_LOGGER
#import <PubNub/PNLLogger.h>
#endif // PUBNUB_DISABLE_LOGGER


#pragma mark Class forward

@class PNClientInformation, PNConfiguration;


NS_ASSUME_NONNULL_BEGIN

/// **PubNub** client core class which is responsible for communication with **PubNub** network and provide responses
/// back to completion block / delegates.
///
/// Basically used by **PubNub** categories (each for own API group) and manage communication with **PubNub** network
/// and share user-specified configuration.
@interface PubNub : NSObject


#pragma mark - Information

#ifndef PUBNUB_DISABLE_LOGGER
/// **PubNub** client logger instance which can be used to add additional logs into console (if enabled) and file
/// (if enabled).
@property (nonatomic, readonly, strong) PNLLogger *logger;
#endif // PUBNUB_DISABLE_LOGGER

/// Basic information about **PubNub** client.
///
/// - Returns: Instance which hold information about **PubNub** client.
+ (PNClientInformation *)information __attribute__((const));

/// Current client's configuration.
///
/// - Returns: Copy of the currently used configuration.
- (PNConfiguration *)currentConfiguration;

/// User ID which has been used during client initialization.
///
/// - Returns: User-provided unique user identifier.
- (NSString *)uuid
    DEPRECATED_MSG_ATTRIBUTE("This method deprecated and will be removed with next major update. Please use `userID` "
                             "instead.");

/// User ID which has been used during client initialization.
///
/// - Returns: User-provided unique user identifier.
- (NSString *)userID;


#pragma mark - Initialization and Configuration

/// Create new **PubNub** client instance with pre-defined configuration.
///
/// If all keys will be specified, client will be able to read and modify data in **PubNub** network.
///
/// > Note: Client will make configuration deep copy and further changes in `PNConfiguration` after it has been passed
/// to the client won't take any effect on client.
///
/// > Note: All completion block and delegate callbacks will be called on the main queue.
///
/// > Note: All required keys can be found on https://admin.pubnub.com
///
/// #### Example:
/// ```objc
/// PNConfiguration *configuration = [PNConfiguration configurationWithPublishKey:@"demo"
///                                                                  subscribeKey:@"demo"
///                                                                        userID:@"user"];
/// PubNub *client = [PubNub clientWithConfiguration:configuration];
/// ```
/// - Parameter configuration: User-provided information about how client should operate and handle events.
/// - Returns: Initialized **PubNub** client instance.
+ (instancetype)clientWithConfiguration:(PNConfiguration *)configuration
    NS_SWIFT_NAME(clientWithConfiguration(_:));

/// Create new **PubNub** client instance with pre-defined configuration.
///
/// If all keys will be specified, client will be able to read and modify data in **PubNub** network.
///
/// > Note: Client will make configuration deep copy and further changes in `PNConfiguration` after it has been passed
/// to the client won't take any effect on client.
///
/// > Note: If `queue` is nil, completion blocks and delegate callbacks will be called on the main queue.
///
/// > Note: All required keys can be found on https://admin.pubnub.com
///
/// #### Example:
/// ```objc
/// PNConfiguration *configuration = [PNConfiguration configurationWithPublishKey:@"demo"
///                                                                  subscribeKey:@"demo"
///                                                                        userID:@"user"];
/// dispatch_queue_t queue = dispatch_queue_create("com.my-app.callback-queue", DISPATCH_QUEUE_SERIAL);
/// PubNub *client = [PubNub clientWithConfiguration:configuration callbackQueue:queue];
/// ```
/// - Parameters:
///   - configuration: User-provided information about how client should operate and handle events.
///   - callbackQueue: Queue which is used by client for completion block and delegate calls. By default set to
///   **main**.
/// - Returns: Initialized **PubNub** client instance.
+ (instancetype)clientWithConfiguration:(PNConfiguration *)configuration
                          callbackQueue:(nullable dispatch_queue_t)callbackQueue
    NS_SWIFT_NAME(clientWithConfiguration(_:callbackQueue:));

/// Make copy of client with it's current state using new configuration.
///
/// Allow to retrieve references on the client, which will have the same state as the receiver but will use updated
/// configuration. If authorization and userID keys have been changed while subscribed, this method will trigger the
/// leave presence event on behalf of the current userID and subscribe using the new one.
///
/// > Note: Copy will be returned asynchronous, because some operations may require communication with **PubNub**
/// network (like switching active `userID` while subscribed).
///
/// > Note: Re-subscription with new `userID` will be done using catchup and all messages which has been sent while
/// client changed configuration will be handled.
///
/// > Note: All listeners will be copied to new client.
///
/// #### Example:
/// ```objc
/// __weak __typeof(self) weakSelf = self;
/// PNConfiguration *configuration = [self.pubnub currentConfiguration];
/// configuration.TLSEnabled = NO;
/// [self.client copyWithConfiguration:configuration completion:^(PubNub *pubnub) {
///     // Store reference on new client with updated configuration.
///     weakSelf.pubnub = pubnub;
/// }];
/// ```
/// - Parameters:
///   - configuration: User-provided information about how client should operate and handle events.
///   - block: Copy completion block which will pass new **PubNub** client instance which use updated `configuration`.
- (void)copyWithConfiguration:(PNConfiguration *)configuration completion:(void(^)(PubNub *client))block
    NS_SWIFT_NAME(copyWithConfiguration(_:completion:));

/// Make copy of client with it's current state using new configuration.
///
/// Allow to retrieve references on the client, which will have the same state as the receiver but will use updated
/// configuration. If authorization and userID keys have been changed while subscribed, this method will trigger the
/// leave presence event on behalf of the current userID and subscribe using the new one.
///
/// > Note: Copy will be returned asynchronous, because some operations may require communication with **PubNub**
/// network (like switching active `userID` while subscribed).
///
/// > Note: Re-subscription with new `userID` will be done using catchup and all messages which has been sent while
/// client changed configuration will be handled.
///
/// > Note: All listeners will be copied to new client.
///
/// #### Example:
/// ```objc
/// __weak __typeof(self) weakSelf = self;
/// dispatch_queue_t queue = dispatch_queue_create("com.my-app.callback-queue", DISPATCH_QUEUE_SERIAL);
/// PNConfiguration *configuration = [self.pubnub currentConfiguration];
/// configuration.TLSEnabled = NO;
/// [self.pubnub copyWithConfiguration:configuration callbackQueue:queue completion:^(PubNub *pubnub) {
///     // Store reference on new client with updated configuration.
///     weakSelf.pubnub = pubnub;
/// }];
/// ```
/// - Parameters:
///   - configuration: User-provided information about how client should operate and handle events.
///   - callbackQueue: Queue which is used by client for completion block and delegate calls. By default set to
///   **main**.
///   - block: Copy completion block which will pass new **PubNub** client instance which use updated `configuration`.
- (void)copyWithConfiguration:(PNConfiguration *)configuration
                callbackQueue:(nullable dispatch_queue_t)callbackQueue
                   completion:(void(^)(PubNub *client))block
    NS_SWIFT_NAME(copyWithConfiguration(_:callbackQueue:completion:));

#pragma mark -


@end

NS_ASSUME_NONNULL_END
