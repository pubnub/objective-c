#import "PNBasePublishRequest.h"
#import "PNCryptoProvider.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Private interface declaration

/// Base `publish` request private extension.
///
/// - Since: 4.15.0
/// - Copyright: 2010-2023 PubNub, Inc.
@interface PNBasePublishRequest (Private)


#pragma mark - Information

/// Pre-process message content basing on request's requirements.
@property (nonatomic, nullable, readonly, strong) id preFormattedMessage;

/// Crypto module for data processing.
///
/// **PubNub** client uses this instance to _encrypt_ and _decrypt_ data that has been sent and received from the
/// **PubNub** network.
@property(nonatomic, nullable, strong) id<PNCryptoProvider> cryptoModule;

/// Whether message should be compressed before sending or not.
@property (nonatomic, assign, getter = shouldCompress) BOOL compress;

/// Dictionary with payloads for different vendors (Apple with `'apns'` key and Google with `'gcm'`).
@property (nonatomic, nullable, strong) NSDictionary *payloads;

/// Publish request sequence number.
@property (nonatomic, assign) NSUInteger sequenceNumber;

/// Whether request is repeatedly sent to retry after recent failure.
@property (nonatomic, assign) BOOL retried;


#pragma mark - Initialization & Configuration

/// Initialize `publish` request.
///
/// - Parameter channel: Name of channel to which message should be published.
/// - Returns: Initialized `publish` request instance.
- (instancetype)initWithChannel:(NSString *)channel;


#pragma mark - Helpers

/// Create JSON objects which should be published to specified `channel`.
///
/// - Parameters:
///   - message: User-provided message which should be sent to channel and available for rest subscribers.
///   - payloads: Mobile notification payloads which should be merged with original `message`.
/// - Returns: JSON string (encrypted if required) which will be published to specified `channel`.
- (NSString *)JSONFromMessage:(id)message withPushNotificationsPayload:(NSDictionary *)payloads;

/// Merge user-specified message with push payloads into single message which will be processed on the **PubNub**
/// service.
///
/// In case if aside from `message` has been passed `payloads` this method will merge them into format known by the
/// **PubNub** service and will cause further push distribution to specified vendors.
///
/// - Parameters:
///   - message: Message which should be merged with `payloads`.
///   - payloads: `NSDictionary` with payloads for different push notification services (Apple with `'apns'` key and
///   Google with `'gcm'`).
/// - Returns: Merged message or original message if there is no data in `payloads`.
- (NSDictionary<NSString *, id> *)mergedMessage:(nullable id)message
                          withMobilePushPayload:(nullable NSDictionary<NSString *, id> *)payloads;

/// Try perform encryption of data which should be pushed to **PubNub** services.
///
/// - Parameters:
///   - message: Data which crypto module should try to encrypt.
///   - error: Pointer into which data encryption error will be passed.
/// - Returns: Encrypted Base64-encoded string or original message.
- (nullable NSString *)encryptedMessage:(NSString *)message
                                  error:(NSError **)error;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
